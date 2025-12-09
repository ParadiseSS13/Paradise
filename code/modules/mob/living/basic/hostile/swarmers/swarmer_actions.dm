/datum/action/cooldown/mob_cooldown/swarmer_trap
	name = "Construct Shock Trap"
	button_icon = 'icons/mob/swarmer.dmi'
	button_icon_state = "ui_trap"
	desc = "Construct a shock trap, using 25 resources."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 60 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/swarmer_trap/Activate(atom/target)
	var/mob/living/basic/swarmer/user = target
	if(!istype(user))
		to_chat(target, "<span class='warning'>Incompatible hardware detected. Aborting.</span>")
		return
	var/turf/T = get_turf(user)
	for(var/turf/turf_in_view in view(1, T))
		if(locate(/obj/structure/swarmer) in turf_in_view)
			to_chat(user, "<span class='warning'>Location too close to existing hardware. Aborting.</span>")
			return
	if(user.resources < 25)
		to_chat(user, "<span class='warning'>Insufficient resources. Aborting.</span>")
		return
	user.resources -= 25
	user.visible_message("<span class='warning'>[user] manufactures a sparking pylon.</span>")
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, TRUE)
	new /obj/structure/swarmer/trap(T)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/swarmer_barrier
	name = "Construct Barricade"
	button_icon = 'icons/mob/swarmer.dmi'
	button_icon_state = "ui_barricade"
	desc = "Construct a barricade, using 25 resources."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 75 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/swarmer_barrier/Activate(atom/target)
	var/mob/living/basic/swarmer/user = target
	if(!istype(user))
		to_chat(target, "<span class='warning'>Incompatible hardware detected. Aborting.</span>")
		return
	if(user.resources < 25)
		to_chat(user, "<span class='warning'>Insufficient resources. Aborting.</span>")
		return
	var/turf/T = get_turf(user)
	for(var/turf/turf_in_view in view(1, T))
		if(locate(/obj/structure/swarmer) in turf_in_view)
			to_chat(user, "<span class='warning'>Location too close to existing hardware. Aborting.</span>")
			return
	if(!do_after_once(user, 2 SECONDS, target = T, attempt_cancel_message = "You stop building a barricade.", interaction_key = "swarmer_barricade_create"))
		return
	// Check again to make sure they still have the requirements
	if(user.resources < 25)
		to_chat(user, "<span class='warning'>Insufficient resources. Aborting.</span>")
		return
	T = get_turf(user)
	for(var/turf/turf_in_view in view(1, T))
		if(locate(/obj/structure/swarmer) in turf_in_view)
			to_chat(user, "<span class='warning'>Location too close to existing hardware. Aborting.</span>")
			return
	user.resources -= 25
	user.visible_message("<span class='warning'>[user] manufactures a holographic shield.</span>")
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, TRUE)
	new /obj/structure/swarmer/barricade(T)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/swarmer_replicate
	name = "Replicate"
	button_icon = 'icons/mob/swarmer.dmi'
	button_icon_state = "ui_replicate"
	desc = "Construct a new swarmer, using 50 resources."
	click_to_activate = FALSE
	cooldown_time = 20 SECONDS
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/swarmer_replicate/Activate(atom/target)
	var/mob/living/basic/swarmer/user = target
	if(!istype(user))
		to_chat(target, "<span class='warning'>Incompatible hardware detected. Aborting.</span>")
		return
	if(user.resources < 50)
		to_chat(user, "<span class='warning'>Insufficient resources. Aborting.</span>")
		return
	if(!do_after_once(user, 4 SECONDS, target = user, attempt_cancel_message = "You stop building a new swarmer.", interaction_key = "swarmer_replicate_create"))
		return
	// Check again after the do-after.
	if(user.resources < 50)
		to_chat(user, "<span class='warning'>Insufficient resources. Aborting.</span>")
		return
	var/turf/T = get_turf(user)
	user.resources -= 50
	user.visible_message("<span class='warning'>[user] manufactures a new swarmer.</span>")
	playsound(get_turf(user), 'sound/items/rped.ogg', 50, TRUE)
	new /mob/living/basic/swarmer/lesser(T)
	StartCooldown()
