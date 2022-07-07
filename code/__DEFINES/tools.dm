#define TOOL_CROWBAR 		"crowbar"
#define TOOL_MULTITOOL		"multitool"
#define TOOL_SCREWDRIVER 	"screwdriver"
#define TOOL_WIRECUTTER 	"wirecutter"
#define TOOL_WRENCH 		"wrench"
#define TOOL_WELDER 		"welder"

#define MIN_TOOL_SOUND_DELAY 20

//Crowbar messages
#define CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE	user.visible_message(span_notice("[user] begins removing the circuit board from [src]..."), span_notice("You begin removing the circuit board from [src]..."), span_warning("You hear prying noises."))
#define CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE	user.visible_message(span_notice("[user] pries out the circuit board from [src]!"), span_notice("You pry out the circuit board from [src]!"), span_warning("You hear prying noises."))

//Screwdriver messages
#define SCREWDRIVER_SCREW_MESSAGE			user.visible_message(span_notice("[user] tightens the screws on [src]!"), span_notice("You tighten the screws on [src]!"), span_warning("You hear a screwdriver."))
#define SCREWDRIVER_UNSCREW_MESSAGE			user.visible_message(span_notice("[user] loosens the screws on [src]!"), span_notice("You loosen the screws on [src]!"), span_warning("You hear a screwdriver."))
#define SCREWDRIVER_OPEN_PANEL_MESSAGE		user.visible_message(span_notice("[user] opens the panel on [src]!"), span_notice("You open the panel on [src]!"), span_warning("You hear a screwdriver."))
#define SCREWDRIVER_CLOSE_PANEL_MESSAGE		user.visible_message(span_notice("[user] closes the panel on [src]!"), span_notice("You close the panel on [src]!"), span_warning("You hear a screwdriver."))

//Wirecutter messages
#define WIRECUTTER_SNIP_MESSAGE					user.visible_message(span_notice("[user] cuts the wires from [src]!"), span_notice("You cut the wires from [src]!"), span_warning("You hear snipping."))
#define WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE	user.visible_message(span_notice("[user] begins cutting [src] apart... "), span_notice("You begin cutting [src] apart..."), span_warning("You hear snipping."))
#define WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE	user.visible_message(span_notice("[user] cuts [src] apart!"), span_notice("You cut [src] apart!"), span_warning("You hear snipping."))

//Welder messages and other stuff
#define HEALPERWELD 15
#define WELDER_ATTEMPT_WELD_MESSAGE			user.visible_message(span_notice("[user] begins welding [src]..."), span_notice("You begin welding [src]..."), span_warning("You hear welding."))
#define WELDER_WELD_SUCCESS_MESSAGE			to_chat(user, span_notice("You finish welding [src]!"))
#define WELDER_ATTEMPT_REPAIR_MESSAGE		user.visible_message(span_notice("[user] begins repairing the damage on [src]..."), span_notice("You begin repairing [src]..."), span_warning("You hear welding."))
#define WELDER_REPAIR_SUCCESS_MESSAGE		to_chat(user, span_notice("You repair the damage on [src]!"))
#define WELDER_ATTEMPT_SLICING_MESSAGE		user.visible_message(span_notice("[user] begins slicing through [src]..."), span_notice("You begin slicing through [src]..."), span_warning("You hear welding."))
#define WELDER_SLICING_SUCCESS_MESSAGE		to_chat(user, span_notice("You slice clean through [src]!"))
#define WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE	user.visible_message(span_notice("[user] begins slicing [src] free from [get_turf(src)]..."), span_notice("You begin slicing [src] free from [get_turf(src)]..."), span_warning("You hear welding."))
#define WELDER_FLOOR_SLICE_SUCCESS_MESSAGE	to_chat(user, span_notice("You slice [src] clear of [get_turf(src)]!"))
#define WELDER_ATTEMPT_FLOOR_WELD_MESSAGE	user.visible_message(span_notice("[user] begins welding [src] to [get_turf(src)]..."), span_notice("You begin welding [src] to [get_turf(src)]..."), span_warning("You hear welding."))
#define WELDER_FLOOR_WELD_SUCCESS_MESSAGE	to_chat(user, span_notice("You weld [src] to [get_turf(src)]!"))
#define WELDER_ATTEMPT_UNWELD_MESSAGE		user.visible_message(span_notice("[user] begins cutting through the weld on [src]..."), span_notice("You begin cutting through the weld on [src]..."), span_warning("You hear welding."))
#define WELDER_UNWELD_SUCCESS_MESSAGE		to_chat(user, span_notice("You finish unwelding [src]!"))

//Wrench messages
#define WRENCH_ANCHOR_MESSAGE				user.visible_message(span_notice("[user] tightens the bolts on [src]!"), span_notice("You tighten the bolts on [src]!"), span_warning("You hear ratcheting."))
#define WRENCH_UNANCHOR_MESSAGE				user.visible_message(span_notice("[user] loosens the bolts on [src]!"), span_notice("You loosen the bolts on [src]!"), span_warning("You hear ratcheting."))
#define WRENCH_UNANCHOR_WALL_MESSAGE		user.visible_message(span_notice("[user] unwrenches [src] from the wall!"), span_notice("You unwrench [src] from the wall!"), span_warning("You hear ratcheting."))
#define WRENCH_ANCHOR_TO_WALL_MESSAGE		user.visible_message(span_notice("[user] affixes [src] to the wall!"), span_notice("You affix [src] to the wall!"), span_warning("You hear ratcheting."))

//Generic tool messages that don't correspond to any particular tool
#define TOOL_ATTEMPT_DISMANTLE_MESSAGE	    user.visible_message(span_notice("[user] begins to disassemble [src] with [I]..."), span_notice("You begin to disassemble [src] with [I]..."), span_warning("You hear someone using some kind of tool."))
#define TOOL_DISMANTLE_SUCCESS_MESSAGE  	user.visible_message(span_notice("[user] dismantles [src]!"), span_notice("You dismantle [src]!"), span_warning("You hear someone using some kind of tool."))
