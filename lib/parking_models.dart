class ParkingSession {
  ParkingSession({
    required this.id,
    required this.plate,
    required this.vehicleType,
    required this.ticketNumber,
    required this.entryAt,
    required this.isMonthly,
    this.spotNumber,
    this.memberName,
    this.exitAt,
    this.paidAmount,
    this.discountAmount,
    this.partnerName,
    this.partnerTicket,
  });

  final String id;
  final String plate;
  final String vehicleType;
  final String ticketNumber;
  final DateTime entryAt;
  final bool isMonthly;
  final int? spotNumber;
  final String? memberName;
  final DateTime? exitAt;
  final double? paidAmount;
  final double? discountAmount;
  final String? partnerName;
  final String? partnerTicket;

  bool get isOpen => exitAt == null;

  ParkingSession copyWith({
    DateTime? exitAt,
    double? paidAmount,
    double? discountAmount,
    String? partnerName,
    String? partnerTicket,
    int? spotNumber,
  }) {
    return ParkingSession(
      id: id,
      plate: plate,
      vehicleType: vehicleType,
      ticketNumber: ticketNumber,
      entryAt: entryAt,
      isMonthly: isMonthly,
      spotNumber: spotNumber ?? this.spotNumber,
      memberName: memberName,
      exitAt: exitAt ?? this.exitAt,
      paidAmount: paidAmount ?? this.paidAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      partnerName: partnerName ?? this.partnerName,
      partnerTicket: partnerTicket ?? this.partnerTicket,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'plate': plate,
    'vehicleType': vehicleType,
    'ticketNumber': ticketNumber,
    'entryAt': entryAt.toIso8601String(),
    'isMonthly': isMonthly,
    'spotNumber': spotNumber,
    'memberName': memberName,
    'exitAt': exitAt?.toIso8601String(),
    'paidAmount': paidAmount,
    'discountAmount': discountAmount,
    'partnerName': partnerName,
    'partnerTicket': partnerTicket,
  };

  factory ParkingSession.fromJson(Map<String, dynamic> json) {
    return ParkingSession(
      id: json['id'] as String,
      plate: json['plate'] as String,
      vehicleType: json['vehicleType'] as String? ?? 'Carro',
      ticketNumber: json['ticketNumber'] as String? ?? json['id'] as String,
      entryAt: DateTime.parse(json['entryAt'] as String),
      isMonthly: json['isMonthly'] as bool? ?? false,
      spotNumber: json['spotNumber'] as int?,
      memberName: json['memberName'] as String?,
      exitAt: json['exitAt'] == null
          ? null
          : DateTime.parse(json['exitAt'] as String),
      paidAmount: (json['paidAmount'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      partnerName: json['partnerName'] as String?,
      partnerTicket: json['partnerTicket'] as String?,
    );
  }
}

class MonthlyMember {
  const MonthlyMember({
    required this.id,
    required this.name,
    required this.plate,
    required this.phone,
    required this.validUntil,
    this.active = true,
  });

  final String id;
  final String name;
  final String plate;
  final String phone;
  final DateTime validUntil;
  final bool active;

  bool isValidAt(DateTime time) {
    final endOfValidity = DateTime(
      validUntil.year,
      validUntil.month,
      validUntil.day,
      23,
      59,
      59,
    );
    return active && !endOfValidity.isBefore(time);
  }

  MonthlyMember copyWith({bool? active}) => MonthlyMember(
    id: id,
    name: name,
    plate: plate,
    phone: phone,
    validUntil: validUntil,
    active: active ?? this.active,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'plate': plate,
    'phone': phone,
    'validUntil': validUntil.toIso8601String(),
    'active': active,
  };

  factory MonthlyMember.fromJson(Map<String, dynamic> json) => MonthlyMember(
    id: json['id'] as String,
    name: json['name'] as String,
    plate: json['plate'] as String,
    phone: json['phone'] as String? ?? '',
    validUntil: DateTime.parse(json['validUntil'] as String),
    active: json['active'] as bool? ?? true,
  );
}

class ParkingPartner {
  const ParkingPartner({
    required this.id,
    required this.name,
    required this.discountValue,
    required this.isPercentage,
    required this.description,
    this.active = true,
  });

  final String id;
  final String name;
  final double discountValue;
  final bool isPercentage;
  final String description;
  final bool active;

  ParkingPartner copyWith({bool? active}) => ParkingPartner(
    id: id,
    name: name,
    discountValue: discountValue,
    isPercentage: isPercentage,
    description: description,
    active: active ?? this.active,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'discountValue': discountValue,
    'isPercentage': isPercentage,
    'description': description,
    'active': active,
  };

  factory ParkingPartner.fromJson(Map<String, dynamic> json) => ParkingPartner(
    id: json['id'] as String,
    name: json['name'] as String,
    discountValue: (json['discountValue'] as num).toDouble(),
    isPercentage: json['isPercentage'] as bool? ?? true,
    description: json['description'] as String? ?? '',
    active: json['active'] as bool? ?? true,
  );
}
