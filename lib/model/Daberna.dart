import '../helper/variables.dart';
import 'dart:convert';

class Daberna {
  String id;
  String type;
  String cardCount;
  String playerCount;
  List<DabernaBoard> boards;
  List numbers;
  List winners;
  List rowWinners;
  String createdAt;

  Daberna.fromJson(Map<String, dynamic> json)
      : id = "${json["id"] ?? ''}",
        type = "${json["type"] ?? ''}",
        boards = parseBoards(json['boards']),
        numbers = json['numbers'] ?? [],
        winners = json['winners'] ?? [],
        rowWinners = json['rowWinners'] ?? [],
        cardCount = "${json["cardCount"] ?? '0'}",
        playerCount = "${json["playerCount"] ?? ''}",
        createdAt = "${json["createdAt"] ?? ''}";

  static parseBoards(json) {
    return (json.runtimeType == String ? jsonDecode(json) : json)
        .map<DabernaBoard>((item) => DabernaBoard.fromJson(item))
        .toList();
  }
}

class DabernaBoard {
  String playerId;
  int cardCount;
  String username;
  String level;
  String cardNumber;
  List card;

  DabernaBoard.fromJson(Map<String, dynamic> json)
      : playerId = "${json["user_id"] ?? 0}",
        card = json["card"],
        username = "${json["username"] ?? ''}",
        level = "${json["level"] ?? ''}",
        cardNumber = "${json["card_number"] ?? ''}",
        cardCount = int.parse("${json["card_count"] ?? 0}");
}
