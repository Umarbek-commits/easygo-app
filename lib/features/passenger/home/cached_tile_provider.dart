import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';

/// Провайдер тайлов с сохранением на телефон.
/// Просмотренные участки карты кешируются на устройство и при повторном
/// открытии грузятся мгновенно (и работают без интернета), без лагов.
class CachedTileProvider extends TileProvider {
  CachedTileProvider({super.headers});

  // Отдельное хранилище тайлов: до 4000 плиток, хранятся 60 дней.
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'easygoMapTiles',
      stalePeriod: const Duration(days: 60),
      maxNrOfCacheObjects: 4000,
    ),
  );

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      cacheManager: _cacheManager,
    );
  }
}
