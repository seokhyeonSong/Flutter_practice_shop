import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders_provider.dart' as oi;

class OrderItem extends StatefulWidget {
  final oi.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  var _expanded = false;
  AnimationController _animationController;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 110, 195) : 95,
      constraints: BoxConstraints(
          minHeight: _expanded
              ? min(widget.order.products.length * 20.0 + 105, 195)
              : 95),
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$ ${widget.order.amount}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    if (_expanded)
                      _animationController.reverse();
                    else
                      _animationController.forward();
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            if (_expanded)
              FadeTransition(
                opacity: _opacityAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  height: min(widget.order.products.length * 20.0 + 10, 100),
                  child: ListView(
                    children: widget.order.products
                        .map((prod) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  prod.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${prod.quantity}x \$${prod.price}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ))
                        .toList(),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
