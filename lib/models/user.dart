class User {
  late int? id;
  late String? firstName;
  late String? lastName;
  late String? username;
  late List<int>? roles;
  late String? token;
  late String? message;
  late bool? Success;

  User(
      {this.firstName,
      this.id,
      this.lastName,
      this.roles,
      this.token,
      this.username,
      this.message,
      this.Success});

  User.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    username = json['Username'];
    roles = List<int>.from(json['Roles']);
    token = json['Token'];
    message = json['message'];
    Success = json['Success'];
  }
}
