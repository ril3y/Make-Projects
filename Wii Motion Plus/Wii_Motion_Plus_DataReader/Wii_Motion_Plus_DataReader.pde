/*
Make Projects
 Arduino Wii Motion Plus Data Reader
 This code is used for the Make Projects: Wii Motion Plus on the Arduino.
 Miles code did not include a license however we would like to thank him for posting it!
 
 Author:  Miles Moody
 Home Page:
 http://randomhacksofboredom.blogspot.com/2009/07/motion-plus-and-nunchuck-together-on.html
 */

#include <Wire.h>

byte data[6];          //six data bytes
int yaw, pitch, roll;  //three axes
int yaw0, pitch0, roll0;  //calibration zeroes

void wmpOn(){
  Wire.beginTransmission(0x53);    //WM+ starts out deactivated at address 0x53
  Wire.send(0xfe);                 //send 0x04 to address 0xFE to activate WM+
  Wire.send(0x04);
  Wire.endTransmission();          //WM+ jumps to address 0x52 and is now active
}

void wmpSendZero(){
  Wire.beginTransmission(0x52);    //now at address 0x52
  Wire.send(0x00);                 //send zero to signal we want info
  Wire.endTransmission();
}

void calibrateZeroes(){
  for (int i=0;i<10;i++){
    wmpSendZero();
    Wire.requestFrom(0x52,6);
    for (int i=0;i<6;i++){
      data[i]=Wire.receive();
    }
    yaw0+=(((data[3]>>2)<<8)+data[0])/10;        //average 10 readings for each zero
    pitch0+=(((data[4]>>2)<<8)+data[1])/10;
    roll0+=(((data[5]>>2)<<8)+data[2])/10;
  }
  Serial.print("Yaw0:");
  Serial.print(yaw0);
  Serial.print("  Pitch0:");
  Serial.print(pitch0);
  Serial.print("  Roll0:");
  Serial.println(roll0);
}

void receiveData(){
  wmpSendZero();                   //send zero before each request (same as nunchuck)
  Wire.requestFrom(0x52,6);        //request the six bytes from the WM+
  for (int i=0;i<6;i++){
    data[i]=Wire.receive();
  }
  yaw=((data[3]>>2)<<8)+data[0]-yaw0;        //see http://wiibrew.org/wiki/Wiimote/Extension_Controllers#Wii_Motion_Plus
  pitch=((data[4]>>2)<<8)+data[1]-pitch0;    //for info on what each byte represents
  roll=((data[5]>>2)<<8)+data[2]-roll0;      
}

void setup(){
  Serial.begin(115200);
  Serial.println("WM+ tester");
  Wire.begin();
  wmpOn();                        //turn WM+ on
  calibrateZeroes();              //calibrate zeroes
  delay(1000);
}

void loop(){
  receiveData();                  //receive data and calculate yaw pitch and roll
  Serial.print("yaw:");           //see diagram on randomhacksofboredom.blogspot.com
  Serial.print(yaw);              //for info on which axis is which
  Serial.print("  pitch:");
  Serial.print(pitch);
  Serial.print("  roll:");
  Serial.println(roll);
  delay(100);
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



