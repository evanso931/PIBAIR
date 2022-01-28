class RobotModel {  
  public

    // Constructor
    RobotModel(){}
  
    void draw_robot(){
        strokeWeight(2);
        translate(x_position,  y_position,  z_position);
        fill(240, 240, 240, 240);
        stroke(240,240,240);
        box(10, 10, 10);
    }

    void move_robot(){
        if (split_data[3] == null){
        }else if(float(split_data[3]) != 0){
            if(float(split_data[1]) < -50){
                z_position++;
            }else if(float(split_data[1]) > 50){
                z_position--;
            }else if (float(split_data[2]) < -45 && float(split_data[2]) > -135) {
                y_position++;
            }else if (float(split_data[2]) > 45 && float(split_data[2]) < 135) {
                y_position--;
            }else if (float(split_data[2]) < 45 && float(split_data[2]) > -45) {
                x_position--;
            }else if (float(split_data[2]) > 135 || float(split_data[2]) < -135) {
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