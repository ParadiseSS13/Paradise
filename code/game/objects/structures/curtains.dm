#define SHOWER_OPEN_LAYER OBJ_LAYER + 0.4
#define SHOWER_CLOSED_LAYER MOB_LAYER + 0.1

/obj/structure/curtain
	icon = 'icons/obj/curtain.dmi'
	name = "curtain"
	icon_state = "curtain_rod"
	face_while_pulling = FALSE
	layer = SHOWER_CLOSED_LAYER
	opacity = TRUE
	var/assembled = TRUE
	var/overlay_color = "#ffffff"
	var/overlay_alpha = 255

/obj/structure/curtain/Initialize(mapload, assembled_ = TRUE)
	. = ..()
	assembled = assembled_
	update_appearance()

/obj/structure/curtain/open
	opacity = FALSE

/obj/item/mounted/curtain/curtain_fixture
	icon_state = "handheld"
	icon = 'icons/obj/curtain.dmi'
	name = "curtain rod assembly"

/obj/item/mounted/curtain/curtain_fixture/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(!istype(target, /obj/structure/window) && !istype(target, /turf/simulated/wall))
		return
	var/on_wall = get_turf(target)
	to_chat(user, "<span class='notice'>You begin attaching [src] to [on_wall].</span>")
	playsound(get_turf(src), 'sound/machines/click.ogg', 75, TRUE)
	if(!do_after(user, 3 SECONDS, target = on_wall))
		return
	var/obj/structure/curtain/curtain = new(on_wall, FALSE)
	curtain.fingerprints = src.fingerprints
	curtain.fingerprintshidden = src.fingerprintshidden
	curtain.fingerprintslast = src.fingerprintslast

	user.visible_message("<span class='notice'>[user] attaches the [src] to [on_wall].</span>", \
		"<span class='notice'>You attach the [src] to [on_wall].</span>")
	qdel(src)

/obj/item/mounted/curtain/curtain_fixture/activate_self(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You begin attaching [src] to the ceiling.</span>")
	playsound(get_turf(src), 'sound/machines/click.ogg', 75, TRUE)
	if(!do_after(user, 3 SECONDS, target = get_turf(user)))
		return
	var/obj/structure/curtain/curtain = new(get_turf(user), FALSE)
	curtain.fingerprints = src.fingerprints
	curtain.fingerprintshidden = src.fingerprintshidden
	curtain.fingerprintslast = src.fingerprintslast

	user.visible_message("<span class='notice'>[user] attaches the [src] to the ceiling.</span>", \
		"<span class='notice'>You attach the [src] to the ceiling.</span>")
	qdel(src)

/obj/structure/curtain/examine(mob/user)
	. = ..()

	if(!assembled)
		. += "<span class='notice'>Alt-Click to take it down.</span>"

/obj/structure/curtain/AltClick(mob/user)
	if(assembled)
		return

	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	var/obj/item/mounted/curtain/curtain_fixture/fixture = new /obj/item/mounted/curtain/curtain_fixture(get_turf(user))
	user.put_in_hands(fixture)
	playsound(loc, 'sound/effects/salute.ogg', 75, TRUE)
	qdel(src)

/obj/structure/curtain/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(assembled && istype(used, /obj/item/toy/crayon))
		color = tgui_input_color(user,"Please choose a color.", "Curtain Color")
		return ITEM_INTERACT_COMPLETE

	if(!assembled && istype(used, /obj/item/stack/sheet/cloth)) // Are we putting the cloth onto the assembly on the wall?
		var/obj/item/stack/sheet/cloth/cloth_used = used
		if(!cloth_used.use(2))
			to_chat(user, "<span class='warning'> You need two sheets of cloth to hang the curtains.</span>")
			return ITEM_INTERACT_COMPLETE

		assembled = TRUE
		update_appearance()
		playsound(loc, used.drop_sound, 75, TRUE) // Play a generic cloth sound.

		return ITEM_INTERACT_COMPLETE

/obj/structure/curtain/attack_hand(mob/user)
	. = ..()
	toggle_curtain()

/obj/structure/curtain/attack_robot(mob/living/user)
	. = ..()
	if(Adjacent(user))
		toggle_curtain()

/obj/structure/curtain/proc/toggle_curtain()
	if(assembled)
		playsound(get_turf(loc), "rustle", 15, TRUE, -5)
		set_opacity(!opacity)
		update_appearance()

/obj/structure/curtain/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/curtain/update_name(updates)
	. = ..()
	name = assembled ? "curtain" : "curtain rod"

/obj/structure/curtain/update_desc()
	. = ..()
	if(assembled)
		desc = "A curtain."
	else
		desc = "A curtain assembly! It still lacks drapes however, some cloth would serve as some nicely."

/obj/structure/curtain/update_overlays()
	. = ..()
	if(!assembled)
		set_opacity(FALSE)
		return

	if(opacity)
		var/image/overlay = image("closed_overlay")
		overlay.color = overlay_color
		overlay.alpha = overlay_alpha
		. += overlay
		layer = SHOWER_CLOSED_LAYER
	else
		var/image/overlay = image("open_overlay")
		overlay.color = overlay_color
		overlay.alpha = overlay_alpha
		. += overlay
		layer = SHOWER_OPEN_LAYER

/obj/structure/curtain/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!assembled)
		to_chat(user, "<span class='notice'>You should probably add some drapes to [src] before anchoring it in place...</span>")
		return
	if(!I.tool_start_check(src, user, 0))
		return
	if(anchored)
		user.visible_message("<span class='notice'>[user] unscrews [src] from the floor.</span>", "<span class='notice'>You start to unscrew [src] from the floor...</span>", "You hear rustling noises.")
		if(I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume) && anchored)
			anchored = FALSE
			to_chat(user, "<span class='notice'>You unscrew [src] from the floor.</span>")
	else
		user.visible_message("<span class='notice'>[user] screws [src] to the floor.</span>", "<span class='notice'>You start to screw [src] to the floor...</span>", "You hear rustling noises.")
		if(I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume) && !anchored)
			anchored = TRUE
			to_chat(user, "<span class='notice'>You screw [src] to the floor.</span>")

/obj/structure/curtain/wirecutter_act(mob/user, obj/item/I)
	if(anchored)
		to_chat(user, "<span class='warning'>You will need to undo the <b>screws</b> anchoring [src] before removing the drapes.</span>")
		return TRUE
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(assembled)
		WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE
		if(I.use_tool(src,user, 5 SECONDS, volume = I.tool_volume))
			WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE
			assembled = FALSE
			update_appearance()
			new /obj/item/stack/sheet/cloth(loc, 2)
			return
		return

/obj/structure/curtain/deconstruct(disassembled = TRUE)
	if(assembled)
		new /obj/item/stack/sheet/cloth(loc, 2)
	new /obj/item/stack/rods(loc, 2)
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
