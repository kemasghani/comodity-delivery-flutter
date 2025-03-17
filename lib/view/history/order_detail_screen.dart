import 'package:flutter/material.dart';
import '../../services/order_history_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderHistoryService _orderHistoryService = OrderHistoryService();
  List<Map<String, dynamic>> commodities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  /// Fetch order details
  Future<void> _loadOrderDetails() async {
    final fetchedCommodities =
        await _orderHistoryService.fetchOrderDetails(widget.orderId);

    setState(() {
      commodities = fetchedCommodities;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : commodities.isEmpty
              ? Center(child: Text('No commodities found'))
              : ListView.builder(
                  itemCount: commodities.length,
                  itemBuilder: (context, index) {
                    final commodity = commodities[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title:
                            Text('Commodity: ${commodity['commodity_name']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: ${commodity['quantity']}'),
                            Text('Weight: ${commodity['weight']} kg'),
                            Text('Created at: ${commodity['created_at']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
