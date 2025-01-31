import 'package:json_annotation/json_annotation.dart';

import 'videoSourceConfiguration.dart';
import 'audioSourceConfiguration.dart';
import 'videoEncoderConfiguration.dart';
import 'audioEncoderConfiguration.dart';
import 'videoAnalyticsConfiguration.dart';
import 'ptzConfiguration.dart';

part 'profile.g.dart';

///representation of a profile that exist in the media service
@JsonSerializable(explicitToJson: true)
class Profile {
  ///Unique identifier of the profile.
  @JsonKey(name: '@token')
  final String token;

  @JsonKey(name: '@fixed')
  final dynamic xmlFixed;

  @JsonKey(name: 'Name')
  final dynamic xmlName;

  ///Optional configuration of the Video input.
  @JsonKey(name: 'VideoSourceConfiguration')
  final VideoSourceConfiguration videoSourceConfiguration;

  ///Optional configuration of the Audio input.
  @JsonKey(name: 'AudioSourceConfiguration')
  final AudioSourceConfiguration audioSourceConfiguration;

  ///Optional configuration of the Video encoder.
  @JsonKey(name: 'VideoEncoderConfiguration')
  final VideoEncoderConfiguration? videoEncoderConfiguration;

  ///Optional configuration of the Audio encoder.
  @JsonKey(name: 'AudioEncoderConfiguration')
  final AudioEncoderConfiguration audioEncoderConfiguration;

  ///Optional configuration of the video analytics module and rule engine.\
  @JsonKey(name: 'VideoAnalyticsConfiguration')
  final VideoAnalyticsConfiguration videoAnalyticsConfiguration;

  ///Optional configuration of the pan tilt zoom unit.
  @JsonKey(name: 'PTZConfiguration')
  final PTZConfiguration ptzConfiguration;

  ///A value of true signals that the profile cannot be deleted. Default is
  ///false.
  bool get fixed => xmlFixed['\$'].toLowerCase() == 'true';

  ///User readable name of the profile.
  String get name => xmlName['\$'];

  Profile(
      {required this.token,
      this.xmlFixed,
      this.xmlName,
      required this.videoSourceConfiguration,
      required this.audioSourceConfiguration,
      this.videoEncoderConfiguration,
      required this.audioEncoderConfiguration,
      required this.videoAnalyticsConfiguration,
      required this.ptzConfiguration});

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
