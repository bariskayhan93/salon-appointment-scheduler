#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"


MAIN_MENU(){

  # display argument if exist
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  if [[ -z $SERVICES ]]
  then "Sorry, we dont have any :("
  else
    # show service menu
    echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
    do
      echo "$SERVICE_ID)" "$NAME"
    done

    read SERVICE_ID_SELECTED
    #if input is not INT
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
      then
      MAIN_MENU "That is not a number"
      else
        SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id =$SERVICE_ID_SELECTED;")
        SERVICE_AVAILABLE_NAME=$($PSQL "SELECT name FROM services WHERE service_id =$SERVICE_ID_SELECTED;")
        #if the number input not found
        if [[ -z $SERVICE_AVAILABLE ]]
         then
          # return to main menu
          MAIN_MENU "I could not find that service. What would you like today?"
          else
          # if a valid option
          # ask for phone number
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone ='$CUSTOMER_PHONE'")
          # if customer not found
          if [[ -z $CUSTOMER_NAME ]]
          then
            # ask for customer name
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            # insert customer data
            UPDATE_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

          fi
         # add appointment time
         echo -e "\nWhat time would you like your $(echo $SERVICE_AVAILABLE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
         read SERVICE_TIME
         CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE';")
         echo $CUSTOMER_ID
         echo $CUSTOMER_PHONE
         # if no time input
         if [[ $SERVICE_TIME ]]
          then
            #insert appointment
            APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_AVAILABLE, '$SERVICE_TIME')")
          if [[ $APPOINTMENT_RESULT=='INSERT 0 1' ]]
          then
            echo -e "\nI have put you down for a $(echo $SERVICE_AVAILABLE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
          else
            MAIN_MENU "Unexpected error occur, please try again."
          fi
        fi
      fi
    fi
  fi
}

MAIN_MENU
