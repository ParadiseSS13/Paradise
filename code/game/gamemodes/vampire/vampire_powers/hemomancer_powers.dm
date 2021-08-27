/obj/effect/proc_holder/spell/self/vamp_claws
	name = "Vampiric Claws (30)"
	desc = "You channel blood magics to forge deadly vampiric claws that leach blood and strike rapidly. Cannot be used if you are holding something that cannot be dropped."
	gain_desc = "Your have gained the ability to forge vampiric claws out of your hands."
	charge_max = 30 SECONDS
	required_blood = 30
	vampire_ability = TRUE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/obj/effect/proc_holder/spell/self/vamp_claws/cast(mob/user)
	to_chat(user, "<span class='notice'>You cast down what was in your hands and large blades spring from your knuckles! </span>")
	var/obj/item/twohanded/required/vamp_claws/claws = new /obj/item/twohanded/required/vamp_claws(user.loc)
	user.drop_l_hand()
	user.drop_r_hand()
	user.put_in_hands(claws)

/obj/effect/proc_holder/spell/self/vamp_claws/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(L.canUnEquip(L.l_hand) && L.canUnEquip(L.r_hand))
		. = ..()

/obj/item/twohanded/required/vamp_claws
	name = "vampiric claws"
	desc = "A pair of eldritch claws made of living blood, they seem to flow yet they are solid"
	icon = 'icons/obj/cult.dmi'
	icon_state = "blood_blade"
	item_state = "blood_blade"
	w_class = WEIGHT_CLASS_BULKY
	flags = ABSTRACT | NODROP | DROPDEL
	force_wielded = 8
	block_chance = 50
	sharp = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "savaged", "clawed")
	sprite_sheets_inhand = list("Skrell" = 'icons/mob/species/skrell/held.dmi')
	var/durability = 20
	var/blood_drain_amount = 15

/obj/item/twohanded/required/vamp_claws/afterattack(atom/target, mob/user, proximity)
	if(user.mind?.vampire)
		if(istype(target, /mob/living/carbon))
			var/mob/living/carbon/C = target
			if(C.ckey &&!C.stat && C.mind && C.affects_vampire() && !(NO_BLOOD in C.dna.species.species_traits))
				C.bleed(blood_drain_amount)
				user.mind.vampire.bloodtotal += 5
				user.mind.vampire.bloodusable += 5
				user.mind.vampire.check_vampire_upgrade()
	durability -= 1
	if(durability <= 0)
		qdel(src)
		to_chat(user, "<span class='warning'>Your claws shatter!</span>")

/obj/item/twohanded/required/vamp_claws/Initialize(mapload)
	..()
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/required/vamp_claws/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

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
	user.changeNext_move(CLICK_CD_MELEE * 0.5)

/obj/item/twohanded/required/vamp_claws/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You dispell your claws!</span>")
	qdel(src)

/obj/effect/proc_holder/spell/targeted/click/blood_tendrils
	name = "Blood Tendrils (10)"
	desc = "You summon blood tendrils from bluespace after a delay to ensnare people in an area, slowing them down."
	gain_desc = "You have gained the ability to summon blood tendrils to slow people down in an area that you target."
	required_blood = 10

	vampire_ability = TRUE
	click_radius = 1
	charge_max = 30 SECONDS
	allowed_type = /atom
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"
	sound = 'sound/misc/enter_blood.ogg'
	var/area_of_affect = 1

	selection_activated_message = "<span class='notice'>You channel blood magics to weaken the bluespace veil. <B>Left-click to cast at a target area!</B></span>"
	selection_deactivated_message = "<span class='notice'>Your magics subside.</span>"


/obj/effect/proc_holder/spell/targeted/click/blood_tendrils/cast(list/targets, mob/user)
	var/turf/T = get_turf(targets[1]) // there should only ever be one entry in targets for this spell

	for(var/turf/simulated/blood_turf in view(area_of_affect, T))
		if(T.density)
			continue
		new /obj/effect/temp_visual/cult/turf/open/floor(blood_turf)

	addtimer(CALLBACK(T, /turf./proc/blood_tendrils, area_of_affect, 3, usr), 5)

/turf/proc/blood_tendrils(distance, slowed_amount, user)
	for(var/mob/living/L in view(distance, src))
		if(L.affects_vampire(user))
			L.AdjustSlowed(slowed_amount)
			L.visible_message("<span class='warning'>[L] gets ensared in blood tendrils restricting [p_their(L)] movement!</span>")

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/blood_pool
	name = "Sanguine Pool (50)"
	desc = "You shift your form into a pool of blood, making us invulnerable and able to move through anything thats not a wall or space. You leave a trail of blood behind us when you do this."
	gain_desc = "You have gained the ability to shift into a pool of blood, allowing you to evade pursuers with great mobility."
	vampire_ability = TRUE
	required_blood = 50
	jaunt_duration = 3 SECONDS
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"
	jaunt_type_path = /obj/effect/dummy/spell_jaunt/blood_pool
	jaunt_water_effect = FALSE
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/cult/phase/out
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/cult/phase
	jaunt_in_time = 0
	sound1 = 'sound/misc/enter_blood.ogg'

/obj/effect/proc_holder/spell/blood_eruption
	name = "Blood Eruption (100)"
	desc = "Every pool of blood in your vision erupts with a spike of living blood, damaging anyone on that tile."
	gain_desc = "You have gained the ability to weaponise pools of blood to damage those stood on them."
	vampire_ability = TRUE
	required_blood = 100
	charge_max = 100 SECONDS
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/obj/effect/proc_holder/spell/blood_eruption/cast(list/targets, mob/user)
	for(var/mob/living/L in targets)
		var/turf/T = get_turf(L)
		new /obj/effect/temp_visual/cult/turf/open/floor(T)
		L.apply_damage(60, BRUTE, BODY_ZONE_CHEST)
		L.apply_damage(90, STAMINA)
		L.visible_message("<span class='warning'><b>[L] gets impaled by a spike of living blood! </b></span>")

/obj/effect/proc_holder/spell/blood_eruption/choose_targets(mob/user)
	var/list/targets = list()
	for(var/mob/living/L in view(7, user))
		var/turf/T = get_turf(L)
		if(locate(/obj/effect/decal/cleanable/blood) in T)
			if(L.affects_vampire(user) && !isLivingSSD(L))
				targets.Add(L)

	if(!length(targets))
		revert_cast(user)
		return

	perform(targets)

/obj/effect/proc_holder/spell/self/blood_spill
	name = "The Blood Bringers Rite"
	desc = "When toggled, everyone around you begins to bleed profusely."
	gain_desc = "You have gained the ability to rip the very life force out of people and absorb it, healing you."
	vampire_ability = TRUE
	charge_max = 10 SECONDS
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/obj/effect/proc_holder/spell/self/blood_spill/cast(list/targets, mob/user)
	var/mob/target = targets[1]
	if(!target.mind.vampire.get_ability(/datum/vampire_passive/blood_spill))
		target.mind.vampire.force_add_ability(/datum/vampire_passive/blood_spill)
	else
		for(var/datum/vampire_passive/blood_spill/B in target.mind.vampire.powers)
			target.mind.vampire.remove_ability(B)

/datum/vampire_passive/blood_spill
	gain_desc = "You begin reaping blood from nearby creatures"

/datum/vampire_passive/blood_spill/New()
	..()
	START_PROCESSING(SSobj, src)

/datum/vampire_passive/blood_spill/Destroy(force, ...)
	STOP_PROCESSING(SSobj, src)
	..()

/datum/vampire_passive/blood_spill/process()
	var/turf/T = get_turf(owner)
	for(var/mob/living/carbon/human/H in view(7, T))
		if(NO_BLOOD in H.dna.species.species_traits)
			continue

		if(H.affects_vampire(owner) && !H.stat && H.player_logged)
			var/drain_amount = rand(10, 20)
			H.bleed(drain_amount)
			H.Beam(owner, icon_state = "drainbeam", time = 2 SECONDS)
			H.adjustBruteLoss(5)
			owner.heal_overall_damage(drain_amount / 2 , drain_amount / 2 , TRUE)
			owner.adjustStaminaLoss(-drain_amount / 2)
			if(drain_amount == 20)
				to_chat(H, "<span class='warning'>You feel your life force draining!</b></span>")
	owner.mind.vampire.bloodusable = max(owner.mind.vampire.bloodusable - 10, 0)
	if(!owner.mind.vampire.bloodusable)
		to_chat(owner, "<span class='warning'>You have run out of useable blood!</b></span>")
		owner.mind.vampire.remove_ability(src)
