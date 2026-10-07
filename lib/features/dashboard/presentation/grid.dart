// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';

class SchoolSafetyMap extends StatefulWidget {
  final bool showGrid;
  final bool showSensors;
  final bool showRoute;

  const SchoolSafetyMap({
    super.key,
    this.showGrid = true,
    this.showSensors = true,
    this.showRoute = true,
  });

  @override
  State<SchoolSafetyMap> createState() => _SchoolSafetyMapState();
}

class _SchoolSafetyMapState extends State<SchoolSafetyMap> {
  String? selectedZone;

  // ============================================================
  // MAP COORDINATES
  //
  // Coordinates are based on the 1214 x 928 map image.
  //
  // x = horizontal position
  // y = vertical position
  //
  // All values are normalized from 0.0 -> 1.0
  // ============================================================

  final List<MapZone> zones = const [
    // ---------------- NORTH BLOCK ----------------
    MapZone(
      id: 'north',
      name: 'NORTH BLOCK',
      x: 0.174,
      y: 0.098,
      width: 0.261,
      height: 0.174,
      risk: RiskLevel.safe,
      occupancy: 42,
      capacity: 60,
    ),

    // ---------------- CENTRAL BLOCK ----------------
    MapZone(
      id: 'central',
      name: 'CENTRAL BLOCK',
      x: 0.462,
      y: 0.117,
      width: 0.282,
      height: 0.285,
      risk: RiskLevel.caution,
      occupancy: 56,
      capacity: 80,
    ),

    // ---------------- EAST BLOCK ----------------
    MapZone(
      id: 'east',
      name: 'EAST BLOCK',
      x: 0.742,
      y: 0.138,
      width: 0.176,
      height: 0.188,
      risk: RiskLevel.critical,
      occupancy: 74,
      capacity: 80,
    ),

    // ---------------- SOUTH BLOCK ----------------
    MapZone(
      id: 'south',
      name: 'SOUTH BLOCK',
      x: 0.230,
      y: 0.526,
      width: 0.258,
      height: 0.196,
      risk: RiskLevel.safe,
      occupancy: 32,
      capacity: 50,
    ),

    // ---------------- WEST BLOCK ----------------
    MapZone(
      id: 'west',
      name: 'WEST BLOCK',
      x: 0.547,
      y: 0.556,
      width: 0.235,
      height: 0.175,
      risk: RiskLevel.high,
      occupancy: 45,
      capacity: 55,
    ),

    // ---------------- EXIT A ----------------
    MapZone(
      id: 'exitA',
      name: 'EXIT A',
      x: 0.090,
      y: 0.410,
      width: 0.075,
      height: 0.080,
      risk: RiskLevel.safe,
      occupancy: 0,
      capacity: 300,
    ),

    // ---------------- EXIT B ----------------
    MapZone(
      id: 'exitB',
      name: 'EXIT B',
      x: 0.880,
      y: 0.430,
      width: 0.075,
      height: 0.080,
      risk: RiskLevel.safe,
      occupancy: 0,
      capacity: 300,
    ),
  ];

  // ============================================================
  // SENSOR POSITIONS
  // ============================================================

  final List<SensorPoint> sensors = const [
    SensorPoint(
      id: 'S1',
      name: 'North Block Sensor',
      x: 0.296,
      y: 0.188,
      type: SensorType.smoke,
    ),

    SensorPoint(
      id: 'S2',
      name: 'Central Block Sensor',
      x: 0.584,
      y: 0.215,
      type: SensorType.temperature,
    ),

    SensorPoint(
      id: 'S3',
      name: 'East Block Sensor',
      x: 0.825,
      y: 0.235,
      type: SensorType.smoke,
    ),

    SensorPoint(
      id: 'S4',
      name: 'South Block Sensor',
      x: 0.360,
      y: 0.615,
      type: SensorType.people,
    ),

    SensorPoint(
      id: 'S5',
      name: 'West Block Sensor',
      x: 0.668,
      y: 0.640,
      type: SensorType.people,
    ),
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF050A0F),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: Colors.cyanAccent.withOpacity(0.18)),
        ),

        child: InteractiveViewer(
          minScale: 0.7,
          maxScale: 4.0,

          boundaryMargin: const EdgeInsets.all(150),

          child: Center(
            child: AspectRatio(
              // IMPORTANT:
              // Matches the generated image exactly.
              aspectRatio: 1214 / 928,

              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final height = constraints.maxHeight;

                  return Stack(
                    clipBehavior: Clip.none,

                    children: [
                      // ==================================================
                      // ACTUAL MAP IMAGE
                      // ==================================================

                      // ==================================================
                      // OPTIONAL GRID OVERLAY
                      //
                      // The image already contains a grid.
                      // Keep this FALSE unless you want an additional
                      // live coordinate grid.
                      // ==================================================
                      if (widget.showGrid)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: CoordinateGridPainter(),
                            ),
                          ),
                        ),

                      // ==================================================
                      // SAFETY ZONES
                      // ==================================================
                      ...zones.map((zone) {
                        return Positioned(
                          left: zone.x * width,

                          top: zone.y * height,

                          width: zone.width * width,

                          height: zone.height * height,

                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedZone = zone.id;
                              });

                              _showZoneDetails(zone);
                            },

                            child: _buildZone(zone),
                          ),
                        );
                      }),

                      // ==================================================
                      // SENSOR MARKERS
                      // ==================================================
                      if (widget.showSensors)
                        ...sensors.map((sensor) {
                          return Positioned(
                            left: sensor.x * width - 14,

                            top: sensor.y * height - 14,

                            child: _buildSensor(sensor),
                          );
                        }),

                      // ==================================================
                      // EVACUATION ROUTE
                      // ==================================================
                      if (widget.showRoute)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: EvacuationRoutePainter(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SAFETY ZONE
  // ============================================================

  Widget _buildZone(MapZone zone) {
    final color = _riskColor(zone.risk);

    final isSelected = selectedZone == zone.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),

      decoration: BoxDecoration(
        color: color.withOpacity(isSelected ? 0.20 : 0.07),

        border: Border.all(
          color: color.withOpacity(isSelected ? 0.95 : 0.45),

          width: isSelected ? 2 : 1,
        ),
      ),

      child: Stack(
        children: [
          // ------------------------------------------
          // ZONE LABEL
          // ------------------------------------------
          Positioned(
            left: 4,
            top: 4,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),

              decoration: BoxDecoration(
                color: const Color(0xDD050A0F),

                border: Border.all(color: color.withOpacity(0.5)),
              ),

              child: Text(
                zone.name,

                style: TextStyle(
                  color: color,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),

          // ------------------------------------------
          // OCCUPANCY
          // ------------------------------------------
          Positioned(
            right: 4,
            bottom: 4,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),

              color: const Color(0xCC050A0F),

              child: Text(
                '${zone.occupancy}/${zone.capacity}',

                style: const TextStyle(color: Colors.white70, fontSize: 7),
              ),
            ),
          ),

          // ------------------------------------------
          // WARNING
          // ------------------------------------------
          if (zone.risk == RiskLevel.critical)
            Positioned(
              right: 5,
              top: 5,

              child: Container(
                padding: const EdgeInsets.all(2),

                decoration: const BoxDecoration(
                  color: Color(0xDD050A0F),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.warning_rounded,

                  color: Colors.redAccent,

                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SENSOR
  // ============================================================

  Widget _buildSensor(SensorPoint sensor) {
    late Color color;
    late IconData icon;

    switch (sensor.type) {
      case SensorType.smoke:
        color = Colors.redAccent;
        icon = Icons.cloud;
        break;

      case SensorType.temperature:
        color = Colors.orangeAccent;
        icon = Icons.thermostat;
        break;

      case SensorType.people:
        color = Colors.cyanAccent;
        icon = Icons.people;
        break;
    }

    return Tooltip(
      message: sensor.name,

      child: Container(
        width: 28,
        height: 28,

        decoration: BoxDecoration(
          color: const Color(0xEE050A0F),

          shape: BoxShape.circle,

          border: Border.all(color: color, width: 2),

          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.55),

              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),

        child: Icon(icon, color: color, size: 14),
      ),
    );
  }

  // ============================================================
  // ZONE DETAILS
  // ============================================================

  void _showZoneDetails(MapZone zone) {
    final color = _riskColor(zone.risk);

    showModalBottomSheet(
      context: context,

      backgroundColor: const Color(0xFF080F15),

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: color),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      zone.name,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),

                      borderRadius: BorderRadius.circular(6),
                    ),

                    child: Text(
                      zone.risk.name.toUpperCase(),

                      style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      'OCCUPANCY',
                      '${zone.occupancy}',
                      Icons.people,
                      Colors.cyanAccent,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _infoCard(
                      'CAPACITY',
                      '${zone.capacity}',
                      Icons.groups,
                      Colors.white70,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _infoCard(
                      'RISK',
                      zone.risk.name.toUpperCase(),
                      Icons.shield,
                      color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: Colors.white10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color, size: 17),

          const SizedBox(height: 6),

          Text(
            title,

            style: const TextStyle(color: Colors.white38, fontSize: 8),
          ),

          const SizedBox(height: 3),

          Text(
            value,

            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.safe:
        return Colors.greenAccent;

      case RiskLevel.caution:
        return Colors.yellowAccent;

      case RiskLevel.high:
        return Colors.orangeAccent;

      case RiskLevel.critical:
        return Colors.redAccent;
    }
  }
}

// ============================================================
// DATA MODELS
// ============================================================

enum RiskLevel { safe, caution, high, critical }

enum SensorType { smoke, temperature, people }

class MapZone {
  final String id;
  final String name;

  final double x;
  final double y;
  final double width;
  final double height;

  final RiskLevel risk;

  final int occupancy;
  final int capacity;

  const MapZone({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.risk,
    required this.occupancy,
    required this.capacity,
  });
}

class SensorPoint {
  final String id;
  final String name;

  final double x;
  final double y;

  final SensorType type;

  const SensorPoint({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.type,
  });
}

// ============================================================
// OPTIONAL COORDINATE GRID
// ============================================================

class CoordinateGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.04)
      ..strokeWidth = 1;

    const spacing = 35.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CoordinateGridPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// EVACUATION ROUTE
// ============================================================

class EvacuationRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // Route starts from East Block
    // and goes through the safer
    // central/south corridor to Exit A.

    path.moveTo(size.width * 0.825, size.height * 0.235);

    path.lineTo(size.width * 0.735, size.height * 0.320);

    path.lineTo(size.width * 0.650, size.height * 0.410);

    path.lineTo(size.width * 0.570, size.height * 0.500);

    path.lineTo(size.width * 0.455, size.height * 0.610);

    path.lineTo(size.width * 0.360, size.height * 0.615);

    path.lineTo(size.width * 0.170, size.height * 0.450);

    // --------------------------------------------
    // GLOW
    // --------------------------------------------

    final glow = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.14)
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glow);

    // --------------------------------------------
    // MAIN ROUTE
    // --------------------------------------------

    final route = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, route);

    // --------------------------------------------
    // ARROWS
    // --------------------------------------------

    _drawArrow(
      canvas,
      Offset(size.width * 0.735, size.height * 0.320),
      Offset(size.width * 0.650, size.height * 0.410),
    );

    _drawArrow(
      canvas,
      Offset(size.width * 0.570, size.height * 0.500),
      Offset(size.width * 0.455, size.height * 0.610),
    );

    _drawArrow(
      canvas,
      Offset(size.width * 0.360, size.height * 0.615),
      Offset(size.width * 0.170, size.height * 0.450),
    );

    // --------------------------------------------
    // EXIT GLOW
    // --------------------------------------------

    final exit = Offset(size.width * 0.170, size.height * 0.450);

    canvas.drawCircle(exit, 8, Paint()..color = Colors.greenAccent);

    canvas.drawCircle(
      exit,
      15,
      Paint()..color = Colors.greenAccent.withOpacity(0.15),
    );
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);

    const arrowLength = 10.0;

    final left = Offset(
      to.dx - arrowLength * math.cos(angle - 0.5),
      to.dy - arrowLength * math.sin(angle - 0.5),
    );

    final right = Offset(
      to.dx - arrowLength * math.cos(angle + 0.5),
      to.dy - arrowLength * math.sin(angle + 0.5),
    );

    canvas.drawLine(to, left, paint);

    canvas.drawLine(to, right, paint);
  }

  @override
  bool shouldRepaint(covariant EvacuationRoutePainter oldDelegate) {
    return false;
  }
}
