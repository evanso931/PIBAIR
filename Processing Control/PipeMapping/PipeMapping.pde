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
String direction = "5";
//String read_data2 = "0";
Serial Port;  
Serial Encoder;
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
boolean firstContact = true;
float encoder_counts = 0;
float previous_counts = 0;
long CurrentMillis = 0;
long PreviousMillis = 0;
int[] fake_data = new int[300];

void setup() {
  // Fill fake data array
  fakeData();

  // Program Window
  size(1920,1030,OPENGL);
  
  // List all the available serial ports:
  printArray(Serial.list());
  // Select Com Port
  Port = new Serial(this, Serial.list()[0], 9600); // Make sure there are no serial terminals open
  Encoder = new Serial(this, Serial.list()[2], 9600); // Might be different if using arduino for 5 v power

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
  printArray(cameras);
  //video = new Capture(this, 550, 413, cameras[0], 30); // Try iether cameras[0] or cameras[1], could be using pc camera
  //video.start();  

  //RobotControl Setup
  control_init(); 

}

void draw() {
  background(26, 28, 35);

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
  //if (video.available() == true) {
   // video.read();
  //}
  //image(video, 1350 , 210); //video position

  control_hud_draw();
  cam.endHUD();

  // Vitual Camera position calcuation for home button
  cam_position = new PVector(cam.getPosition()[0], cam.getPosition()[1], cam.getPosition()[2]);  
  angle_xy = degrees(atan2(cam_position.z, cam_position.x));  // camera XY angle from origin
  distance_xy = sqrt(pow(cam_position.z, 2) + pow(cam_position.x, 2)); // camera-object XY distance (compare to cam.getDistance()
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

void serialEvent(Serial Port) {
    
    //put the incoming data into a String - 
    //the '\n' is our end delimiter indicating the end of a complete packet
    
    String read_data2 = Encoder.readStringUntil('\n');
    if (read_data2 != null ) {
      encoder_counts = float(read_data2);
      println(float(read_data2)); 
    }

    String read_data = Port.readStringUntil('\n');
    //make sure our data isn't empty before continuing
    //String read_data = read_data2;
    if (read_data != null ) {
      //trim whitespace and formatting characters (like carriage return)
      
      // Protects against null pointer eexception error, incase reads serial data incorrectly
  
        direction = read_data;
        println(direction);

      //look for our 'A' string to start the handshake
      //if it's there, clear the buffer, and send a request for data
      if (firstContact == false) {
        if (read_data.equals("A")) {
          Port.clear();
          firstContact = true;
          Port.write("A");
          println("contact");
        }
      }
      else { //if we've already established contact, keep getting and parsing data
        //println(val);

        if (mousePressed == true) 
        {                           //if we clicked in the window
          //String pwm = pwm_data[1];
          Port.write('1');        //send a 1
          println("1");
       }

        // when you've parsed the data you have, ask for more:
        Port.write("A");
      }
    }
}

void fakeData(){
  // fills fake data array with inverse square values
  /*
  for(int i = 0; i < 148; i ++){
    fake_data[i] = 250 * (4)/((150-i)*(150-i));
    println(fake_data[i]);
  }
  fake_data[149] = 250;
  println(fake_data[149]);
  fake_data[150] = 255;
  println(fake_data[150]);
  fake_data[151] = 250;
  println(fake_data[151]);

  for(int i = 153; i < 300; i ++){
    fake_data[i] = 250 * (4)/((150-i)*(150-i));
    println(fake_data[i]);
  }
  */
  for(int i = 0; i < 150; i ++){
    fake_data[i] = int(i*1.5);
    println(fake_data[i]);
  }

  fake_data[150] = 255;

  for(int i = 151; i < 300; i ++){
    fake_data[i] = int(((300-i)*1.5));
    println(fake_data[i]);
  }

}

