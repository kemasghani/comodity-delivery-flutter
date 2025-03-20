import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import '../../services/order_history_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderHistoryService _orderHistoryService = OrderHistoryService();
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> commodities = [];
  bool isLoading = true;

  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final fetchedCommodities =
        await _orderHistoryService.fetchOrderDetails(widget.orderId);

    setState(() {
      commodities = fetchedCommodities;
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName =
          "paymentslip_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await supabase.storage
          .from('paymentslips')
          .upload(fileName, _selectedImage!);

      final publicUrl =
          supabase.storage.from('paymentslips').getPublicUrl(fileName);

      await supabase.from('service_requests').update({
        'payment_image': publicUrl,
      }).eq('id', widget.orderId);

      setState(() {
        _uploadedImageUrl = publicUrl;
        _selectedImage = null;
        _isUploading = false;
      });

      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/check_payment.json',
                    width: 150),
                SizedBox(height: 12),
                Text("Sukses upload struk pembayaran",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    "Harap tunggu konfirmasi dari admin dari struk pembayaran yang anda upload"),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Order Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: isLoading
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
                                title: Text(
                                    'Commodity: ${commodity['commodity_name']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Quantity: ${commodity['quantity']}'),
                                    Text('Weight: ${commodity['weight']} kg'),
                                    Text(
                                        'Created at: ${commodity['created_at']}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            SizedBox(height: 20),
            Divider(),
            Text("Upload Payment Slip",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _selectedImage != null
                ? Column(
                    children: [
                      Image.file(_selectedImage!, height: 200),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _uploadImage,
                        child: _isUploading
                            ? CircularProgressIndicator()
                            : Text("Submit"),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Choose Image"),
                  ),
            SizedBox(height: 20),
            if (_uploadedImageUrl != null) ...[
              Text("Uploaded Image:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Image.network(_uploadedImageUrl!, height: 150),
            ],
          ],
        ),
      ),
    );
  }
}
