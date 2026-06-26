import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vendor.dart';
import '../services/local_storage_service.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final _service = LocalStorageService();
  VendorCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _service.seedVendorData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(AppLocalizations.of(context)!.all),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
              ),
              ...VendorCategory.values.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(c.label),
                  selected: _selectedCategory == c,
                  onSelected: (_) => setState(() => _selectedCategory = c),
                ),
              )),
            ],
          ),
        ),
        // Vendor list
        Expanded(
          child: StreamBuilder<List<Vendor>>(
            stream: _service.getVendors(category: _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final vendors = snapshot.data ?? [];
              if (vendors.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context)!.noVendors));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: vendors.length,
                itemBuilder: (_, i) => _VendorCard(vendor: vendors[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Vendor vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Text(vendor.name[0])),
        title: Text(vendor.name),
        subtitle: Text('${vendor.category.label} • ${vendor.city}\n${vendor.priceRange}'),
        isThreeLine: true,
        trailing: vendor.instagram != null
            ? IconButton(
                icon: const Icon(Icons.open_in_new, size: 20),
                onPressed: () => launchUrl(Uri.parse('https://instagram.com/${vendor.instagram}')),
              )
            : null,
      ),
    );
  }
}
