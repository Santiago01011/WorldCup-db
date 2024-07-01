#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams CASCADE")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;")
declare -A teams

while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  if [[ $WINNER != "winner" ]]; then
    # Agregar los equipos ganadores y oponentes al array
    teams["$WINNER"]=1
    teams["$OPPONENT"]=1
  fi
done < games.csv
  for TEAM in "${!teams[@]}"
  do
    #obtener team_id del equipo
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")

    #si no existe
    if [[ -z $TEAM_ID ]]; then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]; then
        echo "Inserted into teams, $TEAM"
      fi
    fi
  done
  echo "Equipos únicos insertados en la tabla teams."