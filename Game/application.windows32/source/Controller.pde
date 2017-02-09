Tile selected = null;    //The current Tile that is selected. null if no Tile selected
Button pushed = null;   //The current button that is pushed. null if none is pushed.
Toggle toggled = null;   //The current toggle. null if none toggled
boolean showSlider = false;   //Show sliders?

class Controller{
  Watershed waterS;
  GUI view;

  int mousePX;    // Mouse press positions
  int mousePY;
  int mouseRX;   //Mouse release positions
  int mouseRY;
  
  final TileController TILE_CONTROLLER = new TileController();
  final LandUseController LU_CONTROLLER =  new LandUseController();
  final SliderController SLIDE_CONTROLLER = new SliderController();
  final ButtonController BUTTON_CONTROLLER = new ButtonController();
  final ToggleController TOGGLE_CONTROLLER = new ToggleController();


  Controller(Watershed ws, GUI g) {
    waterS = ws;
    view = g;
  }
  
  void eventLoop() {
    /* Perform these actions on mouse input */
    TILE_CONTROLLER.run();
    LU_CONTROLLER.run();
    SLIDE_CONTROLLER.run();
  }
  
  void actionOnPress(){
    /* Perform these actions on mousePress */
    BUTTON_CONTROLLER.actionOnPress();
  }
  
  void actionOnRelease(){
    /* Perform these actions on mouseRelease */
    TILE_CONTROLLER.actionOnRelease();
    LU_CONTROLLER.actionOnRelease();
  }
  
  void actionOnClick(){
    /* Perform these actions on mouseClick */
    TOGGLE_CONTROLLER.actionOnClick();
  }
  
  boolean mouseOverMap(){
    /* Returns true if the mouse position is over the Watershed map. False otherwise. */
    int[] xRange = view.GAME_BOARD.getXRange();
    int[] yRange =  view.GAME_BOARD.getYRange();
    return ((mouseX > xRange[0] && mouseX < xRange[1]) && (mouseY > yRange[0] && mouseY < yRange[1]));
  }
  

  
  boolean inAddMode(){
    /* Returns true if an adder button is pushed (includes demolish). False otherwise */
    return pushed == view.FACTORY_BUTTON ||
           pushed == view.FARM_BUTTON ||
           pushed == view.HOUSE_BUTTON ||
           pushed == view.FOREST_BUTTON ||
           pushed == view.DEMOLISH_BUTTON;
  }
  
  Button getOverButton() {
    /* Returns Button mouse is over, null if mouse not over any button*/
    Button over = null;
    if (view.FACTORY_BUTTON.isOver()) over = view.FACTORY_BUTTON;
    if (view.FARM_BUTTON.isOver()) over = view.FARM_BUTTON;
    if (view.HOUSE_BUTTON.isOver()) over = view.HOUSE_BUTTON;
    if (view.FOREST_BUTTON.isOver()) over = view.FOREST_BUTTON;
    if (view.DEMOLISH_BUTTON.isOver()) over = view.DEMOLISH_BUTTON;
    if (view.RESET_BUTTON.isOver()) over = view.RESET_BUTTON;
    return over;
  }
  
  int[] converter(int xRaw, int yRaw) {
    /*Converts raw coordinates x and y in frame to tile locations   */
    if (mouseOverMap()){
      int xMin = view.GAME_BOARD.getXRange()[0];
      int xMax = view.GAME_BOARD.getXRange()[1];
      int yMin = view.GAME_BOARD.getYRange()[0];
      int yMax = view.GAME_BOARD.getYRange()[1];
      int tileW = round((xMax - xMin)/(float)SIZE_X);
      int tileH = round((yMax - yMin)/(float)SIZE_Y);
      int xloc = constrain((xRaw-xMin)/tileW, 0, SIZE_X-1);
      int yloc = constrain((yRaw-yMin)/tileH, 0, SIZE_Y-1);
      int[] out = {xloc, yloc};
      return out;
    }return new int[] {0,0};
  }
  
  Tile getOverTile(){
    /* Returns the Tile the mouse is hovering over if mouseOverMap, null otherwise */
    if (mouseOverMap()) {
      int[] pos = converter(mouseX, mouseY);
      return waterS.getTile(pos[0], pos[1]);
    } return null;
  }
  
  ArrayList<Tile> getDraggedTiles(){
    /* Returns a list of tiles that are highlighted during click and drag */
    ArrayList<Tile> tlist= new ArrayList<Tile>();
    if (mousePressed && mouseOverMap()) {    
      int[] posP = converter(mousePX, mousePY);   //tile coordinate when mouse is pressed
      int[] posC = converter(mouseX, mouseY);     //current tile coordinate
      for (int x = min(posP[0], posC[0]); x <= max(posP[0], posC[0]); x++) {
        for (int y = min(posP[1], posC[1]); y <= max(posP[1], posC[1]); y++) {
          tlist.add(waterS.getTile(x, y));
        }
      }// for all tiles to highlight
    }// if mouse dragged over map
    return tlist;
  }

  class TileController {
    /* Decides which Tiles to highlight and select, and instructs GUI to update view appropriately */
  
    void run(){
      highlightSingleTile();
      highlightManyTiles();
    }
    
    void actionOnRelease(){
      selectTile();
    }
    
    void highlight(Tile t, color highlightColor){
      /* Instructs GUI the Tile to highlight and its color */
       view.GAME_BOARD.highlightTile(t, highlightColor);
    }

    void highlightSingleTile() {
      /* Decides which Tile to highlight when mouse is over map */
      if (mouseOverMap() && !mousePressed) {
        color highlightColor;
        Tile t = getOverTile();
        if (inAddMode() && (!t.isRiver()))   //Change highlight color when in add mode but not over River
          highlightColor = pushed.baseColor;
        else highlightColor = DEFAULT_HIGHLIGHT;
        highlight(t, highlightColor);
      }
    }
    
    void highlightManyTiles() {
      /* Decides what Tiles to highlight when mouse is dragged, and instructs GUI to highlight it */
      if (mousePressed && mouseOverMap()) {    
        color highlightColor;
        for (Tile t : getDraggedTiles()){
          if (inAddMode() && (!t.isRiver()))   //Change highlight color when in add mode but not over River
            highlightColor = pushed.baseColor;
          else highlightColor = DEFAULT_HIGHLIGHT;
         highlight(t, highlightColor);
        }// for all tiles to highlight
      }// if mouse dragged over map
    } 
    
    void selectTile(){
      /* Logic for selecting a tile when not in add mode */
      if (control.mouseOverMap() && mouseButton == LEFT){ 
        if (pushed == null) {
        selected = getOverTile();     //Select tile if no button is pushed and clicked inside map
        } 
        if (pushed != null) 
          selected = null;     //Remove selection when building things
      }
      if (mouseButton == RIGHT) {    //Right mouse button to cancel selection
        view.FEEDBACK_BOX.setModeMessage("");
        pushed = null;
        selected = null;
      }
      if (! mouseOverMap() && 
          !view.FACTORY_SLIDER.over && !view.FARM_SLIDER.over && !view.HOUSE_SLIDER.over && !view.FOREST_SLIDER.over && 
          !view.POLLUTION_TOGGLE.over && !view.DECAYPOL_TOGGLE.over && !view.DIST_TOGGLE.over && !view.PROFIT_TOGGLE.over && !view.SLIDER_TOGGLE.over)
        selected = null;    //Unselect when I click outside map
    }
  }  //END OF NESTED CLASS TILE_CONTROLLER


  class LandUseController {
    /* Calculates projected values, updates view and model on changing LandUse */
    
    void run(){
      calcAddInfo(getProspectiveTiles());
    }
    
    void actionOnRelease(){
      addStuff();
    }
    
    ArrayList<Tile> getProspectiveTiles(){
      /* Returns an array of Tiles to calculate projected values, including both mouse hover and mouse drag cases */
      ArrayList<Tile> tlist = new ArrayList<Tile>();
      if (mouseOverMap() && inAddMode()) {
        tlist = getDraggedTiles();  //Tiles to calculate info for
        if (!mousePressed) tlist.add(getOverTile());     //Include info for tile mouse is over when mouse is not dragged
      }
      return tlist;
    }
    
    void calcAddInfo(ArrayList<Tile> prospectiveTiles){
      /* Calculates projected values, instructs INFO_BOX to display them */
      float projectedProfit = 0;
      float projectedPollution = 0;
      if (mouseOverMap() && inAddMode()) {
        for (Tile t : prospectiveTiles){
          float d = t.distToRiver();
          if (! t.isRiver()){
            if  (pushed == view.FACTORY_BUTTON) {    
              projectedProfit += FACTORY.calcActualProfit(d);  
              projectedPollution += FACTORY.calcDecayPollution(d);
            } 
            else if (pushed == view.FARM_BUTTON) {
              projectedProfit += FARM.calcActualProfit(d);
              projectedPollution += FARM.calcDecayPollution( d);
            }
            else if (pushed == view.HOUSE_BUTTON) {
              projectedProfit += HOUSE.calcActualProfit(d);
              projectedPollution += HOUSE.calcDecayPollution(d);
            }
            else if (pushed == view.FOREST_BUTTON) {
              projectedProfit += FOREST.calcActualProfit(d);
              projectedPollution += FOREST.calcDecayPollution(d);
            }   //Calculations for each button
          }else {    //Don't sum when over River
            projectedProfit += 0;
            projectedPollution += 0;
          }
        }// for all tiles
        view.INFO_BOX.setProjected(projectedProfit, projectedPollution);
      }// if mouse over map and in add mode
    }

    void addStuff(){
      /* Logic to change LandUses and display appropriate feebback */
      if (control.mouseOverMap() && mouseButton == LEFT && inAddMode()){    //Left mouse button to add
        int[] posP = control.converter(mousePX, mousePY);     //Mouse press position
        int[] posR = control.converter(mouseRX, mouseRY);    //Mouse release position
        LandUse olu = null;  //Original landuse of tile
        int count = 0;    //Number of landUses add/removed
        String thing = "";  
        boolean s = false;
        int i = 0; 
        int j = 0;      
        int m = 0;
        for (int x = min(posP[0], posR[0]); x <= max(posP[0], posR[0]); x++) {
          for (int y = min(posP[1], posR[1]); y <= max(posP[1], posR[1]); y++) {
            m++;
            if (m<2) olu = waterS.getTile(x,y).getLandUse();    //I only have to remember previous landuse when I only change one Tile
            if (pushed == view.FACTORY_BUTTON) {        //If factory button is in pressed state
              s = WS.addFactory(x, y);      //count++ only when true
              if (s) {
                count ++;   //increment and save coordinates if successful
                i = x;
                j = y;
              }
              thing = "Factory";
              if (count > 1) thing = "Factories";
            } 
            else if (pushed == view.FARM_BUTTON) {        //If farm button is in pressed state
              s = WS.addFarm(x, y);
               if (s) {
                count ++;
                i = x;
                j = y;
              }
              thing = "Farm";
              if (count > 1) thing = "Farms";
            }
            else if (pushed == view.HOUSE_BUTTON) {        //If house button is in pressed state
              s = WS.addHouse(x, y);
               if (s) {
                count ++;
                i = x;
                j = y;
              }
              thing = "House";
              if (count > 1) thing = "Houses";
            }
            else if (pushed == view.FOREST_BUTTON) {        //If forest button is in pressed state
              s = WS.addForest(x, y);
              if (s) {
                count ++;
                i = x;
                j = y;
              }
              thing = "Forest";
              if (count > 1) thing = "Forests";
            }
            else if(pushed == view.DEMOLISH_BUTTON) {    //If demolish button is in pressed state
              LandUse temp = waterS.getTile(x,y).getLandUse();
              s = WS.removeLandUse(x,y);
               if (s) {
                count ++;
                i =  x;
                j = y;
              }
              if (s) olu = temp;   //remember previous landuse if successful
            }
          }
        }   //for all Tiles to add landuse
        
        // Set messages to display
        if (count > 1) {
          view.FEEDBACK_BOX.setActionMessage("Built " + Integer.toString(count) + " " + thing);    
          if (pushed == view.DEMOLISH_BUTTON) 
            view.FEEDBACK_BOX.setActionMessage("Removed land use at " + Integer.toString(count) + " locations");
        }  //count > 1
        else if (count == 1){
          view.FEEDBACK_BOX.setActionMessage("Added a " + thing + " at " + "<" +(i)+ ", " +(j)+ ">");  
          if (pushed == view.DEMOLISH_BUTTON) 
            view.FEEDBACK_BOX.setActionMessage("Removed " + olu.toString() + " at " + "<" +(i)+ ", " +(j)+ ">");  
        }  // count == 1
        else {
          //When quota is full
          view.FEEDBACK_BOX.setActionMessage("Quota is full");
          //When attempting build on River
          if (olu.isRiver())
             view.FEEDBACK_BOX.setActionMessage("Cannot build " +thing+ " in river.");
          if (pushed == view.DEMOLISH_BUTTON) 
            view.FEEDBACK_BOX.setActionMessage("Nothing to remove");
        } //count == 0
      } //if mouseOverMap() and mouseButton == LEFT
    }
  }//END OF NESTED CLASS LANDUSE_CONTROLLER
  
  //-------Button and Slider  ----//
  
  class SliderController{
    /* Controls slider values, updates model */
    void run(){
      if (view.FACTORY_SLIDER.isLocked()){
        int currentVal = view.FACTORY_SLIDER.getVal();
        FACTORY.updatePollution(currentVal);
      }
      if (view.FARM_SLIDER.isLocked()){
        int currentVal = view.FARM_SLIDER.getVal();
        FARM.updatePollution(currentVal);
      }
      if (view.HOUSE_SLIDER.isLocked()){
        int currentVal = view.HOUSE_SLIDER.getVal();
        HOUSE.updatePollution(currentVal);
      }
      if (view.FOREST_SLIDER.isLocked()){
        int currentVal = view.FOREST_SLIDER.getVal();
        FOREST.updatePollution(currentVal);
      }
    }
  }//END OF NESTED CLASS SLIDER_CONTROLLER
  
  
  class ButtonController{
    /* Contains logic for all buttons */
    void actionOnPress(){
      pushButtons();
      unpushButtons();
    }
 
    void pushButtons() {
      /* Logic for pushing and unpushing buttons */
      if (getOverButton() != null) {
        Button b = getOverButton();
        if (b != view.RESET_BUTTON && b != view.DEMOLISH_BUTTON){
          if (pushed == b) {
           view.FEEDBACK_BOX.setModeMessage("");
            pushed = null;
          } else {
            pushed = b;
            view.FEEDBACK_BOX.setModeMessage("Add " + b.label + " mode is selected");
            view.FEEDBACK_BOX.setActionMessage("");
           }
        }
        else if(b == view.DEMOLISH_BUTTON) {   //When demolish button is clicked on
          if (pushed == view.DEMOLISH_BUTTON) {
             view.FEEDBACK_BOX.setModeMessage("");
            pushed = null;
          } else {
            pushed = view.DEMOLISH_BUTTON;
            view.FEEDBACK_BOX.setModeMessage("Demolish mode is selected");
            view.FEEDBACK_BOX.setActionMessage("");
          }
        }
        else if(b == view.RESET_BUTTON) {  //When reset button is clicked on
          if (pushed == view.RESET_BUTTON) {
            view.FEEDBACK_BOX.setModeMessage("Restarting game");
            view.FEEDBACK_BOX.setActionMessage("");
            WS = new Watershed(SIZE_X, SIZE_Y);      //
            graphics.waterS = WS;                
            pushed = null;
            selected = null;
            view.FEEDBACK_BOX.setModeMessage("");
            view.FEEDBACK_BOX.setActionMessage("Game is reset");
          }else {
            pushed = view.RESET_BUTTON;
            view.FEEDBACK_BOX.setModeMessage("Do you want to reset the map? Click button again to reset.");
            view.FEEDBACK_BOX.setActionMessage("Click anywhere to cancel.");
          }
        }
      }
    }
    
    void unpushButtons(){
      //Unpress button if clicked out of map but not on sliders and toggles
      if (! mouseOverMap() && getOverButton() == null && 
          !view.FACTORY_SLIDER.over && !view.FARM_SLIDER.over && !view.HOUSE_SLIDER.over && !view.FOREST_SLIDER.over && 
          !view.POLLUTION_TOGGLE.over && !view.DECAYPOL_TOGGLE.over && !view.DIST_TOGGLE.over && !view.PROFIT_TOGGLE.over){
        //Unpress reset button if it is pressed and user clicks outside the button
        if (pushed == view.RESET_BUTTON && ! view.RESET_BUTTON.isOver()) {
          view.FEEDBACK_BOX.setModeMessage("");
          view.FEEDBACK_BOX.setActionMessage("");
        }
        pushed = null;
        view.FEEDBACK_BOX.setModeMessage("");
      }
      if (mouseButton == RIGHT) {    //Right mouse button to unpush any button
        view.FEEDBACK_BOX.setModeMessage("");
        pushed = null;
      }
    }
  }//END OF NESTED CLASS BUTTON_CONTROLLER
  
  class ToggleController{
    
    void actionOnClick(){
      toggle();
    }
    
    void toggle(){
      if (view.POLLUTION_TOGGLE.over) {
        if (toggled == view.POLLUTION_TOGGLE) toggled = null;
        else toggled = view.POLLUTION_TOGGLE;
      }else if (view.DECAYPOL_TOGGLE.over) {
        if (toggled == view.DECAYPOL_TOGGLE) toggled = null;
        else toggled = view.DECAYPOL_TOGGLE;
      }else if (view.DIST_TOGGLE.over) {
        if (toggled == view.DIST_TOGGLE) toggled = null;
        else toggled = view.DIST_TOGGLE;
      }else if (view.PROFIT_TOGGLE.over) {
        if (toggled == view.PROFIT_TOGGLE) toggled = null;
        else toggled = view.PROFIT_TOGGLE;
      }
      else if (view.SLIDER_TOGGLE.over) {
        if (showSlider == true) showSlider = false;
        else showSlider = true;
      }
    }
  }
} //END OF CLASS CONTROLLER


void mousePressed() {  
  control.mousePX = mouseX; 
  control.mousePY = mouseY;
  control.actionOnPress();
}

void mouseReleased() {
  control.mouseRX = mouseX;
  control.mouseRY = mouseY;
  control.actionOnRelease();
}

void mouseClicked() {
  control.actionOnClick();
}