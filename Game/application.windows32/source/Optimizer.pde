class Optimizer {
  void optimize(Watershed ws){
    println("Starting optimization..."); 
    while(!fullyBuilt(ws)) {
      float bestScore = 0.0;
      Tile bestTile = null;
      LandUse bestLandUse = null;
      LandUse[] landUses = { FACTORY, FARM, HOUSE };
      for(Tile t : ws.getAllTiles()) {
        if(t.isDirt()) {
          float dist = t.distToRiver();
          for(LandUse lu : landUses) {
            if(buildOk(lu, ws)) {
              float luProfit = lu.calcActualProfit(dist);
              float luPollution = lu.calcDecayPollution(dist); 
              float luScore = luProfit / max(1.0, luPollution - 6.75);
              if(luScore > bestScore) {
                bestTile = t;
                bestLandUse = lu;
                bestScore = luScore;
              }
            } // if allowed to build this land use type
          } // for each land use
        } // if legal to build here
      } // for each tile
      println("Changing " + bestTile + " to " + bestLandUse);
      bestTile.changeLandUse(bestLandUse);
    } // while not fully built
    for(Tile t : WS.getAllTiles()) {
      LandUse lu = FOREST;
      if(t.isDirt() && buildOk(lu, ws)) {
        t.changeLandUse(lu);
      }
    }
  println("Done!");
  }
  
  boolean fullyBuilt(Watershed ws) {
    return (ws.countFactories() == FACTORY_QUOTA &&
            ws.countFARM_SLIDER() == FARM_QUOTA &&
            ws.countHOUSE_SLIDER() == HOUSE_QUOTA);
  }
  
  boolean buildOk(LandUse lu, Watershed ws) {
    if(lu.isFactory())
      return ws.countFactories() < FACTORY_QUOTA;
    if(lu.isFarm())
      return ws.countFARM_SLIDER() < FARM_QUOTA;
    if(lu.isHouse())
      return ws.countHOUSE_SLIDER() < HOUSE_QUOTA;
    if (lu.isForest())
      return ws.sumDecayPollution() > 1.0;
    return false;    
  }
}
  

  