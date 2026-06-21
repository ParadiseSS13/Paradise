// Tool tools
#define TOOL_CROWBAR 		"crowbar"
#define TOOL_MULTITOOL		"multitool"
#define TOOL_SCREWDRIVER 	"screwdriver"
#define TOOL_WIRECUTTER 	"wirecutter"
#define TOOL_WRENCH 		"wrench"
#define TOOL_WELDER 		"welder"
#define TOOL_HAMMER			"hammer"

GLOBAL_LIST_INIT(construction_tool_behaviors, list(
	TOOL_CROWBAR,
	TOOL_MULTITOOL,
	TOOL_SCREWDRIVER,
	TOOL_WIRECUTTER,
	TOOL_WRENCH,
	TOOL_WELDER
))

// Surgery tools
#define TOOL_RETRACTOR "retractor"
#define TOOL_HEMOSTAT "hemostat"
#define TOOL_CAUTERY "cautery"
#define TOOL_DRILL "drill"
#define TOOL_SCALPEL "scalpel"
#define TOOL_SAW "saw"
#define TOOL_BONESET "bone setter"
#define TOOL_BONEGEL "bone gel"
#define TOOL_FIXOVEIN "fix-o-vein"
#define TOOL_DISSECTOR "dissector"

GLOBAL_LIST_INIT(surgery_tool_behaviors, list(
	TOOL_RETRACTOR,
	TOOL_HEMOSTAT,
	TOOL_CAUTERY,
	TOOL_DRILL,
	TOOL_SCALPEL,
	TOOL_SAW,
	TOOL_BONESET,
	TOOL_BONEGEL,
	TOOL_FIXOVEIN,
	TOOL_DISSECTOR,
))

#define MIN_TOOL_SOUND_DELAY 20

//Crowbar messages
#define CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE	user.visible_message(SPAN_NOTICE("[user] begins removing the circuit board from [src]..."), SPAN_NOTICE("You begin removing the circuit board from [src]..."), SPAN_WARNING("You hear prying noises."))
#define CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE	user.visible_message(SPAN_NOTICE("[user] pries out the circuit board from [src]!"), SPAN_NOTICE("You pry out the circuit board from [src]!"), SPAN_WARNING("You hear prying noises."))

//Screwdriver messages
#define SCREWDRIVER_SCREW_MESSAGE			user.visible_message(SPAN_NOTICE("[user] tightens the screws on [src]!"), SPAN_NOTICE("You tighten the screws on [src]!"), SPAN_WARNING("You hear a screwdriver."))
#define SCREWDRIVER_UNSCREW_MESSAGE			user.visible_message(SPAN_NOTICE("[user] loosens the screws on [src]!"), SPAN_NOTICE("You loosen the screws on [src]!"), SPAN_WARNING("You hear a screwdriver."))
#define SCREWDRIVER_OPEN_PANEL_MESSAGE		user.visible_message(SPAN_NOTICE("[user] opens the panel on [src]!"), SPAN_NOTICE("You open the panel on [src]!"), SPAN_WARNING("You hear a screwdriver."))
#define SCREWDRIVER_CLOSE_PANEL_MESSAGE		user.visible_message(SPAN_NOTICE("[user] closes the panel on [src]!"), SPAN_NOTICE("You close the panel on [src]!"), SPAN_WARNING("You hear a screwdriver."))

//Wirecutter messages
#define WIRECUTTER_SNIP_MESSAGE					user.visible_message(SPAN_NOTICE("[user] cuts the wires from [src]!"), SPAN_NOTICE("You cut the wires from [src]!"), SPAN_WARNING("You hear snipping."))
#define WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE	user.visible_message(SPAN_NOTICE("[user] begins cutting [src] apart..."), SPAN_NOTICE("You begin cutting [src] apart..."), SPAN_WARNING("You hear snipping."))
#define WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE	user.visible_message(SPAN_NOTICE("[user] cuts [src] apart!"), SPAN_NOTICE("You cut [src] apart!"), SPAN_WARNING("You hear snipping."))

//Welder messages and other stuff
#define HEALPERWELD 15
#define WELDER_ATTEMPT_WELD_MESSAGE			user.visible_message(SPAN_NOTICE("[user] begins welding [src]..."), SPAN_NOTICE("You begin welding [src]..."), SPAN_WARNING("You hear welding."))
#define WELDER_WELD_SUCCESS_MESSAGE			to_chat(user, SPAN_NOTICE("You finish welding [src]!"))
#define WELDER_ATTEMPT_REPAIR_MESSAGE		user.visible_message(SPAN_NOTICE("[user] begins repairing the damage on [src]..."), SPAN_NOTICE("You begin repairing [src]..."), SPAN_WARNING("You hear welding."))
#define WELDER_REPAIR_SUCCESS_MESSAGE		to_chat(user, SPAN_NOTICE("You repair the damage on [src]!"))
#define WELDER_ATTEMPT_SLICING_MESSAGE		user.visible_message(SPAN_NOTICE("[user] begins slicing through [src]..."), SPAN_NOTICE("You begin slicing through [src]..."), SPAN_WARNING("You hear welding."))
#define WELDER_SLICING_SUCCESS_MESSAGE		to_chat(user, SPAN_NOTICE("You slice clean through [src]!"))
#define WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE	user.visible_message(SPAN_NOTICE("[user] begins slicing [src] free from [get_turf(src)]..."), SPAN_NOTICE("You begin slicing [src] free from [get_turf(src)]..."), SPAN_WARNING("You hear welding."))
#define WELDER_FLOOR_SLICE_SUCCESS_MESSAGE	to_chat(user, SPAN_NOTICE("You slice [src] clear of [get_turf(src)]!"))
#define WELDER_ATTEMPT_FLOOR_WELD_MESSAGE	user.visible_message(SPAN_NOTICE("[user] begins welding [src] to [get_turf(src)]..."), SPAN_NOTICE("You begin welding [src] to [get_turf(src)]..."), SPAN_WARNING("You hear welding."))
#define WELDER_FLOOR_WELD_SUCCESS_MESSAGE	to_chat(user, SPAN_NOTICE("You weld [src] to [get_turf(src)]!"))
#define WELDER_ATTEMPT_UNWELD_MESSAGE		user.visible_message(SPAN_NOTICE("[user] begins cutting through the weld on [src]..."), SPAN_NOTICE("You begin cutting through the weld on [src]..."), SPAN_WARNING("You hear welding."))
#define WELDER_UNWELD_SUCCESS_MESSAGE		to_chat(user, SPAN_NOTICE("You finish unwelding [src]!"))

//Wrench messages
#define WRENCH_ANCHOR_MESSAGE				user.visible_message(SPAN_NOTICE("[user] tightens the bolts on [src]!"), SPAN_NOTICE("You tighten the bolts on [src]!"), SPAN_WARNING("You hear ratcheting."))
#define WRENCH_UNANCHOR_MESSAGE				user.visible_message(SPAN_NOTICE("[user] loosens the bolts on [src]!"), SPAN_NOTICE("You loosen the bolts on [src]!"), SPAN_WARNING("You hear ratcheting."))
#define WRENCH_ATTEMPT_ANCHOR_MESSAGE				user.visible_message(SPAN_NOTICE("[user] begins tightening the bolts on [src]..."), SPAN_NOTICE("You begin tightening the bolts on [src]..."), SPAN_WARNING("You hear ratcheting."))
#define WRENCH_ATTEMPT_UNANCHOR_MESSAGE				user.visible_message(SPAN_NOTICE("[user] begins loosening the bolts on [src]..."), SPAN_NOTICE("You begin loosening the bolts on [src]..."), SPAN_WARNING("You hear ratcheting."))
#define WRENCH_UNANCHOR_WALL_MESSAGE		user.visible_message(SPAN_NOTICE("[user] unwrenches [src] from the wall!"), SPAN_NOTICE("You unwrench [src] from the wall!"), SPAN_WARNING("You hear ratcheting."))
#define WRENCH_ANCHOR_TO_WALL_MESSAGE		user.visible_message(SPAN_NOTICE("[user] affixes [src] to the wall!"), SPAN_NOTICE("You affix [src] to the wall!"), SPAN_WARNING("You hear ratcheting."))

//Generic tool messages that don't correspond to any particular tool
#define TOOL_ATTEMPT_DISMANTLE_MESSAGE	    user.visible_message(SPAN_NOTICE("[user] begins to disassemble [src] with [I]..."), SPAN_NOTICE("You begin to disassemble [src] with [I]..."), SPAN_WARNING("You hear someone using some kind of tool."))
#define TOOL_DISMANTLE_SUCCESS_MESSAGE  	user.visible_message(SPAN_NOTICE("[user] dismantles [src]!"), SPAN_NOTICE("You dismantle [src]!"), SPAN_WARNING("You hear someone using some kind of tool."))
