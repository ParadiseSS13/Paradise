#define EAT_MOB_DELAY 300 // 30s

// WAS: /datum/bioEffect/alcres
/datum/dna/gene/basic/sober
	name="Sober"
	activation_messages=list("You feel unusually sober.")
	deactivation_messages = list("You feel like you could use a stiff drink.")

	mutation=SOBER

/datum/dna/gene/basic/sober/New()
	block=GLOB.soberblock

//WAS: /datum/bioEffect/psychic_resist
/datum/dna/gene/basic/psychic_resist
	name="Psy-Resist"
	desc = "Boosts efficiency in sectors of the brain commonly associated with meta-mental energies."
	activation_messages = list("Your mind feels closed.")
	deactivation_messages = list("You feel oddly exposed.")

	mutation=PSY_RESIST

/datum/dna/gene/basic/psychic_resist/New()
	block=GLOB.psyresistblock

/////////////////////////
// Stealth Enhancers
/////////////////////////

/datum/dna/gene/basic/stealth
	instability = GENE_INSTABILITY_MODERATE

/datum/dna/gene/basic/stealth/can_activate(var/mob/M, var/flags)
	// Can only activate one of these at a time.
	if(is_type_in_list(/datum/dna/gene/basic/stealth,M.active_genes))
		testing("Cannot activate [type]: /datum/dna/gene/basic/stealth in M.active_genes.")
		return 0
	return ..(M,flags)

/datum/dna/gene/basic/stealth/deactivate(var/mob/M)
	..(M)
	M.alpha=255

// WAS: /datum/bioEffect/darkcloak
/datum/dna/gene/basic/stealth/darkcloak
	name = "Cloak of Darkness"
	desc = "Enables the subject to bend low levels of light around themselves, creating a cloaking effect."
	activation_messages = list("You begin to fade into the shadows.")
	deactivation_messages = list("You become fully visible.")
	activation_prob=25
	mutation = CLOAK

/datum/dna/gene/basic/stealth/darkcloak/New()
	block=GLOB.shadowblock

/datum/dna/gene/basic/stealth/darkcloak/OnMobLife(var/mob/M)
	var/turf/simulated/T = get_turf(M)
	if(!istype(T))
		return
	var/light_available = T.get_lumcount() * 10
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
	activation_prob=25
	mutation = CHAMELEON

/datum/dna/gene/basic/stealth/chameleon/New()
		block=GLOB.chameleonblock

/datum/dna/gene/basic/stealth/chameleon/OnMobLife(var/mob/M)
	if((world.time - M.last_movement) >= 30 && !M.stat && M.canmove && !M.restrained())
		M.alpha -= 25
	else
		M.alpha = round(255 * 0.80)

/////////////////////////////////////////////////////////////////////////////////////////

/datum/dna/gene/basic/grant_spell
	var/obj/effect/proc_holder/spell/spelltype

/datum/dna/gene/basic/grant_spell/activate(var/mob/M, var/connected, var/flags)
	M.AddSpell(new spelltype(null))
	..()
	return 1

/datum/dna/gene/basic/grant_spell/deactivate(var/mob/M, var/connected, var/flags)
	for(var/obj/effect/proc_holder/spell/S in M.mob_spell_list)
		if(istype(S, spelltype))
			M.RemoveSpell(S)
	..()
	return 1

/datum/dna/gene/basic/grant_verb
	var/verbtype

/datum/dna/gene/basic/grant_verb/activate(var/mob/M, var/connected, var/flags)
	..()
	M.verbs += verbtype
	return 1

/datum/dna/gene/basic/grant_verb/deactivate(var/mob/M, var/connected, var/flags)
	..()
	M.verbs -= verbtype

// WAS: /datum/bioEffect/cryokinesis
/datum/dna/gene/basic/grant_spell/cryo
	name = "Cryokinesis"
	desc = "Allows the subject to lower the body temperature of others."
	activation_messages = list("You notice a strange cold tingle in your fingertips.")
	deactivation_messages = list("Your fingers feel warmer.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = CRYO

	spelltype = /obj/effect/proc_holder/spell/targeted/cryokinesis

/datum/dna/gene/basic/grant_spell/cryo/New()
	..()
	block = GLOB.cryoblock

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

/obj/effect/proc_holder/spell/targeted/cryokinesis/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/C = targets[1]

	if(!iscarbon(C))
		to_chat(user, "<span class='warning'>This will only work on normal organic beings.</span>")
		return

	if(COLDRES in C.mutations)
		C.visible_message("<span class='warning'>A cloud of fine ice crystals engulfs [C.name], but disappears almost instantly!</span>")
		return
	var/handle_suit = 0
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.head, /obj/item/clothing/head/helmet/space))
			if(istype(H.wear_suit, /obj/item/clothing/suit/space))
				handle_suit = 1
				if(H.internal)
					H.visible_message("<span class='warning'>[user] sprays a cloud of fine ice crystals, engulfing [H]!</span>",
										"<span class='notice'>[user] sprays a cloud of fine ice crystals over your [H.head]'s visor.</span>")
					add_attack_logs(user, C, "Cryokinesis")
				else
					H.visible_message("<span class='warning'>[user] sprays a cloud of fine ice crystals engulfing, [H]!</span>",
										"<span class='warning'>[user] sprays a cloud of fine ice crystals cover your [H.head]'s visor and make it into your air vents!.</span>")
					add_attack_logs(user, C, "Cryokinesis")
					H.bodytemperature = max(0, H.bodytemperature - 100)
	if(!handle_suit)
		C.bodytemperature = max(0, C.bodytemperature - 200)
		C.ExtinguishMob()

		C.visible_message("<span class='warning'>[user] sprays a cloud of fine ice crystals, engulfing [C]!</span>")
		add_attack_logs(user, C, "Cryokinesis- NO SUIT/INTERNALS")

	//playsound(user.loc, 'bamf.ogg', 50, 0)

	new/obj/effect/self_deleting(C.loc, icon('icons/effects/genetics.dmi', "cryokinesis"))

	return

/obj/effect/self_deleting
	density = 0
	opacity = 0
	anchored = 1
	icon = null
	desc = ""
	//layer = 15

/obj/effect/self_deleting/New(var/atom/location, var/icon/I, var/duration = 20, var/oname = "something")
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
	instability = GENE_INSTABILITY_MINOR
	mutation = EATER

	spelltype=/obj/effect/proc_holder/spell/targeted/eat

/datum/dna/gene/basic/grant_spell/mattereater/New()
	..()
	block = GLOB.eatblock

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
		/mob/living/simple_animal/slime,
		/mob/living/carbon/alien/larva,
		/mob/living/simple_animal/slime,
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/lizard,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/spiderbot
	)
	var/list/own_blacklist = list(
		/obj/item/organ,
		/obj/item/implant
	)

/obj/effect/proc_holder/spell/targeted/eat/proc/doHeal(var/mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/name in H.bodyparts_by_name)
			var/obj/item/organ/external/affecting = null
			if(!H.bodyparts_by_name[name])
				continue
			affecting = H.bodyparts_by_name[name]
			if(!istype(affecting, /obj/item/organ/external))
				continue
			affecting.heal_damage(4, 0, updating_health = FALSE)
		H.UpdateDamageIcon()
		H.updatehealth()

/obj/effect/proc_holder/spell/targeted/eat/choose_targets(mob/user = usr)
	var/list/targets = new /list()
	var/list/possible_targets = new /list()

	if(!check_mouth(user))
		revert_cast(user)
		return

	for(var/atom/movable/O in view_or_range(range, user, selection_type))
		if((O in user) && is_type_in_list(O,own_blacklist))
			continue
		if(is_type_in_list(O,types_allowed))
			if(isanimal(O))
				var/mob/living/simple_animal/SA = O
				if(!SA.gold_core_spawnable)
					continue
			possible_targets += O

	targets += input("Choose the target of your hunger.", "Targeting") as null|anything in possible_targets

	if(!targets.len || !targets[1]) //doesn't waste the spell
		revert_cast(user)
		return

	if(!check_mouth(user))
		revert_cast(user)
		return

	perform(targets, user = user)

/obj/effect/proc_holder/spell/targeted/eat/proc/check_mouth(mob/user = usr)
	var/can_eat = 1
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if((C.head && (C.head.flags_cover & HEADCOVERSMOUTH)) || (C.wear_mask && (C.wear_mask.flags_cover & MASKCOVERSMOUTH) && !C.wear_mask.mask_adjusted))
			to_chat(C, "<span class='warning'>Your mouth is covered, preventing you from eating!</span>")
			can_eat = 0
	return can_eat

/obj/effect/proc_holder/spell/targeted/eat/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/atom/movable/the_item = targets[1]
	if(ishuman(the_item))
		var/mob/living/carbon/human/H = the_item
		var/obj/item/organ/external/limb = H.get_organ(user.zone_selected)
		if(!istype(limb))
			to_chat(user, "<span class='warning'>You can't eat this part of them!</span>")
			revert_cast()
			return 0
		if(istype(limb,/obj/item/organ/external/head))
			// Bullshit, but prevents being unable to clone someone.
			to_chat(user, "<span class='warning'>You try to put \the [limb] in your mouth, but [the_item.p_their()] ears tickle your throat!</span>")
			revert_cast()
			return 0
		if(istype(limb,/obj/item/organ/external/chest))
			// Bullshit, but prevents being able to instagib someone.
			to_chat(user, "<span class='warning'>You try to put [the_item.p_their()] [limb] in your mouth, but it's too big to fit!</span>")
			revert_cast()
			return 0
		user.visible_message("<span class='danger'>[user] begins stuffing [the_item]'s [limb.name] into [user.p_their()] gaping maw!</span>")
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
			limb.droplimb(0, DROPLIMB_SHARP)
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
	instability = GENE_INSTABILITY_MINOR
	mutation = JUMPY

	spelltype =/obj/effect/proc_holder/spell/targeted/leap

/datum/dna/gene/basic/grant_spell/jumpy/New()
	..()
	block = GLOB.jumpblock

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

/obj/effect/proc_holder/spell/targeted/leap/cast(list/targets, mob/user = usr)
	var/failure = 0
	if(istype(user.loc,/mob/) || user.lying || user.stunned || user.buckled || user.stat)
		to_chat(user, "<span class='warning'>You can't jump right now!</span>")
		return

	if(istype(user.loc,/turf/))
		if(user.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(user, 1))
				if(M.pulling == user)
					if(!M.restrained() && M.stat == 0 && M.canmove && user.Adjacent(M))
						failure = 1
					else
						M.stop_pulling()

		user.visible_message("<span class='danger'>[user.name]</b> takes a huge leap!</span>")
		playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
		if(failure)
			user.Weaken(5)
			user.Stun(5)
			user.visible_message("<span class='warning'>[user] attempts to leap away but is slammed back down to the ground!</span>",
								"<span class='warning'>You attempt to leap away but are suddenly slammed back down to the ground!</span>",
								"<span class='notice'>You hear the flexing of powerful muscles and suddenly a crash as a body hits the floor.</span>")
			return 0
		var/prevLayer = user.layer
		var/prevFlying = user.flying
		user.layer = 9

		user.flying = 1
		for(var/i=0, i<10, i++)
			step(user, user.dir)
			if(i < 5) user.pixel_y += 8
			else user.pixel_y -= 8
			sleep(1)
		user.flying = prevFlying

		if(FAT in user.mutations && prob(66))
			user.visible_message("<span class='danger'>[user.name]</b> crashes due to [user.p_their()] heavy weight!</span>")
			//playsound(user.loc, 'zhit.wav', 50, 1)
			user.AdjustWeakened(10)
			user.AdjustStunned(5)

		user.layer = prevLayer

	if(istype(user.loc,/obj/))
		var/obj/container = user.loc
		to_chat(user, "<span class='warning'>You leap and slam your head against the inside of [container]! Ouch!</span>")
		user.AdjustParalysis(3)
		user.AdjustWeakened(5)
		container.visible_message("<span class='danger'>[user.loc]</b> emits a loud thump and rattles a bit.</span>")
		playsound(user.loc, 'sound/effects/bang.ogg', 50, 1)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/polymorphism

/datum/dna/gene/basic/grant_spell/polymorph
	name = "Polymorphism"
	desc = "Enables the subject to reconfigure their appearance to mimic that of others."

	spelltype =/obj/effect/proc_holder/spell/targeted/polymorph
	//cooldown = 1800
	activation_messages = list("You don't feel entirely like yourself somehow.")
	deactivation_messages = list("You feel secure in your identity.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = POLYMORPH

/datum/dna/gene/basic/grant_spell/polymorph/New()
	..()
	block = GLOB.polymorphblock

/obj/effect/proc_holder/spell/targeted/polymorph
	name = "Polymorph"
	desc = "Mimic the appearance of others!"
	panel = "Abilities"
	charge_max = 1800

	clothes_req = 0
	human_req = 1
	stat_allowed = 0
	invocation_type = "none"
	range = 1
	selection_type = "range"

	action_icon_state = "genetic_poly"

/obj/effect/proc_holder/spell/targeted/polymorph/cast(list/targets, mob/user = usr)
	var/mob/living/M = targets[1]
	if(!ishuman(M))
		to_chat(usr, "<span class='warning'>You can only change your appearance to that of another human.</span>")
		return

	user.visible_message("<span class='warning'>[user]'s body shifts and contorts.</span>")

	spawn(10)
		if(M && user)
			playsound(user.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
			var/mob/living/carbon/human/H = user
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
	instability = GENE_INSTABILITY_MINOR
	mutation=EMPATH

/datum/dna/gene/basic/grant_spell/empath/New()
	..()
	block = GLOB.empathblock

/obj/effect/proc_holder/spell/targeted/empath
	name = "Read Mind"
	desc = "Read the minds of others for information."
	charge_max = 180
	clothes_req = 0
	human_req = 1
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

	perform(targets, user = user)

/obj/effect/proc_holder/spell/targeted/empath/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/M in targets)
		if(!iscarbon(M))
			to_chat(user, "<span class='warning'>You may only use this on other organic beings.</span>")
			return

		if(PSY_RESIST in M.mutations)
			to_chat(user, "<span class='warning'>You can't see into [M.name]'s mind at all!</span>")
			return

		if(M.stat == 2)
			to_chat(user, "<span class='warning'>[M.name] is dead and cannot have [M.p_their()] mind read.</span>")
			return
		if(M.health < 0)
			to_chat(user, "<span class='warning'>[M.name] is dying, and [M.p_their()] thoughts are too scrambled to read.</span>")
			return

		to_chat(user, "<span class='notice'>Mind Reading of <b>[M.name]:</b></span>")

		var/pain_condition = M.health / M.maxHealth
		// lower health means more pain
		var/list/randomthoughts = list("what to have for lunch","the future","the past","money",
		"[M.p_their()] hair","what to do next","[M.p_their()] job","space","amusing things","sad things",
		"annoying things","happy things","something incoherent","something [M.p_they()] did wrong")
		var/thoughts = "thinking about [pick(randomthoughts)]"

		if(M.fire_stacks)
			pain_condition -= 0.5
			thoughts = "preoccupied with the fire"

		if(M.radiation)
			pain_condition -= 0.25

		switch(pain_condition)
			if(0.81 to INFINITY)
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] feels good.</span>")
			if(0.61 to 0.8)
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] is suffering mild pain.</span>")
			if(0.41 to 0.6)
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] is suffering significant pain.</span>")
			if(0.21 to 0.4)
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] is suffering severe pain.</span>")
			else
				to_chat(user, "<span class='notice'><b>Condition</b>: [M.name] is suffering excruciating pain.</span>")
				thoughts = "haunted by [M.p_their()] own mortality"

		switch(M.a_intent)
			if(INTENT_HELP)
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense benevolent thoughts from [M.name].</span>")
			if(INTENT_DISARM)
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense cautious thoughts from [M.name].</span>")
			if(INTENT_GRAB)
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense hostile thoughts from [M.name].</span>")
			if(INTENT_HARM)
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense cruel thoughts from [M.name].</span>")
				for(var/mob/living/L in view(7,M))
					if(L == M)
						continue
					thoughts = "thinking about punching [L.name]"
					break
			else
				to_chat(user, "<span class='notice'><b>Mood</b>: You sense strange thoughts from [M.name].</span>")

		if(istype(M,/mob/living/carbon/human))
			var/numbers[0]
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.initial_account)
				numbers += H.mind.initial_account.account_number
				numbers += H.mind.initial_account.remote_access_pin
			if(numbers.len>0)
				to_chat(user, "<span class='notice'><b>Numbers</b>: You sense the number[numbers.len>1?"s":""] [english_list(numbers)] [numbers.len>1?"are":"is"] important to [M.name].</span>")
		to_chat(user, "<span class='notice'><b>Thoughts</b>: [M.name] is currently [thoughts].</span>")

		if(EMPATH in M.mutations)
			to_chat(M, "<span class='warning'>You sense [user.name] reading your mind.</span>")
		else if(prob(5) || M.mind.assigned_role=="Chaplain")
			to_chat(M, "<span class='warning'>You sense someone intruding upon your thoughts...</span>")
		return
