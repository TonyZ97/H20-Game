class Button{ 
  final PFont BASEFONT = createFont("Arial", 16);
  final PFont SELECTEDFONT = createFont("Arial-Black", 16);
  
  int x, y;                 // The x- and y-coordinates of the Button in pixels
  int bWidth;                 // Dimensions in pixels
  int bHeight;
  color baseColor;           // Default color value 
  color overColor;           //Color when mouse over button
  color selectedColor;        //Color when button is selected
  String label;
  boolean over = false;     //true if mouse is over button
  
  Button(int xp, int yp, int w, int h, color c, color o, color s, String l) {
    x = xp;
    y = yp;
    bWidth = w+5;
    bHeight = h+5;
    baseColor = c;          //Default color
    overColor = o;           //Color when mouse over button
    selectedColor = s; 
    label = l;            //Color when button is in pushed state
  }
  
  boolean isOver(){
    return over;
  }
  
  void display() {
    stroke(255);
    strokeWeight(1.5);
    fill(255);  //Color of text label
    textAlign(LEFT,CENTER);
    if (pushed == this) { 
      stroke(90);
      strokeWeight(2.5);
      textFont(SELECTEDFONT);
      text(label, x+bWidth+8, y+(bHeight/2.)-3);
      fill(selectedColor);
    }else if (over) {
      textFont(BASEFONT);
      text(label, x+bWidth+5, y+(bHeight/2.)-1);
      fill(overColor);
    }else {
      textFont(BASEFONT);
      text(label, x+bWidth+5, y+(bHeight/2.)-1);
      fill(baseColor);
    }
    rect(x, y, bWidth, bHeight);
    update();
  }  
  
  // Updates the over field every frame
  void update() {
    if ((mouseX >= x-1) && (mouseX <= x+bWidth+textWidth(label)+8) && 
        (mouseY >= y-1) && (mouseY <= y+bHeight+1)) {
      over = true;
    } else
      over = false;
  }
} 