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
                Text("Payment slip uploaded successfully",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    "Please wait for confirmation from the admin regarding the uploaded payment slip."),
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
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order Details",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : commodities.isEmpty
                      ? Center(child: Text('No commodities found'))
                      : Column(
                          children: commodities.map((commodity) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Commodity: ${commodity['commodity_name']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Quantity: ${commodity['quantity']}'),
                                  Text('Weight: ${commodity['weight']} kg'),
                                  Text(
                                      'Created at: ${commodity['created_at']}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              Text(
                "Upload Payment Slip",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              _selectedImage != null
                  ? Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _uploadImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isUploading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text("Submit"),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Choose Image"),
                    ),
              SizedBox(height: 20),
              if (_uploadedImageUrl != null) ...[
                Text("Uploaded Image:",
                    style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(_uploadedImageUrl!, height: 150),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
