// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audioSourceConfiguration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioSourceConfiguration _$AudioSourceConfigurationFromJson(
    Map<String, dynamic> json) {
  return AudioSourceConfiguration(
    json['Name'],
    json['UseCount'],
    json['SourceToken'],
  );
}

Map<String, dynamic> _$AudioSourceConfigurationToJson(
        AudioSourceConfiguration instance) =>
    <String, dynamic>{
      'Name': instance.xmlName,
      'UseCount': instance.xmlUseCount,
      'SourceToken': instance.sourceToken,
    };
