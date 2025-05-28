// To parse this JSON data, do
//
//     final getVegdata = getVegdataFromJson(jsonString);

import 'dart:convert';

List<GetVegdata> getVegdataFromJson(String str) => List<GetVegdata>.from(json.decode(str).map((x) => GetVegdata.fromJson(x)));

String getVegdataToJson(List<GetVegdata> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetVegdata {
    int? id;
    String? name;
    String? description;
    String? price;
    String? imageUrl;
    String? category;

    GetVegdata({
        this.id,
        this.name,
        this.description,
        this.price,
        this.imageUrl,
        this.category,
    });

    factory GetVegdata.fromJson(Map<String, dynamic> json) => GetVegdata(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"],
        imageUrl: json["image_url"],
        category: json["category"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image_url": imageUrl,
        "category": category,
    };
}
