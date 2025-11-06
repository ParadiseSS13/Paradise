#define MARAUDER_SHIELD_MAX 4

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder
	name = "clockwork marauder"
	desc = "A brass machine of destruction,"
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "clockwork_marauder"
	icon_living = "clockwork_marauder"
	icon_dead = "clockwork_marauder_dead"
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	see_in_dark = 8
	health = 140
	maxHealth = 140
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	initial_traits = list(TRAIT_FLYING)
	move_resist = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	pass_flags = PASSTABLE
	damage_coeff = list("brute" = 1, "fire" = 1, "tox" = 0, "clone" = 0, "stamina" = 0, "oxy" = 0)
	obj_damage = 80
	melee_damage_lower = 24
	melee_damage_upper = 24
	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	chat_color = "#CAA25B"
	retreat_distance = 2 // Dodge in and out of combat.
	faction = list("hostile") // We hate Nar'sie here, but no clockcult yet.
	pressure_resistance = 100
	universal_speak = TRUE
	AIStatus = AI_OFF
	loot = list(/obj/item/food/ectoplasm, /obj/item/clockwork/component/geis_capacitor/fallen_armor)
	del_on_death = TRUE
	deathmessage = "collapses in a shattered heap."
	var/playstyle_string = "<b>You are a Marauder, an instrument of destruction built to fight those that oppose the will of Ratvar. \
						You are a highly effective melee combatent but are vulnerable to holy weapons. \
						You can block up to 4 ranged attacks with your shield. It requires a welder to be repaired.</b>"
	var/list/construct_spells = list(/datum/spell/night_vision)
	var/shield_health = MARAUDER_SHIELD_MAX

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/Initialize(mapload)
	. = ..()
	name = "[name] ([rand(1, 1000)])"
	set_light(2, 3, l_color = LIGHT_COLOR_FIRE)
	for(var/spell in construct_spells)
		AddSpell(new spell(null))

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/death(gibbed)
	new /obj/effect/temp_visual/cult/sparks(get_turf(src))
	playsound(src, 'sound/effects/pylon_shatter.ogg', 40, TRUE)
	return ..()

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/attacked_by(obj/item/I, mob/living/user)
	if(..())
		return FINISH_ATTACK

	if(istype(I, /obj/item/nullrod))
		adjustFireLoss(15)
		if(shield_health > 0)
			damage_shield()
		playsound(src,'sound/hallucinations/veryfar_noise.ogg', 40, 1)

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/bullet_act(obj/item/projectile/Proj)
	if(shield_health > 0)
		damage_shield()
		to_chat(src, "<span class='danger'>Your shield blocks the attack!</span>")
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/proc/damage_shield()
	shield_health--
	playsound(src, 'sound/magic/clockwork/anima_fragment_attack.ogg', 60, TRUE)
	if(shield_health == 0)
		to_chat(src, "<span class='userdanger'>Your shield breaks!</span>")
		to_chat(src, "<span class='danger'>You require a welding tool to repair your damaged shield!</span>")

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/welder_act(mob/living/user, obj/item/I)
	if(health >= maxHealth && shield_health >= MARAUDER_SHIELD_MAX)
		to_chat(user, "<span class='notice'>[src] has no damage to repair.</span>")
		return

	playsound(loc, 'sound/items/welder.ogg', 150, TRUE)
	adjustBruteLoss(-10)
	user.visible_message(
		"<span class='notice'>You repair some of [src]'s damage.</span>",
		"<span class='notice'>[user] repairs some of [src]'s damage.</span>"
	)
	if(shield_health < MARAUDER_SHIELD_MAX)
		shield_health ++
		playsound(src, 'sound/magic/charge.ogg', 60, TRUE)
	return TRUE

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/narsie_act()
	visible_message(
		"<span class='danger'>[src] is instantly crushed by an unholy aura!</span>",
		"<span class='userdanger'>The uncaring gaze of a dark god looks down upon you for a single moment, and your shell is instantly pulverized into dust!</span>"
	)
	gib()

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	return FALSE

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/Life(seconds, times_fired)
	if(holy_check(src))
		throw_alert("holy_fire", /atom/movable/screen/alert/holy_fire, override = TRUE)
		visible_message(
			"<span class='danger'>[src] slowly crumbles to dust in this holy place!</span>", \
			"<span class='danger'>Your shell burns as you crumble to dust in this holy place!</span>"
		)
		playsound(loc, 'sound/items/welder.ogg', 150, TRUE)
		adjustBruteLoss(maxHealth/8)
	else
		clear_alert("holy_fire", clear_override = TRUE)
	return ..()

/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/hostile
	AIStatus = AI_ON

#undef MARAUDER_SHIELD_MAX
