#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while IFS=" | " read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1|2|3|4|5) APPOINTMENT "$SERVICE_ID_SELECTED" ;;
    *) MAIN_MENU "I could not find that service. What would you like today?"
  esac
}

APPOINTMENT() {
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$1")
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo $CUSTOMER_ID
  # if customer not found
  if [[ -z $CUSTOMER_ID ]]
  then
    # add new customer
    echo -e "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  
  # make an appointment
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  echo -e "\nWhat time would you like your $(echo $SERVICE_SELECTED | sed 's/ //'), $(echo $CUSTOMER_NAME | sed 's/ //')?"
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  echo -e "\nI have put you down for a $(echo $SERVICE_SELECTED | sed 's/ //') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //')."
}

MAIN_MENU