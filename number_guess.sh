#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

R=$(($RANDOM%1001))
echo $R
echo Enter your username: 
read USERNAME

USER_ID="$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")"
if [[ -z $USER_ID ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  USER_INSERT="$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME');")"
  USER_ID="$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")"
else
  GAME_COUNT="$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")"
  GUESS_MIN="$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID;")"
  echo Welcome back, $USERNAME! You have played $GAME_COUNT games, and your best game took $GUESS_MIN guesses.
fi
echo Guess the secret number between 1 and 1000:
read GUESS
declare -i COUNT=1

while [ "$GUESS" != "$R" ]
do
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      COUNT=$COUNT+1
      read GUESS
  fi
  if [ $GUESS -lt $R ]
  then
    echo "It's higher than that, guess again:"
    COUNT=$COUNT+1
    read GUESS
  elif [ $GUESS -gt $R ]
  then
    echo "It's lower than that, guess again:"
    COUNT=$COUNT+1
    read GUESS
  fi
done

GAME_RESULT="$($PSQL "INSERT INTO games(user_id, guesses) VALUES ($USER_ID,$COUNT)")"
echo You guessed it in $COUNT tries.  The secret number was $GUESS, Nice job!
