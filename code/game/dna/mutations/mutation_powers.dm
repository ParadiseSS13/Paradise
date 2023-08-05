///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/mutation/nobreath
	name = "No Breathing"
	activation_messages = list("You feel no need to breathe.")
	deactivation_messages = list("You feel the need to breathe, once more.")
	instability = GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_NOBREATH)
	activation_prob = 25

/datum/mutation/nobreath/New()
	..()
	block = GLOB.breathlessblock


/datum/mutation/regenerate
	name = "Regenerate"
	activation_messages = list("Your wounds start healing.")
	deactivation_messages = list("Your regenerative powers feel like they've vanished.")
	instability = GENE_INSTABILITY_MINOR

/datum/mutation/regenerate/New()
	..()
	block = GLOB.regenerateblock

/datum/mutation/regenerate/on_life(mob/living/carbon/human/H)
	if(!H.ignore_gene_stability && H.gene_stability < GENETIC_DAMAGE_STAGE_1)
		H.adjustBruteLoss(-0.25, FALSE)
		H.adjustFireLoss(-0.25)
		return
	H.adjustBruteLoss(-1, FALSE)
	H.adjustFireLoss(-1)

/datum/mutation/increaserun
	name = "Super Speed"
	activation_messages = list("You feel swift and unencumbered.")
	deactivation_messages = list("You feel slow.")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_IGNORESLOWDOWN)

/datum/mutation/increaserun/New()
	..()
	block = GLOB.increaserunblock

/datum/mutation/increaserun/can_activate(mob/M, flags)
	if(!..())
		return FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species && H.dna.species.speed_mod && !(flags & MUTCHK_FORCED))
			return FALSE
	return TRUE

/datum/mutation/heat_resist
	name = "Heat Resistance"
	activation_messages = list("Your skin is icy to the touch.")
	deactivation_messages = list("Your skin no longer feels icy to the touch.")
	instability = GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_RESISTHEAT, TRAIT_RESISTHIGHPRESSURE)

/datum/mutation/heat_resist/New()
	..()
	block = GLOB.coldblock

/datum/mutation/heat_resist/on_draw_underlays(mob/M, g)
	return "cold_s"

/datum/mutation/cold_resist
	name = "Cold Resistance"
	activation_messages = list("Your body is filled with warmth.")
	deactivation_messages = list("Your body is no longer filled with warmth.")
	instability = GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE)

/datum/mutation/cold_resist/New()
	..()
	block = GLOB.fireblock

/datum/mutation/cold_resist/on_draw_underlays(mob/M, g)
	return "fire_s"

/datum/mutation/noprints
	name = "No Prints"
	activation_messages = list("Your fingers feel numb.")
	deactivation_messages = list("Your fingers no longer feel numb.")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_NOFINGERPRINTS)

/datum/mutation/noprints/New()
	..()
	block = GLOB.noprintsblock

/datum/mutation/noshock
	name = "Shock Immunity"
	activation_messages = list("Your skin feels dry and unreactive.")
	deactivation_messages = list("Your skin no longer feels dry and unreactive.")
	instability = GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_SHOCKIMMUNE)

/datum/mutation/noshock/New()
	..()
	block = GLOB.shockimmunityblock

/datum/mutation/midget
	name = "Midget"
	activation_messages = list("Everything around you seems bigger now...")
	deactivation_messages = list("Everything around you seems to shrink...")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_DWARF)

/datum/mutation/midget/New()
	..()
	block = GLOB.smallsizeblock

/datum/mutation/midget/activate(mob/M)
	..()
	M.pass_flags |= PASSTABLE
	M.resize = 0.8
	M.update_transform()

/datum/mutation/midget/deactivate(mob/M)
	..()
	M.pass_flags &= ~PASSTABLE
	M.resize = 1.25
	M.update_transform()

// OLD HULK BEHAVIOR
/datum/mutation/hulk
	name = "Hulk"
	activation_messages = list("Your muscles hurt.")
	deactivation_messages = list("Your muscles shrink.")
	instability = GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_HULK, TRAIT_CHUNKYFINGERS)
	activation_prob = 15

/datum/mutation/hulk/New()
	..()
	block = GLOB.hulkblock

/datum/mutation/hulk/activate(mob/living/carbon/human/M)
	..()
	var/status = CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH
	M.status_flags &= ~status
	M.update_body()

/datum/mutation/hulk/deactivate(mob/living/carbon/human/M)
	..()
	M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH
	M.update_body()

/datum/mutation/hulk/on_life(mob/living/carbon/human/M)
	if(!istype(M))
		return
	if(M.health <= 0)
		M.dna.SetSEState(GLOB.hulkblock, 0)
		singlemutcheck(M, GLOB.hulkblock, MUTCHK_FORCED)
		M.update_mutations()		//update our mutation overlays
		M.update_body()
		M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH //temporary fix until the problem can be solved.
		to_chat(M, "<span class='danger'>You suddenly feel very weak.</span>")

/datum/mutation/tk
	name = "Telekenesis"
	activation_messages = list("You feel smarter.")
	deactivation_messages = list("You feel dumber.")
	instability = GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_TELEKINESIS)
	activation_prob = 15

/datum/mutation/tk/New()
	..()
	block = GLOB.teleblock

/datum/mutation/tk/on_draw_underlays(mob/M, g)
	return "telekinesishead_s"

#define EAT_MOB_DELAY 300 // 30s

// WAS: /datum/bioEffect/alcres
/datum/mutation/sober
	name = "Sober"
	activation_messages = list("You feel unusually sober.")
	deactivation_messages = list("You feel like you could use a stiff drink.")

	traits_to_add = list(TRAIT_ALCOHOL_TOLERANCE)

/datum/mutation/sober/New()
	..()
	block = GLOB.soberblock

//WAS: /datum/bioEffect/psychic_resist
/datum/mutation/psychic_resist
	name = "Psy-Resist"
	desc = "Boosts efficiency in sectors of the brain commonly associated with meta-mental energies."
	activation_messages = list("Your mind feels closed.")
	deactivation_messages = list("You feel oddly exposed.")

/datum/mutation/psychic_resist/New()
	..()
	block = GLOB.psyresistblock

/////////////////////////
// Stealth Enhancers
/////////////////////////

/datum/mutation/stealth
	instability = GENE_INSTABILITY_MODERATE

/datum/mutation/stealth/can_activate(mob/M, flags)
	// Can only activate one of these at a time.
	if(is_type_in_list(/datum/mutation/stealth, M.active_mutations))
		testing("Cannot activate [type]: /datum/mutation/stealth in M.active_mutations.")
		return FALSE
	return ..()

/datum/mutation/stealth/deactivate(mob/living/M)
	..()
	M.reset_visibility()

// WAS: /datum/bioEffect/darkcloak
/datum/mutation/stealth/darkcloak
	name = "Cloak of Darkness"
	desc = "Enables the subject to bend low levels of light around themselves, creating a cloaking effect."
	activation_messages = list("You begin to fade into the shadows.")
	deactivation_messages = list("You become fully visible.")
	activation_prob = 25

/datum/mutation/stealth/darkcloak/New()
	..()
	block = GLOB.shadowblock

/datum/mutation/stealth/darkcloak/on_life(mob/M)
	var/turf/simulated/T = get_turf(M)
	if(!istype(T))
		return
	var/light_available = T.get_lumcount() * 10
	if(light_available <= 2)
		if(M.invisibility != INVISIBILITY_LEVEL_TWO)
			M.alpha = round(M.alpha * 0.8)
	else
		M.reset_visibility()
		M.alpha = round(255 * 0.8)
	if(M.alpha == 0)
		M.make_invisible()

//WAS: /datum/bioEffect/chameleon
/datum/mutation/stealth/chameleon
	name = "Chameleon"
	desc = "The subject becomes able to subtly alter light patterns to become invisible, as long as they remain still."
	activation_messages = list("You feel one with your surroundings.")
	deactivation_messages = list("You feel oddly visible.")
	activation_prob = 25

/datum/mutation/stealth/chameleon/New()
	..()
	block = GLOB.chameleonblock

/datum/mutation/stealth/chameleon/on_life(mob/living/M) //look if a ghost gets this, its an admins problem
	if((world.time - M.last_movement) >= 30 && !M.stat && (M.mobility_flags & MOBILITY_STAND) && !M.restrained())
		if(M.invisibility != INVISIBILITY_LEVEL_TWO)
			M.alpha -= 25
	else
		M.reset_visibility()
		M.alpha = round(255 * 0.80)
	if(M.alpha == 0)
		M.make_invisible()

/////////////////////////////////////////////////////////////////////////////////////////

/datum/mutation/grant_spell
	var/obj/effect/proc_holder/spell/spelltype

/datum/mutation/grant_spell/activate(mob/M)
	M.AddSpell(new spelltype(null))
	..()
	return TRUE

/datum/mutation/grant_spell/deactivate(mob/M)
	for(var/obj/effect/proc_holder/spell/S in M.mob_spell_list)
		if(istype(S, spelltype))
			M.RemoveSpell(S)
	..()
	return TRUE

// WAS: /datum/bioEffect/cryokinesis
/datum/mutation/grant_spell/cryo
	name = "Cryokinesis"
	desc = "Allows the subject to lower the body temperature of others."
	activation_messages = list("You notice a strange cold tingle in your fingertips.")
	deactivation_messages = list("Your fingers feel warmer.")
	instability = GENE_INSTABILITY_MODERATE
	spelltype = /obj/effect/proc_holder/spell/cryokinesis

/datum/mutation/grant_spell/cryo/New()
	..()
	block = GLOB.cryoblock

/obj/effect/proc_holder/spell/cryokinesis
	name = "Cryokinesis"
	desc = "Drops the bodytemperature of another person."
	panel = "Abilities"

	base_cooldown = 1200

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	selection_activated_message		= "<span class='notice'>Your mind grow cold. Click on a target to cast the spell.</span>"
	selection_deactivated_message	= "<span class='notice'>Your mind returns to normal.</span>"
	invocation_type = "none"
	var/list/compatible_mobs = list(/mob/living/carbon/human)

	action_icon_state = "genetic_cryo"

/obj/effect/proc_holder/spell/cryokinesis/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /mob/living/carbon
	T.click_radius = 0
	T.try_auto_target = FALSE // Give the clueless geneticists a way out and to have them not target themselves
	T.selection_type = SPELL_SELECTION_RANGE
	T.include_user = TRUE
	return T

/obj/effect/proc_holder/spell/cryokinesis/cast(list/targets, mob/user = usr)

	var/mob/living/carbon/C = targets[1]

	if(HAS_TRAIT(C, TRAIT_RESISTCOLD))
		C.visible_message("<span class='warning'>A cloud of fine ice crystals engulfs [C.name], but disappears almost instantly!</span>")
		return
	var/handle_suit = FALSE
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.head, /obj/item/clothing/head/helmet/space))
			if(istype(H.wear_suit, /obj/item/clothing/suit/space))
				handle_suit = TRUE
				if(H.internal)
					H.visible_message("<span class='warning'>[user] sprays a cloud of fine ice crystals, engulfing [H]!</span>",
										"<span class='notice'>[user] sprays a cloud of fine ice crystals over your [H.head]'s visor.</span>")
				else
					H.visible_message("<span class='warning'>[user] sprays a cloud of fine ice crystals engulfing, [H]!</span>",
										"<span class='warning'>[user] sprays a cloud of fine ice crystals cover your [H.head]'s visor and make it into your air vents!.</span>")

					H.bodytemperature = max(0, H.bodytemperature - 100)
				add_attack_logs(user, C, "Cryokinesis")
	if(!handle_suit)
		C.bodytemperature = max(0, C.bodytemperature - 200)
		C.ExtinguishMob()

		C.visible_message("<span class='warning'>[user] sprays a cloud of fine ice crystals, engulfing [C]!</span>")
		add_attack_logs(user, C, "Cryokinesis- NO SUIT/INTERNALS")

///////////////////////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/mattereater
/datum/mutation/grant_spell/mattereater
	name = "Matter Eater"
	desc = "Allows the subject to eat just about anything without harm."
	activation_messages = list("You feel hungry.")
	deactivation_messages = list("You don't feel quite so hungry anymore.")
	instability = GENE_INSTABILITY_MINOR

	spelltype=/obj/effect/proc_holder/spell/eat

/datum/mutation/grant_spell/mattereater/New()
	..()
	block = GLOB.eatblock

/obj/effect/proc_holder/spell/eat
	name = "Eat"
	desc = "Eat just about anything!"
	panel = "Abilities"

	base_cooldown = 300

	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"

	action_icon_state = "genetic_eat"

/obj/effect/proc_holder/spell/eat/create_new_targeting()
	return new /datum/spell_targeting/matter_eater

/obj/effect/proc_holder/spell/eat/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	. = ..()
	if(!.)
		return
	var/can_eat = TRUE
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if((C.head && (C.head.flags_cover & HEADCOVERSMOUTH)) || (C.wear_mask && (C.wear_mask.flags_cover & MASKCOVERSMOUTH) && !C.wear_mask.up))
			if(show_message)
				to_chat(C, "<span class='warning'>Your mouth is covered, preventing you from eating!</span>")
			can_eat = FALSE
	return can_eat

/obj/effect/proc_holder/spell/eat/proc/doHeal(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/name in H.bodyparts_by_name)
			var/obj/item/organ/external/affecting = null
			if(!H.bodyparts_by_name[name])
				continue
			affecting = H.bodyparts_by_name[name]
			if(!isorgan(affecting))
				continue
			affecting.heal_damage(4, 0, updating_health = FALSE)
		H.UpdateDamageIcon()
		H.updatehealth()



/obj/effect/proc_holder/spell/eat/cast(list/targets, mob/user = usr)
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
			return FALSE
		if(istype(limb,/obj/item/organ/external/head))
			// Bullshit, but prevents being unable to clone someone.
			to_chat(user, "<span class='warning'>You try to put \the [limb] in your mouth, but [the_item.p_their()] ears tickle your throat!</span>")
			revert_cast()
			return FALSE
		if(istype(limb,/obj/item/organ/external/chest))
			// Bullshit, but prevents being able to instagib someone.
			to_chat(user, "<span class='warning'>You try to put [the_item.p_their()] [limb] in your mouth, but it's too big to fit!</span>")
			revert_cast()
			return FALSE
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

////////////////////////////////////////////////////////////////////////

//WAS: /datum/bioEffect/jumpy
/datum/mutation/grant_spell/jumpy
	name = "Jumpy"
	desc = "Allows the subject to leap great distances."
	//cooldown = 30
	activation_messages = list("Your leg muscles feel taut and strong.")
	deactivation_messages = list("Your leg muscles shrink back to normal.")
	instability = GENE_INSTABILITY_MINOR

	spelltype =/obj/effect/proc_holder/spell/leap

/datum/mutation/grant_spell/jumpy/New()
	..()
	block = GLOB.jumpblock

/obj/effect/proc_holder/spell/leap
	name = "Jump"
	desc = "Leap great distances!"
	panel = "Abilities"

	base_cooldown = 60

	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"

	action_icon_state = "genetic_jump"

/obj/effect/proc_holder/spell/leap/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/leap/cast(list/targets, mob/living/user = usr)
	var/failure = FALSE
	if(ismob(user.loc) || IS_HORIZONTAL(user) || user.IsStunned() || user.buckled || user.stat)
		to_chat(user, "<span class='warning'>You can't jump right now!</span>")
		return

	if(isturf(user.loc))
		if(user.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/living/M in range(user, 1))
				if(M.pulling == user)
					if(!M.restrained() && M.stat == 0 && !(M.mobility_flags & MOBILITY_STAND) && user.Adjacent(M))
						failure = TRUE
					else
						M.stop_pulling()

		user.visible_message("<span class='danger'>[user.name]</b> takes a huge leap!</span>")
		playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
		if(failure)
			user.Weaken(10 SECONDS)
			user.visible_message("<span class='warning'>[user] attempts to leap away but is slammed back down to the ground!</span>",
								"<span class='warning'>You attempt to leap away but are suddenly slammed back down to the ground!</span>",
								"<span class='notice'>You hear the flexing of powerful muscles and suddenly a crash as a body hits the floor.</span>")
			return FALSE
		var/prevLayer = user.layer
		var/prevFlying = user.flying
		user.layer = 9

		user.flying = TRUE
		for(var/i=0, i<10, i++)
			step(user, user.dir)
			if(i < 5) user.pixel_y += 8
			else user.pixel_y -= 8
			sleep(1)
		user.flying = prevFlying

		if(HAS_TRAIT(user, TRAIT_FAT) && prob(66))
			user.visible_message("<span class='danger'>[user.name]</b> crashes due to [user.p_their()] heavy weight!</span>")
			//playsound(user.loc, 'zhit.wav', 50, 1)
			user.AdjustWeakened(20 SECONDS)
			user.AdjustStunned(10 SECONDS)

		user.layer = prevLayer

	if(isobj(user.loc))
		var/obj/container = user.loc
		to_chat(user, "<span class='warning'>You leap and slam your head against the inside of [container]! Ouch!</span>")
		user.AdjustParalysis(6 SECONDS)
		user.AdjustWeakened(10 SECONDS)
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

/datum/mutation/grant_spell/polymorph
	name = "Polymorphism"
	desc = "Enables the subject to reconfigure their appearance to mimic that of others."

	spelltype =/obj/effect/proc_holder/spell/polymorph
	//cooldown = 1800
	activation_messages = list("You don't feel entirely like yourself somehow.")
	deactivation_messages = list("You feel secure in your identity.")
	instability = GENE_INSTABILITY_MODERATE

/datum/mutation/grant_spell/polymorph/New()
	..()
	block = GLOB.polymorphblock

/obj/effect/proc_holder/spell/polymorph
	name = "Polymorph"
	desc = "Mimic the appearance of others!"
	panel = "Abilities"
	base_cooldown = 1800

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	selection_activated_message		= "<span class='notice'>You body becomes unstable. Click on a target to cast transform into them.</span>"
	selection_deactivated_message	= "<span class='notice'>Your body calms down again.</span>"

	invocation_type = "none"

	action_icon_state = "genetic_poly"

/obj/effect/proc_holder/spell/polymorph/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.try_auto_target = FALSE
	T.click_radius = -1
	T.range = 1
	T.selection_type = SPELL_SELECTION_RANGE
	return T

/obj/effect/proc_holder/spell/polymorph/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	user.visible_message("<span class='warning'>[user]'s body shifts and contorts.</span>")

	spawn(10)
		if(target && user)
			playsound(user.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
			var/mob/living/carbon/human/H = user
			H.UpdateAppearance(target.dna.UI)
			H.real_name = target.real_name
			H.name = target.name

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/empath
/datum/mutation/grant_spell/empath
	name = "Empathic Thought"
	desc = "The subject becomes able to read the minds of others for certain information."

	spelltype = /obj/effect/proc_holder/spell/empath
	activation_messages = list("You suddenly notice more about others than you did before.")
	deactivation_messages = list("You no longer feel able to sense intentions.")
	instability = GENE_INSTABILITY_MINOR

/datum/mutation/grant_spell/empath/New()
	..()
	block = GLOB.empathblock

/obj/effect/proc_holder/spell/empath
	name = "Read Mind"
	desc = "Read the minds of others for information."
	base_cooldown = 180
	clothes_req = FALSE
	human_req = TRUE
	stat_allowed = CONSCIOUS
	invocation_type = "none"

	action_icon_state = "genetic_empath"

/obj/effect/proc_holder/spell/empath/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living/carbon
	T.selection_type = SPELL_SELECTION_RANGE
	return T

/obj/effect/proc_holder/spell/empath/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/M in targets)
		if(!iscarbon(M))
			to_chat(user, "<span class='warning'>You may only use this on other organic beings.</span>")
			return

		if(M.dna?.GetSEState(GLOB.psyresistblock))
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

		if(ishuman(M))
			var/numbers[0]
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.initial_account)
				numbers += H.mind.initial_account.account_number
				numbers += H.mind.initial_account.account_pin
			if(numbers.len>0)
				to_chat(user, "<span class='notice'><b>Numbers</b>: You sense the number[numbers.len>1?"s":""] [english_list(numbers)] [numbers.len>1?"are":"is"] important to [M.name].</span>")
		to_chat(user, "<span class='notice'><b>Thoughts</b>: [M.name] is currently [thoughts].</span>")

		if(M.dna?.GetSEState(GLOB.empathblock))
			to_chat(M, "<span class='warning'>You sense [user.name] reading your mind.</span>")
		else if(prob(5) || M.mind?.assigned_role=="Chaplain")
			to_chat(M, "<span class='warning'>You sense someone intruding upon your thoughts...</span>")

///////////////////Vanilla Morph////////////////////////////////////

/datum/mutation/grant_spell/morph
	name = "Morphism"
	desc = "Enables the subject to reconfigure their appearance to that of any human."
	spelltype =/obj/effect/proc_holder/spell/morph
	activation_messages = list("Your body feels like it can alter its appearance.")
	deactivation_messages = list("Your body doesn't feel capable of altering its appearance.")
	instability = GENE_INSTABILITY_MINOR

/datum/mutation/grant_spell/morph/New()
	..()
	block = GLOB.morphblock

/obj/effect/proc_holder/spell/morph
	name = "Morph"
	desc = "Mimic the appearance of your choice!"
	panel = "Abilities"
	base_cooldown = 1800

	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"

	action_icon_state = "genetic_morph"

/obj/effect/proc_holder/spell/morph/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/morph/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return

	if(ismob(user.loc))
		to_chat(user, "<span class='warning'>You can't change your appearance right now!</span>")
		return
	var/mob/living/carbon/human/M = user
	var/obj/item/organ/external/head/head_organ = M.get_organ("head")
	var/obj/item/organ/internal/eyes/eyes_organ = M.get_int_organ(/obj/item/organ/internal/eyes)

	var/new_gender = alert(user, "Please select gender.", "Character Generation", "Male", "Female")
	if(new_gender)
		if(new_gender == "Male")
			M.change_gender(MALE)
		else
			M.change_gender(FEMALE)

	if(eyes_organ)
		var/new_eyes = input("Please select eye color.", "Character Generation", eyes_organ.eye_color) as null|color
		if(new_eyes)
			M.change_eye_color(new_eyes)

	if(istype(head_organ))
		//Alt heads.
		if(head_organ.dna.species.bodyflags & HAS_ALT_HEADS)
			var/list/valid_alt_heads = M.generate_valid_alt_heads()
			var/new_alt_head = input("Please select alternate head", "Character Generation", head_organ.alt_head) as null|anything in valid_alt_heads
			if(new_alt_head)
				M.change_alt_head(new_alt_head)

		// hair
		var/list/valid_hairstyles = M.generate_valid_hairstyles()
		var/new_style = input("Please select hair style", "Character Generation", head_organ.h_style) as null|anything in valid_hairstyles

		// if new style selected (not cancel)
		if(new_style)
			M.change_hair(new_style)

		var/new_hair = input("Please select hair color.", "Character Generation", head_organ.hair_colour) as null|color
		if(new_hair)
			M.change_hair_color(new_hair)

		var/datum/sprite_accessory/hair_style = GLOB.hair_styles_public_list[head_organ.h_style]
		if(hair_style.secondary_theme && !hair_style.no_sec_colour)
			new_hair = input("Please select secondary hair color.", "Character Generation", head_organ.sec_hair_colour) as null|color
			if(new_hair)
				M.change_hair_color(new_hair, TRUE)

		// facial hair
		var/list/valid_facial_hairstyles = M.generate_valid_facial_hairstyles()
		new_style = input("Please select facial style", "Character Generation", head_organ.f_style) as null|anything in valid_facial_hairstyles

		if(new_style)
			M.change_facial_hair(new_style)

		var/new_facial = input("Please select facial hair color.", "Character Generation", head_organ.facial_colour) as null|color
		if(new_facial)
			M.change_facial_hair_color(new_facial)

		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[head_organ.f_style]
		if(facial_hair_style.secondary_theme && !facial_hair_style.no_sec_colour)
			new_facial = input("Please select secondary facial hair color.", "Character Generation", head_organ.sec_facial_colour) as null|color
			if(new_facial)
				M.change_facial_hair_color(new_facial, TRUE)

		//Head accessory.
		if(head_organ.dna.species.bodyflags & HAS_HEAD_ACCESSORY)
			var/list/valid_head_accessories = M.generate_valid_head_accessories()
			var/new_head_accessory = input("Please select head accessory style", "Character Generation", head_organ.ha_style) as null|anything in valid_head_accessories
			if(new_head_accessory)
				M.change_head_accessory(new_head_accessory)

			var/new_head_accessory_colour = input("Please select head accessory colour.", "Character Generation", head_organ.headacc_colour) as null|color
			if(new_head_accessory_colour)
				M.change_head_accessory_color(new_head_accessory_colour)


	//Body accessory.
	if((M.dna.species.tail && M.dna.species.bodyflags & (HAS_TAIL)) || (M.dna.species.wing && M.dna.species.bodyflags & (HAS_WING)))
		var/list/valid_body_accessories = M.generate_valid_body_accessories()
		if(valid_body_accessories.len > 1) //By default valid_body_accessories will always have at the very least a 'none' entry populating the list, even if the user's species is not present in any of the list items.
			var/new_body_accessory = input("Please select body accessory style", "Character Generation", M.body_accessory) as null|anything in valid_body_accessories
			if(new_body_accessory)
				M.change_body_accessory(new_body_accessory)

	if(istype(head_organ))
		//Head markings.
		if(M.dna.species.bodyflags & HAS_HEAD_MARKINGS)
			var/list/valid_head_markings = M.generate_valid_markings("head")
			var/new_marking = input("Please select head marking style", "Character Generation", M.m_styles["head"]) as null|anything in valid_head_markings
			if(new_marking)
				M.change_markings(new_marking, "head")

			var/new_marking_colour = input("Please select head marking colour.", "Character Generation", M.m_colours["head"]) as null|color
			if(new_marking_colour)
				M.change_marking_color(new_marking_colour, "head")

	//Body markings.
	if(M.dna.species.bodyflags & HAS_BODY_MARKINGS)
		var/list/valid_body_markings = M.generate_valid_markings("body")
		var/new_marking = input("Please select body marking style", "Character Generation", M.m_styles["body"]) as null|anything in valid_body_markings
		if(new_marking)
			M.change_markings(new_marking, "body")

		var/new_marking_colour = input("Please select body marking colour.", "Character Generation", M.m_colours["body"]) as null|color
		if(new_marking_colour)
			M.change_marking_color(new_marking_colour, "body")
	//Tail markings.
	if(M.dna.species.bodyflags & HAS_TAIL_MARKINGS)
		var/list/valid_tail_markings = M.generate_valid_markings("tail")
		var/new_marking = input("Please select tail marking style", "Character Generation", M.m_styles["tail"]) as null|anything in valid_tail_markings
		if(new_marking)
			M.change_markings(new_marking, "tail")

		var/new_marking_colour = input("Please select tail marking colour.", "Character Generation", M.m_colours["tail"]) as null|color
		if(new_marking_colour)
			M.change_marking_color(new_marking_colour, "tail")

	//Skin tone.
	if(M.dna.species.bodyflags & HAS_SKIN_TONE)
		var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation", M.s_tone) as null|text
		if(!new_tone)
			new_tone = 35
		else
			new_tone = 35 - max(min(round(text2num(new_tone)), 220), 1)
			M.change_skin_tone(new_tone)

	if(M.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/prompt = "Please select skin tone: 1-[M.dna.species.icon_skin_tones.len] ("
		for(var/i = 1 to M.dna.species.icon_skin_tones.len)
			prompt += "[i] = [M.dna.species.icon_skin_tones[i]]"
			if(i != M.dna.species.icon_skin_tones.len)
				prompt += ", "
		prompt += ")"

		var/new_tone = input(prompt, "Character Generation", M.s_tone) as null|text
		if(!new_tone)
			new_tone = 0
		else
			new_tone = max(min(round(text2num(new_tone)), M.dna.species.icon_skin_tones.len), 1)
			M.change_skin_tone(new_tone)

	//Skin colour.
	if(M.dna.species.bodyflags & HAS_SKIN_COLOR)
		var/new_body_colour = input("Please select body colour.", "Character Generation", M.skin_colour) as null|color
		if(new_body_colour)
			M.change_skin_color(new_body_colour)

	M.update_dna()

	M.visible_message("<span class='notice'>[M] morphs and changes [M.p_their()] appearance!</span>", "<span class='notice'>You change your appearance!</span>", "<span class='warning'>Oh, god!  What the hell was that?  It sounded like flesh getting squished and bone ground into a different shape!</span>")

/datum/mutation/grant_spell/remotetalk
	name = "Telepathy"
	activation_messages = list("You feel you can project your thoughts.")
	deactivation_messages = list("You no longer feel you can project your thoughts.")
	instability = GENE_INSTABILITY_MINOR

	spelltype =/obj/effect/proc_holder/spell/remotetalk

/datum/mutation/grant_spell/remotetalk/New()
	..()
	block = GLOB.remotetalkblock

/datum/mutation/grant_spell/remotetalk/activate(mob/living/M)
	..()
	M.AddSpell(new /obj/effect/proc_holder/spell/mindscan(null))

/datum/mutation/grant_spell/remotetalk/deactivate(mob/user)
	..()
	for(var/obj/effect/proc_holder/spell/S in user.mob_spell_list)
		if(istype(S, /obj/effect/proc_holder/spell/mindscan))
			user.RemoveSpell(S)

/obj/effect/proc_holder/spell/remotetalk
	name = "Project Mind"
	desc = "Make people understand your thoughts!"
	base_cooldown = 0

	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"

	action_icon_state = "genetic_project"

/obj/effect/proc_holder/spell/remotetalk/create_new_targeting()
	return new /datum/spell_targeting/telepathic

/obj/effect/proc_holder/spell/remotetalk/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return
	if(user.mind?.miming) // Dont let mimes telepathically talk
		to_chat(user,"<span class='warning'>You can't communicate without breaking your vow of silence.</span>")
		return
	var/say = input("What do you wish to say") as text|null
	if(!say || usr.stat)
		return
	say = strip_html(say)
	say = pencode_to_html(say, usr, format = 0, fields = 0)

	for(var/mob/living/target in targets)
		log_say("(TPATH to [key_name(target)]) [say]", user)
		user.create_log(SAY_LOG, "Telepathically said '[say]' using [src]", target)
		if(target.dna?.GetSEState(GLOB.remotetalkblock))
			target.show_message("<span class='abductor'>You hear [user.real_name]'s voice: [say]</span>")
		else
			target.show_message("<span class='abductor'>You hear a voice that seems to echo around the room: [say]</span>")
		user.show_message("<span class='abductor'>You project your mind into [(target in user.get_visible_mobs()) ? target.name : "the unknown entity"]: [say]</span>")
		for(var/mob/dead/observer/G in GLOB.player_list)
			G.show_message("<i>Telepathic message from <b>[user]</b> ([ghost_follow_link(user, ghost=G)]) to <b>[target]</b> ([ghost_follow_link(target, ghost=G)]): [say]</i>")

/obj/effect/proc_holder/spell/mindscan
	name = "Scan Mind"
	desc = "Offer people a chance to share their thoughts!"
	base_cooldown = 0
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"
	action_icon_state = "genetic_mindscan"
	var/list/available_targets = list()

/obj/effect/proc_holder/spell/mindscan/create_new_targeting()
	return new /datum/spell_targeting/telepathic

/obj/effect/proc_holder/spell/mindscan/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return
	for(var/mob/living/target in targets)
		var/message = "You feel your mind expand briefly... (Click to send a message.)"
		if(target.dna?.GetSEState(GLOB.remotetalkblock))
			message = "You feel [user.real_name] request a response from you... (Click here to project mind.)"
		user.show_message("<span class='abductor'>You offer your mind to [(target in user.get_visible_mobs()) ? target.name : "the unknown entity"].</span>")
		target.show_message("<span class='abductor'><A href='?src=[UID()];target=[target.UID()];user=[user.UID()]'>[message]</a></span>")
		available_targets += target
		addtimer(CALLBACK(src, PROC_REF(removeAvailability), target), 100)

/obj/effect/proc_holder/spell/mindscan/proc/removeAvailability(mob/living/target)
	if(target in available_targets)
		available_targets -= target
		if(!(target in available_targets))
			target.show_message("<span class='abductor'>You feel the sensation fade...</span>")

/obj/effect/proc_holder/spell/mindscan/Topic(href, href_list)
	var/mob/living/user
	if(href_list["user"])
		user = locateUID(href_list["user"])
	if(href_list["target"])
		if(!user)
			return
		var/mob/living/target = locateUID(href_list["target"])
		if(!(target in available_targets))
			return
		available_targets -= target
		var/say = input("What do you wish to say") as text|null
		if(!say)
			return
		say = strip_html(say)
		say = pencode_to_html(say, target, format = 0, fields = 0)
		user.create_log(SAY_LOG, "Telepathically responded '[say]' using [src]", target)
		log_say("(TPATH to [key_name(target)]) [say]", user)
		if(target.dna?.GetSEState(GLOB.remotetalkblock))
			target.show_message("<span class='abductor'>You project your mind into [user.name]: [say]</span>")
		else
			target.show_message("<span class='abductor'>You fill the space in your thoughts: [say]</span>")
		user.show_message("<span class='abductor'>You hear [target.name]'s voice: [say]</span>")
		for(var/mob/dead/observer/G in GLOB.player_list)
			G.show_message("<i>Telepathic response from <b>[target]</b> ([ghost_follow_link(target, ghost=G)]) to <b>[user]</b> ([ghost_follow_link(user, ghost=G)]): [say]</i>")

/obj/effect/proc_holder/spell/mindscan/Destroy()
	available_targets.Cut()
	return ..()

/datum/mutation/grant_spell/remoteview
	name = "Remote Viewing"
	activation_messages = list("Your mind can see things from afar.")
	deactivation_messages = list("Your mind can no longer can see things from afar.")
	instability = GENE_INSTABILITY_MINOR

	spelltype =/obj/effect/proc_holder/spell/remoteview

/datum/mutation/grant_spell/remoteview/New()
	..()
	block = GLOB.remoteviewblock

/datum/mutation/grant_spell/remoteview/deactivate(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.remoteview_target = null
		H.reset_perspective()

/obj/effect/proc_holder/spell/remoteview
	name = "Remote View"
	desc = "Spy on people from any range!"
	base_cooldown = 100

	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"

	action_icon_state = "genetic_view"

/obj/effect/proc_holder/spell/remoteview/create_new_targeting()
	return new /datum/spell_targeting/remoteview

/obj/effect/proc_holder/spell/remoteview/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H
	if(ishuman(user))
		H = user
	else
		return

	var/mob/target

	if(istype(H.l_hand, /obj/item/tk_grab) || istype(H.r_hand, /obj/item/tk_grab))
		to_chat(H, "<span class='warning'>Your mind is too busy with that telekinetic grab.</span>")
		H.remoteview_target = null
		H.reset_perspective()
		return

	if(H.client.eye != user.client.mob)
		H.remoteview_target = null
		H.reset_perspective()
		return

	for(var/mob/living/L in targets)
		target = L

	if(target)
		H.remoteview_target = target
		H.reset_perspective(target)
	else
		H.remoteview_target = null
		H.reset_perspective()

/datum/mutation/meson_vision
	name = "Meson Vision"
	activation_messages = list("More information seems to reach your eyes...")
	deactivation_messages = list("The amount of information reaching your eyes fades...")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_MESON_VISION)

/datum/mutation/meson_vision/New()
	..()
	block = GLOB.mesonblock

/datum/mutation/meson_vision/activate(mob/living/M)
	..()
	M.update_sight()

/datum/mutation/meson_vision/deactivate(mob/living/M)
	..()
	M.update_sight()

/datum/mutation/night_vision
	name = "Night Vision"
	activation_messages = list("Were the lights always that bright?")
	deactivation_messages = list("The ambient light level returns to normal...")
	instability = GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_NIGHT_VISION)

/datum/mutation/night_vision/New()
	..()
	block = GLOB.nightvisionblock

/datum/mutation/night_vision/activate(mob/living/M)
	..()
	M.update_sight()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_misc_effects()

/datum/mutation/night_vision/deactivate(mob/living/M)
	..()
	M.update_sight()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_misc_effects()

/datum/mutation/flash_protection
	name = "Flash Protection"
	activation_messages = list("You stop noticing the glare from lights...")
	deactivation_messages = list("Lights begin glaring again...")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_FLASH_PROTECTION)

/datum/mutation/flash_protection/New()
	..()
	block = GLOB.noflashblock
