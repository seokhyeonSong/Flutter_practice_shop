import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/orders_provider.dart' show OrdersProvider;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/order';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: FutureBuilder(
          future: Provider.of<OrdersProvider>(context, listen: false)
              .fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                // error handling
                return Text(dataSnapshot.error);
              } else {
                return Consumer<OrdersProvider>(
                  builder: (context, orderData, child) => ListView.builder(
                    itemBuilder: (ctx, index) {
                      return OrderItem(orderData.orders[index]);
                    },
                    itemCount: orderData.orders.length,
                  ),
                );
              }
            }
          }),
      drawer: AppDrawer(),
    );
  }
}
