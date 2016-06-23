final int XPOS = 40;   //XPOS and ypos determines the position of the top left corner of the map, in pixels
final int YPOS = 40;
final int TILEWIDTH = 30;   //width of a tile in pixels
final int TILEHEIGHT = 30;    //height of a tile in pixels
final int XPOSB = XPOS + SIZEX*TILEWIDTH + 40;    //Drawing dimensions. XPOS and ypos are the coordinates of the top most button. 
final int YPOSB = 90;    //All buttons scale with respect to these

Button factoryB;
Button farmB;
Button houseB;
Button forestB;
Button demolishB;
Button resetB;

Toggle showPolT;
Toggle showDecayPolT;
Toggle showDistT;
Toggle showProfitT;


class GUI {
  final PFont AXISFONT = createFont("Calibri", 12);
  final PFont MESSAGEFONT = createFont("Calibri", 13);
  final PFont BIGFONT = createFont("Calibri-Bold", 20);
  final PFont NUMERALFONT = createFont("Courier", 30);
  
  GUI(int x, int y) {
    factoryB = new Button(XPOSB, YPOSB, TILEWIDTH, TILEHEIGHT, FACTORY_BROWN, #73A29C, #EA7E2F, "Factory");
    farmB = new Button(XPOSB, YPOSB + 60, TILEWIDTH, TILEHEIGHT, FARM_YELLOW, #73A29C, #F0AD1D, "Farm");
    houseB = new Button(XPOSB, YPOSB + 120, TILEWIDTH, TILEHEIGHT, HOUSE_GRAY, #73A29C, #90B3B4, "House");
    forestB = new Button(XPOSB, YPOSB + 180, TILEWIDTH, TILEHEIGHT, FOREST_GREEN, #73A29C, #02A002, "Forest");
    demolishB = new Button(XPOSB, YPOSB + 240, TILEWIDTH, TILEHEIGHT, DEMOLISH_BEIGE, #73A29C, #F5BB74, "Demolish");
    resetB = new Button(XPOSB+20, YPOS+TILEHEIGHT*SIZEY+40, TILEWIDTH + 5, TILEHEIGHT + 5, #FFFFFF, #989795, #171717, "RESET MAP");
    
    showPolT = new Toggle(XPOSB+260, YPOSB+690, "Show Pollution");
    showDecayPolT = new Toggle(XPOSB+260, YPOSB+750, "Show decayPollution");
    showDistT = new Toggle(XPOSB+260, YPOSB+810, "Show distToRiver");
    showProfitT = new Toggle(XPOSB+260, YPOSB+870, "Show Money");

    factoryS = new Slider(XPOSB+260, YPOSB, 0, 20, FACTORYPOLLUTION, "Factory", FACTORY_BROWN);
    farmS = new Slider(XPOSB+260, YPOSB + 60, 0, 20, FARMPOLLUTION, "Farm", FARM_YELLOW);
    houseS = new Slider(XPOSB+260, YPOSB + 120, 0, 20, HOUSEPOLLUTION, "House", HOUSE_GRAY);
    forestS = new Slider(XPOSB+260, YPOSB + 180, -10, 10, FORESTPOLLUTION, "Forest", FOREST_GREEN);
    
    fa = new Factory();     //T his would be resolved bty making calcActualProfit() static, but that will mess up Tile.changeLandU()
    fm = new Farm();
    hs = new House();
    fo = new Forest();
  }
  
  void render() {
    /* Draws all the graphics elements of each frame */    
    drawGameBoard();
    axisLabels();
    showSelectedTile();     //For unknown reasons, this MUST be called before the two highlight functions or they all break
    highlightSingle();
    highlightBulk();
    
    showFeedback();
    showActualProfits();
    showScore();
    showBuildQuota();
    showPollutionSlider();
    
    showToggleInfo();    
    
    showPolT.display();
    showDecayPolT.display();
    showDistT.display();
    showProfitT.display();
    
    factoryB.display();
    farmB.display();
    houseB.display();
    forestB.display();
    demolishB.display();
    resetB.display();
    
    factoryS.display();
    farmS.display();
    houseS.display();
    forestS.display();
  }
  
  
  //**** Draws elements of the game map  ****//  -----------------------------------------------
  void drawTile(int x, int y, color c, int t) {
    /* Draws a tile at Location <x, y> on game map, fill color c, transparency t */
    stroke(240);
    strokeWeight(0.5);
    fill(c, t);
    rect(x*TILEWIDTH + XPOS, y*TILEHEIGHT + YPOS, TILEWIDTH, TILEHEIGHT);
    fill(255);    //resets to white.
  } 
  
  void drawGameBoard(){
    /* Draws the game board */
    for (Tile[] tileRow : WS.gameMap) {
      for (Tile t: tileRow) {
        drawTile(t.getX(), t.getY(), t.getLandUse().getIcon(), 255);
      }
    }
  }
  
  void axisLabels() {
    /* Draws axis labels. */
    textFont(AXISFONT);
    textAlign(CENTER, BOTTOM);
    fill(255);
    int xcount = 0;  
    for (int x=XPOS; x < SIZEX*TILEWIDTH+XPOS; x+=TILEWIDTH){
      text(xcount, x+(TILEWIDTH/2), YPOS-3);
      xcount ++;
    }
    textAlign(RIGHT,CENTER);
    int ycount = 0;
    for (int y=YPOS; y < SIZEY*TILEHEIGHT+YPOS; y+=TILEHEIGHT){
      text(ycount, XPOS-7, y+(TILEHEIGHT/2));
      ycount ++;
    }
    textAlign(LEFT);
  }
    
   Factory fa;     //This would be resolved bty making calcActualProfit() static, but that will mess up Tile.changeLandU()
   Farm fm;
   House hs;
   Forest fo;
  
  void showSelectedTile() {    
    /* Accents the selected tile, displays tile information */
    //Draws the box
    stroke(255);
    fill(255);
    rect(XPOS+450, YPOS + SIZEY*TILEHEIGHT + 10, 190, 110);
    
    //Displays info
    if (selected != null) {
      drawTile(selected.getX(), selected.getY(), 255, 130);
      noFill();
      strokeWeight(1.5);
      stroke(245);
      rect(selected.getX()*TILEWIDTH + XPOS, selected.getY()*TILEHEIGHT + YPOS, TILEWIDTH, TILEHEIGHT);
      fill(0);  //Color of text 
      textFont(MESSAGEFONT);
      String text1 = selected.toString() + 
                    "     Type: " + selected.getLandUse().toString();
      text(text1, XPOS+460, YPOS + SIZEY*TILEHEIGHT + 30);   
      String text2 = "Money: " + nfc(selected.getActualProfit(),2) + 
                      "\nPollution: " + nfc(selected.getDecayPollution(),2) + 
                      "\nDistToRiver: " + nfc(selected.getDistToRiver(),2);
      text(text2, XPOS+460, YPOS + SIZEY*TILEHEIGHT + 50);
    }
  }
  
  void highlightSingle() {
    /* Accents the Tile mouse is over, displays purchase information if in purchase mode */
    Tile over = null;   //The Tile mouse is over
    String purchaseInfo = "";
    String pollutionInfo = "";
    float projectedProfit = 0;
    float projectedPollution = 0;
    if (mouseOverMap() && !mousePressed) {   //Highlight tile mouse is over
      int[] pos = converter(mouseX, mouseY);
      color hc;
      over = WS.gameMap[pos[0]][pos[1]];
        if (!(over.getLandUse() instanceof River)) {
           float d = over.getDistToRiver();
          if (pushed == factoryB) {
            hc = fa.getIcon();
            projectedProfit = fa.calcActualProfit(d);
            projectedPollution = calcDecayPollution(fa.s.getVal(), d);
            purchaseInfo = "Money: + $" + nfc(projectedProfit,2);
            pollutionInfo = "Pollution: + " + nfc(projectedPollution,2);
          }
          else if (pushed == farmB) {
            hc = fm.getIcon();
            projectedProfit = fm.calcActualProfit(d);
            projectedPollution = calcDecayPollution(fm.s.getVal(), d);
            purchaseInfo = "Money: + $" + nfc(projectedProfit,2);
            pollutionInfo = "Pollution: + " + nfc(projectedPollution,2);
          }
          else if (pushed == houseB) {
            hc = hs.getIcon();
            projectedProfit = hs.calcActualProfit(d);
            projectedPollution = calcDecayPollution(hs.s.getVal(), d);
            purchaseInfo = "Money: + $" + nfc(projectedProfit,2);
            pollutionInfo = "Pollution: + " + nfc(projectedPollution,2);
          }
          else if (pushed == forestB) {
            hc = fo.getIcon();
            projectedProfit = fo.calcActualProfit(d);
            projectedPollution = calcDecayPollution(fo.s.getVal(), d);
            purchaseInfo = "Money: - $" + nfc(abs(projectedProfit),2);
            pollutionInfo = "Pollution: - " + nfc(abs(projectedPollution),2);
          } else {                //Button not pressed
            hc = #B6FAB1;
            purchaseInfo = "";   
            pollutionInfo = "";
          }
        }else {    //Over the river
          hc = #B6FAB1;
          purchaseInfo = ""; 
          pollutionInfo = "";
        }
    drawTile(pos[0], pos[1], hc , 100);
    }
    textFont(MESSAGEFONT);
    fill(125);
    text(purchaseInfo, XPOS+460, YPOS + SIZEY*TILEHEIGHT + 90);  
    text(pollutionInfo, XPOS+460, YPOS + SIZEY*TILEHEIGHT + 110);
  }
  
  void highlightBulk() {
    /* Highlights tiles during click and drag, and shows bulk purchase info */
    if (mousePressed && mouseOverMap()) {
      int[] posP = converter(mousePX, mousePY);   //tile coordinate when mouse is pressed
      int[] posC = converter(mouseX, mouseY);     //current tile coordinate
      ArrayList<int[]> highlighted = new ArrayList<int[]>();
      if ((posP[0] >= 0 && posP[0] <SIZEX) && (posP[1] >= 0 && posP[1] < SIZEY)) {
        for (int x = min(posP[0], posC[0]); x <= max(posP[0], posC[0]); x++) {
          for (int y = min(posP[1], posC[1]); y <= max(posP[1], posC[1]); y++) {
            highlighted.add(new int[] {x, y});
          }
        }
      }
      String purchaseInfo = "";
      String pollutionInfo = "";
      float projectedProfit = 0;
      float projectedPollution = 0;
      color hc;       //Highlight color
      projectedProfit = 0;     //calculate purchase info
      projectedPollution = 0;
      for (int[] p : highlighted) {
        Tile t = WS.gameMap[p[0]][p[1]];
        float d = t.getDistToRiver();
        if (! (t.getLandUse() instanceof River)) {
          if  (pushed == factoryB) {    
            hc = FACTORY_BROWN;      //highlight color
            projectedProfit += fa.calcActualProfit(d);  
            projectedPollution += calcDecayPollution(fa.s.getVal(), d);
          } 
          else if (pushed == farmB) {
            hc = FARM_YELLOW;
            projectedProfit += fm.calcActualProfit(d);
            projectedPollution += calcDecayPollution(fm.s.getVal(), d);
          }
          else if (pushed == houseB) {
            hc = HOUSE_GRAY;
            projectedProfit += hs.calcActualProfit(d);
            projectedPollution += calcDecayPollution(hs.s.getVal(), d);
          }
          else if (pushed == forestB) {
            hc = #1EC610;
            projectedProfit += fo.calcActualProfit(d);
            projectedPollution += calcDecayPollution(fo.s.getVal(), d);
          }
          else if (pushed == demolishB){
            hc = DEMOLISH_BEIGE;
            purchaseInfo = "";   
            pollutionInfo = "";
          }
          else {
            hc = #B6FAB1;
            purchaseInfo = "";   //No button is pushed
            pollutionInfo = "";
          }
        }else {
          hc = #B6FAB1;
          projectedProfit += 0;
          projectedPollution += 0;
        }
        drawTile(p[0], p[1], hc, 100);    //draws highlighted tile
      }
      if (pushed != null && pushed != demolishB) {
        if (projectedProfit > 0) purchaseInfo = "Money: + $" + nfc(projectedProfit,2);
        else purchaseInfo = "Money: - $" + nfc(abs(projectedProfit),2);
        if (projectedPollution > 0)pollutionInfo = "Pollution: + " + nfc(projectedPollution,2);
        else pollutionInfo = "Pollution: - " + nfc(abs(projectedPollution),2);
        textFont(MESSAGEFONT);
        fill(125);
        text(purchaseInfo, XPOS+460, YPOS + SIZEY*TILEHEIGHT + 90);  
        text(pollutionInfo, XPOS+460, YPOS + SIZEY*TILEHEIGHT + 110); 
      }
    }
  }
  
   void showFeedback() {
     /*Draws the feedback box and shows info */
    stroke(255);
    fill(255);
    rect(XPOS, YPOS + SIZEY*TILEHEIGHT + 10, 430, 110);
    fill(0);  //Color of text 
    textFont(MESSAGEFONT);
    text(message, XPOS + 20, YPOS + SIZEY*TILEHEIGHT + 30);   
    text(message2, XPOS + 20, YPOS + SIZEY*TILEHEIGHT + 50);   
    text("Simple sum of all pollution: " + WS.totalPollution, XPOS + 20, YPOS + SIZEY*TILEHEIGHT + 90);
    text("Total pollution entering river after distance decay: " + nfc(WS.totalDecayPollution,2), XPOS + 20, YPOS + SIZEY*TILEHEIGHT + 110);
  }
  
  void showActualProfits() {
    /* Displays the money */
    int x = XPOS + SIZEX*TILEWIDTH + 40;
    int y = YPOSB + 460;
    fill(0);
    textFont(BIGFONT);
    text("Money: ", x, y);
    textFont(NUMERALFONT);
    text(nfc(WS.totalActualProfits,2), x, y+36);
  }
  
  void showScore() {
    /* Displays the score */
    int x = XPOS + SIZEX*TILEWIDTH + 40;
    int y = YPOSB + 550;
    fill(0);
    textFont(BIGFONT);
    text("Score: ", x, y);
    textFont(NUMERALFONT);
    text(nfc(WS.score,2), x, y+36);
  }
  
  void showBuildQuota() {
    /* Displays the build quota */
    int x = XPOS + SIZEX*TILEWIDTH + 40;
    int y = YPOSB + 690;
    fill(0);
    textFont(MESSAGEFONT);
    textSize(15);
    text("Factories: " + WS.factories + " / " + factoryQuota, x,y);
    text("Farms: " + WS.farms + " / " + farmQuota, x,y+30);
    text("Houses: " + WS.houses + " / " + houseQuota, x,y+60);
  }
  
  void showPollutionSlider() {
    /* Displays the pollution slider and indicator */
    color green = #4BDE4A;
    color red = #FF3300;
    color extreme = #A72200;
    int x =  XPOS + SIZEX*TILEWIDTH + 40;     //xposition of the slider
    int y = YPOSB + 340;       //YPOSition of the slider
    int w = 220;    //width of slider
    int h = 33;  //height if slider
    colorMode(HSB);
    
    //Draws the Slidier
    strokeWeight(1);
    for (float i = x; i <= x+w-w*0.25; i++) {     //Green to red portion
      float inter = map(i, x, x+w-w*0.25, 0, 1);
      color c = lerpColor(green, red, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
    for (float i = x+w-w*0.25; i <= x+w; i++) {       //Red to extreme portion
      float inter = map(i, x+w-w*0.25, x+w, 0, 1);
      color c = lerpColor(red, extreme, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
    stroke(255);
    noFill();
    rect(x-1, y-1, w+2, h+2);
    
    //Draws the needle
    stroke(50);
    strokeWeight(4);
    float scaleC = 1.5;    //Scaling constant that scales decayPollution number to pixel coordinates of slider
    float sliderX = x;    //xposition of the slider in pixels;
    sliderX = constrain(sliderX + scaleC*WS.totalDecayPollution, x, x+w);
    line(sliderX, y-5, sliderX, y+h+5);
    
    //Gives a text indicator:
    String pLevel;
    if (sliderX - x < w*0.2) {
      pLevel = "Healthy";
    } else if (sliderX - x < w*0.34){
      pLevel = "Okay";
    } else if (sliderX -x < w*0.55) {
      pLevel = "Moderate";
    } else if (sliderX-x < w*0.72) {
      pLevel = "Unhealthy";
    } else if (sliderX-x < w*0.89) {
      pLevel = "Severe"; 
    } else if (sliderX-x < w){
      pLevel = "Extreme" ;
    } else {
      pLevel = "Off the scale";
    }
    textFont(MESSAGEFONT);
    textSize(15);
    fill(0);
    text("Pollution indicator: " + pLevel, x, y+65);
  }

 //**** Some helper displays ****//  -----------------------------------------------
 void showToggleInfo() {
   if (toggled == showPolT) {
     showPollution();
   } else if (toggled == showDecayPolT) {
     showDecayPollution();
   } else if (toggled == showDistT) {
     showDist();
   }else if (toggled == showProfitT) {
     showProfit();
   }
 }
 
 void showPollution() {
   for (Tile[] tileRow : WS.gameMap) {
      for (Tile t: tileRow) {
        textFont(MESSAGEFONT);
        textSize(10);
        fill(0);
        textAlign(LEFT, TOP);
        if(t.getTilePollution()!=0) text(round(t.getTilePollution()), t.getX()*TILEWIDTH + XPOS+2, t.getY()*TILEHEIGHT + YPOS+1);
      }
   }
 }
 
 void showDecayPollution() {
   float total = 0.;
   for (Tile[] tileRow : WS.gameMap) {
      for (Tile t: tileRow) {
        textFont(MESSAGEFONT);
        textSize(10);
        fill(0);
        textAlign(LEFT, TOP);
        if(t.getTilePollution()!=0) text(nfc(t.getDecayPollution(),1), t.getX()*TILEWIDTH + XPOS+2, t.getY()*TILEHEIGHT + YPOS+1);
        total += t.getDecayPollution();
      }
   }
   text("Decay Pollution total " + total, 1300, 10);
 }
 
 void showDist() {
   for (Tile[] tileRow : WS.gameMap) {
      for (Tile t: tileRow) {
        textFont(MESSAGEFONT);
        textSize(10);
        fill(0);
        textAlign(LEFT, TOP);
        if (!(t.getLandUse() instanceof River)) text(nfc(t.getDistToRiver(),1), t.getX()*TILEWIDTH + XPOS+2, t.getY()*TILEHEIGHT + YPOS+1);
      }
   }
 }
 
 void showProfit() {
   for (Tile[] tileRow : WS.gameMap) {
      for (Tile t: tileRow) {
        textFont(MESSAGEFONT);
        textSize(10);
        fill(0);
        textAlign(LEFT, TOP);
        if (round(t.getActualProfit())!=0) text(nfc(t.getActualProfit(),1), t.getX()*TILEWIDTH + XPOS+2, t.getY()*TILEHEIGHT + YPOS+1);
      }
   }
 }
}

 
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
  
  void display() {
    stroke(255);
    strokeWeight(2);
    fill(255);  //Color of text label
    textAlign(LEFT,CENTER);
    if (pushed == this) { 
      stroke(135);
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
    } else {
      over = false;
    }
  }
} 


class Toggle {
  int x, y;                 // The x- and y-coordinates of the Button in pixels
  int tWidth;                 // Dimensions in pixels
  int tHeight;
  color baseColor;           // Default color value 
  color overColor;           //Color when mouse over button
  color selectedColor;        //Color when button is selected
  String label;
  PFont BASEFONT = createFont("Arial", 14);
  
  boolean over = false;     //true if mouse is over button
  
  Toggle(int xp, int yp, String l) {
    x = xp;
    y = yp;
    tWidth = 15;
    tHeight = 15;
    baseColor = 255;          //Default color
    overColor = 204;           //Color when mouse over button
    selectedColor = 0; 
    label = l;            //Color when button is in pushed state
  }
  
  void display() {
    ellipseMode(CORNER);
    stroke(255);
    strokeWeight(2);
    textFont(BASEFONT);
    fill(255);  //Color of text label
    textAlign(LEFT,CENTER);
    if (toggled == this) { 
      text(label, x+tWidth+5, y+(tHeight/2.)-1);
      fill(selectedColor);
    }else if (over) {
      text(label, x+tWidth+5, y+(tHeight/2.)-1);
      fill(overColor);
    }else {
      text(label, x+tWidth+5, y+(tHeight/2.)-1);
      fill(baseColor);
    }
    ellipse(x, y, tWidth, tHeight);
    update();
  }  
  
  // Updates the over field every frame
  boolean overEvent() {
    if (mouseX > x-3 && mouseX < x+tWidth+textWidth(label)+9 &&
       mouseY > y-5 && mouseY < y+tHeight+5) {
      return true;
    } else {
      return false;
    }
  }
  
  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
  }
}


 

//**** MOUSE INTERACTION  ****//  -----------------------------------------------
Tile selected = null;    //The current Tile that is selected. null if no Tile selected
Button pushed = null;   //The current button that is pushed. null if none is pushed.
Toggle toggled = null;   //The current toggle. null if none toggled

String message = "";
String message2 = "";
int mousePX;    // Mouse press positions
int mousePY;
int mouseRX;   //Mouse release positions
int mouseRY;

boolean mouseOverMap(){
  /* Helper function: Returns true if the mouse position is over the Watershed map. false otherwise. */
  int[] xRange = {XPOS, XPOS + SIZEX*TILEWIDTH};
  int[] yRange = {YPOS, YPOS + SIZEY*TILEHEIGHT};
  return ((mouseX > xRange[0] && mouseX < xRange[1]) && (mouseY > yRange[0] && mouseY < yRange[1]));
}

int[] converter(int xraw, int yraw) {
  /*Helper function: converts raw coordinates x and y in frame to tile locations   */
  if (mouseOverMap()){
    int xloc = 0;
    int yloc = 0;
    xloc = (xraw-XPOS)/TILEWIDTH;
    yloc = (yraw-YPOS)/TILEHEIGHT;
    int[] out = {xloc, yloc};
    return out;
  } else return new int[] {0,0};
}


void mousePressed() {  
  if (factoryB.over) {      //When factory button is clicked on
    if (pushed == factoryB) {
        message = "";
        pushed = null;
      } else {
    pushed = factoryB;
    message = "Add factory mode is selected";
    message2 = "";
      }
  }
  else if (farmB.over) {      //When farm button is clicked on
    if (pushed == farmB) {
        message = "";
        pushed = null;
      }else {
    pushed = farmB;
    message = "Add farm mode is selected";
    message2 = "";
      }
  }
  else if (houseB.over) {      //When house button is clicked on
    if (pushed == houseB) {
        message = "";
        pushed = null;
      } else {
    pushed = houseB;
    message = "Add house mode is selected";
    message2 = "";
      }
  }
  else if (forestB.over) {      //When forest button is clicked on
    if (pushed == forestB) {
        message = "";
        pushed = null;
      }else {
    pushed = forestB;
    message = "Add forest mode is selected";
    message2 = "";
      }
  }
  else if(demolishB.over) {   //When demolish button is clicked on
    if (pushed == demolishB) {
        message = "";
        pushed = null;
      } else {
    pushed = demolishB;
    message = "Demolish mode is selected";
    message2 = "";
      }
  }
  else if(resetB.over) {  //When reset button is clicked on
    if (pushed == resetB) {
      message = "Restarting game";
      message2 = "";
      WS = new Watershed(SIZEX, SIZEY);
      pushed = null;
      selected = null;
      message = "Game is reset";
      message2 = "";
    } else {
      pushed = resetB;
      message = "Do you want to reset the map? Click button again to reset.";
      message2 = "Click anywhere to cancel.";
    }
  }
  else if (mouseOverMap()){     //When mouse clicked on tile
    mousePX = mouseX;
    mousePY = mouseY;
    if (pushed == resetB) {
      message2 = "";
      message = "";
      pushed = null;
    }
  }
  else {
    if (pushed == resetB) {
      message2 = "";
    }
    pushed = null;
    message = "";
  }
  if (! mouseOverMap() && !factoryS.over && !farmS.over && !houseS.over && !forestS.over && !showPolT.over && !showDecayPolT.over && !showDistT.over && !showProfitT.over) selected = null;    //Unselect when I click outside map
}

void mouseReleased() {
  if (mouseOverMap() && mouseButton == LEFT){    //Left mouse button to add
    mouseRX = mouseX;
    mouseRY = mouseY;
    int[] posP = converter(mousePX, mousePY);
    int[] posR = converter(mouseRX, mouseRY);
    selected = WS.gameMap[posR[0]][posR[1]];
    int count = 0;
    String thing = "";
    boolean s = false;
    for (int x = min(posP[0], posR[0]); x <= max(posP[0], posR[0]); x++) {
      for (int y = min(posP[1], posR[1]); y <= max(posP[1], posR[1]); y++) {
        if (pushed == factoryB) {        //If factory button is in pressed state
          s = WS.addFactory(x, y);      //count++ only when true
          if (s) count ++;
          thing = "Factories";
        } 
        else if (pushed == farmB) {        //If farm button is in pressed state
          s = WS.addFarm(x, y);
          if (s) count ++;
          thing = "Farms";
        }
        else if (pushed == houseB) {        //If house button is in pressed state
          s = WS.addHouse(x, y);
          if (s) count ++;
          thing = "Houses";
        }
        else if (pushed == forestB) {        //If forest button is in pressed state
          s = WS.addForest(x, y);
          if (s) count ++;
          thing = "Forests";
        }
        else if(pushed == demolishB) {    //If demolish button is in pressed state
          s = WS.removeLandUse(x,y);
          if (s) count ++;
        }
      }
    }
    if (pushed == null) {
      selected = WS.gameMap[posR[0]][posR[1]];     //Select tile if no button is pushed and clicked inside map
    } 
    if (pushed != null) selected = null;     //Remove selection when building things
    
    if (count > 1 || (count == 1 && s == false)) {  //Different message if multiple objects 
      message2 = "Added " + Integer.toString(count) + " " + thing;    
      if (pushed == demolishB) message2 = "Removed land use at " + Integer.toString(count) + " locations";
    }    
  }
  if (mouseButton == RIGHT) {    //Right mouse button to cancel selection and button pushed
    message = "";
    pushed = null;
    selected = null;
  }
}

void mouseClicked() {
  if (showPolT.over) {
    if (toggled == showPolT) toggled = null;
    else toggled = showPolT;
  }else if (showDecayPolT.over) {
    if (toggled == showDecayPolT) toggled = null;
    else toggled = showDecayPolT;
  }else if (showDistT.over) {
    if (toggled == showDistT) toggled = null;
    else toggled = showDistT;
  }else if (showProfitT.over) {
    if (toggled == showProfitT) toggled = null;
    else toggled = showProfitT;
  }
}