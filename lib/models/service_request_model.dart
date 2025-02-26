class ServiceRequest {
  final int id;
  final String userId;
  final int commodityId;
  final double weight;
  final double amount;
  final String status;
  final double price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceRequest({
    required this.id,
    required this.userId,
    required this.commodityId,
    required this.weight,
    required this.amount,
    required this.status,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      userId: json['user_id'],
      commodityId: json['commodity_id'],
      weight: json['weight'].toDouble(),
      amount: json['amount'].toDouble(),
      status: json['status'],
      price: json['price'].toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'commodity_id': commodityId,
      'weight': weight,
      'amount': amount,
      'status': status,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
