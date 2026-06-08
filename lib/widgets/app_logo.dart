import 'package:flutter/material.dart';

import '../core/app_assets.dart';
import '../core/app_branding.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 40,
    this.showTitle = true,
    this.compact = false,
  });

  final double size;
  final bool showTitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        AppAssets.appIcon,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome, size: size, color: Theme.of(context).colorScheme.primary),
      ),
    );

    if (!showTitle) return image;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        image,
        SizedBox(width: compact ? 10 : 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppBranding.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              if (!compact) ...[
                const SizedBox(height: 2),
                Text(
                  AppBranding.tagline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
