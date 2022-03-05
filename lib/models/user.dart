class User {
  final String id;
  final String name;
  final String userType;
  final String? imageUrl;
  final String? phoneNumber;
  final String? address;
  final String email;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.userType,
      this.imageUrl,
      this.address,
      this.phoneNumber});

  factory User.fromJSON(Map data) {
    return User(
        id: data['id'],
        email: data['email'],
        name: data['name'],
        userType: data['userType'],
        imageUrl: data['imageUrl']);
  }

  Map<String, dynamic> toJSON() {
    return {
      'name': name,
      'userType': userType,
      'imageUrl': imageUrl,
      "id": id,
      'address':address,
      'email':email,

    };
  }
}
