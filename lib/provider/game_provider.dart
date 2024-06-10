// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:quiz_api/router/app_route.dart';
import 'package:quiz_api/services/api_service.dart';

import '../components/response_tile.dart';
import '../model/question_model.dart';

class GameProvider extends ChangeNotifier {
  int points = 0;
  int score = 0;
  bool canSelected = true;
  int index = 0;

  final List<GlobalKey<ResponseTileState>> responseTileKeys = [
    GlobalKey<ResponseTileState>(),
    GlobalKey<ResponseTileState>(),
    GlobalKey<ResponseTileState>(),
    GlobalKey<ResponseTileState>(),
  ];
  Question? currentQuestion;
  List<Question> questions = [];
  List<Question> questionsTest = [
    // Your list of test questions
  ];

  Map<int, Map<String, dynamic>> selectedAnswers =
      {}; // Store selected answers for each question

  Future<void> init({required String categorie}) async {
    questions = await ApiService.getQuestionByCaterory(categorie) ??
        await ApiService.getRandomQuestion() ??
        questionsTest;
    score = 0;
    canSelected = true;
    index = 0;
    currentQuestion = questions[index];
  }

  void nextQuestion({required BuildContext context}) {
    if (index < 9) {
      bool isOptionSelected = false;
      for (var element in responseTileKeys) {
        if (element.currentState!.isSelected) {
          isOptionSelected = true;
          break;
        }
      }

      if (isOptionSelected) {
        canSelected = true;
        for (var element in responseTileKeys) {
          element.currentState!.init();
        }
        if (index < questions.length) {
          index++;
          currentQuestion = questions[index];
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('YOU MUST SELECT AN OPTION'),
          ),
        );
      }
    } else if (index == 9) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoute.scorePage, (route) => false,
          arguments: score);
    }
  }

  void previousQuestion({required BuildContext context}) {
    if (index > 0) {
      index--;
      currentQuestion = questions[index];
      notifyListeners();
    }
  }

  void corrector() {
    for (var element in responseTileKeys) {
      element.currentState!.correction();
    }
    notifyListeners();
  }

  void playAgain({required BuildContext context}) {
    score = 0;
    canSelected = true;
    index = 0;
    currentQuestion = questions[index];
    selectedAnswers.clear(); // Clear selected answers when starting a new game
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoute.quizPage, (route) => false);
  }

  void addScore() {
    score++;
    notifyListeners();
  }

  bool isSelected(String answer) {
    // ignore: unrelated_type_equality_checks
    return selectedAnswers == answer;
  }

  void setSelectedAnswer(String answer) {
    selectedAnswers = answer as Map<int, Map<String, dynamic>>;
    notifyListeners();
  }

  Map<String, dynamic>? getSelectedAnswer(int questionIndex) {
    return selectedAnswers[questionIndex];
  }
}
