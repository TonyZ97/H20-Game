static final int XPOS = 40;   //XPOS and ypos determines the position of the top left corner of the map, in pixels
static final int YPOS = 30;
static final int TILE_WIDTH = 26;   //width of a tile in pixels
static final int TILE_HEIGHT = 26;    //height of a tile in pixels
static final int XPOSB = XPOS + SIZE_X*TILE_WIDTH + 40;    //Drawing dimensions. XPOS and ypos are the coordinates of the top most button. 
static final int YPOSB = 60;    //All objects scale with respect to these
static final color DEFAULT_HIGHLIGHT = #E5FCFC;   // Default color to highllight Tiles with


class GUI {
  Watershed waterS;
  
  final PFont AXISFONT = createFont("Calibri", 12);
  final PFont MESSAGEFONT = createFont("Calibri", 14);
  final PFont BIGFONT = createFont("Calibri-Bold", 20);
  final PFont NUMERALFONT = createFont("Courier", 30);
  
  final Button FACTORY_BUTTON = new Button(XPOSB, YPOSB, TILE_WIDTH, TILE_HEIGHT, FACTORY_BROWN, #73A29C, #EA7E2F, "Factory");
  final Button FARM_BUTTON = new Button(XPOSB, YPOSB + 60, TILE_WIDTH, TILE_HEIGHT, FARM_YELLOW, #73A29C, #F0AD1D, "Farm");
  final Button HOUSE_BUTTON = new Button(XPOSB, YPOSB + 120, TILE_WIDTH, TILE_HEIGHT, HOUSE_GRAY, #73A29C, #90B3B4, "House");
  final Button FOREST_BUTTON = new Button(XPOSB, YPOSB + 180, TILE_WIDTH, TILE_HEIGHT, FOREST_GREEN, #73A29C, #02A002, "Forest");
  final Button DEMOLISH_BUTTON = new Button(XPOSB, YPOSB + 240, TILE_WIDTH, TILE_HEIGHT, DEMOLISH_BEIGE, #73A29C, #F5BB74, "Demolish");
  final Button RESET_BUTTON = new Button(XPOSB+220, YPOS+TILE_HEIGHT*SIZE_Y-57, TILE_WIDTH + 5, TILE_HEIGHT + 5, #FFFFFF, #989795, #171717, "RESET MAP");
      
  final Toggle POLLUTION_TOGGLE = new Toggle(XPOSB+180, YPOSB+450, "Show Pollution");
  final Toggle DECAYPOL_TOGGLE = new Toggle(XPOSB+180, YPOSB+500, "Show decayPollution");
  final Toggle DIST_TOGGLE = new Toggle(XPOSB+180, YPOSB+550, "Show distToRiver");
  final Toggle PROFIT_TOGGLE = new Toggle(XPOSB+180, YPOSB+600, "Show Money");
  final Toggle SLIDER_TOGGLE = new Toggle(XPOSB+160, YPOSB+240, "Show sliders");
  
  final Slider FACTORY_SLIDER = new Slider(FACTORY, XPOSB+140, YPOSB, 0, 20, FACTORY_BROWN);
  final Slider FARM_SLIDER = new Slider(FARM, XPOSB+140, YPOSB + 60, 0, 20, FARM_YELLOW);
  final Slider HOUSE_SLIDER = new Slider(HOUSE, XPOSB+140, YPOSB + 120, 0, 20, HOUSE_GRAY);
  final Slider FOREST_SLIDER = new Slider(FOREST, XPOSB+140, YPOSB + 180, -10, 10, FOREST_GREEN);
  
  
  final GameBoard GAME_BOARD = new GameBoard(XPOS, YPOS, SIZE_X*TILE_WIDTH, SIZE_Y*TILE_HEIGHT);
  final InfoBox INFO_BOX = new InfoBox(XPOS+455, YPOS + SIZE_Y*TILE_HEIGHT + 10);
  final FeedbackBox FEEDBACK_BOX = new FeedbackBox(XPOS, YPOS + SIZE_Y*TILE_HEIGHT + 10);
  final Dashboard DASHBOARD = new Dashboard(XPOS + SIZE_X*TILE_WIDTH + 40, YPOSB + 340);

  
  GUI(Watershed WS) {
    waterS = WS;   
  }
  
  void render() {
    /* Draws all the graphics elements of each frame */   
    GAME_BOARD.display();
    INFO_BOX.display();
    FEEDBACK_BOX.display();
    DASHBOARD.display();
    
    FACTORY_BUTTON.display();
    FARM_BUTTON.display();
    HOUSE_BUTTON.display();
    FOREST_BUTTON.display();
    DEMOLISH_BUTTON.display();
    RESET_BUTTON.display();
    
    POLLUTION_TOGGLE.display();
    DECAYPOL_TOGGLE.display();
    DIST_TOGGLE.display();
    PROFIT_TOGGLE.display();
    SLIDER_TOGGLE.display();
    
    if (showSlider == true) {
      FACTORY_SLIDER.display();
      FARM_SLIDER.display();
      HOUSE_SLIDER.display();
      FOREST_SLIDER.display();
    }
  }


  
  class GameBoard {
    /* Draws the game board */
    int xpos;
    int ypos;
    int wide;
    int tall;
    int tileW = wide/SIZE_X;
    int tileH = tall/SIZE_Y;
    
    ArrayList<int[]>  highlightThese = new ArrayList<int[]>();    // A list containing all the Tiles that are to be highlighted, each element is of format {posX, posY, color}
    
    GameBoard(int x, int y, int w, int t) {
      xpos = x;
      ypos = y;
      wide = w;
      tall = t;
      tileW = round(wide/(float)SIZE_X);
      tileH = round(tall/(float)SIZE_Y);
    }
    
    int[] getXRange(){
      return new int[] {xpos, xpos+tileW*SIZE_X};
    }
    
    int[] getYRange(){
      return new int[] {ypos, ypos+tileH*SIZE_Y};
    }
 
    void display() {
      drawGameBoard();
      drawAxisLabels();
      highlight();
      showSelectedTile();
      showToggleInfo();
    }
      
    void drawGameBoard(){
      /* Draws the game board */
      for (Tile t: waterS.getAllTiles()) 
        drawTile(t.getX(), t.getY(), t.getLandUse().getIcon(), 255);
    }
    
     void drawTile(int x, int y, color c, int t) {
      /* Draws a tile at Location <x, y> on game map, fill color c, transparency t */
      stroke(240);
      strokeWeight(0.5);
      fill(c, t);
      rect(x*tileW+xpos, y*tileH+ypos, tileW, tileH);
      fill(255);    //resets to white.
    } 
    
    void drawAxisLabels() {
      /* Draws axis labels. */
      textFont(AXISFONT);
      textAlign(CENTER, BOTTOM);
      fill(255);
      for (int x=0; x < SIZE_X; x++){
        text(x, xpos+x*tileW+(tileW/2), ypos-3);
      }
      textAlign(RIGHT,CENTER);
      for (int y=0; y < SIZE_Y; y++){
        text(y, xpos-7, ypos+y*tileH+(tileH/2));
      }
      textAlign(LEFT);
    }
    
    void highlight() {
      /* Hightlights all the Tiles with color hc (during click and drag) */
      for (int [] e : highlightThese){
        drawTile(e[0], e[1], e[2], 100);
      }
      highlightThese = new ArrayList<int[]>();     //Clear list after highlighting all its Tiles
    }
    
    void showSelectedTile() {    
    /* Accents the selected tile */
      if (selected != null){
        drawTile(selected.getX(), selected.getY(), 255, 130);
        noFill();
        strokeWeight(1.5);
        stroke(245);
        rect(selected.getX()*tileW + xpos, selected.getY()*tileH + ypos, tileW, tileH);
      }
    }

    void highlightTile(Tile t, color hc) {
      /* Instructs GameBoard to highlight Tile t with color hc */
      highlightThese.add(new int[] {t.getX(), t.getY(), hc});
    }
    
    Tile[] getHighlightedTiles(){
      /* Returns an array of the Tiles that are highlighted */
      Tile[] tiles = new Tile[highlightThese.size()];
      int i = 0;
      for (int[] e : highlightThese){
        tiles[i] = waterS.getTile(e[0], e[1]);
        i++;
      }
    return tiles;
    }
    
    void showToggleInfo() {
      /* Displays the appropriate information of each Tile */
      if (toggled == POLLUTION_TOGGLE) {
        showPollution();
      }else if (toggled == DECAYPOL_TOGGLE) {
        showDecayPollution();
      }else if (toggled == DIST_TOGGLE) {
        showDist();
      }else if (toggled == PROFIT_TOGGLE) {
        showProfit();
      }
    }
    
    void showPollution() {
      for (Tile t: waterS.getAllTiles()) {
        textFont(MESSAGEFONT);
        textSize(10);
        fill(0);
        textAlign(LEFT, TOP);
        int p = round(t.getBasePollution());
        if(p != 0) 
          text(p, t.getX()*tileW + xpos+2, t.getY()*tileH + ypos+1);
      }
    }
    void showDecayPollution() {
      float total = 0.;
      for (Tile t: waterS.getAllTiles()) {
        textFont(MESSAGEFONT);
        textSize(10);
        fill(0);
        textAlign(LEFT, TOP);
        if(t.getBasePollution()!=0) 
          text(nfc(t.getDecayPollution(),1), t.getX()*tileW + xpos+2, t.getY()*tileH + ypos+1);
        total += t.getDecayPollution();
      }
    }
     
    void showDist() {
      for (Tile t: waterS.getAllTiles()) {
        textFont(MESSAGEFONT);
        textSize(10);
        fill(0);
        textAlign(LEFT, TOP);
        if (!(t.getLandUse() instanceof River)) 
          text(nfc(t.distToRiver(),1), t.getX()*tileW + xpos+2, t.getY()*tileH + ypos+1);
      }
    }
     
     void showProfit() {
      for (Tile t: waterS.getAllTiles()) {
        textFont(MESSAGEFONT);
        textSize(9);
        fill(0);
        textAlign(LEFT, TOP);
        if (round(t.getActualProfit())!=0) 
          text(round(t.getActualProfit()), t.getX()*tileW + xpos+2, t.getY()*tileH + ypos+1);
      }
    }
  }// END OF GAMEBOARD NESTED CLASS

  class InfoBox{
    /* Draws box and displays selected Tile info and prePurchaseInfo */
    int xpos;
    int ypos;
    int wide = 200;
    int tall = 115;
    
    float projectedProfit = 0;
    float projectedPollution = 0;
    boolean showPrePurchase = false;
    
    InfoBox(int x, int y) {
      xpos = x;
      ypos = y;
    }

    void display(){
     /* Draws box and displays selected Tile info and prePurchaseInfo */
      stroke(255);
      strokeWeight(1);
      fill(255);
      rect(xpos, ypos, wide, tall);
      showPrePurchaseInfo();
      showTileInfo();
    }
    
    void showTileInfo() {    
      /* Displays information of selected Tile */
      if (selected != null) {
        fill(0);  //Color of text 
        textAlign(CORNER);
        textFont(MESSAGEFONT);
        String text1 = selected.toString() + 
                      "     Type: " + selected.getLandUse().toString();
        text(text1, xpos+15, ypos+25);   
        String text2 = "Money: $" + round(selected.getActualProfit()) + 
                        "\ndecayPollution: " + nfc(selected.getDecayPollution(),2) + 
                        "\nDistToRiver: " + nfc(selected.distToRiver(),2);
        text(text2, xpos+15, ypos+55);
      }
    }

    void showPrePurchaseInfo(){
      /* Displays information about purchase when in add mode */
      if (showPrePurchase){
        String purchaseInfo = "";
        String pollutionInfo = "";
        if (pushed != DEMOLISH_BUTTON) {
          if (projectedProfit >= 0) purchaseInfo = "Money: + $" + nfc(round(projectedProfit));
          else purchaseInfo = "Money: - $" + nfc(abs(projectedProfit),2);
          if (projectedPollution >= 0)pollutionInfo = "Pollution: + " + nfc(projectedPollution,2);
          else pollutionInfo = "Pollution: - " + nfc(abs(projectedPollution),2);
        }
        if (GAME_BOARD.getHighlightedTiles().length == 1 && GAME_BOARD.getHighlightedTiles()[0].isRiver()){  
          purchaseInfo = ""; 
          pollutionInfo = "";
        }// Empty message when only one River Tile is highlighted
        
        textFont(MESSAGEFONT);
        fill(125);
        textAlign(CORNER);
        text(purchaseInfo, xpos+15, ypos+80);  
        text(pollutionInfo, xpos+15, ypos+100);
        showPrePurchase = false;
      }
    }
    
    void setProjected(float profit, float pollution){
      /* Sets the projected values and displays them */
      projectedProfit = profit;
      projectedPollution = pollution;
      showPrePurchase = true;
    }
  } //END OF NESTED CLASS INFO_BOX
    
  
  class FeedbackBox {
    int xpos;
    int ypos;
    int wide = 440;
    int tall = 115;
    
    String modeMessage = "";
    String actionMessage = "";
    
    FeedbackBox(int x, int y) {
      xpos = x;
      ypos = y;
    }
    
    void display() {
       /*Draws the feedback box and shows messages */
      stroke(255);
      fill(255);
      rect(xpos, ypos, wide, tall);
      fill(0);  //Color of text 
      textFont(MESSAGEFONT);
      textAlign(CORNER);
      text(modeMessage, xpos+15, ypos+25);   
      text(actionMessage, xpos+15, ypos+45);   
      text("Simple sum of all pollution: " + waterS.sumTotalPollution(), xpos+15, ypos+80);
      text("Total pollution entering river after distance decay: " + nfc(waterS.sumDecayPollution(),2), xpos+15,ypos+100);
    }
    
    void setModeMessage(String m){
      modeMessage = m;
    }
    
    void setActionMessage(String m){
      actionMessage = m;
    }
  }//END OF NESTED CLASS FEEDBACK_BOX
  
  
  class Dashboard {
    /* Displays information such as Score, Money and Quotas */
    int xpos;
    int ypos;
    
    Dashboard(int x, int y) {
      xpos = x;
      ypos = y;
    }
    
    void display(){
      showActualProfits();
      showScore();
      showBuildQuota();
      showPollutionSlider();
      drawDividers();
    }
    
    void showPollutionSlider() {
      /* Displays the pollution indicator */
      color green = #4BDE4A;
      color red = #FF3300;
      color extreme = #A72200;
      int x =  xpos;     //xposition of the slider
      int y = ypos;       //YPOSition of the slider
      int w = 220;    //width of slider
      int h = 33;  //height if slider
      int polMax = 1200;  // The maximum pollution the slider can handle
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
      float scaleC = polMax/(float)w;    //Scaling constant that scales decayPollution number to pixel coordinates of slider
      float sliderX = x;    //xposition of the slider in pixels;
      sliderX = constrain(sliderX + waterS.sumDecayPollution()/scaleC, x, x+w);
      line(sliderX, y-5, sliderX, y+h+5);
      
      //Gives a text indicator:
      String pLevel;
      if ((sliderX - x)*scaleC < polMax*0.2) {
        pLevel = "Healthy";
      } else if ((sliderX - x)*scaleC < polMax*0.34){
        pLevel = "Okay";
      } else if ((sliderX - x)*scaleC < polMax*0.52) {
        pLevel = "Moderate";
      } else if ((sliderX - x)*scaleC < polMax*0.70) {
        pLevel = "Unhealthy";
      } else if ((sliderX - x)*scaleC < polMax*0.89) {
        pLevel = "Severe"; 
      } else if ((sliderX - x)*scaleC < polMax){
        pLevel = "Dangerous" ;
      } else {
        pLevel = "Off the scale";
      }
      textFont(MESSAGEFONT);
      textSize(15);
      fill(0);
      text("Pollution indicator: " + pLevel, x, y+65);
    }
    
    void showActualProfits() {
      /* Displays the money */
      int x = xpos;
      int y = ypos + 120;
      fill(0);
      textFont(BIGFONT);
      textAlign(CORNER);
      text("Money: ", x, y);
      textFont(NUMERALFONT);
      text("$"+nfc(round(waterS.sumActualProfits())), x, y+36);
    }
    
    void showScore() {
      /* Displays the score */
      int x = xpos;
      int y = ypos + 210;
      fill(0);
      textFont(BIGFONT);
      textAlign(CORNER);
      text("Score: ", x, y);
      textFont(NUMERALFONT);
      text(nfc(round(waterS.calcScore())), x, y+36);
    }
    
    void showBuildQuota() {
      /* Displays the build quota */
      int x = xpos;
      int y = ypos + 300;
      fill(0);
      textFont(BIGFONT);
      textAlign(CORNER);
      text("Quota: ", x, y);
      textFont(MESSAGEFONT);
      textSize(16);
      text("  Factories: " + waterS.countFactories() + " / " + FACTORY_QUOTA, x,y+30);
      text("  Farms: " + waterS.countFARM_SLIDER() + " / " + FARM_QUOTA, x,y+60);
      text("  Houses: " + waterS.countHOUSE_SLIDER() + " / " + HOUSE_QUOTA, x,y+90);
    }
    
    void drawDividers(){ 
      noFill();
      stroke(204);
      strokeWeight(1);
      rect(xpos-20, ypos - 365, 392, TILE_HEIGHT*SIZE_Y);
      line(xpos-20, ypos+TILE_HEIGHT+5+270-350, xpos-20+392, ypos+TILE_HEIGHT+5+270-350);
    }
  }//END OF NESTED CLASS DASHBOARD
}//END OF GUI CLASS