import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/character_controller.dart';
import '../../theme/app_theme.dart';

class EpisodePage extends StatelessWidget {
  const EpisodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CharacterController controller = Get.isRegistered<CharacterController>()
        ? Get.find<CharacterController>()
        : Get.put(CharacterController(), permanent: true);

    return Scaffold(
      backgroundColor: AppTheme.spaceDark,
      appBar: AppBar(
        title: const Text(
          'Daftar Episode',
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
        if (controller.isLoadingEpisodes.value && controller.episodes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.portalGreen),
          );
        }

        if (controller.episodeError.value.isNotEmpty &&
            controller.episodes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.deadColor),
                  const SizedBox(height: 14),
                  Text(
                    controller.episodeError.value.contains('SocketException') ||
                            controller.episodeError.value.contains('Failed host lookup')
                        ? 'Gagal memuat daftar episode.\nPeriksa koneksi internet Anda.'
                        : 'Gagal memuat daftar episode.',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: controller.fetchEpisodes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.portalGreen,
                      foregroundColor: AppTheme.spaceDark,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchEpisodes,
          color: AppTheme.portalGreen,
          backgroundColor: AppTheme.surfaceCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemCount: controller.episodes.length,
            itemBuilder: (context, index) {
              final episode = controller.episodes[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.borderSubtle.withValues(alpha: 0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.portalBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.portalBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: AppTheme.portalBlue,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    episode.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Rilis: ${episode.airDate}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.portalGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.portalGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      episode.episode,
                      style: const TextStyle(
                        color: AppTheme.portalGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
