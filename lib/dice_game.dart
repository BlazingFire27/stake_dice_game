import 'package:flutter/material.dart';
import 'dart:math';
import 'dice_image.dart';
import 'game_result.dart';
import 'history_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class DiceGame extends StatefulWidget {
  const DiceGame({super.key});

  @override
  _DiceGameState createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> with SingleTickerProviderStateMixin {
  int walletBalance = 10; // Default wallet balance, will update after fetching from Firebase
  TextEditingController wagerController = TextEditingController();
  int wager = 0;
  int gameType = 2; // Default to "2 Alike"
  List<int> diceRolls = [1, 1, 1, 1];
  List<int> finalDiceRolls = [1, 1, 1, 1];
  late AnimationController _animationController;
  String gameResult = '';
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fetchWalletBalance(); // Fetch wallet balance when the game starts
    _fetchHistory(); // Fetch game history when the game starts
  }

  List<int> rollDice() {
    Random random = Random();
    return List.generate(4, (_) => random.nextInt(6) + 1);
  }

  // Fetch wallet balance from Firebase
  Future<void> _fetchWalletBalance() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Fetch the document of the current user
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            walletBalance = userDoc['walletBalance'] ?? 10; // Default to 10 if not found
          });
          print("Fetched wallet balance: $walletBalance");
        }
      } catch (e) {
        print("Error fetching wallet balance: $e");
      }
    }
  }

  // Fetch game history from Firebase
  Future<void> _fetchHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot historySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('gameHistory')
            .orderBy('timestamp', descending: true)
            .get();
        setState(() {
          history = historySnapshot.docs.map((doc) => doc['result'] as String).toList();
        });
      } catch (e) {
        print("Error fetching game history: $e");
      }
    }
  }

  // Update wallet balance in Firebase using `set` to ensure it's updated correctly
  Future<void> _updateWalletBalance(int updatedBalance) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Use 'set' to ensure that the walletBalance is updated properly
        await userDocRef.set({'walletBalance': updatedBalance}, SetOptions(merge: true));

        // Fetch updated balance to reflect on the app
        await _fetchWalletBalance();
        print("Wallet balance updated to: $updatedBalance");
      } catch (e) {
        print("Error updating wallet balance: $e");
      }
    }
  }

  Future<void> _saveGameHistory(String result) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('gameHistory').add({
          'result': result,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error saving game history: $e");
      }
    }
  }

  void onGoPressed() {
    wager = int.tryParse(wagerController.text) ?? 0;
    int maxWager = walletBalance ~/ 2;

    if (wager <= 0 || wager > walletBalance) {
      setState(() {
        gameResult = 'Invalid wager! Wager must be greater than 0 and less than or equal to your wallet balance.';
      });
      return;
    }

    if (wager > maxWager) {
      setState(() {
        gameResult = 'Wager exceeds the maximum allowed wager of $maxWager coins.';
      });
      return;
    }

    finalDiceRolls = rollDice();
    diceRolls = List.generate(4, (_) => Random().nextInt(6) + 1);
    _animationController.forward(from: 0);

    Future.delayed(const Duration(seconds: 1), () {
      _animationController.stop();
      String result = checkWinOrLose(finalDiceRolls, gameType, wager);
      walletBalance = updateWalletBalance(result, walletBalance);
      _updateWalletBalance(walletBalance); // Update Firebase with new balance
      _saveGameHistory(result); // Save game result to Firebase

      setState(() {
        history.insert(0, result);
        gameResult = result;
        diceRolls = finalDiceRolls;
      });
      wagerController.clear();
    });
  }

  // Handle logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stake Dice Game', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout), // Logout button functionality
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
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
                  Text('Wallet Balance: $walletBalance coins', style: const TextStyle(fontSize: 24, color: Colors.white)),
                  const SizedBox(width: 10),
                  Image.asset('assets/coin.jpg', width: 30, height: 30),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: wagerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter wager', filled: true, fillColor: Colors.white),
              ),
              DropdownButton<int>(
                value: gameType,
                items: const [
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
              ElevatedButton(onPressed: onGoPressed, child: const Text('Go')),
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
              const SizedBox(height: 20),
              const Text(
                'History:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
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
