import 'package:golf/models/price_image.dart';

class PriceItem {
  final String title;
  final String date;
  final List<PriceImage> priceImages;

  PriceItem({
    this.title,
    this.date,
    this.priceImages,
  });
}
