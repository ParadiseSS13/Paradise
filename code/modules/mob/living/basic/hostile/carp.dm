#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin for megacarps

/mob/living/basic/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	butcher_results = list(/obj/item/food/carpmeat = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	speed = 0
	maxHealth = 25
	health = 25

	harm_intent_damage = 8
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles

	// Space carp aren't affected by atmos.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	faction = list("carp", "mining")
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN

	initial_traits = list(TRAIT_FLYING, TRAIT_SHOCKIMMUNE)

	var/random_color = TRUE // if the carp uses random coloring
	var/rarechance = 1 // chance for rare color variant

	var/static/list/carp_colors = list(\
	"lightpurple" = "#c3b9f1", \
	"lightpink" = "#da77a8", \
	"green" = "#70ff25", \
	"grape" = "#df0afb", \
	"swamp" = "#e5e75a", \
	"turquoise" = "#04e1ed", \
	"brown" = "#ca805a", \
	"teal" = "#20e28e", \
	"lightblue" = "#4d88cc", \
	"rusty" = "#dd5f34", \
	"beige" = "#bbaeaf", \
	"yellow" = "#f3ca4a", \
	"blue" = "#09bae1", \
	"palegreen" = "#7ef099", \
	)
	var/static/list/carp_colors_rare = list(\
	"silver" = "#fdfbf3", \
	)

/mob/living/basic/carp/Initialize(mapload)
	. = ..()
	carp_randomify(rarechance)
	AddComponent(/datum/component/aggro_emote, emote_list = list("gnashes"))

/mob/living/basic/carp/proc/carp_randomify(rarechance)
	if(random_color)
		var/our_color
		if(prob(rarechance))
			our_color = pick(carp_colors_rare)
			add_atom_colour(carp_colors_rare[our_color], FIXED_COLOUR_PRIORITY)
		else
			our_color = pick(carp_colors)
			add_atom_colour(carp_colors[our_color], FIXED_COLOUR_PRIORITY)
		update_icon()

/mob/living/basic/carp/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE	// No drifting in space for space carp!	//original comments do not steal

/mob/living/basic/carp/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_damage(8, STAMINA)

/mob/living/basic/carp/death(gibbed)
	. = ..()
	if(!random_color || gibbed)
		return
	update_icon()

/mob/living/basic/carp/revive()
	..()
	update_icon()

/mob/living/basic/carp/update_overlays()
	. = ..()
	if(!random_color)
		return

	. += mutable_appearance(icon, "base_[stat == DEAD ? "dead_" : ""]mouth", appearance_flags = RESET_COLOR)

/mob/living/basic/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	maximum_survivable_temperature = INFINITY
	gold_core_spawnable = NO_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	random_color = FALSE

/mob/living/basic/carp/megacarp
	icon = 'icons/mob/alienqueen.dmi'
	name = "Mega Space Carp"
	desc = "A ferocious, fang bearing creature that resembles a shark. This one seems especially ticked off."
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	maxHealth = 20
	health = 20
	pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	random_color = FALSE

	obj_damage = 80
	melee_damage_lower = 20
	melee_damage_upper = 20

	var/regen_cooldown = 0

	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/megacarp

/mob/living/basic/carp/megacarp/Initialize(mapload)
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage_lower += rand(2, 10)
	melee_damage_upper += rand(10, 20)
	maxHealth += rand(30, 60)

/mob/living/basic/carp/megacarp/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/mob/living/basic/carp/megacarp/Life()
	..()
	if(regen_cooldown < world.time)
		heal_overall_damage(4)

#undef REGENERATION_DELAY
