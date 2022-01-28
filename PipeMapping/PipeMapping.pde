/** Pipe Mapping Computer Code
 * Main file for the code that runs on the computer and maps the tethers location using the processing library
 * author Benjamin Evans, University of Leeds
 * date Jan 2021
 */ 

//Libraries
import processing.opengl.*;
import processing.serial.*;
import toxi.geom.*;
import toxi.processing.*;
import peasy.*;

//Object Declarations 
ToxiclibsSupport gfx;
String[] list;
Serial Port;  
PeasyCam cam;

//Variables
int dim = 250;
int move_x = 95;
int move_y = 95;
int move_z= -5;
float encoder_difference = 0;
int interval = 0;
PVector camPos;
PVector[] points = new PVector[50];
float angleXY, d;

void setup() {
  // Program Window
  size(500,500,OPENGL);
  
  rectMode(CORNERS);

  // List all the available serial ports:
  printArray(Serial.list());
  // Select Com Port
  Port = new Serial(this, Serial.list()[4], 9600);

  // Virtual camera setting 
  cam = new PeasyCam(this, 300);
  cam.setMinimumDistance(50); // Zoom in with scroll distance 
  cam.setMaximumDistance(500); 
  float fov      = PI/4;  // field of view
  float nearClip = 1; // how close items go out field of view
  float farClip  = 100000; // how far items go out field of view
  float aspect   = float(width)/float(height);  
  perspective(fov, aspect, nearClip, farClip); 

}

void draw() {
  background(26, 28, 35);

  /* 3D Cube Space
  stroke(0);
  translate(width/2,height/2);
  scale(1,-1,1); // so Y is up, which makes more sense in plotting
  rotateY(45);
  //rotatex(radians(frameCount)/15);
  noFill();
  strokeWeight(1);
  box(dim);
  */

  // Position Planes to line up
  rotateX(PI);
  rotateY(PI/4);
  translate(0,-40,0);
  
  // ZX Plane
  stroke(0, 0, 255);
  noFill();
  plane();
  
  // ZY Plane 
  stroke(0, 255, 0);
  rotateY(HALF_PI);
  plane();
  
  // XY Plane
  stroke(255, 0, 0);
  rotateX(HALF_PI);
  plane();

  // Read Serial port data from IMU and Encoder 
  if (millis() - interval > 10) {
  interval = millis();
  if (Port.available() > 0) {
    String inByte = Port.readString();

    // Protects against null pointer eexception, incase reads serial data incorrectly
    if(inByte != null){
      list = split(inByte, ' ');
      /*
      print(list[0]);
      print(" ");
      print(list[1]);
      print(" ");
      println(list[2]);
      */
    }
  }

  if (list[3] == null){
  }else if(float(list[3]) != 0){
    if(float(list[1]) < -50){
      move_z++;
    }else if(float(list[1]) > 50){
      move_z--;
    }else if (float(list[2]) < -45 && float(list[2]) > -135) {
      move_y++;
    }else if (float(list[2]) > 45 && float(list[2]) < 135) {
      move_y--;
    }else if (float(list[2]) < 45 && float(list[2]) > -45) {
      move_x--;
    }else if (float(list[2]) > 135 || float(list[2]) < -135) {
      move_x++;
    }
  }
  
  // Move cube
  strokeWeight(2);
  translate(move_x,move_y, move_z);
  fill(240, 240, 240, 240);
  stroke(240,240,240);
  box(10, 10, 10);
  }
  
  
  // Vitual Camera position calcuation
  camPos = new PVector(cam.getPosition()[0], cam.getPosition()[1], cam.getPosition()[2]);  
  angleXY = degrees(atan2(camPos.z, camPos.x));  // camera XY angle from origin
  d = sqrt(pow(camPos.z, 2) + pow(camPos.x, 2)); // camera-object XY distance (compare to cam.getDistance())
}

void plane() {
  for (int y=0; y<=10; y++) {
    for (int x=0; x<=10; x++) {
      rect(10*x, 10*y, 10, 10);
    }
  }
}

void drawAxes(float size){
  //X  - red
  stroke(192,0,0);
  line(0,0,0,size,0,0);
  //Y - green
  stroke(0,192,0);
  line(0,0,0,0,size,0);
  //Z - blue
  stroke(0,0,192);
  line(0,0,0,0,0,size);
}


void keyPressed(){
  if(key=='r') setup(); // restart
  if(key==' ') camera(camPos.x, camPos.y, camPos.z, 0, 0, 0, 0, 0, 1); // stabilise image on Z axis

  if(key=='d') {
    angleXY += radians(1);
    camera(sin(angleXY)*d, camPos.y, cos(angleXY)*d, 0, 0, 0, 0, 1, 0);
  }

  // peasycam's rotations work around the subject:
  if(key=='p') cam.rotateY(radians(frameCount)/15);
}