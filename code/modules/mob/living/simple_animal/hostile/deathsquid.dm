/mob/living/simple_animal/hostile/deathsquid
	name = "death squid"
	desc = "A large, floating eldritch horror. Its body glows with an evil red light, and its tentacles look to have been dipped in alien blood."

	speed = 1
	speak_emote = list("telepathically thunders", "telepathically booms")
	maxHealth = 2500 // same as megafauna
	health = 2500

	icon = 'icons/mob/deathsquid_large.dmi' // Credit: FullofSkittles
	icon_state = "deathsquid"
	icon_living = "deathsquid"
	icon_dead = "deathsquiddead"
	pixel_x = -24
	pixel_y = -24

	attacktext = "slices"
	attack_sound = 'sound/weapons/whip.ogg'
	armour_penetration = 25
	melee_damage_lower = 10
	melee_damage_upper = 100
	environment_smash = ENVIRONMENT_SMASH_RWALLS

	force_threshold = 15
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	heat_damage_per_tick = 0

	see_in_dark = 8
	mob_size = MOB_SIZE_LARGE
	ventcrawler = 0
	gold_core_spawnable = NO_SPAWN
	loot = list(/obj/structure/closet/crate/deathsquid, /obj/item/toy/plushie/octopus)


/obj/structure/closet/crate/deathsquid
	name = "digested crate"
	desc = "A half digested crate from the death squid's stomache. It's contents still seem intact."

/obj/structure/closet/crate/deathsquid/New(add_loot = TRUE)
	..()

	if(!add_loot)
		return

	var/loot = rand(1, 20)
	switch(loot)
		if(1)
			new /obj/item/guardiancreator/biological// bingo!
		if(2)
			new /obj/item/spellbook/oneuse/summonitem
			new /obj/item/clothing/head/wizard/fake
		if(3 to 5)
			new /obj/item/teleportation_scroll
		if(6 to 10)
			new /obj/item/clothing/suit/space/hardsuit/syndi
			new /obj/item/gun/projectile/automatic/pistol
		if(11 to 14)
			new /obj/item/storage/belt/utility/chief
			new /obj/item/clothing/head/hardhat/white
			new /obj/item/clothing/gloves/color/yellow
		if(15 to 16)
			new /obj/item/voodoo(src)
			new /obj/item/bedsheet/cult(src)
		if(17 to 18)
			new /obj/item/wisp_lantern(src)
		if(19 to 20)
			new /obj/item/immortality_talisman(src)

/mob/living/simple_animal/hostile/deathsquid/Process_Spacemove(var/movement_dir = 0)
	return 1 //copypasta from carp code

/mob/living/simple_animal/hostile/deathsquid/ex_act(severity)
	return

/mob/living/simple_animal/hostile/deathsquid/joke
	name = "deaf squid"
	desc = "An elderly, hard-of-hearing eldrich horror."
	maxHealth = 200
	health = 200
	speed = 3
	armour_penetration = 5
	melee_damage_lower = 10
	melee_damage_upper = 20
	environment_smash = 2
	loot = list()