#define EMPOWERED_THRALL_LIMIT 5

/obj/effect/proc_holder/spell/proc/shadowling_check(var/mob/living/carbon/human/H)
	if(!H || !istype(H))
		return
	if(H.incorporeal_move == 1)
		to_chat(H, "<span class='warning'>You can't use abilities affecting others while you are traversing between worlds!</span>")
		return FALSE
	if(isshadowling(H) && is_shadow(H))
		return 1
	if(isshadowlinglesser(H) && is_thrall(H))
		return 1
	if(!is_shadow_or_thrall(H))
		to_chat(H, "<span class='warning'>You can't wrap your head around how to do this.</span>")
	else if(is_thrall(H))
		to_chat(H, "<span class='warning'>You aren't powerful enough to do this.</span>")
	else if(is_shadow(H))
		to_chat(H, "<span class='warning'>Your telepathic ability is suppressed. Hatch or use Rapid Re-Hatch first.</span>")
	return 0


/obj/effect/proc_holder/spell/targeted/click/glare //Stuns and mutes a human target, depending on the distance relative to the shadowling
	name = "Glare"
	desc = "Stuns and mutes a target for a decent duration. Duration depends on the proximity to the target."
	panel = "Shadowling Abilities"
	charge_max = 300
	clothes_req = FALSE
	range = 10	//has no effect beyond this range, so setting this makes invalid/useless targets not show up in popup
	action_icon_state = "glare"

	selection_activated_message		= "<span class='notice'>Your prepare to your eyes for a stunning glare! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your eyes relax... for now.</span>"
	allowed_type = /mob/living/carbon/human

/obj/effect/proc_holder/spell/targeted/click/glare/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/living/user = usr)
	if(!shadowling_check(user))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/targeted/click/glare/valid_target(mob/living/carbon/human/target, user)
	if(!..())
		return FALSE
	return !target.stat && !is_shadow_or_thrall(target)

/obj/effect/proc_holder/spell/targeted/click/glare/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = targets[1]

	user.visible_message("<span class='warning'><b>[user]'s eyes flash a blinding red!</b></span>")
	var/distance = get_dist(H, user)
	if (distance <= 1) //Melee glare
		H.visible_message("<span class='danger'>[H] freezes in place, [H.p_their()] eyes glazing over...</span>", \
			"<span class='userdanger'>Your gaze is forcibly drawn into [user]'s eyes, and you are mesmerized by [user.p_their()] heavenly beauty...</span>")
		H.Stun(10)
		H.AdjustSilence(10)
	else //Distant glare
		var/loss = 10 - distance
		var/duration = 10 - loss
		if(loss <= 0)
			to_chat(user, "<span class='danger'>Your glare had no effect over a such long distance!</span>")
			return
		H.slowed = duration
		H.AdjustSilence(10)
		to_chat(H, "<span class='userdanger'>A red light flashes across your vision, and your mind tries to resist them.. you are exhausted.. you are not able to speak..</span>")
		addtimer(CALLBACK(src, .proc/do_stun, H, user, loss), duration SECONDS)

/obj/effect/proc_holder/spell/targeted/click/glare/proc/do_stun(mob/living/carbon/human/target, user, stun_time)
	if(!istype(target) || target.stat)
		return
	target.Stun(stun_time)
	target.visible_message("<span class='danger'>[target] freezes in place, [target.p_their()] eyes glazing over...</span>",\
		"<span class='userdanger'>Red lights suddenly dance in your vision, and you are mesmerized by the heavenly lights...</span>")

/obj/effect/proc_holder/spell/aoe_turf/veil
	name = "Veil"
	desc = "Extinguishes most nearby light sources."
	panel = "Shadowling Abilities"
	charge_max = 150 //Short cooldown because people can just turn the lights back on
	clothes_req = 0
	range = 5
	var/blacklisted_lights = list(/obj/item/flashlight/flare, /obj/item/flashlight/slime)
	action_icon_state = "veil"

/obj/effect/proc_holder/spell/aoe_turf/veil/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		charge_counter = charge_max
		return
	to_chat(user, "<span class='shadowling'>You silently disable all nearby lights.</span>")
	for(var/obj/structure/glowshroom/G in orange(2, user)) //Why the fuck was this in the loop below?
		G.visible_message("<span class='warning'>[G] withers away!</span>")
		qdel(G)
	for(var/turf/T in targets)
		T.extinguish_light()
		for(var/atom/A in T.contents)
			A.extinguish_light()

/obj/effect/proc_holder/spell/targeted/shadow_walk
	name = "Shadow Walk"
	desc = "Phases you into the space between worlds for a short time, allowing movement through walls and invisbility."
	panel = "Shadowling Abilities"
	charge_max = 300 //Used to be twice this, buffed
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/targeted/shadow_walk/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		charge_counter = charge_max
		return
	for(var/mob/living/target in targets)
		playsound(user.loc, 'sound/effects/bamf.ogg', 50, 1)
		target.visible_message("<span class='warning'>[target] vanishes in a puff of black mist!</span>", "<span class='shadowling'>You enter the space between worlds as a passageway.</span>")
		target.SetStunned(0)
		target.SetWeakened(0)
		target.incorporeal_move = 1
		target.alpha = 0
		target.ExtinguishMob()
		var/turf/T = get_turf(target)
		target.forceMove(T) //to properly move the mob out of a potential container
		if(target.pulledby)
			target.pulledby.stop_pulling()
		target.stop_pulling()
		sleep(40) //4 seconds
		target.visible_message("<span class='warning'>[target] suddenly manifests!</span>", "<span class='shadowling'>The pressure becomes too much and you vacate the interdimensional darkness.</span>")
		target.incorporeal_move = 0
		target.alpha = 255
		target.forceMove(user.loc)

/obj/effect/proc_holder/spell/targeted/lesser_shadow_walk
	name = "Guise"
	desc = "Wraps your form in shadows, making you harder to see."
	panel = "Thrall Abilities"
	charge_max = 1200
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/targeted/lesser_shadow_walk/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		target.visible_message("<span class='warning'>[target] suddenly fades away!</span>", "<span class='shadowling'>You veil yourself in darkness, making you harder to see.</span>")
		target.alpha = 10
		sleep(40)
		target.visible_message("<span class='warning'>[target] appears from nowhere!</span>", "<span class='shadowling'>Your shadowy guise slips away.</span>")
		target.alpha = initial(target.alpha)


/obj/effect/proc_holder/spell/targeted/shadow_vision
	name = "Shadowling Darksight"
	desc = "Gives you night and thermal vision."
	panel = "Shadowling Abilities"
	charge_max = 0
	range = -1
	include_user = 1
	clothes_req = 0
	action_icon_state = "darksight"

/obj/effect/proc_holder/spell/targeted/shadow_vision/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(!istype(target) || !ishuman(target))
			return
		var/mob/living/carbon/human/H = target
		if(!H.vision_type)
			to_chat(H, "<span class='notice'>You shift the nerves in your eyes, allowing you to see in the dark.</span>")
			H.set_sight(/datum/vision_override/nightvision)
		else
			to_chat(H, "<span class='notice'>You return your vision to normal.</span>")
			H.set_sight(null)

/obj/effect/proc_holder/spell/targeted/shadow_vision/thrall
	desc = "Thrall Darksight"
	desc = "Gives you night vision."
	panel = "Thrall Abilities"

/obj/effect/proc_holder/spell/aoe_turf/flashfreeze
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage."
	panel = "Shadowling Abilities"
	range = 5
	charge_max = 250
	clothes_req = 0
	action_icon_state = "icy_veins"

/obj/effect/proc_holder/spell/aoe_turf/flashfreeze/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		charge_counter = charge_max
		return
	to_chat(user, "<span class='shadowling'>You freeze the nearby air.</span>")
	playsound(user.loc, 'sound/effects/ghost2.ogg', 50, 1)

	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
			if(is_shadow_or_thrall(M))
				if(M == user) //No message for the user, of course
					continue
				else
					to_chat(M, "<span class='danger'>You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!</span>")
					continue
			to_chat(M, "<span class='userdanger'>A wave of shockingly cold air engulfs you!</span>")
			M.Stun(2)
			M.apply_damage(10, BURN)
			if(M.bodytemperature)
				M.bodytemperature -= 200 //Extreme amount of initial cold
			if(M.reagents)
				M.reagents.add_reagent("frostoil", 15) //Half of a cryosting


/obj/effect/proc_holder/spell/targeted/click/enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Enthrall"
	desc = "Allows you to enslave a conscious, non-braindead, non-catatonic human to your will. This takes some time to cast."
	panel = "Shadowling Abilities"
	charge_max = 0
	clothes_req = FALSE
	range = 1 //Adjacent to user
	var/enthralling = FALSE
	action_icon_state = "enthrall"

	click_radius = -1 // Precision baby
	selection_activated_message		= "<span class='notice'>Your prepare your mind to entrall a mortal. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	allowed_type = /mob/living/carbon/human

/obj/effect/proc_holder/spell/targeted/click/enthrall/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(enthralling || !shadowling_check(user))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/targeted/click/enthrall/valid_target(mob/living/carbon/human/target, user)
	if(!..())
		return FALSE
	return target.key && target.mind && !target.stat && !is_shadow_or_thrall(target) && target.client

/obj/effect/proc_holder/spell/targeted/click/enthrall/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/ling = user
	listclearnulls(SSticker.mode.shadowling_thralls)
	if(!(ling.mind in SSticker.mode.shadows))
		return
	var/mob/living/carbon/human/target = targets[1]
	if(ismindshielded(target))
		to_chat(user, "<span class='danger'>This target has a mindshield, blocking your powers! You cannot thrall it!</span>")
		return
	enthralling = TRUE
	to_chat(user, "<span class='danger'>This target is valid. You begin the enthralling.</span>")
	to_chat(target, "<span class='userdanger'>[user] stares at you. You feel your head begin to pulse.</span>")

	for(var/progress = 0, progress <= 3, progress++)
		switch(progress)
			if(1)
				to_chat(user, "<span class='notice'>You place your hands to [target]'s head...</span>")
				user.visible_message("<span class='warning'>[user] places [user.p_their()] hands onto the sides of [target]'s head!</span>")
			if(2)
				to_chat(user, "<span class='notice'>You begin preparing [target]'s mind as a blank slate...</span>")
				user.visible_message("<span class='warning'>[user]'s palms flare a bright red against [target]'s temples!</span>")
				to_chat(target, "<span class='danger'>A terrible red light floods your mind. You collapse as conscious thought is wiped away.</span>")
				target.Weaken(12)
			if(3)
				to_chat(user, "<span class='notice'>You begin planting the tumor that will control the new thrall...</span>")
				user.visible_message("<span class='warning'>A strange energy passes from [user]'s hands into [target]'s head!</span>")
				to_chat(target, "<span class='boldannounce'>You feel your memories twisting, morphing. A sense of horror dominates your mind.</span>")
		if(!do_mob(user, target, 7.7 SECONDS)) //around 23 seconds total for enthralling
			to_chat(user, "<span class='warning'>The enthralling has been interrupted - your target's mind returns to its previous state.</span>")
			to_chat(target, "<span class='userdanger'>You wrest yourself away from [user]'s hands and compose yourself</span>")
			enthralling = FALSE
			return

	enthralling = FALSE
	to_chat(user, "<span class='shadowling'>You have enthralled <b>[target]</b>!</span>")
	target.visible_message("<span class='big'>[target] looks to have experienced a revelation!</span>", \
							"<span class='warning'>False faces all d<b>ark not real not real not--</b></span>")
	target.setOxyLoss(0) //In case the shadowling was choking them out
	SSticker.mode.add_thrall(target.mind)
	target.mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL

/obj/effect/proc_holder/spell/targeted/shadowling_regenarmor //Resets a shadowling's species to normal, removes genetic defects, and re-equips their armor
	name = "Rapid Re-Hatch"
	desc = "Re-forms protective chitin that may be lost during cloning or similar processes."
	panel = "Shadowling Abilities"
	charge_max = 600
	range = -1
	include_user = 1
	clothes_req = 0
	action_icon_state = "regen_armor"

/obj/effect/proc_holder/spell/targeted/shadowling_regenarmor/cast(list/targets, mob/user = usr)
	if(!is_shadow(user))
		to_chat(user, "<span class='warning'>You must be a shadowling to do this!</span>")
		charge_counter = charge_max
		return
	for(var/mob/living/target in targets)
		if(!istype(target) || !ishuman(target))
			return
		var/mob/living/carbon/human/H = target
		H.visible_message("<span class='warning'>[H]'s skin suddenly bubbles and shifts around [H.p_their()] body!</span>", \
							 "<span class='shadowling'>You regenerate your protective armor and cleanse your form of defects.</span>")
		H.set_species(/datum/species/shadow/ling)
		H.adjustCloneLoss(-target.getCloneLoss())
		H.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(H), slot_gloves)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(H), slot_wear_mask)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/shadowling(H), slot_glasses)

/obj/effect/proc_holder/spell/targeted/collective_mind //Lets a shadowling bring together their thralls' strength, granting new abilities and a headcount
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	panel = "Shadowling Abilities"
	charge_max = 300 //30 second cooldown to prevent spam
	clothes_req = 0
	range = -1
	include_user = 1
	var/blind_smoke_acquired
	var/screech_acquired
	var/nullChargeAcquired
	var/reviveThrallAcquired
	action_icon_state = "collective_mind"

/obj/effect/proc_holder/spell/targeted/collective_mind/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		charge_counter = charge_max
		return
	for(var/mob/living/target in targets)
		var/thralls = 0
		var/victory_threshold = SSticker.mode.required_thralls
		var/mob/M

		to_chat(target, "<span class='shadowling'><b>You focus your telepathic energies abound, harnessing and drawing together the strength of your thralls.</b></span>")

		for(M in GLOB.alive_mob_list)
			if(is_thrall(M))
				thralls++
				to_chat(M, "<span class='shadowling'>You feel hooks sink into your mind and pull.</span>")

		if(!do_after(target, 30, target = target))
			to_chat(target, "<span class='warning'>Your concentration has been broken. The mental hooks you have sent out now retract into your mind.</span>")
			return

		if(thralls >= CEILING(3 * SSticker.mode.thrall_ratio, 1) && !screech_acquired)
			screech_acquired = 1
			to_chat(target, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms.</span>")
			target.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/unearthly_screech(null))

		if(thralls >= CEILING(5 * SSticker.mode.thrall_ratio, 1) && !blind_smoke_acquired)
			blind_smoke_acquired = 1
			to_chat(target, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. \
			It will create a choking cloud that will blind any non-thralls who enter.</i></span>")
			target.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/blindness_smoke(null))

		if(thralls >= CEILING(7 * SSticker.mode.thrall_ratio, 1) && !nullChargeAcquired)
			nullChargeAcquired = 1
			to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Null Charge</b> ability. This ability will drain an APC's contents to the void, preventing it from recharging \
			or sending power until repaired.</i></span>")
			target.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/null_charge(null))

		if(thralls >= CEILING(9 * SSticker.mode.thrall_ratio, 1) && !reviveThrallAcquired)
			reviveThrallAcquired = 1
			to_chat(target, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. \
			This will, after a short time, bring a dead thrall completely back to life with no bodily defects.</i></span>")
			target.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/reviveThrall(null))

		if(thralls < victory_threshold)
			to_chat(target, "<span class='shadowling'>You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present.</span>")

		else if(thralls >= victory_threshold)
			to_chat(target, "<span class='shadowling'><b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i></span>")
			to_chat(target, "<span class='shadowling'><b>You may find Ascendance in the Shadowling Evolution tab.</b></span>")
			for(M in GLOB.alive_mob_list)
				if(is_shadow(M))
					var/obj/effect/proc_holder/spell/targeted/collective_mind/CM
					if(CM in M.mind.spell_list)
						M.mind.spell_list -= CM
						qdel(CM)
					M.mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/shadowling_hatch)
					M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_ascend(null))
					if(M == user)
						to_chat(M, "<span class='shadowling'><i>You project this power to the rest of the shadowlings.</i></span>")
					else
						to_chat(M, "<span class='shadowling'><b>[target.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b></span>")//Tells all the other shadowlings




/obj/effect/proc_holder/spell/targeted/blindness_smoke
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "black_smoke"

/obj/effect/proc_holder/spell/targeted/blindness_smoke/cast(list/targets, mob/user = usr) //Extremely hacky
	if(!shadowling_check(user))
		charge_counter = charge_max
		return
	for(var/mob/living/target in targets)
		target.visible_message("<span class='warning'>[target] suddenly bends over and coughs out a cloud of black smoke, which begins to spread rapidly!</span>")
		to_chat(target, "<span class='deadsay'>You regurgitate a vast cloud of blinding smoke.</span>")
		playsound(target, 'sound/effects/bamf.ogg', 50, 1)
		var/obj/item/reagent_containers/glass/beaker/large/B = new /obj/item/reagent_containers/glass/beaker/large(target.loc)
		B.reagents.clear_reagents() //Just in case!
		B.icon_state = null //Invisible
		B.reagents.add_reagent("blindness_smoke", 10)
		var/datum/effect_system/smoke_spread/chem/S = new
		if(S)
			S.set_up(B.reagents, B.loc, TRUE)
			S.start(4)
		qdel(B)

/datum/reagent/shadowling_blindness_smoke //Blinds non-shadowlings, heals shadowlings/thralls
	name = "odd black liquid"
	id = "blindness_smoke"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 100 //lel

/datum/reagent/shadowling_blindness_smoke/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!is_shadow_or_thrall(M))
		to_chat(M, "<span class='warning'><b>You breathe in the black smoke, and your eyes burn horribly!</b></span>")
		update_flags |= M.EyeBlind(5, FALSE)
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at [M.p_their()] eyes!")
			M.Stun(3)
	else
		to_chat(M, "<span class='notice'><b>You breathe in the black smoke, and you feel revitalized!</b></span>")
		update_flags |= M.heal_organ_damage(2, 2, updating_health = FALSE)
		update_flags |= M.adjustOxyLoss(-2, FALSE)
		update_flags |= M.adjustToxLoss(-2, FALSE)
	return ..() | update_flags

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech
	name = "Sonic Screech"
	desc = "Deafens, stuns, and confuses nearby people. Also shatters windows."
	panel = "Shadowling Abilities"
	range = 7
	charge_max = 300
	clothes_req = 0
	action_icon_state = "screech"

/obj/effect/proc_holder/spell/aoe_turf/unearthly_screech/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		charge_counter = charge_max
		return
	user.audible_message("<span class='warning'><b>[user] lets out a horrible scream!</b></span>")
	playsound(user.loc, 'sound/effects/screech.ogg', 100, 1)

	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == user) //No message for the user, of course
					continue
				else
					continue
			if(iscarbon(target))
				var/mob/living/carbon/M = target
				to_chat(M, "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>")
				M.AdjustConfused(10)
				M.AdjustEarDamage(3)
			else if(issilicon(target))
				var/mob/living/silicon/S = target
				to_chat(S, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>")
				S << 'sound/misc/interference.ogg'
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				do_sparks(5, 1, S)
				S.Weaken(6)
		for(var/obj/structure/window/W in T.contents)
			W.take_damage(rand(80, 100))

/obj/effect/proc_holder/spell/aoe_turf/null_charge
	name = "Null Charge"
	desc = "Empties an APC, preventing it from recharging until fixed."
	panel = "Shadowling Abilities"
	charge_max = 600
	clothes_req = FALSE
	action_icon_state = "null_charge"

/obj/effect/proc_holder/spell/aoe_turf/null_charge/cast(mob/user = usr)
	if(!shadowling_check(user))
		charge_counter = charge_max
		return

	var/list/local_objs = view(1, user)
	var/obj/machinery/power/apc/target_apc
	for(var/object in local_objs)
		if(istype(object, /obj/machinery/power/apc))
			target_apc = object
			break

	if(!target_apc)
		to_chat(user, "<span class='warning'>You must stand next to an APC to drain it!</span>")
		charge_counter = charge_max
		return

	if(target_apc.cell?.charge == 0)
		to_chat(user, "<span class='warning'>APC must have a power to drain!</span>")
		charge_counter = charge_max
		return

	target_apc.operating = 0
	target_apc.update()
	target_apc.update_icon()
	target_apc.visible_message("<span class='warning'>The [target_apc] flickers and begins to grow dark.</span>")

	to_chat(user, "<span class='shadowling'>You dim the APC's screen and carefully begin siphoning its power into the void.</span>")
	if(!do_after(user, 200, target=target_apc))
		//Whoops!  The APC's powers back on
		to_chat(user, "<span class='shadowling'>Your concentration breaks and the APC suddenly repowers!</span>")
		target_apc.operating = 1
		target_apc.update()
		target_apc.update_icon()
		target_apc.visible_message("<span class='warning'>The [target_apc] begins glowing brightly!</span>")
	else
		//We did it!
		to_chat(user, "<span class='shadowling'>You sent the APC's power to the void while overloading all it's lights!</span>")
		target_apc.cell?.charge = 0	//Sent to the shadow realm
		target_apc.chargemode = 0 //Won't recharge either until an someone hits the button
		target_apc.charging = 0
		target_apc.null_charge()
		target_apc.update_icon()



/obj/effect/proc_holder/spell/targeted/click/reviveThrall
	name = "Black Recuperation"
	desc = "Revives or empowers a thrall."
	panel = "Shadowling Abilities"
	range = 1
	charge_max = 600
	clothes_req = FALSE
	include_user = FALSE
	action_icon_state = "revive_thrall"
	click_radius = -1 // Precision baby
	selection_activated_message		= "<span class='notice'>You start focusing your powers on mending wounds of allies. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	allowed_type = /mob/living/carbon/human

/obj/effect/proc_holder/spell/targeted/click/reviveThrall/can_cast(mob/user = usr)
	if(!shadowling_check(user))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/targeted/click/reviveThrall/valid_target(mob/living/carbon/human/target, user)
	if(!..())
		return FALSE

	return is_thrall(target)

/obj/effect/proc_holder/spell/targeted/click/reviveThrall/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/thrallToRevive = targets[1]
	if(thrallToRevive.stat == CONSCIOUS)
		if(isshadowlinglesser(thrallToRevive))
			to_chat(user, "<span class='warning'>[thrallToRevive] is already empowered.</span>")
			revert_cast(user)
			return
		var/empowered_thralls = 0
		for(var/datum/mind/M in SSticker.mode.shadowling_thralls)
			if(!ishuman(M.current))
				return
			var/mob/living/carbon/human/H = M.current
			if(isshadowlinglesser(H))
				empowered_thralls++
		if(empowered_thralls >= EMPOWERED_THRALL_LIMIT)
			to_chat(user, "<span class='warning'>You cannot spare this much energy. There are too many empowered thralls.</span>")
			revert_cast(user)
			return
		user.visible_message("<span class='danger'>[user] places [user.p_their()] hands over [thrallToRevive]'s face, red light shining from beneath.</span>", \
							"<span class='shadowling'>You place your hands on [thrallToRevive]'s face and begin gathering energy...</span>")
		to_chat(thrallToRevive, "<span class='userdanger'>[user] places [user.p_their()] hands over your face. You feel energy gathering. Stand still...</span>")
		if(!do_mob(user, thrallToRevive, 80))
			to_chat(user, "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>")
			revert_cast(user)
			return
		to_chat(user, "<span class='shadowling'><b><i>You release a massive surge of power into [thrallToRevive]!</b></i></span>")
		user.visible_message("<span class='boldannounce'><i>Red lightning surges into [thrallToRevive]'s face!</i></span>")
		playsound(thrallToRevive, 'sound/weapons/egloves.ogg', 50, 1)
		playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
		user.Beam(thrallToRevive,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
		thrallToRevive.Weaken(5)
		thrallToRevive.visible_message("<span class='warning'><b>[thrallToRevive] collapses, [thrallToRevive.p_their()] skin and face distorting!</span>", \
										"<span class='userdanger'><i>AAAAAAAAAAAAAAAAAAAGH-</i></span>")
		sleep(20)
		thrallToRevive.visible_message("<span class='warning'>[thrallToRevive] slowly rises, no longer recognizable as human.</span>", \
										"<span class='shadowling'><b>You feel new power flow into you. You have been gifted by your masters. You now closely resemble them. You are empowered in \
										darkness but wither slowly in light. In addition, you now have glare and true shadow walk.</b></span>")
		thrallToRevive.set_species(/datum/species/shadow/ling/lesser)
		thrallToRevive.mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/lesser_shadow_walk)
		thrallToRevive.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/glare(null))
		thrallToRevive.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadow_walk(null))
	else if(thrallToRevive.stat == DEAD)
		user.visible_message("<span class='danger'>[user] kneels over [thrallToRevive], placing [user.p_their()] hands on [thrallToRevive.p_their()] chest.</span>", \
							"<span class='shadowling'>You crouch over the body of your thrall and begin gathering energy...</span>")
		thrallToRevive.notify_ghost_cloning("Your masters are resuscitating you! Re-enter your corpse if you wish to be brought to life.", source = thrallToRevive)
		if(!do_mob(user, thrallToRevive, 30))
			to_chat(user, "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>")
			revert_cast(user)
			return
		to_chat(user, "<span class='shadowling'><b><i>You release a massive surge of power into [thrallToRevive]!</b></i></span>")
		user.visible_message("<span class='boldannounce'><i>Red lightning surges from [user]'s hands into [thrallToRevive]'s chest!</i></span>")
		playsound(thrallToRevive, 'sound/weapons/egloves.ogg', 50, 1)
		playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
		user.Beam(thrallToRevive,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
		sleep(10)
		if(thrallToRevive.revive())
			thrallToRevive.visible_message("<span class='boldannounce'>[thrallToRevive] heaves in breath, dim red light shining in [thrallToRevive.p_their()] eyes.</span>", \
										"<span class='shadowling'><b><i>You have returned. One of your masters has brought you from the darkness beyond.</b></i></span>")
			thrallToRevive.Weaken(4)
			thrallToRevive.emote("gasp")
			playsound(thrallToRevive, "bodyfall", 50, 1)
	else
		to_chat(user, "<span class='warning'>The target must be awake to empower or dead to revive.</span>")
		revert_cast(user)

/obj/effect/proc_holder/spell/targeted/click/shadowling_extend_shuttle
	name = "Destroy Engines"
	desc = "Extends the time of the emergency shuttle's arrival by ten minutes using a life force of our enemy. Shuttle will be unable to be recalled. This can only be used once."
	panel = "Shadowling Abilities"
	range = 1
	clothes_req = FALSE
	charge_max = 600
	click_radius = -1 // Precision baby
	selection_activated_message		= "<span class='notice'>You start gathering destructive powers to delay the shuttle. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	allowed_type = /mob/living/carbon/human
	action_icon_state = "extend_shuttle"
	var/global/extendlimit = 0

/obj/effect/proc_holder/spell/targeted/click/shadowling_extend_shuttle/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!shadowling_check(user))
		return FALSE
	if(extendlimit == 1)
		if(show_message)
			to_chat(user, "<span class='warning'>Shuttle was already delayed.</span>")
		return FALSE
	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		if(show_message)
			to_chat(user, "<span class='warning'>The shuttle must be inbound only to the station.</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/targeted/click/shadowling_extend_shuttle/valid_target(mob/living/carbon/human/target, user)
	if(!..())
		return FALSE
	return !target.stat && !is_shadow_or_thrall(target)


/obj/effect/proc_holder/spell/targeted/click/shadowling_extend_shuttle/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	user.visible_message("<span class='warning'>[user]'s eyes flash a bright red!</span>", \
						"<span class='notice'>You begin to draw [target]'s life force.</span>")
	target.visible_message("<span class='warning'>[target]'s face falls slack, [target.p_their()] jaw slightly distending.</span>", \
						"<span class='boldannounce'>You are suddenly transported... far, far away...</span>")
	extendlimit = 1
	if(!do_after(user, 150, target = target))
		extendlimit = 0
		to_chat(target, "<span class='warning'>You are snapped back to reality, your haze dissipating!</span>")
		to_chat(user, "<span class='warning'>You have been interrupted. The draw has failed.</span>")
		return
	to_chat(user, "<span class='notice'>You project [target]'s life force toward the approaching shuttle, extending its arrival duration!</span>")
	target.visible_message("<span class='warning'>[target]'s eyes suddenly flare red. They proceed to collapse on the floor, not breathing.</span>", \
						"<span class='warning'><b>...speeding by... ...pretty blue glow... ...touch it... ...no glow now... ...no light... ...nothing at all...</span>")
	target.death()
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/more_minutes = 6000
		var/timer = SSshuttle.emergency.timeLeft(1) + more_minutes
		GLOB.event_announcement.Announce("Major system failure aboard the emergency shuttle. This will extend its arrival time by approximately 10 minutes and the shuttle is unable to be recalled.", "System Failure", 'sound/misc/notice1.ogg')
		SSshuttle.emergency.setTimer(timer)
		SSshuttle.emergency.canRecall = FALSE
	user.mind.spell_list.Remove(src) //Can only be used once!
	qdel(src)

// ASCENDANT ABILITIES BEYOND THIS POINT //

/obj/effect/proc_holder/spell/targeted/click/annihilate
	name = "Annihilate"
	desc = "Gibs someone instantly."
	panel = "Ascendant"
	range = 7
	charge_max = FALSE
	clothes_req = FALSE
	action_icon_state = "annihilate"
	selection_activated_message		= "<span class='notice'>You start thinking about gibs. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	allowed_type = /mob/living/carbon/human

/obj/effect/proc_holder/spell/targeted/click/annihilate/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = user
	if(SHA.phasing)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		charge_counter = charge_max
		return

	playsound(user.loc, 'sound/magic/staff_chaos.ogg', 100, 1)
	for(var/mob/living/boom in targets)
		if(is_shadow(boom)) //Used to not work on thralls. Now it does so you can PUNISH THEM LIKE THE WRATHFUL GOD YOU ARE.
			to_chat(user, "<span class='warning'>Making an ally explode seems unwise.</span>")
			charge_counter = charge_max
			return
		user.visible_message("<span class='danger'>[user]'s markings flare as [user.p_they()] gesture[user.p_s()] at [boom]!</span>", \
							"<span class='shadowling'>You direct a lance of telekinetic energy at [boom].</span>")
		sleep(4)
		if(iscarbon(boom))
			playsound(boom, 'sound/magic/disintegrate.ogg', 100, 1)
		boom.visible_message("<span class='userdanger'>[boom] explodes!</span>")
		boom.gib()



/obj/effect/proc_holder/spell/targeted/click/hypnosis
	name = "Hypnosis"
	desc = "Instantly enthralls a human."
	panel = "Ascendant"
	range = 7
	charge_max = FALSE
	clothes_req = FALSE
	action_icon_state = "enthrall"

	click_radius = -1
	selection_activated_message		= "<span class='notice'>You start preparing to mindwash over a mortal mind. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	allowed_type = /mob/living/carbon/human

/obj/effect/proc_holder/spell/targeted/click/hypnosis/can_cast(mob/living/simple_animal/ascendant_shadowling/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!istype(user))
		return FALSE
	if(user.phasing)
		if(show_message)
			to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/targeted/click/hypnosis/valid_target(mob/living/carbon/human/target, user)
	if(!..())
		return FALSE
	return !is_shadow_or_thrall(target) && target.ckey && target.mind && !target.stat

/obj/effect/proc_holder/spell/targeted/click/hypnosis/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	to_chat(user, "<span class='shadowling'>You instantly rearrange <b>[target]</b>'s memories, hyptonitizing [target.p_them()] into a thrall.</span>")
	to_chat(target, "<span class='userdanger'><font size=3>An agonizing spike of pain drives into your mind, and--</font></span>")
	SSticker.mode.add_thrall(target.mind)
	target.mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL
	target.add_language("Shadowling Hivemind")



/obj/effect/proc_holder/spell/targeted/shadowling_phase_shift
	name = "Phase Shift"
	desc = "Phases you into the space between worlds at will, allowing you to move through walls and become invisible."
	panel = "Ascendant"
	range = -1
	include_user = 1
	charge_max = 15
	clothes_req = 0
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/targeted/shadowling_phase_shift/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = user
	for(SHA in targets)
		SHA.phasing = !SHA.phasing
		if(SHA.phasing)
			SHA.visible_message("<span class='danger'>[SHA] suddenly vanishes!</span>", \
			"<span class='shadowling'>You begin phasing through planes of existence. Use the ability again to return.</span>")
			SHA.incorporeal_move = 1
			SHA.alpha = 0
		else
			SHA.visible_message("<span class='danger'>[SHA] suddenly appears from nowhere!</span>", \
			"<span class='shadowling'>You return from the space between worlds.</span>")
			SHA.incorporeal_move = 0
			SHA.alpha = 255



/obj/effect/proc_holder/spell/aoe_turf/ascendant_storm
	name = "Lightning Storm"
	desc = "Shocks everyone nearby."
	panel = "Ascendant"
	range = 6
	charge_max = 100
	clothes_req = 0
	action_icon_state = "lightning_storm"

/obj/effect/proc_holder/spell/aoe_turf/ascendant_storm/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/ascendant_shadowling/SHA = user
	if(SHA.phasing)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		charge_counter = charge_max
		return

	user.visible_message("<span class='warning'><b>A massive ball of lightning appears in [user]'s hands and flares out!</b></span>", \
						"<span class='shadowling'>You conjure a ball of lightning and release it.</span>")
	playsound(user.loc, 'sound/magic/lightningbolt.ogg', 100, 1)
	for(var/turf/T in targets)
		for(var/mob/living/carbon/human/target in T.contents)
			if(is_shadow_or_thrall(target))
				continue
			to_chat(target, "<span class='userdanger'>You are struck by a bolt of lightning!</span>")
			playsound(target, 'sound/magic/lightningshock.ogg', 50, 1)
			target.Weaken(8)
			target.take_organ_damage(0,50)
			user.Beam(target,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)

/obj/effect/proc_holder/spell/targeted/shadowlingAscendantTransmit
	name = "Ascendant Broadcast"
	desc = "Sends a message to the whole wide world."
	panel = "Ascendant"
	charge_max = 200
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "transmit"

/obj/effect/proc_holder/spell/targeted/shadowlingAscendantTransmit/cast(list/targets, mob/user = usr)
	for(var/mob/living/simple_animal/ascendant_shadowling/target in targets)
		var/text = stripped_input(target, "What do you want to say to everything on and near [station_name()]?.", "Transmit to World", "")
		if(!text)
			return
		target.announce(text)
