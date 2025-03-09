class Commodity {
  final int id;
  final String name;
  final String description;
  final double pricePerKg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Commodity({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerKg,
    this.createdAt,
    this.updatedAt,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pricePerKg: json['price_per_kg'].toDouble(),
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
      'name': name,
      'description': description,
      'price_per_kg': pricePerKg,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
