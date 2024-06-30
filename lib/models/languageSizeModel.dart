import 'dart:convert';

class LngFileSizeResponse {
  int? lcid;
  String? fileName;
  Map<int, double>? fileSizeList;

  LngFileSizeResponse({
    this.lcid,
    this.fileName,
    this.fileSizeList,
  });

  factory LngFileSizeResponse.fromMap(Map<String, dynamic> json) => LngFileSizeResponse(
        lcid: json["lcid"],
        fileName: json["fileName"],
        fileSizeList: (json["fileSizeList"] as Map<String, dynamic>).map(
          (key, value) => MapEntry(int.parse(key), value.toDouble()),
        ),
      );

  Map<String, dynamic> toMap() => {
        "lcid": lcid,
        "fileName": fileName,
        "fileSizeList": fileSizeList?.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      };

  String toJson() {
    final Map<String, dynamic> data = toMap();
    return json.encode(data);
  }

  factory LngFileSizeResponse.fromJson(String str) {
    final Map<String, dynamic> data = json.decode(str);
    return LngFileSizeResponse.fromMap(data);
  }

  static List<LngFileSizeResponse> listFromJson(List<dynamic> jsonData) {

    return jsonData.map((item) => LngFileSizeResponse.fromMap(item)).toList();
  }

  static String listToJson(List<LngFileSizeResponse> data) {
    final List<Map<String, dynamic>> jsonData = data.map((item) => item.toMap()).toList();
    return json.encode(jsonData);
  }
}
