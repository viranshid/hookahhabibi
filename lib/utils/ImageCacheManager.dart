import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  final Map<String, Uint8List> _memoryCache = {};
  static const int _maxCacheSize = 50; // Maximum number of images to cache in memory

  /// Get cached image widget with loading and error states
  Widget getCachedImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(errorWidget, width, height);
    }

    return FutureBuilder<Uint8List?>(
      future: _getImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder(placeholder, width, height);
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildErrorWidget(errorWidget, width, height);
        }

        Widget image = Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(errorWidget, width, height);
          },
        );

        if (borderRadius != null) {
          image = ClipRRect(
            borderRadius: borderRadius,
            child: image,
          );
        }

        return image;
      },
    );
  }

  /// Get image from cache or download
  Future<Uint8List?> _getImage(String imageUrl) async {
    try {
      final String cacheKey = _generateCacheKey(imageUrl);

      // Check memory cache first
      if (_memoryCache.containsKey(cacheKey)) {
        return _memoryCache[cacheKey];
      }

      // Check disk cache
      final File? cachedFile = await _getCachedFile(cacheKey);
      if (cachedFile != null && await cachedFile.exists()) {
        final Uint8List imageData = await cachedFile.readAsBytes();
        _addToMemoryCache(cacheKey, imageData);
        return imageData;
      }

      // Download image
      final Uint8List? downloadedData = await _downloadImage(imageUrl);
      if (downloadedData != null) {
        _addToMemoryCache(cacheKey, downloadedData);
        _saveToDisk(cacheKey, downloadedData);
        return downloadedData;
      }

      return null;
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }

  /// Download image from URL
  Future<Uint8List?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {'User-Agent': 'Flutter App'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }

  /// Generate cache key from URL
  String _generateCacheKey(String imageUrl) {
    var bytes = utf8.encode(imageUrl);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get cached file path
  Future<File?> _getCachedFile(String cacheKey) async {
    try {
      final Directory cacheDir = await _getCacheDirectory();
      return File('${cacheDir.path}/$cacheKey.jpg');
    } catch (e) {
      debugPrint('Error getting cached file: $e');
      return null;
    }
  }

  /// Get cache directory
  Future<Directory> _getCacheDirectory() async {
    final Directory tempDir = await getTemporaryDirectory();
    final Directory cacheDir = Directory('${tempDir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Save image to disk
  Future<void> _saveToDisk(String cacheKey, Uint8List imageData) async {
    try {
      final File? file = await _getCachedFile(cacheKey);
      if (file != null) {
        await file.writeAsBytes(imageData);
      }
    } catch (e) {
      debugPrint('Error saving image to disk: $e');
    }
  }

  /// Add image to memory cache
  void _addToMemoryCache(String cacheKey, Uint8List imageData) {
    if (_memoryCache.length >= _maxCacheSize) {
      // Remove oldest entry
      final String oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }
    _memoryCache[cacheKey] = imageData;
  }

  /// Build placeholder widget
  Widget _buildPlaceholder(Widget? placeholder, double width, double height) {
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        );
  }

  /// Build error widget
  Widget _buildErrorWidget(Widget? errorWidget, double width, double height) {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.broken_image,
            color: Colors.white,
            size: 30,
          ),
        );
  }

  /// Clear memory cache
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  /// Clear disk cache
  Future<void> clearDiskCache() async {
    try {
      final Directory cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      _memoryCache.clear();
    } catch (e) {
      debugPrint('Error clearing disk cache: $e');
    }
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    try {
      final Directory cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final FileSystemEntity entity in cacheDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0;
    }
  }
}