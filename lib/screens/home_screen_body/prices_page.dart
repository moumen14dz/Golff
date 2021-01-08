import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/models/price_item.dart';
import 'package:golf/providers/price_items.dart';
import 'package:golf/screens/price_images_screen.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';

class PricesPage extends StatefulWidget {
  @override
  _PricesPageState createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  TextEditingController _searchController = TextEditingController();
  List<PriceItem> _priceItems = [];
  List<PriceItem> _filteredPriceItems = [];

  void onSearchTextChanged(String searchText) {
    _filteredPriceItems.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _priceItems.forEach((item) {
      if (item.title.contains(searchText.trim())) {
        _filteredPriceItems.add(item);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'بحث',
              suffixIcon: _searchController.text.isEmpty
                  ? Icon(Icons.search)
                  : IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _filteredPriceItems.clear();
                          _searchController.text = '';
                        });
                      },
                    ),
            ),
            onChanged: onSearchTextChanged,
            controller: _searchController,
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future:
                Provider.of<PriceItems>(context, listen: false).getPriceItems(),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  )
                : Consumer<PriceItems>(
                    builder: (context, priceItemsData, ch) {
                      _priceItems = priceItemsData.priceItems;
                      if (_filteredPriceItems.isEmpty) {
                        if (_searchController.text.isNotEmpty) {
                          return Center(
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
                          );
                        } else {
                          return ListView.builder(
                            itemCount: priceItemsData.priceItems.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Card(
                                  elevation: 8,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              priceItemsData
                                                  .priceItems[i].title,
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            Text(
                                              priceItemsData.priceItems[i].date,
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                        RaisedButton(
                                          child: Text(
                                            'عرض',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          color: mainColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                              PriceImagesScreen.ROUTE_NAME,
                                              arguments: priceItemsData
                                                  .priceItems[i].priceImages,
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      } else {
                        return ListView.builder(
                          itemCount: _filteredPriceItems.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Card(
                                elevation: 8,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            _filteredPriceItems[i].title,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            _filteredPriceItems[i].date,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      ),
                                      RaisedButton(
                                        child: Text(
                                          'عرض',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        color: mainColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                            PriceImagesScreen.ROUTE_NAME,
                                            arguments: _filteredPriceItems[i]
                                                .priceImages,
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
