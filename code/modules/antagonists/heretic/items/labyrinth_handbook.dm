/obj/effect/forcefield/wizard/heretic
	name = "labyrinth pages"
	desc = "A field of papers flying in the air, repulsing heathens with impossible force."
	icon_state = "lintel"
	lifetime = 10 SECONDS

/obj/effect/forcefield/wizard/heretic/Bumped(mob/living/bumpee)
	. = ..()
	if(!istype(bumpee) || IS_HERETIC_OR_MONSTER(bumpee))
		return
	var/throwtarget = get_edge_target_turf(loc, get_dir(loc, get_step_away(bumpee, loc)))
	bumpee.throw_at(throwtarget, 10, 1)
	visible_message("<span class='danger'>[src] repulses [bumpee] in a storm of paper!</span>")

///A heretic item that spawns a barrier at the clicked turf, 3 uses
/obj/item/heretic_labyrinth_handbook
	name = "labyrinth handbook"
	desc = "A book containing the laws and regulations of the Locked Labyrinth, penned on an unknown substance. Its pages squirm and strain, looking to lash out and escape."
	icon = 'icons/obj/library.dmi'
	icon_state = "heretichandbook"
	force = 10
	damtype = BURN
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashes", "curses")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	new_attack_chain = TRUE
	///what type of barrier do we spawn when used
	var/barrier_type = /obj/effect/forcefield/wizard/heretic
	///how many uses do we have left
	var/uses = 3

/obj/item/heretic_labyrinth_handbook/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return
	. += "<span class='hierophant_warning'>Materializes a barrier upon any tile in sight, which only you can pass through. Lasts 8 seconds.</span>"
	. += "<span class='hierophant_warning'>It has <b>[uses]</b> uses left.</span>"

/obj/item/heretic_labyrinth_handbook/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!IS_HERETIC(user))
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			to_chat(human_user, "<span class='userdanger'>Your mind burns as you stare deep into the book, a headache setting in like your brain is on fire!</span>")
			human_user.adjustBrainLoss(30)
			human_user.drop_item()
		return ITEM_INTERACT_COMPLETE

	var/turf/turf_target = get_turf(target)
	if(locate(barrier_type) in turf_target)
		to_chat(user, "<span class='warning'>This turf already has a barrier!</span>")
		return ITEM_INTERACT_COMPLETE
	turf_target.visible_message("<span class='warning'>A storm of paper materializes!</span>")
	new /obj/effect/temp_visual/paper_scatter(turf_target)
	playsound(turf_target, 'sound/magic/smoke.ogg', 30)
	new barrier_type(turf_target, user)
	uses--
	if(uses <= 0)
		to_chat(user, "<span class='warning'>[src] falls apart, turning into ash and dust!</span>")
		qdel(src)
	return ITEM_INTERACT_COMPLETE


//fancy effects
/obj/effect/temp_visual/paper_scatter
	name = "scattering paper"
	desc = "Pieces of paper scattering to the wind."
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "paper_scatter"
	anchored = TRUE
	duration = 0.5 SECONDS
	randomdir = FALSE
