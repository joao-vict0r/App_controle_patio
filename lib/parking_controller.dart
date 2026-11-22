import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'parking_models.dart';

class ParkingController extends ChangeNotifier {
  static const _sessionsKey = 'parking_sessions_v1';
  static const _membersKey = 'parking_members_v1';
  static const _partnersKey = 'parking_partners_v1';
  static const _rateKey = 'parking_hourly_rate_v1';
  static const _capacityKey = 'parking_capacity_v1';
  static const _sectorCapacitiesKey = 'parking_sector_capacities_v1';

  List<ParkingSession> sessions = [];
  List<MonthlyMember> members = [];
  List<ParkingPartner> partners = [];
  double hourlyRate = 12;
  Map<String, int> sectorCapacities = {'A': 8, 'B': 8, 'VIP': 4};

  int get parkingCapacity =>
      sectorCapacities.values.fold(0, (total, value) => total + value);

  int get freeSpaces {
    final available = parkingCapacity - openSessions.length;
    return available < 0 ? 0 : available;
  }

  double get occupancyRate => parkingCapacity == 0
      ? 0
      : (openSessions.length / parkingCapacity).clamp(0, 1).toDouble();

  List<ParkingSession> get openSessions =>
      sessions.where((session) => session.isOpen).toList()
        ..sort((a, b) => b.entryAt.compareTo(a.entryAt));

  List<ParkingSession> get closedSessions =>
      sessions.where((session) => !session.isOpen).toList()
        ..sort((a, b) => b.exitAt!.compareTo(a.exitAt!));

  List<ParkingSession> get ticketSessions => closedSessions
      .where((session) => session.partnerTicket?.isNotEmpty ?? false)
      .toList();

  List<MonthlyMember> get activeMembers =>
      members.where((member) => member.isValidAt(DateTime.now())).toList();

  double get todayRevenue => sessions
      .where(
        (session) =>
            session.exitAt != null &&
            _isSameDay(session.exitAt!, DateTime.now()),
      )
      .fold(0, (total, session) => total + (session.paidAmount ?? 0));

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    sessions = _decodeList(
      preferences.getString(_sessionsKey),
      ParkingSession.fromJson,
    );
    members = _decodeList(
      preferences.getString(_membersKey),
      MonthlyMember.fromJson,
    );
    partners = _decodeList(
      preferences.getString(_partnersKey),
      ParkingPartner.fromJson,
    );
    hourlyRate = preferences.getDouble(_rateKey) ?? hourlyRate;
    final storedSectorCapacities = preferences.getString(_sectorCapacitiesKey);
    if (storedSectorCapacities == null) {
      sectorCapacities = _splitCapacity(preferences.getInt(_capacityKey) ?? 20);
    } else {
      final stored = Map<String, dynamic>.from(
        jsonDecode(storedSectorCapacities) as Map,
      );
      sectorCapacities = {
        'A': (stored['A'] as num?)?.toInt() ?? 0,
        'B': (stored['B'] as num?)?.toInt() ?? 0,
        'VIP': (stored['VIP'] as num?)?.toInt() ?? 0,
      };
    }
    final migratedSpots = _assignMissingSpots();
    if (migratedSpots) await _saveSessions();
    notifyListeners();
  }

  bool _assignMissingSpots() {
    final occupied = openSessions
        .map((session) => session.spotNumber)
        .whereType<int>()
        .toSet();
    var changed = false;
    for (var index = 0; index < sessions.length; index++) {
      final session = sessions[index];
      if (!session.isOpen || session.spotNumber != null) continue;
      final available = _firstAvailableSpot(occupied);
      if (available == null) break;
      sessions[index] = session.copyWith(spotNumber: available);
      occupied.add(available);
      changed = true;
    }
    return changed;
  }

  int? _firstAvailableSpot(Set<int> occupied) {
    for (var number = 1; number <= parkingCapacity; number++) {
      if (!occupied.contains(number)) return number;
    }
    return null;
  }

  List<T> _decodeList<T>(
    String? encoded,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (encoded == null || encoded.isEmpty) return [];
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  bool hasOpenPlate(String plate) =>
      openSessions.any((session) => session.plate == normalizePlate(plate));

  MonthlyMember? validMemberFor(String plate) {
    final normalizedPlate = normalizePlate(plate);
    for (final member in members) {
      if (member.plate == normalizedPlate && member.isValidAt(DateTime.now())) {
        return member;
      }
    }
    return null;
  }

  Future<ParkingSession> registerEntry({
    required String plate,
    required String vehicleType,
  }) async {
    final normalizedPlate = normalizePlate(plate);
    if (normalizedPlate.isEmpty) throw ArgumentError('Informe a placa.');
    if (hasOpenPlate(normalizedPlate)) {
      throw StateError('Já existe uma entrada em aberto para esta placa.');
    }
    final availableSpot = _firstAvailableSpot(
      openSessions
          .map((session) => session.spotNumber)
          .whereType<int>()
          .toSet(),
    );
    if (availableSpot == null) {
      throw StateError('O estacionamento está cheio. Não há vagas livres.');
    }
    final member = validMemberFor(normalizedPlate);
    final now = DateTime.now();
    final session = ParkingSession(
      id: now.microsecondsSinceEpoch.toString(),
      plate: normalizedPlate,
      vehicleType: vehicleType,
      ticketNumber:
          'PT-${now.millisecondsSinceEpoch.toRadixString(36).toUpperCase()}',
      entryAt: now,
      isMonthly: member != null,
      spotNumber: availableSpot,
      memberName: member?.name,
    );
    sessions.add(session);
    await _saveSessions();
    notifyListeners();
    return session;
  }

  Future<void> registerExit({
    required String sessionId,
    required double paidAmount,
    required double discountAmount,
    String? partnerName,
    String? partnerTicket,
  }) async {
    final index = sessions.indexWhere((session) => session.id == sessionId);
    if (index < 0 || !sessions[index].isOpen) {
      throw StateError('Este veículo não está mais no pátio.');
    }
    sessions[index] = sessions[index].copyWith(
      exitAt: DateTime.now(),
      paidAmount: paidAmount,
      discountAmount: discountAmount,
      partnerName: partnerName,
      partnerTicket: partnerTicket,
    );
    await _saveSessions();
    notifyListeners();
  }

  Future<void> addMember({
    required String name,
    required String plate,
    required String phone,
    required DateTime validUntil,
  }) async {
    final normalizedPlate = normalizePlate(plate);
    if (normalizedPlate.isEmpty || name.trim().isEmpty) {
      throw ArgumentError('Informe o nome e a placa do mensalista.');
    }
    if (members.any((member) => member.plate == normalizedPlate)) {
      throw StateError('Já existe um cadastro para esta placa.');
    }
    members.add(
      MonthlyMember(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        plate: normalizedPlate,
        phone: phone.trim(),
        validUntil: validUntil,
      ),
    );
    await _saveMembers();
    notifyListeners();
  }

  Future<void> updateMember({
    required String id,
    required String name,
    required String plate,
    required String phone,
    required DateTime validUntil,
  }) async {
    final normalizedPlate = normalizePlate(plate);
    if (normalizedPlate.isEmpty || name.trim().isEmpty) {
      throw ArgumentError('Informe o nome e a placa do mensalista.');
    }
    if (members.any(
      (member) => member.id != id && member.plate == normalizedPlate,
    )) {
      throw StateError('Já existe um cadastro para esta placa.');
    }
    final index = members.indexWhere((member) => member.id == id);
    if (index < 0) throw StateError('Cadastro de mensalista não encontrado.');
    members[index] = MonthlyMember(
      id: id,
      name: name.trim(),
      plate: normalizedPlate,
      phone: phone.trim(),
      validUntil: validUntil,
      active: members[index].active,
    );
    await _saveMembers();
    notifyListeners();
  }

  Future<void> setMemberActive(String id, bool active) async {
    final index = members.indexWhere((member) => member.id == id);
    if (index < 0) return;
    members[index] = members[index].copyWith(active: active);
    await _saveMembers();
    notifyListeners();
  }

  Future<void> addPartner({
    required String name,
    required double discountValue,
    required bool isPercentage,
    required String description,
  }) async {
    if (name.trim().isEmpty || discountValue <= 0) {
      throw ArgumentError('Informe o parceiro e um desconto válido.');
    }
    partners.add(
      ParkingPartner(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        discountValue: discountValue,
        isPercentage: isPercentage,
        description: description.trim(),
      ),
    );
    await _savePartners();
    notifyListeners();
  }

  Future<void> updatePartner({
    required String id,
    required String name,
    required double discountValue,
    required bool isPercentage,
    required String description,
  }) async {
    if (name.trim().isEmpty || discountValue <= 0) {
      throw ArgumentError('Informe o parceiro e um desconto válido.');
    }
    final index = partners.indexWhere((partner) => partner.id == id);
    if (index < 0) throw StateError('Cadastro de parceiro não encontrado.');
    partners[index] = ParkingPartner(
      id: id,
      name: name.trim(),
      discountValue: discountValue,
      isPercentage: isPercentage,
      description: description.trim(),
      active: partners[index].active,
    );
    await _savePartners();
    notifyListeners();
  }

  Future<void> setPartnerActive(String id, bool active) async {
    final index = partners.indexWhere((partner) => partner.id == id);
    if (index < 0) return;
    partners[index] = partners[index].copyWith(active: active);
    await _savePartners();
    notifyListeners();
  }

  Future<void> updateHourlyRate(double value) async {
    if (value <= 0) throw ArgumentError('A tarifa precisa ser maior que zero.');
    hourlyRate = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_rateKey, value);
    notifyListeners();
  }

  Future<void> updateSectorCapacity({
    required String sector,
    required int value,
  }) async {
    if (!sectorCapacities.containsKey(sector)) {
      throw ArgumentError('Selecione um setor válido.');
    }
    if (value < 0) {
      throw ArgumentError('A quantidade de vagas não pode ser negativa.');
    }
    final updatedCapacities = Map<String, int>.from(sectorCapacities)
      ..[sector] = value;
    final newTotal = updatedCapacities.values.fold<int>(
      0,
      (total, capacity) => total + capacity,
    );
    if (openSessions.length > newTotal) {
      throw StateError(
        'A capacidade não pode ficar abaixo dos veículos no pátio.',
      );
    }
    sectorCapacities = updatedCapacities;
    final open = openSessions..sort((a, b) => a.entryAt.compareTo(b.entryAt));
    for (var index = 0; index < open.length; index++) {
      final sessionIndex = sessions.indexWhere(
        (item) => item.id == open[index].id,
      );
      if (sessionIndex >= 0) {
        sessions[sessionIndex] = sessions[sessionIndex].copyWith(
          spotNumber: index + 1,
        );
      }
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _sectorCapacitiesKey,
      jsonEncode(sectorCapacities),
    );
    await preferences.setInt(_capacityKey, newTotal);
    await _saveSessions();
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _sessionsKey,
      jsonEncode(sessions.map((session) => session.toJson()).toList()),
    );
  }

  Future<void> _saveMembers() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _membersKey,
      jsonEncode(members.map((member) => member.toJson()).toList()),
    );
  }

  Future<void> _savePartners() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _partnersKey,
      jsonEncode(partners.map((partner) => partner.toJson()).toList()),
    );
  }
}

String normalizePlate(String value) =>
    value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

bool _isSameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

Map<String, int> _splitCapacity(int total) {
  final firstSector = (total * .4).floor();
  final secondSector = (total * .4).floor();
  return {
    'A': firstSector,
    'B': secondSector,
    'VIP': total - firstSector - secondSector,
  };
}
