// ignore_for_file: constant_identifier_names

class LngPlanType {
  static const int Free = 0;
  static const int QRCode = 1;
  static const int Premium = 2;
}

class UserRole {
  static const int admin = 1;
  static const int premium = 2;
  static const int qr = 3;
  static const int free = 4;
  static const int unknown = 0;

  int role;

  UserRole(this.role);

  String getRoleDescription() {
    switch (role) {
      case admin:
        return "Admin";
      case premium:
        return "Premium";
      case qr:
        return "QR";
      case free:
        return "Free";
      default:
        return "Unknown";
    }
  }

  static String getRoleDescriptionFromId(int r) {
    switch (r) {
      case 1:
        return "Admin";
      case 2:
        return "Premium";
      case 3:
        return "QR";
      case 4:
        return "Free";
      default:
        return "";
    }
  }
}

String getRoleName(int id) {
  switch (id) {
    case 1:
      return "Admin";
    case 2:
      return "Premium";
    case 3:
      return "QR";
    case 4:
      return "Free";
    default:
      return "Unknown";
  }
}
