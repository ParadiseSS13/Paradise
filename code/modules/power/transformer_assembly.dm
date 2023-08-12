
#define CONSTRUCTION_CIRCUIT_PRIED 1 // circuit board is removed, wires are available
#define CONSTRUCTION_WIRES_CUT 2 // wires are cut, and the silver internals are available
#define CONSTRUCTION_GUTTED 3 // silver Cylinders taken off, can safely unbolt
#define CONSTRUCTION_UNBOLTED 4 // Bolts loosened, can safely weld off the floor
#define CONSTRUCTION_UNWELDED 5 // welded off the floor, itsa free moving now and can be broken down!

/obj/item/transformer_electronics
	name = "transformer electronics"
	icon = 'icons/obj/module.dmi'
	icon_state = "engineering"
	item_state = "electronic"
	desc = "A circuit board used in construction of transformers."
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "engineering=2;programming=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/structure/transformer_assembly
	name = "Transformer Box Assembly"
	desc = "A titanium container that can be constructed into a transformer."
	icon = 'icons/obj/power.dmi'
	icon_state = "transformer_assembly"
	anchored = FALSE
	density = TRUE
	/// the current step we are in construct/deconstructing this transformer assembly
	var/construction_step = CONSTRUCTION_CIRCUIT_PRIED

/obj/structure/transformer_assembly/Initialize(mapload, current_construction_step)
	. = ..()
	construction_step = current_construction_step ? current_construction_step : CONSTRUCTION_UNWELDED
	if(construction_step == CONSTRUCTION_CIRCUIT_PRIED)
		new /obj/item/transformer_electronics(get_turf(src))
	if(construction_step != CONSTRUCTION_UNWELDED)
		anchored = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/structure/transformer_assembly/update_icon_state()
	. = ..()
	// there is only icon states for the first few construction steps
	icon_state = "transformer_assembly[clamp(construction_step, CONSTRUCTION_CIRCUIT_PRIED, CONSTRUCTION_GUTTED)]"

/obj/structure/transformer_assembly/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/structure/transformer_assembly/examine(mob/user)
	. = ..()
	switch(construction_step)
		if(CONSTRUCTION_CIRCUIT_PRIED)
			. += "<span class='notice'>The circuit board is missing and the wires have been exposed, it looks like they can be <i>cut out</i>.</span>"
		if(CONSTRUCTION_WIRES_CUT)
			. += "<span class='notice'>The internal <i>wires</i> are missing and the silver internals are <b>exposed</b>.</span>"
		if(CONSTRUCTION_GUTTED)
			. += "<span class='notice'>The <b>silver internals</b> are missing and the floor bolts are <b>connected</b>.</span>"
		if(CONSTRUCTION_UNBOLTED)
			. += "<span class='notice'>The floor bolts are <b>loose</b>. The frame could be <b>cut</b> from the floor plating.</span>"
		if(CONSTRUCTION_UNBOLTED)
			. += "<span class='notice'>It has been unanchored but could be welded to the floor.</span>"

/obj/structure/transformer_assembly/attackby(obj/item/C, mob/user)
	switch(construction_step)
		if(CONSTRUCTION_CIRCUIT_PRIED) // adding wires
			if(!istype(C, /obj/item/transformer_electronics))
				return ..()
			var/obj/item/transformer_electronics/E = C
			user.visible_message("<span class='notice'>[user] begins wiring [src]...</span>", \
								"<span class='notice'>You begin adding wires to [src]...</span>")
			playsound(get_turf(src), E.usesound, 50, 1)
			if(!do_after(user, (6 SECONDS) * E.toolspeed, target = src))
				return
			if(construction_step != CONSTRUCTION_CIRCUIT_PRIED || !E)
				return
			user.visible_message("<span class='notice'>[user] adds [E] to [src].</span>", \
								"<span class='notice'>You add [E] to [src].</span>")
			playsound(get_turf(src), E.usesound, 50, 1)
			E.use(5)
			new /obj/machinery/power/transformer(get_turf(src), TRUE)
			qdel(src)
			return
		if(CONSTRUCTION_WIRES_CUT) // adding wires
			if(!islvcoil(C))
				return ..()
			var/obj/item/stack/cable_coil/low_voltage/B = C
			if(B.get_amount() < 5)
				to_chat(user, "<span class='warning'>You need more wires to add wiring to [src].</span>")
				return
			user.visible_message("<span class='notice'>[user] begins wiring [src]...</span>", \
								"<span class='notice'>You begin adding wires to [src]...</span>")
			playsound(get_turf(src), B.usesound, 50, 1)
			if(!do_after(user, 60 * B.toolspeed, target = src))
				return
			if(construction_step != CONSTRUCTION_WIRES_CUT || !B || B.get_amount() < 5)
				return
			user.visible_message("<span class='notice'>[user] adds wires to [src].</span>", \
								"<span class='notice'>You wire [src].</span>")
			playsound(get_turf(src), B.usesound, 50, 1)
			B.use(5)
			construction_step = CONSTRUCTION_CIRCUIT_PRIED
			update_icon(UPDATE_ICON_STATE)
			return
		if(CONSTRUCTION_GUTTED) // adding silver internals
			if(!istype(C, /obj/item/stack/sheet/mineral/silver))
				return ..()
			var/obj/item/stack/sheet/mineral/silver/B = C
			if(B.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need more silver to construct [src]'s internals'.</span>")
				return
			user.visible_message("<span class='notice'>[user] begins adding the silver to [src]...</span>", \
								"<span class='notice'>You begin adding the silver to [src]...</span>")
			playsound(get_turf(src), B.usesound, 50, TRUE)
			if(!do_after(user, 3 SECONDS, target = src))
				return
			if(construction_step != CONSTRUCTION_GUTTED || !B || B.get_amount() < 2)
				return
			user.visible_message("<span class='notice'>[user] adds the silver to [src].</span>", \
								"<span class='notice'>You add the silver to [src].</span>")
			playsound(get_turf(src), C.usesound, 50, 1)
			construction_step = CONSTRUCTION_WIRES_CUT
			update_icon(UPDATE_ICON_STATE)
			B.use(2)
			return
	return ..()


/obj/structure/transformer_assembly/wrench_act(mob/user, obj/item/I)
	if(construction_step != CONSTRUCTION_UNBOLTED && construction_step != CONSTRUCTION_GUTTED)
		return FALSE
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(construction_step == CONSTRUCTION_UNBOLTED)
		WRENCH_ATTEMPT_ANCHOR_MESSAGE
	else
		WRENCH_ATTEMPT_UNANCHOR_MESSAGE

	if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
		return
	if(construction_step == CONSTRUCTION_UNBOLTED)
		WRENCH_ANCHOR_MESSAGE
		construction_step = CONSTRUCTION_GUTTED
		update_icon(UPDATE_ICON_STATE)
	else
		WRENCH_UNANCHOR_MESSAGE
		construction_step = CONSTRUCTION_UNBOLTED
		update_icon(UPDATE_ICON_STATE)

/obj/structure/transformer_assembly/welder_act(mob/user, obj/item/I)
	if(construction_step != CONSTRUCTION_UNBOLTED && construction_step != CONSTRUCTION_UNWELDED)
		if(!I.tool_use_check(user, 0))
			return TRUE
		default_welder_repair()
		return FALSE
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	switch(construction_step)
		if(CONSTRUCTION_UNBOLTED)
			WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
		if(CONSTRUCTION_UNWELDED)
			WELDER_ATTEMPT_FLOOR_WELD_MESSAGE

	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return

	switch(construction_step)
		if(CONSTRUCTION_UNBOLTED)
			WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
			construction_step = CONSTRUCTION_UNWELDED
			update_icon(UPDATE_ICON_STATE)
			anchored = FALSE
		if(CONSTRUCTION_UNWELDED)
			WELDER_FLOOR_WELD_SUCCESS_MESSAGE
			construction_step = CONSTRUCTION_UNBOLTED
			update_icon(UPDATE_ICON_STATE)
			anchored = TRUE

