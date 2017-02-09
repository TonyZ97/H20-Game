import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Game extends PApplet {

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

public void setup() {
  frameRate(30);
  
  WS = new Watershed(SIZE_X, SIZE_Y);   //Creates watershed of size 20*20
  graphics = new GUI(WS);
  control = new Controller(WS, graphics);
  Optimizer op = new Optimizer();
  //op.optimize(WS);
}

public void draw() {  
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
  
  public void populateGameMap(){
    /* Initializes a game map with all Dirt Tiles */
    for (int j=0; j<SIZE_Y; j++) {
      for (int i=0; i<SIZE_X; i++) { 
         GAME_MAP[i][j] = new Tile(DIRT, i, j);
      }
    }
  }
  
  public void initializeRiver() {
    /* River for a 30*30 board.
    *Adds River Tiles at designated locations
    *River design 2 used. (See Excel sheet)*/
    final int[][] RIVER_COORDS = { { 5 , 5 },  { 5 , 19 },  { 5 , 20 },  { 5 , 21 },  { 6 , 5 },  { 6 , 21 },  { 7 , 5 },  { 7 , 6 },  { 7 , 21 },  { 8 , 6 },  { 8 , 21 },  { 8 , 22 },  { 9 , 6 },  { 9 , 22 },  { 10 , 6 },  { 10 , 7 },  { 10 , 22 },  { 11 , 6 },  { 11 , 7 },  { 11 , 8 },  { 11 , 9 },  { 11 , 14 },  { 11 , 15 },  { 11 , 16 },  { 11 , 22 },  { 12 , 7 },  { 12 , 8 },  { 12 , 9 },  { 12 , 10 },  { 12 , 11 },  { 12 , 12 },  { 12 , 13 },  { 12 , 14 },  { 12 , 15 },  { 12 , 16 },  { 12 , 17 },  { 12 , 18 },  { 12 , 19 },  { 12 , 20 },  { 12 , 21 },  { 12 , 22 },  { 13 , 9 },  { 13 , 10 },  { 13 , 11 },  { 13 , 12 },  { 13 , 13 },  { 13 , 14 },  { 13 , 16 },  { 13 , 17 },  { 13 , 18 },  { 13 , 19 },  { 13 , 20 },  { 13 , 21 },  { 13 , 22 },  { 13 , 23 },  { 13 , 24 },  { 13 , 25 },  { 14 , 7 },  { 14 , 8 },  { 14 , 9 },  { 14 , 11 },  { 14 , 12 },  { 14 , 18 },  { 14 , 19 },  { 14 , 22 },  { 14 , 23 },  { 14 , 24 },  { 14 , 25 },  { 14 , 26 },  { 14 , 27 },  { 14 , 28 },  { 14 , 29 },  { 15 , 6 },  { 15 , 11 },  { 15 , 17 },  { 15 , 18 },  { 15 , 24 },  { 15 , 25 },  { 15 , 26 },  { 15 , 27 },  { 15 , 28 },  { 15 , 29 },  { 16 , 5 },  { 16 , 11 },  { 16 , 16 },  { 16 , 17 },  { 16 , 26 },  { 16 , 27 },  { 16 , 28 },  { 16 , 29 },  { 17 , 4 },  { 17 , 10 },  { 17 , 11 },  { 17 , 16 },  { 17 , 27 },  { 17 , 28 },  { 17 , 29 },  { 18 , 9 },  { 18 , 10 },  { 18 , 16 },  { 18 , 17 },  { 19 , 8 },  { 19 , 9 },  { 20 , 7 },  { 20 , 8 },  { 21 , 7 },  { 22 , 7 },  { 23 , 6 },  { 23 , 7 },  { 23 , 8 },  { 24 , 7 },  { 24 , 8 },  { 25 , 7 } };
    for (int[] c: RIVER_COORDS) { 
      getTile(c[0], c[1]).landU = RIVER;
      riverTiles.add(getTile(c[0], c[1]));
    }
  }
  
  public void buildForests() {
    /* PrimaryForests for a 30*30 board.
    *Adds PrimaryForests at designated locations
    *River design 2 used. (See Excel sheet)*/
    final int[][] FOREST_COORDS = { { 1 , 1 },  { 1 , 2 },  { 1 , 5 },  { 1 , 18 },  { 1 , 19 },  { 2 , 2 },  { 2 , 3 },  { 2 , 4 },  { 2 , 17 },  { 2 , 18 },  { 2 , 19 },  { 2 , 20 },  { 3 , 2 },  { 3 , 3 },  { 3 , 4 },  { 3 , 5 },  { 3 , 16 },  { 3 , 17 },  { 3 , 18 },  { 3 , 19 },  { 4 , 2 },  { 4 , 3 },  { 4 , 4 },  { 4 , 15 },  { 4 , 16 },  { 4 , 17 },  { 4 , 18 },  { 5 , 4 },  { 5 , 17 },  { 6 , 16 },  { 6 , 17 },  { 6 , 18 },  { 7 , 2 },  { 7 , 17 },  { 7 , 18 },  { 7 , 19 },  { 8 , 17 },  { 8 , 18 },  { 10 , 24 },  { 11 , 24 },  { 11 , 25 },  { 14 , 20 },  { 14 , 21 },  { 15 , 19 },  { 15 , 20 },  { 15 , 21 },  { 15 , 22 },  { 15 , 23 },  { 16 , 18 },  { 16 , 19 },  { 16 , 20 },  { 16 , 21 },  { 17 , 18 },  { 17 , 19 },  { 17 , 20 },  { 21 , 20 },  { 21 , 22 },  { 21 , 23 },  { 22 , 3 },  { 22 , 4 },  { 22 , 19 },  { 22 , 20 },  { 22 , 21 },  { 22 , 22 },  { 22 , 23 },  { 23 , 2 },  { 23 , 3 },  { 23 , 4 },  { 23 , 18 },  { 23 , 19 },  { 23 , 20 },  { 23 , 21 },  { 23 , 22 },  { 23 , 23 },  { 24 , 1 },  { 24 , 2 },  { 24 , 3 },  { 24 , 4 },  { 24 , 5 },  { 24 , 19 },  { 24 , 20 },  { 24 , 21 },  { 24 , 22 },  { 24 , 23 },  { 25 , 2 },  { 25 , 3 },  { 25 , 4 },  { 25 , 5 },  { 25 , 12 },  { 25 , 13 },  { 25 , 20 },  { 25 , 21 },  { 25 , 22 },  { 26 , 3 },  { 26 , 4 },  { 26 , 5 },  { 26 , 6 },  { 26 , 12 },  { 26 , 13 },  { 26 , 23 },  { 26 , 24 },  { 26 , 25 },  { 27 , 4 },  { 27 , 12 },  { 27 , 24 },  { 27 , 25 },  { 27 , 26 },  { 28 , 25 },  { 28 , 26 } };
    for (int[] c: FOREST_COORDS)
      getTile(c[0], c[1]).changeLandUse(PFOREST);
  }
  
  public void buildAll() {
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

  public Tile[] getAllTiles(){
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
  
  public Tile getTile(int x, int y){
    /* Returns Tile at positon <x, y> on map */
    try{
     return GAME_MAP[x][y];
    }catch(ArrayIndexOutOfBoundsException e){
      println("Error at getTile(",x,y,"). Check x & y are valid array index");
      return null;
    }
  }
  
  
  public int countFactories() {
    /* Sums the number of each landUse  */
    int factories = 0;
    for (Tile t: getAllTiles()){
      if (t.isFactory()) 
        factories ++;
    }
    return factories;
  }
  
    public int countFARM_SLIDER() {
    /* Sums the number of each landUse  */
    int FARM_SLIDER = 0;
    for (Tile t: getAllTiles()) {
      if (t.isFarm()) 
        FARM_SLIDER ++;
    }
    return FARM_SLIDER;
  }
  
    public int countHOUSE_SLIDER() {
    /* Sums the number of each landUse  */
    int HOUSE_SLIDER = 0;
    for (Tile t: getAllTiles()) {
      if (t.isHouse()) 
        HOUSE_SLIDER ++;
    }
    return HOUSE_SLIDER;
  }
  
  public int sumTotalPollution() {
    /* Returns simple sum of pollution generated for all Tiles */
    int totalPollution = 0;
    for (Tile t: getAllTiles()) 
       totalPollution += t.getBasePollution();
    return totalPollution;
  }
  
  public float sumDecayPollution() {
  /* Linear decay model of pollution that enters the river.
    Returns total pollution entering river from all sources according decay model defined for each LandUse*/
    float totalDecayPollution = 0.f;
    for (Tile t: getAllTiles())   //Calculate pollution contribution from t after linear decay
      totalDecayPollution += t.getDecayPollution();
    return max(1.0f, totalDecayPollution);
  }
  
  
  public float sumActualProfits() {
    /* Returns the total actual profits made from all the property on the map */
    float profit = 0;
    for (Tile t: getAllTiles()) 
      profit += t.getActualProfit();
    return profit;
  }
  
  public float calcScore() {
    /* Returns the player's score */
    return sumActualProfits()/sumDecayPollution();
  }
  

  //**** Methods to add, change and remove land uses  ****//  -----------------------------------------------
    
  public boolean addFactory(int x, int y) {
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
  
  public boolean addFarm(int x, int y) {
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
  
  public boolean addHouse(int x, int y) {
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
  
  public boolean addForest(int x, int y) {
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
  
  public boolean addDirt(int x, int y) {
    /* Places a new Dirt at Location <x, y> on the map. */
    Tile t =getTile(x, y);
    t.changeLandUse(DIRT); 
    return true;
  }
  
  public boolean removeLandUse(int x, int y) {
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
  
  public void eventLoop() {
    /* Perform these actions on mouse input */
    TILE_CONTROLLER.run();
    LU_CONTROLLER.run();
    SLIDE_CONTROLLER.run();
  }
  
  public void actionOnPress(){
    /* Perform these actions on mousePress */
    BUTTON_CONTROLLER.actionOnPress();
  }
  
  public void actionOnRelease(){
    /* Perform these actions on mouseRelease */
    TILE_CONTROLLER.actionOnRelease();
    LU_CONTROLLER.actionOnRelease();
  }
  
  public void actionOnClick(){
    /* Perform these actions on mouseClick */
    TOGGLE_CONTROLLER.actionOnClick();
  }
  
  public boolean mouseOverMap(){
    /* Returns true if the mouse position is over the Watershed map. False otherwise. */
    int[] xRange = view.GAME_BOARD.getXRange();
    int[] yRange =  view.GAME_BOARD.getYRange();
    return ((mouseX > xRange[0] && mouseX < xRange[1]) && (mouseY > yRange[0] && mouseY < yRange[1]));
  }
  

  
  public boolean inAddMode(){
    /* Returns true if an adder button is pushed (includes demolish). False otherwise */
    return pushed == view.FACTORY_BUTTON ||
           pushed == view.FARM_BUTTON ||
           pushed == view.HOUSE_BUTTON ||
           pushed == view.FOREST_BUTTON ||
           pushed == view.DEMOLISH_BUTTON;
  }
  
  public Button getOverButton() {
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
  
  public int[] converter(int xRaw, int yRaw) {
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
  
  public Tile getOverTile(){
    /* Returns the Tile the mouse is hovering over if mouseOverMap, null otherwise */
    if (mouseOverMap()) {
      int[] pos = converter(mouseX, mouseY);
      return waterS.getTile(pos[0], pos[1]);
    } return null;
  }
  
  public ArrayList<Tile> getDraggedTiles(){
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
  
    public void run(){
      highlightSingleTile();
      highlightManyTiles();
    }
    
    public void actionOnRelease(){
      selectTile();
    }
    
    public void highlight(Tile t, int highlightColor){
      /* Instructs GUI the Tile to highlight and its color */
       view.GAME_BOARD.highlightTile(t, highlightColor);
    }

    public void highlightSingleTile() {
      /* Decides which Tile to highlight when mouse is over map */
      if (mouseOverMap() && !mousePressed) {
        int highlightColor;
        Tile t = getOverTile();
        if (inAddMode() && (!t.isRiver()))   //Change highlight color when in add mode but not over River
          highlightColor = pushed.baseColor;
        else highlightColor = DEFAULT_HIGHLIGHT;
        highlight(t, highlightColor);
      }
    }
    
    public void highlightManyTiles() {
      /* Decides what Tiles to highlight when mouse is dragged, and instructs GUI to highlight it */
      if (mousePressed && mouseOverMap()) {    
        int highlightColor;
        for (Tile t : getDraggedTiles()){
          if (inAddMode() && (!t.isRiver()))   //Change highlight color when in add mode but not over River
            highlightColor = pushed.baseColor;
          else highlightColor = DEFAULT_HIGHLIGHT;
         highlight(t, highlightColor);
        }// for all tiles to highlight
      }// if mouse dragged over map
    } 
    
    public void selectTile(){
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
    
    public void run(){
      calcAddInfo(getProspectiveTiles());
    }
    
    public void actionOnRelease(){
      addStuff();
    }
    
    public ArrayList<Tile> getProspectiveTiles(){
      /* Returns an array of Tiles to calculate projected values, including both mouse hover and mouse drag cases */
      ArrayList<Tile> tlist = new ArrayList<Tile>();
      if (mouseOverMap() && inAddMode()) {
        tlist = getDraggedTiles();  //Tiles to calculate info for
        if (!mousePressed) tlist.add(getOverTile());     //Include info for tile mouse is over when mouse is not dragged
      }
      return tlist;
    }
    
    public void calcAddInfo(ArrayList<Tile> prospectiveTiles){
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

    public void addStuff(){
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
    public void run(){
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
    public void actionOnPress(){
      pushButtons();
      unpushButtons();
    }
 
    public void pushButtons() {
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
    
    public void unpushButtons(){
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
    
    public void actionOnClick(){
      toggle();
    }
    
    public void toggle(){
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


public void mousePressed() {  
  control.mousePX = mouseX; 
  control.mousePY = mouseY;
  control.actionOnPress();
}

public void mouseReleased() {
  control.mouseRX = mouseX;
  control.mouseRY = mouseY;
  control.actionOnRelease();
}

public void mouseClicked() {
  control.actionOnClick();
}
static final int XPOS = 40;   //XPOS and ypos determines the position of the top left corner of the map, in pixels
static final int YPOS = 30;
static final int TILE_WIDTH = 26;   //width of a tile in pixels
static final int TILE_HEIGHT = 26;    //height of a tile in pixels
static final int XPOSB = XPOS + SIZE_X*TILE_WIDTH + 40;    //Drawing dimensions. XPOS and ypos are the coordinates of the top most button. 
static final int YPOSB = 60;    //All objects scale with respect to these
static final int DEFAULT_HIGHLIGHT = 0xffE5FCFC;   // Default color to highllight Tiles with


class GUI {
  Watershed waterS;
  
  final PFont AXISFONT = createFont("Calibri", 12);
  final PFont MESSAGEFONT = createFont("Calibri", 14);
  final PFont BIGFONT = createFont("Calibri-Bold", 20);
  final PFont NUMERALFONT = createFont("Courier", 30);
  
  final Button FACTORY_BUTTON = new Button(XPOSB, YPOSB, TILE_WIDTH, TILE_HEIGHT, FACTORY_BROWN, 0xff73A29C, 0xffEA7E2F, "Factory");
  final Button FARM_BUTTON = new Button(XPOSB, YPOSB + 60, TILE_WIDTH, TILE_HEIGHT, FARM_YELLOW, 0xff73A29C, 0xffF0AD1D, "Farm");
  final Button HOUSE_BUTTON = new Button(XPOSB, YPOSB + 120, TILE_WIDTH, TILE_HEIGHT, HOUSE_GRAY, 0xff73A29C, 0xff90B3B4, "House");
  final Button FOREST_BUTTON = new Button(XPOSB, YPOSB + 180, TILE_WIDTH, TILE_HEIGHT, FOREST_GREEN, 0xff73A29C, 0xff02A002, "Forest");
  final Button DEMOLISH_BUTTON = new Button(XPOSB, YPOSB + 240, TILE_WIDTH, TILE_HEIGHT, DEMOLISH_BEIGE, 0xff73A29C, 0xffF5BB74, "Demolish");
  final Button RESET_BUTTON = new Button(XPOSB+220, YPOS+TILE_HEIGHT*SIZE_Y-57, TILE_WIDTH + 5, TILE_HEIGHT + 5, 0xffFFFFFF, 0xff989795, 0xff171717, "RESET MAP");
      
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
  
  public void render() {
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
    
    public int[] getXRange(){
      return new int[] {xpos, xpos+tileW*SIZE_X};
    }
    
    public int[] getYRange(){
      return new int[] {ypos, ypos+tileH*SIZE_Y};
    }
 
    public void display() {
      drawGameBoard();
      drawAxisLabels();
      highlight();
      showSelectedTile();
      showToggleInfo();
    }
      
    public void drawGameBoard(){
      /* Draws the game board */
      for (Tile t: waterS.getAllTiles()) 
        drawTile(t.getX(), t.getY(), t.getLandUse().getIcon(), 255);
    }
    
     public void drawTile(int x, int y, int c, int t) {
      /* Draws a tile at Location <x, y> on game map, fill color c, transparency t */
      stroke(240);
      strokeWeight(0.5f);
      fill(c, t);
      rect(x*tileW+xpos, y*tileH+ypos, tileW, tileH);
      fill(255);    //resets to white.
    } 
    
    public void drawAxisLabels() {
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
    
    public void highlight() {
      /* Hightlights all the Tiles with color hc (during click and drag) */
      for (int [] e : highlightThese){
        drawTile(e[0], e[1], e[2], 100);
      }
      highlightThese = new ArrayList<int[]>();     //Clear list after highlighting all its Tiles
    }
    
    public void showSelectedTile() {    
    /* Accents the selected tile */
      if (selected != null){
        drawTile(selected.getX(), selected.getY(), 255, 130);
        noFill();
        strokeWeight(1.5f);
        stroke(245);
        rect(selected.getX()*tileW + xpos, selected.getY()*tileH + ypos, tileW, tileH);
      }
    }

    public void highlightTile(Tile t, int hc) {
      /* Instructs GameBoard to highlight Tile t with color hc */
      highlightThese.add(new int[] {t.getX(), t.getY(), hc});
    }
    
    public Tile[] getHighlightedTiles(){
      /* Returns an array of the Tiles that are highlighted */
      Tile[] tiles = new Tile[highlightThese.size()];
      int i = 0;
      for (int[] e : highlightThese){
        tiles[i] = waterS.getTile(e[0], e[1]);
        i++;
      }
    return tiles;
    }
    
    public void showToggleInfo() {
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
    
    public void showPollution() {
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
    public void showDecayPollution() {
      float total = 0.f;
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
     
    public void showDist() {
      for (Tile t: waterS.getAllTiles()) {
        textFont(MESSAGEFONT);
        textSize(10);
        fill(0);
        textAlign(LEFT, TOP);
        if (!(t.getLandUse() instanceof River)) 
          text(nfc(t.distToRiver(),1), t.getX()*tileW + xpos+2, t.getY()*tileH + ypos+1);
      }
    }
     
     public void showProfit() {
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

    public void display(){
     /* Draws box and displays selected Tile info and prePurchaseInfo */
      stroke(255);
      strokeWeight(1);
      fill(255);
      rect(xpos, ypos, wide, tall);
      showPrePurchaseInfo();
      showTileInfo();
    }
    
    public void showTileInfo() {    
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

    public void showPrePurchaseInfo(){
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
    
    public void setProjected(float profit, float pollution){
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
    
    public void display() {
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
    
    public void setModeMessage(String m){
      modeMessage = m;
    }
    
    public void setActionMessage(String m){
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
    
    public void display(){
      showActualProfits();
      showScore();
      showBuildQuota();
      showPollutionSlider();
      drawDividers();
    }
    
    public void showPollutionSlider() {
      /* Displays the pollution indicator */
      int green = 0xff4BDE4A;
      int red = 0xffFF3300;
      int extreme = 0xffA72200;
      int x =  xpos;     //xposition of the slider
      int y = ypos;       //YPOSition of the slider
      int w = 220;    //width of slider
      int h = 33;  //height if slider
      int polMax = 1200;  // The maximum pollution the slider can handle
      colorMode(HSB);
      
      //Draws the Slidier
      strokeWeight(1);
      for (float i = x; i <= x+w-w*0.25f; i++) {     //Green to red portion
        float inter = map(i, x, x+w-w*0.25f, 0, 1);
        int c = lerpColor(green, red, inter);
        stroke(c);
        line(i, y, i, y+h);
      }
      for (float i = x+w-w*0.25f; i <= x+w; i++) {       //Red to extreme portion
        float inter = map(i, x+w-w*0.25f, x+w, 0, 1);
        int c = lerpColor(red, extreme, inter);
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
      if ((sliderX - x)*scaleC < polMax*0.2f) {
        pLevel = "Healthy";
      } else if ((sliderX - x)*scaleC < polMax*0.34f){
        pLevel = "Okay";
      } else if ((sliderX - x)*scaleC < polMax*0.52f) {
        pLevel = "Moderate";
      } else if ((sliderX - x)*scaleC < polMax*0.70f) {
        pLevel = "Unhealthy";
      } else if ((sliderX - x)*scaleC < polMax*0.89f) {
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
    
    public void showActualProfits() {
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
    
    public void showScore() {
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
    
    public void showBuildQuota() {
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
    
    public void drawDividers(){ 
      noFill();
      stroke(204);
      strokeWeight(1);
      rect(xpos-20, ypos - 365, 392, TILE_HEIGHT*SIZE_Y);
      line(xpos-20, ypos+TILE_HEIGHT+5+270-350, xpos-20+392, ypos+TILE_HEIGHT+5+270-350);
    }
  }//END OF NESTED CLASS DASHBOARD
}//END OF GUI CLASS
class Button{ 
  final PFont BASEFONT = createFont("Arial", 16);
  final PFont SELECTEDFONT = createFont("Arial-Black", 16);
  
  int x, y;                 // The x- and y-coordinates of the Button in pixels
  int bWidth;                 // Dimensions in pixels
  int bHeight;
  int baseColor;           // Default color value 
  int overColor;           //Color when mouse over button
  int selectedColor;        //Color when button is selected
  String label;
  boolean over = false;     //true if mouse is over button
  
  Button(int xp, int yp, int w, int h, int c, int o, int s, String l) {
    x = xp;
    y = yp;
    bWidth = w+5;
    bHeight = h+5;
    baseColor = c;          //Default color
    overColor = o;           //Color when mouse over button
    selectedColor = s; 
    label = l;            //Color when button is in pushed state
  }
  
  public boolean isOver(){
    return over;
  }
  
  public void display() {
    stroke(255);
    strokeWeight(1.5f);
    fill(255);  //Color of text label
    textAlign(LEFT,CENTER);
    if (pushed == this) { 
      stroke(90);
      strokeWeight(2.5f);
      textFont(SELECTEDFONT);
      text(label, x+bWidth+8, y+(bHeight/2.f)-3);
      fill(selectedColor);
    }else if (over) {
      textFont(BASEFONT);
      text(label, x+bWidth+5, y+(bHeight/2.f)-1);
      fill(overColor);
    }else {
      textFont(BASEFONT);
      text(label, x+bWidth+5, y+(bHeight/2.f)-1);
      fill(baseColor);
    }
    rect(x, y, bWidth, bHeight);
    update();
  }  
  
  // Updates the over field every frame
  public void update() {
    if ((mouseX >= x-1) && (mouseX <= x+bWidth+textWidth(label)+8) && 
        (mouseY >= y-1) && (mouseY <= y+bHeight+1)) {
      over = true;
    } else
      over = false;
  }
} 
class Slider { 
  static final int BAR_WIDTH = 180;
  static final int BAR_HEIGHT = 20;    // width and height of bar 
  static final int S_WIDTH = 20;        //width and height of slider
  static final int S_HEIGHT = BAR_HEIGHT;  
  
  final PFont SLIDERFONT = createFont("Calibri", 14);
 
  int x, y;       // x and y position of bar
  int spos; //position of the slider in pixels
  boolean over;           // is the mouse over the slider?
  boolean locked;
  int col;
  
  LandUse lu;
  int minVal;        //Min and max val of slider
  int maxVal;
  int currentVal;    //The initial value of the slider
  float ratio;   //units per pixellength
  
  Slider(LandUse l, int xp, int yp, int minV, int maxV, int c) {
    lu = l;
    x = xp;
    y = yp;
    minVal = minV;
    maxVal = maxV;
    currentVal = l.getBasePollution();
    ratio = (maxVal - minVal)/((float)(BAR_WIDTH - S_WIDTH));
    spos = valToSpos(currentVal);
    col = c ;
  }
  
  public boolean isOver(){
    if (mouseX > x && mouseX < x+BAR_WIDTH &&
       mouseY > y && mouseY < y+BAR_HEIGHT) {
      return true;
    } else {
      return false;
    }
  }
  
  public boolean isLocked(){
    return locked;
  }
  
  public void setVal(int v){  // ---> does nothing now
    currentVal = v;
  }
  
  public int valToSpos(int v){
    return round(x + (currentVal-minVal)/ratio);
  }

  public void update() {
    if (isOver()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      spos = constrain(mouseX, x+1, x+BAR_WIDTH-S_WIDTH);
    }
  }

  public void display() {
    stroke(255);
    strokeWeight(1);
    fill(col);
    rectMode(CORNER);
    rect(x, y, BAR_WIDTH, BAR_HEIGHT);
    noStroke();
    fill(80);
    rect(spos, y-1, S_WIDTH, S_HEIGHT+2);
    fill(0);
    textFont(SLIDERFONT); 
    text(getVal(), x + BAR_WIDTH + 15, y+7);
    update();
  }

  public int getVal() {
    // Convert spos to be values between minVal and maxVal
    return round(((spos - x) * ratio) + minVal);
  }
}


 
class Toggle {
  final PFont BASEFONT = createFont("Arial", 14);  
  int x, y;                 // The x- and y-coordinates of the Button in pixels
  int tWidth;                 // Dimensions in pixels
  int tHeight;
  int baseColor;           // Default color value 
  int overColor;           //Color when mouse over button
  int selectedColor;        //Color when button is selected
  String label;
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
  
  public void display() {
    ellipseMode(CORNER);
    stroke(255);
    strokeWeight(2);
    textFont(BASEFONT);
    fill(255);  //Color of text label
    textAlign(LEFT,CENTER);
    if ((toggled == this) || (this.label.equals("Show sliders") && showSlider == true)) { 
      text(label, x+tWidth+5, y+(tHeight/2.f)-1);
      fill(selectedColor);
      if (this.label.equals("Show sliders")) fill(0xffB72416);
    }else if (over) {
      text(label, x+tWidth+5, y+(tHeight/2.f)-1);
      fill(overColor);
    }else {
      text(label, x+tWidth+5, y+(tHeight/2.f)-1);
      fill(baseColor);
    }
    ellipse(x, y, tWidth, tHeight);
    update();
  }  
  
  // Updates the over field every frame
  public boolean overEvent() {
    if (mouseX > x-3 && mouseX < x+tWidth+textWidth(label)+9 &&
       mouseY > y-5 && mouseY < y+tHeight+5) {
      return true;
    } else {
      return false;
    }
  }
  
  public void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
  }
}
static final int RIVER_BLUE = 0xff3CA1E3;
static final int FACTORY_BROWN = 0xffEA9253; 
static final int FARM_YELLOW = 0xffF0D446;
static final int FOREST_GREEN = 0xff5DD65E;
static final int HOUSE_GRAY = 0xff9CC2C4;
static final int DIRT_BROWN = 0xffAF956A;
static final int DEMOLISH_BEIGE = 0xffF5DAB9;

//Default pollution values that the game is initialized with
static final int DEFAULT_FACTORY_POLLUTION = 20;    
static final int DEFAULT_FARM_POLLUTION = 12;
static final int DEFAULT_HOUSE_POLLUTION = 4;
static final int DEFAULT_FOREST_POLLUTION = -2;
static final int DEFAULT_DIRT_POLLUTION = 0;


static class LandUse {
  int icon;
  int basePollution;
  int baseProfit;  
  
  public boolean isDirt() {
    return (this == Dirt.getInstance());
  }
  public boolean isForest() {
    return (this == Forest.getInstance());
  }
  public boolean isFactory() {
    return (this == Factory.getInstance());
  }
  public boolean isFarm() {
    return (this == Farm.getInstance());
  }
  public boolean isHouse() {
    return (this == House.getInstance());
  }
  public boolean isRiver() {
    return (this == River.getInstance());
  }
  
  public int getIcon() {
    return icon;
  }
   
  public int getBaseProfit() {
    return baseProfit;
  }
  
  public int getBasePollution() {
    return basePollution;
  }
  
  public void updatePollution(int newPollution){
    basePollution = newPollution;
  }
 
  public float calcActualProfit(float distToR){    //Subclasses can ovveride this
    return 0;
  }
  
  public float calcDecayPollution(float distToRiver) {
   /* Returns the pollution entering river of Tile t according to distance decay model.  */
     float decayPollution = basePollution/(distToRiver/2+0.5f);
     return decayPollution;
  }
}



//Only one instance of each LandUse subclass is ever created, accessed statically using Subclass.getInstance();
  
static class Factory extends LandUse {
  private static Factory instance = new Factory();
  
  public static Factory getInstance(){
    return instance;
  }
  
  private Factory () {
    icon = FACTORY_BROWN;   //Color code for drawing on map
    basePollution = DEFAULT_FACTORY_POLLUTION;
    baseProfit = 2000;
  }
  
  public @Override
  float calcActualProfit(float distToRiver) {
    /*Returns the actual profit made according to profit model  */
    return baseProfit/(sqrt(distToRiver)/4 + 0.75f);
  }
  
  @Override
  public String toString() {
    return "Factory";
  }
}


static class Farm extends LandUse {
  private static Farm instance = new Farm();
  
  public static Farm getInstance(){
    return instance;
  }
  
  private Farm () {
    icon = FARM_YELLOW;
    basePollution = DEFAULT_FARM_POLLUTION;
    baseProfit = 1000;
 }
  
  public @Override
  float calcActualProfit(float distToRiver) {
     /*Returns the actual profit made according to profit model  */
    return baseProfit/(distToRiver/5+0.8f);
  }
  
   @Override
  public String toString() {
    return "Farm";
  }
}


static class House extends LandUse {
  private static House instance = new House();
  
  public static House getInstance(){
    return instance;
  }
  
  private House() {
    icon = HOUSE_GRAY;
    basePollution = DEFAULT_HOUSE_POLLUTION;
    baseProfit = 700;
  }
  
  public @Override
  float calcActualProfit(float distToRiver) {
     /*Returns the actual profit made according to profit model  */
    return baseProfit/(sqrt(distToRiver)/2+0.5f);
  }

  @Override
  public String toString() {
    return "House";
  }
}


static class Forest extends LandUse {
  private static Forest instance = new Forest();
  
  public static Forest getInstance(){
    return instance;
  }
  
  
  private Forest () {  
    icon = FOREST_GREEN;
    basePollution = DEFAULT_FOREST_POLLUTION;
    baseProfit = -300;
  }
  
  public @Override
  float calcActualProfit(float distToRiver) {
     /*Returns the actual profit made according to profit model  */
    return baseProfit;      //Cost of forest is a constant.
  }
  
  public @Override
  float calcDecayPollution(float distToRiver) {
    /* Forest pollution does not decay */
    return basePollution;
  }
  
  public @Override 
  void updatePollution(int newPollution){
    basePollution = newPollution;
    PrimaryForest.getInstance().updatePollution(newPollution);
  }
  
  @Override
  public String toString() {
    return "Forest";
  }
}

static class PrimaryForest extends Forest {
  /* PrimaryFOREST_SLIDER have zero cost */
  private static PrimaryForest instance = new PrimaryForest();
  
  public static PrimaryForest getInstance(){
    return instance;
  }
  
  private PrimaryForest () {  
    baseProfit = 0;
  }
  
  public @Override
  float calcActualProfit(float distToRiver) {
    /*Returns the actual profit made according to profit model  */
    return baseProfit; 
  }
  
  public @Override 
  void updatePollution(int newPollution){
    basePollution = newPollution;
  }
  
  @Override
  public String toString() {
    return "Forest";
  }
}


static class Dirt extends LandUse {
  private static Dirt instance = new Dirt();
  
  public static Dirt getInstance(){
    return instance;
  }
  
  private Dirt() {
    icon = DIRT_BROWN;
    basePollution = DEFAULT_DIRT_POLLUTION;
    baseProfit = 0;
 }
 
  @Override
  public String toString() {
    return "Dirt";
  }
}


static class River extends LandUse {
  private static River instance = new River();
  
  public static River getInstance(){
    return instance;
  }
  
  private River(){
    icon = RIVER_BLUE;
  }

 
  @Override
  public String toString() {
    return "River";
  }
}

 
  
class Optimizer {
  public void optimize(Watershed ws){
    println("Starting optimization..."); 
    while(!fullyBuilt(ws)) {
      float bestScore = 0.0f;
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
              float luScore = luProfit / max(1.0f, luPollution - 6.75f);
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
  
  public boolean fullyBuilt(Watershed ws) {
    return (ws.countFactories() == FACTORY_QUOTA &&
            ws.countFARM_SLIDER() == FARM_QUOTA &&
            ws.countHOUSE_SLIDER() == HOUSE_QUOTA);
  }
  
  public boolean buildOk(LandUse lu, Watershed ws) {
    if(lu.isFactory())
      return ws.countFactories() < FACTORY_QUOTA;
    if(lu.isFarm())
      return ws.countFARM_SLIDER() < FARM_QUOTA;
    if(lu.isHouse())
      return ws.countHOUSE_SLIDER() < HOUSE_QUOTA;
    if (lu.isForest())
      return ws.sumDecayPollution() > 1.0f;
    return false;    
  }
}
  

  
class Tile {
  /*A Tile holds properties of the terrain */
  final int X;  //x-coordinate
  final int Y;  //y-coordinate
  LandUse landU;
  
  Tile(LandUse lu, int xp, int yp) {
     /* Constructor: Initializes Tile with LandUse lu, and integer slope sl, soil so values */
     X = xp;
     Y = yp;
     landU = lu;     
  }

  public boolean isDirt() {
    return (landU.isDirt());
  }
  public boolean isForest() {
    return (landU.isForest());
  }
  public boolean isFactory() {
    return (landU.isFactory());
  }
  public boolean isFarm() {
    return (landU.isFarm());
  }
  public boolean isHouse() {
    return (landU.isHouse());
  }
  public boolean isRiver() {
    return (landU.isRiver());
  }
  
  public float distToRiver() {
    /* Helper: Returns the distance of location this to closest River Tile. */
    float minDist = Float.MAX_VALUE;
    for (Tile t: riverTiles) {
      float d = dist(X, Y, t.getX(), t.getY());
      if (d < minDist) minDist = d;
    }
    return minDist;
  }
  
  public void changeLandUse(LandUse lu) {
    /* Changes the LandUse held by the Tile to lu */
    landU = lu;
  }
  
  public LandUse getLandUse() {
    /* Returns the LandUse object of the Tile */
    return landU;
  }
  
  public float getBasePollution() {
    /* Returns the pollution generated by the LandUse held by the Tile */
    if (! (this.isRiver())) {
      return landU.getBasePollution();
    }else return 0;
  }
  
  public float getDecayPollution() {
      return landU.calcDecayPollution(distToRiver());
  }
    
  public int getBaseProfit() {
    /* Returns the baseProfit of the landUse of this Tile */
    return landU.getBaseProfit();
  }
  
  public float getActualProfit() {
    /* Returns the actual profit gained at this tile */
    return landU.calcActualProfit(distToRiver());
  }
  
  public int getX(){
    /* Returns the XPOS of the tile */
    return X;
  }
  
  public int getY(){
    /* Returns the XPOS of the tile */
    return Y;
  }
  
  @Override
  public String toString() {
    return "<" + str(X) + ", " + str(Y)+ ">";
  }
}
  public void settings() {  size(1300, 950); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Game" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
