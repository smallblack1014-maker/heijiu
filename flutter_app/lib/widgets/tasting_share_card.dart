import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/tasting.dart';
import '../models/tasting_appearance.dart';
import '../models/tasting_aroma.dart';
import '../models/tasting_palate.dart';
import '../models/tasting_overall.dart';
import '../models/wine.dart';
import '../theme/app_theme.dart';
import '../utils/wine_type_helper.dart';

/// A shareable tasting card widget rendered as an image.
class TastingShareCard extends StatelessWidget {
  final Wine wine;
  final Tasting tasting;
  final TastingAppearance? appearance;
  final TastingAroma? aroma;
  final TastingPalate? palate;
  final TastingOverall? overall;
  final List<String> flavors;
  final GlobalKey repaintKey;

  const TastingShareCard({
    super.key,
    required this.wine,
    required this.tasting,
    this.appearance,
    this.aroma,
    this.palate,
    this.overall,
    this.flavors = const [],
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.wineRed,
              AppTheme.wineRedDark,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const Icon(Icons.wine_bar, color: Colors.white70, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    wine.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (wine.vintage != null)
                    Text(
                      '${wine.vintage}年',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  if (wine.winery != null)
                    Text(
                      wine.winery!,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Score
            if (tasting.score100 != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      '${tasting.score100}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '/ 100',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            // Dimension bars — only scoring dimensions (no acidity/tannin)
            if (aroma != null) ...[
              _buildScoreBar('香气', (
                aroma!.intensity + aroma!.complexity + aroma!.purity
              ) / 3),
              const SizedBox(height: 6),
            ],
            if (palate != null) ...[
              // Palate score: only body, balance, complexity, finishLength
              // (acidity and tannin are descriptive-only, not scoring)
              _buildScoreBar('口感', (
                palate!.body + palate!.balance + palate!.complexity + palate!.finishLength
              ) / 4),
              const SizedBox(height: 6),
            ],
            if (overall != null) ...[
              _buildScoreBar('综合', (
                overall!.typicality + overall!.enjoyment + overall!.value +
                overall!.agingPotential + overall!.repurchase
              ) / 5),
              const SizedBox(height: 6),
            ],
            // Flavors
            if (flavors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '风味: ${flavors.take(5).join(" · ")}${flavors.length > 5 ? "..." : ""}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
            // Wine info
            const SizedBox(height: 16),
            if (wine.country != null || wine.region != null || wine.variety != null)
              Text(
                [
                  if (wine.country != null) wine.country,
                  if (wine.region != null) wine.region,
                  if (wine.variety != null) wine.variety,
                ].join(' · '),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  WineTypeHelper.getLabel(wine.wineType),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                if (tasting.drinkingDate != null)
                  Text(
                    '${tasting.drinkingDate!.year}-${tasting.drinkingDate!.month.toString().padLeft(2, '0')}-${tasting.drinkingDate!.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, double score) {
    final normalized = (score / 10.0).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text(
              (score * 10).round().toString(),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: normalized,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.wineGold),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// Utility class for capturing and sharing the tasting card as an image.
class TastingShareHelper {
  /// Capture the share card as a PNG byte array.
  static Future<Uint8List?> captureCard(GlobalKey repaintKey) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Save the captured image to a temp file path (for share_plus).
  /// Returns the file path or null on failure.
  static Future<String?> saveToTemp(Uint8List bytes) async {
    // Create a data URL for web or save via path_provider on mobile
    // This is a simplified version that relies on share_plus XFile.fromData
    return null;
  }
}
