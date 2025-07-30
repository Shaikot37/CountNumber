import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'numbers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Learner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: NumberLearningPage(),
    );
  }
}

class NumberLearningPage extends StatefulWidget {
  @override
  _NumberLearningPageState createState() => _NumberLearningPageState();
}

class _NumberLearningPageState extends State<NumberLearningPage>
    with TickerProviderStateMixin {
  String selectedLanguage = 'English';
  final AudioPlayer _player = AudioPlayer();
  bool autoPlayNext = false;
  int? highlighted;
  bool _isPlayingSequence = false; // block input during autoplay

  // Play audio for a number, optionally autoplay next recursively
  Future<void> _playAudio(int number) async {
    if (_isPlayingSequence && !autoPlayNext)
      return; // Block clicks during single play

    final audioFile = numbers[number]?[selectedLanguage]?['audio'];
    if (audioFile != null) {
      setState(() {
        highlighted = number;
        if (autoPlayNext) _isPlayingSequence = true;
      });

      try {
        await _player.play(AssetSource('audio/$audioFile'));
      } catch (e) {
        print('Error playing audio: $e');
      }

      // If autoplay on and number less than max, wait and play next
      if (autoPlayNext && number < 10) {
        await Future.delayed(const Duration(milliseconds: 1500));
        await _playAudio(number + 1);
      } else {
        // Wait briefly so the last number stays highlighted visibly
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _isPlayingSequence = false;
          highlighted = null;
        });
      }
    } else {
      print('Audio file not found for number $number in $selectedLanguage');
    }
  }

  Color get appBarColor {
    if (highlighted != null) {
      return Colors.green.shade600; // matches the highlight green tones
    } else {
      return Colors.blue.shade700; // matches default blue tiles
    }
  }

  Color get appBarTextColor {
    if (highlighted != null) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allNumbers = numbers.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Learn Numbers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: appBarTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Auto-play',
                  style: TextStyle(
                    color: appBarTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: autoPlayNext,
                    activeColor: Colors.lightGreenAccent,
                    onChanged: (val) {
                      if (!_isPlayingSequence) {
                        setState(() => autoPlayNext = val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Select Language',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value != null && !_isPlayingSequence) {
                    setState(() => selectedLanguage = value);
                  }
                },
                items: ['English', 'Arabic', 'French', 'Chinese']
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: numbers.length,
                itemBuilder: (context, index) {
                  final number = allNumbers[index];
                  final translation =
                      numbers[number]?[selectedLanguage]?['text'] ?? '';
                  final isActive = number == highlighted;
                  final disabled = _isPlayingSequence && !isActive;

                  return AbsorbPointer(
                    absorbing:
                        disabled, // disable tap when autoplay playing other numbers
                    child: Opacity(
                      opacity: disabled ? 0.5 : 1,
                      child: GestureDetector(
                        onTap: () => _playAudio(number),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(
                                    colors: [
                                      Colors.lightGreenAccent,
                                      Colors.amberAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.lightBlue.shade200,
                                      Colors.lightBlue.shade100,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$number',
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.deepOrange
                                        : Colors.deepPurple,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Colors.deepPurple.withOpacity(
                                          0.3,
                                        ),
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  translation,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
