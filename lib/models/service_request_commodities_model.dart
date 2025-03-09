class ServiceRequestCommodityModel {
  final String id;
  final String serviceRequestId;
  final String commodityId;
  final num quantity;
  final num? weight;
  final DateTime? createdAt;

  ServiceRequestCommodityModel({
    required this.id,
    required this.serviceRequestId,
    required this.commodityId,
    required this.quantity,
    this.weight,
    this.createdAt,
  });

  factory ServiceRequestCommodityModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestCommodityModel(
      id: json['id'],
      serviceRequestId: json['service_request_id'],
      commodityId: json['commodity_id'],
      quantity: json['quantity'],
      weight: json['weight'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_request_id': serviceRequestId,
      'commodity_id': commodityId,
      'quantity': quantity,
      'weight': weight,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
