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

//Upper left action buttons, displayed when you pick up an item that has this enabled.
#define ui_action_slot1 "1:6,16:26"
#define ui_action_slot2 "2:8,16:26"
#define ui_action_slot3 "3:10,16:26"
#define ui_action_slot4 "4:12,16:26"
#define ui_action_slot5 "5:14,16:26"
#define ui_action_slot6 "6:16,16:26"
#define ui_action_slot7 "7:18,16:26"
#define ui_action_slot8 "8:20,16:26"
#define ui_action_slot9 "9:22,16:26"
#define ui_action_slot10 "10:24,16:26"

#define ui_power_slot1 "1:6,15:24"
#define ui_power_slot2 "2:8,15:24"
#define ui_power_slot3 "3:10,15:24"
#define ui_power_slot4 "4:12,15:24"
#define ui_power_slot5 "5:14,15:24"
#define ui_power_slot6 "6:16,15:24"
#define ui_power_slot7 "7:18,15:24"
#define ui_power_slot8 "8:20,15:24"
#define ui_power_slot9 "9:22,15:24"
#define ui_power_slot10 "10:24,15:24"

//Middle left indicators
#define ui_alienplasmadisplay "1,6:15"

//Lower left, persistant menu
#define ui_inventory "1:6,1:5"

//Lower center, persistant menu
#define ui_sstore1 "3:10,1:5"
#define ui_id "4:12,1:5"
#define ui_belt "5:14,1:5"
#define ui_back "6:14,1:5"
#define ui_rhand "7:16,1:5"
#define ui_lhand "8:16,1:5"
#define ui_equip "7:16,2:5"
#define ui_swaphand1 "7:16,2:5"
#define ui_swaphand2 "8:16,2:5"
#define ui_storage1 "9:18,1:5"
#define ui_storage2 "10:20,1:5"

#define ui_pda "11:22,1:5"

#define ui_alien_head "4:12,1:5"	//aliens
#define ui_alien_oclothing "5:14,1:5"	//aliens

#define ui_inv1 "6:16,1:5"			//borgs
#define ui_inv2 "7:16,1:5"			//borgs
#define ui_inv3 "8:16,1:5"			//borgs
#define ui_borg_module "CENTER+1:16,SOUTH:5"
#define ui_borg_store "CENTER+2:16,SOUTH:5"		//borgs


#define ui_monkey_mask "5:14,1:5"	//monkey
#define ui_monkey_back "6:14,1:5"	//monkey

//Lower right, persistant menu
//#define ui_dropbutton "11:22,1:5"
#define ui_drop_throw "16:28,2:7"
#define ui_pull_resist "15:26,2:7"
#define ui_acti "15:26,1:5"
#define ui_movi "14:24,1:5"
#define ui_zonesel "16:28,1:5"
#define ui_acti_alt "16:28,1:5" //alternative intent switcher for when the interface is hidden (F12)

#define ui_borg_pull "EAST-2:26,SOUTH+1:7"
#define ui_borg_radio "EAST-1:28,SOUTH+1:7"
#define ui_borg_intents "EAST-2:26,SOUTH:5"

//Gun buttons
#define ui_gun1 "15:26,3:7"
#define ui_gun2 "16:28, 4:7"
#define ui_gun3 "15:26,4:7"
#define ui_gun_select "16:28,3:7"

//Upper-middle right (damage indicators)
#define ui_toxin "16:28,13:27"
#define ui_fire "16:28,12:25"
#define ui_oxygen "16:28,11:23"
#define ui_pressure "16:28,10:21"

#define ui_alien_toxin "16:28,13:25"
#define ui_alien_fire "16:28,12:25"
#define ui_alien_oxygen "16:28,11:25"

//Middle right (status indicators)
#define ui_nutrition "16:28,5:11"
#define ui_temp "16:28,6:13"
#define ui_health "16:28,7:15"
#define ui_internal "16:28,8:17"
									//borgs
#define ui_borg_health "16:28,6:13" //borgs have the health display where humans have the pressure damage indicator.
#define ui_alien_health "16:28,6:13" //aliens have the health display where humans have the pressure damage indicator.

//Pop-up inventory
#define ui_shoes "2:8,1:5"

#define ui_iclothing "1:6,2:7"
#define ui_oclothing "2:8,2:7"
#define ui_gloves "3:10,2:7"


#define ui_glasses "1:6,3:9"
#define ui_mask "2:8,3:9"
#define ui_l_ear "3:10,3:9"
#define ui_r_ear "3:10,4:11"

#define ui_head "2:8,4:11"

//Intent small buttons
#define ui_help_small "14:8,1:1"
#define ui_disarm_small "14:15,1:18"
#define ui_grab_small "14:32,1:18"
#define ui_harm_small "14:39,1:1"

//#define ui_swapbutton "6:-16,1:5" //Unused

//#define ui_headset "SOUTH,8"
#define ui_hand "6:14,1:5"
#define ui_hstore1 "5,5"
//#define ui_resist "EAST+1,SOUTH-1"
#define ui_sleep "EAST+1, NORTH-13"
#define ui_rest "EAST+1, NORTH-14"


#define ui_iarrowleft "SOUTH-1,11"
#define ui_iarrowright "SOUTH-1,13"

// AI

#define ui_ai_core "SOUTH:6,WEST:16"
#define ui_ai_camera_list "SOUTH:6,WEST+1:16"
#define ui_ai_track_with_camera "SOUTH:6,WEST+2:16"
#define ui_ai_camera_light "SOUTH:6,WEST+3:16"
#define ui_ai_crew_monitor "SOUTH:6,WEST+4:16"
#define ui_ai_crew_manifest "SOUTH:6,WEST+5:16"
#define ui_ai_alerts "SOUTH:6,WEST+6:16"
#define ui_ai_announcement "SOUTH:6,WEST+7:16"
#define ui_ai_shuttle "SOUTH:6,WEST+8:16"
#define ui_ai_state_laws "SOUTH:6,WEST+9:16"
#define ui_ai_pda_send "SOUTH:6,WEST+10:16"
#define ui_ai_pda_log "SOUTH:6,WEST+11:16"
#define ui_ai_take_picture "SOUTH:6,WEST+12:16"
#define ui_ai_view_images "SOUTH:6,WEST+13:16"