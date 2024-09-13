import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_info.freezed.dart';
part 'channel_info.g.dart';

@freezed
class ChannelInfo with _$ChannelInfo {
  const factory ChannelInfo({
    String? id,
    String? name,
    List<String>? altNames,
    String? network,
    List<String>? owners,
    String? country,
    String? subdivision,
    String? city,
    List<String>? broadcastArea,
    List<String>? languages,
    List<String>? categories,
    bool? isNsfw,
    DateTime? launched,
    DateTime? closed,
    String? replacedBy,
    String? website,
    String? logo,
  }) = _ChannelInfo;

  factory ChannelInfo.fromJson(Map<String, dynamic> json) =>
      _$ChannelInfoFromJson(json);
}
