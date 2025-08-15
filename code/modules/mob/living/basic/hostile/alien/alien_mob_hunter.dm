/mob/living/basic/alien
	name = "alien hunter"
	desc = "Hiss!"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alienh_running"
	icon_living = "alienh_running"
	icon_dead = "alienh_dead"
	icon_gib = "syndicate_gib"
	gender = FEMALE
	speed = 0
	status_flags = CANPUSH
	basic_mob_flags = FLAMMABLE_MOB
	butcher_results = list(/obj/item/food/monstermeat/xenomeat= 3, /obj/item/stack/sheet/animalhide/xeno = 1)
	maxHealth = 125
	health = 125
	harm_intent_damage = 5
	obj_damage = 60

	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	speak_emote = list("hisses")
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES

	bubble_icon = "alien"
	a_intent = INTENT_HARM
	attack_sound = 'sound/weapons/bladeslice.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	unsuitable_heat_damage = 20
	faction = list("alien")
	minimum_survivable_temperature = 0
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	death_sound = 'sound/voice/hiss6.ogg'
	deathmessage = "lets out a waning guttural screech, green blood bubbling from its maw..."
	step_type = FOOTSTEP_MOB_CLAW
	loot = list(/obj/effect/decal/cleanable/blood/gibs/xeno/limb, /obj/effect/decal/cleanable/blood/gibs/xeno/core, /obj/effect/decal/cleanable/blood/xeno/splatter, /obj/effect/decal/cleanable/blood/gibs/xeno/body, /obj/effect/decal/cleanable/blood/gibs/xeno/down)

	ai_controller = /datum/ai_controller/basic_controller/alien

	/// Boolean on whether the xeno can plant weeds.
	var/can_plant_weeds = TRUE
	/// Boolean on whether the xeno can lay eggs.
	var/can_lay_eggs = FALSE

/mob/living/basic/alien/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, emote_list = list("hisses"), emote_chance = 20)

/mob/living/basic/alien/proc/spread_plants()
	if(!isturf(loc) || isspaceturf(loc))
		return
	if(locate(/obj/structure/alien/weeds/node) in get_turf(src))
		return
	visible_message("<span class='alertalien'>[src] has planted some alien weeds!</span>")
	new /obj/structure/alien/weeds/node(loc)

/mob/living/basic/alien/proc/lay_eggs()
	if(!isturf(loc) || isspaceturf(loc))
		return
	if(locate(/obj/structure/alien/egg) in get_turf(src))
		return
	visible_message("<span class='alertalien'>[src] has laid an egg!</span>")
	new /obj/structure/alien/egg(loc)

/mob/living/basic/alien/lavaland
	maximum_survivable_temperature = INFINITY
