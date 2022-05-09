/** PIBAIR Tether Microcontroller Code
 * Main file for the code that runs on the teency microcontroller that is on the tether up the pipe
 * Author: Benjamin Evans, University of Leeds
 * Date: Dec 2021
 */ 


// Libraries
#include <Arduino.h>
#include "ICM_20948.h"
#include <string>


// Definitions
#define SERIAL_PORT Serial
#define WIRE_PORT Wire 
#define AD0_VAL 1   
#define LOOPTIME  10


// Object Declarations 
ICM_20948_I2C myICM;


// Function Declarations 
void establishContact();
void initialiseMotors();
void moveMotors78();
String getValue(String data, char separator, int index);

//Variables
const int ledPin = 13;
double yaw = 0;
double pitch = 0;
double roll = 0;
unsigned long CurrentMillis = 0;
unsigned long PreviousMillis = 0;
byte analogPin = 0;
boolean ledState = LOW; //toggle LED
String val; 
int current_direction = 7;
int val1;
String stringPWM [16] = 0;
int intPWM [16] = {0};

// Motor initialisation Variables
int apin = 12;
int bpin = 13;
int switchPinA = 20;
int switchPinB = 21;
int switchInput;
int readOpen;
int readClosed;
int buttonPress;
int pwm1 = 255;


void setup(void) {
  SERIAL_PORT.begin(9600);
  pinMode(ledPin, OUTPUT);
  pinMode(switchPinA, INPUT);
  pinMode(switchPinB, INPUT);

  delay(100);
  
  // IMU Setup
  WIRE_PORT.begin();
  WIRE_PORT.setClock(400000);
  myICM.begin(WIRE_PORT, AD0_VAL);
  bool success = true;
  success &= (myICM.initializeDMP() == ICM_20948_Stat_Ok); 
  success &= (myICM.enableDMPSensor(INV_ICM20948_SENSOR_GAME_ROTATION_VECTOR) == ICM_20948_Stat_Ok);
  success &= (myICM.setDMPODRrate(DMP_ODR_Reg_Quat6, 0) == ICM_20948_Stat_Ok);
  success &= (myICM.enableFIFO() == ICM_20948_Stat_Ok);
  success &= (myICM.enableDMP() == ICM_20948_Stat_Ok);
  success &= (myICM.resetDMP() == ICM_20948_Stat_Ok);
  success &= (myICM.resetFIFO() == ICM_20948_Stat_Ok);

  establishContact();
}


void loop() {
  icm_20948_DMP_data_t data;
  myICM.readDMPdataFromFIFO(&data);
  CurrentMillis = millis();

  // Read PWM values from processing 
  if (Serial.available()) {
    
    val = Serial.readStringUntil('\n'); // read it and store it in val
    val.trim();
    
    for (int i = 0; i < 16; i++){
      stringPWM[i] = getValue(val, ':', i);
      intPWM[i] = stringPWM[i].toInt();
      analogWrite(i, intPWM[i]);
    }
  
  // Send IMU direction values to processing 
  }else { 
    if (CurrentMillis - PreviousMillis >= LOOPTIME) {
      PreviousMillis = CurrentMillis;  
      if((myICM.status == ICM_20948_Stat_Ok) || (myICM.status == ICM_20948_Stat_FIFOMoreDataAvail)) {
        digitalWrite(ledPin, !digitalRead(ledPin));
        if ((data.header & DMP_header_bitmap_Quat6) > 0) {
          //Read IMU
          double q1 = ((double)data.Quat6.Data.Q1) / 1073741824.0; // Convert to double. Divide by 2^30
          double q2 = ((double)data.Quat6.Data.Q2) / 1073741824.0; // Convert to double. Divide by 2^30
          double q3 = ((double)data.Quat6.Data.Q3) / 1073741824.0; // Convert to double. Divide by 2^30

          // Convert the quaternions to Euler angles (roll, pitch, yaw)
          // https://en.wikipedia.org/w/index.php?title=Conversion_between_quaternions_and_Euler_angles&section=8#Source_code_2

          double q0 = sqrt(1.0 - ((q1 * q1) + (q2 * q2) + (q3 * q3)));

          double q2sqr = q2 * q2;

          // roll (x-axis rotation)
          double t0 = +2.0 * (q0 * q1 + q2 * q3);
          double t1 = +1.0 - 2.0 * (q1 * q1 + q2sqr);
          roll = atan2(t0, t1) * 180.0 / PI;

          // pitch (y-axis rotation)
          double t2 = +2.0 * (q0 * q2 - q3 * q1);
          t2 = t2 > 1.0 ? 1.0 : t2;
          t2 = t2 < -1.0 ? -1.0 : t2;
          pitch = asin(t2) * 180.0 / PI;

          // yaw (z-axis rotation)
          double t3 = +2.0 * (q0 * q3 + q1 * q2);
          double t4 = +1.0 - 2.0 * (q2sqr + q3 * q3);
          yaw = atan2(t3, t4) * 180.0 / PI;
          

          if (SERIAL_PORT.available() > 0) { // If data is available to read,
            val = SERIAL_PORT.read(); // read it and store it in val
            if(val == '1') {
              ledState = !ledState; //flip the ledState
              digitalWrite(ledPin, ledState); 
            }
          } else {

            // Down
            if (pitch < - 50) {
                SERIAL_PORT.println(0); 
                
            // Up
            }else if (pitch> 50) {
                SERIAL_PORT.println(1);

            // Right
            }else if (yaw < - 45 && yaw > - 135) {
                SERIAL_PORT.println(2);
               
            // Left
            }else if (yaw > 45 && yaw < 135) {
                SERIAL_PORT.println(3);
                
            // Backward
            }else if (yaw > 135 || yaw < - 135) {            
                SERIAL_PORT.println(4);

            // Forward
            } else if (yaw < 45 && yaw > - 45) {
                SERIAL_PORT.println(5); 
            }
          }
        }
      }
    }

    if (myICM.status != ICM_20948_Stat_FIFOMoreDataAvail) // If more data is available then we should read it right away - and not delay
    {
      delay(10);
    }
  }
}

String getValue(String data, char separator, int index)
{
    int found = 0;
    int strIndex[] = { 0, -1 };
    int maxIndex = data.length() - 1;

    for (int i = 0; i <= maxIndex && found <= index; i++) {
        if (data.charAt(i) == separator || i == maxIndex) {
            found++;
            strIndex[0] = strIndex[1] + 1;
            strIndex[1] = (i == maxIndex) ? i+1 : i;
        }
    }
    return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}

void establishContact() {
  while (Serial.available() <= 0) {
  Serial.println("A");   // send a capital A
  delay(300);
  }
  //initialiseMotors();
}

void initialiseMotors(){

  if (readClosed ==  0 && readOpen == 0) {
    // if PinA - done
    // start motor
    analogWrite(apin, pwm1);
    analogWrite(bpin, 0); //Sets speed variable via PWM

    // wait for contact 
    while (readOpen == 0) {
      readOpen= digitalRead(switchPinA); // pin 20
       Serial.print("Open = ");
       Serial.println(readOpen);
      readClosed= digitalRead(switchPinB); // pin 21
       Serial.print("Closed = "); 
       Serial.println(readClosed);
      if (readClosed == 1) {
        // stop motor
         analogWrite(apin, 0);
         analogWrite(bpin, 0); 
        break;
      }
    }
     analogWrite(apin, 0);
     analogWrite(bpin, 0); 

    // if PinB run opposite until PinA
    if (readClosed ==  1) {
      // states
      delay(5);
       Serial.println("Legs closed");
       Serial.print("Open = ");
       Serial.println(readOpen);
       Serial.print("Closed = "); 
       Serial.println(readClosed);

      // start motor
       analogWrite(apin, 0);
       analogWrite(bpin, pwm1); //Sets speed variable via PWM

      // wait for contact - Want to start open 
      while (readOpen == 0) {
        readOpen= digitalRead(switchPinA); // pin 22
        // Serial.print("Open = "); Serial.println(readOpen);
      }

      // stop motor
       analogWrite(apin, 0);
       analogWrite(bpin, 0);
    }
  }
  if (readClosed ==  1) {
    // states
     Serial.println("Legs closed");
     Serial.print("Open = ");
     Serial.println(readOpen);
     Serial.print("Closed = "); 
     Serial.println(readClosed);

    // start motor
     analogWrite(apin, pwm1);
     analogWrite(bpin, 0); //Sets speed variable via PWM

    // wait for contact - Want to start open 
    while (readOpen == 0) {
      readOpen= digitalRead(switchPinA); // pin 22
      // Serial.print("Open = "); Serial.println(readOpen);
    }

    // stop motor
     analogWrite(apin, 0);
     analogWrite(bpin, 0);
  }
}

void moveMotors78(){
  
  // setup write pin
   analogWrite(apin, 0);
   analogWrite(bpin, 0);

  // set up read pins
  readOpen= digitalRead(switchPinA); // pin 22
  readClosed= digitalRead(switchPinB); // pin 23

  Serial.print("Button = ");
  Serial.println(buttonPress);

  // check gates are working
  //print("Open = ");println(readOpen);
  //print("Closed = "); println(readClosed);

  if (buttonPress == 1) {
    if (readClosed == 1) {
      // states
       Serial.println("Legs closed");
       Serial.print("Open = ");
       Serial.println(readOpen);
       Serial.print("Closed = "); 
       Serial.println(readClosed);

      // start motor
       analogWrite(apin, pwm1);
       analogWrite(bpin, 0); //Sets speed variable via PWM

      // wait for contact 
      while (readOpen == 0) {
        readOpen= digitalRead(switchPinA); // pin 22
         Serial.print("Open = ");
         Serial.println(readOpen);
      }

      // stop motor
       analogWrite(apin, 0);
       analogWrite(bpin, 0);
    }
    if (readOpen == 1) {
       Serial.println("Legs Open");
       Serial.print("Open = "); 
       Serial.println(readOpen);
       Serial.print("Closed = ");
       Serial.println(readClosed);

      // start motor
       analogWrite(apin, 0);
       analogWrite(bpin, pwm1); //Sets speed variable via PWM

      // wait for contact 
      while (readClosed == 0) {
        readClosed= digitalRead(switchPinB); // pin 22
         Serial.print("Closed = ");
         Serial.println(readClosed);
      }

      // stop motor
       analogWrite(apin, 0);
       analogWrite(bpin, 0);
    }
  }
}