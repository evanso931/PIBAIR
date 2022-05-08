/** PIBAIR Tether Microcontroller Code
 * Main file for the code that runs on the teency microcontroller that is on the tether up the pipe
 * author Benjamin Evans, University of Leeds
 * date Dec 2021
 */ 


//Libraries
#include <Arduino.h>
#include "ICM_20948.h"
#include <string>


//Definitions
#define SERIAL_PORT Serial
#define WIRE_PORT Wire 
#define AD0_VAL 1   
#define LOOPTIME  10


//Object Declarations 
ICM_20948_I2C myICM;


//Function Declarations 
void motor_drive();
void establishContact();
void motor_stop();
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

void setup(void) {
  //establishContact();  // establish handshake with device, repeatably send message till response
  SERIAL_PORT.begin(9600);
  pinMode(ledPin, OUTPUT);
  //pinMode(buttonPin, INPUT);

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

  if (Serial.available()) {
    
    val = Serial.readStringUntil('\n'); // read it and store it in val
    val.trim();
    
    for (int i = 0; i < 16; i++){
      stringPWM[i] = getValue(val, ':', i);
      intPWM[i] = stringPWM[i].toInt();
      analogWrite(i, intPWM[i]);
    }
  
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

            /* Send IMU and encoder values of serial port
            SERIAL_PORT.print(roll, 1);
            SERIAL_PORT.print(" ");
            SERIAL_PORT.print(pitch, 1);
            SERIAL_PORT.print(" ");
            SERIAL_PORT.println(yaw, 1);
            SERIAL_PORT.println(" ");
            */

            // Down
            if (pitch < - 50) {
              //if (current_direction != 0){
                SERIAL_PORT.println(0); 
                //current_direction = 0;
              //}
            // Up
            }else if (pitch> 50) {
              //if (current_direction != 1){
                SERIAL_PORT.println(1);
                //current_direction = 1;
              //}
            // Right
            }else if (yaw < - 45 && yaw > - 135) {
              //if (current_direction != 2){
                SERIAL_PORT.println(2);
                //current_direction = 2;
              //}
            // Left
            }else if (yaw > 45 && yaw < 135) {
              //if (current_direction != 3){
                SERIAL_PORT.println(3);
                //current_direction = 3;
              //}
            // Backward
            }else if (yaw > 135 || yaw < - 135) {
              //if (current_direction != 4){
                SERIAL_PORT.println(4);
                //current_direction = 4;
              //}
            // Forward
            } else if (yaw < 45 && yaw > - 45) {
              //if (current_direction != 5){
                SERIAL_PORT.println(5); 
                //current_direction = 5;
              //}
            }
          }
        }
      }
    }

    if (myICM.status != ICM_20948_Stat_FIFOMoreDataAvail) // If more data is available then we should read it right away - and not delay
    {
      delay(10);
    }
    
    //motor_stop();
  }

}

void motor_drive(){
  
  // M1
  analogWrite(0, 254);
  analogWrite(1, 0);

  // M2
  analogWrite(2, 254);
  analogWrite(3, 0);

  // M3
  analogWrite(4, 254);
  analogWrite(5, 0);

  // M4
  analogWrite(6, 254);
  analogWrite(7, 0);

  // M5
  analogWrite(8, 254);
  analogWrite(9, 0);

  // M6
  analogWrite(10, 254);
  analogWrite(11, 0);
  
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
}