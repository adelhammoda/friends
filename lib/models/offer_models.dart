class Offer {
  final String id, name, offerOwnerId, description;
  final double value;
  final Map info;
  final DateTime date;
  final int? totalCapacity;
  final List images;

  Offer({
    required this.id,
    required this.images,
    required this.name,
    required this.offerOwnerId,
    required this.description,
    required this.date,
    required this.info,
    required this.value,
    this.totalCapacity,
  });

  factory Offer.fromJSON(Map data) {
    print('I am in from JSON and the result is $data');
    return Offer(
        id: data['id'].toString(),
        images: data['images'],
        name: data['offerName'],
        offerOwnerId: data['offerOwnerId'].toString(),
        description: data['description'],
        date: stringToDate(data['date']),
        info: data['info']??{},
        value: int.tryParse(data['offerValue'].toString())?.toDouble()??0.0,
        totalCapacity: int.tryParse(data['totalCapacity'].toString())??0);
  }

  String dateToDataBaseString() => date.toIso8601String();

  static DateTime stringToDate(String str) => DateTime.parse(str);

  Map<String, dynamic> toJSON() {
    return {
      'images': images,
      'offerName': name,
      'offerOwnerId': offerOwnerId,
      'description': description,
      'date': dateToDataBaseString(),
      'info': info,
      'offerValue': value,
    };
  }

  static Map fromList(List<Map> data){
    Map res={ };
     data.forEach((element) {
       res.addAll({element.keys.first:element.values.first});
     });
     return res;
  }
}
