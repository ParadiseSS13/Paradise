#define SHOWER_OPEN_LAYER OBJ_LAYER + 0.4
#define SHOWER_CLOSED_LAYER MOB_LAYER + 0.1

/obj/structure/curtain
	icon = 'icons/obj/curtain.dmi'
	name = "curtain"
	icon_state = "closed"
	face_while_pulling = FALSE
	layer = SHOWER_CLOSED_LAYER
	opacity = TRUE
	density = FALSE
	var/image/overlay = null
	new_attack_chain = TRUE
	var/assembled = FALSE
	var/overlay_color = "#ffffff"
	var/overlay_alpha = 255


/obj/structure/curtain/Initialize(mapload)
	. = ..()
	if(opacity)
		icon_state = "closed"
		overlay = image("closed_overlay")
		overlay.color = overlay_color
		overlay.alpha = overlay_alpha
		add_overlay(overlay)
		layer = SHOWER_CLOSED_LAYER
	else
		icon_state = "open"
		overlay = image("open_overlay")
		overlay.color = overlay_color
		overlay.alpha = overlay_alpha
		add_overlay(overlay)
		layer = SHOWER_OPEN_LAYER

/obj/structure/curtain/open
	icon_state = "open"
	layer = SHOWER_OPEN_LAYER
	opacity = FALSE

/obj/item/mounted/curtain/curtain_fixture
	icon_state = "handheld"
	icon = 'icons/obj/curtain.dmi'
	name = "\improper curtain rod assembly"
	new_attack_chain = TRUE

/obj/item/mounted/curtain/curtain_fixture/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(!istype(target ,/obj/structure/window) && !istype(target, /turf/simulated/wall/))
		return
	var/on_wall = get_turf(target)
	to_chat(user, "<span class='notice'>You begin attaching [src] to [on_wall].</span>")
	playsound(get_turf(src), 'sound/machines/click.ogg', 75, TRUE)
	if(!do_after(user, 3 SECONDS, target = on_wall))
		return
	var/obj/structure/curtain/assembly/new_curtain = new /obj/structure/curtain/assembly(on_wall)
	new_curtain.fingerprints = src.fingerprints
	new_curtain.fingerprintshidden = src.fingerprintshidden
	new_curtain.fingerprintslast = src.fingerprintslast

	user.visible_message("<span class='notice'>[user] attaches the [src] to [on_wall].</span>", \
		"<span class='notice'>You attach the [src] to [on_wall].</span>")
	qdel(src)

/obj/item/mounted/curtain/curtain_fixture/activate_self(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You begin attaching [src] to the ceiling.</span>")
	playsound(get_turf(src), 'sound/machines/click.ogg', 75, TRUE)
	if(!do_after(user, 3 SECONDS, target = get_turf(user)))
		return
	var/obj/structure/curtain/assembly/new_curtain = new /obj/structure/curtain/assembly(get_turf(user))
	new_curtain.fingerprints = src.fingerprints
	new_curtain.fingerprintshidden = src.fingerprintshidden
	new_curtain.fingerprintslast = src.fingerprintslast

	user.visible_message("<span class='notice'>[user] attaches the [src] to the ceiling.</span>", \
		"<span class='notice'>You attach the [src] to the ceiling.</span>")
	qdel(src)



/obj/structure/curtain/assembly
	icon_state = "assembly0"
	name = "Curtain Rod"
	opacity = FALSE
	density = FALSE
	desc = "A curtain assembly! It needs a <b>material</b>."

/obj/structure/curtain/assembly/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-Click to take it down.</span>"

/obj/structure/curtain/assembly/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	// TODO: turn back into assembly item
	new /obj/item/mounted/curtain/curtain_fixture(get_turf(user))
	playsound(loc, 'sound/effects/salute.ogg' , 75, TRUE)
	qdel(src)

/obj/structure/curtain/assembly/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stack/sheet/cloth)) // Are we putting the cloth onto the assembly on the wall?
		var/obj/item/stack/sheet/cloth/cloth_used = used
		if(!cloth_used.use(2))
			to_chat(user, "<span class='warning'> You need two sheets of cloth to hang the curtains.</span>")
			return ITEM_INTERACT_COMPLETE

		var/obj/structure/curtain/new_curtain = new /obj/structure/curtain/(loc, 1)
		new_curtain.assembled = TRUE
		playsound(loc, used.drop_sound, 75, TRUE) // Play a generic cloth sound.
		qdel(src)

		return ITEM_INTERACT_COMPLETE

/obj/structure/curtain/attack_hand(mob/user)
	playsound(get_turf(loc), "rustle", 15, TRUE, -5)
	toggle()
	..()
/obj/structure/curtain/attack_robot(mob/living/user)
	. = ..()
	playsound(get_turf(loc), "rustle", 15, TRUE, -5)
	toggle()
	..()


/obj/structure/curtain/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/curtain/proc/toggle()
	set_opacity(!opacity)
	cut_overlays()
	if(opacity)
		icon_state = "closed"
		overlay = image("closed_overlay")
		overlay.color = overlay_color
		overlay.alpha = overlay_alpha
		add_overlay(overlay)
		layer = SHOWER_CLOSED_LAYER
	else
		icon_state = "open"
		overlay = image("open_overlay")
		overlay.color = overlay_color
		overlay.alpha = overlay_alpha
		add_overlay(overlay)
		layer = SHOWER_OPEN_LAYER

/obj/structure/curtain/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/toy/crayon))
		color = tgui_input_color(user,"Please choose a color.", "Curtain Color")
		return ITEM_INTERACT_COMPLETE

/obj/structure/curtain/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(anchored)
		user.visible_message("<span class='warning'>[user] unscrews [src] from the floor.</span>", "<span class='notice'>You start to unscrew [src] from the floor...</span>", "You hear rustling noises.")
		if(I.use_tool(src, user, 50, volume = I.tool_volume) && anchored)
			anchored = FALSE
			to_chat(user, "<span class='notice'>You unscrew [src] from the floor.</span>")
	else
		user.visible_message("<span class='warning'>[user] screws [src] to the floor.</span>", "<span class='notice'>You start to screw [src] to the floor...</span>", "You hear rustling noises.")
		if(I.use_tool(src, user, 50, volume = I.tool_volume) && !anchored)
			anchored = TRUE
			to_chat(user, "<span class='notice'>You screw [src] to the floor.</span>")



/obj/structure/curtain/wirecutter_act(mob/user, obj/item/I)
	if(anchored)
		return
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(assembled)
		WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE
		if(I.use_tool(src,user, 5 SECONDS, volume = I.tool_volume))
			WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE
			var/obj/structure/curtain/assembly/new_assembly = new /obj/structure/curtain/assembly(loc, 1)
			new_assembly.assembled = TRUE
			var/obj/item/stack/sheet/cloth/dropped_cloth = new /obj/item/stack/sheet/cloth(loc, 2)
			qdel(src)
			return
		return

	WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
		WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE
		deconstruct()

/obj/structure/curtain/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/cloth(loc, 2)
	new /obj/item/stack/rods(loc, 1)
	qdel(src)

/obj/structure/curtain/black
	name = "black curtain"
	overlay_color = "#222222"

/obj/structure/curtain/medical
	name = "plastic curtain"
	overlay_color = "#B8F5E3"
	overlay_alpha = 200

/obj/structure/curtain/open/shower
	name = "shower curtain"
	overlay_color = "#7aa6c4"
	overlay_alpha = 200

/obj/structure/curtain/open/shower/engineering
	overlay_color = "#FFA500"

/obj/structure/curtain/open/shower/security
	overlay_color = "#AA0000"

/obj/structure/curtain/open/shower/centcom
	overlay_color = "#000066"

#undef SHOWER_OPEN_LAYER
#undef SHOWER_CLOSED_LAYER
