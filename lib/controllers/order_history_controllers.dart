import 'package:get/get.dart';
import '../services/order_history_service.dart';
import '../models/service_request_model.dart';
import '../models/service_request_commodities_model.dart';

class OrderHistoryController extends GetxController {
  final OrderHistoryService _orderHistoryService = OrderHistoryService();

  var orders = <ServiceRequest>[].obs;
  var selectedOrder = Rxn<ServiceRequest>();
  var commodities = <ServiceRequestCommodityModel>[].obs;
  var isLoading = false.obs;
  var orderDetail = Rxn<ServiceRequest>();
  var orderCommodities = <ServiceRequestCommodityModel>[].obs;

  /// Load order history for a user
  Future<void> loadOrderHistory(String userId) async {
    try {
      isLoading.value = true;
      print('Loading order history for userId: $userId');

      final fetchedOrders =
          await _orderHistoryService.fetchOrderHistory(userId);
      orders.value = fetchedOrders;
    } catch (e, stackTrace) {
      print('Error loading order history: $e');
      print(stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

}
