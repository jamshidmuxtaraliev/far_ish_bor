import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final bool? forUserImages;

  const CustomCachedNetworkImage({super.key, required this.url, this.height, this.width, this.fit, this.borderRadius, this.forUserImages});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url ?? '';
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cacheWidth = ((width ?? screenWidth) * pixelRatio).toInt().clamp(1, 1920);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        memCacheWidth: cacheWidth,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => Container(color: Colors.grey.shade200),
        errorWidget:
            (context, url, error) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Image.asset(
                  forUserImages == true ? Assets.images.avatar.path : Assets.images.logoText.path,
                  height: height,
                  width: width,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
      ),
    );
  }
}
