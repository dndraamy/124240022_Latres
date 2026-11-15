import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/character_controller.dart';
import '../../models/character_model.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';
import '../../theme/app_theme.dart';

class DetailPage extends StatefulWidget {
  final int characterId;

  const DetailPage({super.key, required this.characterId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Character? _character;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadCharacterDetail();
  }

  Future<void> _loadCharacterDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final character = await ApiService.getCharacterById(widget.characterId);
      final isFav = await LocalStorageService.isFavorite(widget.characterId);
      if (mounted) {
        setState(() {
          _character = character;
          _isFavorite = isFav;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _toggleFavorite() async {
    if (_character == null) return;

    if (_isFavorite) {
      await LocalStorageService.removeFavorite(_character!.id);
      if (Get.isRegistered<CharacterController>()) {
        Get.find<CharacterController>().loadFavorites();
      }
      setState(() => _isFavorite = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite_border, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_character!.name} dihapus dari favorit',
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
    } else {
      await LocalStorageService.addFavorite(_character!);
      if (Get.isRegistered<CharacterController>()) {
        Get.find<CharacterController>().loadFavorites();
      }
      setState(() => _isFavorite = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: AppTheme.deadColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_character!.name} ditambahkan ke favorit',
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
    }
  }

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
    return Scaffold(
      backgroundColor: AppTheme.spaceDark,
      appBar: AppBar(
        title: Text(
          _character?.name ?? 'Detail Karakter',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.surfaceCard,
        foregroundColor: AppTheme.portalGreen,
        elevation: 0,
        actions: [
          if (_character != null)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? AppTheme.deadColor : AppTheme.textSecondary,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.portalGreen),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.deadColor),
              const SizedBox(height: 14),
              Text(
                _errorMessage.contains('SocketException') || _errorMessage.contains('Failed host lookup')
                    ? 'Gagal memuat detail karakter.\nPeriksa koneksi internet Anda.'
                    : 'Gagal memuat detail karakter.',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadCharacterDetail,
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

    if (_character == null) {
      return const Center(
        child: Text(
          'Data karakter tidak ditemukan',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
      );
    }

    final char = _character!;
    final statusColor = _getStatusColor(char.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto Karakter dengan portal glow
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.portalGreen.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.portalGreen.withValues(alpha: 0.25),
                    blurRadius: 22,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Hero(
                  tag: 'char_img_${char.id}',
                  child: Image.network(
                    char.image,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 220,
                      height: 220,
                      color: AppTheme.surfaceCardLight,
                      child: const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nama Karakter
          Text(
            char.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.8),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  char.status.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Card Informasi Lengkap
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.borderSubtle.withValues(alpha: 0.7),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _infoTile(Icons.category_outlined, 'Spesies', char.species),
                const Divider(color: AppTheme.borderSubtle, height: 20),
                _infoTile(Icons.wc_outlined, 'Gender', char.gender),
                if (char.type.isNotEmpty) ...[
                  const Divider(color: AppTheme.borderSubtle, height: 20),
                  _infoTile(Icons.info_outline, 'Type', char.type),
                ],
                const Divider(color: AppTheme.borderSubtle, height: 20),
                _infoTile(Icons.public, 'Origin', char.origin.name),
                const Divider(color: AppTheme.borderSubtle, height: 20),
                _infoTile(Icons.location_on_outlined, 'Location', char.location.name),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Favorite
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.white : AppTheme.spaceDark,
              ),
              label: Text(
                _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isFavorite ? Colors.white : AppTheme.spaceDark,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFavorite ? AppTheme.deadColor : AppTheme.portalGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppTheme.portalBlue),
        const SizedBox(width: 14),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
