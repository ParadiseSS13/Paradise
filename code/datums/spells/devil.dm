/obj/effect/proc_holder/spell/conjure_item/pitchfork
	name = "Summon Pitchfork"
	desc = "A devil's weapon of choice.  Use this to summon/unsummon your pitchfork."
	item_type = /obj/item/twohanded/pitchfork/demonic
	action_icon_state = "pitchfork"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/conjure_item/pitchfork/greater
	item_type = /obj/item/twohanded/pitchfork/demonic/greater


/obj/effect/proc_holder/spell/conjure_item/pitchfork/ascended
	item_type = /obj/item/twohanded/pitchfork/demonic/ascended


/obj/effect/proc_holder/spell/conjure_item/violin
	item_type = /obj/item/instrument/violin/golden
	desc = "A devil's instrument of choice.  Use this to summon/unsummon your golden violin."
	invocation_type = "whisper"
	invocation = "I ain't have this much fun since Georgia."
	action_icon_state = "golden_violin"
	name = "Summon golden violin"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/summon_contract
	name = "Summon infernal contract"
	desc = "Skip making a contract by hand, just do it by magic."
	invocation_type = "whisper"
	invocation = "Just sign on the dotted line."
	selection_activated_message = "<span class='notice'>You prepare a detailed contract. Click on a target to summon the contract in his hands.</span>"
	selection_deactivated_message = "<span class='notice'>You archive the contract for later use.</span>"
	clothes_req = FALSE
	human_req = FALSE
	school = "conjuration"
	base_cooldown = 15 SECONDS
	cooldown_min = 1 SECONDS
	action_icon_state = "spell_default"
	action_background_icon_state = "bg_demon"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/summon_contract/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 5
	T.click_radius = -1
	T.allowed_type = /mob/living/carbon
	return T


/obj/effect/proc_holder/spell/summon_contract/valid_target(mob/living/carbon/target, mob/user)
	return target.mind && target.ckey && !target.stat


/obj/effect/proc_holder/spell/summon_contract/cast(list/targets, mob/user = usr)
	for(var/target in targets)
		var/mob/living/carbon/C = target
		if(C.mind && user.mind)
			if(C.stat == DEAD)
				if(user.drop_from_active_hand())
					var/obj/item/paper/contract/infernal/revive/contract = new(user.loc, C.mind, user.mind)
					user.put_in_hands(contract)
			else
				var/obj/item/paper/contract/infernal/contract
				var/contractTypeName = input(user, "What type of contract?") in list (CONTRACT_POWER, CONTRACT_WEALTH, CONTRACT_PRESTIGE, CONTRACT_MAGIC, CONTRACT_KNOWLEDGE, CONTRACT_FRIENDSHIP)  //TODO: Refactor this to be less boilerplate-y
				switch(contractTypeName)
					if(CONTRACT_POWER)
						contract = new /obj/item/paper/contract/infernal/power(C.loc, C.mind, user.mind)
					if(CONTRACT_WEALTH)
						contract = new /obj/item/paper/contract/infernal/wealth(C.loc, C.mind, user.mind)
					if(CONTRACT_PRESTIGE)
						contract = new /obj/item/paper/contract/infernal/prestige(C.loc, C.mind, user.mind)
					if(CONTRACT_MAGIC)
						contract = new /obj/item/paper/contract/infernal/magic(C.loc, C.mind, user.mind)
					if(CONTRACT_KNOWLEDGE)
						contract = new /obj/item/paper/contract/infernal/knowledge(C.loc, C.mind, user.mind)
					if(CONTRACT_FRIENDSHIP)
						contract = new /obj/item/paper/contract/infernal/friendship(C.loc, C.mind, user.mind)
				C.put_in_hands(contract)
		else
			to_chat(user,"<span class='notice'>[C] seems to not be sentient. You are unable to summon a contract for them.</span>")


/obj/effect/proc_holder/spell/fireball/hellish
	name = "Hellfire"
	desc = "This spell launches hellfire at the target."
	school = "evocation"
	base_cooldown = 8 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	invocation = "Your very soul will catch fire!"
	invocation_type = "shout"
	fireball_type = /obj/item/projectile/magic/fireball/infernal
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/infernal_jaunt
	name = "Infernal Jaunt"
	desc = "Use hellfire to phase out of existence."
	base_cooldown = 20 SECONDS
	cooldown_min = 0
	overlay = null
	action_icon_state = "jaunt"
	action_background_icon_state = "bg_demon"
	phase_allowed = TRUE


/obj/effect/proc_holder/spell/infernal_jaunt/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/infernal_jaunt/cast(list/targets, mob/living/user = usr)
	if(istype(user))
		if(istype(user.loc, /obj/effect/dummy/slaughter))
			var/continuing = 0
			if(istype(get_area(user), /area/shuttle)) // Can always phase in in a shuttle.
				continuing = TRUE
			else
				for(var/mob/living/C in orange(2, get_turf(user.loc))) //Can also phase in when nearby a potential buyer.
					if (C.mind && C.mind.soulOwner == C.mind)
						continuing = TRUE
						break
			if(continuing)
				to_chat(user,"<span class='warning'>You are now phasing in.</span>")
				if(do_mob(user,user,150))
					user.infernalphasein()
			else
				to_chat(user,"<span class='warning'>You can only re-appear near a potential signer or on a shuttle.</span>")
				revert_cast()
				return ..()
		else
			user.fakefire()
			to_chat(user,"<span class='warning'>You begin to phase back into sinful flames.</span>")
			if(do_mob(user,user,150))
				user.notransform = TRUE
				user.infernalphaseout()
			else
				to_chat(user,"<span class='warning'>You must remain still while exiting.</span>")
				user.ExtinguishMob()
		cooldown_handler.start_recharge()
		return
	revert_cast()


/mob/living/proc/infernalphaseout()
	dust_animation()
	visible_message("<span class='warning'>[src] disappears in a flashfire!</span>")
	playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, 1, -1)
	var/obj/effect/dummy/slaughter/s_holder = new(loc)
	ExtinguishMob()
	forceMove(s_holder)
	holder = s_holder
	notransform = FALSE
	fakefireextinguish()


/mob/living/proc/infernalphasein()
	if(notransform)
		to_chat(src,"<span class='warning'>You're too busy to jaunt in.</span>")
		return 0
	fakefire()
	forceMove(get_turf(src))
	visible_message("<span class='warning'><B>[src] appears in a firey blaze!</B></span>")
	playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, 1, -1)
	spawn(1.5 SECONDS)
		fakefireextinguish(TRUE)


/obj/effect/proc_holder/spell/sintouch
	name = "Sin Touch"
	desc = "Subtly encourage someone to sin."
	base_cooldown = 180 SECONDS
	cooldown_min = 0
	clothes_req = FALSE
	human_req = FALSE
	overlay = null
	action_icon_state = "sintouch"
	action_background_icon_state = "bg_demon"
	invocation = "TASTE SIN AND INDULGE!!"
	invocation_type = "shout"
	var/max_targets = 3


/obj/effect/proc_holder/spell/sintouch/ascended
	name = "Greater sin touch"
	base_cooldown = 10 SECONDS
	max_targets = 10


/obj/effect/proc_holder/spell/sintouch/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.random_target = TRUE
	T.target_priority = SPELL_TARGET_RANDOM
	T.use_turf_of_user = TRUE
	T.range = 2
	T.max_targets = 3
	return T


/obj/effect/proc_holder/spell/sintouch/sintouch/cast(list/targets, mob/living/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		if(!H.mind)
			continue
		for(var/datum/objective/sintouched/A in H.mind.objectives)
			continue
		H.influenceSin()
		H.Weaken(4 SECONDS)


/obj/effect/proc_holder/spell/summon_dancefloor
	name = "Summon Dancefloor"
	desc = "When what a Devil really needs is funk."
	clothes_req = FALSE
	human_req = FALSE
	school = "conjuration"
	base_cooldown = 1 SECONDS
	cooldown_min = 5 SECONDS //5 seconds, so the smoke can't be spammed
	action_icon_state = "funk"
	action_background_icon_state = "bg_demon"

	var/list/dancefloor_turfs
	var/list/dancefloor_turfs_types
	var/dancefloor_exists = FALSE
//	var/datum/effect_system/smoke_spread/transparent/dancefloor_devil/smoke


/obj/effect/proc_holder/spell/summon_dancefloor/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/summon_dancefloor/cast(list/targets, mob/user = usr)
	LAZYINITLIST(dancefloor_turfs)
	LAZYINITLIST(dancefloor_turfs_types)

/*
	if(!smoke)
		smoke = new()
	smoke.set_up(0, get_turf(user))
	smoke.start()
*/

	if(dancefloor_exists)
		dancefloor_exists = FALSE
		for(var/i in 1 to dancefloor_turfs.len)
			var/turf/T = dancefloor_turfs[i]
			T.ChangeTurf(dancefloor_turfs_types[i])
	else
		var/list/funky_turfs = RANGE_TURFS(1, user)
		for(var/turf/T in funky_turfs)
			if(T.density)
				to_chat(user, "<span class='warning'>You're too close to a wall.</span>")
				return
		dancefloor_exists = TRUE
		var/i = 1
		dancefloor_turfs.len = funky_turfs.len
		dancefloor_turfs_types.len = funky_turfs.len
		for(var/t in funky_turfs)
			var/turf/T = t
			dancefloor_turfs[i] = T
			dancefloor_turfs_types[i] = T.type
			T.ChangeTurf((i % 2 == 0) ? /turf/simulated/floor/light/colour_cycle/dancefloor_a : /turf/simulated/floor/light/colour_cycle/dancefloor_b)
			i++


/*
/datum/effect_system/smoke_spread/transparent/dancefloor_devil
	effect_type = /obj/effect/particle_effect/smoke/transparent/dancefloor_devil


/obj/effect/particle_effect/smoke/transparent/dancefloor_devil
	lifetime = 2
*/
