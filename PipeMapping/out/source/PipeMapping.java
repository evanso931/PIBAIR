import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.opengl.*; 
import processing.serial.*; 
import toxi.geom.*; 
import toxi.processing.*; 
import peasy.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PipeMapping extends PApplet {

/** Pipe Mapping Computer Code
 * Main file for the code that runs on the computer and maps the tethers location using the processing library
 * author Benjamin Evans, University of Leeds
 * date Jan 2021
 */ 

//Libraries






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

public void setup() {
  // Program Window
  
  
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
  float aspect   = PApplet.parseFloat(width)/PApplet.parseFloat(height);  
  perspective(fov, aspect, nearClip, farClip); 

}

public void draw() {
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

  if (millis() - interval > 10) {
  interval = millis();
  if (Port.available() > 0) {
    String inByte = Port.readString();
    if(inByte != null){
      list = split(inByte, ' ');
      print(list[0]);
      print(" ");
      print(list[1]);
      print(" ");
      println(list[2]);
    }
  }
  
  //rotateX(float(list[1])/180 * PI);
  //rotateY(float(list[2])/180 * PI);
  //rotateZ(float(list[0])/180 * PI);
  //drawAxes(40);

  if (list[3] == null){

  }else if(PApplet.parseFloat(list[3]) != 0){
    if(PApplet.parseFloat(list[1]) < -50){
      move_z++;
    }else if(PApplet.parseFloat(list[1]) > 50){
      move_z--;
    }else if (PApplet.parseFloat(list[2]) < -45 && PApplet.parseFloat(list[2]) > -135) {
      move_y++;
    }else if (PApplet.parseFloat(list[2]) > 45 && PApplet.parseFloat(list[2]) < 135) {
      move_y--;
    }else if (PApplet.parseFloat(list[2]) < 45 && PApplet.parseFloat(list[2]) > -45) {
      move_x--;
    }else if (PApplet.parseFloat(list[2]) > 135 || PApplet.parseFloat(list[2]) < -135) {
      move_x++;
    }
  }
  
  strokeWeight(2);
  translate(move_x,move_y, move_z);
  fill(240, 240, 240, 240);
  stroke(240,240,240);
  box(10, 10, 10);
  }
  
  stroke(0);
  
  camPos = new PVector(cam.getPosition()[0], cam.getPosition()[1], cam.getPosition()[2]);  
  angleXY = degrees(atan2(camPos.z, camPos.x));  // camera XY angle from origin
  d = sqrt(pow(camPos.z, 2) + pow(camPos.x, 2)); // camera-object XY distance (compare to cam.getDistance())


}

public void plane() {
  for (int y=0; y<=10; y++) {
    for (int x=0; x<=10; x++) {
      rect(10*x, 10*y, 10, 10);
    }
  }
}

public void drawAxes(float size){
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


public void keyPressed(){
  if(key=='r') setup(); // restart
  if(key==' ') camera(camPos.x, camPos.y, camPos.z, 0, 0, 0, 0, 0, 1); // stabilise image on Z axis

  if(key=='d') {
    angleXY += radians(1);
    camera(sin(angleXY)*d, camPos.y, cos(angleXY)*d, 0, 0, 0, 0, 1, 0);
  }

  // peasycam's rotations work around the subject:
  if(key=='p') cam.rotateY(radians(2));
}
  public void settings() {  size(500,500,OPENGL); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PipeMapping" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
