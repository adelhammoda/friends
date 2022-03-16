class User {
  final String id;
  final String name;
  final String userType;
  final String? imageUrl;
  final String phoneNumber;
  final String? address;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.phoneNumber,
    this.imageUrl,
    this.address,
  });

  factory User.fromJSON(Map data) {
    return User(
        id: data['id'],
        email: data['email'],
        phoneNumber: data['phone_number'],
        name: data['name'],
        userType: data['userType'],
        imageUrl: data['imageUrl']);
  }

  Map<String, String> toJSON() {
    return {
      'phone_number':phoneNumber,
      'name': name,
      'userType': userType,
      'imageUrl': imageUrl.toString(),
      "id": id,
      'address': address.toString(),
      'email': email,
    };
  }
}
