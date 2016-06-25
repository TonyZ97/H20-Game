class Tile {
  /*A Tile holds properties of the terrain */
  final int X;  //x-coordinate
  final int Y;  //y-coordinate
  LandUse landU;
  
  //Every derived variable that is summed over all Tiles in WS is stored as constants, to avoid expensive calculation over each frame.
  float distToRiver;
  float pollution;        //Source pollution this Tile generates
  float decayPollution;      //Pollution entering river from this tile after decay
  float actualProfit = 0;  //Actual profit made by the landU at this tile
  
  Tile(LandUse lu, int xp, int yp) {
     /* Constructor: Initializes Tile with LandUse lu, and integer slope sl, soil so values */
     X = xp;
     Y = yp;
     landU = lu;     
  }
 
  
  void changeLandUse(LandUse lu) {
    /* Changes the LandUse held by the Tile to lu */
    landU = lu;
    pollution = getPollution(lu);
    if (! (lu instanceof Forest) && !(lu instanceof River)) {
      decayPollution = calcDecayPollution(pollution, distToRiver);
    } else decayPollution = getPollution(lu);
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
    if (showSlider == true) {
      if (! (landU instanceof Dirt) && !(landU instanceof River)){
        pollution = landU.getSliderPollution();
      }
      if (! (landU instanceof Forest) && !(landU instanceof River)) {
        decayPollution = calcDecayPollution(pollution, distToRiver);
      } else decayPollution = pollution;
    }else{
      pollution = getPollution(landU);
      if (! (landU instanceof Forest) && !(landU instanceof River)) {
        decayPollution = calcDecayPollution(pollution, distToRiver);
      } else decayPollution = pollution;
    }
  }
  
  
  // ----  Some geometry methods ---- //
  int getX(){
    /* Returns the XPOS of the tile */
    return X;
  }
  
  int getY(){
    /* Returns the XPOS of the tile */
    return Y;
  }
  
  @Override
  public String toString() {
    return "<" + str(X) + ", " + str(Y)+ ">";
  }
}