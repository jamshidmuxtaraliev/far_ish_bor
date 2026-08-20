import 'package:flutter/material.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../../auth/data/models/resume_model.dart';
import '../../../../core/theme/jb_palette.dart';

/// Profil ekranidagi "Rezyume (PDF)" bloki.
///
/// PDF **serverda** yasaladi — bu yerda faqat `/mobile/anketa/resume` javobidagi
/// `ready` + `reason` bo'yicha tugma holati chiziladi.
class ResumeCard extends StatelessWidget {
  final ResumeInfoModel? resume;

  /// Holat so'rovi ketmoqda (birinchi tekshiruv).
  final bool loading;
  final bool downloading;
  final double progress;

  /// Oxirgi saqlangan fayl — internetsiz ham ochib beriladi.
  final String? savedFilePath;

  /// Anketa hali umuman to'ldirilmaganmi (rezyume holatini olib bo'lmadi).
  final bool anketaMissing;

  final VoidCallback onDownload;
  final VoidCallback onUploadPhoto;
  final VoidCallback onRetry;
  final VoidCallback onFillAnketa;
  final VoidCallback onOpenSaved;
  final VoidCallback onShareSaved;

  const ResumeCard({
    super.key,
    required this.resume,
    required this.loading,
    required this.downloading,
    required this.progress,
    required this.savedFilePath,
    required this.anketaMissing,
    required this.onDownload,
    required this.onUploadPhoto,
    required this.onRetry,
    required this.onFillAnketa,
    required this.onOpenSaved,
    required this.onShareSaved,
  });

  @override
  Widget build(BuildContext context) {
    return JBCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              JBIconTile(
                icon: Icons.picture_as_pdf_outlined,
                bg: context.jb.redBg,
                fg: context.jb.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rezyume (PDF)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.jb.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(),
                      style: TextStyle(fontSize: 12.5, color: context.jb.gray, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildAction(),
          if (savedFilePath != null && !downloading) ...[
            const SizedBox(height: 12),
            _buildSavedRow(),
          ],
        ],
      ),
    );
  }

  String _subtitle() {
    if (downloading) {
      return progress > 0
          ? 'Yuklanmoqda — ${(progress * 100).round()}%'
          : 'Yuklanmoqda…';
    }
    if (anketaMissing) return "Avval anketani to'ldiring";
    if (loading && resume == null) return 'Tekshirilmoqda…';
    final info = resume;
    if (info == null) return "Holatni olib bo'lmadi";
    if (info.ready) {
      final size = info.size;
      return size != null
          ? 'Tayyor · ${_formatSize(size)}'
          : 'Rezyumengiz tayyor';
    }
    if (info.isNotApproved) return "Operator tasdig'ini kutmoqda";
    if (info.isPhotoRequired) return 'Rezyume uchun rasm kerak';
    return info.message ?? 'Hozircha mavjud emas';
  }

  Widget _buildAction() {
    if (downloading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              minHeight: 6,
              backgroundColor: jb.chipBg,
              valueColor: AlwaysStoppedAnimation(jb.blue),
            ),
          ),
          const SizedBox(height: 12),
          const JBPillButton(
            label: 'Yuklanmoqda…',
            variant: JBBtnVariant.disabled,
            expand: true,
          ),
        ],
      );
    }

    if (anketaMissing) {
      return JBPillButton(
        label: "Anketani to'ldirish",
        leadingIcon: Icons.edit_outlined,
        expand: true,
        onTap: onFillAnketa,
      );
    }

    if (loading && resume == null) {
      return const JBPillButton(
        label: 'Tekshirilmoqda…',
        variant: JBBtnVariant.disabled,
        expand: true,
      );
    }

    final info = resume;
    if (info == null) {
      return JBPillButton(
        label: 'Qayta urinish',
        leadingIcon: Icons.refresh,
        variant: JBBtnVariant.outline,
        expand: true,
        onTap: onRetry,
      );
    }

    if (info.ready) {
      return JBPillButton(
        label: 'PDF yuklab olish',
        leadingIcon: Icons.download_outlined,
        expand: true,
        elevated: true,
        onTap: onDownload,
      );
    }

    if (info.isPhotoRequired) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNote(
            icon: Icons.add_a_photo_outlined,
            text: info.message ?? 'Rezyume uchun avval suratingizni yuklang',
            bg: jb.amberBg,
            fg: jb.amber,
          ),
          const SizedBox(height: 12),
          JBPillButton(
            label: 'Rasm yuklash',
            leadingIcon: Icons.camera_alt_outlined,
            expand: true,
            onTap: onUploadPhoto,
          ),
        ],
      );
    }

    // not_approved yoki boshqa noma'lum sabab — tugma yopiq.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNote(
          icon: Icons.lock_outline,
          text: info.message ??
              'Rezyume anketa tasdiqlangandan keyin yuklab olinadi',
          bg: jb.chipBg,
          fg: jb.gray,
        ),
        const SizedBox(height: 12),
        const JBPillButton(
          label: 'PDF — tasdiqdan keyin',
          leadingIcon: Icons.lock_outline,
          variant: JBBtnVariant.disabled,
          expand: true,
        ),
      ],
    );
  }

  Widget _buildNote({
    required IconData icon,
    required String text,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: fg, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedRow() {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: 15, color: jb.green),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Oxirgi yuklangan rezyume',
            style: TextStyle(fontSize: 12, color: jb.gray),
          ),
        ),
        _SavedAction(icon: Icons.open_in_new, label: 'Ochish', onTap: onOpenSaved),
        const SizedBox(width: 4),
        _SavedAction(icon: Icons.ios_share, label: 'Ulashish', onTap: onShareSaved),
      ],
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _SavedAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SavedAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: context.jb.blue),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: context.jb.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
