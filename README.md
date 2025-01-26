# STAKE DICE GAME

A flutter/dart based application for modules of DevSoc(AppDev Vertical)

## CORE FEATURES

    A wallet balance is displayed and initialized to 10 coins.
    Users can enter a wager amount and select one of the following game types:
        "2 Alike": Win or lose 2x the wager.
        "3 Alike": Win or lose 3x the wager.
        "4 Alike": Win or lose 4x the wager.
    Check if the wager is valid based on the current wallet balance:
        Maximum wager for "2 alike" = Balance ÷ 2
        Maximum wager for "3 alike" = Balance ÷ 3
        Maximum wager for "4 alike" = Balance ÷ 4
    When the user presses the “Go” button:
        Roll four dice (generate random numbers between 1 and 6 for each dice).
        Display the result via a Toast message (showing the dice rolls and if the player won or lost).
        Update the wallet balance based on the result.
        Clear the wager input field.

### User Authentication:

    Implement Firebase Authentication to allow users to sign up, log in, and log out.
    Use email and password for authentication.
    Display the user's email on the main screen after logging in.

### Wallet Syncing with Firebase:

    Store each user's wallet balance in Firebase Realtime Database or Firestore.
    Fetch the wallet balance upon login and display it.
    Update the wallet balance in Firebase after each game round.

### Game History Storage:

    Save each user's game history (wager, dice rolls, outcome, and updated balance) in Firebase.
    Display the history in a dedicated screen.

## ADDED EXTRAS

History Screen: Show a history of past wagers, dice rolls, and outcomes.

Custom UI: Design a custom layout with images of dice and a creative interface.


## FUTURE POSSIBLE IMPLEMENTATIONS

Dice Animation: Adding animations when rolling the dice.

Sound Effects: Playing a sound when the dice are rolled.

    Leaderboards:
        Creating a global leaderboard showing top users with the highest wallet balances.
        Fetching and displaying the leaderboard data from Firebase.

    Google Sign-In:
        Allowing users to log in using Google Sign-In as an alternative to email/password authentication.

    Daily Rewards:
        Implementing a feature to grant users daily login rewards.
        Using Firebase to track when the reward was last claimed.

## THANKING NOTICE

Thanking AppDev community of DevSoc technical club

