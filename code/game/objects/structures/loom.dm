#define FABRIC_PER_SHEET 4


///This is a loom. It's usually made out of wood and used to weave fabric like durathread or cotton into their respective cloth types.
/obj/structure/loom
	name = "loom"
	desc = "A simple device used to weave cloth and other thread-based fabrics together into usable material."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "loom"
	density = TRUE
	anchored = TRUE

/obj/structure/loom/attackby(obj/item/I, mob/user)
	if(default_unfasten_wrench(user, I, 5))
		return
	if(weave(I, user))
		return
	return ..()

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
	user.show_message("<span class='notice'>You start weaving \the [W.name] through the loom..</span>", 1)
	if(do_after(user, W.pull_effort, target = src))
		if(W.amount >= FABRIC_PER_SHEET)
			new W.loom_result(drop_location())
			W.use(FABRIC_PER_SHEET)
			user.show_message("<span class='notice'>You weave \the [W.name] into a workable fabric.</span>", 1)
	return TRUE

#undef FABRIC_PER_SHEET