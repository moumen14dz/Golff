import 'package:flutter/foundation.dart';
import 'package:golf/models/price_image.dart';

class PriceImages with ChangeNotifier {
  List<PriceImage> _priceImages = [
    PriceImage(
      url:
          'https://c8.alamy.com/comp/W94E3T/vector-abstract-backgrounds-of-a4-size-the-texture-brush-strokes-in-trendy-colors-mustard-blue-purple-coral-template-for-poster-card-brochure-W94E3T.jpg',
      title: 'عنوان الاول',
    ),
    PriceImage(
      url:
          'https://i.pinimg.com/originals/ca/76/0b/ca760b70976b52578da88e06973af542.jpg',
      title: 'عنوان الثانى',
    ),
    PriceImage(
      url: 'https://data.whicdn.com/images/351167498/original.jpg?t=1607177171',
      title: 'عنوان الثالث',
    ),
    PriceImage(
      url:
          'https://c8.alamy.com/comp/W94E3T/vector-abstract-backgrounds-of-a4-size-the-texture-brush-strokes-in-trendy-colors-mustard-blue-purple-coral-template-for-poster-card-brochure-W94E3T.jpg',
      title: 'عنوان الرابع',
    ),
    PriceImage(
      url:
          'https://c8.alamy.com/comp/W94E3T/vector-abstract-backgrounds-of-a4-size-the-texture-brush-strokes-in-trendy-colors-mustard-blue-purple-coral-template-for-poster-card-brochure-W94E3T.jpg',
      title: 'عنوان الخامس',
    ),
    PriceImage(
      url:
          'https://c8.alamy.com/comp/W94E3T/vector-abstract-backgrounds-of-a4-size-the-texture-brush-strokes-in-trendy-colors-mustard-blue-purple-coral-template-for-poster-card-brochure-W94E3T.jpg',
      title: 'عنوان الاول',
    ),
    PriceImage(
      url:
          'https://i.pinimg.com/originals/ca/76/0b/ca760b70976b52578da88e06973af542.jpg',
      title: 'عنوان الثانى',
    ),
    PriceImage(
      url: 'https://data.whicdn.com/images/351167498/original.jpg?t=1607177171',
      title: 'عنوان الثالث',
    ),
    PriceImage(
      url:
          'https://c8.alamy.com/comp/W94E3T/vector-abstract-backgrounds-of-a4-size-the-texture-brush-strokes-in-trendy-colors-mustard-blue-purple-coral-template-for-poster-card-brochure-W94E3T.jpg',
      title: 'عنوان الرابع',
    ),
    PriceImage(
      url:
          'https://c8.alamy.com/comp/W94E3T/vector-abstract-backgrounds-of-a4-size-the-texture-brush-strokes-in-trendy-colors-mustard-blue-purple-coral-template-for-poster-card-brochure-W94E3T.jpg',
      title: 'عنوان الخامس',
    ),
  ];

  List<PriceImage> get priceImages {
    return [..._priceImages];
  }
}
