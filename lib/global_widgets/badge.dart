import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final int quantity;

  Badge({
    @required this.child,
    @required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          top: 0,
          child: CircleAvatar(
            backgroundColor:
                quantity == 0 ? Colors.transparent : Colors.red[700],
            radius: 10,
            child: FittedBox(
              child: Text(
                quantity.toString(),
                style: TextStyle(
                  color: quantity == 0 ? Colors.transparent : Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
