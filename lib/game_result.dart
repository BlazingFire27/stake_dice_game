String checkWinOrLose(List<int> diceRolls, int gameType, int wager) {
  Map<int, int> frequency = {};
  for (var die in diceRolls) {
    frequency[die] = (frequency[die] ?? 0) + 1;
  }

  bool win = false;
  int coinsChanged = 0;

  switch (gameType) {
    case 2:
      win = frequency.values.any((count) => count >= 2);
      coinsChanged = win ? wager * 2 : -wager;
      break;
    case 3:
      win = frequency.values.any((count) => count >= 3);
      coinsChanged = win ? wager * 3 : -wager;
      break;
    case 4:
      win = frequency.values.any((count) => count == 4);
      coinsChanged = win ? wager * 4 : -wager;
      break;
  }

  return win ? 'You Win $coinsChanged coins' : 'You Lose $coinsChanged coins';
}

// Update wallet balance and return the updated balance
int updateWalletBalance(String result, int walletBalance) {
  int coinsChanged = int.parse(result.split(' ')[2]);
  return walletBalance + coinsChanged;
}
