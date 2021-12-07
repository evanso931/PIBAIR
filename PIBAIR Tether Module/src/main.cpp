/** PIBAIR Tether Microcontroller Code
 * Main file for the code that runs on the teency microcontroller that is on the tether
 * author Benjamin Evans, University of Leeds
 * date Dec 2021
 */ 

//Libraries
#include <Arduino.h>
#include <FlexCAN_T4.h>
#include "ICM_20948.h"

//Definitions
#define SERIAL_PORT Serial
#define WIRE_PORT Wire 
#define AD0_VAL 1   

//Object Declarations 
FlexCAN_T4<CAN1, RX_SIZE_256, TX_SIZE_16> can1;
FlexCAN_T4<CAN2, RX_SIZE_256, TX_SIZE_16> can2;
CAN_message_t msg;
ICM_20948_I2C myICM;

//Function Declarations 
void read_can_bus();
void imu_to_can_buf();
void can_buf_to_imu();
void motor_drive();


//Variables
const int ledPin = 13;
int can_mesage_length = 9;
double yaw = 0;
double pitch = 0;
double roll = 0;
const int M1A1 = 10;
const int M1A2 = 11;
int M1PWM1;
int M1PWM2;


void setup(void) {

  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);
  

  // IMU setup
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

  // CAN bus setup 
  can1.begin();
  can1.setBaudRate(125000);
  can2.begin();
  can2.setBaudRate(125000);
  
}


void loop() {
  icm_20948_DMP_data_t data;
  myICM.readDMPdataFromFIFO(&data);

  msg.len = can_mesage_length;
  msg.id = 5;
 
  
  if((myICM.status == ICM_20948_Stat_Ok) || (myICM.status == ICM_20948_Stat_FIFOMoreDataAvail)) {
    //static uint32_t prev_ms = millis();

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

      Serial.print(F("Roll:"));
      Serial.print(roll, 1);
      Serial.print(F(" Pitch:"));
      Serial.print(pitch, 1);
      Serial.print(F(" Yaw:"));
      Serial.print(yaw, 1);

      // CAN messaging

      static uint32_t prev_ms = millis();
      if (millis() > prev_ms + 25) {
        imu_to_can_buf();
        can1.write(msg);
        can_buf_to_imu();
        digitalWrite(ledPin, !digitalRead(ledPin));
      }
    }
  }
  

  if (myICM.status != ICM_20948_Stat_FIFOMoreDataAvail) // If more data is available then we should read it right away - and not delay
  {
    delay(10);
  }

  //motor_drive();
  
}

void imu_to_can_buf(){
  int temp_array[9] = { };
  
  float imu_values [3] = { }; 
  imu_values[0] = roll;
  imu_values[1] = pitch;
  imu_values[2] = yaw;

  // Splits number into inter, decimal and minus
  for(int i = 0; i < 3; i++){
    if (imu_values[i] < 0){
    temp_array[i*3] = 1;
    temp_array[(1+i*3)] = imu_values[i]*-1; 
    
    int int_number = imu_values[i];
    temp_array[2+i*3] = (imu_values[i] - int_number)*-100;
    } else {
    temp_array[i*3] = 0;
    temp_array[(1+i*3)] = imu_values[i];

    int int_number = imu_values[i];
    temp_array[2+i*3] = (imu_values[i] - int_number)*100;
    }

  
  }
  
  // Fills can message buffer with the number
  for (int i = 0; i <= can_mesage_length; i++){
    msg.buf[i] = temp_array[i];  
  }
}

void can_buf_to_imu(){
  float imu_values [3] = { };

  for (int i = 0; i < 3; i++ ) {
    if (msg.buf[i*3] == 1){
    float decimal_minus = msg.buf[i*3+2];
    imu_values[i] = (msg.buf[i*3+1]*-1) + decimal_minus/100;

    }else {
    float decimal_plus = msg.buf[i*3+2];
    imu_values[i] = msg.buf[i*3+1] + decimal_plus/100;
    }
  }
  Serial.print("    roll = ");
  Serial.print(imu_values[0]);
  Serial.print(", pitch = ");
  Serial.print(imu_values[1]);
  Serial.print(", yaw = ");
  Serial.println(imu_values[2]);
}

void read_can_bus(){
  if (can2.read(msg) ) {
    Serial.print("CAN2 "); 
    Serial.print("MB: "); Serial.print(msg.mb);
    Serial.print("  ID: 0x"); Serial.print(msg.id, HEX );
    Serial.print("  EXT: "); Serial.print(msg.flags.extended );
    Serial.print("  LEN: "); Serial.print(msg.len);
    Serial.print(" DATA: ");

    for (uint8_t i = 0; i < can_mesage_length; i++ ) {
      Serial.print(msg.buf[i]); Serial.print(" ");
    }

    Serial.print("  TS: "); Serial.println(msg.timestamp);
  }
}

void motor_drive(){
  
  //println(pwm1);
  analogWrite(M1A1, 0);
  analogWrite(M1A1, 250); //Sets speed variable via PWM

}