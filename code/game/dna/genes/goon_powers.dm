#define EAT_MOB_DELAY 300 // 30s

// WAS: /datum/bioEffect/alcres
/datum/dna/gene/basic/sober
	name="Sober"
	activation_messages=list("You feel unusually sober.")
	deactivation_messages = list("You feel like you could use a stiff drink.")

	mutation=SOBER

	New()
		block=SOBERBLOCK

//WAS: /datum/bioEffect/psychic_resist
/datum/dna/gene/basic/psychic_resist
	name="Psy-Resist"
	desc = "Boosts efficiency in sectors of the brain commonly associated with meta-mental energies."
	activation_messages = list("Your mind feels closed.")
	deactivation_messages = list("You feel oddly exposed.")

	mutation=PSY_RESIST

	New()
		block=PSYRESISTBLOCK

/////////////////////////
// Stealth Enhancers
/////////////////////////

/datum/dna/gene/basic/stealth
	can_activate(var/mob/M, var/flags)
		// Can only activate one of these at a time.
		if(is_type_in_list(/datum/dna/gene/basic/stealth,M.active_genes))
			testing("Cannot activate [type]: /datum/dna/gene/basic/stealth in M.active_genes.")
			return 0
		return ..(M,flags)

	deactivate(var/mob/M)
		..(M)
		M.alpha=255

// WAS: /datum/bioEffect/darkcloak
/datum/dna/gene/basic/stealth/darkcloak
	name = "Cloak of Darkness"
	desc = "Enables the subject to bend low levels of light around themselves, creating a cloaking effect."
	activation_messages = list("You begin to fade into the shadows.")
	deactivation_messages = list("You become fully visible.")
	activation_prob=10
	mutation = CLOAK

	New()
		block=SHADOWBLOCK

	OnMobLife(var/mob/M)
		var/turf/simulated/T = get_turf(M)
		if(!istype(T))
			return
		var/atom/movable/lighting_overlay/L = locate(/atom/movable/lighting_overlay) in T
		var/light_available
		if(L)
			light_available = L.get_clamped_lum()*10
		else
			light_available = 5
		if(light_available <= 2)
			M.alpha = round(M.alpha * 0.8)
		else
			M.alpha = 255

//WAS: /datum/bioEffect/chameleon
/datum/dna/gene/basic/stealth/chameleon
	name = "Chameleon"
	desc = "The subject becomes able to subtly alter light patterns to become invisible, as long as they remain still."
	activation_messages = list("You feel one with your surroundings.")
	deactivation_messages = list("You feel oddly visible.")
	activation_prob=10
	mutation = CHAMELEON

	New()
		block=CHAMELEONBLOCK

	OnMobLife(var/mob/M)
		if((world.time - M.last_movement) >= 30 && !M.stat && M.canmove && !M.restrained())
			M.alpha -= 25
		else
			M.alpha = round(255 * 0.80)

/////////////////////////////////////////////////////////////////////////////////////////

/datum/dna/gene/basic/grant_spell
	var/obj/effect/proc_holder/spell/spelltype

	activate(var/mob/M, var/connected, var/flags)
		M.AddSpell(new spelltype(M))
		..()
		return 1

	deactivate(var/mob/M, var/connected, var/flags)
		for(var/obj/effect/proc_holder/spell/S in M.spell_list)
			if(istype(S,spelltype))
				M.spell_list.Remove(S)
		..()
		return 1

/datum/dna/gene/basic/grant_verb
	var/verbtype

	activate(var/mob/M, var/connected, var/flags)
		..()
		M.verbs += verbtype
		return 1

	deactivate(var/mob/M, var/connected, var/flags)
		..()
		M.verbs -= verbtype

// WAS: /datum/bioEffect/cryokinesis
/datum/dna/gene/basic/grant_spell/cryo
	name = "Cryokinesis"
	desc = "Allows the subject to lower the body temperature of others."
	activation_messages = list("You notice a strange cold tingle in your fingertips.")
	deactivation_messages = list("Your fingers feel warmer.")
	mutation = CRYO

	spelltype = /obj/effect/proc_holder/spell/targeted/cryokinesis

	New()
		..()
		block = CRYOBLOCK

/obj/effect/proc_holder/spell/targeted/cryokinesis
	name = "Cryokinesis"
	desc = "Drops the bodytemperature of another person."
	panel = "Abilities"

	charge_type = "recharge"
	charge_max = 1200

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = 7
	selection_type = "range"
	include_user = 1
	var/list/compatible_mobs = list(/mob/living/carbon/human)

	action_icon_state = "genetic_cryo"

/obj/effect/proc_holder/spell/targeted/cryokinesis/cast(list/targets)
	if(!targets.len)
		to_chat(usr, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/C = targets[1]

	if(!iscarbon(C))
		to_chat(usr, "\red This will only work on normal organic beings.")
		return

	if (RESIST_COLD in C.mutations)
		C.visible_message("\red A cloud of fine ice crystals engulfs [C.name], but disappears almost instantly!")
		return
	var/handle_suit = 0
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.head, /obj/item/clothing/head/helmet/space))
			if(istype(H.wear_suit, /obj/item/clothing/suit/space))
				handle_suit = 1
				if(H.internal)
					H.visible_message("\red [usr] sprays a cloud of fine ice crystals, engulfing [H]!",
										"<span class='notice'>[usr] sprays a cloud of fine ice crystals over your [H.head]'s visor.</span>")
					log_admin("[key_name(usr)] has used cryokinesis on [key_name(C)] while wearing internals and a suit")
					msg_admin_attack("[key_name_admin(usr)] has cast cryokinesis on [key_name_admin(C)]")
				else
					H.visible_message("\red [usr] sprays a cloud of fine ice crystals engulfing, [H]!",
										"<span class='warning'>[usr] sprays a cloud of fine ice crystals cover your [H.head]'s visor and make it into your air vents!.</span>")
					log_admin("[key_name(usr)] has used cryokinesis on [key_name(C)]")
					msg_admin_attack("[key_name_admin(usr)] has cast cryokinesis on [key_name_admin(C)]")
					H.bodytemperature = max(0, H.bodytemperature - 50)
					H.adjustFireLoss(5)
	if(!handle_suit)
		C.bodytemperature = max(0, C.bodytemperature - 100)
		C.adjustFireLoss(10)
		C.ExtinguishMob()

		C.visible_message("\red [usr] sprays a cloud of fine ice crystals, engulfing [C]!")
		log_admin("[key_name(usr)] has used cryokinesis on [key_name(C)] without internals or a suit")
		msg_admin_attack("[key_name_admin(usr)] has cast cryokinesis on [key_name_admin(C)]")

	//playsound(usr.loc, 'bamf.ogg', 50, 0)

	new/obj/effect/self_deleting(C.loc, icon('icons/effects/genetics.dmi', "cryokinesis"))

	return

/obj/effect/self_deleting
	density = 0
	opacity = 0
	anchored = 1
	icon = null
	desc = ""
	//layer = 15

	New(var/atom/location, var/icon/I, var/duration = 20, var/oname = "something")
		src.name = oname
		loc=location
		src.icon = I
		spawn(duration)
			qdel(src)

///////////////////////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/mattereater
/datum/dna/gene/basic/grant_spell/mattereater
	name = "Matter Eater"
	desc = "Allows the subject to eat just about anything without harm."
	activation_messages = list("You feel hungry.")
	deactivation_messages = list("You don't feel quite so hungry anymore.")
	mutation = EATER

	spelltype=/obj/effect/proc_holder/spell/targeted/eat

	New()
		..()
		block = EATBLOCK

/obj/effect/proc_holder/spell/targeted/eat
	name = "Eat"
	desc = "Eat just about anything!"
	panel = "Abilities"

	charge_type = "recharge"
	charge_max = 300

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = 1
	selection_type = "view"

	action_icon_state = "genetic_eat"

	var/list/types_allowed = list(
		/obj/item,
		/mob/living/simple_animal/pet,
		/mob/living/simple_animal/hostile,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/mouse,
		/mob/living/carbon/human,
		/mob/living/carbon/slime,
		/mob/living/carbon/alien/larva,
		/mob/living/simple_animal/slime,
		/mob/living/simple_animal/adultslime,
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/lizard,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/spiderbot
	)
	var/list/own_blacklist = list(
		/obj/item/organ,
		/obj/item/weapon/implant
	)

/obj/effect/proc_holder/spell/targeted/eat/proc/doHeal(var/mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/name in H.organs_by_name)
			var/obj/item/organ/external/affecting = null
			if(!H.organs[name])
				continue
			affecting = H.organs[name]
			if(!istype(affecting, /obj/item/organ/external))
				continue
			affecting.heal_damage(4, 0)
		H.UpdateDamageIcon()
		H.updatehealth()

/obj/effect/proc_holder/spell/targeted/eat/choose_targets(mob/user = usr)
	var/list/targets = new /list()
	var/list/possible_targets = new /list()

	for(var/atom/movable/O in view_or_range(range, user, selection_type))
		if((O in user) && is_type_in_list(O,own_blacklist))
			continue
		if(is_type_in_list(O,types_allowed))
			possible_targets += O

	targets += input("Choose the target of your hunger.", "Targeting") as null|anything in possible_targets

	if(!targets.len || !targets[1]) //doesn't waste the spell
		revert_cast(user)
		return

	perform(targets)

/obj/effect/proc_holder/spell/targeted/eat/cast(list/targets)
	var/mob/user = usr
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/atom/movable/the_item = targets[1]
	if(ishuman(the_item))
		//My gender
		var/m_his = "his"
		if(user.gender == FEMALE)
			m_his = "her"
		// Their gender
		var/t_his = "his"
		if(the_item.gender == FEMALE)
			t_his = "her"
		var/mob/living/carbon/human/H = the_item
		var/obj/item/organ/external/limb = H.get_organ(user.zone_sel.selecting)
		if(!istype(limb))
			to_chat(user, "<span class='warning'>You can't eat this part of them!</span>")
			revert_cast()
			return 0
		if(istype(limb,/obj/item/organ/external/head))
			// Bullshit, but prevents being unable to clone someone.
			to_chat(user, "<span class='warning'>You try to put \the [limb] in your mouth, but [t_his] ears tickle your throat!</span>")
			revert_cast()
			return 0
		if(istype(limb,/obj/item/organ/external/chest))
			// Bullshit, but prevents being able to instagib someone.
			to_chat(user, "<span class='warning'>You try to put their [limb] in your mouth, but it's too big to fit!</span>")
			revert_cast()
			return 0
		user.visible_message("<span class='danger'>[user] begins stuffing [the_item]'s [limb.name] into [m_his] gaping maw!</span>")
		var/oldloc = H.loc
		if(!do_mob(user,H,EAT_MOB_DELAY))
			to_chat(user, "<span class='danger'>You were interrupted before you could eat [the_item]!</span>")
		else
			if(!limb || !H)
				return
			if(H.loc != oldloc)
				to_chat(user, "<span class='danger'>\The [limb] moved away from your mouth!</span>")
				return
			user.visible_message("<span class='danger'>[user] [pick("chomps","bites")] off [the_item]'s [limb]!</span>")
			playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
			limb.droplimb(0, DROPLIMB_EDGE)
			doHeal(user)
	else
		user.visible_message("<span class='danger'>[user] eats \the [the_item].</span>")
		playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
		qdel(the_item)
		doHeal(user)
	return

////////////////////////////////////////////////////////////////////////

//WAS: /datum/bioEffect/jumpy
/datum/dna/gene/basic/grant_spell/jumpy
	name = "Jumpy"
	desc = "Allows the subject to leap great distances."
	//cooldown = 30
	activation_messages = list("Your leg muscles feel taut and strong.")
	deactivation_messages = list("Your leg muscles shrink back to normal.")
	mutation = JUMPY

	spelltype =/obj/effect/proc_holder/spell/targeted/leap

	New()
		..()
		block = JUMPBLOCK

/obj/effect/proc_holder/spell/targeted/leap
	name = "Jump"
	desc = "Leap great distances!"
	panel = "Abilities"
	range = -1
	include_user = 1

	charge_type = "recharge"
	charge_max = 60

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"

	action_icon_state = "genetic_jump"

/obj/effect/proc_holder/spell/targeted/leap/cast(list/targets)
	var/failure = 0
	if (istype(usr.loc,/mob/) || usr.lying || usr.stunned || usr.buckled || usr.stat)
		to_chat(usr, "\red You can't jump right now!")
		return

	if (istype(usr.loc,/turf/))


		if(usr.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(usr, 1))
				if(M.pulling == usr)
					if(!M.restrained() && M.stat == 0 && M.canmove && usr.Adjacent(M))
						failure = 1
					else
						M.stop_pulling()

		if(usr.pinned.len)
			failure = 1

		usr.visible_message("\red <b>[usr.name]</b> takes a huge leap!")
		playsound(usr.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
		if(failure)
			usr.Weaken(5)
			usr.Stun(5)
			usr.visible_message("<span class='warning'> \the [usr] attempts to leap away but is slammed back down to the ground!</span>",
								"<span class='warning'>You attempt to leap away but are suddenly slammed back down to the ground!</span>",
								"<span class='notice'>You hear the flexing of powerful muscles and suddenly a crash as a body hits the floor.</span>")
			return 0
		var/prevLayer = usr.layer
		var/prevFlying = usr.flying
		usr.layer = 9

		usr.flying = 1
		for(var/i=0, i<10, i++)
			step(usr, usr.dir)
			if(i < 5) usr.pixel_y += 8
			else usr.pixel_y -= 8
			sleep(1)
		usr.flying = prevFlying

		if (FAT in usr.mutations && prob(66))
			usr.visible_message("\red <b>[usr.name]</b> crashes due to their heavy weight!")
			//playsound(usr.loc, 'zhit.wav', 50, 1)
			usr.AdjustWeakened(10)
			usr.AdjustStunned(5)

		usr.layer = prevLayer

	if (istype(usr.loc,/obj/))
		var/obj/container = usr.loc
		to_chat(usr, "\red You leap and slam your head against the inside of [container]! Ouch!")
		usr.AdjustParalysis(3)
		usr.AdjustWeakened(5)
		container.visible_message("\red <b>[usr.loc]</b> emits a loud thump and rattles a bit.")
		playsound(usr.loc, 'sound/effects/bang.ogg', 50, 1)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0


	return

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/polymorphism

/datum/dna/gene/basic/grant_spell/polymorph
	name = "Polymorphism"
	desc = "Enables the subject to reconfigure their appearance to mimic that of others."

	spelltype =/obj/effect/proc_holder/spell/targeted/polymorph
	//cooldown = 1800
	activation_messages = list("You don't feel entirely like yourself somehow.")
	deactivation_messages = list("You feel secure in your identity.")
	mutation = POLYMORPH

	New()
		..()
		block = POLYMORPHBLOCK

/obj/effect/proc_holder/spell/targeted/polymorph
	name = "Polymorph"
	desc = "Mimic the appearance of others!"
	panel = "Abilities"
	charge_max = 1800

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = 1
	selection_type = "range"

	action_icon_state = "genetic_poly"

/obj/effect/proc_holder/spell/targeted/polymorph/cast(list/targets)
	var/mob/living/M=targets[1]
	if(!ishuman(M))
		to_chat(usr, "\red You can only change your appearance to that of another human.")
		return

	if(!ishuman(usr))
		return

	usr.visible_message("\red [usr]'s body shifts and contorts.")

	spawn(10)
		if(M && usr)
			playsound(usr.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
			var/mob/living/carbon/human/H = usr
			var/mob/living/carbon/human/target = M
			H.UpdateAppearance(target.dna.UI)
			H.real_name = target.real_name
			H.name = target.name

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/empath
/datum/dna/gene/basic/grant_spell/empath
	name = "Empathic Thought"
	desc = "The subject becomes able to read the minds of others for certain information."

	spelltype = /obj/effect/proc_holder/spell/targeted/empath
	activation_messages = list("You suddenly notice more about others than you did before.")
	deactivation_messages = list("You no longer feel able to sense intentions.")
	mutation=EMPATH

	New()
		..()
		block = EMPATHBLOCK

/obj/effect/proc_holder/spell/targeted/empath
	name = "Read Mind"
	desc = "Read the minds of others for information."
	charge_max = 180
	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = -2
	selection_type = "range"

	action_icon_state = "genetic_empath"

/obj/effect/proc_holder/spell/targeted/empath/choose_targets(mob/user = usr)
	var/list/targets = new /list()
	targets += input("Choose the target to spy on.", "Targeting") as null|mob in range(7,usr)

	if(!targets.len || !targets[1]) //doesn't waste the spell
		revert_cast(user)
		return

	perform(targets)

/obj/effect/proc_holder/spell/targeted/empath/cast(list/targets)
	if(!ishuman(usr))	return


	for(var/mob/living/carbon/M in targets)
		if(!iscarbon(M))
			to_chat(usr, "\red You may only use this on other organic beings.")
			return

		if (PSY_RESIST in M.mutations)
			to_chat(usr, "\red You can't see into [M.name]'s mind at all!")
			return

		if (M.stat == 2)
			to_chat(usr, "\red [M.name] is dead and cannot have their mind read.")
			return
		if (M.health < 0)
			to_chat(usr, "\red [M.name] is dying, and their thoughts are too scrambled to read.")
			return

		to_chat(usr, "\blue Mind Reading of [M.name]:</b>")
		var/pain_condition = M.health
		// lower health means more pain
		var/list/randomthoughts = list("what to have for lunch","the future","the past","money",
		"their hair","what to do next","their job","space","amusing things","sad things",
		"annoying things","happy things","something incoherent","something they did wrong")
		var/thoughts = "thinking about [pick(randomthoughts)]"

		if(M.fire_stacks)
			pain_condition -= 50
			thoughts = "preoccupied with the fire"

		if (M.radiation)
			pain_condition -= 25

		switch(pain_condition)
			if (81 to INFINITY)
				to_chat(usr, "\blue <b>Condition</b>: [M.name] feels good.")
			if (61 to 80)
				to_chat(usr, "\blue <b>Condition</b>: [M.name] is suffering mild pain.")
			if (41 to 60)
				to_chat(usr, "\blue <b>Condition</b>: [M.name] is suffering significant pain.")
			if (21 to 40)
				to_chat(usr, "\blue <b>Condition</b>: [M.name] is suffering severe pain.")
			else
				to_chat(usr, "\blue <b>Condition</b>: [M.name] is suffering excruciating pain.")
				thoughts = "haunted by their own mortality"

		switch(M.a_intent)
			if (I_HELP)
				to_chat(usr, "\blue <b>Mood</b>: You sense benevolent thoughts from [M.name].")
			if (I_DISARM)
				to_chat(usr, "\blue <b>Mood</b>: You sense cautious thoughts from [M.name].")
			if (I_GRAB)
				to_chat(usr, "\blue <b>Mood</b>: You sense hostile thoughts from [M.name].")
			if (I_HARM)
				to_chat(usr, "\blue <b>Mood</b>: You sense cruel thoughts from [M.name].")
				for(var/mob/living/L in view(7,M))
					if (L == M)
						continue
					thoughts = "thinking about punching [L.name]"
					break
			else
				to_chat(usr, "\blue <b>Mood</b>: You sense strange thoughts from [M.name].")

		if (istype(M,/mob/living/carbon/human))
			var/numbers[0]
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.initial_account)
				numbers += H.mind.initial_account.account_number
				numbers += H.mind.initial_account.remote_access_pin
			if(numbers.len>0)
				to_chat(usr, "\blue <b>Numbers</b>: You sense the number[numbers.len>1?"s":""] [english_list(numbers)] [numbers.len>1?"are":"is"] important to [M.name].")
		to_chat(usr, "\blue <b>Thoughts</b>: [M.name] is currently [thoughts].")

		if (EMPATH in M.mutations)
			to_chat(M, "\red You sense [usr.name] reading your mind.")
		else if (prob(5) || M.mind.assigned_role=="Chaplain")
			to_chat(M, "\red You sense someone intruding upon your thoughts...")
		return

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/superfart
/datum/dna/gene/basic/grant_spell/superfart
	name = "High-Pressure Intestines"
	desc = "Vastly increases the gas capacity of the subject's digestive tract."
	activation_messages = list("You feel bloated and gassy.")
	deactivation_messages = list("You no longer feel gassy. What a relief!")

	mutation = SUPER_FART
	spelltype = /obj/effect/proc_holder/spell/aoe_turf/superfart

	New()
		..()
		block = SUPERFARTBLOCK

/obj/effect/proc_holder/spell/aoe_turf/superfart
	name = "Super Fart"
	desc = "Fart with the fury of 1000 burritos."
	panel = "Abilities"
	charge_max = 900
	invocation_type = "emote"
	range = 3
	clothes_req = 0
	selection_type = "view"
	action_icon_state = "superfart"

/obj/effect/proc_holder/spell/aoe_turf/superfart/invocation(mob/user = usr)
	invocation = "<span class='warning'><b>[user]</b> hunches down and grits their teeth!</span>"
	invocation_emote_self = invocation
	..(user)

/obj/effect/proc_holder/spell/aoe_turf/superfart/cast(list/targets)
	var/UT = get_turf(usr)

	if(do_after(usr, 30, target = usr))
		playsound(UT, 'sound/goonstation/effects/superfart.ogg', 50, 0)
		usr.visible_message("<span class='warning'><b>[usr]</b> unleashes a [pick("tremendous","gigantic","colossal")] fart!</span>", "<span class='warning'>You hear a [pick("tremendous","gigantic","colossal")] fart.</span>")
		for(var/T in targets)
			for(var/mob/living/M in T)
				shake_camera(M, 10, 5)
				if (M == usr)
					continue
				to_chat(M, "<span class='warning'>You are sent flying!</span>")
				M.Weaken(5)
				step_away(M, UT, 15)
				step_away(M, UT, 15)
				step_away(M, UT, 15)
	else
		to_chat(usr, "<span class='warning'>You were interrupted and couldn't fart! Rude!</span>")
