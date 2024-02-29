#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

# select a service
SERVICE_MENU(){
  echo -e "$1"
  echo "$($PSQL "SELECT * FROM SERVICES;")" | while read SERVICE_ID BAR SERVICE
  do 
    if [[ SERVICE_ID != 'service_id' && ! SERVICE_ID =~ ^-*$ ]]
    then
      echo -e "$SERVICE_ID) $SERVICE";
    fi
  done
}

echo "What service would you like to have?"
SERVICE_MENU
read SERVICE_ID_SELECTED

#get service name
SERVICE_NAME=$($PSQL "SELECT NAME FROM SERVICES WHERE SERVICE_ID=$SERVICE_ID_SELECTED");
echo $SERVICE_NAME

# if service does not exists
if [[ -z $SERVICE_NAME ]]
then
  SERVICE_MENU "PLEASE SELECT A VALID SERVICE"
else
  #get phone number
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  # get customer name
  CUSTOMER_NAME=$($PSQL "SELECT NAME FROM CUSTOMERS WHERE PHONE='$CUSTOMER_PHONE';")
  echo $CUSTOMER_NAME

  # if customer does not exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get customer_name
    echo -e "\nWhat is your name?" 
    read CUSTOMER_NAME

    # insert customer
    CUSTOMER_INSERTION_RESULT=$($PSQL "INSERT INTO CUSTOMERS(NAME, PHONE) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  fi
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT CUSTOMER_ID FROM CUSTOMERS WHERE PHONE='$CUSTOMER_PHONE'");
  echo $CUSTOMER_ID

  # time
  echo -e "\nWhat is your preferred time for service?" 
  read SERVICE_TIME

  APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO APPOINTMENTS(CUSTOMER_ID, SERVICE_ID, TIME) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')");

  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *//g')."
fi
