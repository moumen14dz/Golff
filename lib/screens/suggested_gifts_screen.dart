import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/providers/plumbers.dart';
import 'package:golf/screens/send_plumber_gift.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';

class SuggestedGiftsScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/suggestedGiftsScreen';

  @override
  _SuggestedGiftsScreenState createState() => _SuggestedGiftsScreenState();
}

class _SuggestedGiftsScreenState extends State<SuggestedGiftsScreen> {
  @override
  Widget build(BuildContext context) {
    final int plumberId = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('الهدايا المقترحة'),
        backgroundColor: mainColor,
      ),
      body: FutureBuilder(
        future:
            Provider.of<Plumbers>(context, listen: false).getGifts(plumberId),
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: SpinKitDoubleBounce(
                  color: Colors.white,
                  size: 50.0,
                ),
              )
            : !Provider.of<Plumbers>(context, listen: false).hasGifts()
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.yellowAccent,
                        ),
                        Text('لم يتم العثور على شئ.'),
                      ],
                    ),
                  )
                : Consumer<Plumbers>(
                    builder: (context, plumbersData, ch) => ListView.builder(
                      itemCount: plumbersData.plumberGifts.length,
                      itemBuilder: (context, i) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(plumbersData.plumberGifts[i].giftName),
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: mainColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: FittedBox(
                                          child: Text(
                                            plumbersData
                                                .plumberGifts[i].giftPoints,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                OutlineButton(
                                  child: Text('إرسال'),
                                  textColor: mainColor,
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed(
                                        SendPlumberGift.ROUTE_NAME,
                                        arguments: {
                                          'giftId':
                                              plumbersData.plumberGifts[i].id,
                                          'plumberId': plumberId,
                                          'giftName': plumbersData
                                              .plumberGifts[i].giftName,
                                        });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
