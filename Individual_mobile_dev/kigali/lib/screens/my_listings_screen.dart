import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'listing_form_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final listingsProvider = context.watch<ListingsProvider>();
    final uid = auth.user?.uid ?? '';
    final myListings = listingsProvider.userListings(uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListingFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: listingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : myListings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.post_add,
                          size: 56, color: theme.colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        'You have not created any listings yet.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonalIcon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ListingFormScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Your First'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: myListings.length,
                  itemBuilder: (context, i) {
                    final listing = myListings[i];
                    return ListingCard(
                      listing: listing,
                      showActions: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ListingDetailScreen(listing: listing),
                        ),
                      ),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ListingFormScreen(listing: listing),
                        ),
                      ),
                      onDelete: () => _confirmDelete(
                          context, listingsProvider, listing.id!),
                    );
                  },
                ),
    );
  }

  void _confirmDelete(
      BuildContext context, ListingsProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteListing(id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
