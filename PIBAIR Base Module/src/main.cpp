/** PIBAIR Base Microcontroller Code
 * Main file for the code that runs on the teency microcontroller that at the base of the tether plugged into the computer 
 * author Benjamin Evans, University of Leeds
 * date Dec 2021
 */ 

//Libraries
#include <FlexCAN_T4.h>


//Object Declarations 
FlexCAN_T4<CAN1, RX_SIZE_256, TX_SIZE_16> can1;
FlexCAN_T4<CAN2, RX_SIZE_256, TX_SIZE_16> can2;
CAN_message_t msg, msg_motor;


//Function Declarations 
void read_can_bus();
void can_buf_to_imu();


//Variables
const int ledPin = 13;


void setup(void) {
  can1.begin();
  can1.setBaudRate(125000);
  can2.begin();
  can2.setBaudRate(125000);

  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);
}

void loop() {
  
if (can1.read(msg) ) {
    Serial.print("CAN1"); 
    Serial.print("MB: "); Serial.print(msg.mb);
    Serial.print("  ID: 0x"); Serial.print(msg.id, HEX );
    Serial.print("  EXT: "); Serial.print(msg.flags.extended );
    Serial.print("  LEN: "); Serial.print(msg.len);
    Serial.print(" DATA: ");

    for (uint8_t i = 0; i < 9; i++ ) {
      Serial.print(msg.buf[i]); Serial.print(" ");
    }
 }
 if (can2.read(msg) ) {
    Serial.print("CAN1"); 
    Serial.print("MB: "); Serial.print(msg.mb);
    Serial.print("  ID: 0x"); Serial.print(msg.id, HEX );
    Serial.print("  EXT: "); Serial.print(msg.flags.extended );
    Serial.print("  LEN: "); Serial.print(msg.len);
    Serial.print(" DATA: ");

    for (uint8_t i = 0; i < 9; i++ ) {
      Serial.print(msg.buf[i]); Serial.print(" ");
    }
 }

  digitalWrite(ledPin, !digitalRead(ledPin));
  
  can_buf_to_imu();

  delay (500);
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
  Serial.print("roll = ");
  Serial.print(imu_values[0]);
  Serial.print(", pitch = ");
  Serial.print(imu_values[1]);
  Serial.print(", yaw = ");
  Serial.println(imu_values[2]);
}
