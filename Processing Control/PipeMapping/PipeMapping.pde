/** Pipe Mapping Computer Code
 * Main file for the code that runs on the computer and maps the tethers location using the processing library
 * author Benjamin Evans, University of Leeds
 * date Jan 2021
 */ 


//Libraries -----------------------------------------------------
import processing.opengl.*;
import processing.serial.*;
import toxi.geom.*;
import toxi.processing.*;
import peasy.*;
import processing.video.*;
import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;
import cc.arduino.*;
import org.firmata.*;
import controlP5.*;


//Object Declarations -------------------------------------------
ToxiclibsSupport gfx;
String[] split_data;
Serial Port;  
PeasyCam cam;
Planes planes;
RobotModel robot;
Capture video;
Textlabel title;


//Variables -----------------------------------------------------
float encoder_difference = 0;
int read_interval = 0;
PVector cam_position;
ArrayList<RobotModel> robots = new ArrayList<RobotModel>();
float angle_xy = 0;
float distance_xy = 0;


void setup() {
  // Program Window
  size(1920,1080,OPENGL);
  String read_data = "0 0 0 0";
  split_data = split(read_data, ' ');
  
  // List all the available serial ports:
  printArray(Serial.list());
  // Select Com Port
  //Port = new Serial(this, Serial.list()[4], 9600); // Make sure there are no serial terminals open

  // Virtual camera setting 
  cam = new PeasyCam(this, 500); // start zoom
  cam.setMinimumDistance(50); // min/max Zoom in with scroll distance 
  cam.setMaximumDistance(600); 
  float fov     = PI/4;  // field of view
  float nearClip = 1; // how close items go out field of viewf
  float farClip  = 100000; // how far items go out field of view
  float aspect   = float(width)/float(height);  
  perspective(fov, aspect, nearClip, farClip); 

  // Declare New Objects
  robot = new RobotModel();
  planes = new Planes();

  // Setup external endoscope camera
  String[] cameras = Capture.list();
  video = new Capture(this, 550, 413, cameras[1], 30); // Try iether cameras[0] or cameras[1], could be using pc camera
  video.start();  

  //RobotControl Setup
  control_init(); 
}

void draw() {
  background(26, 28, 35);

  //read_serial();

  planes.draw_planes();
  robot.move_robot();
  robot.draw_robot();

  // Items in HUD are still and will not rotate with 3D axis 
  cam.beginHUD();
  //Axis frame
  strokeWeight(0);
  
  // Draws blocking rectangles to make a frame around the 3D axis from going over rest of the HUD
  pushMatrix();
  hudFrame(); 
  popMatrix();

  // External Endoscope Camera 
  if (video.available() == true) {
    video.read();
  }
  image(video, 1350 , 210); //video position

  control_hud_draw();
  cam.endHUD();

  // Vitual Camera position calcuation for home button
  cam_position = new PVector(cam.getPosition()[0], cam.getPosition()[1], cam.getPosition()[2]);  
  angle_xy = degrees(atan2(cam_position.z, cam_position.x));  // camera XY angle from origin
  distance_xy = sqrt(pow(cam_position.z, 2) + pow(cam_position.x, 2)); // camera-object XY distance (compare to cam.getDistance()
}

void read_serial(){
  // Reads Serial port data containing IMU and Encoder values every 10 ms
  if (millis() - read_interval > 10) {
    read_interval = millis();
    if (Port.available() > 0) {
      String read_data = "0 0 0 0";
      
      // Protects against null pointer eexception error, incase reads serial data incorrectly
      if(read_data != null){
        split_data = split(read_data, ' ');
      }
    }
  }
}



void keyPressed(){

  if(key=='r') setup(); // restart
  if(key==' ') camera(cam_position.x, cam_position.y, cam_position.z, 0, 0, 0, 0, 0, 1); // stabilise image on Z axis

  if(key=='d') {
    angle_xy += radians(1);
    camera(sin(angle_xy)*distance_xy, cam_position.y, cos(angle_xy)*distance_xy, 0, 0, 0, 0, 1, 0);
  }
   
  // peasycam's rotations work around the subject:
  if(key=='p') cam.rotateY(radians(frameCount)/15);
}

void hudFrame(){
  // top bar
  stroke(26, 28, 35);
  fill(26, 28, 35);
  rect(0, 0, 1920, 200);

  // left bar
  stroke(26, 28, 35);
  fill(26, 28, 35);
  rect(0, 0, 600, 1100);

  // bright bar
  pushMatrix();
  translate(1320, 0, 0);
  stroke(26, 28, 35);
  fill(26, 28, 35);
  rect(0, 0, 600, 1100);
  popMatrix();

  // top bar
  pushMatrix();
  translate(0, 840, 0);
  stroke(26, 28, 35);
  fill(26, 28, 35);
  rect(0, 0, 1920, 340);
  popMatrix();
  
  // frame
  translate(600, 200, 0);
  strokeWeight(3);
  stroke(46,48,62);
  noFill();
  rect(0, 0, 720, 640) ;

  // endoscope camera frame
  translate(740, 0, 0);
  strokeWeight(3);
  stroke(46,48,62);
  noFill();
  rect(0, 0, 570, 433) ;
}