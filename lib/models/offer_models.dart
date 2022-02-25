class Offer {
  final String id, imageUrl, name, offerOwnerId, description;
  final double value;
  final Map info;
  final DateTime date;
  final double? totalCapacity;

  Offer({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.offerOwnerId,
    required this.description,
    required this.date,
    required this.info,
    required this.value,
     this.totalCapacity,
  });

  factory Offer.fromJSON(Map data) {
    return Offer(
        id: data['id'],
        imageUrl: data['imageUrl'],
        name: data['name'],
        offerOwnerId: data['offerOwnerId'],
        description: data['description'],
        date: stringToDate(data['date']),
        info: data['info'],
        value: data['value'],
    totalCapacity: data['totalCapacity']);
  }

  String dateToDataBaseString() => date.toIso8601String();

  static DateTime stringToDate(String str) => DateTime.parse(str);

  Map<String, dynamic> toJSON() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'offerOwnerId': offerOwnerId,
      'description': description,
      'date': dateToDataBaseString(),
      'info': info,
      'value': value,
    };
  }
}
