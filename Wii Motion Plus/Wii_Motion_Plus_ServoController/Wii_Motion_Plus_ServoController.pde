/*Make Projects
Arduino Wii Motion Plus
This code is used for the Make Projects: Wii Motion Plus on the Arduino.

I could not verify the exact author as it looks to be a community driven effort.  See this link for more details:
http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1248889032/0

This code is rather advanced so be warned up front.  However if you just want to test out 2 servos and the wm+ then this
is a good start.

Trapezoid or Runge-kutta 4th order integration program of wm+
*/

#include <Streaming.h>
#include <Wire.h>
#include <Servo.h>

Servo yawServo;
Servo pitchServo;

int yawServoVal;
int pitchServoVal;

#define steps_per_deg_slow 20
#define steps_per_deg_fast 4

byte data[6];	    //six data bytes
int yaw, pitch, roll;  //three axes
int yaw0, pitch0, roll0;  //calibration zeroes
int time, last_time;
float delta_t;
int last_yaw[3], last_pitch[3], last_roll[3];
float yaw_deg, pitch_deg, roll_deg;
int yaw_deg2, pitch_deg2, roll_deg2;
int startTag=0xDEAD;
int accel_x_axis, accel_y_axis, accel_z_axis;

void wmpOn(){
  Wire.beginTransmission(0x53);    //WM+ starts out deactivated at address 0x53
  Wire.send(0xfe);		     //send 0x04 to address 0xFE to activate WM+
  Wire.send(0x04);
  Wire.endTransmission();	    //WM+ jumps to address 0x52 and is now active
}

void wmpSendZero(){
  Wire.beginTransmission(0x52);    //now at address 0x52
  Wire.send(0x00);		     //send zero to signal we want info
  Wire.endTransmission();
}

void calibrateZeroes(){
  for (int i=0;i<10;i++){
    wmpSendZero();
    Wire.requestFrom(0x52,6);
    for (int i=0;i<6;i++){
	data[i]=Wire.receive();
    }
    yaw0+=(((data[3]>>2)<<8)+data[0])/10;	  //average 10 readings for each zero
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
  wmpSendZero();			 //send zero before each request (same as nunchuck)
  Wire.requestFrom(0x52,6);	  //request the six bytes from the WM+
  for (int i=0;i<6;i++){
    data[i]=Wire.receive();
  }
  if(bitRead(data[3], 1)==1) yaw=(((data[3]>>2)<<8)+data[0]-yaw0)/steps_per_deg_slow;	  //see http://wiibrew.org/wiki/Wiimote/Extension_Controllers#Wii_Motion_Plus
  else yaw=(((data[3]>>2)<<8)+data[0]-yaw0)/steps_per_deg_fast;
  if(bitRead(data[3], 0)==1) pitch=(((data[4]>>2)<<8)+data[1]-pitch0)/steps_per_deg_slow;    //for info on what each byte represents
  else pitch=(((data[4]>>2)<<8)+data[1]-pitch0)/steps_per_deg_fast;
  if(bitRead(data[4], 1)==1) roll=(((data[5]>>2)<<8)+data[2]-roll0)/steps_per_deg_slow;
  else roll=(((data[5]>>2)<<8)+data[2]-roll0)/steps_per_deg_fast;
}

float trapIntegrate(int y2, int y1, float deltax){
  float area=0;
  area=(y2+y1)/2*deltax/1000;
  return area;
}

float rk4Integrate(int y4, int y3, int y2, int y1, float deltax){
  float area=0;
  area=((y4+2*y3+2*y2+y1)/6)*deltax/1000;
  return area;
}

void setup()
  {
  Serial.begin(115200);
  Serial.println("WM+ Tuning People Bot Control");
  Wire.begin();
  wmpOn();				//turn WM+ on
  calibrateZeroes();		  //calibrate zeroes
  delay(1000);

  yawServo.attach(2);
  pitchServo.attach(3);
  pinMode(4, INPUT);
  }

void loop(){
  receiveData();			//receive data and calculate yaw pitch and roll
  time=millis();
  delta_t=(time-last_time);

  /* Runge-kutta 4th Order Integration */
  yaw_deg+=rk4Integrate(yaw, last_yaw[0], last_yaw[1], last_yaw[2], delta_t);
  pitch_deg+=rk4Integrate(pitch, last_pitch[0], last_pitch[1], last_pitch[2], delta_t);
  roll_deg+=rk4Integrate(roll, last_roll[0], last_roll[1], last_roll[2], delta_t);
  last_yaw[2]=last_yaw[1];
  last_pitch[2]=last_pitch[1];
  last_roll[2]=last_roll[1];
  last_yaw[1]=last_yaw[0];
  last_pitch[1]=last_pitch[0];
  last_roll[1]=last_roll[0];
  last_yaw[0]=yaw;
  last_pitch[0]=pitch;
  last_roll[0]=roll;
  last_time=time;
  /* Runge-kutta 4th Order Integration */

  if (digitalRead(4) == 1)
    {
    last_yaw[2]=0;
    last_pitch[2]=0;
    last_roll[2]=0;
    last_yaw[1]=0;
    last_pitch[1]=0;
    last_roll[1]=0;
    last_yaw[0]=0;
    last_pitch[0]=0;
    last_roll[0]=0;
    yaw = 0;
    pitch = 0;
    roll = 0;
    yaw_deg = 0;
    pitch_deg = 0;
    roll_deg = 0;
    }

  yawServoVal = map(yaw_deg, -90, 90, 0, 179);
  if (yawServoVal < 0){yawServoVal = 0;};
  if (yawServoVal > 179){yawServoVal = 179;};
  yawServo.write(yawServoVal);

  pitchServoVal = map(pitch_deg, -90, 90, 0, 179);
  if (pitchServoVal < 60){pitchServoVal = 60;};
  if (pitchServoVal > 179){pitchServoVal = 179;};
  pitchServo.write(pitchServoVal);

  Serial<<yaw_deg<<"\t"<<pitch_deg<<"\t"<<roll_deg<<"\n";
  delay(10);
}


 


