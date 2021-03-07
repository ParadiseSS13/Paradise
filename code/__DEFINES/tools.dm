#define TOOL_CROWBAR 		"crowbar"
#define TOOL_MULTITOOL		"multitool"
#define TOOL_SCREWDRIVER 	"screwdriver"
#define TOOL_WIRECUTTER 	"wirecutter"
#define TOOL_WRENCH 		"wrench"
#define TOOL_WELDER 		"welder"

#define MIN_TOOL_SOUND_DELAY 20

//Crowbar messages
#define CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE	user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", "<span class='notice'>You begin removing the circuit board from [src]...</span>", "<span class='warning'>You hear prying noises.</span>")
#define CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE	user.visible_message("<span class='notice'>[user] pries out the circuit board from [src]!</span>", "<span class='notice'>You pry out the circuit board from [src]!</span>", "<span class='warning'>You hear prying noises.</span>")

//Screwdriver messages
#define SCREWDRIVER_SCREW_MESSAGE			user.visible_message("<span class='notice'>[user] tightens the screws on [src]!</span>", "<span class='notice'>You tighten the screws on [src]!</span>", "<span class='warning'>You hear a screwdriver.</span>")
#define SCREWDRIVER_UNSCREW_MESSAGE			user.visible_message("<span class='notice'>[user] loosens the screws on [src]!</span>", "<span class='notice'>You loosen the screws on [src]!</span>", "<span class='warning'>You hear a screwdriver.</span>")
#define SCREWDRIVER_OPEN_PANEL_MESSAGE		user.visible_message("<span class='notice'>[user] opens the panel on [src]!</span>", "<span class='notice'>You open the panel on [src]!</span>", "<span class='warning'>You hear a screwdriver.</span>")
#define SCREWDRIVER_CLOSE_PANEL_MESSAGE		user.visible_message("<span class='notice'>[user] closes the panel on [src]!</span>", "<span class='notice'>You close the panel on [src]!</span>", "<span class='warning'>You hear a screwdriver.</span>")

//Wirecutter messages
#define WIRECUTTER_SNIP_MESSAGE					user.visible_message("<span class='notice'>[user] cuts the wires from [src]!</span>", "<span class='notice'>You cut the wires from [src]!</span>", "<span class='warning'>You hear snipping.</span>")
#define WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE	user.visible_message("<span class='notice'>[user] begins cutting [src] apart... </span>", "<span class='notice'>You begin cutting [src] apart...</span>", "<span class='warning'>You hear snipping.</span>")
#define WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE	user.visible_message("<span class='notice'>[user] cuts [src] apart!</span>", "<span class='notice'>You cut [src] apart!</span>", "<span class='warning'>You hear snipping.</span>")

//Welder messages and other stuff
#define HEALPERWELD 15
#define WELDER_ATTEMPT_WELD_MESSAGE			user.visible_message("<span class='notice'>[user] begins welding [src]...</span>", "<span class='notice'>You begin welding [src]...</span>", "<span class='warning'>You hear welding.</span>")
#define WELDER_WELD_SUCCESS_MESSAGE			to_chat(user, "<span class='notice'>You finish welding [src]!</span>")
#define WELDER_ATTEMPT_REPAIR_MESSAGE		user.visible_message("<span class='notice'>[user] begins repairing the damage on [src]...</span>", "<span class='notice'>You begin repairing [src]...</span>", "<span class='warning'>You hear welding.</span>")
#define WELDER_REPAIR_SUCCESS_MESSAGE		to_chat(user, "<span class='notice'>You repair the damage on [src]!</span>")
#define WELDER_ATTEMPT_SLICING_MESSAGE		user.visible_message("<span class='notice'>[user] begins slicing through [src]...</span>", "<span class='notice'>You begin slicing through [src]...</span>", "<span class='warning'>You hear welding.</span>")
#define WELDER_SLICING_SUCCESS_MESSAGE		to_chat(user, "<span class='notice'>You slice clean through [src]!</span>")
#define WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE	user.visible_message("<span class='notice'>[user] begins slicing [src] free from [get_turf(src)]...</span>", "<span class='notice'>You begin slicing [src] free from [get_turf(src)]...</span>", "<span class='warning'>You hear welding.</span>")
#define WELDER_FLOOR_SLICE_SUCCESS_MESSAGE	to_chat(user, "<span class='notice'>You slice [src] clear of [get_turf(src)]!</span>")
#define WELDER_ATTEMPT_FLOOR_WELD_MESSAGE	user.visible_message("<span class='notice'>[user] begins welding [src] to [get_turf(src)]...</span>", "<span class='notice'>You begin welding [src] to [get_turf(src)]...</span>", "<span class='warning'>You hear welding.</span>")
#define WELDER_FLOOR_WELD_SUCCESS_MESSAGE	to_chat(user, "<span class='notice'>You weld [src] to [get_turf(src)]!</span>")

//Wrench messages
#define WRENCH_ANCHOR_MESSAGE				user.visible_message("<span class='notice'>[user] tightens the bolts on [src]!</span>", "<span class='notice'>You tighten the bolts on [src]!</span>", "<span class='warning'>You hear ratcheting.</span>")
#define WRENCH_UNANCHOR_MESSAGE				user.visible_message("<span class='notice'>[user] loosens the bolts on [src]!</span>", "<span class='notice'>You loosen the bolts on [src]!</span>", "<span class='warning'>You hear ratcheting.</span>")
#define WRENCH_UNANCHOR_WALL_MESSAGE		user.visible_message("<span class='notice'>[user] unwrenches [src] from the wall!</span>", "<span class='notice'>You unwrench [src] from the wall!</span>", "<span class='warning'>You hear ratcheting.</span>")
#define WRENCH_ANCHOR_TO_WALL_MESSAGE		user.visible_message("<span class='notice'>[user] affixes [src] to the wall!</span>", "<span class='notice'>You affix [src] to the wall!</span>", "<span class='warning'>You hear ratcheting.</span>")

//Generic tool messages that don't correspond to any particular tool
#define TOOL_ATTEMPT_DISMANTLE_MESSAGE	    user.visible_message("<span class='notice'>[user] begins to disassemble [src] with [I]...</span>", "<span class='notice'>You begin to disassemble [src] with [I]...</span>", "<span class='warning'>You hear someone using some kind of tool.</span>")
#define TOOL_DISMANTLE_SUCCESS_MESSAGE  	user.visible_message("<span class='notice'>[user] dismantles [src]!</span>", "<span class='notice'>You dismantle [src]!</span>", "<span class='warning'>You hear someone using some kind of tool.</span>")
