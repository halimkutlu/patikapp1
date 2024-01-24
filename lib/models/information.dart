import 'dart:convert';

class Information {
  int? lcid;
  String? code;
  String? version;
  String? directory;
  int? lngPlanType;
  String? lngHash;

  Information({
    this.lcid,
    this.code,
    this.version,
    this.directory,
    this.lngPlanType,
    this.lngHash,
  });

  factory Information.fromMap(Map<String, dynamic> json) => Information(
        lcid: json["LCID"],
        code: json["Code"],
        version: json["Version"],
        directory: json["Directory"],
        lngPlanType: json["LngPlanType"],
        lngHash: json["LngHash"],
      );

  Map<String, dynamic> toMap() => {
        "LCID": lcid,
        "Code": code,
        "Version": version,
        "Directory": directory,
        "LngPlanType": lngPlanType,
        "LngHash": lngHash,
      };

  String toJson() {
    final Map<String, dynamic> data = toMap();
    return json.encode(data);
  }

  factory Information.fromJson(String str) {
    final Map<String, dynamic> data = json.decode(str);
    return Information.fromMap(data);
  }
}
