//ITEM INVENTORY WEIGHT, FOR w_class
#define WEIGHT_CLASS_TINY     1 //Usually items smaller then a human hand, ex: Playing Cards, Lighter, Scalpel, Coins/Money
#define WEIGHT_CLASS_SMALL    2 //Pockets can hold small and tiny items, ex: Flashlight, Grenades, GPS Device
#define WEIGHT_CLASS_NORMAL   3 //Standard backpacks can carry tiny, small & normal items, ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define WEIGHT_CLASS_BULKY    4 //Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define WEIGHT_CLASS_HUGE     5 //Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define WEIGHT_CLASS_GIGANTIC 6 //Essentially means it cannot be picked up or placed in an inventory, ex: Mech Parts, Safe

//Inventory depth: limits how many nested storage items you can access directly.
//1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH 3
#define STORAGE_VIEW_DEPTH 2
