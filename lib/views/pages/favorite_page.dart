import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/character_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/character_card.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CharacterController controller = Get.isRegistered<CharacterController>()
        ? Get.find<CharacterController>()
        : Get.put(CharacterController(), permanent: true);

    return Scaffold(
      backgroundColor: AppTheme.spaceDark,
      appBar: AppBar(
        title: const Text(
          'Karakter Favorit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.surfaceCard,
        foregroundColor: AppTheme.portalGreen,
        elevation: 0,
      ),
      body: Obx(() {
        final favorites = controller.favorites;

        // Tampilan saat daftar favorit masih kosong
        if (favorites.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceCard,
                      border: Border.all(
                        color: AppTheme.borderSubtle,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Daftar favorit masih kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ketuk ikon hati pada karakter untuk menyimpannya ke daftar ini',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Menghapus item dengan gestur geser (swipe)
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final character = favorites[index];

            return Dismissible(
              key: Key('fav_${character.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.deadColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.deadColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.delete_outline, color: Colors.white, size: 24),
                  ],
                ),
              ),
              onDismissed: (direction) async {
                final removedName = character.name;
                await controller.removeFavoriteAt(character.id);

                // Notifikasi setelah karakter dihapus
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: AppTheme.deadColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$removedName berhasil dihapus dari favorit!',
                              style: const TextStyle(color: AppTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppTheme.surfaceCardLight,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: CharacterCard(character: character),
            );
          },
        );
      }),
    );
  }
}
