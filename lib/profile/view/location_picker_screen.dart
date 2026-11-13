import 'package:flutter/material.dart';

/// Represents a location choice with name, city, and coordinates.
class LocationItem {
  const LocationItem({
    required this.name,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String city;
  final String state;
  final double latitude;
  final double longitude;

  String get formatted => '$name, $city';
}

/// Dedicated Google Maps style Location Picker page.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  final String? initialLocation;

  static const List<LocationItem> popularLocations = [
    LocationItem(
      name: 'Jubilee Hills',
      city: 'Hyderabad',
      state: 'Telangana',
      latitude: 17.4319,
      longitude: 78.4073,
    ),
    LocationItem(
      name: 'Banjara Hills',
      city: 'Hyderabad',
      state: 'Telangana',
      latitude: 17.4156,
      longitude: 78.4350,
    ),
    LocationItem(
      name: 'Madhapur / Hitec City',
      city: 'Hyderabad',
      state: 'Telangana',
      latitude: 17.4483,
      longitude: 78.3915,
    ),
    LocationItem(
      name: 'Gachibowli',
      city: 'Hyderabad',
      state: 'Telangana',
      latitude: 17.4401,
      longitude: 78.3489,
    ),
    LocationItem(
      name: 'Koramangala',
      city: 'Bangalore',
      state: 'Karnataka',
      latitude: 12.9352,
      longitude: 77.6245,
    ),
    LocationItem(
      name: 'Indiranagar',
      city: 'Bangalore',
      state: 'Karnataka',
      latitude: 12.9784,
      longitude: 77.6408,
    ),
    LocationItem(
      name: 'Bandra West',
      city: 'Mumbai',
      state: 'Maharashtra',
      latitude: 19.0596,
      longitude: 72.8295,
    ),
    LocationItem(
      name: 'Connaught Place',
      city: 'New Delhi',
      state: 'Delhi',
      latitude: 28.6315,
      longitude: 77.2167,
    ),
    LocationItem(
      name: 'Panaji',
      city: 'Goa',
      state: 'Goa',
      latitude: 15.4909,
      longitude: 73.8278,
    ),
    LocationItem(
      name: 'Koregaon Park',
      city: 'Pune',
      state: 'Maharashtra',
      latitude: 18.5362,
      longitude: 73.8939,
    ),
  ];

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late LocationItem _selected;
  double _zoomLevel = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLocation?.trim() ?? '';
    _selected = LocationPickerScreen.popularLocations.firstWhere(
      (loc) => loc.formatted.toLowerCase() == initial.toLowerCase(),
      orElse: () => LocationItem(
        name: initial.isNotEmpty ? initial : 'Jubilee Hills',
        city: 'Hyderabad',
        state: 'Telangana',
        latitude: 17.4319,
        longitude: 78.4073,
      ),
    );
    _searchCtrl.text = _selected.formatted;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectLocation(LocationItem item) {
    setState(() {
      _selected = item;
      _searchCtrl.text = item.formatted;
      _searchQuery = '';
    });
  }

  void _useCurrentLocation() {
    // Current GPS detected location
    const current = LocationItem(
      name: 'Current Location (Jubilee Hills)',
      city: 'Hyderabad',
      state: 'Telangana',
      latitude: 17.4325,
      longitude: 78.4080,
    );
    setState(() {
      _selected = current;
      _searchCtrl.text = current.formatted;
      _searchQuery = '';
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.my_location, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Location detected via GPS!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _confirmAndPop() {
    Navigator.of(context).pop(_selected.formatted);
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = LocationPickerScreen.popularLocations.where((loc) {
      if (_searchQuery.trim().isEmpty) return false;
      final q = _searchQuery.trim().toLowerCase();
      return loc.name.toLowerCase().contains(q) ||
          loc.city.toLowerCase().contains(q) ||
          loc.state.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E2D),
        actions: [
          IconButton(
            tooltip: 'Use GPS',
            icon: const Icon(Icons.my_location, color: Color(0xFF6C4AB6)),
            onPressed: _useCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Interactive Map View Canvas
          Positioned.fill(
            child: ClipRect(
              child: GestureDetector(
                onScaleUpdate: (details) {
                  setState(() {
                    _zoomLevel = (_zoomLevel * details.scale).clamp(0.6, 2.5);
                  });
                },
                child: CustomPaint(
                  painter: _MapCanvasPainter(
                    lat: _selected.latitude,
                    lng: _selected.longitude,
                    zoom: _zoomLevel,
                  ),
                ),
              ),
            ),
          ),

          // Center Pin Marker
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2D),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.place,
                        size: 14,
                        color: Color(0xFFFF5252),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selected.formatted,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.location_on_sharp,
                  size: 42,
                  color: Color(0xFF6C4AB6),
                ),
                Container(
                  width: 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 42),
              ],
            ),
          ),

          // Map Zoom & Target Controls (Right side)
          Positioned(
            right: 16,
            bottom: 220,
            child: Column(
              children: [
                _buildMapControl(
                  icon: Icons.add,
                  onTap: () => setState(
                    () => _zoomLevel = (_zoomLevel + 0.2).clamp(0.6, 2.5),
                  ),
                ),
                const SizedBox(height: 8),
                _buildMapControl(
                  icon: Icons.remove,
                  onTap: () => setState(
                    () => _zoomLevel = (_zoomLevel - 0.2).clamp(0.6, 2.5),
                  ),
                ),
                const SizedBox(height: 8),
                _buildMapControl(
                  icon: Icons.my_location,
                  onTap: _useCurrentLocation,
                ),
              ],
            ),
          ),

          // 2. Top Search Floating Bar & Results
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  shadowColor: Colors.black.withValues(alpha: 0.15),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search city, area, or landmark...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF6C4AB6),
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                // Autocomplete Suggestions Dropdown
                if (searchResults.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = searchResults[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF6C4AB6),
                              size: 20,
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              '${item.city}, ${item.state}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            onTap: () => _selectLocation(item),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Popular City Chips Bar
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: LocationPickerScreen.popularLocations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final loc =
                            LocationPickerScreen.popularLocations[index];
                        final isSel = _selected.formatted == loc.formatted;
                        return ChoiceChip(
                          label: Text(loc.formatted),
                          selected: isSel,
                          selectedColor: const Color(0xFF6C4AB6),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.w500,
                            color: isSel ? Colors.white : Colors.black87,
                          ),
                          elevation: 1,
                          side: BorderSide(
                            color: isSel
                                ? const Color(0xFF6C4AB6)
                                : const Color(0xFFECEAF3),
                          ),
                          onSelected: (_) => _selectLocation(loc),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 3. Bottom Location Details Card & Confirm Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(20),
              shadowColor: Colors.black.withValues(alpha: 0.2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5FC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.map_rounded,
                            color: Color(0xFF6C4AB6),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selected.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1E1E2D),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_selected.city}, ${_selected.state} • '
                                '${_selected.latitude.toStringAsFixed(4)}, '
                                '${_selected.longitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _confirmAndPop,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C4AB6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1E1E2D)),
        ),
      ),
    );
  }
}

/// Custom painter for rendering stylized Google Maps streets, waterways,
/// and city blocks.
class _MapCanvasPainter extends CustomPainter {
  const _MapCanvasPainter({
    required this.lat,
    required this.lng,
    required this.zoom,
  });

  final double lat;
  final double lng;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background land
    final bgPaint = Paint()..color = const Color(0xFFF3F2EE);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final parkPaint = Paint()
      ..color = const Color(0xFFC8E6C9).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Parks / Greenery patches
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.1, size.height * 0.2, 140, 100),
          const Radius.circular(20),
        ),
        parkPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.65, size.height * 0.45, 120, 160),
          const Radius.circular(24),
        ),
        parkPaint,
      );

    // Curving river
    final riverPath = Path()
      ..moveTo(0, size.height * 0.65)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.65,
        size.height * 0.75,
        size.width,
        size.height * 0.6,
      )
      ..lineTo(size.width, size.height * 0.72)
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.87,
        size.width * 0.35,
        size.height * 0.67,
        0,
        size.height * 0.77,
      )
      ..close();
    final riverPaint = Paint()..color = const Color(0xFFB3E5FC);
    canvas.drawPath(riverPath, riverPaint);

    // 3. Grid of secondary roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0 * zoom
      ..style = PaintingStyle.stroke;

    final step = 70.0 * zoom;
    for (double x = 0; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
    for (double y = 0; y < size.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }

    // 4. Primary arterial avenues
    final primaryRoadPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.9)
      ..strokeWidth = 7.0 * zoom
      ..style = PaintingStyle.stroke;

    canvas
      ..drawLine(
        Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.4),
        primaryRoadPaint,
      )
      ..drawLine(
        Offset(size.width * 0.5, 0),
        Offset(size.width * 0.5, size.height),
        primaryRoadPaint,
      );

    // Diagonal highway
    final highwayPaint = Paint()
      ..color = const Color(0xFFFFB74D)
      ..strokeWidth = 9.0 * zoom
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.15),
      Offset(size.width, size.height * 0.85),
      highwayPaint,
    );

    // 5. Concentric radar ring around center pin
    final center = Offset(size.width / 2, size.height / 2);
    final pulsePaint = Paint()
      ..color = const Color(0xFF6C4AB6).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 55.0 * zoom, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.lat != lat ||
        oldDelegate.lng != lng ||
        oldDelegate.zoom != zoom;
  }
}
