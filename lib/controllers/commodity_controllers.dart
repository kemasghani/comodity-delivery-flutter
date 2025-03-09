import '../models/commodity_model.dart';
import '../services/commodity_services.dart';

class CommodityController {
  final CommodityService _commodityService = CommodityService();

  // ✅ Fetch all commodities
  Future<List<Commodity>> fetchCommodities() async {
    return await _commodityService.getCommodities();
  }

  // ✅ Fetch a single commodity by ID
  Future<Commodity?> getCommodityById(int id) async {
    return await _commodityService.getCommodityById(id);
  }

  // ✅ Add a new commodity
  Future<bool> addCommodity(Commodity commodity) async {
    return await _commodityService.addCommodity(commodity);
  }
}
