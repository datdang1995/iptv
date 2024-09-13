import 'package:iptv/constants/video_constants.dart';
import 'package:iptv/models/channel_info.dart';
import 'package:iptv/models/stream_info.dart';
import 'package:iptv/services/api_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'video_repository.g.dart';

class VideoRepository {
  final ApiService _apiService;
  final Logger _logger;

  VideoRepository(this._apiService, {Logger? logger})
      : _logger = logger ?? Logger();

  Future<List<ChannelInfo>> fetchVideoChannels() async {
    try {
      final data = await _apiService.get(VideoConstants.videoChannelsEndPoint);
      return (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ChannelInfo.fromJson)
          .toList();
    } on ApiException catch (e) {
      _logger.e('Failed to fetch video channels', error: e);
      throw Exception('Failed to fetch video channels: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error while fetching video channels', error: e);
      throw Exception(
        'An unexpected error occurred while fetching video channels',
      );
    }
  }

  Future<List<StreamInfo>> fetchVideoStreams() async {
    try {
      final data = await _apiService.get(VideoConstants.videoStreamsEndPoint);
      return (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(StreamInfo.fromJson)
          .toList();
    } on ApiException catch (e) {
      _logger.e('Failed to fetch video streams', error: e);
      throw Exception('Failed to fetch video streams: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error while fetching video streams', error: e);
      throw Exception(
        'An unexpected error occurred while fetching video streams',
      );
    }
  }
}

@riverpod
VideoRepository videoRepository(VideoRepositoryRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return VideoRepository(apiService);
}
