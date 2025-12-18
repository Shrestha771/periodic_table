#!/bin/bash

# Set up PSQL command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

INPUT=$1

# Determine if input is a number (atomic_number) or text (symbol/name)
if [[ $INPUT =~ ^[0-9]+$ ]]
then
  # Input is atomic number
  # QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  #        FROM elements e
  #        JOIN properties p ON e.atomic_number = p.atomic_number
  #        JOIN types t ON p.type_id = t.type_id
  #        WHERE e.atomic_number = $INPUT;"
else
  # Input is symbol or name (case-insensitive)
  QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         JOIN properties p ON e.atomic_number = p.atomic_number
         JOIN types t ON p.type_id = t.type_id
         WHERE LOWER(e.symbol) = LOWER('$INPUT') OR LOWER(e.name) = LOWER('$INPUT');"
fi

RESULT=$($PSQL "$QUERY")

if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$RESULT"
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
fi
