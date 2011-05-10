#include <VirtualWire.h>
byte message[VW_MAX_MESSAGE_LEN];	// a buffer to hold the incoming messages b
byte msgLength = VW_MAX_MESSAGE_LEN; // the size of the message
void setup()
{
  Serial.begin(9600);
  Serial.println("Ready");
  // Initialize the IO and ISR 
  vw_setup(2000);	// Bits per sec   
  vw_rx_start();	// Start the receiver
}

void loop()
{
  if (vw_get_message(message, &msgLength)) // Non-blocking 
    {
      Serial.print("Got: "); 
      for (int i = 0; i < msgLength; i++) 
        {
          Serial.write(message[i]);
        } 
  
      Serial.println(); 
    }
 }

