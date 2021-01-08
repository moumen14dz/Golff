import 'package:flutter/foundation.dart';

class Offer {
  final int type;
  final String body;
  final String startDate;
  final String endDate;

  Offer({
    @required this.type,
    @required this.body,
    @required this.startDate,
    @required this.endDate,
  });
}
