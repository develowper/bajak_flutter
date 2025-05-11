import '../helper/variables.dart';
import 'dart:convert';

class Room {
  String id;
  String type;
  int cardPrice;
  int secondsRemaining;
  int maxSeconds;
  String title;
  String page;
  String cardCount;
  String userCardCount;
  String playerCount;
  int maxUserCardsCount;
  String maxCardsCount;
  String winScore;
  List<RoomPlayer> players;
  String image;
  bool isActive;
  bool startWithMe;

  Room.fromJson(Map<String, dynamic> json)
      : id = "${json["id"] ?? ''}",
        type = "${json["type"] ?? ''}",
        cardPrice = int.parse("${json["cardPrice"] ?? '0'}"),
        page = "${json["page"] ?? ''}",
        title = "${json["title"] ?? ''}",
        maxSeconds = int.parse("${json["maxSeconds"] ?? '0'}"),
        secondsRemaining = int.parse("${json["secondsRemaining"] ?? '0'}"),
        maxCardsCount = "${json["maxCardsCount"] ?? ''}",
        maxUserCardsCount = int.parse("${json["maxUserCardsCount"] ?? '0'}"),
        userCardCount = "${json["userCardCount"] ?? '0'}",
        cardCount = "${json["cardCount"] ?? '0'}",
        playerCount = "${json["playerCount"] ?? ''}",
        winScore = "${json["winScore"] ?? ''}",
        image =
            json['image'] != null ? "${Variable.DOMAIN}/${json['image']}" : '',
        players = parsePlayers(json['players'] ?? '[]'),
        startWithMe = json["startWithMe"] ?? false,
        isActive = json["isActive"] ?? false;

  Room.fromNull()
      : id = "",
        page = "",
        type = "",
        cardPrice = 0,
        title = "",
        maxSeconds = 0,
        secondsRemaining = 0,
        maxCardsCount = '0',
        maxUserCardsCount = 0,
        userCardCount = '0',
        cardCount = '0',
        playerCount = "",
        winScore = "",
        image = "",
        players = [],
        startWithMe = false,
        isActive = false;

  static parsePlayers(json) {
    return (json.runtimeType == String ? jsonDecode(json) : json)
        .map<RoomPlayer>((item) => RoomPlayer.fromJson(item))
        .toList();
  }
}

class RoomPlayer {
  String playerId;
  int cardCount;
  String username;

  RoomPlayer.fromJson(Map<String, dynamic> json)
      : playerId = "${json["user_id"] ?? 0}",
        username = "${json["username"] ?? ''}",
        cardCount = int.parse("${json["card_count"] ?? 0}") {
    // print(
    //     'Parsed RoomPlayer -> id: $playerId, username: $username, cardCount: $cardCount');
  }
}
