import 'package:json_annotation/json_annotation.dart';

part 'id_name_model.g.dart';

@JsonSerializable()
class IdNameModel {
  final int? id;
  final String? name;

  IdNameModel(this.id, this.name);

  factory IdNameModel.fromJson(Map<String, dynamic> json) {
    return _$IdNameModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$IdNameModelToJson(this);
  }
}
