class UserModel {
  final String id; // UUID from Supabase Auth
  final String name;
  final String address;

  UserModel({
    required this.id,
    required this.name,
    required this.address,
  });

  // Convert JSON (from Supabase) to a UserModel object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }

  // Convert UserModel object to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }
}
