import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/video_constants.dart';
import '../models/channel_info.dart';
import '../models/stream_info.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

part 'video_repository.g.dart';

class VideoRepository {
  final ApiService _apiService;
  final CacheService _cacheService;
  final Logger _logger;

  VideoRepository(this._apiService, this._cacheService, {Logger? logger})
      : _logger = logger ?? Logger();

  static const channelCacheKey = 'video_channels';
  static const channelCacheExpiration = Duration(hours: 1);

  Future<List<ChannelInfo>> fetchVideoChannels() async {
    try {
      // Try to get data from cache first
      final cachedData =
          _cacheService.getWithExpiration<String>(channelCacheKey);
      if (cachedData != null) {
        _logger.i('Returning cached video channels');
        return (json.decode(cachedData) as List)
            .cast<Map<String, dynamic>>()
            .map(ChannelInfo.fromJson)
            .toList();
      }

      // If not in cache, fetch from API
      final data = await _apiService.get(VideoConstants.videoStreamsEndPoint);
      final channels = (data as List)
          .cast<Map<String, dynamic>>()
          .map(ChannelInfo.fromJson)
          .toList();

      // Cache the fetched data
      await _cacheService.setWithExpiration(
        channelCacheKey,
        json.encode(data),
        channelCacheExpiration,
      );

      return channels;
    } on ApiException catch (e) {
      _logger.e('Failed to fetch video channels', error: e);
      throw Exception('Failed to fetch video channels: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error while fetching video channels', error: e);
      throw Exception(
          'An unexpected error occurred while fetching video channels');
    }
  }

  Future<List<StreamInfo>> fetchVideoStreams() async {
    try {
      // For video streams, we don't cache as they might change frequently
      final data = await _apiService.get(VideoConstants.videoStreamsEndPoint);
      return (data as List)
          .cast<Map<String, dynamic>>()
          .map(StreamInfo.fromJson)
          .toList();
    } on ApiException catch (e) {
      _logger.e('Failed to fetch video streams', error: e);
      throw Exception('Failed to fetch video streams: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error while fetching video streams', error: e);
      throw Exception(
          'An unexpected error occurred while fetching video streams');
    }
  }

  Future<void> refreshChannels() async {
    try {
      final data = await _apiService.get(VideoConstants.videoChannelsEndPoint);
      await _cacheService.setWithExpiration(
        channelCacheKey,
        json.encode(data),
        channelCacheExpiration,
      );
      _logger.i('Refreshed and cached video channels');
    } catch (e) {
      _logger.e('Failed to refresh video channels', error: e);
      throw Exception('Failed to refresh video channels');
    }
  }
}

@riverpod
Future<VideoRepository> videoRepository(VideoRepositoryRef ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final cacheService = await ref.watch(cacheServiceProvider.future);
  return VideoRepository(apiService, cacheService);
}
