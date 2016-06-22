class Tile {
  /*A Tile holds properties of the terrain */
  final int slope;   //Slope of tile
  final int soil;  
  final int xpos;  //x-coordinate
  final int ypos;  //y-coordinate
  LandUse landU;
  
  //Every derived variable that is summed over all Tiles in WS is stored as constants, to avoid expensive calculation over each frame.
  float distToRiver;
  float pollution;        //Source pollution this Tile generates
  float decayPollution;      //Pollution entering river from this tile after decay
  float actualProfit = 0;  //Actual profit made by the landU at this tile
  
  
  Tile(LandUse lu, int x, int y, int sl, int so) {
     /* Constructor: Initializes Tile with LandUse lu, and integer slope sl, soil so values */
     xpos = x;
     ypos = y;
     slope = sl;
     soil = so;
     landU = lu;     
  }
 
  
  void changeLandUse(LandUse lu) {
    /* Changes the LandUse held by the Tile to lu */
    landU = lu;
    pollution = getPollution(lu);
    decayPollution = calcDecayPollution((int)pollution, distToRiver);
    actualProfit = lu.calcActualProfit(distToRiver);
  }
  
  LandUse getLandUse() {
    /* Returns the LandUse object of the Tile */
    return landU;
  }
  
  float getDistToRiver() {
    /* Returns the distanceToRiver object of the Tile */
    return distToRiver;
  }

  
  float getTilePollution() {
    /* Returns the pollution generated by the LandUse held by the Tile */
    if (! (landU instanceof River)) {
      return pollution;
    }else return 0;
  }
  
  float getDecayPollution() {
    if (! (landU instanceof River)) {
      return decayPollution;
    }else return 0;
  }
    
  int getBaseProfit() {
    /* Returns the baseProfit of the landUse of this Tile */
    return landU.getBaseProfit();
  }
  
  float getActualProfit() {
    /* Returns the actual profit gained at this tile */
    return actualProfit;
  }
  
  void update() {
    pollution = landU.getSliderPollution();
    decayPollution = calcDecayPollution((int)pollution, distToRiver);
  }
  
  
  // ----  Some geometry methods ---- //
  int getX(){
    /* Returns the xpos of the tile */
    return xpos;
  }
  
  int getY(){
    /* Returns the xpos of the tile */
    return ypos;
  }
  
  @Override
  public String toString() {
    return "<" + str(xpos) + ", " + str(ypos)+ ">";
  }
}