import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImagePreview extends StatefulWidget {
  final String imageUrl;
  final int i;

  const FullScreenImagePreview(this.imageUrl, this.i);

  @override
  _FullScreenImagePreviewState createState() => _FullScreenImagePreviewState();
}

class _FullScreenImagePreviewState extends State<FullScreenImagePreview> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: widget.i,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(),
              ),
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
