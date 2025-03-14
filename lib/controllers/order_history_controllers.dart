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

  Future<void> loadOrderHistory(String userId) async {
    isLoading.value = true;
    orders.value = await _orderHistoryService.fetchOrderHistory(userId);
    isLoading.value = false;
  }

  Future<void> loadOrderDetails(int orderId) async {
    isLoading.value = true;
    selectedOrder.value = await _orderHistoryService.fetchOrderDetails(orderId);
    commodities.value =
        await _orderHistoryService.fetchOrderCommodities(orderId);
    isLoading.value = false;
  }
}
