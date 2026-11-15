import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/character_controller.dart';
import '../../services/local_storage_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/character_card.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Pemicu Infinite Scroll ketika mendekati dasar list (250px)
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 250) {
      Get.find<CharacterController>().loadMoreCharacters();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.deadColor),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Keluar',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deadColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await LocalStorageService.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final CharacterController controller = Get.isRegistered<CharacterController>()
        ? Get.find<CharacterController>()
        : Get.put(CharacterController(), permanent: true);

    return Scaffold(
      backgroundColor: AppTheme.spaceDark,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hub_outlined, color: AppTheme.portalGreen, size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rick & Morty',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppTheme.portalGreen,
                    letterSpacing: 1.2,
                  ),
                ),
                Obx(() => Text(
                  controller.loggedInName.value.isNotEmpty
                      ? 'Halo, ${controller.loggedInName.value}'
                      : 'Katalog Karakter',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.portalBlue,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: AppTheme.deadColor),
            tooltip: 'Keluar',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Kolom Pencarian Karakter
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari karakter berdasarkan nama...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppTheme.portalGreen),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    controller.searchByName('');
                  },
                ),
                filled: true,
                fillColor: AppTheme.surfaceCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.portalGreen, width: 1.5),
                ),
              ),
              onChanged: (val) => controller.searchByName(val),
            ),
          ),

          // Filter Status Karakter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() {
                final currentStatus = controller.selectedStatus.value;
                return Row(
                  children: [
                    _filterChip(
                      label: 'All',
                      selectedStatus: currentStatus,
                      activeColor: AppTheme.portalGreen,
                      onTap: () => controller.filterByStatus('All'),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Alive',
                      selectedStatus: currentStatus,
                      activeColor: AppTheme.aliveColor,
                      icon: Icons.favorite,
                      onTap: () => controller.filterByStatus('Alive'),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Dead',
                      selectedStatus: currentStatus,
                      activeColor: AppTheme.deadColor,
                      icon: Icons.dangerous,
                      onTap: () => controller.filterByStatus('Dead'),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Unknown',
                      selectedStatus: currentStatus,
                      activeColor: AppTheme.unknownColor,
                      icon: Icons.help_outline,
                      onTap: () => controller.filterByStatus('Unknown'),
                    ),
                  ],
                );
              }),
            ),
          ),

          // Ringkasan Jumlah Karakter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() {
              final count = controller.characters.length;
              final total = controller.totalCharacters.value;
              if (count == 0) return const SizedBox.shrink();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.portalGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Total: $total Karakter',
                        style: const TextStyle(
                          color: AppTheme.portalGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Menampilkan $count dari $total',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),

          // Character List dengan Infinite Scroll (Paging)
          Expanded(
            child: Obx(() {
              // Loading state halaman pertama
              if (controller.isLoadingCharacters.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.portalGreen),
                      SizedBox(height: 14),
                      Text(
                        'Memuat daftar karakter...',
                        style: TextStyle(color: AppTheme.portalGreen, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              // Error handling
              if (controller.characterError.value.isNotEmpty) {
                final isNetworkErr = controller.characterError.value.contains('SocketException') ||
                    controller.characterError.value.contains('Failed host lookup');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 60, color: AppTheme.deadColor),
                        const SizedBox(height: 12),
                        const Text(
                          'Gagal Memuat Data',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isNetworkErr
                              ? 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'
                              : controller.characterError.value,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: controller.fetchCharacters,
                          icon: const Icon(Icons.refresh, color: AppTheme.spaceDark),
                          label: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              color: AppTheme.spaceDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.portalGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Empty result
              if (controller.characters.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: AppTheme.textSecondary),
                      SizedBox(height: 12),
                      Text(
                        'Tidak ada karakter yang cocok dengan kriteria',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              final hasMore = controller.hasNextPage.value;
              final itemCount = controller.characters.length + (hasMore ? 1 : 0);

              // Daftar karakter
              return RefreshIndicator(
                onRefresh: controller.fetchCharacters,
                color: AppTheme.spaceDark,
                backgroundColor: AppTheme.portalGreen,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index < controller.characters.length) {
                      final character = controller.characters[index];
                      return CharacterCard(character: character);
                    }

                    // Loading indicator saat memuat halaman berikutnya (Infinite Scroll)
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.portalGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Memuat karakter lainnya...',
                              style: TextStyle(
                                color: AppTheme.portalGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required String selectedStatus,
    required Color activeColor,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedStatus == label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.borderSubtle,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? activeColor : AppTheme.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
