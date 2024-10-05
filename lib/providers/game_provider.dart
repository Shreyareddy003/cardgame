// lib/providers/game_provider.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/card_model.dart';

class GameProvider with ChangeNotifier {
  List<CardModel> _cards = [];
  int? _firstSelectedIndex;
  int? _secondSelectedIndex;
  bool _isChecking = false;

  // Extra Task: Timer and Scoring System
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _score = 0;

  // Callback for victory
  VoidCallback? onVictory;

  GameProvider() {
    _initializeGame();
  }

  List<CardModel> get cards => _cards;
  int get elapsedSeconds => _elapsedSeconds;
  int get score => _score;

  void _initializeGame() {
    _cards = [];
    _elapsedSeconds = 0;
    _score = 0;
    _firstSelectedIndex = null;
    _secondSelectedIndex = null;
    _isChecking = false;

    // Define your images (ensure these assets are added to pubspec.yaml)
    List<String> images = [
      'assets/images/image1.jpeg',
      'assets/images/image2.jpeg',
      'assets/images/image3.jpeg',
      'assets/images/image4.jpeg',
      'assets/images/image5.jpeg',
      'assets/images/image6.jpeg',
      'assets/images/image7.jpeg',
      'assets/images/image8.jpeg',
    ];

    // Duplicate the images to create pairs
    List<String> cardImages = List.from(images)..addAll(images);

    // Shuffle the cards
    cardImages.shuffle(Random());

    // Assign unique IDs
    _cards = List.generate(cardImages.length, (index) {
      return CardModel(id: index, imageAsset: cardImages[index]);
    });

    // Start Timer
    _startTimer();

    notifyListeners();
  }

  void flipCard(int index) {
    if (_isChecking) return;
    if (_cards[index].state == CardState.faceUp || _cards[index].state == CardState.matched) return;

    _cards[index].state = CardState.faceUp;
    notifyListeners();

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _secondSelectedIndex = index;
      _isChecking = true;
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    if (_firstSelectedIndex == null || _secondSelectedIndex == null) return;

    final firstCard = _cards[_firstSelectedIndex!];
    final secondCard = _cards[_secondSelectedIndex!];

    if (firstCard.imageAsset == secondCard.imageAsset) {
      // Match found
      firstCard.state = CardState.matched;
      secondCard.state = CardState.matched;
      _score += 10; // Example scoring
      _checkWinCondition();
    } else {
      // Not a match
      _score -= 5; // Example scoring
      Future.delayed(Duration(seconds: 1), () {
        firstCard.state = CardState.faceDown;
        secondCard.state = CardState.faceDown;
        notifyListeners();
      });
    }

    _firstSelectedIndex = null;
    _secondSelectedIndex = null;
    _isChecking = false;
    notifyListeners();
  }

  void _checkWinCondition() {
    bool allMatched = _cards.every((card) => card.state == CardState.matched);
    if (allMatched) {
      _stopTimer();
      if (onVictory != null) {
        onVictory!();
      }
    }
  }

  // Extra Task Methods
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void restartGame() {
    _timer?.cancel();
    _initializeGame();
  }
}
