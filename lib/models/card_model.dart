// lib/models/card_model.dart

enum CardState { faceDown, faceUp, matched }

class CardModel {
  final int id;
  final String imageAsset;
  CardState state;

  CardModel({
    required this.id,
    required this.imageAsset,
    this.state = CardState.faceDown,
  });
}
