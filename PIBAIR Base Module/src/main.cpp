/** PIBAIR Base Microcontroller Code
 * Main file for the code that runs on the teency microcontroller in the cable encoder measurement device
 * Author: Benjamin Evans, University of Leeds
 * Date: Dec 2021
 */ 

// Libraries
#include <Arduino.h>

// Function Declarations
void wheelSpeed();

// Variables
const int ledPin = 13;
const byte LeftEncoderpinA = 2;//A pin -> the interrupt pin 0 
const byte LeftEncoderpinB = 3;//B pin -> the digital pin 4
byte LeftEncoderPinALast;
volatile long LeftDuration = 0;//the number of the pulses // Right
boolean LeftDirection;//the rotation direction
int interval = 0;
volatile long PrevLeftDuration = 0;


void setup(void) {
  LeftDirection = true;//default -> Forward
  pinMode(LeftEncoderpinB,INPUT);//  Left 
  attachInterrupt(2, wheelSpeed, CHANGE);

  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);
}

void loop() {
  Serial.println(-LeftDuration);

  delay(50);
  digitalWrite(ledPin, !digitalRead(ledPin));
}

void wheelSpeed() {
   int Lstate = digitalRead(LeftEncoderpinA);
  if((LeftEncoderPinALast == LOW) && Lstate==HIGH)
  {
    int val = digitalRead(LeftEncoderpinB);
    if(val == LOW && LeftDirection)
    {
      LeftDirection = false; //Reverse
    }
    else if(val == HIGH && !LeftDirection)
    {
      LeftDirection = true;  //Forward
    }
  }
  LeftEncoderPinALast = Lstate;

  if(!LeftDirection)  {
    LeftDuration--;
  
  }else  {
    LeftDuration++;
  }
}
