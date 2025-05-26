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

    Getdata({
        this.id,
        this.name,
        this.description,
        this.price,
        this.imageUrl,
    });

    factory Getdata.fromJson(Map<String, dynamic> json) => Getdata(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"],
        imageUrl: json["image_url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image_url": imageUrl,
    };
}
