/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

//Middle left indicators
#define UI_ALIENPLASMADISPLAY "EAST-1:28,CENTER-2:15"

//Lower left, persistant menu
#define UI_INVENTORY "WEST:6,SOUTH:5"

//Middle left indicators
#define UI_LINGCHEMDISPLAY "WEST:6,CENTER-1:15"
#define UI_LINGSTINGDISPLAY "WEST:6,CENTER-3:11"

//Lower center, persistant menu
#define UI_SSTORE1 "CENTER-5:10,SOUTH:5"
#define UI_ID "CENTER-4:12,SOUTH:5"
#define UI_BELT "CENTER-3:14,SOUTH:5"
#define UI_BACK "CENTER-2:14,SOUTH:5"
#define UI_RHAND "CENTER:-16,SOUTH:5"
#define UI_LHAND "CENTER: 16,SOUTH:5"
#define UI_EQUIP "CENTER:-16,SOUTH+1:5"
#define UI_SWAPHAND1 "CENTER:-16,SOUTH+1:5"
#define UI_SWAPHAND2 "CENTER: 16,SOUTH+1:5"
#define UI_STORAGE1 "CENTER+1:18,SOUTH:5"
#define UI_STORAGE2 "CENTER+2:20,SOUTH:5"
#define UI_PDA "CENTER+3:22,SOUTH:5"
#define UI_COMBO "CENTER+4:24,SOUTH+1:7" //combo meter for martial arts

#define UI_ALIEN_HEAD "4:12,1:5"	//aliens
#define UI_ALIEN_OCLOTHING "5:14,1:5"	//aliens

#define UI_BORG_SENSOR "CENTER-3:16, SOUTH:5"	//borgs
#define UI_BORG_LAMP "CENTER-4:16, SOUTH:5"		//borgs
#define UI_BORG_THRUSTERS "CENTER-5:16, SOUTH:5"//borgs
#define UI_BORG_PDA "CENTER-6:16, SOUTH:5"      //borgs
#define UI_INV1 "CENTER-2:16,SOUTH:5"			//borgs
#define UI_INV2 "CENTER-1  :16,SOUTH:5"			//borgs
#define UI_INV3 "CENTER  :16,SOUTH:5"			//borgs
#define UI_BORG_MODULE "CENTER+1:16,SOUTH:5"
#define UI_BORG_STORE "CENTER+2:16,SOUTH:5"		//borgs


#define UI_MONKEY_MASK "CENTER-3:14,SOUTH:5"	//monkey
#define UI_MONKEY_BACK "CENTER-2:15,SOUTH:5"	//monkey

#define UI_ALIEN_STORAGE_L "CENTER-2:14,SOUTH:5"//alien
#define UI_ALIEN_STORAGE_R "CENTER+1:18,SOUTH:5"//alien
#define UI_ALIEN_LANGUAGE_MENU "EAST-3:25,SOUTH+1:7"//alien
#define UI_ALIENLARVA_LANGUAGE_MENU "EAST-3:26,SOUTH:5"//alien

//Lower right, persistant menu
#define UI_DROP_THROW "EAST-1:28,SOUTH+1:7"
#define UI_PULL_RESIST "EAST-2:26,SOUTH+1:7"
#define UI_ACTI "EAST-2:26,SOUTH:5"
#define UI_MOVI "EAST-3:24,SOUTH:5"
#define UI_ZONESEL "EAST-1:28,SOUTH:5"
#define UI_ACTI_ALT "EAST-1:28,SOUTH:5" //alternative intent switcher for when the interface is hidden (F12)

#define UI_CRAFTING	"EAST:-5,SOUTH+2:7"
#define UI_LANGUAGE_MENU "EAST:-22,SOUTH+2:7"

#define UI_BORG_PULL "EAST-2:26,SOUTH+1:7"
#define UI_BORG_RADIO "EAST-1:28,SOUTH+1:7"
#define UI_BORG_INTENTS "EAST-2:26,SOUTH:5"
#define UI_BORG_LANUGAGE_MENU "EAST-2:26,SOUTH+1:7"

//Upper-middle right (alerts)
#define UI_ALERT1 "EAST-1:28,CENTER+5:27"
#define UI_ALERT2 "EAST-1:28,CENTER+4:25"
#define UI_ALERT3 "EAST-1:28,CENTER+3:23"
#define UI_ALERT4 "EAST-1:28,CENTER+2:21"
#define UI_ALERT5 "EAST-1:28,CENTER+1:19"

//Middle right (status indicators)
#define UI_INTERNAL "EAST-1:28,CENTER+1:19"
#define UI_HEALTH "EAST-1:28,CENTER:17"
#define UI_HEALTHDOLL "EAST-1:28,CENTER-1:15"
#define UI_NUTRITION "EAST-2:32,CENTER-1:13"
#define UI_STAMINA "EAST-1:28,CENTER-2:15"

//borgs
#define UI_BORG_HEALTH "EAST-1:28,CENTER-1:15" //borgs have the health display where humans have the pressure damage indicator.

//aliens
#define UI_ALIEN_HEALTH "EAST-1:28,CENTER-1:15" //aliens have the health display where humans have the pressure damage indicator.

//constructs
#define UI_CONSTRUCT_PULL "EAST-1:28,SOUTH+1:10" //above the zone_sel icon
#define UI_CONSTRUCT_HEALTH "EAST,CENTER:15" //same height as humans, hugging the right border

//slimes
#define UI_SLIME_HEALTH "EAST,CENTER:15"  //same as borgs, constructs and humans

//Pop-up inventory
#define UI_SHOES "WEST+1:8,SOUTH:5"

#define UI_ICLOTHING "WEST:6,SOUTH+1:7"
#define UI_OCLOTHING "WEST+1:8,SOUTH+1:7"
#define UI_GLOVES "WEST+2:10,SOUTH+1:7"


#define UI_GLASSES "WEST:6,SOUTH+3:11"
#define UI_MASK "WEST+1:8,SOUTH+2:9"
#define UI_L_EAR "WEST+2:10,SOUTH+2:9"
#define UI_R_EAR "WEST+2:10,SOUTH+3:11"

#define UI_NECK "WEST:6,SOUTH+2:9"

#define UI_HEAD "WEST+1:8,SOUTH+3:11"

// AI

#define UI_AI_VIEW_IMAGES "BOTTOM+1:6,LEFT"
#define UI_AI_TAKE_PICTURE "BOTTOM+1:6,LEFT+1"
#define UI_AI_CAMERA_LIST "BOTTOM:6,LEFT"
#define UI_AI_CAMERA_LIGHT "BOTTOM:6,LEFT+1"
#define UI_AI_TRACK_WITH_CAMERA "BOTTOM:6,LEFT+2"

#define UI_AI_CREW_MONITOR "BOTTOM:6,CENTER-3"
#define UI_AI_CREW_MANIFEST "BOTTOM:6,CENTER-2"
#define UI_AI_ALERTS "BOTTOM:6,CENTER-1"
#define UI_AI_ANNOUNCEMENT "BOTTOM:6,CENTER"
#define UI_AI_SHUTTLE "BOTTOM:6,CENTER+1"
#define UI_AI_PDA "BOTTOM:6,CENTER+2"

#define UI_AI_STATE_LAWS "SOUTH:6,RIGHT-2"
#define UI_AI_CORE "SOUTH:6,RIGHT-1"
#define UI_AI_SENSOR "SOUTH:6,RIGHT"

// Bots
#define UI_BOT_RADIO "EAST-1:28,SOUTH:7"
#define UI_BOT_PULL "EAST-2:26,SOUTH:7"

//Ghosts
#define UI_GHOST_ORBIT "SOUTH:6,CENTER-2"
#define UI_GHOST_REENTER_CORPSE "SOUTH:6,CENTER-1"
#define UI_GHOST_TELEPORT "SOUTH:6,CENTER"
#define UI_GHOST_RESPAWN_LIST "SOUTH:6,CENTER+1"
#define UI_GHOST_RESPAWN_MOB "SOUTH:6+1,CENTER+1"
#define UI_GHOST_RESPAWN_PAI "SOUTH:6+2,CENTER+1"
#define UI_GHOST_RESPAWN_CHAR "SOUTH:6,CENTER+2"

//HUD styles. Please ensure HUD_VERSIONS is the same as the maximum index. Index order defines how they are cycled in F12.
#define HUD_STYLE_STANDARD 1
#define HUD_STYLE_REDUCED 2
#define HUD_STYLE_NOHUD 3
#define HUD_STYLE_ACTIONHUD 4


#define HUD_VERSIONS 4	//used in show_hud()
//1 = standard hud
//2 = reduced hud (just hands and intent switcher)
//3 = no hud (for screenshots)
//4 = Only action buttons (so vampires / changelings and such can use abilities while asleep)
