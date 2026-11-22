import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'app_theme.dart';
import 'parking_controller.dart';
import 'parking_models.dart';

class ParkingHome extends StatefulWidget {
  const ParkingHome({super.key, required this.controller});

  final ParkingController controller;

  @override
  State<ParkingHome> createState() => _ParkingHomeState();
}

class _ParkingHomeState extends State<ParkingHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        controller: widget.controller,
        onRegisterEntry: () => _showEntryForm(context, widget.controller),
        onShowParking: () => setState(() => _index = 2),
        onShowSpaces: () => setState(() => _index = 1),
        onExit: (session) => _showExitForm(context, widget.controller, session),
      ),
      SpacesPage(
        controller: widget.controller,
        onRegisterEntry: () => _showEntryForm(context, widget.controller),
        onExit: (session) => _showExitForm(context, widget.controller, session),
      ),
      ParkingPage(
        controller: widget.controller,
        onRegisterEntry: () => _showEntryForm(context, widget.controller),
        onExit: (session) => _showExitForm(context, widget.controller, session),
      ),
      TariffsPage(controller: widget.controller),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 74,
        title: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: appPurple,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: appPurple.withValues(alpha: .28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_parking_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ParkFlow',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Unidade Centro • Pátio 01',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: appMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: appGreen.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: appGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Registrar entrada',
            onPressed: () => _showEntryForm(context, widget.controller),
            icon: const Icon(Icons.add_rounded, size: 26),
            style: IconButton.styleFrom(
              backgroundColor: appPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Abrir tarifas e cadastros',
            onPressed: () => setState(() => _index = 3),
            icon: const Icon(Icons.wb_sunny_outlined, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: appSurface,
              foregroundColor: appMuted,
              minimumSize: const Size(46, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on_rounded),
            selectedIcon: Icon(Icons.grid_on_rounded),
            label: 'Vagas',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car_filled_rounded),
            label: 'Pátio',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Tarifas',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.controller,
    required this.onRegisterEntry,
    required this.onShowParking,
    required this.onShowSpaces,
    required this.onExit,
  });

  final ParkingController controller;
  final VoidCallback onRegisterEntry;
  final VoidCallback onShowParking;
  final VoidCallback onShowSpaces;
  final ValueChanged<ParkingSession> onExit;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final sessions = controller.openSessions;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _RevenueCard(
              revenue: controller.todayRevenue,
              occupied: sessions.length,
              capacity: controller.parkingCapacity,
              occupancy: controller.occupancyRate,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Total vagas',
                    value: '${controller.parkingCapacity}',
                    icon: Icons.layers_rounded,
                    tint: const Color(0xFF29364B),
                    iconColor: appMuted,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Ocupadas',
                    value: sessions.length.toString().padLeft(2, '0'),
                    icon: Icons.directions_car_filled_rounded,
                    tint: const Color(0xFF3A283B),
                    iconColor: appRed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Livres',
                    value: controller.freeSpaces.toString().padLeft(2, '0'),
                    icon: Icons.check_circle_outline_rounded,
                    tint: const Color(0xFF173A3A),
                    iconColor: appGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const _DashboardSectionLabel(title: 'ACESSO RÁPIDO'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.login_rounded,
                    title: 'Registrar\nEntrada',
                    subtitle: 'Ler placa ou digitar',
                    accent: appPurple,
                    primary: true,
                    onTap: onRegisterEntry,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Mapa do\nPátio',
                    subtitle: 'Ver setores A, B e VIP',
                    accent: appAmber,
                    onTap: onShowSpaces,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _SectionHeading(
              title: 'Veículos no pátio',
              subtitle:
                  '${sessions.length} de ${controller.parkingCapacity} vagas ocupadas',
              actionLabel: 'Ver todos',
              onAction: onShowParking,
            ),
            const SizedBox(height: 12),
            if (sessions.isEmpty)
              const _EmptyState(
                icon: Icons.local_parking_rounded,
                title: 'Nenhum veículo estacionado',
                subtitle: 'As entradas registradas aparecerão aqui.',
              )
            else
              ...sessions
                  .take(2)
                  .map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SessionCard(
                        session: session,
                        onExit: () => onExit(session),
                      ),
                    ),
                  ),
            const SizedBox(height: 14),
            _InfoStrip(
              icon: Icons.workspace_premium_outlined,
              title: '${controller.activeMembers.length} mensalistas ativos',
              subtitle: 'Reconhecidos automaticamente pela placa.',
            ),
          ],
        );
      },
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({
    required this.revenue,
    required this.occupied,
    required this.capacity,
    required this.occupancy,
  });

  final double revenue;
  final int occupied;
  final int capacity;
  final double occupancy;

  @override
  Widget build(BuildContext context) {
    final percentage = (occupancy * 100).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF202949), Color(0xFF1B263D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFF303B5A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: appGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'FATURAMENTO HOJE',
                  style: TextStyle(
                    color: Color(0xFFC1CADB),
                    fontSize: 12,
                    letterSpacing: .7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: appGreen.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: appGreen.withValues(alpha: .25)),
                ),
                child: const Text(
                  'HOJE',
                  style: TextStyle(
                    color: appGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _money(revenue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.1,
              letterSpacing: -1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: const Color(0xFF34405A)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Taxa de Ocupação Atual',
                  style: TextStyle(
                    color: Color(0xFFB8C2D3),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$percentage%  ($occupied/$capacity)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: occupancy,
              minHeight: 7,
              color: appPurple,
              backgroundColor: const Color(0xFF303B52),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSectionLabel extends StatelessWidget {
  const _DashboardSectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: appMuted,
      fontSize: 12,
      letterSpacing: .7,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          constraints: const BoxConstraints(minHeight: 122),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primary ? appPurple : appSurface,
            borderRadius: BorderRadius.circular(19),
            border: primary ? null : Border.all(color: appBorder),
            boxShadow: primary
                ? [
                    BoxShadow(
                      color: appPurple.withValues(alpha: .22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary
                          ? Colors.white.withValues(alpha: .14)
                          : accent.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: primary ? Colors.white : accent),
                  ),
                  const Spacer(),
                  if (primary)
                    const Icon(
                      Icons.arrow_outward_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.05,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primary ? Colors.white70 : appMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParkingPage extends StatefulWidget {
  const ParkingPage({
    super.key,
    required this.controller,
    required this.onRegisterEntry,
    required this.onExit,
  });

  final ParkingController controller;
  final VoidCallback onRegisterEntry;
  final ValueChanged<ParkingSession> onExit;

  @override
  State<ParkingPage> createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  final _searchController = TextEditingController();
  bool _showHistory = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final source = _showHistory
            ? widget.controller.closedSessions
            : widget.controller.openSessions;
        final query = normalizePlate(_searchController.text);
        final visible = source
            .where((session) => session.plate.contains(query))
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            const Text(
              'Pátio',
              style: TextStyle(
                color: appInk,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Acompanhe as entradas e finalize as saídas.',
              style: TextStyle(color: appMuted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: widget.onRegisterEntry,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar entrada'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Buscar pela placa',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.directions_car_outlined),
                  label: Text('No pátio'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.history_rounded),
                  label: Text('Histórico'),
                ),
              ],
              selected: {_showHistory},
              onSelectionChanged: (selection) =>
                  setState(() => _showHistory = selection.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),
            if (visible.isEmpty)
              _EmptyState(
                icon: _showHistory
                    ? Icons.history_rounded
                    : Icons.local_parking_rounded,
                title: query.isNotEmpty
                    ? 'Nenhum veículo encontrado'
                    : _showHistory
                    ? 'Ainda sem saídas registradas'
                    : 'Nenhum veículo no pátio',
                subtitle: query.isNotEmpty
                    ? 'Confira a placa e tente novamente.'
                    : _showHistory
                    ? 'As saídas finalizadas serão listadas aqui.'
                    : 'Quando um veículo entrar, ele aparecerá nesta lista.',
              )
            else
              ...visible.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SessionCard(
                    session: session,
                    showExit: !_showHistory,
                    onExit: () => widget.onExit(session),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class SpacesPage extends StatelessWidget {
  const SpacesPage({
    super.key,
    required this.controller,
    required this.onRegisterEntry,
    required this.onExit,
  });

  final ParkingController controller;
  final VoidCallback onRegisterEntry;
  final ValueChanged<ParkingSession> onExit;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final capacity = controller.parkingCapacity;
        var nextSpotNumber = 1;
        final sectors = <MapEntry<String, List<int>>>[];
        for (final entry in controller.sectorCapacities.entries) {
          final spaces = List.generate(
            entry.value,
            (index) => nextSpotNumber + index,
          );
          if (spaces.isNotEmpty) {
            final name = entry.key == 'VIP' ? 'VIP' : 'SETOR ${entry.key}';
            sectors.add(MapEntry(name, spaces));
          }
          nextSpotNumber += entry.value;
        }
        final occupiedBySpot = {
          for (final session in controller.openSessions)
            if (session.spotNumber != null) session.spotNumber!: session,
        };

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mapa do Pátio',
                    style: TextStyle(
                      color: appInk,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Editar tamanho do pátio',
                  onPressed: () => _showCapacityDialog(context, controller),
                  icon: const Icon(Icons.settings_outlined),
                  style: IconButton.styleFrom(
                    foregroundColor: appMuted,
                    backgroundColor: appSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${controller.freeSpaces} vagas livres de $capacity',
              style: const TextStyle(color: appMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRegisterEntry,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar entrada'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                _MapLegendDot(color: appGreen, label: 'Livre'),
                const SizedBox(width: 18),
                _MapLegendDot(color: appRed, label: 'Ocupada'),
                const Spacer(),
                Text(
                  '${controller.openSessions.length}/$capacity',
                  style: const TextStyle(
                    color: appMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final sector in sectors) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(
                      sector.key,
                      style: const TextStyle(
                        color: appMuted,
                        fontSize: 11,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 1, color: appBorder)),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sector.value.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  final number = sector.value[index];
                  final session = occupiedBySpot[number];
                  return _ParkingSpotCard(
                    number: number,
                    session: session,
                    onTap: session == null ? null : () => onExit(session),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
            const _InfoStrip(
              icon: Icons.touch_app_outlined,
              title: 'Toque em uma vaga ocupada',
              subtitle:
                  'Abra o veículo para conferir dados e registrar a saída.',
            ),
          ],
        );
      },
    );
  }
}

class _MapLegendDot extends StatelessWidget {
  const _MapLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: appMuted, fontSize: 11)),
    ],
  );
}

class _ParkingSpotCard extends StatelessWidget {
  const _ParkingSpotCard({
    required this.number,
    required this.session,
    required this.onTap,
  });

  final int number;
  final ParkingSession? session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final occupied = session != null;
    final accent = occupied ? appRed : appGreen;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: occupied ? const Color(0xFF302638) : appSurface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: occupied ? const Color(0xFF5B384D) : appBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    occupied
                        ? Icons.directions_car_filled_rounded
                        : Icons.check_circle_outline_rounded,
                    color: accent,
                    size: 15,
                  ),
                  const Spacer(),
                  Text(
                    number.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: appMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                occupied ? _formatPlate(session!.plate) : 'Livre',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: occupied ? Colors.white : appMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistryPage extends StatefulWidget {
  const RegistryPage({super.key, required this.controller});

  final ParkingController controller;

  @override
  State<RegistryPage> createState() => _RegistryPageState();
}

class _RegistryPageState extends State<RegistryPage> {
  bool _showPartners = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final members = widget.controller.members;
        final partners = widget.controller.partners;
        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
          children: [
            const Text(
              'Cadastros',
              style: TextStyle(
                color: appInk,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mensalistas e comércios conveniados.',
              style: TextStyle(color: appMuted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.person_outline_rounded),
                  label: Text('Mensalistas'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.storefront_outlined),
                  label: Text('Parceiros'),
                ),
              ],
              selected: {_showPartners},
              onSelectionChanged: (selection) =>
                  setState(() => _showPartners = selection.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),
            if (_showPartners)
              ..._partnerList(context, partners)
            else
              ..._memberList(context, members),
          ],
        );
      },
    );
  }

  List<Widget> _memberList(BuildContext context, List<MonthlyMember> members) {
    return [
      _RegistryAddButton(
        label: 'Cadastrar mensalista',
        onTap: () => _showMemberForm(context, widget.controller),
      ),
      const SizedBox(height: 12),
      if (members.isEmpty)
        const _EmptyState(
          icon: Icons.person_add_alt_1_rounded,
          title: 'Nenhum mensalista cadastrado',
          subtitle: 'Adicione a placa para liberar entradas sem cobrança.',
        )
      else
        ...members.map((member) {
          final valid = member.isValidAt(DateTime.now());
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RegistryCard(
              icon: Icons.person_rounded,
              title: member.name,
              subtitle:
                  '${_formatPlate(member.plate)}  ·  ${member.phone.isEmpty ? 'Sem telefone' : member.phone}',
              detail: valid
                  ? 'Válido até ${_formatDate(member.validUntil)}'
                  : 'Mensalidade vencida ou suspensa',
              active: valid,
              activeLabel: valid ? 'Ativo' : 'Inativo',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar mensalista',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        _showMemberForm(context, widget.controller, member),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                  Switch.adaptive(
                    value: member.active,
                    activeThumbColor: appGreen,
                    onChanged: (value) =>
                        widget.controller.setMemberActive(member.id, value),
                  ),
                ],
              ),
            ),
          );
        }),
    ];
  }

  List<Widget> _partnerList(
    BuildContext context,
    List<ParkingPartner> partners,
  ) {
    return [
      _RegistryAddButton(
        label: 'Cadastrar parceiro',
        onTap: () => _showPartnerForm(context, widget.controller),
      ),
      const SizedBox(height: 12),
      if (partners.isEmpty)
        const _EmptyState(
          icon: Icons.storefront_outlined,
          title: 'Nenhum parceiro cadastrado',
          subtitle: 'Cadastre comércios próximos e os descontos acordados.',
        )
      else
        ...partners.map((partner) {
          final deal = partner.isPercentage
              ? '${_number(partner.discountValue)}% de desconto'
              : '${_money(partner.discountValue)} de desconto';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RegistryCard(
              icon: Icons.storefront_rounded,
              title: partner.name,
              subtitle: partner.description.isEmpty
                  ? 'Condição: $deal'
                  : partner.description,
              detail: deal,
              active: partner.active,
              activeLabel: partner.active ? 'Ativo' : 'Pausado',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar parceiro',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        _showPartnerForm(context, widget.controller, partner),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                  Switch.adaptive(
                    value: partner.active,
                    activeThumbColor: appGreen,
                    onChanged: (value) =>
                        widget.controller.setPartnerActive(partner.id, value),
                  ),
                ],
              ),
            ),
          );
        }),
    ];
  }
}

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key, required this.controller});

  final ParkingController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final tickets = controller.ticketSessions;
        final totalDiscount = tickets.fold<double>(
          0,
          (total, session) => total + (session.discountAmount ?? 0),
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
          children: [
            const Text(
              'Tickets conveniados',
              style: TextStyle(
                color: appInk,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Descontos aplicados na saída dos veículos.',
              style: TextStyle(color: appMuted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Tickets usados',
                    value: '${tickets.length}',
                    icon: Icons.confirmation_number_rounded,
                    tint: const Color(0xFF173A3A),
                    iconColor: appGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Descontos dados',
                    value: _money(totalDiscount),
                    icon: Icons.discount_outlined,
                    tint: const Color(0xFF3C3426),
                    iconColor: appAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (tickets.isEmpty)
              const _EmptyState(
                icon: Icons.confirmation_number_outlined,
                title: 'Nenhum ticket utilizado',
                subtitle: 'Na saída, informe o parceiro e o código do ticket para aplicar o desconto.',
              )
            else
              ...tickets.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TicketCard(session: session),
                ),
              ),
          ],
        );
      },
    );
  }
}

class TariffsPage extends StatefulWidget {
  const TariffsPage({super.key, required this.controller});

  final ParkingController controller;

  @override
  State<TariffsPage> createState() => _TariffsPageState();
}

class _TariffsPageState extends State<TariffsPage> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tarifas e cadastros',
            style: TextStyle(
              color: appInk,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Configure a operação e os acordos do estacionamento.',
            style: TextStyle(color: appMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                icon: Icon(Icons.sell_outlined),
                label: Text('Tarifa'),
              ),
              ButtonSegment(
                value: 1,
                icon: Icon(Icons.people_alt_outlined),
                label: Text('Cadastros'),
              ),
              ButtonSegment(
                value: 2,
                icon: Icon(Icons.confirmation_number_outlined),
                label: Text('Tickets'),
              ),
            ],
            selected: {_section},
            onSelectionChanged: (selection) =>
                setState(() => _section = selection.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: IndexedStack(
              index: _section,
              children: [
                _TariffSettingsPage(controller: widget.controller),
                RegistryPage(controller: widget.controller),
                TicketsPage(controller: widget.controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TariffSettingsPage extends StatelessWidget {
  const _TariffSettingsPage({required this.controller});

  final ParkingController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          _SettingCard(
            icon: Icons.payments_outlined,
            title: 'Tarifa por hora',
            subtitle: 'Cobrança por hora iniciada após 15 minutos.',
            value: _money(controller.hourlyRate),
            onEdit: () => _showRateDialog(context, controller),
          ),
          const SizedBox(height: 11),
          _SettingCard(
            icon: Icons.grid_view_rounded,
            title: 'Capacidade do pátio',
            subtitle: 'Vagas disponíveis para alocação automática.',
            value: '${controller.parkingCapacity} vagas',
            onEdit: () => _showCapacityDialog(context, controller),
          ),
          const SizedBox(height: 15),
          _InfoStrip(
            icon: Icons.info_outline_rounded,
            title: '${controller.freeSpaces} vagas livres agora',
            subtitle:
                'Mensalistas ocupam uma vaga, mas a entrada não gera cobrança.',
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onEdit,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: appPurple.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: appPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: appInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: appMuted, fontSize: 10),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: appGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Editar $title',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 19),
            style: IconButton.styleFrom(
              foregroundColor: appMuted,
              backgroundColor: appSurfaceRaised,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: appInk,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: appMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: appInk,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: appMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onExit,
    this.showExit = true,
  });

  final ParkingSession session;
  final VoidCallback onExit;
  final bool showExit;

  @override
  Widget build(BuildContext context) {
    final open = session.isOpen;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: session.isMonthly
                  ? const Color(0xFF173A3A)
                  : const Color(0xFF29364B),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              session.vehicleType == 'Moto'
                  ? Icons.two_wheeler_rounded
                  : Icons.directions_car_filled_rounded,
              color: session.isMonthly ? appGreen : appMuted,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _formatPlate(session.plate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: appInk,
                          fontSize: 16,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (session.isMonthly) ...[
                      const SizedBox(width: 6),
                      const _TinyTag(label: 'MENSALISTA'),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.vehicleType}  ·  ${open ? 'Entrada ${_formatTime(session.entryAt)}' : 'Saída ${_formatDateTime(session.exitAt!)}'}  ·  Vaga ${session.spotNumber?.toString().padLeft(2, '0') ?? '—'}  ·  Ticket ${session.ticketNumber}',
                  style: const TextStyle(color: appMuted, fontSize: 11),
                ),
                if (session.isMonthly && session.memberName != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    session.memberName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: appGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (!open) ...[
                  const SizedBox(height: 3),
                  Text(
                    session.isMonthly
                        ? 'Isento · mensalista'
                        : 'Pago ${_money(session.paidAmount ?? 0)}${(session.discountAmount ?? 0) > 0 ? ' · desconto ${_money(session.discountAmount!)}' : ''}',
                    style: const TextStyle(
                      color: appMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showExit && open)
            IconButton.filledTonal(
              tooltip: 'Registrar saída',
              onPressed: onExit,
              icon: const Icon(Icons.logout_rounded, size: 19),
              style: IconButton.styleFrom(
                foregroundColor: appGreen,
                backgroundColor: const Color(0xFF173A3A),
                minimumSize: const Size(40, 40),
              ),
            )
          else if (!open)
            Text(
              _money(session.paidAmount ?? 0),
              style: const TextStyle(
                color: appGreen,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: appGreen.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: appGreen,
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appSurfaceRaised,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: appGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: appInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: appMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: appSurfaceRaised,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: appGreen, size: 23),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: appInk,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: appMuted, height: 1.4, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RegistryAddButton extends StatelessWidget {
  const _RegistryAddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: appPurple,
        minimumSize: const Size.fromHeight(48),
        backgroundColor: appSurface,
        side: const BorderSide(color: appBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _RegistryCard extends StatelessWidget {
  const _RegistryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.active,
    required this.activeLabel,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;
  final bool active;
  final String activeLabel;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 13, 8, 13),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appSurfaceRaised,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: appGreen, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: appInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: appMuted, fontSize: 10),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      active ? Icons.check_circle_rounded : Icons.info_rounded,
                      size: 12,
                      color: active ? appGreen : appAmber,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '$activeLabel  ·  $detail',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active ? appGreen : appAmber,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.session});

  final ParkingSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: appAmber.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number_rounded,
              color: appAmber,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.partnerName ?? 'Parceiro',
                  style: const TextStyle(
                    color: appInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Ticket ${session.partnerTicket}  ·  estacionamento ${session.ticketNumber}  ·  ${_formatPlate(session.plate)}',
                  style: const TextStyle(color: appMuted, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(session.exitAt ?? session.entryAt),
                  style: const TextStyle(color: appMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${_money(session.discountAmount ?? 0)}',
                style: const TextStyle(
                  color: appGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Final ${_money(session.paidAmount ?? 0)}',
                style: const TextStyle(color: appMuted, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showEntryForm(
  BuildContext context,
  ParkingController controller,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => EntryForm(controller: controller),
  );
}

class EntryForm extends StatefulWidget {
  const EntryForm({super.key, required this.controller});

  final ParkingController controller;

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  String _vehicleType = 'Carro';
  bool _busy = false;
  bool _readingPlate = false;

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _readPlate() async {
    setState(() => _readingPlate = true);
    try {
      final plate = await _capturePlateWithCamera();
      if (plate == null || !mounted) return;
      _plateController.text = plate;
      _showSnack(context, 'Placa reconhecida. Confira antes de confirmar.');
    } catch (_) {
      if (mounted) {
        _showSnack(context, 'Não consegui ler a placa. Digite manualmente.');
      }
    } finally {
      if (mounted) setState(() => _readingPlate = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final session = await widget.controller.registerEntry(
        plate: _plateController.text,
        vehicleType: _vehicleType,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      _showSnackOn(
        messenger,
        session.isMonthly
            ? 'Entrada registrada na vaga ${session.spotNumber}. Mensalista identificado: sem cobrança.'
            : 'Entrada registrada na vaga ${session.spotNumber}. Ticket ${session.ticketNumber}.',
      );
    } catch (error) {
      if (mounted) {
        _showSnack(context, _errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 22,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrar entrada',
                style: TextStyle(
                  color: appInk,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'A placa identifica automaticamente um mensalista ativo.',
                style: TextStyle(color: appMuted, fontSize: 12),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _plateController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Placa do veículo',
                  hintText: 'ABC1D23',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  suffixIcon: IconButton(
                    tooltip: 'Ler placa com a câmera',
                    onPressed: _readingPlate ? null : _readPlate,
                    icon: _readingPlate
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_camera_outlined),
                  ),
                ),
                validator: (value) {
                  final plate = normalizePlate(value ?? '');
                  if (plate.length != 7) {
                    return 'Informe uma placa com 7 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13),
              DropdownButtonFormField<String>(
                initialValue: _vehicleType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de veículo',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'Carro', child: Text('Carro')),
                  DropdownMenuItem(value: 'Moto', child: Text('Moto')),
                ],
                onChanged: (value) =>
                    setState(() => _vehicleType = value ?? 'Carro'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirmar entrada'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showExitForm(
  BuildContext context,
  ParkingController controller,
  ParkingSession session,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => ExitForm(controller: controller, session: session),
  );
}

class ExitForm extends StatefulWidget {
  const ExitForm({super.key, required this.controller, required this.session});

  final ParkingController controller;
  final ParkingSession session;

  @override
  State<ExitForm> createState() => _ExitFormState();
}

class _ExitFormState extends State<ExitForm> {
  late final TextEditingController _plateController;
  final _ticketController = TextEditingController();
  String? _partnerId;
  String? _lastResolvedSessionId;
  bool _busy = false;
  bool _readingPlate = false;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.session.plate);
    _lastResolvedSessionId = widget.session.id;
  }

  ParkingSession? get _activeSession {
    final plate = normalizePlate(_plateController.text);
    for (final session in widget.controller.openSessions) {
      if (session.plate == plate) return session;
    }
    return null;
  }

  void _onPlateChanged() {
    final nextId = _activeSession?.id;
    if (nextId != _lastResolvedSessionId) {
      _lastResolvedSessionId = nextId;
      _partnerId = null;
      _ticketController.clear();
    }
    setState(() {});
  }

  int get _minutes {
    final session = _activeSession;
    if (session == null) return 0;
    return math.max(0, DateTime.now().difference(session.entryAt).inMinutes);
  }

  int get _chargedHours {
    if (_activeSession?.isMonthly ?? false) return 0;
    if (_minutes <= 15) return 0;
    return math.max(1, (_minutes / 60).ceil());
  }

  double get _baseAmount => _chargedHours * widget.controller.hourlyRate;

  ParkingPartner? get _selectedPartner {
    for (final partner in widget.controller.partners) {
      if (partner.id == _partnerId && partner.active) return partner;
    }
    return null;
  }

  double get _discount {
    final partner = _selectedPartner;
    if ((_activeSession?.isMonthly ?? false) ||
        partner == null ||
        _ticketController.text.trim().isEmpty) {
      return 0;
    }
    final discount = partner.isPercentage
        ? _baseAmount * partner.discountValue / 100
        : partner.discountValue;
    return math.min(_baseAmount, discount).toDouble();
  }

  double get _total => math.max(0, _baseAmount - _discount).toDouble();

  @override
  void dispose() {
    _plateController.dispose();
    _ticketController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final session = _activeSession;
    if (session == null) {
      _showSnack(context, 'Não há uma entrada em aberto para esta placa.');
      return;
    }
    if (_selectedPartner != null && _ticketController.text.trim().isEmpty) {
      _showSnack(
        context,
        'Informe o código do ticket para aplicar o desconto.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final total = _total;
      final discount = _discount;
      final partner = _selectedPartner;
      final ticketCode = _ticketController.text.trim();
      await widget.controller.registerExit(
        sessionId: session.id,
        paidAmount: total,
        discountAmount: discount,
        partnerName:
            !session.isMonthly && partner != null && ticketCode.isNotEmpty
            ? partner.name
            : null,
        partnerTicket:
            !session.isMonthly && partner != null && ticketCode.isNotEmpty
            ? ticketCode
            : null,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      _showSnackOn(
        messenger,
        session.isMonthly
            ? 'Saída registrada para mensalista. Sem cobrança.'
            : 'Saída registrada. Total: ${_money(total)}.',
      );
    } catch (error) {
      if (mounted) _showSnack(context, _errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final partners = widget.controller.partners
        .where((partner) => partner.active)
        .toList();
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final session = _activeSession;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 22,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Registrar saída',
                  style: TextStyle(
                    color: appInk,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 13),
                TextField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => _onPlateChanged(),
                  decoration: InputDecoration(
                    labelText: 'Placa do veículo',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    suffixIcon: IconButton(
                      tooltip: 'Ler placa com a câmera',
                      onPressed: _readingPlate ? null : _readExitPlate,
                      icon: _readingPlate
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_camera_outlined),
                    ),
                  ),
                ),
                if (session == null) ...[
                  const SizedBox(height: 9),
                  const Text(
                    'Não há uma entrada em aberto para esta placa.',
                    style: TextStyle(
                      color: Color(0xFFB45E37),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (session != null) ...[
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: appSurfaceRaised,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          color: appGreen,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatPlate(session.plate),
                                style: const TextStyle(
                                  color: appInk,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Entrada ${_formatDateTime(session.entryAt)}  ·  ${_durationLabel(_minutes)}  ·  Ticket ${session.ticketNumber}',
                                style: const TextStyle(
                                  color: appMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (session.isMonthly)
                          const _TinyTag(label: 'MENSALISTA'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (session.isMonthly)
                    const _InfoStrip(
                      icon: Icons.verified_user_outlined,
                      title: 'Mensalista identificado',
                      subtitle: 'Esta saída será registrada sem cobrança.',
                    )
                  else ...[
                    if (partners.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _partnerId,
                        decoration: const InputDecoration(
                          labelText: 'Parceiro do ticket (opcional)',
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Sem desconto'),
                          ),
                          ...partners.map(
                            (partner) => DropdownMenuItem(
                              value: partner.id,
                              child: Text(partner.name),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _partnerId = value),
                      ),
                      if (_selectedPartner != null) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _ticketController,
                          onChanged: (_) => setState(() {}),
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Código do ticket do parceiro',
                            prefixIcon: Icon(
                              Icons.confirmation_number_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _selectedPartner!.description.isNotEmpty
                              ? '${_partnerDiscountLabel(_selectedPartner!)} · ${_selectedPartner!.description}'
                              : _partnerDiscountLabel(_selectedPartner!),
                          style: const TextStyle(color: appMuted, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 13),
                    ],
                    _CalculationLine(
                      label: 'Tempo estacionado',
                      value: _durationLabel(_minutes),
                    ),
                    const SizedBox(height: 7),
                    _CalculationLine(
                      label: 'Tarifa (${_chargedHours}h)',
                      value: _money(_baseAmount),
                    ),
                    if (_discount > 0) ...[
                      const SizedBox(height: 7),
                      _CalculationLine(
                        label: 'Desconto do parceiro',
                        value: '- ${_money(_discount)}',
                        valueColor: appGreen,
                      ),
                    ],
                    const Divider(height: 22),
                    _CalculationLine(
                      label: 'Total a cobrar',
                      value: _money(_total),
                      strong: true,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Até 15 minutos: sem cobrança. Depois, cobrança por hora iniciada.',
                      style: TextStyle(color: appMuted, fontSize: 10),
                    ),
                  ],
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy || session == null ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Confirmar saída'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _readExitPlate() async {
    setState(() => _readingPlate = true);
    try {
      final plate = await _capturePlateWithCamera();
      if (plate == null || !mounted) return;
      _plateController.text = plate;
      _onPlateChanged();
      if (_activeSession == null) {
        _showSnack(
          context,
          'Não há entrada em aberto para ${_formatPlate(plate)}.',
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnack(context, 'Não consegui ler a placa. Digite manualmente.');
      }
    } finally {
      if (mounted) setState(() => _readingPlate = false);
    }
  }
}

class _CalculationLine extends StatelessWidget {
  const _CalculationLine({
    required this.label,
    required this.value,
    this.valueColor,
    this.strong = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: strong ? appInk : appMuted,
            fontSize: strong ? 14 : 12,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? appInk,
            fontSize: strong ? 16 : 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

Future<void> _showMemberForm(
  BuildContext context,
  ParkingController controller, [
  MonthlyMember? member,
]) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => MemberForm(controller: controller, member: member),
  );
}

class MemberForm extends StatefulWidget {
  const MemberForm({super.key, required this.controller, this.member});

  final ParkingController controller;
  final MonthlyMember? member;

  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _plate = TextEditingController();
  final _phone = TextEditingController();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member != null) {
      _name.text = member.name;
      _plate.text = member.plate;
      _phone.text = member.phone;
      _validUntil = member.validUntil;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _plate.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _validUntil.isBefore(DateTime.now())
          ? DateTime.now()
          : _validUntil,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Validade do mensalista',
      cancelText: 'Cancelar',
      confirmText: 'Selecionar',
    );
    if (date != null) setState(() => _validUntil = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (widget.member == null) {
        await widget.controller.addMember(
          name: _name.text,
          plate: _plate.text,
          phone: _phone.text,
          validUntil: _validUntil,
        );
      } else {
        await widget.controller.updateMember(
          id: widget.member!.id,
          name: _name.text,
          plate: _plate.text,
          phone: _phone.text,
          validUntil: _validUntil,
        );
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      _showSnackOn(
        messenger,
        widget.member == null
            ? 'Mensalista cadastrado com sucesso.'
            : 'Cadastro de mensalista atualizado.',
      );
    } catch (error) {
      if (mounted) _showSnack(context, _errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 22,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.member == null ? 'Novo mensalista' : 'Editar mensalista',
                style: const TextStyle(
                  color: appInk,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Informe o nome.'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _plate,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Placa do veículo',
                  hintText: 'ABC1D23',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
                validator: (value) => normalizePlate(value ?? '').length != 7
                    ? 'Informe uma placa com 7 caracteres.'
                    : null,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone (opcional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text('Válido até ${_formatDate(_validUntil)}'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: appGreen,
                  side: const BorderSide(color: Color(0xFFD7E3E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.member == null
                              ? 'Salvar mensalista'
                              : 'Atualizar cadastro',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showPartnerForm(
  BuildContext context,
  ParkingController controller, [
  ParkingPartner? partner,
]) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => PartnerForm(controller: controller, partner: partner),
  );
}

class PartnerForm extends StatefulWidget {
  const PartnerForm({super.key, required this.controller, this.partner});

  final ParkingController controller;
  final ParkingPartner? partner;

  @override
  State<PartnerForm> createState() => _PartnerFormState();
}

class _PartnerFormState extends State<PartnerForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _discount = TextEditingController();
  final _description = TextEditingController();
  bool _percentage = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final partner = widget.partner;
    if (partner != null) {
      _name.text = partner.name;
      _discount.text = partner.discountValue.toString();
      _description.text = partner.description;
      _percentage = partner.isPercentage;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _discount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final value = double.parse(_discount.text.replaceAll(',', '.'));
    setState(() => _busy = true);
    try {
      if (widget.partner == null) {
        await widget.controller.addPartner(
          name: _name.text,
          discountValue: value,
          isPercentage: _percentage,
          description: _description.text,
        );
      } else {
        await widget.controller.updatePartner(
          id: widget.partner!.id,
          name: _name.text,
          discountValue: value,
          isPercentage: _percentage,
          description: _description.text,
        );
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      _showSnackOn(
        messenger,
        widget.partner == null
            ? 'Parceiro cadastrado.'
            : 'Acordo com parceiro atualizado.',
      );
    } catch (error) {
      if (mounted) _showSnack(context, _errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 22,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.partner == null ? 'Novo parceiro' : 'Editar parceiro',
                style: const TextStyle(
                  color: appInk,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome do comércio',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Informe o nome.'
                    : null,
              ),
              const SizedBox(height: 11),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Percentual')),
                  ButtonSegment(value: false, label: Text('Valor fixo')),
                ],
                selected: {_percentage},
                onSelectionChanged: (selection) =>
                    setState(() => _percentage = selection.first),
                showSelectedIcon: false,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _discount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _percentage ? 'Desconto (%)' : 'Desconto (R\$)',
                  prefixIcon: const Icon(Icons.sell_outlined),
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );
                  if (parsed == null || parsed <= 0) {
                    return 'Informe um desconto maior que zero.';
                  }
                  if (_percentage && parsed > 100) return 'Use no máximo 100%.';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Condições do acordo (opcional)',
                  hintText: 'Ex.: válido para compras acima de R\$ 30',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.partner == null
                              ? 'Salvar parceiro'
                              : 'Atualizar acordo',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showRateDialog(
  BuildContext context,
  ParkingController controller,
) async {
  final input = TextEditingController(
    text: controller.hourlyRate.toStringAsFixed(2).replaceAll('.', ','),
  );
  final value = await showDialog<double>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Tarifa por hora'),
      content: TextField(
        controller: input,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Valor em reais',
          prefixText: 'R\$ ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            final parsed = double.tryParse(input.text.replaceAll(',', '.'));
            if (parsed == null || parsed <= 0) {
              _showSnack(dialogContext, 'Informe um valor válido.');
              return;
            }
            Navigator.pop(dialogContext, parsed);
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
  input.dispose();
  if (value == null || !context.mounted) return;
  try {
    await controller.updateHourlyRate(value);
    if (context.mounted) {
      _showSnack(context, 'Tarifa atualizada para ${_money(value)} por hora.');
    }
  } catch (error) {
    if (context.mounted) _showSnack(context, _errorMessage(error));
  }
}

Future<void> _showCapacityDialog(
  BuildContext context,
  ParkingController controller,
) async {
  var selectedSector = controller.sectorCapacities.keys.first;
  final input = TextEditingController(
    text: controller.sectorCapacities[selectedSector].toString(),
  );
  final result = await showDialog<MapEntry<String, int>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final currentSectorCapacity =
            controller.sectorCapacities[selectedSector] ?? 0;
        final requestedCapacity =
            int.tryParse(input.text.trim()) ?? currentSectorCapacity;
        final totalAfterSave =
            controller.parkingCapacity -
            currentSectorCapacity +
            requestedCapacity;
        return AlertDialog(
          title: const Text('Editar vagas por setor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedSector,
                decoration: const InputDecoration(
                  labelText: 'Setor',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: controller.sectorCapacities.keys
                    .map(
                      (sector) => DropdownMenuItem(
                        value: sector,
                        child: Text(sector == 'VIP' ? 'VIP' : 'Setor $sector'),
                      ),
                    )
                    .toList(),
                onChanged: (sector) {
                  if (sector == null) return;
                  input.text = controller.sectorCapacities[sector].toString();
                  setDialogState(() => selectedSector = sector);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: input,
                onChanged: (_) => setDialogState(() {}),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Vagas neste setor',
                  suffixText: 'vagas',
                  prefixIcon: Icon(Icons.grid_view_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appSurfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total geral após salvar: $totalAfterSave vagas',
                  style: const TextStyle(
                    color: appGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(input.text.trim());
                if (parsed == null || parsed < 0) {
                  _showSnack(
                    dialogContext,
                    'Informe uma quantidade igual ou maior que zero.',
                  );
                  return;
                }
                Navigator.pop(dialogContext, MapEntry(selectedSector, parsed));
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    ),
  );
  input.dispose();
  if (result == null || !context.mounted) return;
  try {
    await controller.updateSectorCapacity(
      sector: result.key,
      value: result.value,
    );
    if (context.mounted) {
      _showSnack(
        context,
        'Setor ${result.key} atualizado para ${result.value} vagas. Total: ${controller.parkingCapacity}.',
      );
    }
  } catch (error) {
    if (context.mounted) _showSnack(context, _errorMessage(error));
  }
}

String _formatDate(DateTime date) {
  const months = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

String _formatDateTime(DateTime date) =>
    '${_formatDate(date)} às ${_formatTime(date)}';

String _formatPlate(String plate) {
  final normalized = normalizePlate(plate);
  if (normalized.length == 7) {
    return '${normalized.substring(0, 3)}-${normalized.substring(3)}';
  }
  return normalized;
}

String _durationLabel(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (hours == 0) return '$remainingMinutes min';
  if (remainingMinutes == 0) return '${hours}h';
  return '${hours}h ${remainingMinutes}min';
}

String _money(double value) {
  final fixed = value.toStringAsFixed(2).split('.');
  final whole = fixed[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'R\$ $whole,${fixed[1]}';
}

String _number(double value) =>
    (value == value.roundToDouble()
            ? value.toStringAsFixed(0)
            : value.toString())
        .replaceAll('.', ',');

String _partnerDiscountLabel(ParkingPartner partner) => partner.isPercentage
    ? '${_number(partner.discountValue)}% de desconto com este ticket.'
    : '${_money(partner.discountValue)} de desconto com este ticket.';

String _errorMessage(Object error) {
  if (error is StateError) {
    return error.message.toString();
  }
  if (error is ArgumentError) {
    return error.message.toString();
  }
  return 'Não foi possível salvar. Tente novamente.';
}

void _showSnack(BuildContext context, String message) {
  _showSnackOn(ScaffoldMessenger.of(context), message);
}

void _showSnackOn(ScaffoldMessengerState messenger, String message) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<String?> _capturePlateWithCamera() async {
  final photo = await ImagePicker().pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.rear,
    imageQuality: 88,
  );
  if (photo == null) return null;

  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  String recognizedText;
  try {
    final result = await recognizer.processImage(
      InputImage.fromFilePath(photo.path),
    );
    recognizedText = result.text.toUpperCase();
  } finally {
    await recognizer.close();
  }

  final match = RegExp(r'[A-Z]{3}[-\s]?[0-9][A-Z0-9][\s-]?[0-9]{2}')
      .firstMatch(recognizedText);
  if (match == null) throw const FormatException('Placa não identificada.');
  return normalizePlate(match.group(0)!);
}
