import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';
import 'listing_detail_screen.dart';

const _kigaliCenter = LatLng(-1.9441, 30.0619);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  String? _selectedCategory;

  Set<Marker> _buildMarkers(List<Listing> listings) {
    var filtered = listings.where((l) => l.latitude != 0.0 || l.longitude != 0.0);
    if (_selectedCategory != null) {
      filtered = filtered.where((l) => l.category == _selectedCategory);
    }

    return filtered.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id ?? listing.name),
        position: LatLng(listing.latitude, listing.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(_categoryHue(listing.category)),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing),
            ),
          ),
        ),
      );
    }).toSet();
  }

  double _categoryHue(String category) {
    switch (category) {
      case 'Hospital':
        return BitmapDescriptor.hueRose;
      case 'Police Station':
        return BitmapDescriptor.hueBlue;
      case 'Library':
        return BitmapDescriptor.hueOrange;
      case 'Restaurant':
        return BitmapDescriptor.hueRed;
      case 'Café':
        return BitmapDescriptor.hueYellow;
      case 'Park':
        return BitmapDescriptor.hueGreen;
      case 'Tourist Attraction':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueMagenta;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ListingsProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: _mapType,
            initialCameraPosition:
                const CameraPosition(target: _kigaliCenter, zoom: 13),
            onMapCreated: (controller) => _mapController = controller,
            markers: _buildMarkers(provider.allListings),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            padding: const EdgeInsets.only(top: 120, bottom: 16),
          ),

          // Category filter chips overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title bar
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(28),
                    color: theme.colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.map,
                              color: theme.colorScheme.primary, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Kigali Map',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${provider.allListings.where((l) => l.latitude != 0.0 || l.longitude != 0.0).length} places',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(context, 'All', null),
                        ...Listing.categories.map(
                          (cat) => _buildFilterChip(context, cat, cat),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map controls (right side)
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Map type toggle
                FloatingActionButton.small(
                  heroTag: 'mapType',
                  onPressed: () => setState(() {
                    _mapType = _mapType == MapType.normal
                        ? MapType.satellite
                        : MapType.normal;
                  }),
                  child: Icon(
                    _mapType == MapType.satellite
                        ? Icons.map_outlined
                        : Icons.satellite_alt,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),
                // Zoom to Kigali
                FloatingActionButton.small(
                  heroTag: 'resetView',
                  onPressed: () => _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_kigaliCenter, 13),
                  ),
                  child: const Icon(Icons.center_focus_strong, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        elevation: isSelected ? 2 : 1,
        borderRadius: BorderRadius.circular(20),
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _selectedCategory = category),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
