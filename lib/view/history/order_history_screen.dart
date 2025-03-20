import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/user_session.dart';
import '../../controllers/order_history_controllers.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  static String routeName = "/order_history";

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderHistoryController orderHistoryController =
      Get.put(OrderHistoryController());
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchOrders();
  }

  /// Fetch userId from session and load order history
  Future<void> _loadUserAndFetchOrders() async {
    String? storedUserId = await UserSession().getUserId();

    if (storedUserId != null) {
      print("✅ User ID Found: $storedUserId");
      setState(() {
        userId = storedUserId;
      });
      orderHistoryController.loadOrderHistory(storedUserId);
    } else {
      print("❌ User ID not found in session");
    }
  }

  /// Function to get color based on order status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on progress':
        return Colors.orange;
      case 'done':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Function to get payment badge
  Widget _getPaymentStatusBadge(int paid) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: paid == 1
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        paid == 1 ? "Paid" : "Unpaid",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: paid == 1 ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8), // Light background
      appBar: AppBar(
        title: Text(
          "Order History",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFF7642), // Orange color
        elevation: 0,
      ),
      body: Obx(() {
        if (orderHistoryController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (orderHistoryController.orders.isEmpty) {
          return Center(
            child: Text(
              "No orders found",
              style: TextStyle(color: Colors.black54, fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: orderHistoryController.orders.length,
          itemBuilder: (context, index) {
            final order = orderHistoryController.orders[index];

            return GestureDetector(
              onTap: () {
                Get.to(() => OrderDetailScreen(orderId: order.id));
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFFF7642),
                    radius: 24,
                    child: Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  title: Text(
                    "Order #${order.id}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            order.createdAt != null
                                ? "${order.createdAt!.toLocal()}"
                                : "N/A",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(order.status),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          // Payment Badge
                          _getPaymentStatusBadge(order.paid),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
