
import processing.opengl.*;
import processing.serial.*;
import toxi.geom.*;
import toxi.processing.*;
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

void setup() {
  size(500,500,OPENGL);
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

void draw() {

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
      //println(list[3]);
    }
  }
  
  //rotateX(float(list[1])/180 * PI);
  //rotateY(float(list[2])/180 * PI);
  //rotateZ(float(list[0])/180 * PI);
  //drawAxes(40);

  if (list[3] == null){

  }else if(float(list[3]) != 0){
    if(float(list[1]) < -50){
      move_y--;
      
    }else if(float(list[1]) > 50){
      move_y++;
    }else if (float(list[2]) < -50) {
      move_x--;
    }else if (float(list[2]) > 50) {
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
