import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_own_flashcards/main.dart';
import 'package:my_own_flashcards/screens/word_list_screen.dart';

import '../db/database.dart';

enum EditStatus { ADD, EDIT }

class EditScreen extends StatefulWidget {
  final EditStatus status;
  final Word? word;

  EditScreen({required this.status, this.word});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _textTitle = "";

  bool _isQuestionEnabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.status == EditStatus.ADD){
      _textTitle = "新しい単語の追加";
      questionController.text = "";
      answerController.text = "";
      _isQuestionEnabled = true;
    }else{
      _textTitle = "登録した単語の修正";
      questionController.text = widget.word!.strQuestion;
      answerController.text = widget.word!.strAnswer;
      _isQuestionEnabled = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backWordListScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_textTitle),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: "登録",
              onPressed: () => _onWordRegisterd(),
              icon: const Icon(Icons.done),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 100.0,
              ),
              const Center(
                child: Text(
                  "問題と答えを入力して「登録」ボタンを押してください",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              const SizedBox(
                height: 50.0,
              ),
              _questionInputPart(),
              const SizedBox(
                height: 50.0,
              ),
              _answerInputPart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          const Text(
            "問題",
            style: TextStyle(fontSize: 24.0),
          ),
          TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30.0),
          ),
        ],
      ),
    );
  }

  Widget _answerInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          const Text(
            "答え",
            style: TextStyle(fontSize: 24.0),
          ),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30.0),
          )
        ],
      ),
    );
  }

  Future<bool> _backWordListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WordListScreen(),
      ),
    );
    return Future.value(false);
  }

  _insertWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Fluttertoast.showToast(
        msg: "問題と答えの両方を入力しないと登録できません",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    try {
      var word = Word(
          strQuestion: questionController.text,
          strAnswer: answerController.text);
      await database.addWord(word);
      questionController.clear();
      answerController.clear();
      Fluttertoast.showToast(
        msg: "登録が完了しました",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } on SqliteException catch (e) {
      Fluttertoast.showToast(
        msg: "登録に失敗しました",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  _onWordRegisterd() {
    if(widget.status == EditStatus.ADD){
      _insertWord();
    }else{
      _updateWord();
    }
  }

  _updateWord() async{
    if (questionController.text == "" || answerController.text == "") {
      Fluttertoast.showToast(
        msg: "問題と答えの両方を入力しないと登録できません",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    try {
      var word = Word(
          strQuestion: questionController.text,
          strAnswer: answerController.text);
      await database.updateWord(word);
      _backWordListScreen();
    } on SqliteException catch (e) {
      Fluttertoast.showToast(
        msg: "修正に失敗しました",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
