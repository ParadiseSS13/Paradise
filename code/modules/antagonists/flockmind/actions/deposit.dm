/datum/action/cooldown/flock/deposit
	name = "Deposit"
	click_to_activate = TRUE
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/flock/deposit/is_valid_target(atom/cast_on)
	return istype(cast_on, /obj/structure/flock/tealprint)

/datum/action/cooldown/flock/deposit/Activate(atom/target)
	. = ..()
	var/mob/living/basic/flock/bird = owner
	astype(bird, /mob/living/basic/flock/drone)?.stop_flockphase(TRUE)
	bird.face_atom(target)

	playsound(target, 'sound/goonstation/flockmind/flockdrone_quickbuild.ogg', 50, TRUE)

	while(do_after(bird, 1 SECONDS, target =  target, interaction_key = "flock_deposit"))
		bird.visible_message(SPAN_NOTICE("[bird] deposits materials into [target]."), blind_message = SPAN_HEAR("You hear an otherwordly whirring."))

		var/obj/structure/flock/tealprint/tealprint = target
		var/deposit = min(bird.substrate.has_points(), tealprint.substrate.how_empty(), FLOCK_SUBSTRATE_COST_DEPOST_TEALPRINT)
		bird.substrate.remove_points(deposit)
		tealprint.substrate.add_points(deposit)
	return TRUE

