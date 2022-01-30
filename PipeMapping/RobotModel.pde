class RobotModel {  
  public

    // Constructor
    RobotModel(){
        posisions.add(new PVector(x_position, y_position, z_position));
    }
  
    void draw_robot(){
        strokeWeight(2);
        fill(240, 240, 240, 240);
        stroke(240,240,240);
        
        //println(x_position, " ", y_position, " ", z_position);
        for(PVector p:posisions){
            translate(p.x, p.y, p.z);
            println(p.x, " ", p.y, " ",p.z);
            box(10, 10, 10);
        } 
    }

    void move_robot(){
        if (split_data[3] == null){
        }else if(float(split_data[3]) != 0){
            if(float(split_data[1]) < -50){
                posisions.add(new PVector(0,0,1));
                z_position++;
            }else if(float(split_data[1]) > 50){
                posisions.add(new PVector(0,0,-1));
                z_position--;
            }else if (float(split_data[2]) < -45 && float(split_data[2]) > -135) {
                posisions.add(new PVector(0,1,0));
                y_position++;
            }else if (float(split_data[2]) > 45 && float(split_data[2]) < 135) {
                posisions.add(new PVector(0,-1,0));
                y_position--;
            }else if (float(split_data[2]) > 135 || float(split_data[2]) < -135) {
                posisions.add(new PVector(1,0,0));
                x_position++;
            }else if (float(split_data[2]) < 45 && float(split_data[2]) > -45) {
                posisions.add(new PVector(-1,0,0));
                x_position--;
            }
        }
    }

  private
  // Function prototypes ------------------------------------------


  // Variables ----------------------------------------------------
  ArrayList<PVector> posisions = new ArrayList<PVector>();
    float x_position = 95;
    float y_position = 95;
    float z_position = -5; 

} 