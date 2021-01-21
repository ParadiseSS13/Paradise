/obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."

	school = "transmutation"
	charge_max = 300
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	cooldown_min = 100 //50 deciseconds reduction per rank
	include_user = 1
	nonabstract_req = 1
	centcom_cancast = 0 //Prevent people from getting to centcom

	var/jaunt_duration = 50 //in deciseconds
	var/jaunt_in_time = 5

	///Do we do the glowy wizard thing on the tile the wizard entered / exit
	var/has_jaunt_effect = TRUE
	var/jaunt_in_type = /obj/effect/temp_visual/wizard
	var/jaunt_out_type = /obj/effect/temp_visual/wizard/out
	/// Do we show the fun blue water effect spread out thing
	var/has_smoke_jaunt_effect = TRUE

	/// Sound to play on jaunting
	var/jaunt_enter_sound = 'sound/magic/ethereal_enter.ogg'

	/// Sound to play when we start exiting jaunt
	var/jaunt_exit_sound = 'sound/magic/ethereal_exit.ogg'

	/// Do we unstun (currently shadowling)
	var/unstuns = FALSE

	/// Do we play a message when activating / deactivating the spell, in the format of "<span class='warning'>(user's name) (message to be displayed)</span>"
	var/plays_message = FALSE
	var/message_in = "Should not"
	var/message_out = "See this"

	/// Do we pop out instantly when the spell ends (not reccomended if using jaunt effects)
	var/instant_pop_out = FALSE

	action_icon_state = "jaunt"

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/cast(list/targets, mob/user = usr) //magnets, so mostly hardcoded
	playsound(get_turf(user), jaunt_enter_sound, 50, 1, -1)
	for(var/mob/living/target in targets)
		if(!target.can_safely_leave_loc()) // No more brainmobs hopping out of their brains
			to_chat(target, "<span class='warning'>You are somehow too bound to your current location to abandon it.</span>")
			continue
		INVOKE_ASYNC(src, .proc/do_jaunt, target)

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/do_jaunt(mob/living/target)
	if(plays_message)
		target.visible_message("<span class='warning'>[target] [message_in]</span>")
	target.notransform = 1
	var/turf/mobloc = get_turf(target)
	var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt(mobloc)
	if(has_jaunt_effect)
		new jaunt_out_type(mobloc, target.dir)
	target.ExtinguishMob()
	if(unstuns)
		target.SetStunned(0)
		target.SetWeakened(0)
	target.forceMove(holder)
	target.reset_perspective(holder)
	target.notransform = 0 //mob is safely inside holder now, no need for protection.
	if(has_smoke_jaunt_effect)
		jaunt_steam(mobloc)

	sleep(jaunt_duration)

	if(target.loc != holder) //mob warped out of the warp
		qdel(holder)
		return
	mobloc = get_turf(target.loc)
	if(has_smoke_jaunt_effect)
		jaunt_steam(mobloc)
	target.canmove = 0
	holder.reappearing = 1
	playsound(get_turf(target), jaunt_exit_sound, 50, 1, -1)
	if(!instant_pop_out)
		sleep(25 - jaunt_in_time)
	if(has_jaunt_effect)
		new jaunt_in_type(mobloc, holder.dir)
	target.setDir(holder.dir)
	if(!instant_pop_out)
		sleep(jaunt_in_time)
	qdel(holder)
	if(!QDELETED(target))
		if(mobloc.density)
			for(var/direction in GLOB.alldirs)
				var/turf/T = get_step(mobloc, direction)
				if(T)
					if(target.Move(T))
						break
		target.canmove = 1
		if(plays_message)
			target.visible_message("<span class='warning'>[target] [message_out]</span>")

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/jaunt_steam(mobloc)
	var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
	steam.set_up(10, 0, mobloc)
	steam.start()

/obj/effect/dummy/spell_jaunt
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/reappearing = 0
	var/movedelay = 0
	var/movespeed = 2
	density = 0
	anchored = 1
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/spell_jaunt/Destroy()
	// Eject contents if deleted somehow
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()

/obj/effect/dummy/spell_jaunt/relaymove(mob/user, direction)
	if((movedelay > world.time) || reappearing || !direction)
		return
	var/turf/newLoc = get_step(src,direction)
	setDir(direction)
	if(!(newLoc.flags & NOJAUNT))
		forceMove(newLoc)
	else
		to_chat(user, "<span class='warning'>Some strange aura is blocking the way!</span>")
	movedelay = world.time + movespeed

/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return

/obj/effect/dummy/spell_jaunt/bullet_act(blah)
	return
