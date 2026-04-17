#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICE_MENU() {
  # Print list of services
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id" | sed 's/|/) /g')"

  echo -e "\nPlease select a service:"
  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED=$(echo $SERVICE_ID_SELECTED | xargs)
  
  # Check if service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # If service doesn't exist
  if [[ -z $SERVICE_NAME ]]
  then
    echo "I could not find that service. Please choose again."
    SERVICE_MENU 
  else
    CUSTOMER_FLOW
  fi
  export SERVICE_ID_SELECTED
  export SERVICE_NAME
}
CUSTOMER_FLOW() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_PHONE=$(echo $CUSTOMER_PHONE | xargs)

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
  # If customer doesn't exist
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)
    
    # Insert new customer
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_ID=$(echo $CUSTOMER_ID | xargs)  
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  fi

  export CUSTOMER_ID
  export CUSTOMER_NAME
  APPOINTMENT_FLOW
}
APPOINTMENT_FLOW() {
  
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME
  SERVICE_TIME=$(echo $SERVICE_TIME | xargs)

  # Insert appointment
  INSERT_APPT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//')

  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}

SERVICE_MENU

