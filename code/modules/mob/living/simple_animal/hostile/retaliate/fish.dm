
/mob/living/simple_animal/hostile/retaliate/carp
	name = "sea carp"
	desc = "A large fish bearing similarities to a certain space-faring menace."
	icon = 'icons/mob/carp.dmi'
	icon_state = "carp"
	icon_gib = "carp_gib"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	turns_per_move = 5
	butcher_results = list(/obj/item/food/carpmeat = 1)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	speed = 0
	maxHealth = 25
	health = 25
	retreat_distance = 6
	vision_range = 5
	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")
	faction = list("carp")
	initial_traits = list(TRAIT_FLYING)

	var/carp_color = "carp" //holder for icon set
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

/mob/living/simple_animal/hostile/retaliate/carp/Initialize(mapload)
	. = ..()
	carp_randomify()
	update_icons()

/mob/living/simple_animal/hostile/retaliate/carp/proc/carp_randomify(rarechance)
	// Simplified version of: /mob/living/basic/carp/proc/carp_randomify(rarechance)
	var/our_color
	our_color = pick(carp_colors)
	add_atom_colour(carp_colors[our_color], FIXED_COLOUR_PRIORITY)
	regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/carp/koi
	name = "space koi"
	desc = "A gentle space-faring koi."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "koi1"
	icon_living = "koi1"
	icon_dead = "koi1-dead"

	harm_intent_damage = 1
	melee_damage_lower = 2
	melee_damage_upper = 2
	speak_emote = list("blurps")
	butcher_results = list(/obj/item/food/salmonmeat = 1)

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	gold_core_spawnable = HOSTILE_SPAWN
	var/randomize_icon = TRUE

/mob/living/simple_animal/hostile/retaliate/carp/koi/Initialize(mapload)
	. = ..()
	if(randomize_icon)
		var/koinum = rand(1, 4)
		icon_state = "koi[koinum]"
		icon_living = "koi[koinum]"
		icon_dead = "koi[koinum]-dead"

/mob/living/simple_animal/hostile/retaliate/carp/koi/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/hostile/retaliate/carp/koi/honk
	icon_state = "koi5"
	icon_living = "koi5"
	icon_dead = "koi5-dead"
	randomize_icon = FALSE
