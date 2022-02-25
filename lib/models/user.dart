class User {
  final String id;
  final String name;
  final String userType;
  final String? imageUrl;

  User(
      {required this.id,
      required this.name,
      required this.userType,
      this.imageUrl});

  factory User.fromJSON(Map data, String id) {
    return User(
        id: id,
        name: data['name'],
        userType: data['userType'],
        imageUrl: data['imageUrl']);
  }

  Map<String, dynamic> toJSON() {
    return {
      'name': name,
      'userType': userType,
      'imageUrl':imageUrl
    };
  }
}
