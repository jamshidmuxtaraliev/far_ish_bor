import 'package:json_annotation/json_annotation.dart';

part 'map_item_model.g.dart';

@JsonSerializable()
class MapItemModel {
  final double lat;
  final double long;
  final String address;

  MapItemModel(this.lat, this.long, this.address);

  factory MapItemModel.fromJson(Map<String, dynamic> json) {
    return _$MapItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$MapItemModelToJson(this);
  }
}
