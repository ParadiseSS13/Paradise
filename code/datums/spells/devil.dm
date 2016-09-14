/obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork
	name = "Summon Pitchfork"
	desc = "A devil's weapon of choice.  Use this to summon/unsummon your pitchfork."
	item_type = /obj/item/weapon/twohanded/pitchfork/demonic/
	action_icon_state = "pitchfork"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork/greater
	item_type = /obj/item/weapon/twohanded/pitchfork/demonic/greater

/obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork/ascended
	item_type = /obj/item/weapon/twohanded/pitchfork/demonic/ascended

/obj/effect/proc_holder/spell/targeted/conjure_item/violin
	item_type = /obj/item/device/violin/golden
	desc = "A devil's instrument of choice.  Use this to summon/unsummon your golden violin."
	invocation_type = "whisper"
	invocation = "I aint have this much fun since Georgia."
	action_icon_state = "golden_violin"
	name = "Summon golden violin"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/targeted/summon_contract
	name = "Summon infernal contract"
	desc = "Skip making a contract by hand, just do it by magic."
	invocation_type = "whisper"
	invocation = "Just sign on the dotted line."
	include_user = 0
	range = 5
	clothes_req = 0

	school = "conjuration"
	charge_max = 150
	cooldown_min = 10
	action_icon_state = "spell_default"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/summon_contract/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		if(C.mind && user.mind)
			if(C.stat == DEAD)
				if(user.drop_item())
					var/obj/item/weapon/paper/contract/infernal/revive/contract = new(user.loc, C.mind, user.mind)
					user.put_in_hands(contract)
			else
				var/obj/item/weapon/paper/contract/infernal/contract  // = new(user.loc, C.mind, contractType, user.mind)
				var/contractTypeName = input(user, "What type of contract?") in list ("Power", "Wealth", "Prestige", "Magic", "Knowledge")
				switch(contractTypeName)
					if("Power")
						contract = new /obj/item/weapon/paper/contract/infernal/power(C.loc, C.mind, user.mind)
					if("Wealth")
						contract = new /obj/item/weapon/paper/contract/infernal/wealth(C.loc, C.mind, user.mind)
					if("Prestige")
						contract = new /obj/item/weapon/paper/contract/infernal/prestige(C.loc, C.mind, user.mind)
					if("Magic")
						contract = new /obj/item/weapon/paper/contract/infernal/magic(C.loc, C.mind, user.mind)
					if("Knowledge")
						contract = new /obj/item/weapon/paper/contract/infernal/knowledge(C.loc, C.mind, user.mind)
				C.put_in_hands(contract)
		else
			to_chat(user,"<span class='notice'>[C] seems to not be sentient.  You cannot summon a contract for them.</span>")


/obj/effect/proc_holder/spell/dumbfire/fireball/hellish
	name = "Hellfire"
	desc = "This spell launches hellfire at the target."

	school = "evocation"
	charge_max = 80
	clothes_req = 0
	invocation = "Your very soul will catch fire!"
	invocation_type = "shout"
	proj_type = /obj/effect/proc_holder/spell/turf/fireball/infernal
	range = 2
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/turf/fireball/infernal/cast(var/turf/T)
	explosion(T, -1, -1, -1, 4, 0, flame_range = 5)

/obj/effect/proc_holder/spell/targeted/infernal_jaunt
	name = "Infernal Jaunt"
	desc = "Use hellfire to phase out of existence."
	charge_max = 200
	clothes_req = 0
	selection_type = "range"
	range = -1
	cooldown_min = 0
	overlay = null
	include_user = 1
	action_icon_state = "jaunt"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/infernal_jaunt/cast(list/targets, mob/living/user = usr)
	if(istype(user))
		if(istype(user.loc, /obj/effect/dummy/slaughter/))
			var/continuing = 0
			if(istype(get_area(user), /area/shuttle/)) // Can always phase in in a shuttle.
				continuing = 1
			else
				for(var/mob/living/C in orange(2, get_turf(user.loc))) //Can also phase in when nearby a potential buyer.
					if (C.mind && C.mind.soulOwner == C.mind)
						continuing = 1
						break
			if(continuing)
				to_chat(user,"<span class='warning'>You are now phasing in.</span>")
				if(do_mob(user,user,150))
					user.infernalphasein()
			else
				to_chat(user,"<span class='warning'>You can only re-appear near a potential signer.")
				revert_cast()
				return ..()
		else
			user.notransform = 1
			user.fakefire()
			to_chat(user,"<span class='warning'>You begin to phase back into sinful flames.</span>")
			if(do_mob(user,user,150))
				user.infernalphaseout()
			else
				to_chat(user,"<span class='warning'>You must remain still while exiting.</span>")
				user.ExtinguishMob()
		start_recharge()
		return
	revert_cast()


/mob/living/proc/infernalphaseout()
	dust_animation()
	src.visible_message("<span class='warning'>[src] disappears in a flashfire!</span>")
	playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, 1, -1)
	var/obj/effect/dummy/slaughter/holder = PoolOrNew(/obj/effect/dummy/slaughter,loc)
	src.ExtinguishMob()
	if(buckled)
		buckled.unbuckle_mob(src,force=1)
	if(has_buckled_mobs())
		unbuckle_mob()
	if(pulledby)
		pulledby.stop_pulling()
	if(pulling)
		stop_pulling()
	src.loc = holder
	src.holder = holder
	src.notransform = 0
	fakefireextinguish()

/mob/living/proc/infernalphasein()
	if(src.notransform)
		to_chat(src,"<span class='warning'>You're too busy to jaunt in.</span>")
		return 0
	fakefire()
	src.loc = get_turf(src)
	src.client.eye = src
	src.visible_message("<span class='warning'><B>[src] appears in a firey blaze!</B>")
	playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, 1, -1)
	spawn(15)
		fakefireextinguish(TRUE)

/obj/effect/proc_holder/spell/targeted/sintouch
	name = "Sin Touch"
	desc = "Subtly encourage someone to sin."
	charge_max = 1800
	clothes_req = 0
	selection_type = "range"
	range = 2
	cooldown_min = 0
	overlay = null
	include_user = 0
	action_icon_state = "sintouch"
	action_background_icon_state = "bg_demon"
	random_target = 1
	random_target_priority = TARGET_RANDOM
	max_targets = 3
	invocation = "TASTE SIN AND INDULGE!!"
	invocation_type = "shout"

/obj/effect/proc_holder/spell/targeted/sintouch/ascended
	name = "Greater sin touch"
	charge_max = 100
	range = 7
	max_targets = 10

/obj/effect/proc_holder/spell/targeted/sintouch/cast(list/targets, mob/living/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		if(!H.mind)
			continue
		for(var/datum/objective/sintouched/A in H.mind.objectives)
			continue
		H.influenceSin()
		H.Weaken(2)
		H.Stun(2)
