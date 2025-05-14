#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~~ MY SALON ~~~~~"
echo -e "\n Welcome to My Salon, how can I help you?\n"

CUSTOMER_NAME=""
CUSTOMER_PHONE=""
SERVICES=$($PSQL "SELECT service_id, name FROM services;")

LIST_SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME Service"
  done
  # Get input from user
  read SERVICE_ID_SELECTED
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
     LIST_SERVICES "\nI could not find that service. What would you like today?"
  else
    HAVE_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    if [[ -z $HAVE_SERVICE ]]
    then 
      LIST_SERVICES "\nI could not find that service. What would you like today?"
    else
      MAIN_MENU
    fi
  fi
}

CREATE_APPOINTMENT() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  CUST_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_NAME_FROMATTED=$(echo $SERVICE_NAME | sed 's/ //g')
  CUST_NAME_FROMATTED=$(echo $CUST_NAME | sed 's/ //g')
  echo -e "\nWhat time would you like your $SERVICE_NAME_FROMATTED, $CUST_NAME_FROMATTED?"
  read SERVICE_TIME
  INSERTED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUST_ID','$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME_FROMATTED at $SERVICE_TIME, $CUST_NAME_FROMATTED."
}

MAIN_MENU() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  HAVE_CUSTOMER=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
 
  if [[ -z $HAVE_CUSTOMER ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # Adding customer to database
    INSERTED=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CREATE_APPOINTMENT
  else 
    CREATE_APPOINTMENT
  fi
}

# Start the script by listing services
LIST_SERVICES
