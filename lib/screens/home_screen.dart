import 'package:flutter/material.dart';
import 'package:my_own_flashcards/parts/button_with_icon.dart';
import 'package:my_own_flashcards/screens/test_screen.dart';
import 'package:my_own_flashcards/screens/word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isIncludedMemorizedWords = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Image.asset("assets/images/image_title.png"),
            ),
            _titleText(),
            const Divider(
              height: 30.0,
              indent: 8.0,
              endIndent: 8.0,
              thickness: 1.0,
              color: Colors.white,
            ),
            ButtonWithIcon(
              onPressed: () => _startTestScreen(context),
              icon: const Icon(Icons.play_arrow),
              label: "確認テストをする",
              color: Colors.brown,
            ),
            const SizedBox(
              height: 10.0,
            ),
            _radioButtons(),
            const SizedBox(
              height: 20.0,
            ),
            ButtonWithIcon(
                onPressed: () => _startWordListScreen(context),
                icon: const Icon(Icons.list),
                label: "単語一覧をみる",
                color: Colors.grey),
            const SizedBox(
              height: 60.0,
            ),
            const Text(
              "powered by Telulu LLC",
              style: TextStyle(fontFamily: "Mont"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleText() {
    return Column(
      children: const [
        Text(
          "私だけの単語帳",
          style: TextStyle(fontSize: 40.0, fontFamily: "Lanobe"),
        ),
        Text(
          "My Own Flashcard",
          style: TextStyle(fontSize: 24.0),
        ),
      ],
    );
  }

  Widget _radioButtons() {
    return Column(
      children: [
        RadioListTile(
          title: const Text(
            "暗記済みの単語を除外する",
            style: TextStyle(fontSize: 16.0),
          ),
          value: false,
          groupValue: isIncludedMemorizedWords,
          onChanged: (bool? value) => _onRadioSelected(value!),
        ),
        RadioListTile(
          title: const Text(
            "暗記済みの単語を含む",
            style: TextStyle(fontSize: 16.0),
          ),
          value: true,
          groupValue: isIncludedMemorizedWords,
          onChanged: (bool? value) => _onRadioSelected(value!),
        ),
      ],
    );
  }

  _onRadioSelected(bool value) {
    setState(() {
      isIncludedMemorizedWords = value;
    });
  }

  _startWordListScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordListScreen(),
      ),
    );
  }

  _startTestScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestScreen(
          isIncludedMemorizedWords: isIncludedMemorizedWords,
        ),
      ),
    );
  }
}
