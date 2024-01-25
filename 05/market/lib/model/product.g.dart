// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      docId: json['docId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      price: json['price'] as int?,
      stock: json['stock'] as int?,
      saleRate: (json['saleRate'] as num?)?.toDouble(),
      imgUrl: json['imgUrl'] as String?,
      timestamp: json['timestamp'] as int?,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'docId': instance.docId,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'stock': instance.stock,
      'saleRate': instance.saleRate,
      'imgUrl': instance.imgUrl,
      'timestamp': instance.timestamp,
    };

_$CartImpl _$$CartImplFromJson(Map<String, dynamic> json) => _$CartImpl(
      cartDocId: json['cartDocId'] as String?,
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      timestamp: json['timestamp'] as int?,
      count: json['count'] as int?,
      product: json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CartImplToJson(_$CartImpl instance) =>
    <String, dynamic>{
      'cartDocId': instance.cartDocId,
      'uid': instance.uid,
      'email': instance.email,
      'timestamp': instance.timestamp,
      'count': instance.count,
      'product': instance.product,
    };
