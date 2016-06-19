//This should hold all the vampire related powers

/obj/effect/proc_holder/spell/vampire
	panel = "Vampire"
	school = "vampire"
	clothes_req = 0
	range = 1
	charge_max = 1800
	action_background_icon_state = "bg_vampire"
	var/required_blood = 0
	var/gain_desc = null

/obj/effect/proc_holder/spell/vampire/New()
	..()
	if(!gain_desc)
		gain_desc = "You have gained \the [src] ability."

/obj/effect/proc_holder/spell/vampire/cast_check(skipcharge = 0, mob/living/user = usr)
	if(!user.mind)
		return 0
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You are in too weak of a form to do this!</span>")
		return 0

	var/datum/vampire/vampire = user.mind.vampire

	if(!vampire)
		return 0

	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)

	if(user.stat >= DEAD)
		to_chat(user, "<span class='warning'>Not when you're dead!</span>")
		return 0

	if(vampire.nullified && !fullpower)
		to_chat(user, "<span class='warning'>Something is blocking your powers!</span>")
		return 0
	if(vampire.bloodusable < required_blood)
		to_chat(user, "<span class='warning'>You require at least [required_blood] units of usable blood to do that!</span>")
		return 0
	//chapel check
	if(istype(loc.loc, /area/chapel) && !fullpower)
		to_chat(user, "<span class='warning'>Your powers are useless on this holy ground.</span>")
		return 0
	return ..()

/obj/effect/proc_holder/spell/vampire/can_cast(mob/user = usr)
	if(!user.mind)
		return 0
	if(!ishuman(user))
		return 0

	var/datum/vampire/vampire = user.mind.vampire

	if(!vampire)
		return 0

	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)

	if(user.stat >= DEAD)
		return 0

	if(vampire.nullified && !fullpower)
		return 0
	if(vampire.bloodusable < required_blood)
		return 0
	if(istype(loc.loc, /area/chapel) && !fullpower)
		return 0
	return ..()

/obj/effect/proc_holder/spell/vampire/proc/affects(mob/target, mob/user = usr)
	//Other vampires aren't affected
	if(target.mind && target.mind.vampire)
		return 0
	//Vampires who have reached their full potential can affect nearly everything
	if(user.mind.vampire.get_ability(/datum/vampire_passive/full))
		return 1
	//Chaplains are resistant to vampire powers
	if(target.mind && target.mind.assigned_role == "Chaplain")
		return 0
	return 1

/obj/effect/proc_holder/spell/vampire/proc/can_reach(mob/M as mob)
	if(M.loc == usr.loc)
		return 1 //target and source are in the same thing
	return M in oview_or_orange(range, usr, selection_type)

/obj/effect/proc_holder/spell/vampire/before_cast(list/targets)
	// sanity check before we cast
	if(!usr.mind || !usr.mind.vampire)
		targets.Cut()
		return

	if(!required_blood)
		return

	// enforce blood
	var/datum/vampire/vampire = usr.mind.vampire

	if(required_blood <= vampire.bloodusable)
		vampire.bloodusable -= required_blood
	else
		// stop!!
		targets.Cut()

	if(targets.len)
		to_chat(usr, "<span class='notice'><b>You have [vampire.bloodusable] left to use.</b></span>")

/obj/effect/proc_holder/spell/vampire/targetted/choose_targets(mob/user = usr)
	var/list/possible_targets[0]
	for(var/mob/living/carbon/C in oview_or_orange(range, user, selection_type))
		possible_targets += C
	var/mob/living/carbon/T = input(user, "Choose your victim.", name) as null|mob in possible_targets

	if(!T || !can_reach(T))
		revert_cast(user)
		return

	perform(list(T))

/obj/effect/proc_holder/spell/vampire/self/choose_targets(mob/user = usr)
	perform(list(user))

/obj/effect/proc_holder/spell/vampire/mob_aoe/choose_targets(mob/user = usr)
	var/list/targets[0]
	for(var/mob/living/carbon/C in oview_or_orange(range, user, selection_type))
		targets += C

	if(!targets.len)
		revert_cast(user)
		return

	perform(targets)

/datum/vampire_passive
	var/gain_desc

/datum/vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You have gained \the [src] ability."

////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/vampire/self/rejuvenate
	name = "Rejuvenate"
	desc= "Flush your system with spare blood to remove any incapacitating effects."
	action_icon_state = "vampire_rejuvinate"
	charge_max = 200
	stat_allowed = 1

/obj/effect/proc_holder/spell/vampire/self/rejuvenate/cast()
	var/mob/living/U = usr

	usr.SetWeakened(0)
	usr.SetStunned(0)
	usr.SetParalysis(0)
	U.adjustStaminaLoss(-75)
	to_chat(usr, "<span class='notice'>You flush your system with clean blood and remove any incapacitating effects.</span>")
	spawn(1)
		if(usr.mind.vampire.get_ability(/datum/vampire_passive/regen))
			for(var/i = 1 to 5)
				U.adjustBruteLoss(-2)
				U.adjustOxyLoss(-5)
				U.adjustToxLoss(-2)
				U.adjustFireLoss(-2)
				sleep(35)

/obj/effect/proc_holder/spell/vampire/targetted/hypnotise
	name = "Hypnotise (20)"
	desc= "A piercing stare that incapacitates your victim for a good length of time."
	action_icon_state = "vampire_hypnotise"
	required_blood = 20

/obj/effect/proc_holder/spell/vampire/targetted/hypnotise/cast(list/targets)
	for(var/mob/living/target in targets)
		usr.visible_message("<span class='warning'>[usr]'s eyes flash briefly as he stares into [target]'s eyes</span>")
		if(do_mob(usr, target, 50))
			if(!affects(target))
				to_chat(usr, "<span class='warning'>Your piercing gaze fails to knock out [target].</span>")
				to_chat(target, "\blue [usr]'s feeble gaze is ineffective.")
			else
				to_chat(usr, "<span class='warning'>Your piercing gaze knocks out [target].</span>")
				to_chat(target, "<span class='warning'>You find yourself unable to move and barely able to speak.</span>")
				target.Weaken(10)
				target.Stun(10)
				target.stuttering = 10
		else
			revert_cast(usr)
			to_chat(usr, "<span class='warning'>You broke your gaze.</span>")

/obj/effect/proc_holder/spell/vampire/targetted/disease
	name = "Diseased Touch (100)"
	desc = "Touches your victim with infected blood giving them Grave Fever, which will, left untreated, causes toxic building and frequent collapsing."
	gain_desc = "You have gained the Diseased Touch ability which causes those you touch to become weak unless treated medically."
	action_icon_state = "vampire_disease"
	required_blood = 100

/obj/effect/proc_holder/spell/vampire/targetted/disease/cast(list/targets)
	for(var/mob/living/carbon/target in targets)
		to_chat(usr, "<span class='warning'>You stealthily infect [target] with your diseased touch.</span>")
		target.help_shake_act(usr)
		if(!affects(target))
			to_chat(usr, "<span class='warning'>They seem to be unaffected.</span>")
			continue
		var/datum/disease/D = new /datum/disease/vampire
		target.ForceContractDisease(D)

/obj/effect/proc_holder/spell/vampire/mob_aoe/glare
	name = "Glare"
	desc = "A scary glare that incapacitates people for a short while around you."
	action_icon_state = "vampire_glare"
	charge_max = 300
	stat_allowed = 1

/obj/effect/proc_holder/spell/vampire/mob_aoe/glare/cast(list/targets)
	usr.visible_message("<span class='warning'><b>[usr]'s eyes emit a blinding flash!</span>")
	if(istype(usr:glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(usr, "<span class='warning'>You're blindfolded!</span>")
		return
	for(var/mob/living/target in targets)
		if(!affects(target))
			continue
		target.Stun(5)
		target.Weaken(5)
		target.stuttering = 20
		to_chat(target, "<span class='warning'>You are blinded by [usr]'s glare.</span>")

/obj/effect/proc_holder/spell/vampire/self/shapeshift
	name = "Shapeshift (50)"
	desc = "Changes your name and appearance at the cost of 50 blood and has a cooldown of 3 minutes."
	gain_desc = "You have gained the shapeshifting ability, at the cost of stored blood you can change your form permanently."
	action_icon_state = "genetic_poly"
	required_blood = 50

/obj/effect/proc_holder/spell/vampire/self/shapeshift/cast()
	usr.visible_message("<span class='warning'>[usr] transforms!</span>")
	usr.client.prefs.real_name = usr.generate_name()
	usr.client.prefs.random_character()
	usr.client.prefs.copy_to(usr)
	usr.regenerate_icons()

/obj/effect/proc_holder/spell/vampire/self/screech
	name = "Chiroptean Screech (30)"
	desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	gain_desc = "You have gained the Chriopteran Screech ability which stuns anything with ears in a large radius and shatters glass in the process."
	action_icon_state = "vampire_screech"
	required_blood = 30

/obj/effect/proc_holder/spell/vampire/self/screech/cast()
	usr.visible_message("<span class='warning'>[usr] lets out an ear piercing shriek!</span>", "<span class='warning'>You let out a loud shriek.</span>", "<span class='warning'>You hear a loud painful shriek!</span>")
	for(var/mob/living/carbon/C in hearers(4))
		if(C == usr)
			continue
		if(ishuman(C) && (C:l_ear || C:r_ear) && istype((C:l_ear || C:r_ear), /obj/item/clothing/ears/earmuffs))
			continue
		if(!affects(C))
			continue
		to_chat(C, "<span class='warning'><font size='3'><b>You hear a ear piercing shriek and your senses dull!</font></b></span>")
		C.Weaken(4)
		C.ear_deaf = 20
		C.stuttering = 20
		C.Stun(4)
		C.Jitter(150)
	for(var/obj/structure/window/W in view(4))
		W.destroy()
	playsound(usr.loc, 'sound/effects/creepyshriek.ogg', 100, 1)


/proc/isvampirethrall(mob/living/M as mob)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.vampire_enthralled)

/obj/effect/proc_holder/spell/vampire/targetted/enthrall
	name = "Enthrall (300)"
	desc = "You use a large portion of your power to sway those loyal to none to be loyal to you only."
	gain_desc = "You have gained the Enthrall ability which at a heavy blood cost allows you to enslave a human that is not loyal to any other for a random period of time."
	action_icon_state = "vampire_enthrall"
	required_blood = 300

/obj/effect/proc_holder/spell/vampire/targetted/enthrall/cast(list/targets)
	for(var/mob/living/target in targets)
		usr.visible_message("<span class='warning'>[usr] bites [target]'s neck!</span>", "<span class='warning'>You bite [target]'s neck and begin the flow of power.</span>")
		to_chat(target, "<span class='warning'>You feel the tendrils of evil invade your mind.</span>")
		if(!ishuman(target))
			to_chat(usr, "<span class='warning'>You can only enthrall humans.</span>")
			break
		if(do_mob(usr, target, 50))
			if(can_enthrall(usr, target))
				handle_enthrall(usr, target)
			else
				revert_cast(usr)
				to_chat(usr, "<span class='warning'>You or your target either moved or you dont have enough usable blood.</span>")

/obj/effect/proc_holder/spell/vampire/targetted/enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/C)
	var/enthrall_safe = 0
	for(var/obj/item/weapon/implant/loyalty/L in C)
		if(L && L.implanted)
			enthrall_safe = 1
			break
	for(var/obj/item/weapon/implant/traitor/T in C)
		if(T && T.implanted)
			enthrall_safe = 1
			break
	if(!C)
		log_to_dd("something bad happened on enthralling a mob, attacker is [user] [user.key] \ref[user]")
		return 0
	if(!C.mind)
		to_chat(user, "<span class='warning'>[C.name]'s mind is not there for you to enthrall.</span>")
		return 0
	if(enthrall_safe || ( C.mind in ticker.mode.vampires )||( C.mind.vampire )||( C.mind in ticker.mode.vampire_enthralled ))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>You feel a familiar sensation in your skull that quickly dissipates.</span>")
		return 0
	if(!affects(C))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>Your faith of [ticker.Bible_deity_name] has kept your mind clear of all evil.</span>")
	if(!ishuman(C))
		to_chat(user, "<span class='warning'>You can only enthrall humans!</span>")
		return 0
	return 1

/obj/effect/proc_holder/spell/vampire/targetted/enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/H as mob)
	if(!istype(H))
		return 0
	var/ref = "\ref[user.mind]"
	if(!(ref in ticker.mode.vampire_thralls))
		ticker.mode.vampire_thralls[ref] = list(H.mind)
	else
		ticker.mode.vampire_thralls[ref] += H.mind

	ticker.mode.update_vampire_icons_added(H.mind)
	ticker.mode.update_vampire_icons_added(user.mind)
	var/datum/mindslaves/slaved = user.mind.som
	H.mind.som = slaved
	slaved.serv += H
	slaved.add_serv_hud(user.mind, "vampire")//handles master servent icons
	slaved.add_serv_hud(H.mind, "vampthrall")

	ticker.mode.vampire_enthralled.Add(H.mind)
	ticker.mode.vampire_enthralled[H.mind] = user.mind
	H.mind.special_role = "VampThrall"
	to_chat(H, "<span class='danger'>You have been Enthralled by [user]. Follow their every command.</span>")
	to_chat(src, "<span class='warning'>You have successfully Enthralled [H]. <i>If they refuse to do as you say just adminhelp.</i></span>")
	log_admin("[ckey(user.key)] has mind-slaved [ckey(H.key)].")

/obj/effect/proc_holder/spell/vampire/self/cloak
	name = "Cloak of Darkness"
	desc = "Toggles whether you are currently cloaking yourself in darkness."
	gain_desc = "You have gained the Cloak of Darkness ability which when toggled makes you near invisible in the shroud of darkness."
	action_icon_state = "vampire_cloak"
	charge_max = 10

/obj/effect/proc_holder/spell/vampire/self/cloak/New()
	..()
	update_name()

/obj/effect/proc_holder/spell/vampire/self/cloak/proc/update_name()
	var/mob/living/user = loc
	if(!ishuman(user) || !user.mind || !user.mind.vampire)
		return
	name = "[initial(name)] ([user.mind.vampire.iscloaking ? "Deactivate" : "Activate"])"

/obj/effect/proc_holder/spell/vampire/self/cloak/cast()
	var/datum/vampire/V = usr.mind.vampire
	V.iscloaking = !V.iscloaking
	update_name()
	to_chat(usr, "<span class='notice'>You will now be [V.iscloaking ? "hidden" : "seen"] in darkness.</span>")

/obj/effect/proc_holder/spell/vampire/bats
	name = "Summon Bats (75)"
	desc = "You summon a pair of space bats who attack nearby targets until they or their target is dead."
	gain_desc = "You have gained the Summon Bats ability."
	action_icon_state = "vampire_bats"
	charge_max = 1200
	required_blood = 75
	var/num_bats = 2

/obj/effect/proc_holder/spell/vampire/bats/choose_targets(mob/user = usr)
	var/list/turf/locs = new
	for(var/direction in alldirs) //looking for bat spawns
		if(locs.len == num_bats) //we found 2 locations and thats all we need
			break
		var/turf/T = get_step(usr, direction) //getting a loc in that direction
		if(AStar(user, T, /turf/proc/Distance, 1, simulated_only = 0)) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	// pad with player location
	for(var/i = locs.len + 1 to num_bats)
		locs += user.loc

	perform(locs)

/obj/effect/proc_holder/spell/vampire/bats/cast(list/targets)
	for(var/T in targets)
		new /mob/living/simple_animal/hostile/scarybat(T, usr)

/obj/effect/proc_holder/spell/vampire/self/jaunt
	name = "Mist Form (30)"
	desc = "You take on the form of mist for a short period of time."
	gain_desc = "You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path."
	action_icon_state = "jaunt"
	charge_max = 600
	required_blood = 30
	var/jaunt_duration = 50 //in deciseconds

/obj/effect/proc_holder/spell/vampire/self/jaunt/cast()
	if(usr.buckled)
		usr.buckled.unbuckle_mob()
	spawn(0)
		var/mob/living/U = usr
		var/originalloc = get_turf(usr.loc)
		var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt(originalloc)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(originalloc)
		animation.name = "water"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "liquify"
		animation.layer = 5
		animation.master = holder
		U.ExtinguishMob()
		if(usr.buckled)
			usr.buckled.unbuckle_mob()
		flick("liquify", animation)
		usr.forceMove(holder)
		usr.client.eye = holder
		var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread()
		steam.set_up(10, 0, originalloc)
		steam.start()
		sleep(jaunt_duration)
		var/mobloc = get_turf(usr.loc)
		if(get_area(mobloc) == /area/security/armoury/gamma)
			to_chat(usr, "A strange energy repels you!")
			mobloc = originalloc
		animation.loc = mobloc
		steam.location = mobloc
		steam.start()
		usr.canmove = 0
		sleep(20)
		flick("reappear",animation)
		sleep(5)
		if(!usr.Move(mobloc))
			for(var/direction in list(1,2,4,8,5,6,9,10))
				var/turf/T = get_step(mobloc, direction)
				if(T)
					if(usr.Move(T))
						break
		usr.canmove = 1
		usr.client.eye = usr
		qdel(animation)
		qdel(holder)

// Blink for vamps
// Less smoke spam.
/obj/effect/proc_holder/spell/vampire/shadowstep
	name = "Shadowstep (30)"
	desc = "Vanish into the shadows."
	gain_desc = "You have gained the ability to shadowstep, which makes you disappear into nearby shadows at the cost of blood."
	action_icon_state = "blink"
	charge_max = 20
	required_blood = 30

	// Teleport radii
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6
	// Maximum lighting_lumcount.
	var/max_lum = 1

/obj/effect/proc_holder/spell/vampire/shadowstep/choose_targets(mob/user = usr)
	var/list/turfs = new/list()
	for(var/turf/T in range(user, outer_tele_radius))
		if(T in range(user, inner_tele_radius))
			continue
		if(istype(T, /turf/space))
			continue
		if(T.density)
			continue
		if(T.x > world.maxx-outer_tele_radius || T.x < outer_tele_radius)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy-outer_tele_radius || T.y < outer_tele_radius)
			continue

		var/atom/movable/lighting_overlay/L = locate(/atom/movable/lighting_overlay) in T
		var/lightingcount = L.get_clamped_lum(0.5) * 10

		// LIGHTING CHECK
		if(lightingcount > max_lum)
			continue
		turfs += T

	if(!turfs.len)
		revert_cast(user)
		to_chat(user, "\red You cannot find darkness to step to.")
		return

	perform(turfs)

/obj/effect/proc_holder/spell/vampire/shadowstep/cast(list/targets)
	if(usr.buckled)
		usr.buckled.unbuckle_mob()
	spawn(0)
		var/turf/picked = pick(targets)

		if(!picked || !isturf(picked))
			return
		var/mob/living/U = usr
		U.ExtinguishMob()
		if(usr.buckled)
			usr.buckled.unbuckle_mob()
		var/atom/movable/overlay/animation = new /atom/movable/overlay(get_turf(usr))
		animation.name = usr.name
		animation.density = 0
		animation.anchored = 1
		animation.icon = usr.icon
		animation.alpha = 127
		animation.layer = 5
		//animation.master = src
		usr.forceMove(picked)
		spawn(10)
			qdel(animation)

/datum/vampire_passive/regen
	gain_desc = "Your rejuvination abilities have improved and will now heal you over time when used."

/datum/vampire_passive/vision
	gain_desc = "Your vampiric vision has improved."

/datum/vampire_passive/full
	gain_desc = "You have reached your full potential and are no longer weak to the effects of anything holy and your vision has been improved greatly."
