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

//Libraries -----------------------------------------------------






//Object Declarations -------------------------------------------
ToxiclibsSupport gfx;
String[] split_data;
Serial Port;  
PeasyCam cam;
RobotModel robot;

//Variables -----------------------------------------------------
float encoder_difference = 0;
int read_interval = 0;
PVector cam_position;
PVector[] points = new PVector[50];
float angle_xy;
float distance_xy;

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
  float fov     = PI/4;  // field of view
  float nearClip = 1; // how close items go out field of view
  float farClip  = 100000; // how far items go out field of view
  float aspect   = PApplet.parseFloat(width)/PApplet.parseFloat(height);  
  perspective(fov, aspect, nearClip, farClip); 

  robot = new RobotModel();
}

public void draw() {
  background(26, 28, 35);

  read_serial();
  draw_planes();
  robot.move_robot();
  robot.draw_robot();

  // Vitual Camera position calcuation
  cam_position = new PVector(cam.getPosition()[0], cam.getPosition()[1], cam.getPosition()[2]);  
  angle_xy = degrees(atan2(cam_position.z, cam_position.x));  // camera XY angle from origin
  distance_xy = sqrt(pow(cam_position.z, 2) + pow(cam_position.x, 2)); // camera-object XY distance (compare to cam.getDistance())
}

public void read_serial(){
  // Reads Serial port data contaiing IMU and Encoder values
  if (millis() - read_interval > 10) {
    read_interval = millis();
    if (Port.available() > 0) {
      String read_data = Port.readString();

      // Protects against null pointer eexception error, incase reads serial data incorrectly
      if(read_data != null){
        split_data = split(read_data, ' ');
        /*
        print(list[0]);
        print(" ");
        print(list[1]);
        print(" ");
        println(list[2]);
        */
      }
    }
  }
}

public void draw_planes(){
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
}

public void plane() {
  for (int y=0; y<=10; y++) {
    for (int x=0; x<=10; x++) {
      rect(10*x, 10*y, 10, 10);
    }
  }
}

public void keyPressed(){
  if(key=='r') setup(); // restart
  if(key==' ') camera(cam_position.x, cam_position.y, cam_position.z, 0, 0, 0, 0, 0, 1); // stabilise image on Z axis

  if(key=='d') {
    angle_xy += radians(1);
    camera(sin(angle_xy)*distance_xy, cam_position.y, cos(angle_xy)*distance_xy, 0, 0, 0, 0, 1, 0);
  }

  // peasycam's rotations work around the subject:
  if(key=='p') cam.rotateY(radians(frameCount)/15);
}
class RobotModel {  
  public

    // Constructor
    RobotModel(){}
  
    public void draw_robot(){
        strokeWeight(2);
        translate(x_position,  y_position,  z_position);
        fill(240, 240, 240, 240);
        stroke(240,240,240);
        box(10, 10, 10);
    }

    public void move_robot(){
        if (split_data[3] == null){
        }else if(PApplet.parseFloat(split_data[3]) != 0){
            if(PApplet.parseFloat(split_data[1]) < -50){
                z_position++;
            }else if(PApplet.parseFloat(split_data[1]) > 50){
                z_position--;
            }else if (PApplet.parseFloat(split_data[2]) < -45 && PApplet.parseFloat(split_data[2]) > -135) {
                y_position++;
            }else if (PApplet.parseFloat(split_data[2]) > 45 && PApplet.parseFloat(split_data[2]) < 135) {
                y_position--;
            }else if (PApplet.parseFloat(split_data[2]) < 45 && PApplet.parseFloat(split_data[2]) > -45) {
                x_position--;
            }else if (PApplet.parseFloat(split_data[2]) > 135 || PApplet.parseFloat(split_data[2]) < -135) {
                x_position++;
            }
        }
    }

  private
  // Function prototypes ------------------------------------------


  // Variables ----------------------------------------------------
    float x_position = 95;
    float y_position = 95;
    float z_position = -5; 

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
