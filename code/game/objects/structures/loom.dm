#define FABRIC_PER_SHEET 4


///This is a loom. It's usually made out of wood and used to weave fabric like durathread or cotton into their respective cloth types.
/obj/structure/loom
	name = "loom"
	desc = "A simple device used to weave cloth and other thread-based fabrics together into usable material."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "loom"
	density = TRUE
	anchored = TRUE
	// TODO: should absolutely be keyed to tool speed but
	// is just a constant for now for use in tests
	var/disassemble_speed = 5 SECONDS

/obj/structure/loom/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(weave(I, user))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/loom/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, disassemble_speed, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/loom/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 20)

/obj/structure/loom/deconstruct(disassembled = FALSE)
	var/mat_drop = 5
	if(disassembled)
		mat_drop = 10
	new /obj/item/stack/sheet/wood(drop_location(), mat_drop)
	..()

///Handles the weaving.
/obj/structure/loom/proc/weave(obj/item/stack/sheet/cotton/W, mob/user)
	if(!istype(W))
		return FALSE
	if(!anchored)
		user.show_message("<span class='notice'>The loom needs to be wrenched down.</span>", 1)
		return FALSE
	if(W.amount < FABRIC_PER_SHEET)
		user.show_message("<span class='notice'>You need at least [FABRIC_PER_SHEET] units of fabric before using this.</span>", 1)
		return FALSE
	user.show_message("<span class='notice'>You start weaving [W] through the loom...</span>", 1)
	if(do_after(user, W.pull_effort, target = src))
		if(W.amount >= FABRIC_PER_SHEET)
			new W.loom_result(drop_location())
			W.use(FABRIC_PER_SHEET)
			user.show_message("<span class='notice'>You weave [W] into a workable fabric.</span>", 1)
	return TRUE

#undef FABRIC_PER_SHEET
