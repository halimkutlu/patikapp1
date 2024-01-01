import 'dart:convert';

class WordStatistics {
  int? wordId;
  int? learned;
  int? repeat;
  int? workHard;
  int? successCount;
  int? errorCount;

  WordStatistics({
    this.wordId,
    this.learned,
    this.repeat,
    this.workHard,
    this.successCount,
    this.errorCount,
  });

  factory WordStatistics.fromMap(Map<String, dynamic> json) => WordStatistics(
        wordId: json["WordId"],
        learned: json["Learned"],
        repeat: json["Repeat"],
        workHard: json["WorkHard"],
        successCount: json["SuccessCount"],
        errorCount: json["ErrorCount"],
      );

  Map<String, dynamic> toMap() => {
        "WordId": wordId,
        "Learned": learned,
        "Repeat": repeat,
        "WorkHard": workHard,
        "SuccessCount": successCount,
        "ErrorCount": errorCount,
      };

  String toJson() {
    final Map<String, dynamic> data = toMap();
    return json.encode(data);
  }

  factory WordStatistics.fromJson(String str) {
    final Map<String, dynamic> data = json.decode(str);
    return WordStatistics.fromMap(data);
  }
}
