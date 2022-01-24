/** PIBAIR Tether Microcontroller Code
 * Main file for the code that runs on the teency microcontroller that is on the tether up the pipe
 * author Benjamin Evans, University of Leeds
 * date Dec 2021
 */ 

//Libraries
#include <Arduino.h>
#include "ICM_20948.h"

//Definitions
#define SERIAL_PORT Serial
#define WIRE_PORT Wire 
#define AD0_VAL 1   
#define LOOPTIME  10

//Object Declarations 
ICM_20948_I2C myICM;

//Function Declarations 
void motor_drive();
void wheelSpeed();

//Variables
const int ledPin = 13;
double yaw = 0;
double pitch = 0;
double roll = 0;
const int M1A1 = 15;
const int M1A2 = 14;
int M1PWM1 = 0;
int M1PWM2 = 0;
unsigned long CurrentMillis = 0;
unsigned long PreviousMillis = 0;


const byte LeftEncoderpinA = 2;//A pin -> the interrupt pin 0 
const byte LeftEncoderpinB = 5;//B pin -> the digital pin 4
byte LeftEncoderPinALast;
volatile long LeftDuration = 0;//the number of the pulses // Right
boolean LeftDirection;//the rotation direction
int interval = 0;
volatile long PrevLeftDuration = 0;


void setup(void) {
  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);
  
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

  // Encoder Setup
  LeftDirection = true;//default -> Forward
  pinMode(LeftEncoderpinB,INPUT);//  Left 
  attachInterrupt(2, wheelSpeed, CHANGE);
}


void loop() {
  icm_20948_DMP_data_t data;
  myICM.readDMPdataFromFIFO(&data);
  CurrentMillis = millis();

  if (CurrentMillis - PreviousMillis >= LOOPTIME) {
    PreviousMillis = CurrentMillis;  
    if((myICM.status == ICM_20948_Stat_Ok) || (myICM.status == ICM_20948_Stat_FIFOMoreDataAvail)) {

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

        SERIAL_PORT.print(roll, 1);
        SERIAL_PORT.print(F(" "));
        SERIAL_PORT.print(pitch, 1);
        SERIAL_PORT.print(F(" "));
        SERIAL_PORT.print(yaw, 1);
        SERIAL_PORT.print(F(" "));
        
        LeftDuration = LeftDuration - PrevLeftDuration;
        PrevLeftDuration = LeftDuration;
        SERIAL_PORT.print(-LeftDuration);
        SERIAL_PORT.print((" "));
      }
    }
  }

  if (myICM.status != ICM_20948_Stat_FIFOMoreDataAvail) // If more data is available then we should read it right away - and not delay
  {
    delay(10);
  }
  
  
  digitalWrite(ledPin, !digitalRead(ledPin));
}

void motor_drive(){
  analogWrite(M1A1, 0);
  analogWrite(M1A2, 150); //Sets speed variable via PWM
}

void wheelSpeed()
{
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