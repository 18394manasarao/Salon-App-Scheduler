#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

# Display services
SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Prompt for service
echo -e "\nPlease select a service:"
read SERVICE_ID_SELECTED

# Check if service exists
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
if [[ -z $SERVICE_NAME ]]
then
  echo -e "\nInvalid service. Please try again."
  exec $0
fi

# Prompt for phone number
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
  # Prompt for name
  echo -e "\nIt looks like you are a new customer. Please enter your name:"
  read CUSTOMER_NAME
  # Insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Prompt for appointment time
echo -e "\nPlease enter the appointment time:"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Output confirmation
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
