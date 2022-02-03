import processing.serial.*;

import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

import cc.arduino.*;
import org.firmata.*;

import controlP5.*;

ControlDevice cont;
ControlIO control;

Arduino arduino1;

// GUI item setups
ControlP5 cp5;
Slider2D stick1;
Slider2D stick2;
Knob m1motor1;
Knob m1motor2;
Knob m1motor3;
Knob m1motor4;
Knob m1motor5;
Knob m1motor6;
Knob m2motor1;
Knob m2motor2;
Knob m2motor3;
Knob m2motor4;
Knob m2motor5;
Knob m2motor6;
Slider m1motor7;
Slider m1motor8;
Slider m2motor7;
Slider m2motor8;
Toggle override_switch;
Textlabel module1label;
Textlabel module2label;
Button s1_butt;
Button s2_butt;
Button s3_butt;
Button ss1_butt;
Button ss2_butt;

float pi = 3.1415926535897932384626433832795;

// front motors
int m1apin = 0;
int m1bpin = 1;
int m2apin = 2;
int m2bpin = 3;
int m3apin = 4;
int m3bpin = 5;
 
// rear motors
int m4apin = 6;
int m4bpin = 7;
int m5apin = 8;
int m5bpin = 9;
int m6apin = 10;
int m6bpin = 11;

//// retraction motors
int m7apin = 12;//A4;
int m7bpin = 13;//A5;
int m8apin = 14;//A8;
int m8bpin = 15;//A9;

int m1pwm1;
int m1pwm2;
int m1pwm3;
int m1pwm4;
int m1pwm5;
int m1pwm6;
int m1pwm7;
int m1pwm8;

int m2pwm1;
int m2pwm2;
int m2pwm3;
int m2pwm4;
int m2pwm5;
int m2pwm6;
int m2pwm7;
int m2pwm8;

//int led1 = 16;

float forward;
float back;
float rear_pitch_x; 
float rear_pitch_y;
float front_pitch_x; 
float front_pitch_y; 
float rear_flip; 
//float rear_drive;
float extend1;
float compress1;
float front_flip; 
//float front_drive; 
float for_retract;
float back_retract;
float for_retract1;
float back_retract1;
float for_retract2;
float back_retract2;
float for_retract3;
float back_retract3;
float for_retract4;
float back_retract4;
float ret_toggle;
float state_sel;

float joy_thresh = 40;
float retraction_derate = 0.1;

boolean front = false;
boolean rear = false;
//boolean ret_switch = false;

boolean man_override = false;

float rear_r;
float rear_theta;
float front_r;
float front_theta;
float l_theta;
float lf_theta;
float m1;
float m2;
float m3;
float m4;
float m5;
float m6;
float m7;
float m8;

//module states
int state = 0;
boolean state_adv = false;
boolean state_back = false;

// 0 = all, 1 = m1, 2 = m2

//module sub-states
int sub_state = 0;
boolean sub_state_adv = false;
boolean sub_state_back = false;

// 0 = full, 1 = split

long interval = 500;
long previousMillis = 0;

int ret_switch = 0;
boolean ret_adv = false;
//0 = m1f, 1 = m1r, 2 = m2f, 3 = m2r


void control_init() {
 
  cp5 = new ControlP5(this);
  control = ControlIO.getInstance(this);
  //cont = control.getMatchedDevice("tri_pipebot");
  cont = control.getMatchedDevice("trr_xbox_win_2"); //windows controller
  
  
  
  if (cont == null) {
    println("not working");
    System.exit(-1);
  }
  
  println(Arduino.list());
  delay(500);
  try{
  arduino1 = new Arduino(this, Arduino.list()[4], 9600); // list 2 for windows
  //arduino2 = new Arduino(this, Arduino.list()[1], 57600); // list 2 for windows
  }
  catch (Exception e){
    e.printStackTrace();
    exit();
    
    
  }
  
  //GUI
  
  stick1 = cp5.addSlider2D("Left Stick")
         .setPosition(30,140+100)
         .setSize(100,100)
         .setMinMax(-255,-255,255,255)
         .setValue(0,0)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         //.disableCrosshair()
         ;
 stick2 = cp5.addSlider2D("Right Stick")
         .setPosition(140,140+100)
         .setSize(100,100)
         .setMinMax(-255,-255,255,255)
         .setValue(0,0)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         //.disableCrosshair()
         ;
  m1motor1 = cp5.addKnob("M1")
       .setPosition(300,150+100)
       .setRange(-255,255)
       .setColorLabel(255)
       .setColorBackground(#3A54B4)
       .setColorForeground(#FFFFFF)
       ;
       
  m1motor2 = cp5.addKnob("M2")
       .setPosition(325,190+100)
       .setRange(-255,255)
       .setColorLabel(255)
       .setColorBackground(#3A54B4)
       .setColorForeground(#FFFFFF)
       ;
       
  m1motor3 = cp5.addKnob("M3")
         .setPosition(275,190+100)
         .setRange(-255,255)
         .setColorLabel(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m1motor4 = cp5.addKnob("M4")
         .setPosition(300,240+100)
         .setRange(-255,255)
         .setColorLabel(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m1motor5 = cp5.addKnob("M5")
         .setPosition(325,280+100)
         .setRange(-255,255)
         .setColorLabel(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m1motor6 = cp5.addKnob("M6")
         .setPosition(275,280+100)
         .setRange(-255,255)
         .setColorLabel(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m1motor7 = cp5.addSlider("M7")
         .setPosition(375,165+100)
         .setRange(-255,255)
         .setSize(10,50)
         .setColorLabel(255)
         .setColorValue(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m1motor8 = cp5.addSlider("M8")
         .setPosition(375,255+100)
         .setRange(-255,255)
         .setSize(10,50)
         .setColorLabel(255)
         .setColorValue(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
 m2motor1 = cp5.addKnob("2M1")
       .setCaptionLabel("M1")
       .setPosition(300+170,150+100)
       .setRange(-255,255)
       .setColorLabel(255)
       .setColorBackground(#3A54B4)
       .setColorForeground(#FFFFFF)
       ;
       
  m2motor2 = cp5.addKnob("2M2")
        .setCaptionLabel("M2")
       .setPosition(325+170,190+100)
       .setRange(-255,255)
       .setColorLabel(255)
       .setColorBackground(#3A54B4)
       .setColorForeground(#FFFFFF)
       ;
       
  m2motor3 = cp5.addKnob("2M3")
          .setCaptionLabel("M3")
         .setPosition(275+170,190+100)
         .setRange(-255,255)
         .setColorLabel(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m2motor4 = cp5.addKnob("2M4")
        .setCaptionLabel("M4")
         .setPosition(300+170,240+100)
         .setRange(-255,255)
         .setColorLabel(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m2motor5 = cp5.addKnob("2M5")
        .setCaptionLabel("M5")
         .setPosition(325+170,280+100)
         .setRange(-255,255)
         .setColorLabel(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m2motor6 = cp5.addKnob("2M6")
          .setCaptionLabel("M6")
         .setPosition(275+170,280+100)
         .setRange(-255,255)
         .setColorLabel(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m2motor7 = cp5.addSlider("2M7")
        .setCaptionLabel("M7")
         .setPosition(375+170,165+100)
         .setRange(-255,255)
         .setSize(10,50)
         .setColorLabel(255)
         .setColorValue(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  m2motor8 = cp5.addSlider("2M8")
        .setCaptionLabel("M8")
         .setPosition(375+170,255+100)
         .setRange(-255,255)
         .setSize(10,50)
         .setColorLabel(255)
         .setColorValue(255)
         .setColorBackground(#3A54B4)
         .setColorForeground(#FFFFFF)
         ;
         
  override_switch = cp5.addToggle("man_override")
         .setCaptionLabel("Manual Control")
         .setPosition(40,350+100)
         .setSize(50,20)
         .setValue(true)
         .setMode(ControlP5.SWITCH)
         .setColorBackground(#FFFFFF)
         .setColorForeground(#FFFFFF)
         .setColorActive(#3A54B4)
         ;
         
  module1label = cp5.addTextlabel("label1")
        .setText("Module 1")
        .setPosition(300,115+100)
        //.setHeight(30)
        //.setSize(200, 40)
        //.setColorValue(0xffffff00)
        .setFont(createFont("Georgia",16))
        ;

  module2label = cp5.addTextlabel("label2")
        .setText("Module 2")
        .setPosition(300+170,115+100)
        //.setHeight(30)
        //.setSize(200, 40)
        //.setColorValue(0xffffff00)
        .setFont(createFont("Georgia",16))
        ;
        
// state buttons
  s1_butt = cp5.addButton("s1_butt")
    .setCaptionLabel("All")
     .setValue(0)
     .setPosition(150,100+300)
     .setSize(60,19)
      .setColorForeground(#3A54B4)
     ;
 s2_butt = cp5.addButton("s2_butt")
   .setCaptionLabel("Module 1")
     .setValue(0)
     .setPosition(150,125+300)
     .setSize(60,19)
    
         .setColorForeground(#3A54B4)
     ;
 s3_butt = cp5.addButton("s3_butt")
   .setCaptionLabel("Module 2")
     .setValue(0)
     .setPosition(150,150+300)
     .setSize(60,19)
         .setColorForeground(#3A54B4)
     ;
     
ss1_butt = cp5.addButton("ss1_butt")
    .setCaptionLabel("Full")
     .setValue(0)
     .setPosition(150,200+300)
     .setSize(60,19)
         .setColorForeground(#3A54B4)
     ;
 ss2_butt = cp5.addButton("ss2_butt")
    .setCaptionLabel("Split")
     .setValue(0)
     .setPosition(150,225+300)
     .setSize(60,19)
         .setColorForeground(#3A54B4)
     ;
         
  smooth();
  
  cp5.setAutoDraw(false);

  title = cp5.addTextlabel("labeltitlepibair")
        .setText("PIBAIR")
        .setPosition(10,10)
        //.setHeight(100)
        //.setSize(300, 140)
        .setColorValue(color(#3A54B4))
        .setFont(createFont("Arial Bold Italic",150,true))
        ;

   title = cp5.addTextlabel("labeltitlecontrolpanel")
        .setText("Control Panel")
        .setPosition(550,10)
        //.setHeight(100)
        //.setSize(300, 140)
        .setColorValue(color(#FFFFFF))
        .setFont(createFont("Arial Bold Italic",150,true))
        ;


  
   
  //arduino.pinMode(led1, Arduino.OUTPUT);
 
}



public void getUserInput(){
  
  // assign our float value
  // access the controller
  forward = map(cont.getButton("forward").getValue(), 0, 1, 0, 255);
  back = map(cont.getButton("back").getValue(), 0, 1, 0, -255);
  rear_pitch_x = map(cont.getSlider("front_pitch_x").getValue(), -1, 1, -255, 255);
  rear_pitch_y = map(cont.getSlider("front_pitch_y").getValue(), -1, 1, -255, 255);
  front_pitch_x = map(cont.getSlider("rear_pitch_x").getValue(), -1, 1, -255, 255);
  front_pitch_y = map(cont.getSlider("rear_pitch_y").getValue(), -1, 1, -255, 255);
  rear_flip = cont.getButton("rear_flip").getValue();
  //rear_drive = map(cont.getSlider("rear_drive").getValue(), -1, 1, 0, 255);
  extend1 = map(cont.getSlider("extend1").getValue(), -1, 1, -255, 255);
  front_flip = cont.getButton("front_flip").getValue();
  //compress1 = map(cont.getSlider("front_drive").getValue(), -1, 1, 0, 255);
  //front_drive = map(cont.getSlider("front_drive").getValue(), -1, 1, 0, 255);
  for_retract = map(cont.getButton("for_retract").getValue(), 0, 1, 0, 255);
  back_retract = map(cont.getButton("back_retract").getValue(), 0, 1, 0, -255);
  ret_toggle = cont.getButton("ret_toggle").getValue();
  state_sel = cont.getButton("state_sel").getValue();
  
  //println(extend1);
  
  
}


// button functions

public void s1_butt() {

  state = 0;
}
public void s2_butt() {
  state = 1;
}
public void s3_butt() {
  state = 2;
}
public void ss1_butt() {

  sub_state = 0;
}
public void ss2_butt() {
  sub_state = 1;
}




void control_hud_draw(){
  
 long currentMillis = millis(); 
 //println(state_sel);

  

 // GUI
 

 
  
 stick1.setValue(front_pitch_x,front_pitch_y);
 stick2.setValue(rear_pitch_x,rear_pitch_y);
 

 
 // if manual override not activated, set the sliders to pwm values
 if(man_override==true){
   m1motor1.setValue(m1pwm1);
   m1motor2.setValue(m1pwm2);
   m1motor3.setValue(m1pwm3);
   m1motor4.setValue(m1pwm4);
   m1motor5.setValue(m1pwm5);
   m1motor6.setValue(m1pwm6);
   m1motor7.setValue(m1pwm7);
   m1motor8.setValue(m1pwm8);
   
   m2motor1.setValue(m2pwm1);
   m2motor2.setValue(m2pwm2);
   m2motor3.setValue(m2pwm3);
   m2motor4.setValue(m2pwm4);
   m2motor5.setValue(m2pwm5);
   m2motor6.setValue(m2pwm6);
   m2motor7.setValue(m2pwm7);
   m2motor8.setValue(m2pwm8);
 }
 
 // shapes on GUI
 
  pushMatrix();
  /*
  // module 1 box
  if(man_override==false) { 
    fill(#23F764);
  } else if(state==2){
    fill(128,128,110);
  }else{
    fill(#DEDEDE);
  }
  rect(260,35,160,210);
  
   // module 2 box
  if(man_override==false) { 
    fill(#23F764);
  } else if(state==1){
    fill(128,128,110);
  }else{
    fill(#DEDEDE);
  }
  rect(430,35,160,210);
  */
  
  //manual override light
  if(man_override==false) { 
    fill(#FF0009);
  } else {
    fill(128,128,110);
  }
  ellipse(110,460,20,20);   
  
  // retraction toggle front light 1
 if(ret_switch==0) {
    fill(#FF0009);
  } else {
    fill(128,128,110);
  }
  ellipse(400,322,15,15);   
  
  // retraction toggle front light 2
 if(ret_switch==2) {
    fill(#FF0009);
  } else {
    fill(128,128,110);
  }
  ellipse(400+170,322,15,15); 
  
  // retraction toggle rear light 1
  if(ret_switch==1) {
    fill(#FF0009);
  } else {
    fill(128,128,110);
  }
  ellipse(400,412,15,15);  
  
  // retraction toggle rear light 2
  if(ret_switch==3) {
    fill(#FF0009);
  } else {
    fill(128,128,110);
  }
  ellipse(400+170,412,15,15); 
  
  
  popMatrix();
  
  
  
 //robot control
  
 getUserInput();
 
 
 //state checker
 // module state forward
 if(state_adv==false){
   if((int)state_sel == 4){
     state_adv = true;
     previousMillis = currentMillis;
       
   }
 }
 else if(state_adv==true){
   if (currentMillis - previousMillis >= interval) {
     state_adv = false;
     state++;
     if(state > 2){ state = 0;
   }
    } 
 }
 
 // module state back
 if(state_back==false){
   if((int)state_sel == 8){
     state_back = true;
     previousMillis = currentMillis;
       
   }
 }
 else if(state_back==true){
   if (currentMillis - previousMillis >= interval) {
     state_back = false;
     state--;
     if(state < 0){ state = 2;
   }
    } 
 }
 
 
 // module sub - state forward
 if(sub_state_adv==false){
   if((int)state_sel == 2){
     sub_state_adv = true;
     previousMillis = currentMillis;
       
   }
 }
 else if(sub_state_adv==true){
   if (currentMillis - previousMillis >= interval) {
     sub_state_adv = false;
     sub_state++;
     if(sub_state > 1){ sub_state = 0;
   }
    } 
 }
 
 // module sub_state back
 if(sub_state_back==false){
   if((int)state_sel == 6){
     sub_state_back = true;
     previousMillis = currentMillis;
       
   }
 }
 else if(sub_state_back==true){
   if (currentMillis - previousMillis >= interval) {
     sub_state_back = false;
     sub_state--;
     if(sub_state < 0){ sub_state = 1;
   }
    } 
 }
 
 
 // change visuals for state buttons
 if(state==0){
   s1_butt.setColorBackground(#3A54B4);
   s1_butt.setColorLabel(255);
   sub_state=0; //substate 0 only possible in state 0
 
 }else{
   s1_butt.setColorBackground(color(128,128,110));
   s1_butt.setColorLabel(255);
 }
 if(state==1){
   s2_butt.setColorBackground(#3A54B4);
   s2_butt.setColorLabel(255);
 }
 else{
   s2_butt.setColorBackground(color(128,128,110));
   s2_butt.setColorLabel(255);
 }
 if(state==2){
   s3_butt.setColorBackground(#3A54B4);
   s3_butt.setColorLabel(255);
 }
 else{
   s3_butt.setColorBackground(color(128,128,110));
   s3_butt.setColorLabel(255);
 }
 
 if(sub_state==0){
   ss1_butt.setColorBackground(#3A54B4);
   ss1_butt.setColorLabel(255);
 
 }else{
   ss1_butt.setColorBackground(color(128,128,110));
   ss1_butt.setColorLabel(255);
 }
 if(sub_state==1){
   ss2_butt.setColorBackground(#3A54B4);
   ss2_butt.setColorLabel(255);
 }
 else{
   ss2_butt.setColorBackground(color(128,128,110));
   ss2_butt.setColorLabel(255);
 }
 
 
 
 // cycles ends of retraction when button is pressed
 if(ret_adv==false){
   if((int)ret_toggle == 8){
     ret_adv = true;
     previousMillis = currentMillis;
   }
 }else if(ret_adv== true){
   if (currentMillis - previousMillis >= interval) {
     ret_adv = false;
     ret_switch++;
     if(state==0 && ret_switch>3){
       ret_switch =0;
     }else if(state==1 && ret_switch>1){
       ret_switch =0;
     }else if(state==2 && ret_switch>3){
       ret_switch =2;
     }
   }
 }
   
   
 //}
 if(ret_switch == 0){
   for_retract1 = for_retract;
   back_retract1 = back_retract;
   for_retract2 = 0;
   back_retract2 = 0;
   for_retract3 = 0;
   back_retract3 = 0;
   for_retract4 = 0;
   back_retract4 = 0;
   
 }else if(ret_switch == 1){
   for_retract2 = for_retract;
   back_retract2 = back_retract;
   for_retract1 = 0;
   back_retract1 = 0;
   for_retract3 = 0;
   back_retract3 = 0;
   for_retract4 = 0;
   back_retract4 = 0;
 }else if(ret_switch == 2){
   for_retract3 = for_retract;
   back_retract3 = back_retract;
   for_retract1 = 0;
   back_retract1 = 0;
   for_retract2 = 0;
   back_retract2 = 0;
   for_retract4 = 0;
   back_retract4 = 0;
 }
 else if(ret_switch == 3){
   for_retract4 = for_retract;
   back_retract4 = back_retract;
   for_retract1 = 0;
   back_retract1 = 0;
   for_retract3 = 0;
   back_retract3 = 0;
   for_retract2 = 0;
   back_retract2 = 0;
 }

 cp5.draw();
 
 
 // quadrant determination (left stick) this is based on the method outlined in Joe's thesis
 
 front_r = sqrt((sq(front_pitch_x)) + (sq(front_pitch_y)));
 
 if(front_r > joy_thresh){
   if((front_pitch_x > 0) && (front_pitch_y > 0)){ //Q1
     front_theta = 180/pi * (atan2(front_pitch_y, front_pitch_x)) ;
     
   }else if((front_pitch_x < 0) && (front_pitch_y > 0)){ //Q2
     front_theta = 180/pi * (atan2(front_pitch_y, front_pitch_x)) ;
     
   }else if((front_pitch_x < 0) && (front_pitch_y < 0)){ //Q3
     front_theta = 180/pi * (pi + (pi + atan2(front_pitch_y, front_pitch_x)))  ;
     
   }else if((front_pitch_x > 0) && (front_pitch_y < 0)){ //Q4
     front_theta = 180/pi * (pi + (pi + atan2(front_pitch_y, front_pitch_x))) ;
   }
 }else{
   front_theta = 0;
 }
 
 // adjust angle to be in line with m1
 
 if(front_theta >= 270){
  front_theta = front_theta -270 ;
 }
 else if(front_theta < 270){
  front_theta = 90 + front_theta ;
 }
   
   //println(front_r);
  // proportion to motors
if (front_r < joy_thresh){
   m4 = 1;
   m5 = 1;
   m6 = 1;
}else{
  
 if((60 > front_theta) && (front_theta > 0)){
   lf_theta = front_theta;
   m4 = (0.5 + (0.5 *(1-((lf_theta)/60)))) * -1;
   m5 = (1-((lf_theta)/30)) * 0.5;
   m6 = 0.5+(0.5*(lf_theta/60));
   
 }else if((120 > front_theta) && (front_theta > 60)){
   lf_theta = 60-(front_theta -60)  ;  
   m5 = (0.5 + (0.5 *(1-(lf_theta/60)))) * -1;
   m4 = (1-(lf_theta/30)) * 0.5;
   m6 = 0.5+(0.5*(lf_theta/60)) ;
   
 }else if((180 > front_theta) && (front_theta > 120)){
   lf_theta = front_theta -120;
   m5 = (0.5 + (0.5 *(1-(lf_theta/60)))) * -1;
   m6 = (1-(lf_theta/30)) * 0.5;
   m4 = 0.5+(0.5*(lf_theta/60));
   
 }else if((240 > front_theta) && (front_theta > 180)){
   lf_theta = 60- (front_theta - 180);
   m6 = (0.5 + (0.5 *(1-(lf_theta/60)))) * -1;
   m5 = (1-(lf_theta/30)) * 0.5;
   m4 = 0.5+(0.5*(lf_theta/60));
   
 }else if((300 > front_theta) && (front_theta > 240)){
   lf_theta = front_theta -240 ;
   m6 = (0.5 + (0.5 *(1-(lf_theta/60)))) * -1;
   m4 = (1-(lf_theta/30)) * 0.5;
   m5 = 0.5+(0.5*(lf_theta/60));
   
 }else if((360 > front_theta) && (front_theta > 300)){
   lf_theta = 60-(front_theta - 300);
   m4 = (0.5 + (0.5 *(1-(lf_theta/60)))) * -1;
   m6 = (1-(lf_theta/30)) * 0.5;
   m5 = 0.5+(0.5*(lf_theta/60));
   
 }else{
   m4 = 1;
   m5 = 1;
   m6 = 1;
 }
}
 
 // debug
 //println(front_theta);
 //println(m4);
 //println(m5);
 //println(m6);
 
 
 
 // quadrant determination (right stick)
 
 rear_r = sqrt((sq(rear_pitch_x)) + (sq(rear_pitch_y)));
 
 if(rear_r > joy_thresh){
   if((rear_pitch_x > 0) && (rear_pitch_y > 0)){ //Q1
     rear_theta = 180/pi * (atan2(rear_pitch_y, rear_pitch_x)) ;
     
   }else if((rear_pitch_x < 0) && (rear_pitch_y > 0)){ //Q2
     rear_theta = 180/pi * (atan2(rear_pitch_y, rear_pitch_x)) ;
     
   }else if((rear_pitch_x < 0) && (rear_pitch_y < 0)){ //Q3
     rear_theta = 180/pi * (pi + (pi + atan2(rear_pitch_y, rear_pitch_x)))  ;
     
   }else if((rear_pitch_x > 0) && (rear_pitch_y < 0)){ //Q4
     rear_theta = 180/pi * (pi + (pi + atan2(rear_pitch_y, rear_pitch_x))) ;
   }
 }else{
   rear_theta = 0;
 }
 
 // adjust angle to be in line with m1
 
 if(rear_theta >= 270){
  rear_theta = rear_theta -270 ;
 }
 else if(front_theta < 270){
  rear_theta = 90 + rear_theta ;
 }
   
   //println(front_r);
  // proportion to motors
if (rear_r < joy_thresh){
   m1 = 1;
   m2 = 1;
   m3 = 1;
}else{
  
 if((60 > rear_theta) && (rear_theta > 0)){
   l_theta = rear_theta;
   m1 = (0.5 + (0.5 *(1-((l_theta)/60)))) * -1;
   m2 = (1-((l_theta)/30)) * 0.5;
   m3 = 0.5+(0.5*(l_theta/60));
   
 }else if((120 > rear_theta) && (rear_theta > 60)){
   l_theta = 60-(rear_theta -60)  ;  
   m2 = (0.5 + (0.5 *(1-(l_theta/60)))) * -1;
   m1 = (1-(l_theta/30)) * 0.5;
   m3 = 0.5+(0.5*(l_theta/60)) ;
   
 }else if((180 > rear_theta) && (rear_theta > 120)){
   l_theta = rear_theta -120;
   m2 = (0.5 + (0.5 *(1-(l_theta/60)))) * -1;
   m3 = (1-(l_theta/30)) * 0.5;
   m1 = 0.5+(0.5*(l_theta/60));
   
 }else if((240 > rear_theta) && (rear_theta > 180)){
   l_theta = 60- (rear_theta - 180);
   m3 = (0.5 + (0.5 *(1-(l_theta/60)))) * -1;
   m2 = (1-(l_theta/30)) * 0.5;
   m1 = 0.5+(0.5*(l_theta/60));
   
 }else if((300 > rear_theta) && (rear_theta > 240)){
   l_theta = rear_theta -240 ;
   m3 = (0.5 + (0.5 *(1-(l_theta/60)))) * -1;
   m1 = (1-(l_theta/30)) * 0.5;
   m2 = 0.5+(0.5*(l_theta/60));
   
 }else if((360 > rear_theta) && (rear_theta > 300)){
   l_theta = 60-(rear_theta - 300);
   m1 = (0.5 + (0.5 *(1-(l_theta/60)))) * -1;
   m3 = (1-(l_theta/30)) * 0.5;
   m2 = 0.5+(0.5*(l_theta/60));
   
 }else{
   m1 = 1;
   m2 = 1;
   m3 = 1;
 }
}
 
 


if(man_override==true){ //check for manual override

  if(state==0){ //all

    m1pwm1 = (int)forward + (int)back + ((int)(extend1)) ;//- ((int)(compress1*m4));
    m1pwm2 = (int)forward + (int)back + ((int)(extend1)) ;//- ((int)(compress1*m5));
    m1pwm3 = (int)forward + (int)back + ((int)(extend1)) ;//- ((int)(compress1*m6));
    m1pwm4 = (int)forward + (int)back + ((int)(extend1)) ;//+ ((int)(compress1*m4));
    m1pwm5 = (int)forward + (int)back + ((int)(extend1)) ;//+ ((int)(compress1*m5));
    m1pwm6 = (int)forward + (int)back + ((int)(extend1)) ;//+ ((int)(compress1*m6));
    
    m1pwm7 = (int)((for_retract1 + back_retract1)*retraction_derate); 
    m1pwm8 = (int)((for_retract2 + back_retract2)*retraction_derate);
    
    
    m2pwm1 = (int)forward + (int)back - ((int)(extend1)) ;//- ((int)(compress1*m4));
    m2pwm2 = (int)forward + (int)back - ((int)(extend1)) ;//- ((int)(compress1*m5));
    m2pwm3 = (int)forward + (int)back - ((int)(extend1)) ;//- ((int)(compress1*m6));
    m2pwm4 = (int)forward + (int)back - ((int)(extend1)) ;//+ ((int)(compress1*m4));
    m2pwm5 = (int)forward + (int)back - ((int)(extend1)) ;//+ ((int)(compress1*m5));
    m2pwm6 = (int)forward + (int)back - ((int)(extend1)) ;//+ ((int)(compress1*m6));
    
    m2pwm7 = (int)((for_retract3 + back_retract3)*retraction_derate); 
    m2pwm8 = (int)((for_retract4 + back_retract4)*retraction_derate);
  }

  if(state==1){ //m1
    if(sub_state==0){  //full

    m1pwm1 = (int)forward + (int)back + ((int)(extend1*m4)) ;//- ((int)(compress1*m4));
    m1pwm2 = (int)forward + (int)back + ((int)(extend1*m5)) ;//- ((int)(compress1*m5));
    m1pwm3 = (int)forward + (int)back + ((int)(extend1*m6)) ;//- ((int)(compress1*m6));
    m1pwm4 = (int)forward + (int)back - ((int)(extend1*m4)) ;//+ ((int)(compress1*m4));
    m1pwm5 = (int)forward + (int)back - ((int)(extend1*m5)) ;//+ ((int)(compress1*m5));
    m1pwm6 = (int)forward + (int)back - ((int)(extend1*m6)) ;//+ ((int)(compress1*m6));
    
    m1pwm7 = (int)((for_retract1 + back_retract1)*retraction_derate); 
    m1pwm8 = (int)((for_retract2 + back_retract2)*retraction_derate);
    
    }else if(sub_state==1){ //split
      
    if(m4 !=1||m5 !=1||m6 !=1){
      
      m1pwm1 = (int)forward + (int)back + ((int)(extend1*m4)) ;//- ((int)(compress1*m4));
      m1pwm2 = (int)forward + (int)back + ((int)(extend1*m5)) ;//- ((int)(compress1*m5));
      m1pwm3 = (int)forward + (int)back + ((int)(extend1*m6)) ;//- ((int)(compress1*m6));
      m1pwm4 = (int)forward + (int)back ;//- ((int)(extend1*m1)) ;//+ ((int)(compress1*m4));
      m1pwm5 = (int)forward + (int)back ;//- ((int)(extend1*m2)) ;//+ ((int)(compress1*m5));
      m1pwm6 = (int)forward + (int)back ;//- ((int)(extend1*m3)) ;//+ ((int)(compress1*m6));
      
      m1pwm7 = (int)((for_retract3 + back_retract3)*retraction_derate); 
      m1pwm8 = (int)((for_retract4 + back_retract4)*retraction_derate);
      
    }else if(m1 !=1||m2 !=1||m3 !=1){
      
    
    m1pwm1 = (int)forward + (int)back; //+ ((int)(extend1*m4)) ;//- ((int)(compress1*m4));
    m1pwm2 = (int)forward + (int)back; //+ ((int)(extend1*m5)) ;//- ((int)(compress1*m5));
    m1pwm3 = (int)forward + (int)back ;//+ ((int)(extend1*m6)) ;//- ((int)(compress1*m6));
    m1pwm4 = (int)forward + (int)back - ((int)(extend1*m1)) ;//+ ((int)(compress1*m4));
    m1pwm5 = (int)forward + (int)back - ((int)(extend1*m2)) ;//+ ((int)(compress1*m5));
    m1pwm6 = (int)forward + (int)back - ((int)(extend1*m3)) ;//+ ((int)(compress1*m6));
    
    m1pwm7 = (int)((for_retract3 + back_retract3)*retraction_derate); 
    m1pwm8 = (int)((for_retract4 + back_retract4)*retraction_derate);
    }
      
    }
  }
  
  if(state==2){ //m2
    if(sub_state==0){ //full

    m2pwm1 = (int)forward + (int)back + ((int)(extend1*m4)) ;//- ((int)(compress1*m4));
    m2pwm2 = (int)forward + (int)back + ((int)(extend1*m5)) ;//- ((int)(compress1*m5));
    m2pwm3 = (int)forward + (int)back + ((int)(extend1*m6)) ;//- ((int)(compress1*m6));
    m2pwm4 = (int)forward + (int)back - ((int)(extend1*m4)) ;//+ ((int)(compress1*m4));
    m2pwm5 = (int)forward + (int)back - ((int)(extend1*m5)) ;//+ ((int)(compress1*m5));
    m2pwm6 = (int)forward + (int)back - ((int)(extend1*m6)) ;//+ ((int)(compress1*m6));
    
    m2pwm7 = (int)((for_retract3 + back_retract3)*retraction_derate); 
    m2pwm8 = (int)((for_retract4 + back_retract4)*retraction_derate);
    
  }else if(sub_state==1){ //split
    if(m4 !=1||m5 !=1||m6 !=1){
      
      m2pwm1 = (int)forward + (int)back + ((int)(extend1*m4)) ;//- ((int)(compress1*m4));
      m2pwm2 = (int)forward + (int)back + ((int)(extend1*m5)) ;//- ((int)(compress1*m5));
      m2pwm3 = (int)forward + (int)back + ((int)(extend1*m6)) ;//- ((int)(compress1*m6));
      m2pwm4 = (int)forward + (int)back ;//- ((int)(extend1*m1)) ;//+ ((int)(compress1*m4));
      m2pwm5 = (int)forward + (int)back ;//- ((int)(extend1*m2)) ;//+ ((int)(compress1*m5));
      m2pwm6 = (int)forward + (int)back ;//- ((int)(extend1*m3)) ;//+ ((int)(compress1*m6));
      
      m2pwm7 = (int)((for_retract3 + back_retract3)*retraction_derate); 
      m2pwm8 = (int)((for_retract4 + back_retract4)*retraction_derate);
      
    }else if(m1 !=1||m2 !=1||m3 !=1){
      
    
    m2pwm1 = (int)forward + (int)back; //+ ((int)(extend1*m4)) ;//- ((int)(compress1*m4));
    m2pwm2 = (int)forward + (int)back; //+ ((int)(extend1*m5)) ;//- ((int)(compress1*m5));
    m2pwm3 = (int)forward + (int)back ;//+ ((int)(extend1*m6)) ;//- ((int)(compress1*m6));
    m2pwm4 = (int)forward + (int)back - ((int)(extend1*m1)) ;//+ ((int)(compress1*m4));
    m2pwm5 = (int)forward + (int)back - ((int)(extend1*m2)) ;//+ ((int)(compress1*m5));
    m2pwm6 = (int)forward + (int)back - ((int)(extend1*m3)) ;//+ ((int)(compress1*m6));
    
    m2pwm7 = (int)((for_retract3 + back_retract3)*retraction_derate); 
    m2pwm8 = (int)((for_retract4 + back_retract4)*retraction_derate);
    }
  }
 
  }

}else { // grab the values from the GUI
  
    m1pwm1 = (int)m1motor1.getValue();
    m1pwm2 = (int)m1motor2.getValue();
    m1pwm3 = (int)m1motor3.getValue();
    m1pwm4 = (int)m1motor4.getValue();
    m1pwm5 = (int)m1motor5.getValue();
    m1pwm6 = (int)m1motor6.getValue();
    
    m1pwm7 = (int)m1motor7.getValue(); 
    m1pwm8 = (int)m1motor8.getValue();
    
    m2pwm1 = (int)m2motor1.getValue();
    m2pwm2 = (int)m2motor2.getValue();
    m2pwm3 = (int)m2motor3.getValue();
    m2pwm4 = (int)m2motor4.getValue();
    m2pwm5 = (int)m2motor5.getValue();
    m2pwm6 = (int)m2motor6.getValue();
    
    m2pwm7 = (int)m2motor7.getValue(); 
    m2pwm8 = (int)m2motor8.getValue();
  
  
}

 //arduino.analogWrite(10, (int)thumb);
 
 // motor speed controls module 1
if (m1pwm1 > 0) { // motor 1
    //println(pwm1);
    arduino1.analogWrite(m1apin, 0);
    arduino1.analogWrite(m1bpin, m1pwm1);//Sets speed variable via PWM
  }
  else {
    arduino1.analogWrite(m1apin, abs(m1pwm1));
    arduino1.analogWrite(m1bpin, 0);//Sets speed variable via PWM
  }
  
if (m1pwm2 > 0) { // motor 2
//    Serial.print(out);
    arduino1.analogWrite(m2apin, 0);
    arduino1.analogWrite(m2bpin, m1pwm2);//Sets speed variable via PWM
  }
  else {
    arduino1.analogWrite(m2apin, abs(m1pwm2));
    arduino1.analogWrite(m2bpin, 0);//Sets speed variable via PWM
  }

if (m1pwm3 > 0) { // motor 3
//    Serial.print(out);
    arduino1.analogWrite(m3apin, 0);
    arduino1.analogWrite(m3bpin, m1pwm3);//Sets speed variable via PWM
  }
  else {
    arduino1.analogWrite(m3apin, abs(m1pwm3));
    arduino1.analogWrite(m3bpin, 0);//Sets speed variable via PWM
  }

if (m1pwm4 > 0) { // motor 4
//    Serial.print(out);
    arduino1.analogWrite(m4apin, m1pwm4);
    arduino1.analogWrite(m4bpin, 0);//Sets speed variable via PWM
  }
  else {
    arduino1.analogWrite(m4apin, 0);
    arduino1.analogWrite(m4bpin, abs(m1pwm4));//Sets speed variable via PWM
  }
  
  if (m1pwm5 > 0) { // motor 5
//    Serial.print(out);
    arduino1.analogWrite(m5apin, m1pwm5);
    arduino1.analogWrite(m5bpin, 0);//Sets speed variable via PWM
  }
  else {
    arduino1.analogWrite(m5apin, 0);
    arduino1.analogWrite(m5bpin, abs(m1pwm5));//Sets speed variable via PWM
  }
  
  if (m1pwm6 > 0) { // motor 6
//    Serial.print(out);
    arduino1.analogWrite(m6apin, m1pwm6);
    arduino1.analogWrite(m6bpin, 0);//Sets speed variable via PWM
  }
  else {
    arduino1.analogWrite(m6apin, 0);
    arduino1.analogWrite(m6bpin, abs(m1pwm6));//Sets speed variable via PWM
  }
  
  if (m1pwm7 > 0) { // motor 7
//println(pwm7);
    arduino1.analogWrite(m7apin, m1pwm7);
    arduino1.analogWrite(m7bpin, 0);//Sets speed variable via PWM
  }
  else  {
    arduino1.analogWrite(m7apin, 0);
    arduino1.analogWrite(m7bpin, abs(m1pwm7));//Sets speed variable via PWM
  }
  
  if (m1pwm8 > 0) { // motor 8
//    Serial.print(out);
    arduino1.analogWrite(m8apin, m1pwm8);
    arduino1.analogWrite(m8bpin, 0);//Sets speed variable via PWM
  }
  else {
    arduino1.analogWrite(m8apin, 0);
    arduino1.analogWrite(m8bpin, abs(m1pwm8));//Sets speed variable via PWM
  }
  
  
 /*
  // motor speed controls module 2
if (m2pwm1 > 0) { // motor 1
    //println(pwm1);
    arduino2.analogWrite(m1apin, 0);
    arduino2.analogWrite(m1bpin, m2pwm1);//Sets speed variable via PWM
  }
  else {
    arduino2.analogWrite(m1apin, abs(m2pwm1));
    arduino2.analogWrite(m1bpin, 0);//Sets speed variable via PWM
  }
  
if (m2pwm2 > 0) { // motor 2
//    Serial.print(out);
    arduino2.analogWrite(m2apin, m2pwm2);
    arduino2.analogWrite(m2bpin, 0);//Sets speed variable via PWM
  }
  else {
    arduino2.analogWrite(m2apin, 0);
    arduino2.analogWrite(m2bpin, abs(m2pwm2));//Sets speed variable via PWM
  }

if (m2pwm3 > 0) { // motor 3
//    Serial.print(out);
    arduino2.analogWrite(m3apin, m2pwm3);
    arduino2.analogWrite(m3bpin, 0);//Sets speed variable via PWM
  }
  else {
    arduino2.analogWrite(m3apin, 0);
    arduino2.analogWrite(m3bpin, abs(m2pwm3));//Sets speed variable via PWM
  }

if (m2pwm4 > 0) { // motor 4
//    Serial.print(out);
    arduino2.analogWrite(m4apin, m2pwm4);
    arduino2.analogWrite(m4bpin, 0);//Sets speed variable via PWM
  }
  else {
    arduino2.analogWrite(m4apin, 0);
    arduino2.analogWrite(m4bpin, abs(m2pwm4));//Sets speed variable via PWM
  }
  
  if (m2pwm5 > 0) { // motor 5
//    Serial.print(out);
    arduino2.analogWrite(m5apin, 0);
    arduino2.analogWrite(m5bpin, m2pwm5);//Sets speed variable via PWM
  }
  else {
    arduino2.analogWrite(m5apin, abs(m2pwm5));
    arduino2.analogWrite(m5bpin, 0);//Sets speed variable via PWM
  }
  
  if (m2pwm6 > 0) { // motor 6
//    Serial.print(out);
    arduino2.analogWrite(m6apin, m2pwm6);
    arduino2.analogWrite(m6bpin, 0);//Sets speed variable via PWM
  }
  else {
    arduino2.analogWrite(m6apin, 0);
    arduino2.analogWrite(m6bpin, abs(m2pwm6));//Sets speed variable via PWM
  }
  
  if (m2pwm7 > 0) { // motor 7
//println(pwm7);
    arduino2.analogWrite(m7apin, m2pwm7);
    arduino2.analogWrite(m7bpin, 0);//Sets speed variable via PWM
  }
  else  {
    arduino2.analogWrite(m7apin, 0);
    arduino2.analogWrite(m7bpin, abs(m2pwm7));//Sets speed variable via PWM
  }
  
  if (m2pwm8 > 0) { // motor 8
//    Serial.print(out);
    arduino2.analogWrite(m8apin, m2pwm8);
    arduino2.analogWrite(m8bpin, 0);//Sets speed variable via PWM
  }
  else {
    arduino2.analogWrite(m8apin, 0);
    arduino2.analogWrite(m8bpin, abs(m2pwm8));//Sets speed variable via PWM
  }
    
    */
 
}
