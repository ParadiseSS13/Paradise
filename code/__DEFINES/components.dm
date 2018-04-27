//shorthand
#define GET_COMPONENT_FROM(varname, path, target) var##path/##varname = ##target.GetComponent(##path)
#define GET_COMPONENT(varname, path) GET_COMPONENT_FROM(varname, path, src)

#define COMPONENT_INCOMPATIBLE 1

// How multiple components of the exact same type are handled in the same datum

#define COMPONENT_DUPE_HIGHLANDER 0		//old component is deleted (default)
#define COMPONENT_DUPE_ALLOWED 1		//duplicates allowed
#define COMPONENT_DUPE_UNIQUE 2			//new component is deleted
#define COMPONENT_DUPE_UNIQUE_PASSARGS 4	//old component is given the initialization args of the new

// All signals. Format:
// When the signal is called: (signal arguments)

// /datum signals
#define COMSIG_COMPONENT_ADDED "component_added"				//when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"			//before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_PARENT_QDELETED "parent_qdeleted"				//before a datum's Destroy() is called: ()

// /atom signals
#define COMSIG_PARENT_ATTACKBY "atom_attackby"			        //from base of atom/attackby(): (/obj/item, /mob/living, params)
	#define COMPONENT_NO_AFTERATTACK 1								//Return this in response if you don't want afterattack to be called
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"					//from base of atom/attack_hulk(): (/mob/living/carbon/human)
#define COMSIG_PARENT_EXAMINE "atom_examine"                    //from base of atom/examine(): (/mob)
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_examine_name"		//from base of atom/get_examine_name(): (/mob, list/overrides)
	//Positions for overrides list
	#define EXAMINE_POSITION_ARTICLE 1
	#define EXAMINE_POSITION_BEFORE 2
	//End positions
	#define COMPONENT_EXNAME_CHANGED 1
#define COMSIG_ATOM_ENTERED "atom_entered"                      //from base of atom/Entered(): (atom/movable/entering, /atom)
#define COMSIG_ATOM_EXITED "atom_exited"						//from base of atom/Exited(): (atom/movable/exiting, atom/newloc)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"						//from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"						//from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"					//from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"				//from base of atom/bullet_act(): (/obj/item/projectile, def_zone)
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"					//from base of atom/blob_act(): (/obj/structure/blob)
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"					//from base of atom/acid_act(): (acidpwr, acid_volume)
#define COMSIG_ATOM_EMAG_ACT "atom_emag_act"					//from base of atom/emag_act(): ()
#define COMSIG_ATOM_RAD_ACT "atom_rad_act"						//from base of atom/rad_act(intensity)
#define COMSIG_ATOM_NARSIE_ACT "atom_narsie_act"				//from base of atom/narsie_act(): ()
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"				//from base of atom/ratvar_act(): ()
#define COMSIG_ATOM_RCD_ACT "atom_rcd_act"						//from base of atom/rcd_act(): (/mob, /obj/item/construction/rcd, passed_mode)
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"					//from base of atom/singularity_pull(): (S, current_size)
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"					//from base of atom/set_light(): (l_range, l_power, l_color)
#define COMSIG_ATOM_ROTATE "atom_rotate"						//from base of atom/shuttleRotate(): (rotation, params)
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"				//from base of atom/setDir(): (old_dir, new_dir)
#define COMSIG_ATOM_CONTENTS_DEL "atom_contents_del"			//from base of atom/handle_atom_del(): (atom/deleted)
/////////////////
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"			//from base of atom/attack_ghost(): (mob/dead/observer/ghost)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"				//from base of atom/attack_hand(): (mob/user)
#define COMSIG_ATOM_ATTACK_PAW "atom_attack_paw"				//from base of atom/attack_paw(): (mob/user)
	#define COMPONENT_NO_ATTACK_HAND 1							//works on all 3.
/////////////////

#define COMSIG_ENTER_AREA "enter_area" 						//from base of area/Entered(): (/area)
#define COMSIG_EXIT_AREA "exit_area" 							//from base of area/Exited(): (/area)

#define COMSIG_CLICK "atom_click"								//from base of atom/Click(): (location, control, params)
#define COMSIG_CLICK_SHIFT "shift_click"						//from base of atom/ShiftClick(): (/mob)
#define COMSIG_CLICK_CTRL "ctrl_click"							//from base of atom/CtrlClickOn(): (/mob)
#define COMSIG_CLICK_ALT "alt_click"							//from base of atom/AltClick(): (/mob)
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"				//from base of atom/CtrlShiftClick(/mob)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"					//from base of atom/MouseDrop(): (/atom/over, /mob/user)
	#define COMPONENT_NO_MOUSEDROP 1
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"			//from base of atom/MouseDrop_T: (/atom/from, /mob/user)

// /area signals
#define COMSIG_AREA_ENTERED "area_entered" 						//from base of area/Entered(): (atom/movable/M)
#define COMSIG_AREA_EXITED "area_exited" 							//from base of area/Exited(): (atom/movable/M)

// /atom/movable signals
#define COMSIG_MOVABLE_MOVED "movable_moved"					//from base of atom/movable/Moved(): (/atom, dir)
#define COMSIG_MOVABLE_CROSSED "movable_crossed"                //from base of atom/movable/Crossed(): (/atom/movable)
#define COMSIG_MOVABLE_UNCROSSED "movable_uncrossed"            //from base of atom/movable/Uncrossed(): (/atom/movable)
#define COMSIG_MOVABLE_COLLIDE "movable_collide"				//from base of atom/movable/Collide(): (/atom)
#define COMSIG_MOVABLE_IMPACT "movable_impact"					//from base of atom/movable/throw_impact(): (/atom/hit_atom, /datum/thrownthing/throwingdatum)
#define COMSIG_MOVABLE_IMPACT_ZONE "item_impact_zone"				//from base of mob/living/hitby(): (mob/living/target, hit_zone)
#define COMSIG_MOVABLE_BUCKLE "buckle"								//from base of atom/movable/buckle_mob(): (mob, force)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"							//from base of atom/movable/unbuckle_mob(): (mob, force)
#define COMSIG_MOVABLE_THROW "movable_throw"					//from base of atom/movable/throw_at(): (datum/thrownthing, spin)

// /obj signals
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"				//from base of obj/deconstruct(): (disassembled)

// /obj/item signals
#define COMSIG_ITEM_ATTACK "item_attack"						//from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"				//from base of obj/item/attack_self(): (/mob)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"				//from base of obj/item/attack_obj(): (/obj, /mob)
	#define COMPONENT_NO_ATTACK_OBJ 1
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"				//from base of obj/item/pre_attack(): (atom/target, mob/user, params)
	#define COMPONENT_NO_ATTACK 1
#define COMSIG_ITEM_EQUIPPED "item_equip"						//from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_DROPPED "item_drop"
#define COMSIG_ITEM_PICKUP "item_pickup"						//from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_ATTACK_ZONE "item_attack_zone"				//from base of mob/living/carbon/attacked_by(): (mob/living/carbon/target, mob/living/user, hit_zone)

// /obj/item/clothing signals
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"			//from base of obj/item/clothing/shoes/proc/step_action(): ()

// /obj/machinery signals
#define COMSIG_MACHINE_PROCESS "machine_process"				//from machinery subsystem fire(): ()
#define COMSIG_MACHINE_PROCESS_ATMOS "machine_process_atmos"	//from air subsystem process_atmos_machinery(): ()

// /mob/living/carbon/human signals
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"			//from mob/living/carbon/human/UnarmedAttack(): (atom/target)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY "human_melee_unarmed_attackby"		//from mob/living/carbon/human/UnarmedAttack(): (mob/living/carbon/human/attacker)
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit"	//Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)

/*******Component Specific Signals*******/
//Janitor
#define COMSIG_TURF_IS_WET "check_turf_wet"							//(): Returns bitflags of wet values.
#define COMSIG_TURF_MAKE_DRY "make_turf_try"						//(max_strength, immediate, duration_decrease = INFINITY): Returns bool.
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"					//called on an object to clean it of cleanables. Usualy with soap: (num/strength)

//Food
#define COMSIG_FOOD_EATEN "food_eaten"		//from base of obj/item/reagent_containers/food/snacks/attack(): (mob/living/eater, mob/feeder)

//Mood
#define COMSIG_ADD_MOOD_EVENT "add_mood" //Called when you send a mood event from anywhere in the code.
#define COMSIG_CLEAR_MOOD_EVENT "clear_mood" //Called when you clear a mood event from anywhere in the code.

//NTnet
#define COMSIG_COMPONENT_NTNET_RECIEVE "ntnet_recieve"			//called on an object by its NTNET connection component on recieve. (sending_id(number), sending_netname(text), data(datum/netdata))

// /datum/component/storage signals
#define COMSIG_CONTAINS_STORAGE "is_storage"						//() - returns bool.
#define COMSIG_TRY_STORAGE_INSERT "storage_try_insert"				//(obj/item/inserting, mob/user, silent, force) - returns bool
#define COMSIG_TRY_STORAGE_SHOW "storage_show_to"					//(mob/show_to, force) - returns bool.
#define COMSIG_TRY_STORAGE_HIDE_FROM "storage_hide_from"			//(mob/hide_from) - returns bool
#define COMSIG_TRY_STORAGE_HIDE_ALL "storage_hide_all"				//returns bool
#define COMSIG_TRY_STORAGE_SET_LOCKSTATE "storage_lock_set_state"	//(newstate)
#define COMSIG_IS_STORAGE_LOCKED "storage_get_lockstate"			//() - returns bool. MUST CHECK IF STORAGE IS THERE FIRST!
#define COMSIG_TRY_STORAGE_TAKE_TYPE "storage_take_type"			//(type, atom/destination, amount = INFINITY, check_adjacent, force, mob/user, list/inserted) - returns bool - type can be a list of types.
#define COMSIG_TRY_STORAGE_FILL_TYPE "storage_fill_type"			//(type, amount = INFINITY, force = FALSE)			//don't fuck this up. Force will ignore max_items, and amount is normally clamped to max_items.
#define COMSIG_TRY_STORAGE_TAKE "storage_take_obj"					//(obj, new_loc, force = FALSE) - returns bool
#define COMSIG_TRY_STORAGE_QUICK_EMPTY "storage_quick_empty"		//(loc) - returns bool - if loc is null it will dump at parent location.
#define COMSIG_TRY_STORAGE_RETURN_INVENTORY "storage_return_inventory"	//(list/list_to_inject_results_into)
#define COMSIG_TRY_STORAGE_CAN_INSERT "storage_can_equip"			//(obj/item/insertion_candidate, mob/user, silent) - returns bool

/*******Non-Signal Component Related Defines*******/

//Arch
#define ARCH_PROB "probability"					//Probability for each item
#define ARCH_MAXDROP "max_drop_amount"				//each item's max drop amount

//Ouch my toes!
#define CALTROP_BYPASS_SHOES 1
#define CALTROP_IGNORE_WALKERS 2
