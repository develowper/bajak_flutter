import '../helper/variables.dart';

class User {
  String id;
  String avatar;
  String phone;
  String username;
  String fullName;
  String telegramUsername;
  String telegramId;
  String email;
  bool isVip;
  bool phoneVerified;
  bool emailVerified;
  bool isActive;
  String score;
  String wallet;
  String expiresAt;
  String refId;
  String refCount;
  String rank;
  bool ticketNotification;
  UserFinancial financial;

  User({
    required this.id,
    required this.avatar,
    required this.phone,
    required this.fullName,
    required this.username,
    required this.email,
    required this.expiresAt,
    required this.telegramUsername,
    required this.telegramId,
    required this.isVip,
    required this.isActive,
    required this.score,
    required this.phoneVerified,
    required this.emailVerified,
    required this.refId,
    required this.refCount,
    required this.ticketNotification,
    required this.wallet,
    required this.financial,
    required this.rank,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = "${json["id"] ?? ''}",
        username = json["username"] ?? '',
        fullName = json["fullName"] ?? '',
        telegramUsername = json["telegram_username"] ?? '',
        telegramId = json["telegram_id"] ?? '',
        email = json["email"] ?? '',
        score = "${json["score"] ?? 0}",
        wallet = "${json["wallet"] ?? 0}",
        rank = "${json["wallet"] ?? 0}",
        phone = json["phone"] ?? '',
        isActive = json["isActive"] ?? false,
        refCount = "${json["refCount"] ?? '0'}",
        isVip = json["is_vip"] ?? false,
        avatar = "${Variable.LINK_STORAGE_USERS}/${json['id']}.jpg",
        phoneVerified = json["phone_verified"] ?? false,
        emailVerified = json["email_verified"] ?? false,
        ticketNotification = json["ticket_notification"] ?? false,
        refId = json["ref_id"] ?? '',
        financial = json["financial"] != null
            ? UserFinancial.fromJson(json["financial"])
            : UserFinancial.fromNull(),
        expiresAt = json["expires_at"] ?? '';

  User.nullUser()
      : id = '',
        username = '',
        avatar = "",
        fullName = '',
        phone = '',
        telegramUsername = '',
        telegramId = '',
        email = '',
        score = '0',
        wallet = '0',
        rank = '0',
        refCount = '0',
        isVip = false,
        refId = '',
        ticketNotification = false,
        phoneVerified = false,
        emailVerified = false,
        isActive = false,
        financial = UserFinancial.fromNull(),
        expiresAt = '';
}

class UserFinancial {
  String id;
  String userId;
  int balance;
  String card;
  String sheba;

  UserFinancial.fromJson(Map<String, dynamic> json)
      : id = "${json["id"] ?? ''}",
        userId = "${json["userId"] ?? ''}",
        balance = int.parse("${json["balance"] ?? '0'}"),
        card = "${json["card"] ?? ''}",
        sheba = "${json["sheba"] ?? ''}";

  UserFinancial.fromNull()
      : id = '0',
        userId = '0',
        balance = 0,
        card = '',
        sheba = '';
}
