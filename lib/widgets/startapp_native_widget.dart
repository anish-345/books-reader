import 'dart:io';
import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';
import '../services/startapp_ad_service.dart';

class StartAppNativeWidget extends StatefulWidget {
  final int index; // Unique index for each ad position

  const StartAppNativeWidget({super.key, required this.index});

  @override
  State<StartAppNativeWidget> createState() => _StartAppNativeWidgetState();
}

class _StartAppNativeWidgetState extends State<StartAppNativeWidget> {
  StartAppNativeAd? _nativeAd;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  Future<void> _loadNativeAd() async {
    if (!Platform.isAndroid) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final adService = StartAppAdService();
      if (!adService.isInitialized) {
        await adService.initialize();
      }

      // Load a fresh native ad for this position
      final nativeAd = await adService.loadNativeAd();
      if (mounted) {
        setState(() {
          _nativeAd = nativeAd;
          _isLoading = false;
          _hasError = nativeAd == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    // Don't show loading indicator, just hide if not loaded
    if (_isLoading || _nativeAd == null || _hasError) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: StartAppNative(_nativeAd!, (context, setState, nativeAd) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                'Ad',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ad image
                  if (nativeAd.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        nativeAd.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.image, color: Colors.grey[500]),
                          );
                        },
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Ad content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        if (nativeAd.title != null)
                          Text(
                            nativeAd.title!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        // Description
                        if (nativeAd.description != null)
                          Text(
                            nativeAd.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        // Rating and CTA
                        Row(
                          children: [
                            // Rating
                            if (nativeAd.rating != null && nativeAd.rating! > 0)
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber[700],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    nativeAd.rating!.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            const Spacer(),
                            // Call to action button
                            if (nativeAd.callToAction != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  nativeAd.callToAction!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _nativeAd = null;
    super.dispose();
  }
}
