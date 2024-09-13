import 'package:iptv/models/channel_info.dart';
import 'package:iptv/models/stream_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/video_repository.dart';

part 'video_providers.g.dart';

@riverpod
class VideoChannelsNotifier extends _$VideoChannelsNotifier {
  @override
  FutureOr<List<ChannelInfo>> build() async {
    return _fetchChannels();
  }

  Future<List<ChannelInfo>> _fetchChannels() async {
    final repository = ref.read(videoRepositoryProvider);
    return await repository.fetchVideoChannels();
  }

  Future<void> refreshChannels() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchChannels);
  }
}

@riverpod
class VideoStreamsNotifier extends _$VideoStreamsNotifier {
  @override
  FutureOr<List<StreamInfo>> build() async {
    return _fetchVideoStreams();
  }

  Future<List<StreamInfo>> _fetchVideoStreams() async {
    final repository = ref.read(videoRepositoryProvider);
    return await repository.fetchVideoStreams();
  }

  Future<void> refreshVideoStreams() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchVideoStreams);
  }
}

@riverpod
Future<List<StreamInfo>> channelStreams(
  ChannelStreamsRef ref,
  String channelId,
) async {
  final allStreams = await ref.watch(videoStreamsNotifierProvider.future);
  return allStreams.where((stream) => stream.channel == channelId).toList();
}
