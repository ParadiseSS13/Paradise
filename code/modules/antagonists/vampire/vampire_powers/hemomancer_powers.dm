/obj/effect/proc_holder/spell/vampire/self/vamp_claws
	name = "Vampiric Claws"
	desc = "You channel blood magics to forge deadly vampiric claws that leech blood and strike rapidly. Cannot be used if you are holding something that cannot be dropped."
	gain_desc = "You have gained the ability to forge your hands into vampiric claws."
	base_cooldown = 15 SECONDS
	required_blood = 20
	action_icon_state = "vampire_claws"


/obj/effect/proc_holder/spell/vampire/self/vamp_claws/cast(mob/user)
	if(user.l_hand || user.r_hand)
		to_chat(user, span_notice("You drop what was in your hands as large blades spring from your fingers!"))
		user.drop_l_hand()
		user.drop_r_hand()
	else
		to_chat(user, span_notice("Large blades of blood spring from your fingers!"))
	var/obj/item/twohanded/required/vamp_claws/claws = new /obj/item/twohanded/required/vamp_claws(user.loc, src)
	RegisterSignal(user, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(dispel))
	user.put_in_hands(claws)


/obj/effect/proc_holder/spell/vampire/self/vamp_claws/proc/dispel()
	SIGNAL_HANDLER

	var/mob/living/carbon/human/user = action.owner
	if(!user.mind.has_antag_datum(/datum/antagonist/vampire))
		return

	var/current
	if(istype(user.l_hand, /obj/item/twohanded/required/vamp_claws))
		current = user.l_hand

	if(istype(user.r_hand, /obj/item/twohanded/required/vamp_claws))
		current = user.r_hand

	if(current)
		qdel(current)
		to_chat(user, span_notice("You dispel your claws!"))


/obj/effect/proc_holder/spell/vampire/self/vamp_claws/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(L.can_unEquip(L.l_hand) && L.can_unEquip(L.r_hand))
		return ..()


/obj/item/twohanded/required/vamp_claws
	name = "vampiric claws"
	desc = "A pair of eldritch claws made of living blood, they seem to flow yet they are solid"
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "vamp_claws"
	w_class = WEIGHT_CLASS_BULKY
	flags = ABSTRACT | NODROP | DROPDEL
	force = 15
	force_wielded = 15
	armour_penetration = 40
	sharp = TRUE
	attack_effect_override = ATTACK_EFFECT_CLAW
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "savaged", "clawed")
	sprite_sheets_inhand = list("Vox" = 'icons/mob/species/vox/held.dmi', "Drask" = 'icons/mob/species/drask/held.dmi')
	var/durability = 15
	var/blood_drain_amount = 15
	var/blood_absorbed_amount = 5
	var/obj/effect/proc_holder/spell/vampire/self/vamp_claws/parent_spell


/obj/item/twohanded/required/vamp_claws/Initialize(mapload, new_parent_spell)
	. = ..()
	parent_spell = new_parent_spell


/obj/item/twohanded/required/vamp_claws/Destroy()
	if(parent_spell)
		parent_spell.UnregisterSignal(parent_spell.action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		parent_spell.action.UpdateButtonIcon()
		parent_spell = null
	return ..()


/obj/item/twohanded/required/vamp_claws/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	var/datum/antagonist/vampire/V = user.mind?.has_antag_datum(/datum/antagonist/vampire)
	var/mob/living/attacker = user

	if(!V)
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		// no parameter in [affects_vampire()] so holy always protects
		if(C.ckey && C.stat != DEAD && C.affects_vampire() && !(NO_BLOOD in C.dna.species.species_traits))
			C.bleed(blood_drain_amount)
			V.adjust_blood(C, blood_absorbed_amount)
			attacker.adjustStaminaLoss(-20) // security is dead
			attacker.heal_overall_damage(4, 4) // the station is full
			attacker.AdjustWeakened(-1 SECONDS) // blood is fuel

	if(!V.get_ability(/datum/vampire_passive/blood_spill))
		durability--
		if(durability <= 0)
			qdel(src)
			to_chat(user, span_warning("Your claws shatter!"))


/obj/item/twohanded/required/vamp_claws/melee_attack_chain(mob/user, atom/target, params)
	..()
	if(wielded)
		user.changeNext_move(CLICK_CD_MELEE * 0.5)


/obj/item/twohanded/required/vamp_claws/attack_self(mob/user)
	qdel(src)
	to_chat(user, span_notice("You dispel your claws!"))


/obj/effect/proc_holder/spell/vampire/blood_tendrils
	name = "Blood Tendrils"
	desc = "You summon blood tendrils from bluespace after a delay to ensnare people in an area, slowing them down and applying moderate toxic damage."
	gain_desc = "You have gained the ability to summon blood tendrils to slow people down in an area that you target."
	required_blood = 10

	base_cooldown = 10 SECONDS
	action_icon_state = "blood_tendrils"
	sound = 'sound/misc/enter_blood.ogg'
	var/area_of_affect = 1
	need_active_overlay = TRUE

	selection_activated_message		= span_notice("You channel blood magics to weaken the bluespace veil. <B>Left-click to cast at a target area!</B>")
	selection_deactivated_message	= span_notice("Your magics subside.")


/obj/effect/proc_holder/spell/vampire/blood_tendrils/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /atom
	T.try_auto_target = FALSE
	return T


/obj/effect/proc_holder/spell/vampire/blood_tendrils/cast(list/targets, mob/user)
	var/turf/T = get_turf(targets[1]) // there should only ever be one entry in targets for this spell

	for(var/turf/simulated/blood_turf in view(area_of_affect, T))
		if(blood_turf.density)
			continue
		new /obj/effect/temp_visual/blood_tendril(blood_turf)

	addtimer(CALLBACK(src, PROC_REF(apply_slowdown), T, area_of_affect, 6 SECONDS, user), 1 SECONDS)


/obj/effect/proc_holder/spell/vampire/blood_tendrils/proc/apply_slowdown(turf/T, distance, slowed_amount, mob/user)
	for(var/mob/living/L in range(distance, T))
		if(L.affects_vampire(user))
			L.Slowed(slowed_amount)
			L.adjustToxLoss(33)
			L.visible_message(span_warning("[L] gets ensnare in blood tendrils, restricting [L.p_their()] movement!"))
			var/turf/target_turf = get_turf(L)
			playsound(target_turf, 'sound/magic/tail_swing.ogg', 50, TRUE)
			new /obj/effect/decal/cleanable/blood(target_turf)
			new /obj/effect/temp_visual/blood_tendril/long(target_turf)


/obj/effect/temp_visual/blood_tendril
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "blood_tendril"
	duration = 1 SECONDS


/obj/effect/temp_visual/blood_tendril/long
	duration = 2 SECONDS


/obj/effect/proc_holder/spell/vampire/blood_barrier
	name = "Blood Barrier"
	desc = "Select two points within 3 tiles of each other and make a barrier between them. You can cast on self to make a barrier on your current position instantly."
	gain_desc = "You have gained the ability to summon a crystaline wall of blood between two points, the barrier is easily destructable, however you can walk freely through it. You can cast on self to make a barrier on your current position instantly."
	required_blood = 20
	base_cooldown = 30 SECONDS
	should_recharge_after_cast = FALSE
	deduct_blood_on_cast = FALSE
	action_icon_state = "blood_barrier"
	need_active_overlay = TRUE

	var/max_walls = 3
	var/turf/start_turf = null


/obj/effect/proc_holder/spell/vampire/blood_barrier/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /atom
	T.try_auto_target = FALSE
	return T


/obj/effect/proc_holder/spell/vampire/blood_barrier/remove_ranged_ability(mob/user, msg)
	. = ..()
	if(msg) // this is only true if the user intentionally turned off the spell
		start_turf = null
		should_recharge_after_cast = FALSE


/obj/effect/proc_holder/spell/vampire/blood_barrier/should_remove_click_intercept()
	if(start_turf)
		return TRUE
	return FALSE


/obj/effect/proc_holder/spell/vampire/blood_barrier/cast(list/targets, mob/user)
	// First we check if vampire clicks on himself
	var/turf/target_turf = get_turf(targets[1])
	var/user_found = FALSE
	for(var/mob/living/check in target_turf.contents)
		if(check == user)
			user_found = TRUE
			break

	if(user_found && !start_turf)
		var/odd_number = max_walls % 2
		var/walls_amount = odd_number ? ((max_walls - 1) / 2) : (max_walls / 2 - 1)
		var/dir_right = turn(user.dir, 90)
		var/dir_left = turn(user.dir, 270)

		new /obj/structure/blood_barrier(target_turf)
		for(var/i in 1 to walls_amount)
			new /obj/structure/blood_barrier(get_step(target_turf, dir_right))

		for(var/i in 1 to (odd_number ? walls_amount : walls_amount + 1))
			new /obj/structure/blood_barrier(get_step(target_turf, dir_left))

		var/datum/spell_handler/vampire/V = custom_handler
		var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
		var/blood_cost = V.calculate_blood_cost(vampire)
		vampire.bloodusable -= blood_cost
		remove_ranged_ability(user)
		cooldown_handler.start_recharge()
		return

	// Otherwise we will try to build a wall by two clicks
	if(target_turf == start_turf)
		to_chat(user, span_notice("You deselect the targeted turf."))
		start_turf = null
		should_recharge_after_cast = FALSE
		return

	if(!start_turf)
		start_turf = target_turf
		should_recharge_after_cast = TRUE
		return

	var/wall_count
	for(var/turf/T in getline(target_turf, start_turf))
		if(max_walls <= wall_count)
			break
		new /obj/structure/blood_barrier(T)
		wall_count++

	var/datum/spell_handler/vampire/V = custom_handler
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/blood_cost = V.calculate_blood_cost(vampire)
	vampire.bloodusable -= blood_cost
	start_turf = null
	should_recharge_after_cast = FALSE


/obj/structure/blood_barrier
	name = "blood barrier"
	desc = "a grotesque structure of crystalised blood. It's slowly melting away..."
	max_integrity = 100
	icon_state = "blood_barrier"
	icon = 'icons/effects/vampire_effects.dmi'
	density = TRUE
	anchored = TRUE
	opacity = FALSE


/obj/structure/blood_barrier/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/structure/blood_barrier/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/structure/blood_barrier/process()
	take_damage(8, sound_effect = FALSE)


/obj/structure/blood_barrier/obj_destruction(damage_flag)
	new /obj/effect/decal/cleanable/blood(loc)
	return ..()


/obj/structure/blood_barrier/CanPass(atom/movable/mover, turf/target, height)
	if(!isliving(mover))
		return FALSE

	var/mob/living/L = mover
	if(!L.mind)
		return FALSE

	var/datum/antagonist/vampire/V = L.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return FALSE

	if(is_type_in_list(V.subclass, list(SUBCLASS_HEMOMANCER, SUBCLASS_ANCIENT)))
		return TRUE


/obj/effect/proc_holder/spell/ethereal_jaunt/blood_pool
	name = "Sanguine Pool"
	desc = "You shift your form into a pool of blood, making you invulnerable and able to move through anything that's not a wall or space. You leave a trail of blood behind you when you do this."
	gain_desc = "You have gained the ability to shift into a pool of blood, allowing you to evade pursuers with great mobility."
	jaunt_duration = 3 SECONDS
	clothes_req = FALSE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"
	action_icon_state = "blood_pool"
	base_cooldown = 25 SECONDS
	jaunt_type_path = /obj/effect/dummy/spell_jaunt/blood_pool
	jaunt_water_effect = FALSE
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/cult/phase/out
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/cult/phase
	jaunt_in_time = 0
	sound_in = 'sound/misc/enter_blood.ogg'
	sound_out = 'sound/misc/exit_blood.ogg'


/obj/effect/proc_holder/spell/ethereal_jaunt/blood_pool/after_spell_init()
	update_vampire_spell_name()


/obj/effect/proc_holder/spell/ethereal_jaunt/blood_pool/create_new_handler()
	var/datum/spell_handler/vampire/H = new
	H.required_blood = 30
	return H


/obj/effect/proc_holder/spell/vampire/predator_senses
	name = "Predator Senses"
	desc = "Hunt down your prey, there's nowhere to hide... Will stun for a short perion if in view."
	gain_desc = "Your senses are heightened, nobody can hide from you now."
	action_icon_state = "predator_sense"
	base_cooldown = 10 SECONDS
	create_attack_logs = FALSE


/obj/effect/proc_holder/spell/vampire/predator_senses/create_new_targeting()
	var/datum/spell_targeting/alive_mob_list/A = new()
	A.allowed_type = /mob/living/carbon/human
	A.max_targets = 300 // hopefully we never hit this number
	return A


/obj/effect/proc_holder/spell/vampire/predator_senses/valid_target(mob/target, mob/user)
	return target.z == user.z && target.mind


/obj/effect/proc_holder/spell/vampire/predator_senses/cast(list/targets, mob/user)
	var/targets_by_name = list()
	for(var/mob/living/carbon/human/H as anything in targets)
		targets_by_name[H.real_name] = H

	var/target_name = input(user, "Person to Locate", "Blood Stench") in targets_by_name
	if(!target_name)
		return

	var/mob/living/carbon/human/target = targets_by_name[target_name]
	var/message = "[target_name] is in [get_area(target)], [dir2text(get_dir(user, target))] from you."
	if(target.get_damage_amount() >= 40 || target.bleed_rate)
		message += "<i> They are wounded...</i>"
	to_chat(user, span_cultlarge("[message]"))

	if(target in view(user))
		target.Stun(4 SECONDS)
		var/turf/target_turf = get_turf(target)
		playsound(target_turf, 'sound/effects/splat.ogg', 50, TRUE)
		new /obj/effect/decal/cleanable/blood(target_turf)


/obj/effect/proc_holder/spell/vampire/blood_eruption
	name = "Blood Eruption"
	desc = "Every pool of blood in 4 tiles erupts with a spike of living blood, damaging anyone stood on it."
	gain_desc = "You have gained the ability to weaponise pools of blood to damage those stood on them."
	required_blood = 50
	base_cooldown = 1 MINUTES
	action_icon_state = "blood_spikes"


/obj/effect/proc_holder/spell/vampire/blood_eruption/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.range = 4
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/vampire/blood_eruption/valid_target(mob/living/target, user)
	var/turf/T = get_turf(target)
	if(locate(/obj/effect/decal/cleanable/blood) in T)
		if(target.affects_vampire(user) && !isLivingSSD(target))
			return TRUE
	return FALSE


/obj/effect/proc_holder/spell/vampire/blood_eruption/cast(list/targets, mob/user)
	for(var/mob/living/L in targets)
		var/turf/T = get_turf(L)
		var/obj/effect/decal/cleanable/blood/B = locate(/obj/effect/decal/cleanable/blood) in T
		var/obj/effect/temp_visual/blood_spike/spike = new /obj/effect/temp_visual/blood_spike(T)
		spike.color = B.basecolor
		playsound(L, 'sound/misc/demon_attack1.ogg', 50, TRUE)
		L.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
		L.Stun(3 SECONDS)
		L.visible_message(span_warning("<b>[L] gets impaled by a spike of living blood!</b>"))


/obj/effect/temp_visual/blood_spike
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "bloodspike_white"
	duration = 0.3 SECONDS


/obj/effect/proc_holder/spell/vampire/self/blood_spill
	name = "The Blood Bringers Rite"
	desc = "When toggled, everyone around you begins to bleed profusely. You will drain their blood and rejuvenate yourself with it."
	gain_desc = "You have gained the ability to rip the very life force out of people and absorb it, healing you."
	base_cooldown = 10 SECONDS
	action_icon_state = "blood_bringers_rite"
	required_blood = 10


/obj/effect/proc_holder/spell/vampire/self/blood_spill/cast(list/targets, mob/user)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V.get_ability(/datum/vampire_passive/blood_spill))
		V.force_add_ability(/datum/vampire_passive/blood_spill)
	else
		for(var/datum/vampire_passive/blood_spill/B in V.powers)
			V.remove_ability(B)


/datum/vampire_passive/blood_spill
	var/max_beams = 10


/datum/vampire_passive/blood_spill/New()
	..()
	START_PROCESSING(SSobj, src)


/datum/vampire_passive/blood_spill/Destroy(force, ...)
	STOP_PROCESSING(SSobj, src)
	return ..()


/datum/vampire_passive/blood_spill/process()
	var/beam_number = 0
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	for(var/mob/living/carbon/human/H in view(7, owner))
		if(NO_BLOOD in H.dna.species.species_traits)
			continue

		if(!H.affects_vampire(owner) || H.stat)
			continue

		var/drain_amount = rand(5, 10)
		beam_number++
		H.bleed(drain_amount)
		H.Beam(owner, icon_state = "drainbeam", time = 2 SECONDS)
		H.adjustBruteLoss(5)
		owner.heal_overall_damage(8, 2, TRUE)
		owner.adjustStaminaLoss(-15)
		owner.AdjustStunned(-2 SECONDS)
		owner.AdjustWeakened(-2 SECONDS)
		if(drain_amount == 10)
			to_chat(H, span_warning("<b>You feel your life force draining!</b>"))

		if(beam_number >= max_beams)
			break

	V.bloodusable = max(V.bloodusable - 10, 0)

	if(!V.bloodusable || owner.stat == DEAD)
		V.remove_ability(src)

