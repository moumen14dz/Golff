import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/global_widgets/keep_alive_page.dart';
import 'package:golf/models/product.dart';
import 'package:golf/providers/auth.dart';
import 'package:golf/providers/products.dart';
import 'package:golf/screens/bill_print_preview.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';

class NewBillCategoriesScreen extends StatefulWidget {
  static const ROUTE_NAME = '/newBillCategoriesScreen';

  @override
  _NewBillCategoriesScreenState createState() =>
      _NewBillCategoriesScreenState();
}

class _NewBillCategoriesScreenState extends State<NewBillCategoriesScreen> {
  bool _isCategoriesLoading = false;
  List<Category> _categories = [];

  final _pageViewController = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();
    getProductsData();
  }

  Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        // Mobile data detected & internet connection confirmed.
        return true;
      } else {
        // Mobile data detected but no internet connection found.
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a WIFI network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        // Wifi detected & internet connection confirmed.
        return true;
      } else {
        // Wifi detected but no internet connection found.
        return false;
      }
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      return false;
    }
  }

  void _showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('تحذير'),
            content: Text('هل أنت متأكد من حفظ الفاتورة؟'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('حفظ'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('إلغاء'),
              ),
            ],
          );
        });
  }

  Future<void> getProductsData() async {
    setState(() {
      _isCategoriesLoading = true;
    });
    final productsData = Provider.of<Products>(context, listen: false);
    await productsData.getCategories(false);
    _categories = productsData.categories;
    setState(() {
      _isCategoriesLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesData = Provider.of<Products>(context, listen: false);
    print('cat: ' + _categories.toString());
    final Map<String, dynamic> _screen1Data =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('إختيار المنتجات'),
        backgroundColor: mainColor,
      ),
      body: _isCategoriesLoading
          ? Center(
              child: SpinKitDoubleBounce(
                color: Colors.white,
                size: 50.0,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageViewController,
                    onPageChanged: (_) {},
                    children: _categories
                        .map((cat) => KeepAlivePage(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        cat.name,
                                        style: kMainTitleStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: cat.products.length,
                                        itemBuilder: (context, i) {
                                          return Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      cat.products[i].name,
                                                      style:
                                                          kTableRowColumnTitleStyle,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: TextFormField(
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: 'العدد',
                                                        ),
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .center,
                                                        textAlign:
                                                            TextAlign.center,
                                                        onChanged: (text) {
                                                          if (int.tryParse(
                                                                  text) !=
                                                              null) {
                                                            cat.products[i]
                                                                    .amount =
                                                                int.tryParse(
                                                                    text);
                                                          } else if (text
                                                              .isEmpty) {
                                                            cat.products[i]
                                                                .amount = 0;
                                                          }
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                RaisedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'معاينة الفاتورة',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  elevation: 0,
                  color: mainColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    _categories.forEach((cat) {
                      cat.products.forEach((product) {
                        print(product.amount);
                      });
                    });
                    Navigator.of(context).pushNamed(
                      BillPrintPreview.ROUTE_NAME,
                      arguments: _screen1Data,
                    );
                    categoriesData.addCoupons(_categories);
                  },
                ),
              ],
            ),
    );
  }
}
