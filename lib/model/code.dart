import 'package:json_annotation/json_annotation.dart';

part 'code.g.dart';

@JsonSerializable(explicitToJson: true)
class Code {
  @JsonKey(name: 'Value')
  final dynamic xmlValue;

  @JsonKey(name: 'Subcode')
  final Code code;

  String get value => xmlValue['\$'];

  Code(this.xmlValue, this.code);

  factory Code.fromJson(Map<String, dynamic> json) => _$CodeFromJson(json);

  Map<String, dynamic> toJson() => _$CodeToJson(this);
}
