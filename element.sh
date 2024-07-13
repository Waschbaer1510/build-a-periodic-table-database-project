#! /bin/bash


PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

VALIDATE_INFO() {
  if [[ -z $1 ]]
  then 
    echo -e "I could not find that element in the database."
    exit
  fi
}

FORMAT_STRING() {
  # this removes leading spaces
    local str="$1"
    str="$(echo "$str" | sed -r 's/^ *| *$//g')"
    echo "$str"
}

# check input arguments
if [[ -z $1 ]]
then
  # if no argument, print and finish
  echo -e "Please provide an element as an argument."
  exit
fi

# if input contains only a number then check the atomic_number column
if [[ $1 =~ ^[0-9]+$ ]]
then
  ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $1;")
  # if not found, exit function
  VALIDATE_INFO $ELEMENT_NAME
  ELEMENT_ID=$1
  ELEMENT_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ELEMENT_ID;")
else
  # elif input does not contain a number, check if symbol or name matches
  ELEMENT_ID=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1' OR symbol='$1';")
  # if not found, exit function
  VALIDATE_INFO $ELEMENT_ID
  ELEMENT_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ELEMENT_ID;")
  ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ELEMENT_ID;")
fi

# get properties
ELEMENT_TYPE=$($PSQL "SELECT type FROM properties INNER JOIN types USING(type_id) WHERE atomic_number = $ELEMENT_ID;")
ELEMENT_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ELEMENT_ID;")
ELEMENT_MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ELEMENT_ID;")
ELEMENT_BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ELEMENT_ID;")

# format strings
ELEMENT_ID_F=$(FORMAT_STRING "$ELEMENT_ID")
ELEMENT_SYMBOL_F=$(FORMAT_STRING "$ELEMENT_SYMBOL")
ELEMENT_NAME_F=$(FORMAT_STRING "$ELEMENT_NAME")
ELEMENT_TYPE_F=$(FORMAT_STRING "$ELEMENT_TYPE")
ELEMENT_MASS_F=$(FORMAT_STRING "$ELEMENT_MASS")
ELEMENT_MELTING_POINT_F=$(FORMAT_STRING "$ELEMENT_MELTING_POINT")
ELEMENT_BOILING_POINT_F=$(FORMAT_STRING "$ELEMENT_BOILING_POINT")

echo -e "The element with atomic number $ELEMENT_ID_F is $ELEMENT_NAME_F ($ELEMENT_SYMBOL_F). It's a $ELEMENT_TYPE_F, with a mass of $ELEMENT_MASS_F amu. $ELEMENT_NAME_F has a melting point of $ELEMENT_MELTING_POINT_F celsius and a boiling point of $ELEMENT_BOILING_POINT_F celsius."