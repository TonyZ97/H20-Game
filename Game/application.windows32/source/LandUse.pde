static final color RIVER_BLUE = #3CA1E3;
static final color FACTORY_BROWN = #EA9253; 
static final color FARM_YELLOW = #F0D446;
static final color FOREST_GREEN = #5DD65E;
static final color HOUSE_GRAY = #9CC2C4;
static final color DIRT_BROWN = #AF956A;
static final color DEMOLISH_BEIGE = #F5DAB9;

//Default pollution values that the game is initialized with
static final int DEFAULT_FACTORY_POLLUTION = 20;    
static final int DEFAULT_FARM_POLLUTION = 12;
static final int DEFAULT_HOUSE_POLLUTION = 4;
static final int DEFAULT_FOREST_POLLUTION = -2;
static final int DEFAULT_DIRT_POLLUTION = 0;


static class LandUse {
  color icon;
  int basePollution;
  int baseProfit;  
  
  boolean isDirt() {
    return (this == Dirt.getInstance());
  }
  boolean isForest() {
    return (this == Forest.getInstance());
  }
  boolean isFactory() {
    return (this == Factory.getInstance());
  }
  boolean isFarm() {
    return (this == Farm.getInstance());
  }
  boolean isHouse() {
    return (this == House.getInstance());
  }
  boolean isRiver() {
    return (this == River.getInstance());
  }
  
  color getIcon() {
    return icon;
  }
   
  int getBaseProfit() {
    return baseProfit;
  }
  
  int getBasePollution() {
    return basePollution;
  }
  
  void updatePollution(int newPollution){
    basePollution = newPollution;
  }
 
  float calcActualProfit(float distToR){    //Subclasses can ovveride this
    return 0;
  }
  
  float calcDecayPollution(float distToRiver) {
   /* Returns the pollution entering river of Tile t according to distance decay model.  */
     float decayPollution = basePollution/(distToRiver/2+0.5);
     return decayPollution;
  }
}



//Only one instance of each LandUse subclass is ever created, accessed statically using Subclass.getInstance();
  
static class Factory extends LandUse {
  private static Factory instance = new Factory();
  
  static Factory getInstance(){
    return instance;
  }
  
  private Factory () {
    icon = FACTORY_BROWN;   //Color code for drawing on map
    basePollution = DEFAULT_FACTORY_POLLUTION;
    baseProfit = 2000;
  }
  
  @Override
  float calcActualProfit(float distToRiver) {
    /*Returns the actual profit made according to profit model  */
    return baseProfit/(sqrt(distToRiver)/4 + 0.75);
  }
  
  @Override
  public String toString() {
    return "Factory";
  }
}


static class Farm extends LandUse {
  private static Farm instance = new Farm();
  
  static Farm getInstance(){
    return instance;
  }
  
  private Farm () {
    icon = FARM_YELLOW;
    basePollution = DEFAULT_FARM_POLLUTION;
    baseProfit = 1000;
 }
  
  @Override
  float calcActualProfit(float distToRiver) {
     /*Returns the actual profit made according to profit model  */
    return baseProfit/(distToRiver/5+0.8);
  }
  
   @Override
  public String toString() {
    return "Farm";
  }
}


static class House extends LandUse {
  private static House instance = new House();
  
  static House getInstance(){
    return instance;
  }
  
  private House() {
    icon = HOUSE_GRAY;
    basePollution = DEFAULT_HOUSE_POLLUTION;
    baseProfit = 700;
  }
  
  @Override
  float calcActualProfit(float distToRiver) {
     /*Returns the actual profit made according to profit model  */
    return baseProfit/(sqrt(distToRiver)/2+0.5);
  }

  @Override
  public String toString() {
    return "House";
  }
}


static class Forest extends LandUse {
  private static Forest instance = new Forest();
  
  static Forest getInstance(){
    return instance;
  }
  
  
  private Forest () {  
    icon = FOREST_GREEN;
    basePollution = DEFAULT_FOREST_POLLUTION;
    baseProfit = -300;
  }
  
  @Override
  float calcActualProfit(float distToRiver) {
     /*Returns the actual profit made according to profit model  */
    return baseProfit;      //Cost of forest is a constant.
  }
  
  @Override
  float calcDecayPollution(float distToRiver) {
    /* Forest pollution does not decay */
    return basePollution;
  }
  
  @Override 
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
  
  static PrimaryForest getInstance(){
    return instance;
  }
  
  private PrimaryForest () {  
    baseProfit = 0;
  }
  
  @Override
  float calcActualProfit(float distToRiver) {
    /*Returns the actual profit made according to profit model  */
    return baseProfit; 
  }
  
  @Override 
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
  
  static Dirt getInstance(){
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
  
  static River getInstance(){
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

 
  