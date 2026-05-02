// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapItemModel _$MapItemModelFromJson(Map<String, dynamic> json) => MapItemModel(
  (json['lat'] as num).toDouble(),
  (json['long'] as num).toDouble(),
  json['address'] as String,
);

Map<String, dynamic> _$MapItemModelToJson(MapItemModel instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'long': instance.long,
      'address': instance.address,
    };
