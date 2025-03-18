import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Fetch order details
  Future<void> _loadOrderDetails() async {
    final fetchedCommodities =
        await _orderHistoryService.fetchOrderDetails(widget.orderId);

    setState(() {
      commodities = fetchedCommodities;
      isLoading = false;
    });
  }

  /// Pick Image and Show Preview
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Upload Image to Supabase Storage and Update Database
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName =
          "paymentslip_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Upload image to Supabase Storage
      await supabase.storage
          .from('paymentslips')
          .upload(fileName, _selectedImage!);

      // Get the public URL of the uploaded image
      final publicUrl =
          supabase.storage.from('paymentslips').getPublicUrl(fileName);

      // Update the service_requests table with the image URL
      await supabase.from('service_requests').update({
        'payment_image': publicUrl,
      }).eq('id', widget.orderId);

      setState(() {
        _uploadedImageUrl = publicUrl;
        _selectedImage = null; // Reset after successful upload
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload successful! Payment slip updated.")),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }
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

            // Order Details List
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

            // Image Upload Section
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

            // Show uploaded image from Supabase
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
