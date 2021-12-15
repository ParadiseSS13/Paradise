/obj/effect/proc_holder/spell/vampire/self/vamp_claws
	name = "Vampiric Claws (30)"
	desc = "You channel blood magics to forge deadly vampiric claws that leech blood and strike rapidly. Cannot be used if you are holding something that cannot be dropped."
	gain_desc = "You have gained the ability to forge your hands into vampiric claws."
	charge_max = 30 SECONDS
	required_blood = 30
	action_icon_state = "vampire_claws"

/obj/effect/proc_holder/spell/vampire/self/vamp_claws/cast(mob/user)
	if(user.l_hand || user.r_hand)
		to_chat(user, "<span class='notice'>You drop what was in your hands as large blades spring from your fingers!</span>")
		user.drop_l_hand()
		user.drop_r_hand()
	else
		to_chat(user, "<span class='notice'>Large blades of blood spring from your fingers!</span>")
	var/obj/item/twohanded/required/vamp_claws/claws = new /obj/item/twohanded/required/vamp_claws(user.loc)
	user.put_in_hands(claws)


/obj/effect/proc_holder/spell/vampire/self/vamp_claws/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(L.canUnEquip(L.l_hand) && L.canUnEquip(L.r_hand))
		return ..()

/obj/item/twohanded/required/vamp_claws
	name = "vampiric claws"
	desc = "A pair of eldritch claws made of living blood, they seem to flow yet they are solid"
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "vamp_claws"
	w_class = WEIGHT_CLASS_BULKY
	flags = ABSTRACT | NODROP | DROPDEL
	force = 10
	force_wielded = 10
	armour_penetration = 20
	block_chance = 50
	sharp = TRUE
	attack_effect_override = ATTACK_EFFECT_CLAW
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "savaged", "clawed")
	sprite_sheets_inhand = list("Vox" = 'icons/mob/clothing/species/vox/held.dmi', "Drask" = 'icons/mob/clothing/species/drask/held.dmi')
	var/durability = 20
	var/blood_drain_amount = 15
	var/blood_absorbed_amount = 5

/obj/item/twohanded/required/vamp_claws/afterattack(atom/target, mob/user, proximity)
	var/datum/antagonist/vampire/V = user.mind?.has_antag_datum(/datum/antagonist/vampire)

	if(!V)
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.ckey && C.stat != DEAD && C.affects_vampire() && !(NO_BLOOD in C.dna.species.species_traits))
			C.bleed(blood_drain_amount)
			V.adjust_blood(C, blood_absorbed_amount)
	durability -= 1
	if(durability <= 0)
		qdel(src)
		to_chat(user, "<span class='warning'>Your claws shatter!</span>")

/obj/item/twohanded/required/vamp_claws/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/required/vamp_claws/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/twohanded/required/vamp_claws/process()
	durability -= 1
	if(durability <= 0)
		qdel(src)

/obj/item/twohanded/required/vamp_claws/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0
	return ..()

/obj/item/twohanded/required/vamp_claws/melee_attack_chain(mob/user, atom/target, params)
	..()
	if(wielded)
		user.changeNext_move(CLICK_CD_MELEE * 0.5)

/obj/item/twohanded/required/vamp_claws/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You dispel your claws!</span>")
	qdel(src)

/obj/effect/proc_holder/spell/vampire/blood_tendrils
	name = "Blood Tendrils (10)"
	desc = "You summon blood tendrils from bluespace after a delay to ensnare people in an area, slowing them down."
	gain_desc = "You have gained the ability to summon blood tendrils to slow people down in an area that you target."
	required_blood = 10

	charge_max = 30 SECONDS
	action_icon_state = "blood_tendrils"
	sound = 'sound/misc/enter_blood.ogg'
	var/area_of_affect = 1

	selection_activated_message = "<span class='notice'>You channel blood magics to weaken the bluespace veil. <B>Left-click to cast at a target area!</B></span>"
	selection_deactivated_message = "<span class='notice'>Your magics subside.</span>"

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

	addtimer(CALLBACK(src, .proc/apply_slowdown, T, area_of_affect, 3, user), 0.5 SECONDS)

/obj/effect/proc_holder/spell/vampire/blood_tendrils/proc/apply_slowdown(turf/T, distance, slowed_amount, mob/user)
	for(var/mob/living/L in range(distance, T))
		if(L.affects_vampire(user))
			L.AdjustSlowed(slowed_amount)
			L.visible_message("<span class='warning'>[L] gets ensared in blood tendrils, restricting [L.p_their()] movement!</span>")
			new /obj/effect/temp_visual/blood_tendril/long(get_turf(L))

/obj/effect/temp_visual/blood_tendril
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "blood_tendril"
	duration = 1 SECONDS

/obj/effect/temp_visual/blood_tendril/long
	duration = 2 SECONDS

/obj/effect/proc_holder/spell/ethereal_jaunt/blood_pool
	name = "Sanguine Pool (50)"
	desc = "You shift your form into a pool of blood, making you invulnerable and able to move through anything that's not a wall or space. You leave a trail of blood behind you when you do this."
	gain_desc = "You have gained the ability to shift into a pool of blood, allowing you to evade pursuers with great mobility."
	jaunt_duration = 3 SECONDS
	clothes_req = FALSE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"
	action_icon_state = "blood_pool"
	jaunt_type_path = /obj/effect/dummy/spell_jaunt/blood_pool
	jaunt_water_effect = FALSE
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/cult/phase/out
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/cult/phase
	jaunt_in_time = 0
	sound1 = 'sound/misc/enter_blood.ogg'

/obj/effect/proc_holder/spell/ethereal_jaunt/blood_pool/create_new_handler()
	var/datum/spell_handler/vampire/H = new
	H.required_blood = 50
	return H

/obj/effect/proc_holder/spell/vampire/blood_eruption
	name = "Blood Eruption (100)"
	desc = "Every pool of blood in 4 tiles erupts with a spike of living blood, damaging anyone stood on it."
	gain_desc = "You have gained the ability to weaponise pools of blood to damage those stood on them."
	required_blood = 100
	charge_max = 200 SECONDS
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
		L.visible_message("<span class='warning'><b>[L] gets impaled by a spike of living blood!</b></span>")

/obj/effect/temp_visual/blood_spike
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "bloodspike_white"
	duration = 0.3 SECONDS

/obj/effect/proc_holder/spell/vampire/self/blood_spill
	name = "The Blood Bringers Rite"
	desc = "When toggled, everyone around you begins to bleed profusely."
	gain_desc = "You have gained the ability to rip the very life force out of people and absorb it, healing you."
	charge_max = 10 SECONDS
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
	var/turf/T = get_turf(owner)
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	for(var/mob/living/carbon/human/H in view(7, T))
		if(NO_BLOOD in H.dna.species.species_traits)
			continue

		if(!H.affects_vampire(owner) || H.stat)
			continue

		var/drain_amount = rand(5, 10)
		beam_number++
		H.bleed(drain_amount)
		H.Beam(owner, icon_state = "drainbeam", time = 2 SECONDS)
		H.adjustBruteLoss(2)
		owner.heal_overall_damage(8, 2, TRUE)
		owner.adjustStaminaLoss(-15)
		owner.AdjustStunned(-1)
		owner.AdjustWeakened(-1)
		if(drain_amount == 10)
			to_chat(H, "<span class='warning'>You feel your life force draining!</b></span>")

		if(beam_number >= max_beams)
			break
	V.bloodusable = max(V.bloodusable - 10, 0)
	if(!V.bloodusable || owner.stat == DEAD)
		V.remove_ability(src)
