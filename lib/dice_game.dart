import 'package:flutter/material.dart';
import 'dart:math';
import 'dice_image.dart';
import 'game_result.dart';
import 'history_list.dart';

class DiceGame extends StatefulWidget {
  @override
  _DiceGameState createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> with SingleTickerProviderStateMixin {
  int walletBalance = 10;
  TextEditingController wagerController = TextEditingController();
  int wager = 0;
  int gameType = 2; // Default to "2 Alike"
  List<int> diceRolls = [1, 1, 1, 1]; // List for displaying dice values
  List<int> finalDiceRolls = [1, 1, 1, 1]; // Store final dice rolls used for win/loss check
  late AnimationController _animationController;
  String gameResult = ''; // To display win/lose message
  List<String> history = []; // List to store the history of results (win/lose and coin changes)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  // Function to roll 4 dice (final values)
  List<int> rollDice() {
    Random random = Random();
    return List.generate(4, (_) => random.nextInt(6) + 1);
  }

  // Function to handle the 'Go' button press
  void onGoPressed() {
    wager = int.tryParse(wagerController.text) ?? 0;

    // Check if wager is valid based on game type and wallet balance
    int maxWager = 0;
    switch (gameType) {
      case 2:
        maxWager = walletBalance ~/ 2; // Maximum wager for "2 Alike" = Balance ÷ 2
        break;
      case 3:
        maxWager = walletBalance ~/ 3; // Maximum wager for "3 Alike" = Balance ÷ 3
        break;
      case 4:
        maxWager = walletBalance ~/ 4; // Maximum wager for "4 Alike" = Balance ÷ 4
        break;
    }

    if (wager <= 0 || wager > walletBalance) {
      setState(() {
        gameResult = 'Invalid wager! Wager must be greater than 0 and less than or equal to your wallet balance.';
      });
      return;
    }

    if (wager > maxWager) {
      setState(() {
        gameResult = 'Invalid wager! Maximum wager for this game type is $maxWager coins.';
      });
      return;
    }

    // Generate the final dice rolls before starting the animation
    finalDiceRolls = rollDice(); // Store final dice rolls
    diceRolls = List.generate(4, (_) => Random().nextInt(6) + 1); // Initial random dice rolls for animation

    // Start the dice rolling animation
    _animationController.forward(from: 0);

    // After animation finishes, evaluate the result
    Future.delayed(Duration(seconds: 1), () {
      _animationController.stop();

      String result = checkWinOrLose(finalDiceRolls, gameType, wager);
      walletBalance = updateWalletBalance(result, walletBalance); // Update wallet balance

      // Store the result in the history list
      setState(() {
        history.insert(0, result);
        gameResult = result;
        diceRolls = finalDiceRolls;
      });
      wagerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stake Dice Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Wallet Balance: $walletBalance coins',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Image.asset('assets/coin.jpg', width: 30, height: 30),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: wagerController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter wager',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              DropdownButton<int>(
                value: gameType,
                items: [
                  DropdownMenuItem(value: 2, child: Text('2 Alike')),
                  DropdownMenuItem(value: 3, child: Text('3 Alike')),
                  DropdownMenuItem(value: 4, child: Text('4 Alike')),
                ],
                onChanged: (value) {
                  setState(() {
                    gameType = value!;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DiceImage(diceValue: diceRolls[index]),
                  );
                }),
              ),
              ElevatedButton(
                onPressed: onGoPressed,
                child: Text('Go'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  gameResult,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: gameResult.contains('Win') ? Colors.green : Colors.red,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'History:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              Expanded(child: HistoryList(history: history)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
