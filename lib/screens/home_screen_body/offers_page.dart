import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/providers/offers.dart';
import 'package:provider/provider.dart';

class OffersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Offers>(context, listen: false).getOffers(),
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? Center(
              child: SpinKitDoubleBounce(
                color: Colors.white,
                size: 50.0,
              ),
            )
          : Consumer<Offers>(
              builder: (context, offersData, ch) => ListView.builder(
                itemCount: offersData.offers.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Card(
                      elevation: 12,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  offersData.offers[i].type == 1
                                      ? 'عرض'
                                      : 'مسابقة',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  offersData.offers[i].type == 1
                                      ? Icons.local_offer
                                      : Icons.emoji_events,
                                  color: offersData.offers[i].type == 1
                                      ? Colors.red
                                      : Colors.yellow[800],
                                  size: 40,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            offersData.offers[i].body,
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('من: ${offersData.offers[i].startDate}'),
                                Text('إلى: ${offersData.offers[i].endDate}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
