import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_history_controllers.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderHistoryController orderHistoryController = Get.find<OrderHistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Obx(() {
        if (orderHistoryController.isLoading.value ||
            orderHistoryController.selectedOrder.value == null) {
          return Center(child: CircularProgressIndicator());
        }

        final order = orderHistoryController.selectedOrder.value!;
        final commodities = orderHistoryController.commodities;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order ID: ${order.id}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Status: ${order.status}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Text(
                          "Created At: ${order.createdAt?.toLocal()}",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Commodities",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (commodities.isEmpty)
                  Center(
                    child: Text(
                      "No commodities found",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: commodities.length,
                    itemBuilder: (context, index) {
                      final item = commodities[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child:
                                Icon(Icons.shopping_bag, color: Colors.white),
                          ),
                          title: Text(
                            "Commodity ID: ${item.commodityId}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Quantity: ${item.quantity}, Weight: ${item.weight ?? "N/A"}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
