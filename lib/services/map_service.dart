import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:path_provider/path_provider.dart';

class MapService {
  static CacheStore? _cacheStore;

  static Future<CacheStore> getCacheStore() async {
    if (_cacheStore != null) return _cacheStore!;

    final cacheDirectory = await getTemporaryDirectory();
    _cacheStore = FileCacheStore('${cacheDirectory.path}/map_tiles');

    return _cacheStore!;
  }
}
