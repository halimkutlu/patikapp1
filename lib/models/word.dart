import 'dart:convert';

class Word {
  int? id;
  String? word;
  String? wordA;
  String? wordT;
  bool? isCategoryName;
  String? categories;
  String? activities;
  int? orderId;

  Word({
    this.id,
    this.word,
    this.wordA,
    this.wordT,
    this.isCategoryName,
    this.categories,
    this.activities,
    this.orderId,
  });

  factory Word.fromMap(Map<String, dynamic> json) => Word(
        id: json["Id"],
        word: json["Word"],
        wordA: json["WordA"],
        wordT: json["WordT"],
        isCategoryName: json["IsCategoryName"] == 1,
        categories: json["Categories"],
        activities: json["Activities"],
        orderId: json["OrderId"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Word": word,
        "WordA": wordA,
        "WordT": wordT,
        "IsCategoryName": isCategoryName! ? 1 : 0,
        "Categories": categories,
        "Activities": activities,
        "OrderId": orderId,
      };

  String toJson() {
    final Map<String, dynamic> data = toMap();
    return json.encode(data);
  }

  factory Word.fromJson(String str) {
    final Map<String, dynamic> data = json.decode(str);
    return Word.fromMap(data);
  }
}

class WordListInformation {
  String? categoryName;
  int? categoryWordCount;
  int? totalCount;
  String? categoryImage;
  String? categoryOrderName;
  int? order;
  int? orderColor;

  WordListInformation(
      {this.categoryImage,
      this.categoryName,
      this.categoryWordCount,
      this.order,
      this.categoryOrderName,
      this.orderColor,
      this.totalCount});
}
