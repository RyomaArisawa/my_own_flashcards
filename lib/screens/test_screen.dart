import 'package:flutter/material.dart';
import 'package:my_own_flashcards/db/database.dart';
import 'package:my_own_flashcards/main.dart';

enum TestStatus { BEFORE_START, SHOW_QUESTION, SHOW_ANSWER, FINISHED }

class TestScreen extends StatefulWidget {
  final bool isIncludedMemorizedWords;

  TestScreen({required this.isIncludedMemorizedWords});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestion = 0;
  String _textQuestion = "Test";
  String _textAnswer = "Answer";
  bool _isMemorized = false;
  List<Word> _testDataList = [];

  bool _isQuestionCardVisible = false;
  bool _isAnswerCardVisible = false;
  bool _isCheckBoxVisible = false;
  bool _isFabVisible = false;

  TestStatus _testStatus = TestStatus.BEFORE_START;

  int _index = 0;
  late Word _currentWord;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getTestData();
  }

  void _getTestData() async {
    if (widget.isIncludedMemorizedWords) {
      _testDataList = await database.allWords;
    } else {
      _testDataList = await database.allWordsExcludedMemorized;
    }
    _testDataList.shuffle();
    _testStatus = TestStatus.BEFORE_START;
    _index = 0;

    setState(() {
      _isQuestionCardVisible = false;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;
      _numberOfQuestion = _testDataList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    var isIncluded = widget.isIncludedMemorizedWords;
    return Scaffold(
      appBar: AppBar(
        title: const Text("確認テスト"),
        centerTitle: true,
      ),
      floatingActionButton: (_isFabVisible && _testDataList.isNotEmpty)
          ? FloatingActionButton(
              onPressed: () => _goNextStatus(),
              child: const Icon(Icons.skip_next),
              tooltip: "次に進む",
            )
          : null,
      body: Stack(
        children: [
          Column(children: [
            const SizedBox(
              height: 10.0,
            ),
            _numberOfQuestionsPart(),
            const SizedBox(
              height: 20.0,
            ),
            _questionCardPart(),
            const SizedBox(
              height: 20.0,
            ),
            _answerCardPart(),
            const SizedBox(
              height: 20.0,
            ),
            _isMemorizedCheckPart()
          ]),
          _endMessage(),
        ],
      ),
    );
  }

  Widget _numberOfQuestionsPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "残り問題数",
          style: TextStyle(fontSize: 14.0),
        ),
        const SizedBox(
          width: 30.0,
        ),
        Text(
          _numberOfQuestion.toString(),
          style: const TextStyle(fontSize: 24.0),
        )
      ],
    );
  }

  Widget _questionCardPart() {
    if (_isQuestionCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/images/image_flash_question.png"),
          Text(
            _textQuestion,
            style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _answerCardPart() {
    if (_isAnswerCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/images/image_flash_answer.png"),
          Text(
            _textAnswer,
            style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _isMemorizedCheckPart() {
    if (_isCheckBoxVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CheckboxListTile(
          title: const Text(
            "暗記済みにする場合はチェックを入れてください",
            style: TextStyle(fontSize: 12.0),
          ),
          value: _isMemorized,
          onChanged: (bool? value) {
            setState(() {
              _isMemorized = value!;
            });
          },
        ),
      );
    } else {
      return Container();
    }
  }

  _goNextStatus() async {
    switch (_testStatus) {
      case TestStatus.BEFORE_START:
        _testStatus = TestStatus.SHOW_QUESTION;
        _showQuestion();
        break;
      case TestStatus.SHOW_QUESTION:
        _testStatus = TestStatus.SHOW_ANSWER;
        _showAnswer();
        break;
      case TestStatus.SHOW_ANSWER:
        await _updateMemorizedFlag();
        if (_numberOfQuestion <= 0) {
          setState(() {
            _testStatus = TestStatus.FINISHED;
          });
        } else {
          _testStatus = TestStatus.SHOW_QUESTION;
          _showQuestion();
        }
        break;
    }
  }

  void _showQuestion() {
    _currentWord = _testDataList[_index];
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;
      _textQuestion = _currentWord.strQuestion;
    });
    _numberOfQuestion--;
    _index++;
  }

  void _showAnswer() {
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = true;
      _isCheckBoxVisible = true;
      _isFabVisible = true;
      _textAnswer = _currentWord.strAnswer;
      _isMemorized = _currentWord.isMemorized;
    });
  }

  Future<void> _updateMemorizedFlag() async {
    var updateWord = Word(
      strQuestion: _currentWord.strQuestion,
      strAnswer: _currentWord.strAnswer,
      isMemorized: _isMemorized,
    );
    await database.updateWord(updateWord);
  }

  Widget _endMessage() {
    if (_testStatus == TestStatus.FINISHED) {
      return const Center(
        child: Text(
          "テスト終了",
          style: TextStyle(fontSize: 50.0),
        ),
      );
    } else {
      return Container();
    }
  }
}
