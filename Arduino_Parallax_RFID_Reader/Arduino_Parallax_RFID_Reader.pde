/**
 * author Benjamin Eckel
 * date 10-17-2009
 *
 * Minor edits by Riley Porter
 * 2-27-2011
 */
#define RFID_ENABLE 2   //to RFID ENABLE
#define CODE_LEN 10      //Max length of RFID tag
#define VALIDATE_TAG 1  //should we validate tag?
#define VALIDATE_LENGTH  200 //maximum reads b/w tag read and validate
#define ITERATION_LENGTH 2000 //time, in ms, given to the user to move hand away
#define START_BYTE 0x0A 
#define STOP_BYTE 0x0D
 
char tag[CODE_LEN];  
 
void setup() { 
  Serial.begin(2400);  
  pinMode(RFID_ENABLE,OUTPUT);   
}
 
void loop() {   //Start our main Arduino Loop
  enableRFID();   //Enable the RFID card
  getRFIDTag();   //Reads the tag
  if(isCodeValid()) {  //Validates that the tag is good
    disableRFID();  //Puts the RFID reader in to low power mode
    sendCode();     //Sends the code read to the serial port
    delay(ITERATION_LENGTH);  //Debounce?
  } else {
    disableRFID();  //Got a incomplete code.. 
    Serial.println("Got some noise");  
  }
  Serial.flush();
  clearCode();
} 
 
/**
 * Clears out the memory space for the tag to 0s.
 */
void clearCode() {
  for(int i=0; i<CODE_LEN; i++) {
    tag[i] = 0; 
  }
}
 
/**
 * Sends the tag to the computer.
 */ 
void sendCode() {
  //This is where I would add a return value (the code) to "validiate" or whatever at.
    Serial.print("TAG:");  

    char full_tag[10];
    for(int i=0; i<CODE_LEN; i++) {

      if (i == 9)  //Edits by riley porter
        Serial.println(tag[i]);  //This checks to see if its the last byte
      else                       //If it is it will print a "new line" so that the codes to jumble together
        Serial.print(tag[i]);  
      
    } 
}
 
/**************************************************************/
/********************   RFID Functions  ***********************/
/**************************************************************/
 
void enableRFID() {
   digitalWrite(RFID_ENABLE, LOW);    
}
 
void disableRFID() {
   digitalWrite(RFID_ENABLE, HIGH);  
}
 
/**
 * Blocking function, waits for and gets the RFID tag.
 */
void getRFIDTag() {
  byte next_byte; 
  while(Serial.available() <= 0) {}
  if((next_byte = Serial.read()) == START_BYTE) {      
    byte bytesread = 0; 
    while(bytesread < CODE_LEN) {
      if(Serial.available() > 0) { //wait for the next byte
          if((next_byte = Serial.read()) == STOP_BYTE) break;       
          tag[bytesread++] = next_byte;                   
      }
    }                
  }    
}
 
/**
 * Waits for the next incoming tag to see if it matches
 * the current tag.
 */
boolean isCodeValid() {
  byte next_byte; 
  int count = 0;
  while (Serial.available() < 2) {  //there is already a STOP_BYTE in buffer
    delay(1); //probably not a very pure millisecond
    if(count++ > VALIDATE_LENGTH) return false;
  }
  Serial.read(); //throw away extra STOP_BYTE
  if ((next_byte = Serial.read()) == START_BYTE) {  
    byte bytes_read = 0; 
    while (bytes_read < CODE_LEN) {
      if (Serial.available() > 0) { //wait for the next byte      
          if ((next_byte = Serial.read()) == STOP_BYTE) break;
          if (tag[bytes_read++] != next_byte) return false;                     
      }
    }                
  }
  return true;   
}
