import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/commodity_model.dart';

class AddOrderModal extends StatefulWidget {
  final List<Commodity> commodities;

  const AddOrderModal({super.key, required this.commodities});

  @override
  _AddOrderModalState createState() => _AddOrderModalState();
}

class _AddOrderModalState extends State<AddOrderModal> {
  final TextEditingController weightController = TextEditingController();
  Commodity? selectedCommodity;

  @override
  void initState() {
    super.initState();
    if (widget.commodities.isNotEmpty) {
      selectedCommodity = widget.commodities[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Waste Item",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Commodity Dropdown
            DropdownButtonFormField<Commodity>(
              value: selectedCommodity,
              decoration: InputDecoration(
                labelText: "Waste Classification",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: widget.commodities.map((commodity) {
                return DropdownMenuItem(
                  value: commodity,
                  child: Text(commodity.name), // Display name but store ID
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCommodity = value;
                });
              },
            ),
            const SizedBox(height: 10),

            // Weight Input
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
              ],
              decoration: InputDecoration(
                labelText: "Weight (Kg)",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // Add Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              ),
              onPressed: () {
                if (weightController.text.isEmpty || selectedCommodity == null)
                  return;
                Navigator.pop(context, {
                  "commodity_id":
                      selectedCommodity!.id.toString(), // Store only ID
                  "commodity_name":
                      selectedCommodity!.name, // Display name in UI
                  "weight": weightController.text,
                });
              },
              child: const Text("Add",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
