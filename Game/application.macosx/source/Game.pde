static final int SIZE_X = 30;    //Dimensions of the watershed in tiles
static final int SIZE_Y = 30;

static final int FACTORY_QUOTA = 40;    //Quota for each landuse
static final int FARM_QUOTA = 60;
static final int HOUSE_QUOTA = 100;

static final Factory FACTORY = Factory.getInstance();   //Singletons for each landUse type
static final Farm FARM = Farm.getInstance();
static final House HOUSE = House.getInstance();
static final Forest FOREST = Forest.getInstance();
static final PrimaryForest PFOREST =  PrimaryForest.getInstance();
static final Dirt DIRT = Dirt.getInstance();
static final River RIVER = River.getInstance();

ArrayList<Tile> riverTiles = new ArrayList<Tile>(200);    //All the Tiles that are River

Watershed WS;
GUI graphics;
Controller control;

//-------------------------------------------------------------------------------------------------//

void setup() {
  frameRate(30);
  size(1300, 950);
  WS = new Watershed(SIZE_X, SIZE_Y);   //Creates watershed of size 20*20
  graphics = new GUI(WS);
  control = new Controller(WS, graphics);
  Optimizer op = new Optimizer();
  //op.optimize(WS);
}

void draw() {  
  background(165);
  control.eventLoop();
  graphics.render();
}

//-------------------------------------------------------------------------------------------------//

class Watershed{
  /* Contains all game model and functions */
  final Tile[][] GAME_MAP = new Tile[SIZE_X][SIZE_Y]; //2D Matrix of all grid Tiles on game map
  
  Watershed(int x, int y) {
    populateGameMap();
    initializeRiver();
    buildForests();
   // buildAll();
  }  
  
  void populateGameMap(){
    /* Initializes a game map with all Dirt Tiles */
    for (int j=0; j<SIZE_Y; j++) {
      for (int i=0; i<SIZE_X; i++) { 
         GAME_MAP[i][j] = new Tile(DIRT, i, j);
      }
    }
  }
  
  void initializeRiver() {
    /* River for a 30*30 board.
    *Adds River Tiles at designated locations
    *River design 2 used. (See Excel sheet)*/
    final int[][] RIVER_COORDS = { { 5 , 5 },  { 5 , 19 },  { 5 , 20 },  { 5 , 21 },  { 6 , 5 },  { 6 , 21 },  { 7 , 5 },  { 7 , 6 },  { 7 , 21 },  { 8 , 6 },  { 8 , 21 },  { 8 , 22 },  { 9 , 6 },  { 9 , 22 },  { 10 , 6 },  { 10 , 7 },  { 10 , 22 },  { 11 , 6 },  { 11 , 7 },  { 11 , 8 },  { 11 , 9 },  { 11 , 14 },  { 11 , 15 },  { 11 , 16 },  { 11 , 22 },  { 12 , 7 },  { 12 , 8 },  { 12 , 9 },  { 12 , 10 },  { 12 , 11 },  { 12 , 12 },  { 12 , 13 },  { 12 , 14 },  { 12 , 15 },  { 12 , 16 },  { 12 , 17 },  { 12 , 18 },  { 12 , 19 },  { 12 , 20 },  { 12 , 21 },  { 12 , 22 },  { 13 , 9 },  { 13 , 10 },  { 13 , 11 },  { 13 , 12 },  { 13 , 13 },  { 13 , 14 },  { 13 , 16 },  { 13 , 17 },  { 13 , 18 },  { 13 , 19 },  { 13 , 20 },  { 13 , 21 },  { 13 , 22 },  { 13 , 23 },  { 13 , 24 },  { 13 , 25 },  { 14 , 7 },  { 14 , 8 },  { 14 , 9 },  { 14 , 11 },  { 14 , 12 },  { 14 , 18 },  { 14 , 19 },  { 14 , 22 },  { 14 , 23 },  { 14 , 24 },  { 14 , 25 },  { 14 , 26 },  { 14 , 27 },  { 14 , 28 },  { 14 , 29 },  { 15 , 6 },  { 15 , 11 },  { 15 , 17 },  { 15 , 18 },  { 15 , 24 },  { 15 , 25 },  { 15 , 26 },  { 15 , 27 },  { 15 , 28 },  { 15 , 29 },  { 16 , 5 },  { 16 , 11 },  { 16 , 16 },  { 16 , 17 },  { 16 , 26 },  { 16 , 27 },  { 16 , 28 },  { 16 , 29 },  { 17 , 4 },  { 17 , 10 },  { 17 , 11 },  { 17 , 16 },  { 17 , 27 },  { 17 , 28 },  { 17 , 29 },  { 18 , 9 },  { 18 , 10 },  { 18 , 16 },  { 18 , 17 },  { 19 , 8 },  { 19 , 9 },  { 20 , 7 },  { 20 , 8 },  { 21 , 7 },  { 22 , 7 },  { 23 , 6 },  { 23 , 7 },  { 23 , 8 },  { 24 , 7 },  { 24 , 8 },  { 25 , 7 } };
    for (int[] c: RIVER_COORDS) { 
      getTile(c[0], c[1]).landU = RIVER;
      riverTiles.add(getTile(c[0], c[1]));
    }
  }
  
  void buildForests() {
    /* PrimaryForests for a 30*30 board.
    *Adds PrimaryForests at designated locations
    *River design 2 used. (See Excel sheet)*/
    final int[][] FOREST_COORDS = { { 1 , 1 },  { 1 , 2 },  { 1 , 5 },  { 1 , 18 },  { 1 , 19 },  { 2 , 2 },  { 2 , 3 },  { 2 , 4 },  { 2 , 17 },  { 2 , 18 },  { 2 , 19 },  { 2 , 20 },  { 3 , 2 },  { 3 , 3 },  { 3 , 4 },  { 3 , 5 },  { 3 , 16 },  { 3 , 17 },  { 3 , 18 },  { 3 , 19 },  { 4 , 2 },  { 4 , 3 },  { 4 , 4 },  { 4 , 15 },  { 4 , 16 },  { 4 , 17 },  { 4 , 18 },  { 5 , 4 },  { 5 , 17 },  { 6 , 16 },  { 6 , 17 },  { 6 , 18 },  { 7 , 2 },  { 7 , 17 },  { 7 , 18 },  { 7 , 19 },  { 8 , 17 },  { 8 , 18 },  { 10 , 24 },  { 11 , 24 },  { 11 , 25 },  { 14 , 20 },  { 14 , 21 },  { 15 , 19 },  { 15 , 20 },  { 15 , 21 },  { 15 , 22 },  { 15 , 23 },  { 16 , 18 },  { 16 , 19 },  { 16 , 20 },  { 16 , 21 },  { 17 , 18 },  { 17 , 19 },  { 17 , 20 },  { 21 , 20 },  { 21 , 22 },  { 21 , 23 },  { 22 , 3 },  { 22 , 4 },  { 22 , 19 },  { 22 , 20 },  { 22 , 21 },  { 22 , 22 },  { 22 , 23 },  { 23 , 2 },  { 23 , 3 },  { 23 , 4 },  { 23 , 18 },  { 23 , 19 },  { 23 , 20 },  { 23 , 21 },  { 23 , 22 },  { 23 , 23 },  { 24 , 1 },  { 24 , 2 },  { 24 , 3 },  { 24 , 4 },  { 24 , 5 },  { 24 , 19 },  { 24 , 20 },  { 24 , 21 },  { 24 , 22 },  { 24 , 23 },  { 25 , 2 },  { 25 , 3 },  { 25 , 4 },  { 25 , 5 },  { 25 , 12 },  { 25 , 13 },  { 25 , 20 },  { 25 , 21 },  { 25 , 22 },  { 26 , 3 },  { 26 , 4 },  { 26 , 5 },  { 26 , 6 },  { 26 , 12 },  { 26 , 13 },  { 26 , 23 },  { 26 , 24 },  { 26 , 25 },  { 27 , 4 },  { 27 , 12 },  { 27 , 24 },  { 27 , 25 },  { 27 , 26 },  { 28 , 25 },  { 28 , 26 } };
    for (int[] c: FOREST_COORDS)
      getTile(c[0], c[1]).changeLandUse(PFOREST);
  }
  
  void buildAll() {
    /* Build all landuses for a 30*30 board.
    *Adds landuses at designated locations
    *River design 2 used. (See Excel sheet)*/
    final int[][] FOREST_COORDS = { { 1 , 1 },  { 1 , 2 },  { 1 , 5 },  { 1 , 18 },  { 1 , 19 },  { 2 , 2 },  { 2 , 3 },  { 2 , 4 },  { 2 , 17 },  { 2 , 18 },  { 2 , 19 },  { 2 , 20 },  { 3 , 2 },  { 3 , 3 },  { 3 , 4 },  { 3 , 5 },  { 3 , 16 },  { 3 , 17 },  { 3 , 18 },  { 3 , 19 },  { 4 , 2 },  { 4 , 3 },  { 4 , 4 },  { 4 , 15 },  { 4 , 16 },  { 4 , 17 },  { 4 , 18 },  { 5 , 4 },  { 5 , 17 },  { 6 , 16 },  { 6 , 17 },  { 6 , 18 },  { 7 , 2 },  { 7 , 17 },  { 7 , 18 },  { 7 , 19 },  { 8 , 17 },  { 8 , 18 },  { 9 , 7 },  { 9 , 8 },  { 9 , 12 },  { 10 , 8 },  { 10 , 12 },  { 10 , 14 },  { 10 , 15 },  { 10 , 19 },  { 10 , 24 },  { 11 , 19 },  { 11 , 24 },  { 11 , 25 },  { 13 , 15 },  { 14 , 14 },  { 14 , 16 },  { 14 , 17 },  { 14 , 21 },  { 15 , 20 },  { 15 , 21 },  { 15 , 22 },  { 15 , 23 },  { 16 , 18 },  { 16 , 19 },  { 16 , 20 },  { 16 , 21 },  { 17 , 7 },  { 17 , 15 },  { 17 , 18 },  { 17 , 19 },  { 17 , 20 },  { 19 , 11 },  { 19 , 15 },  { 20 , 11 },  { 21 , 6 },  { 21 , 20 },  { 21 , 22 },  { 21 , 23 },  { 22 , 3 },  { 22 , 4 },  { 22 , 6 },  { 22 , 13 },  { 22 , 14 },  { 22 , 15 },  { 22 , 19 },  { 22 , 20 },  { 22 , 21 },  { 22 , 22 },  { 22 , 23 },  { 23 , 2 },  { 23 , 3 },  { 23 , 4 },  { 23 , 16 },  { 23 , 18 },  { 23 , 19 },  { 23 , 20 },  { 23 , 21 },  { 23 , 22 },  { 23 , 23 },  { 24 , 1 },  { 24 , 2 },  { 24 , 3 },  { 24 , 4 },  { 24 , 5 },  { 24 , 12 },  { 24 , 19 },  { 24 , 20 },  { 24 , 21 },  { 24 , 22 },  { 24 , 23 },  { 25 , 2 },  { 25 , 3 },  { 25 , 4 },  { 25 , 11 },  { 25 , 12 },  { 25 , 13 },  { 25 , 15 },  { 25 , 20 },  { 25 , 21 },  { 25 , 22 },  { 26 , 3 },  { 26 , 4 },  { 26 , 12 },  { 26 , 13 },  { 26 , 23 },  { 26 , 24 },  { 26 , 25 },  { 27 , 4 },  { 27 , 12 },  { 27 , 24 },  { 27 , 25 },  { 27 , 26 },  { 28 , 25 },  { 28 , 26 } };
    final int[][] FACTORY_COORDS = { { 5 , 11 },  { 5 , 12 },  { 5 , 13 },  { 5 , 14 },  { 6 , 10 },  { 6 , 11 },  { 6 , 12 },  { 6 , 13 },  { 6 , 14 },  { 7 , 11 },  { 7 , 12 },  { 7 , 13 },  { 9 , 15 },  { 9 , 16 },  { 9 , 17 },  { 9 , 18 },  { 9 , 19 },  { 10 , 16 },  { 10 , 17 },  { 10 , 18 },  { 11 , 17 },  { 11 , 18 },  { 23 , 13 },  { 23 , 14 },  { 23 , 15 },  { 24 , 13 },  { 24 , 14 },  { 24 , 15 },  { 25 , 14 } };
    final int[][] FARM_COORDS = { { 9 , 11 },  { 10 , 9 },  { 10 , 10 },  { 17 , 14 },  { 18 , 12 },  { 18 , 14 },  { 18 , 15 },  { 19 , 4 },  { 19 , 5 },  { 19 , 13 },  { 20 , 3 },  { 20 , 4 },  { 20 , 5 },  { 20 , 6 },  { 20 , 10 },  { 20 , 13 },  { 20 , 14 },  { 20 , 15 },  { 21 , 3 },  { 21 , 4 },  { 21 , 5 },  { 21 , 8 },  { 21 , 9 },  { 21 , 10 },  { 21 , 11 },  { 21 , 14 },  { 22 , 5 },  { 22 , 8 },  { 22 , 10 },  { 23 , 9 },  { 23 , 10 },  { 24 , 6 },  { 24 , 9 },  { 24 , 10 },  { 25 , 5 },  { 25 , 6 },  { 25 , 8 },  { 25 , 9 },  { 26 , 5 },  { 26 , 6 },  { 26 , 7 } };
    final int[][] HOUSE_COORDS = { { 10 , 11 },  { 11 , 10 },  { 11 , 11 },  { 11 , 12 },  { 11 , 13 },  { 14 , 10 },  { 14 , 13 },  { 14 , 15 },  { 14 , 20 },  { 15 , 7 },  { 15 , 8 },  { 15 , 9 },  { 15 , 10 },  { 15 , 12 },  { 15 , 13 },  { 15 , 14 },  { 15 , 15 },  { 15 , 16 },  { 15 , 19 },  { 16 , 7 },  { 16 , 8 },  { 16 , 9 },  { 16 , 10 },  { 16 , 12 },  { 16 , 13 },  { 16 , 14 },  { 16 , 15 },  { 17 , 8 },  { 17 , 9 },  { 17 , 12 },  { 18 , 7 },  { 18 , 8 },  { 18 , 11 },  { 18 , 13 },  { 19 , 6 },  { 19 , 7 },  { 19 , 10 },  { 19 , 14 },  { 20 , 9 },  { 22 , 9 },  { 23 , 5 } };
    for (int[] c: FOREST_COORDS) 
      getTile(c[0], c[1]).changeLandUse(PFOREST);
    for (int[] c: FACTORY_COORDS) 
      getTile(c[0], c[1]).changeLandUse(FACTORY);
    for (int[] c: FARM_COORDS) 
      getTile(c[0], c[1]).changeLandUse(FARM);
    for (int[] c: HOUSE_COORDS) 
      getTile(c[0], c[1]).changeLandUse(HOUSE);
  }

  Tile[] getAllTiles(){
    /* Returns an array of all the tiles on the game map (hides gameMap internal structure) */
    Tile[] allTiles = new Tile[(SIZE_X)*(SIZE_Y)];
    int i = 0;
    for (Tile[] tileRow : GAME_MAP) {
      for (Tile t: tileRow) {
        allTiles[i] = t;
        i++;
      }
    }
    return allTiles;
  }
  
  Tile getTile(int x, int y){
    /* Returns Tile at positon <x, y> on map */
    try{
     return GAME_MAP[x][y];
    }catch(ArrayIndexOutOfBoundsException e){
      println("Error at getTile(",x,y,"). Check x & y are valid array index");
      return null;
    }
  }
  
  
  int countFactories() {
    /* Sums the number of each landUse  */
    int factories = 0;
    for (Tile t: getAllTiles()){
      if (t.isFactory()) 
        factories ++;
    }
    return factories;
  }
  
    int countFARM_SLIDER() {
    /* Sums the number of each landUse  */
    int FARM_SLIDER = 0;
    for (Tile t: getAllTiles()) {
      if (t.isFarm()) 
        FARM_SLIDER ++;
    }
    return FARM_SLIDER;
  }
  
    int countHOUSE_SLIDER() {
    /* Sums the number of each landUse  */
    int HOUSE_SLIDER = 0;
    for (Tile t: getAllTiles()) {
      if (t.isHouse()) 
        HOUSE_SLIDER ++;
    }
    return HOUSE_SLIDER;
  }
  
  int sumTotalPollution() {
    /* Returns simple sum of pollution generated for all Tiles */
    int totalPollution = 0;
    for (Tile t: getAllTiles()) 
       totalPollution += t.getBasePollution();
    return totalPollution;
  }
  
  float sumDecayPollution() {
  /* Linear decay model of pollution that enters the river.
    Returns total pollution entering river from all sources according decay model defined for each LandUse*/
    float totalDecayPollution = 0.;
    for (Tile t: getAllTiles())   //Calculate pollution contribution from t after linear decay
      totalDecayPollution += t.getDecayPollution();
    return max(1.0, totalDecayPollution);
  }
  
  
  float sumActualProfits() {
    /* Returns the total actual profits made from all the property on the map */
    float profit = 0;
    for (Tile t: getAllTiles()) 
      profit += t.getActualProfit();
    return profit;
  }
  
  float calcScore() {
    /* Returns the player's score */
    return sumActualProfits()/sumDecayPollution();
  }
  

  //**** Methods to add, change and remove land uses  ****//  -----------------------------------------------
    
  boolean addFactory(int x, int y) {
    /* Places a new Factory at Location <x, y> on the map. 
    Returns true if successful. False otherwise.  */
    if (countFactories() < FACTORY_QUOTA) {
      Tile t = getTile(x, y);
      if (! (t.isRiver())) {
        t.changeLandUse(FACTORY);
        println("Added a Factory at", t);
        return true;      
      }else {
        println("Cannot built factory in river. Nothing is added");
        return false;
      }
    }return false;
  }
  
  boolean addFarm(int x, int y) {
    /* Places a new Farm at Location <x, y> on the map. 
    Returns true if successful. False otherwise. */
    if (countFARM_SLIDER() < FARM_QUOTA) {
      Tile t = getTile(x, y);
      if (! (t.isRiver())) {
        t.changeLandUse(FARM); 
        println("Added a Farm at", t);
        return true;
      }else {
        println("Cannot built farm in river. Nothing is added.");
        return false;
      }
    }return false;
  }
  
  boolean addHouse(int x, int y) {
    /* Places a new House at Location <x, y> on the map. 
    Returns true if successful. False otherwise. */
    if (countHOUSE_SLIDER() < HOUSE_QUOTA) {
      Tile t = getTile(x, y);
      if (! (t.isRiver())) {
        t.changeLandUse(HOUSE); 
        println("Added a House at", t);
        return true;
      }else {
        println("Cannot built house in river. Nothing is added.");
        return false;
      }
    }return false;
  } 
  
  boolean addForest(int x, int y) {
    /* Places a new Forest at Location <x, y> on the map. 
    Returns true if successful. False otherwise.  */
    Tile t = getTile(x, y);
    if (! (t.isRiver())) {
      t.changeLandUse(FOREST); 
      println("Added a Forest at", t);
      return true;
    }else {
      println("Cannot plant trees in river. Nothing is added.");
      return false;
    }
  }
  
  boolean addDirt(int x, int y) {
    /* Places a new Dirt at Location <x, y> on the map. */
    Tile t =getTile(x, y);
    t.changeLandUse(DIRT); 
    return true;
  }
  
  boolean removeLandUse(int x, int y) {
    /* Removes LandUse at Location <x, y> on the map. (changes them to Dirt) 
    Returns true if successful. False otherwise.*/
    Tile t = getTile(x, y);
    if (! (t.isRiver())) {
      LandUse olu = t.getLandUse();   //Original land use
      if (olu.isDirt()) {
        println("Nothing to remove");
        return false;
      }
      addDirt(x,y);
      println("Removed land use at", t);
      return true;
    }else {
      println("River cannot be removed.");
      return false;
    }
  }
}