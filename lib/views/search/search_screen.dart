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

  void _onToggleFavorite(LocationModel location) async {
    final searchVM = context.read<SearchViewModel>();
    final isNowFav = await searchVM.toggleFavorite(location);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isNowFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isNowFav ? AppColors.starGold : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isNowFav
                      ? '${location.name} ditambahkan ke favorit'
                      : '${location.name} dihapus dari favorit',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Kota'),
      ),
      body: Column(
        children: [
          // 1. Search Bar Input
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
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
                      hintText: 'Cari kota (misal: Lampung, Jambi, Tokyo)...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
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
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    context.read<SearchViewModel>().search(_searchController.text);
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : AppColors.darkPill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: isDark ? AppColors.darkPill : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Search Results OR Riwayat Pencarian Saja
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, searchVM, _) {
                // Sedang loading search
                if (searchVM.isSearching) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(strokeWidth: 3),
                        SizedBox(height: 16),
                        Text(
                          'Mencari lokasi dari Open-Meteo...',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                // Jika sedang ada query pencarian
                if (_searchController.text.isNotEmpty) {
                  if (searchVM.errorMessage != null && searchVM.searchResults.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                color: AppColors.pastelPinkBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_off_rounded,
                                size: 38,
                                color: AppColors.pastelPinkText,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              searchVM.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return _buildSearchResultsList(searchVM, isDark);
                }

                // Default view: Murni Riwayat Pencarian Saja
                return _buildSearchHistoryOnly(searchVM, isDark);
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final location = results[index];
        final isFav = searchVM.isLocationFavorite(location);

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.pastelBlueBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_city_rounded,
                color: AppColors.pastelBlueText,
                size: 20,
              ),
            ),
            title: Text(
              location.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            subtitle: Text(
              location.subtitle,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isFav ? AppColors.starGold : Colors.grey.shade400,
                    size: 24,
                  ),
                  tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                  onPressed: () => _onToggleFavorite(location),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
            onTap: () => _onSelectLocation(location),
          ),
        );
      },
    );
  }

  /// Menampilkan riwayat pencarian kota saja (dari Local Storage)
  Widget _buildSearchHistoryOnly(SearchViewModel searchVM, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.pastelBlueBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: AppColors.pastelBlueText,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Riwayat Pencarian',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (searchVM.searchHistory.isNotEmpty)
                TextButton(
                  onPressed: () => searchVM.clearHistory(),
                  child: const Text(
                    'Hapus Semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (searchVM.searchHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(Icons.manage_search_rounded, size: 44, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Riwayat pencarian masih kosong.',
                    style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ketik nama kota di atas untuk mulai mencari.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
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
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0x14000000),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_rounded, color: Colors.grey, size: 18),
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
                    trailing: const Icon(Icons.north_west_rounded, size: 16, color: Colors.grey),
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
