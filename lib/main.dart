import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:golf/providers/auth.dart';
import 'package:golf/providers/bills.dart';
import 'package:golf/providers/complaints.dart';
import 'package:golf/providers/cs_managers.dart';
import 'package:golf/providers/customer_services_agents.dart';
import 'package:golf/providers/distributors.dart';
import 'package:golf/providers/gifts.dart';
import 'package:golf/providers/governorates.dart';
import 'package:golf/providers/locations.dart';
import 'package:golf/providers/merchants.dart';
import 'package:golf/providers/offers.dart';
import 'package:golf/providers/orders.dart';
import 'package:golf/providers/plumbers.dart';
import 'package:golf/providers/price_images.dart';
import 'package:golf/providers/price_items.dart';
import 'package:golf/providers/products.dart';
import 'package:golf/providers/reports.dart';
import 'package:golf/providers/sales_agents.dart';
import 'package:golf/providers/sales_managers.dart';
import 'package:golf/providers/visits.dart';
import 'package:golf/screens/bill_media_import.dart';
import 'package:golf/screens/bill_print_preview.dart';
import 'package:golf/screens/bill_success_screen.dart';
import 'package:golf/screens/home_screen.dart';
import 'package:golf/screens/home_screen_body/complaints_page.dart';
import 'package:golf/screens/home_screen_body/serials_screen.dart';
import 'package:golf/screens/login_screen.dart';
import 'package:golf/screens/merchant_loc_map.dart';
import 'package:golf/screens/new_bill_categories_screen.dart';
import 'package:golf/screens/new_bill_form_screen.dart';
import 'package:golf/screens/new_complaint_message.dart';
import 'package:golf/screens/new_complaint_screen.dart';
import 'package:golf/screens/new_distibutor_screen.dart';
import 'package:golf/screens/new_gift_screen.dart';
import 'package:golf/screens/new_merchant_screen.dart';
import 'package:golf/screens/new_order_screen.dart';
import 'package:golf/screens/new_plumber_screen.dart';
import 'package:golf/screens/new_report_screen.dart';
import 'package:golf/screens/new_serial_screen.dart';
import 'package:golf/screens/new_visit_screen.dart';
import 'package:golf/screens/plumber_bills_screen.dart';
import 'package:golf/screens/plumber_credits_screen.dart';
import 'package:golf/screens/price_images_screen.dart';
import 'package:golf/screens/send_plumber_gift.dart';
import 'package:golf/screens/splash_screen.dart';
import 'package:golf/screens/suggested_gifts_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/districts.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // if (prefs.getInt('id') != null) {
  //   SharedPreferences.setMockInitialValues({'id': prefs.getInt('id')});
  //   print('prefs = null');
  // }
  // print('main function continued');
  // WidgetsFlutterBinding.ensureInitialized();
  // await SharedPreferences.getInstance();
  // SharedPreferences.setMockInitialValues({});
  runApp(GolfApp());
}

class GolfApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Merchants>(
          update: (context, authData, prevData) => Merchants(authData.id),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Distributors>(
          update: (context, authData, prevData) => Distributors(authData.id),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Reports>(
          update: (context, authData, prevData) => Reports(authData.id),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Gifts>(
          update: (context, authData, prevData) => Gifts(authData.id),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (context, authData, prevData) => Orders(authData.id),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Visits>(
          update: (context, authData, prevData) => Visits(authData.id),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Plumbers>(
          update: (context, authData, prevData) => Plumbers(authData.id),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Locations>(
          update: (context, authData, prevData) => Locations(authData.id),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (context, authData, prevData) => Products(
            userId: authData.id,
          ),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Bills>(
          update: (context, authData, prevData) => Bills(authData.id),
          create: null,
        ),
        ChangeNotifierProxyProvider<Auth, Complaints>(
          update: (context, authData, prevData) => Complaints(authData.id),
          create: null,
        ),
        ChangeNotifierProvider(
          create: (context) => PriceItems(),
        ),
        ChangeNotifierProvider(
          create: (context) => Offers(),
        ),
        ChangeNotifierProvider(
          create: (context) => PriceImages(),
        ),
        ChangeNotifierProvider(
          create: (context) => SalesManagers(),
        ),
        ChangeNotifierProvider(
          create: (context) => CSManagers(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerServicesAgents(),
        ),
        ChangeNotifierProvider(
          create: (context) => SalesAgents(),
        ),
        ChangeNotifierProvider(
          create: (context) => Governorates(),
        ),
        ChangeNotifierProvider(
          create: (context) => Districts(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, authData, ch) => MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            // ... app-specific localization delegate[s] here
            //AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''), // English, no country code
            const Locale('ar', ''), // Arabic, no country code
            // ... other locales the app supports
          ],
          locale: const Locale('ar', ''),
          title: 'Golf App',
          theme: ThemeData.dark(),
          home: authData.isAuth()
              ? HomeScreen()
              : FutureBuilder(
                  future: authData.tryLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : LoginScreen(),
                ),
          routes: {
            LoginScreen.ROUTE_NAME: (context) => LoginScreen(),
            HomeScreen.ROUTE_NAME: (context) => HomeScreen(),
            NewMerchantScreen.ROUTE_NAME: (context) => NewMerchantScreen(),
            NewComplaintScreen.ROUTE_NAME: (context) => NewComplaintScreen(),
            NewGiftScreen.ROUTE_NAME: (context) => NewGiftScreen(),
            NewOrdersScreen.ROUTE_NAME: (context) => NewOrdersScreen(),
            NewVisitScreen.ROUTE_NAME: (context) => NewVisitScreen(),
            NewSerialScreen.ROUTE_NAME: (context) => NewSerialScreen(),
            SerialsScreen.ROUTE_NAME: (context) => SerialsScreen(),
            PriceImagesScreen.ROUTE_NAME: (context) => PriceImagesScreen(),
            NewDistributorScreen.ROUTE_NAME: (context) =>
                NewDistributorScreen(),
            NewReportScreen.ROUTE_NAME: (context) => NewReportScreen(),
            NewBillFormScreen.ROUTE_NAME: (context) => NewBillFormScreen(),
            MerchantLocMap.ROUTE_NAME: (context) => MerchantLocMap(),
            NewBillCategoriesScreen.ROUTE_NAME: (context) =>
                NewBillCategoriesScreen(),
            BillPrintPreview.ROUTE_NAME: (context) => BillPrintPreview(),
            PlumberCreditsScreen.ROUTE_NAME: (context) =>
                PlumberCreditsScreen(),
            PlumberBillsScreen.ROUTE_NAME: (context) => PlumberBillsScreen(),
            SuggestedGiftsScreen.ROUTE_NAME: (context) =>
                SuggestedGiftsScreen(),
            NewPlumberScreen.ROUTE_NAME: (context) => NewPlumberScreen(),
            SendPlumberGift.ROUTE_NAME: (context) => SendPlumberGift(),
            BillMediaImport.ROUTE_NAME: (context) => BillMediaImport(),
            BillSuccessScreen.ROUTE_NAME: (context) => BillSuccessScreen(),
            ComplaintsPage.ROUTE_NAME: (context) => ComplaintsPage(),
            NewComplaintMessageScreen.ROUTE_NAME: (context) =>
                NewComplaintMessageScreen(),
          },
        ),
      ),
    );
  }
}
