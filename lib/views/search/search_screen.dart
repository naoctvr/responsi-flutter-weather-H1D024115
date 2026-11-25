import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/location_model.dart';
import '../../viewmodels/search_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().loadLocalData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSelectLocation(LocationModel location) async {
    final searchVM = context.read<SearchViewModel>();
    await searchVM.onLocationSelected(location);
    if (mounted) {
      Navigator.pop(context, location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari & Kelola Lokasi'),
      ),
      body: Column(
        children: [
          // 1. Search Bar Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (query) {
                      context.read<SearchViewModel>().search(query);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari nama kota (misal: Bandung, Tokyo)...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchViewModel>().clearSearch();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                      if (value.isEmpty) {
                        context.read<SearchViewModel>().clearSearch();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  tooltip: 'Cari',
                  onPressed: () {
                    context.read<SearchViewModel>().search(_searchController.text);
                  },
                ),
              ],
            ),
          ),

          // 2. Search Results OR Favorites & History
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, searchVM, _) {
                // Sedang loading search
                if (searchVM.isSearching) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Mencari lokasi dari Open-Meteo...'),
                      ],
                    ),
                  );
                }

                // Jika sedang ada query dan hasil pencarian tersedia
                if (_searchController.text.isNotEmpty) {
                  if (searchVM.errorMessage != null && searchVM.searchResults.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_off, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              searchVM.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return _buildSearchResultsList(searchVM, isDark);
                }

                // Default view: Tab / Tampilan Favorit & Riwayat
                return _buildFavoritesAndHistory(searchVM, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Menampilkan hasil pencarian dari Open-Meteo API
  Widget _buildSearchResultsList(SearchViewModel searchVM, bool isDark) {
    final results = searchVM.searchResults;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final location = results[index];
        final isFav = searchVM.isLocationFavorite(location);

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              backgroundColor: Color(0x1F2563EB),
              child: Icon(Icons.location_city, color: AppColors.primary),
            ),
            title: Text(
              location.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              location.subtitle,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isFav ? const Color(0xFFFBBF24) : Colors.grey,
                  ),
                  tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                  onPressed: () {
                    searchVM.toggleFavorite(location);
                  },
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () => _onSelectLocation(location),
          ),
        );
      },
    );
  }

  /// Menampilkan daftar lokasi favorit dan riwayat pencarian (dari Local Storage)
  Widget _buildFavoritesAndHistory(SearchViewModel searchVM, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SEKSI 1: LOKASI FAVORIT ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bookmark_rounded, color: Color(0xFFFBBF24), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Lokasi Favorit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${searchVM.favoriteLocations.length} Kota',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (searchVM.favoriteLocations.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Belum ada lokasi favorit tersimpan.\nKlik ikon bookmark untuk menyimpan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchVM.favoriteLocations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final location = searchVM.favoriteLocations[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0x26FBBF24),
                      child: Icon(Icons.star_rounded, color: Color(0xFFFBBF24)),
                    ),
                    title: Text(
                      location.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      location.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          tooltip: 'Hapus dari Favorit',
                          onPressed: () => searchVM.removeFavorite(location),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () => _onSelectLocation(location),
                  ),
                );
              },
            ),

          const SizedBox(height: 28),

          // --- SEKSI 2: RIWAYAT PENCARIAN ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Riwayat Pencarian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (searchVM.searchHistory.isNotEmpty)
                TextButton(
                  onPressed: () => searchVM.clearHistory(),
                  child: const Text('Hapus Semua', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (searchVM.searchHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Riwayat pencarian masih kosong.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchVM.searchHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final location = searchVM.searchHistory[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.withAlpha(30),
                      child: const Icon(Icons.history, color: Colors.grey),
                    ),
                    title: Text(
                      location.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      location.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    trailing: const Icon(Icons.north_west_rounded, size: 18, color: Colors.grey),
                    onTap: () => _onSelectLocation(location),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
