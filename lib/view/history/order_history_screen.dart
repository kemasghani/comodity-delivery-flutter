import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/user_session.dart';
import '../../controllers/order_history_controllers.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderHistoryController orderHistoryController =
      Get.put(OrderHistoryController());
  String? userId; // Store user ID

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchOrders();
  }

  /// Fetch userId from session and load order history
  Future<void> _loadUserAndFetchOrders() async {
    String? storedUserId = await UserSession().getUserId();

    if (storedUserId != null) {
      print("✅ User ID Found: $storedUserId"); // Debugging print
      setState(() {
        userId = storedUserId;
      });
      orderHistoryController.loadOrderHistory(storedUserId);
    } else {
      print("❌ User ID not found in session");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order History",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Obx(() {
        if (orderHistoryController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (orderHistoryController.orders.isEmpty) {
          return Center(
            child: Text("No orders found",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          );
        }

        return ListView.builder(
          itemCount: orderHistoryController.orders.length,
          itemBuilder: (context, index) {
            final order = orderHistoryController.orders[index];

            return GestureDetector(
              onTap: () {
                Get.to(() => OrderDetailScreen(orderId: order.id));
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  title: Text("Order #${order.id}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Status: ${order.status}",
                      style: TextStyle(color: Colors.grey[600])),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                      SizedBox(height: 5),
                      Text(
                        order.createdAt != null
                            ? "${order.createdAt!.toLocal()}"
                            : "N/A",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
