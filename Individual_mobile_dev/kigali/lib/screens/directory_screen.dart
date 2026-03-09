import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'listing_form_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ListingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Listing',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ListingFormScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or address…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => provider.setSearchQuery(''),
                      )
                    : null,
              ),
              onChanged: (v) => provider.setSearchQuery(v),
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: provider.categoryFilter == null,
                    onSelected: (_) => provider.setCategoryFilter(null),
                  ),
                ),
                ...Listing.categories.map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(cat),
                        selected: provider.categoryFilter == cat,
                        onSelected: (_) => provider.setCategoryFilter(
                          provider.categoryFilter == cat ? null : cat,
                        ),
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Listings
          Expanded(
            child: _buildListingsContent(context, provider, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsContent(
      BuildContext context, ListingsProvider provider, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(provider.error!, style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }

    final listings = provider.filteredListings;

    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'No listings found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: listings.length,
      itemBuilder: (context, i) {
        final listing = listings[i];
        return ListingCard(
          listing: listing,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing),
            ),
          ),
        );
      },
    );
  }
}
