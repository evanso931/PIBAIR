/** Planes
 * Class to draw xyz planes in gui
 * Author: Benjamin Evans, University of Leeds
 * Date: Dec 2021
 */ 

class Planes {  
  public

    // Constructor
    Planes(){}
  
    void draw_planes(){
      strokeWeight(2);
      rectMode(CORNERS);
      
      // Position Planes to line up
      rotateX(PI);
      rotateY(PI/4);
      translate(0, -40, 0);
      
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

  private
  // Functions ----------------------------------------------------
    void plane() {
      for (int y=0; y<=10; y++) {
        for (int x=0; x<=10; x++) {
          rect(10*x, 10*y, 10, 10);
          }
      }
    }

  // Variables ----------------------------------------------------
} 