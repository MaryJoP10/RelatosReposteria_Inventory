import 'package:flutter/material.dart';

import '../brand/brand_config.dart';
import '../theme/relatos_colors.dart';
import '../theme/relatos_spacing.dart';

enum BrandLogoSize { compact, regular, large }

/// Relatos wordmark plus the brand emblem. The image comes from [BrandConfig].
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.showTagline = false,
    this.size = BrandLogoSize.regular,
  });

  final bool showTagline;
  final BrandLogoSize size;

  @override
  Widget build(BuildContext context) {
    final markSize = switch (size) {
      BrandLogoSize.compact => 36.0,
      BrandLogoSize.regular => 52.0,
      BrandLogoSize.large => 88.0,
    };
    final textTheme = Theme.of(context).textTheme;
    final nameStyle = switch (size) {
      BrandLogoSize.compact => textTheme.titleMedium,
      BrandLogoSize.regular => textTheme.headlineSmall,
      BrandLogoSize.large => textTheme.headlineMedium,
    };

    final emblem = ClipRRect(
      borderRadius: BorderRadius.circular(RelatosRadii.md),
      child: Image.asset(
        BrandConfig.logoAsset,
        width: markSize,
        height: markSize,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: markSize,
          height: markSize,
          color: RelatosColors.primary,
          alignment: Alignment.center,
          child: Text(
            'RR',
            style: TextStyle(
              color: RelatosColors.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: markSize * 0.32,
            ),
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        emblem,
        const SizedBox(width: RelatosSpacing.md),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                BrandConfig.name,
                style: nameStyle?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: RelatosColors.onSurface,
                ),
              ),
              if (showTagline)
                Text(
                  BrandConfig.tagline,
                  style: textTheme.labelMedium?.copyWith(
                    color: RelatosColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
