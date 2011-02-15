/*
Make Projects
Arduino Wii Motion Plus Data Reader
This program initializes the Wii Motion Plus, calibrates the gyros at startup.
Once the wm+ is setup it will print out 3 axis gyroscope data to the serial port.


*/

#include <Wire.h>


void setup()
{
  Serial.begin(115200);              //Setup the serial port 
  Serial.println("Make Projets");    //Write our program start message
  Serial.println("Wii Motion Plus Data Reader");
  delay(4);   //Pause for a short delay;
}



void loop() 
{
  
}





/*
Additional Reading:
The wii motion plus's initialization sequence was pull from here:
http://wiibrew.org/wiki/Wiimote/Extension_Controllers#Wii_Motion_Plus

The data format is well documented here:
http://wiibrew.org/wiki/Wiimote/Extension_Controllers#Data_Format_.28Wii_Motion_Plus.29

More pinout diagrams can be found here:
http://wiibrew.org/wiki/Wiimote/Extension_Controllers#Hardware_.28Wii_Motion_Plus.29
*/


