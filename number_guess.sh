#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESS_GAME() {
  TARGET=$[$RANDOM % 1000 + 1]

  echo -e "\n~~~~ Welcome to the Number Guessing Game ~~~~"
  echo -e "\nEnter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

  if [[ -z $USER_ID ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  else
    GAME_QUERY=$($PSQL "SELECT COUNT(game_id) AS num_games, MIN(num_guesses) AS best_game FROM games WHERE user_id=$USER_ID")
    GAMES_PLAYED=$(echo $GAME_QUERY | awk '{split($0, a, "|"); print a[1]}')
    BEST_GAME=$(echo $GAME_QUERY | awk '{split($0, a, "|"); print a[2]}')

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESS

  REGEX_NUM='^[0-9]+$'
  COUNT=1

  while true
  do
    if [[ $GUESS =~ $REGEX_NUM ]]
    then
      if [[ $GUESS -eq $TARGET ]]
      then
        break
      elif [[ $GUESS -gt $TARGET ]]
      then
        echo -e "\nIt's lower than that, guess again:"
      else
        echo -e "\nIt's higher than that, guess again:"
      fi
    else
      echo -e "\nThat is not an integer, guess again:"
    fi
    read GUESS
    ((COUNT++))
  done

  echo -e "\nYou guessed it in $COUNT tries. The secret number was $TARGET. Nice job!"
  INSERT_GAME_RECORD=$($PSQL "INSERT INTO games(user_id, num_guesses) VALUES ($USER_ID, $COUNT)")
}

GUESS_GAME
