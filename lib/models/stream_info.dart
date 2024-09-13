import 'package:freezed_annotation/freezed_annotation.dart';

part 'stream_info.freezed.dart';
part 'stream_info.g.dart';

@freezed
class StreamInfo with _$StreamInfo {
  const factory StreamInfo({
    String? channel,
    String? url,
    String? timeshift,
    String? httpReferrer,
    String? userAgent,
  }) = _StreamInfo;
  factory StreamInfo.fromJson(Map<String, dynamic> json) =>
      _$StreamInfoFromJson(json);
}
