#include <VirtualWire.h>
#include <stdlib.h> //Used for int to string
//Remote Mailbox Code

int TIMEOUT = 21600000;  //This is when, once your mail has been delivered your Arduino will start checking for mail again.
int THRESHOLD = 800; //This should be set to whatever value is best for YOUR mailbox.
//Experiment when this.  Set DEBUG to 1 and place the remote arduino into your mailbox.
//Note the values you get when its open and when its closed.  Then set THRESHOLD to your desire.

int sensorPin = A0;    // LDR sensor ping 
int sensorValue = 0;  // variable to store the value coming from the LDR sensor
int DEBUG;  //Set to 1 if you would like to echo all LDR readings locally
char  sens_string[4];  //Array to store the results of itoa (int to string)

void setup() {
  DEBUG = 0;
  // declare the ledPin as an OUTPUT:
    vw_setup(2000);

}

void loop() {
  //Start the main arduino loop
  
  sensorValue = analogRead(sensorPin);  // read the value from the sensor as a int
  if (DEBUG == 1) //If debug is set to 1 then echo the LDR values to the remote arduino and the local serial port
  {
    itoa(sensorValue, sens_string, 10);  //Takes an integer and returns a char array (sens_string)
    send(("Value: %s", sens_string));    //Send the transmission to the 
    Serial.println(("Value: %s", sens_string));  //Print the Value to the local Serial port also.
  }  
  
  if (DEBUG == 0)  //Only send the "mail is here" msg once threshold is met.
    {
      while (1)
      {
      sensorValue = analogRead(sensorPin);  // read the value from the sensor as a int
        
        if (sensorValue > THRESHOLD)  //If the light level gets higher than the THRESHOLD break the loop
          {

            break;
          }
         
         else //The mailbox is closed still.... 
           {
             send("No Mail Yet... Sleeping..\n");
             delay(60000); //Delay 10 minutes
           } 
      }
     send("Mail is here!");
     delay(TIMEOUT);  //Delay 6 hours... Then start the whole thing over again... 
   }    
  }



void send(char *message)
{
  vw_send((uint8_t *)message, strlen(message));  //virtual wire send message function 
  vw_wait_tx(); //Blocks til tx is done
}



