//Make Projects
//Arduino Wii Motion Plus


#include <Wire.h>   //Arduino's Built in i2c Lib 
#include <Servo.h>  //Arduino's Built in Servo Lib

Servo pitchServo;
Servo yawServo;
Servo rollServo;

void setup() //Every Arduino Sketch has a setup() function.
             //This runs 1x at start up
{
  Serial.being(115200); //Start our Serial Port connection.
  Serial.println("Make Projects - Wii Motion Plus");
  Wire.begin();  //Initialize our i2c Connection.
}

void loop() //This function runs over and over.  This is the "main loop" 
            //Of Arduino Projects.
{

}

  
 
  
