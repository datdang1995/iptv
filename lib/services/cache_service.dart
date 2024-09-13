// lib/services/cache_service.dart

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cache_service.g.dart';

class CachedItem<T> {
  final T data;
  final DateTime timestamp;

  CachedItem(this.data, this.timestamp);

  Map<String, dynamic> toJson() => {
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CachedItem.fromJson(Map<String, dynamic> json) {
    return CachedItem(
      json['data'],
      DateTime.parse(json['timestamp']),
    );
  }
}

class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  Future<void> setWithExpiration(
      String key, dynamic value, Duration expiration) async {
    final item = CachedItem(value, DateTime.now().add(expiration));
    await _prefs.setString(key, json.encode(item.toJson()));
  }

  T? getWithExpiration<T>(String key) {
    final string = _prefs.getString(key);
    if (string != null) {
      final item = CachedItem<T>.fromJson(json.decode(string));
      if (DateTime.now().isBefore(item.timestamp)) {
        return item.data;
      } else {
        // Cache expired, remove it
        _prefs.remove(key);
      }
    }
    return null;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}

@riverpod
Future<CacheService> cacheService(CacheServiceRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return CacheService(prefs);
}
