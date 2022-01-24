import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.opengl.*; 
import processing.serial.*; 
import toxi.geom.*; 
import toxi.processing.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PipeMapping extends PApplet {






ToxiclibsSupport gfx;


String[] list;

Serial myPort;  // The serial port
 
PVector[] vecs = new PVector[100];
int dim = 250;
int move_x = -100;
int move_y = -100;
int move_z= -100;
float encoder_difference = 0;
int interval = 0;

public void setup() {
  
  gfx = new ToxiclibsSupport(this);
  for (int i=0; i<vecs.length; i++) {
    vecs[i] = new PVector(random(dim),random(dim),random(dim));
  }
  // List all the available serial ports:
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[4], 9600);
  background(0);

  
}

public void draw() {

  stroke(255);
  translate(width/2,height/2);
  scale(1,-1,1); // so Y is up, which makes more sense in plotting
  rotateY(45);
  //rotatex(radians(frameCount)/15);
 
  noFill();
  strokeWeight(1);
  box(dim);

  if (millis() - interval > 10) {
  interval = millis();
  if (myPort.available() > 0) {
    String inByte = myPort.readString();
    if(inByte != null){
      list = split(inByte, ' ');
      println(list[3]);
    }
  }
  
  //rotateX(float(list[1])/180 * PI);
  //rotateY(float(list[2])/180 * PI);
  //rotateZ(float(list[0])/180 * PI);
  //drawAxes(40);

  if (list[3] == null){

  }else if(PApplet.parseFloat(list[3]) != 0){
    if(PApplet.parseFloat(list[1]) < -50){
      move_y--;
      
    }else if(PApplet.parseFloat(list[1]) > 50){
      move_y++;
    }else if (PApplet.parseFloat(list[2]) < -50) {
      move_x--;
    }else if (PApplet.parseFloat(list[2]) > 50) {
      move_x++;
    }else{
      move_z++;
    }
  }
  
  strokeWeight(2);
  translate(move_x,move_y, move_z);
  fill(255, 0, 0, 200);
  stroke(192,0,0);
  box(10, 10, 10);
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
