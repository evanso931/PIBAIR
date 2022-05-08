class RobotModel {  
  public
    
    // Constructor
    RobotModel() {
      positions.add(new PVector(x_position, y_position, z_position));
    }
    
    void draw_robot() {
      stroke(240,240,240);

      // Draw all the previous positions of robot to form a pipe shape
      int i = 0;
      for (PVector p : positions) {
        translate(p.x, p.y, p.z);
        if (i%10 == 0){
          strokeWeight(2);
          stroke(0,0,0);
        }else {
          strokeWeight(1);
          stroke(240,240,240);
        }
        fill(fake_data[i], (240-fake_data[i]), 0, 240);
        box(10, 10, 10);
        i++;
      } 
    }
    
    void move_robot() {

      if (encoder_counts - previous_counts > 325) {
        previous_counts = encoder_counts;
        if (float(direction) == 0) {
          positions.add(new PVector(0,0,1));
          z_position++;
        } else if (float(direction) == 1) {
          positions.add(new PVector(0,0, -1));
          z_position--;
        } else if (float(direction) == 2) {
          positions.add(new PVector(0,1,0));
          y_position++;
        } else if (float(direction) == 3) {
          positions.add(new PVector(0, -1,0));
          y_position--;
        } else if (float(direction) == 4) {
          positions.add(new PVector(1,0,0));
          x_position++;
        } else if (float(direction) == 5) {
          positions.add(new PVector( -1,0,0));
          x_position--;
        }
      }
    }
    private
    //Function prototypes ------------------------------------------
    
    
    //Variables ----------------------------------------------------
    ArrayList<PVector> positions = new ArrayList<PVector>();
    float x_position = 95;
    float y_position = 95;
    float z_position = -5; 
    
} 