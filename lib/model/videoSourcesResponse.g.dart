// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videoSourcesResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetVideoSourcesResponse _$GetVideoSourcesResponseFromJson(
    Map<String, dynamic> json) {
  return GetVideoSourcesResponse(
    VideoSources.fromJson(json['VideoSources'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GetVideoSourcesResponseToJson(
        GetVideoSourcesResponse instance) =>
    <String, dynamic>{
      'VideoSources': instance.videoSources.toJson(),
    };
