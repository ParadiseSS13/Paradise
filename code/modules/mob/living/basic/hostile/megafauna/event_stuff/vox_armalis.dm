/mob/living/basic/megafauna/vox_armalis
	name = "vox armalis"
	desc = "A massive vox, clad in heavy carapace armor and wielding a massive spikethrower. Something this large and heavy should not be moving with such finesse."
	health = 300
	maxHealth = 300
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	icon_state = "bluespace_horror"
	speak_emote = list("creels")
	melee_attack_cooldown_min = 1 SECONDS
	damage_coeff = list(BRUTE = 0.2, BURN = 0.2, TOX = 0.2, CLONE = 0, STAMINA = 0, OXY = 0)
	melee_damage_lower = 35
	melee_damage_upper = 45
	attack_verb_simple = "slice"
	attack_verb_continuous = "slices"
	attack_sound ='sound/weapons/blade1.ogg'
	see_in_dark = 20 // I see you
	step_type = FOOTSTEP_MOB_HEAVY
	is_ranged = TRUE
	casing_type = /obj/item/ammo_casing/caseless/heavy_spike
	projectile_sound = 'sound/weapons/bladeslice.ogg'
	ranged_burst_count = 1
	ranged_burst_interval = 0.4
	ranged_cooldown = 0.5 SECONDS // It's player controlled, it can have player fire rates.
	crusher_loot = list()
	true_spawn = FALSE
	innate_actions = list()

/mob/living/basic/megafauna/vox_armalis/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")
	add_language("Vox-pidgin")
	set_default_language(GLOB.all_languages["Vox-pidgin"])

/mob/living/basic/megafauna/vox_armalis/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/megafauna/vox_armalis/ex_act(severity)
	return

/mob/living/basic/megafauna/vox_armalis/death(gibbed)
	visible_message("<span class='userdanger'>[src] starts beeping ominously!</span>")
	for(i in 1 to 4)
		playsound(loc, 'sound/items/timer.ogg', 30, 0)
		sleep(1 SECONDS)
	explosion(src, 5, 11, 20, 26, flame_range = 26, cause = name)

/obj/item/ammo_casing/caseless/heavy_spike
	name = "heavy alloy spike"
	desc = "A large broadhead spike made out of a weird silvery metal."
	projectile_type = /obj/item/projectile/bullet/hspike
	muzzle_flash_effect = null
	select_name = "hspike"
	fire_sound = 'sound/weapons/bladeslice.ogg'

/obj/item/ammo_casing/caseless/spike_flechettes
	name = "spike flechettes"
	desc = "A cluster of loosely-packed alloy spikes."
	projectile_type = /obj/item/projectile/bullet/fspike
	muzzle_flash_effect = null
	select_name = "fspike"
	fire_sound = 'sound/weapons/bladeslice.ogg'

/obj/item/ammo_casing/caseless/spike_penetrator
	name = "spike penetrator"
	desc = "A dense alloy spike with a reinforced, sharpened tip."
	projectile_type = /obj/item/projectile/bullet/pspike
	muzzle_flash_effect = null
	select_name = "pspike"
	fire_sound = 'sound/weapons/bladeslice.ogg'

/obj/item/projectile/bullet/hspike
	name = "heavy alloy spike"
	desc = "It's about two feet of weird silvery metal with a wicked point."
	damage = 35
	knockdown = 3
	armor_penetration_flat = 45
	pellets = 5
	variance = 60
	icon_state = "magspear"

/obj/item/projectile/bullet/hspike/on_hit(atom/target, blocked = 0)
	if((blocked < 100) && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(75)
		H.Immobilize(1 SECONDS)
		to_chat("<span class='userdanger'>[src] pins you to the floor!</span>")
	..()

/obj/item/projectile/bullet/fspike
	name = "alloy spike flechette"
	desc = "A sharpened dart of silvery metal."
	damage = 15
	knockdown = 1
	armor_penetration_flat = 15
	icon_state = "magspear"

/obj/item/projectile/bullet/fspike/on_hit(atom/target, blocked = 0)
	if((blocked < 100) && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(25)
	..()

/obj/item/projectile/bullet/pspike
	name = "alloy spike penetrator"
	desc = "A 2-foot reinforced spike made of a silvery metal and sharpened to a dangerous point."
	damage = 60
	knockdown = 4
	armor_penetration_flat = 100
	icon_state = "magspear"
	forcedodge = 8

/obj/item/projectile/bullet/pspike/on_hit(atom/target, blocked = 0)
	if((blocked < 100) && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(75)
	..()
