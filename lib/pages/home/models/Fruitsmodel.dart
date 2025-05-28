// To parse this JSON data, do
//
//     final getdata = getdataFromJson(jsonString);

import 'dart:convert';

List<Getdata> getdataFromJson(String str) => List<Getdata>.from(json.decode(str).map((x) => Getdata.fromJson(x)));

String getdataToJson(List<Getdata> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getdata {
    int? id;
    String? name;
    String? description;
    String? price;
    String? imageUrl;
    Category? category;

    Getdata({
        this.id,
        this.name,
        this.description,
        this.price,
        this.imageUrl,
        this.category,
    });

    factory Getdata.fromJson(Map<String, dynamic> json) => Getdata(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"],
        imageUrl: json["image_url"],
        category: categoryValues.map[json["category"]]!,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image_url": imageUrl,
        "category": categoryValues.reverse[category],
    };
}

enum Category {
    FRUIT
}

final categoryValues = EnumValues({
    "Fruit": Category.FRUIT
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
