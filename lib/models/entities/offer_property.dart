import 'package:andlet/models/entities/property.dart';
import 'package:hive/hive.dart';
import 'offer.dart';

part 'offer_property.g.dart';

@HiveType(typeId: 2)
class OfferProperty {
  @HiveField(0)
  final Offer offer;

  @HiveField(1)
  final Property property;

  OfferProperty({required this.offer, required this.property});
}
