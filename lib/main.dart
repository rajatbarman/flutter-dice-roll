import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DiceRollerApp());
}

class DiceRollerApp extends StatelessWidget {
  const DiceRollerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Roller',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Screen(title: 'Dice Roller app'),
    );
  }
}

class Screen extends StatefulWidget {
  const Screen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> with SingleTickerProviderStateMixin {
  final diceImages = [
    'one.png',
    'two.png',
    'three.png',
    'four.png',
    'five.png',
    'six-alt.png'
  ];

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  var currentDiceImage = 'one.png';
  int lastDiceFace = 1;
  late AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    ); // Repeats animation back and forth

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print('animation completed ...');
        _shuffleDice();
        // You can trigger any other callback or action here
      } else if (status == AnimationStatus.dismissed) {
        print("Animation Dismissed");
      }
    });

    // Animation to run continuously
    Tween<double>(begin: 0, end: 1).animate(_animController).addListener(() {
      setState(() {
        // Change image every time the animation progress is updated
        print('animation ...');
        _shuffleDiceAnimation();
      });
    });

    // Scale animation (scales between 0.5 and 1.5)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: .3),
        weight: 50, // 0% to 25%
      ),
      TweenSequenceItem(
        tween: Tween(begin: .3, end: 1.0),
        weight: 50, // 25% to 50%
      ),
    ]).animate(_animController);

    // Rotation animation (rotates between 0 and 360 degrees)
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: 2 * pi),
        weight: 50, // 0% to 25%
      ),
      TweenSequenceItem(
        tween: Tween(begin: 2 * pi, end: 0),
        weight: 50, // 25% to 50%
      ),
    ]).animate(_animController);
  }

  void onDiceTap() {
    _animController.reset();
    _playDiceRollSound();
    _animController.forward();
  }

  Future<void> _playDiceRollSound() async {
    print('playDiceRollSound');
    await audioPlayer.play('assets/dice-roll.mp3'); // Play the sound
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _shuffleDiceAnimation() {
    currentDiceImage = diceImages[generateRandomNumber() - 1];
  }

  void _shuffleDice() {
    print('Dice rolled : $currentDiceImage');
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // _counter++;
      int nextDiceFace = generateRandomNumber();
      while (lastDiceFace == nextDiceFace) {
        nextDiceFace = generateRandomNumber();
      }
      lastDiceFace = nextDiceFace;
      currentDiceImage = diceImages[nextDiceFace - 1];
    });
  }

  int generateRandomNumber() {
    return Random().nextInt(6) + 1;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
            onTap: onDiceTap,
            child: Container(
                margin: const EdgeInsets.only(top: 260),
                decoration: BoxDecoration(
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.amber.withOpacity(0.1),
                    //     blurRadius: 20.0,
                    //     spreadRadius: 5.0,
                    //     offset: Offset(0, 0), // Shadow position
                    //   )
                    // ],
                    ),
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value, // Apply scaling
                      child: Transform.rotate(
                        angle: _rotationAnimation.value, // Apply rotation
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset('assets/$currentDiceImage',
                      width: 150, height: 150),
                )))
      ]),
    );
  }
}
