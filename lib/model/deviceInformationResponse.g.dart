// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deviceInformationResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetDeviceInformationResponse _$GetDeviceInformationResponseFromJson(
    Map<String, dynamic> json) {
  return GetDeviceInformationResponse(
    json['Manufacturer'],
    json['Model'],
    json['FirmwareVersion'],
    json['SerialNumber'],
    json['HardwareId'],
  );
}

Map<String, dynamic> _$GetDeviceInformationResponseToJson(
        GetDeviceInformationResponse instance) =>
    <String, dynamic>{
      'Manufacturer': instance.xmlManufacturer,
      'Model': instance.xmlModel,
      'FirmwareVersion': instance.xmlFirmwareVersion,
      'SerialNumber': instance.xmlSerialNumber,
      'HardwareId': instance.xmlHardwareId,
    };
