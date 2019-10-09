#define TOOL_CROWBAR 		"crowbar"
#define TOOL_MULTITOOL		"multitool"
#define TOOL_SCREWDRIVER 	"screwdriver"
#define TOOL_WIRECUTTER 	"wirecutter"
#define TOOL_WRENCH 		"wrench"
#define TOOL_WELDER 		"welder"

#define MIN_TOOL_SOUND_DELAY 20

//Welder stuff e.g. messages
#define HEALPERWELD 15
#define WELDER_WELD_MESSAGE				user.visible_message("<span class='notice'>[user] begins welding [src]...</span>", "<span class='notice'>You begin welding [src]...</span>", "<span class='warning'>You hear welding.</span>")
#define WELDER_REPAIR_MESSAGE			user.visible_message("<span class='notice'>[user] begins repairing the damage on [src]...</span>", "<span class='notice'>You begin repairing [src]...</span>", "<span class='warning'>You hear welding.</span>")
#define WELDER_SLICING_MESSAGE			user.visible_message("<span class='notice'>[user] begins slicing through [src]...</span>", "<span class='notice'>You begin slicing through [src]...</span>", "<span class='warning'>You hear welding.</span>")
#define WELDER_FLOOR_SLICE_MESSAGE		user.visible_message("<span class='notice'>[user] begins slicing [src] free from [get_turf(src)]...</span>", "<span class='notice'>You begin slicing [src] free from [get_turf(src)]...</span>", "<span class='warning'>You hear welding.</span>")
#define WELDER_FLOOR_WELD_MESSAGE		user.visible_message("<span class='notice'>[user] begins welding [src] to [get_turf(src)]...</span>", "<span class='notice'>You begin welding [src] to [get_turf(src)]...</span>", "<span class='warning'>You hear welding.</span>")

#define WELDER_WELD_SUCCESS_MESSAGE			to_chat(user, "<span class='notice'>You finish welding [src]!</span>")
#define WELDER_REPAIR_SUCCESS_MESSAGE		to_chat(user, "<span class='notice'>You repair the damage on [src]!</span>")
#define WELDER_SLICING_SUCCESS_MESSAGE		to_chat(user, "<span class='notice'>You slice clean through [src]!</span>")
#define WELDER_FLOOR_SLICE_SUCCESS_MESSAGE	to_chat(user, "<span class='notice'>You slice [src] clear of [get_turf(src)]!</span>")
#define WELDER_FLOOR_WELD_SUCCESS_MESSAGE	to_chat(user, "<span class='notice'>You weld [src] to [get_turf(src)]!</span>")
