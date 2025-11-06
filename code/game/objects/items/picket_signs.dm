/obj/item/picket_sign
	name = "blank picket sign"
	desc = "It's blank."
	icon_state = "picket"
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed","smacked")
	resistance_flags = FLAMMABLE

	new_attack_chain = TRUE

	/// The cooldown tracking when we can next wave the sign
	COOLDOWN_DECLARE(wave_cooldown)
	/// What does the sign say?
	var/label = ""

/obj/item/picket_sign/attack_by(obj/item/attacking, mob/user, params)
	if(is_pen(attacking) || istype(attacking, /obj/item/toy/crayon))
		var/txt = tgui_input_text(user, "What would you like to write on the sign?", "Sign Label", max_length = 30)
		if(isnull(txt))
			return
		label = txt
		src.name = "[label] sign"
		desc =	"It reads: [label]"
	..()

/obj/item/picket_sign/activate_self(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		user.show_message("<span class='warning'>Your arm is too tired to do that again so soon!</span>")
		return

	if(label)
		user.visible_message("<span class='notice'>[user] waves around \the \"[label]\" sign.</span>")
	else
		user.visible_message("<span class='notice'>[user] waves around blank sign.</span>")
	user.changeNext_move(CLICK_CD_MELEE)
	COOLDOWN_START(src, wave_cooldown, 8 SECONDS)

/obj/item/picket_sign/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(user.a_intent != INTENT_HELP)
		return
	if(!isturf(target))
		return
	var/turf/target_turf = target
	if(target_turf == get_turf(user))
		to_chat(user, "<span class='notice'>You cannot place [src] under yourself.</span>")
		return
	if(locate(/obj/structure/custom_sign) in target_turf) // No putting signs on signs
		to_chat(user, "<span class='notice'>There's already a sign there!</span>")
		return
	user.visible_message("<span class='notice'>[user] starts to attach [src] to [target].</span>", "<span class='notice'>You start to attach [src] to [target].</span>")
	if(do_after(user, 2 SECONDS, target = target_turf))
		if(iswallturf(target))
			new /obj/structure/custom_sign/wall_sign(user.loc, label, get_dir(user, target_turf))
		else
			new /obj/structure/custom_sign(target_turf, label)
		qdel(src)

/obj/structure/custom_sign
	name = "floor sign"
	anchored = TRUE
	max_integrity = 50
	icon_state = "floor_sign"
	/// What does the sign say?
	var/label = ""

/obj/structure/custom_sign/New(turf/loc, new_label)
	. = ..()
	if(new_label)
		change_label(new_label)

/obj/structure/custom_sign/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(is_pen(used) || istype(used, /obj/item/toy/crayon))
		var/txt = tgui_input_text(user, "What would you like to write on the sign?", "Sign Label", max_length = 30)
		if(isnull(txt))
			return ITEM_INTERACT_COMPLETE
		change_label(txt)
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE
	..()

/obj/structure/custom_sign/proc/change_label(new_label)
	label = new_label
	name = "[new_label] sign"
	desc =	"It reads: [new_label]"

/obj/structure/custom_sign/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message("<span class='notice'>[user] starts to detach [src].</span>", "<span class='notice'>You start to detach [src].</span>")
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return
	var/obj/item/picket_sign/picket = new /obj/item/picket_sign(loc)
	if(label)
		picket.label = label
		picket.name = "[label] sign"
		picket.desc =	"It reads: [label]"
	qdel(src)

/obj/structure/custom_sign/wall_sign
	name = "wall sign"
	icon_state = "wall_sign"

/obj/structure/custom_sign/wall_sign/New(turf/loc, new_label, direction)
	. = ..()
	// Offset 24 pixels in direction of dir. This allows the sign to be embedded in a wall
	setDir(direction)
	set_pixel_offsets_from_dir(24, -24, 24, -24)
	update_icon()

/datum/crafting_recipe/picket_sign
	name = "Picket Sign"
	result = list(/obj/item/picket_sign)
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cardboard = 2)
	time = 80
	category = CAT_MISC
