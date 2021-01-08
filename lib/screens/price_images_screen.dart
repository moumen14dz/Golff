import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:golf/models/price_image.dart';
import 'package:golf/providers/price_images.dart';
import 'package:golf/screens/full_screen_image_preview.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';

class PriceImagesScreen extends StatefulWidget {
  static const ROUTE_NAME = '/priceImagesScreen';

  @override
  _PriceImagesScreenState createState() => _PriceImagesScreenState();
}

class _PriceImagesScreenState extends State<PriceImagesScreen> {
  @override
  Widget build(BuildContext context) {
    final List<PriceImage> priceImages =
        ModalRoute.of(context).settings.arguments;
    final priceImagesData = Provider.of<PriceImages>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمة الجولف'),
        backgroundColor: mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListView.builder(
            itemCount: priceImages.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Hero(
                        tag: i,
                        child: ClipRRect(
                          child: CachedNetworkImage(
                            imageUrl: priceImages[i].url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            priceImages[i].title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullScreenImagePreview(
                              priceImages[i].url,
                              i,
                            )),
                  );
                },
              );
            }),
      ),
    );
  }
}
//priceImagesData.priceImages[i].url
