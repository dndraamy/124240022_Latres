import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/character_model.dart';
import '../../controllers/character_controller.dart';
import '../../theme/app_theme.dart';
import '../pages/detail_page.dart';

class CharacterCard extends StatelessWidget {
  final Character character;

  const CharacterCard({super.key, required this.character});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return AppTheme.aliveColor;
      case 'dead':
        return AppTheme.deadColor;
      default:
        return AppTheme.unknownColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final CharacterController controller = Get.isRegistered<CharacterController>()
        ? Get.find<CharacterController>()
        : Get.put(CharacterController(), permanent: true);
    final statusColor = _getStatusColor(character.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderSubtle.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.portalGreen.withValues(alpha: 0.1),
          highlightColor: AppTheme.portalGreen.withValues(alpha: 0.05),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(characterId: character.id),
              ),
            );
          },
          child: Row(
            children: [
              // Foto Karakter
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Hero(
                  tag: 'char_img_${character.id}',
                  child: Image.network(
                    character.image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: AppTheme.surfaceCardLight,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppTheme.spaceDark,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.portalGreen,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info Karakter
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.6),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${character.status} - ${character.species}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Origin: ${character.origin.name}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Favorit
              Obx(() {
                final isFav = controller.isFavorite(character.id);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppTheme.deadColor : AppTheme.textSecondary,
                    size: 26,
                  ),
                  onPressed: () async {
                    final added = await controller.toggleFavorite(character);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                added ? Icons.favorite : Icons.favorite_border,
                                color: added ? AppTheme.deadColor : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  added
                                      ? '${character.name} ditambahkan ke favorit'
                                      : '${character.name} dihapus dari favorit',
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
                );
              }),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
