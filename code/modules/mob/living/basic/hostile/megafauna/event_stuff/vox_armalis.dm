/mob/living/basic/megafauna/vox_armalis
	name = "vox armalis"
	desc = "A massive vox, clad in heavy carapace armor and wielding a massive spikethrower. Something this large and heavy should not be moving with such finesse."
	health = 300
	maxHealth = 300
	gender = PLURAL
	icon = 'icons/mob/lavaland/32x64fauna.dmi'
	icon_state = "armalis"
	speak_emote = list("creels")
	melee_attack_cooldown_min = 1 SECONDS
	damage_coeff = list(BRUTE = 0.2, BURN = 0.2, TOX = 0.2, CLONE = 0, STAMINA = 0, OXY = 0)
	melee_damage_lower = 25
	melee_damage_upper = 30
	attack_verb_simple = "punch"
	attack_verb_continuous = "punches"
	attack_sound = 'sound/weapons/resonator_blast.ogg'
	response_help_continuous = "gestures at"
	response_help_simple = "gesture at"
	move_force = MOVE_FORCE_NORMAL
	see_in_dark = 20 // I see you
	step_type = FOOTSTEP_MOB_SHOE
	is_ranged = TRUE
	casing_type = /obj/item/ammo_casing/caseless/heavy_spike
	projectile_sound = 'sound/weapons/bladeslice.ogg'
	ranged_burst_count = 2
	ranged_cooldown = 0.5 SECONDS // It's player controlled, it can have player fire rates.
	initial_traits = list()
	crusher_loot = list()
	true_spawn = FALSE
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/vox_armalis/swap_ammo,
		/datum/action/cooldown/mob_cooldown/vox_armalis/activate_qani,
		/datum/action/cooldown/mob_cooldown/vox_armalis/ignite_claws,
	)
	/// Are the claws on
	var/plasma_claws = FALSE

/mob/living/basic/megafauna/vox_armalis/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")
	add_language("Vox-pidgin")
	set_default_language(GLOB.all_languages["Vox-pidgin"])
	sight |= SEE_MOBS
	var/datum/language/lang = GLOB.all_languages["Vox-pidgin"]
	name = lang.get_random_name(gender)

/mob/living/basic/megafauna/vox_armalis/IsAdvancedToolUser()
	return TRUE

/mob/living/basic/megafauna/vox_armalis/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/megafauna/vox_armalis/update_overlays()
	. = ..()
	overlays.Cut()
	if(plasma_claws)
		. += "armalis_plasma_claws"

/mob/living/basic/megafauna/vox_armalis/ex_act(severity)
	switch(severity)
		if(1)
			adjustBruteLoss(75)

		if(2)
			adjustBruteLoss(25)

		if(3)
			adjustBruteLoss(10)

/mob/living/basic/megafauna/vox_armalis/devour(mob/living/L)
	return

/mob/living/basic/megafauna/vox_armalis/death(gibbed)
	death_explosion()
	return ..()

/mob/living/basic/megafauna/vox_armalis/proc/death_explosion()
	visible_message("<span class='userdanger'>[src] starts beeping ominously!</span>")
	for(var/i in 1 to 4)
		playsound(loc, 'sound/items/timer.ogg', 30, 0)
		sleep(1 SECONDS)
	explosion(loc, 5, 11, 20, 26, flame_range = 26, cause = name)
	qdel(src)

/mob/living/basic/megafauna/vox_armalis/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(a_intent == INTENT_HARM)
		if(ismob(target) && !plasma_claws)
			var/mob/dustlung = target
			var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
			dustlung.throw_at(throw_target, 15, 9) // Like getting hit with a max-spool powerfist
		return ..()
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		try_open_airlock(A)
		return
	if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/A = target
		if(A.density)
			A.open()
		else
			A.close()
		return
	if(iswallturf(target))
		return // We're not on kill intent. Don't smash.
	if(ismachinery(target)) // We can interface with machines!
		var/obj/machinery/machine = target
		machine.attack_hand(src)
		return

/mob/living/basic/megafauna/vox_armalis/RangedAttack(atom/A, params)
	if(a_intent != INTENT_HARM)
		return // No shoot on friendly mode
	. = ..()

/mob/living/basic/megafauna/vox_armalis/proc/try_open_airlock(obj/machinery/door/airlock/D)
	if(D.operating)
		return
	if(D.welded)
		to_chat(src, "<span class='warning'>The door is welded.</span>")
	else if(D.locked)
		to_chat(src, "<span class='warning'>The door is bolted.</span>")
	else if(D.allowed(src))
		if(D.density)
			D.open(TRUE)
		else
			D.close(TRUE)
		return TRUE
	visible_message("<span class='danger'>[src] forces the door!</span>")
	playsound(src.loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(D.density)
		D.open(TRUE)
	else
		D.close(TRUE)

/obj/item/ammo_casing/caseless/heavy_spike
	name = "heavy alloy spike"
	desc = "A large broadhead spike made out of a weird silvery metal."
	projectile_type = /obj/projectile/bullet/hspike
	muzzle_flash_effect = null
	fire_sound = 'sound/weapons/bladeslice.ogg'

/obj/item/ammo_casing/caseless/spike_flechettes
	name = "spike flechettes"
	desc = "A cluster of loosely-packed alloy spikes."
	projectile_type = /obj/projectile/bullet/fspike
	muzzle_flash_effect = null
	fire_sound = 'sound/weapons/bladeslice.ogg'
	pellets = 5
	variance = 60

/obj/item/ammo_casing/caseless/spike_penetrator
	name = "spike penetrator"
	desc = "A dense alloy spike with a reinforced, sharpened tip."
	projectile_type = /obj/projectile/bullet/pspike
	muzzle_flash_effect = null
	fire_sound = 'sound/weapons/bladeslice.ogg'

/obj/projectile/bullet/hspike
	name = "heavy alloy spike"
	desc = "It's about two feet of weird silvery metal with a wicked point."
	damage = 35
	knockdown = 3
	armor_penetration_flat = 45
	icon_state = "magspear"

/obj/projectile/bullet/hspike/on_hit(atom/target, blocked = 0)
	if((blocked < 100) && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(75)
		H.Immobilize(1 SECONDS)
	..()

/obj/projectile/bullet/fspike
	name = "alloy spike flechette"
	desc = "A sharpened dart of silvery metal."
	damage = 15
	knockdown = 1
	armor_penetration_flat = 15
	icon_state = "magspear"

/obj/projectile/bullet/fspike/on_hit(atom/target, blocked = 0)
	if((blocked < 100) && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(25)
	..()

/obj/projectile/bullet/pspike
	name = "alloy spike penetrator"
	desc = "A 2-foot reinforced spike made of a silvery metal and sharpened to a dangerous point."
	knockdown = 4
	armor_penetration_flat = 100
	icon_state = "magspear"
	forcedodge = 8

/obj/projectile/bullet/pspike/on_hit(atom/target, blocked = 0)
	if((blocked < 100) && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(75)
	..()
