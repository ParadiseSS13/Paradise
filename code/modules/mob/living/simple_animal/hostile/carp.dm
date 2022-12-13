#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin for megacarps (ty robustin!)

/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/carpmeat = 2)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25

	harm_intent_damage = 8
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "кусает"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")
	tts_seed = "Peon"

	//Space carp aren't affected by atmos.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("carp")
	flying = TRUE
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN

	var/random_color = TRUE //if the carp uses random coloring
	var/rarechance = 1 //chance for rare color variant

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

/mob/living/simple_animal/hostile/carp/Initialize(mapload)
	. = ..()
	carp_randomify(rarechance)
	update_icons()

/mob/living/simple_animal/hostile/carp/proc/carp_randomify(rarechance)
	if(random_color)
		var/our_color
		if(prob(rarechance))
			our_color = pick(carp_colors_rare)
			add_atom_colour(carp_colors_rare[our_color], FIXED_COLOUR_PRIORITY)
		else
			our_color = pick(carp_colors)
			add_atom_colour(carp_colors[our_color], FIXED_COLOUR_PRIORITY)
		regenerate_icons()

/mob/living/simple_animal/hostile/carp/proc/add_carp_overlay()
	if(!random_color)
		return
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "base_mouth")
	base_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)

/mob/living/simple_animal/hostile/carp/proc/add_dead_carp_overlay()
	if(!random_color)
		return
	var/mutable_appearance/base_dead_overlay = mutable_appearance(icon, "base_dead_mouth")
	base_dead_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_dead_overlay)

/mob/living/simple_animal/hostile/carp/Process_Spacemove(movement_dir = 0)
	return TRUE	//No drifting in space for space carp!	//original comments do not steal

/mob/living/simple_animal/hostile/carp/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustStaminaLoss(8)

/mob/living/simple_animal/hostile/carp/death(gibbed)
	. = ..()
	if(!random_color || gibbed)
		return
	regenerate_icons()

/mob/living/simple_animal/hostile/carp/revive()
	..()
	regenerate_icons()

/mob/living/simple_animal/hostile/carp/regenerate_icons()
	..()
	if(!random_color)
		return
	if(stat != DEAD)
		add_carp_overlay()
	else
		add_dead_carp_overlay()

/mob/living/simple_animal/hostile/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	maxbodytemp = INFINITY
	gold_core_spawnable = NO_SPAWN
	del_on_death = 1
	random_color = FALSE

/mob/living/simple_animal/hostile/carp/megacarp
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
	tts_seed = "Shaker"

/mob/living/simple_animal/hostile/carp/megacarp/Initialize()
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage_lower += rand(2, 10)
	melee_damage_upper += rand(10, 20)
	maxHealth += rand(30, 60)
	move_to_delay = rand(3, 7)

/mob/living/simple_animal/hostile/carp/megacarp/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/mob/living/simple_animal/hostile/carp/megacarp/Life()
	..()
	if(regen_cooldown < world.time)
		heal_overall_damage(4)

/mob/living/simple_animal/hostile/carp/sea
	name = "sea carp"
	desc = "A large fish bearing similarities to a certain space-faring menace."
	icon_state = "carp"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/carpmeat = 1)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	retreat_distance = 6
	vision_range = 5
	retaliate_only = TRUE
	minbodytemp = 250
	maxbodytemp = 350
	gold_core_spawnable = NO_SPAWN
	var/carp_color = "carp" //holder for icon set

/mob/living/simple_animal/hostile/carp/koi
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
	butcher_results = list(/obj/item/reagent_containers/food/snacks/salmonmeat = 1)

	var/randomize_icon = TRUE

	retaliate_only = TRUE

/mob/living/simple_animal/hostile/carp/koi/Initialize(mapload)
	. = ..()
	if(randomize_icon)
		var/koinum = rand(1, 4)
		icon_state = "koi[koinum]"
		icon_living = "koi[koinum]"
		icon_dead = "koi[koinum]-dead"

/mob/living/simple_animal/hostile/carp/koi/honk
	icon_state = "koi5"
	icon_living = "koi5"
	icon_dead = "koi5-dead"
	randomize_icon = FALSE
	retaliate_only = TRUE

#undef REGENERATION_DELAY
