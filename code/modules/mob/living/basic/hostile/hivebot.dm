/obj/item/projectile/hivebotbullet

/mob/living/basic/hivebot
	name = "Hivebot"
	desc = "A small robot."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	mob_biotypes = MOB_ROBOTIC
	health = 15
	maxHealth = 15
	melee_damage_lower = 2
	melee_damage_upper = 3
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("hivebot")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	speak_emote = list("states")
	gold_core_spawnable = HOSTILE_SPAWN
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	death_message = "blows apart!"
	bubble_icon = "machine"
	basic_mob_flags = DEL_ON_DEATH
	step_type = FOOTSTEP_MOB_CLAW
	ai_controller = /datum/ai_controller/basic_controller/hivebot
	projectile_type = /obj/item/projectile/hivebotbullet
	projectile_sound = 'sound/weapons/gunshots/gunshot.ogg'

/mob/living/basic/hivebot/range
	desc = "A smallish robot, this one is armed!"
	is_ranged = TRUE
	ai_controller = /datum/ai_controller/basic_controller/hivebot/ranged

/mob/living/basic/hivebot/rapid
	is_ranged = TRUE
	ranged_burst_count = 3
	ai_controller = /datum/ai_controller/basic_controller/hivebot/ranged/rapid

/mob/living/basic/hivebot/strong
	name = "Strong Hivebot"
	desc = "A robot, this one is armed and looks tough!"
	health = 80
	maxHealth = 80
	is_ranged = TRUE
	ai_controller = /datum/ai_controller/basic_controller/hivebot/ranged

/mob/living/basic/hivebot/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)

/mob/living/basic/hivebot/tele // Hivebot Telebeacon
	name = "Beacon"
	desc = "Some odd beacon thing."
	icon_state = "def_radar-off"
	icon_living = "def_radar-off"
	health = 200
	maxHealth = 200
	status_flags = 0
	anchored = TRUE
	ai_controller = /datum/ai_controller/basic_controller/beacon
	/// The total number of hivebots to spawn
	var/bot_amt = 10

/mob/living/basic/hivebot/tele/Initialize(mapload)
	. = ..()
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(5, FALSE, loc)
	smoke.start()
	visible_message("<span class='danger'>[src] warps in!</span>")
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, 1)

/mob/living/basic/hivebot/tele/proc/warpbots()
	icon_state = "def_radar"
	visible_message("<span class='warning'>[src] turns on!</span>")
	while(bot_amt > 0)
		bot_amt--
		if(bot_amt > 3)
			var/mob/living/basic/hivebot/H = new /mob/living/basic/hivebot(get_turf(src))
			H.faction = faction
		else if(bot_amt > 0)
			var/mob/living/basic/hivebot/range/R = new /mob/living/basic/hivebot/range(get_turf(src))
			R.faction = faction
		else
			var/mob/living/basic/hivebot/rapid/F = new /mob/living/basic/hivebot/rapid(get_turf(src))
			F.faction = faction
	spawn(100)
		qdel(src)
	return
