import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../controllers/commodity_controllers.dart';
import '../../models/commodity_model.dart';
import './components/add_item_modal.dart';
import './components/waste_item_card.dart';
import '../map/map_screen.dart'; // Import Map Screen

class AddOrderScreen extends StatefulWidget {
  static String routeName = "/add_order";

  const AddOrderScreen({super.key});

  @override
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  List<Map<String, String>> wasteItems = [];
  List<Commodity> commodities = [];
  final CommodityController _commodityController = CommodityController();

  @override
  void initState() {
    super.initState();
    _fetchCommodities();
    _loadWasteItems();
  }

  Future<void> _fetchCommodities() async {
    try {
      List<Commodity> data = await _commodityController.fetchCommodities();
      setState(() {
        commodities = data;
      });
    } catch (error) {
      print("Error fetching commodities: $error");
    }
  }

  Future<void> _loadWasteItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("waste_items");
    if (data != null) {
      setState(() {
        wasteItems = List<Map<String, String>>.from(json.decode(data));
      });
    }
  }

  Future<void> _saveWasteItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("waste_items", json.encode(wasteItems));
  }

  void _removeItem(int index) {
    setState(() {
      wasteItems.removeAt(index);
    });
    _saveWasteItems();
  }

  void _showAddItemModal() async {
    if (commodities.isEmpty) return;

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddOrderModal(commodities: commodities),
    );

    if (result != null) {
      setState(() {
        wasteItems.add({
          "commodity_id": result["commodity_id"],
          "commodity_name": result["commodity_name"],
          "weight": result["weight"],
        });
      });
      _saveWasteItems();
    }
  }

  void _confirmOrder() {
    print("Confirming Order: $wasteItems");
    Navigator.pushNamed(
      context,
      MapScreen.routeName,
      arguments: wasteItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Waste Items")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: wasteItems.isEmpty
                    ? const Center(child: Text("No items added yet"))
                    : ListView.builder(
                        itemCount: wasteItems.length,
                        itemBuilder: (context, index) {
                          final item = wasteItems[index];
                          return WasteItemCard(
                            classification: item["commodity_name"]!,
                            weight: item["weight"]!,
                            onRemove: () => _removeItem(index),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _showAddItemModal,
              child: const Icon(Icons.add, size: 30),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: wasteItems.isEmpty ? null : _confirmOrder,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              child:
                  const Text("Confirm Order", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
