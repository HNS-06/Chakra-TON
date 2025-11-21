import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';

class StoreLocatorScreen extends StatefulWidget {
  const StoreLocatorScreen({super.key});

  @override
  State<StoreLocatorScreen> createState() => _StoreLocatorScreenState();
}

class _StoreLocatorScreenState extends State<StoreLocatorScreen> {
  double? _userLat;
  double? _userLon;
  final MapController _mapController = MapController();
  final double _currentZoom = 15.0;
  StreamSubscription<Position>? _positionStreamSub;
  bool _loading = true;
  String? _error;
  List<_Place> _places = [];
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndFetch();
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndFetch() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final asked = await Geolocator.requestPermission();
        if (asked == LocationPermission.denied || asked == LocationPermission.deniedForever) {
          if (!mounted) return;
          setState(() {
            _error = 'Location permission is required to find nearby stores.';
            _loading = false;
          });
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;

      setState(() {
        _userLat = pos.latitude;
        _userLon = pos.longitude;
        _mapInitialized = true;
      });

      // Start listening for location updates
      _positionStreamSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      ).listen((p) {
        if (!mounted) return;
        setState(() {
          _userLat = p.latitude;
          _userLon = p.longitude;
        });
        _mapController.move(ll.LatLng(p.latitude, p.longitude), _currentZoom);
      });

      // Fetch nearby places
      await _fetchNearbyPlaces(pos.latitude, pos.longitude);

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to get location: $e';
        _loading = false;
      });
    }
  }

  Future<void> _fetchNearbyPlaces(double lat, double lon) async {
    const radius = 2000; // meters

    final query = '''
[out:json][timeout:10];
(
  node["shop"](around:$radius,$lat,$lon);
  node["amenity"="cafe"](around:$radius,$lat,$lon);
  node["amenity"="restaurant"](around:$radius,$lat,$lon);
  node["amenity"="fast_food"](around:$radius,$lat,$lon);
);
out center;
''';

    Future<List<_Place>> fetchFromOverpass(Uri endpoint) async {
      final resp = await http
          .post(
            endpoint,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
              'User-Agent': 'chakra-ton-app/1.0 (support@chakra-ton.app)',
            },
            body: {'data': query},
          )
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode != 200) {
        throw _OverpassException('Overpass error ${resp.statusCode}');
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>?;
      if (decoded == null) {
        throw const FormatException('Unexpected response structure');
      }

      final elements = (decoded['elements'] as List<dynamic>?) ?? [];
      final List<_Place> places = [];

      for (final e in elements) {
        final tags = e['tags'] as Map<String, dynamic>?;
        if (tags == null) continue;

        final name = tags['name'] ?? tags['shop'] ?? tags['brand'] ?? 'Unknown';
        final rawLat = e['lat'] ?? (e['center'] as Map<String, dynamic>?)?['lat'];
        final rawLon = e['lon'] ?? (e['center'] as Map<String, dynamic>?)?['lon'];
        final latE = rawLat is num ? rawLat.toDouble() : null;
        final lonE = rawLon is num ? rawLon.toDouble() : null;

        if (latE == null || lonE == null) continue;

        final distMeters = Geolocator.distanceBetween(lat, lon, latE, lonE);
        final street = tags['addr:street'] ?? '';
        final house = tags['addr:housenumber'] ?? '';
        final address = [street, house].where((part) => part.toString().trim().isNotEmpty).join(' ');

        places.add(_Place(name.toString(), address, latE, lonE, distMeters));
      }

      places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return places;
    }

    try {
      final endpoints = [
        Uri.parse('https://overpass.kumi.systems/api/interpreter'), // reliable mirror
        Uri.parse('https://maps.mail.ru/osm/tools/overpass/api/interpreter'),
        Uri.parse('https://overpass-api.de/api/interpreter'),
      ];

      List<_Place>? places;
      Exception? lastError;

      for (final endpoint in endpoints) {
        try {
          places = await fetchFromOverpass(endpoint);
          if (places.isNotEmpty) break;
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          await Future.delayed(const Duration(milliseconds: 400));
          continue;
        }
      }

      if (!mounted) return;

      if (places != null && places.isNotEmpty) {
        setState(() {
          _error = null;
          _places = places!;
        });
      } else if (places != null && places.isEmpty) {
        setState(() {
          _error = 'No partner stores found nearby.\nTry widening your search radius.';
          _places = [];
        });
      } else {
        throw lastError ?? Exception('Unknown map service error');
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _error = 'Store service timed out. Please check your connection and retry.');
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Invalid data from store service: ${e.message}');
    } on _OverpassException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      final fallbackPlaces = [
        _Place('Coffee House', 'Main Street 12', lat + 0.001, lon + 0.001, 150),
        _Place('Daily Market', 'Central Plaza', lat - 0.0015, lon + 0.0008, 220),
        _Place('Green Grocer', 'Oak Avenue', lat + 0.002, lon - 0.001, 310),
      ];
      setState(() {
        _error = 'Unable to reach store service. Showing sample locations.';
        _places = fallbackPlaces;
      });
    }
  }

  void _showPlaceActions(_Place place) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(place.address?.isNotEmpty == true ? place.address! : 'No address available'),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final lat = place.lat;
                      final lon = place.lon;
                      final gmaps = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
                      if (await canLaunchUrl(gmaps)) {
                        await launchUrl(gmaps, mode: LaunchMode.externalApplication);
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open maps')),
                        );
                      }
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _searchStores(String query) {
    if (_places.isEmpty) return;
    
    final matches = _places.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    if (matches.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found: ${matches.first.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Locator'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    // Map
                    Container(
                      height: 220,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _mapInitialized && _userLat != null && _userLon != null
                            ? FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: ll.LatLng(_userLat!, _userLon!),
                                  initialZoom: _currentZoom,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 40,
                                        height: 40,
                                        point: ll.LatLng(_userLat!, _userLon!),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          child: const Icon(Icons.person, color: Colors.white, size: 18),
                                        ),
                                      ),
                                      ..._places.map((p) => Marker(
                                            width: 40,
                                            height: 40,
                                            point: ll.LatLng(p.lat, p.lon),
                                            child: GestureDetector(
                                              onTap: () => _showPlaceActions(p),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).cardColor,
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(6),
                                                child: Icon(
                                                  Icons.store,
                                                  color: Theme.of(context).primaryColor,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),

                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search stores or address',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: _searchStores,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // List
                    Expanded(
                      child: _places.isEmpty
                          ? const Center(child: Text('No nearby places found.'))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _places.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final p = _places[index];
                                final distanceKm = (p.distanceMeters / 1000);
                                return Material(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context).cardColor,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                      child: Icon(
                                        Icons.store,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    title: Text(p.name),
                                    subtitle: Text(p.address?.isNotEmpty == true ? p.address! : 'No address available'),
                                    trailing: Text('${distanceKm.toStringAsFixed(1)} km'),
                                    onTap: () => _showPlaceActions(p),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _OverpassException implements Exception {
  final String message;
  const _OverpassException(this.message);
}

class _Place {
  final String name;
  final String? address;
  final double lat;
  final double lon;
  final double distanceMeters;

  _Place(this.name, this.address, this.lat, this.lon, this.distanceMeters);
}