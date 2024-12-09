// To parse this JSON data, do
//
//     final storeEntry = storeEntryFromJson(jsonString);

import 'dart:convert';

List<StoreEntry> storeEntryFromJson(String str) => List<StoreEntry>.from(json.decode(str).map((x) => StoreEntry.fromJson(x)));

String storeEntryToJson(List<StoreEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StoreEntry {
    String model;
    int pk;
    Fields fields;

    StoreEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory StoreEntry.fromJson(Map<String, dynamic> json) => StoreEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String name;
    String description;
    String address;
    String opening_days;
    String opening_hours;
    String phone;
    String image1;
    String image2;
    String image3;
    String location_link;

    Fields({
        required this.name,
        required this.description,
        required this.address,
        required this.opening_days,
        required this.opening_hours,
        required this.phone,
        required this.image1,
        required this.image2,
        required this.image3,
        required this.location_link,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        description: json["description"],
        address: json["address"],
        opening_days: json["opening_days"],
        opening_hours: json["opening_hours"],
        phone: json["phone"],
        image1: json["image1"],
        image2: json["image2"],
        image3: json["image3"],
        location_link: json["location_link"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "address": address,
        "opening_days": opening_days,
        "opening_hours": opening_hours,
        "phone": phone,
        "image1": image1,
        "image2": image2,
        "image3": image3,
        "location_link": location_link,
    };
}
