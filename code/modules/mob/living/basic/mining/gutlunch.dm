/// Gutlunches, passive mods that devour blood and gibs
/mob/living/basic/mining/gutlunch
	name = "gutlunch"
	desc = "A scavenger that eats raw meat, often found alongside ash walkers. Produces a thick, medicinally nutritious milk."
	icon_state = "gutlunch"
	icon_living = "gutlunch"
	icon_dead = "gutlunch"
	speak_emote = list("warbles", "quavers")
	weather_immunities = list("lava","ash")
	faction = list("mining", "ashwalker")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "squishes"
	response_harm_simple = "squish"
	friendly_verb_continuous = "pinches"
	friendly_verb_simple = "pinch"
	density = FALSE
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	a_intent = INTENT_HELP
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	deathmessage = "is pulped into bugmash."

	ai_controller = /datum/ai_controller/basic_controller/gutlunch

	var/list/food_types = list(
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/kidneys,
		/obj/item/organ/internal/appendix
	)
	var/obj/item/udder/gutlunch/udder
	/// can we breed?
	var/can_breed = TRUE

/mob/living/basic/mining/gutlunch/Initialize(mapload)
	. = ..()
	udder = new()
	// Have all eating components share the same exact list per mob subtype
	var/static/list/static_food_types
	if(!static_food_types)
		static_food_types = food_types.Copy()

	AddElement(/datum/element/basic_eating, food_types_ = static_food_types)
	AddElement(/datum/element/ai_retaliate)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(static_food_types))
	if(can_breed)
		add_breeding_component()

/mob/living/basic/mining/gutlunch/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/basic/mining/gutlunch/regenerate_icons()
	..()
	if(udder.reagents.total_volume == udder.reagents.maximum_volume)
		add_overlay("gl_full")

/mob/living/basic/mining/gutlunch/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(stat == CONSCIOUS && istype(O, /obj/item/reagent_containers/glass))
		udder.milkAnimal(O, user)
		regenerate_icons()
		return ITEM_INTERACT_COMPLETE

/obj/item/udder/gutlunch
	name = "nutrient sac"

/obj/item/udder/gutlunch/generateMilk()
	if(prob(60))
		reagents.add_reagent("cream", rand(2, 5))
	if(prob(45))
		reagents.add_reagent("salglu_solution", rand(2, 5))
	if(prob(30))
		reagents.add_reagent("epinephrine", rand(2, 5))


/mob/living/basic/mining/gutlunch/proc/add_breeding_component()
	var/static/list/partner_paths = typecacheof(list(/mob/living/basic/mining/gutlunch))
	var/static/list/baby_paths = list(
		/mob/living/basic/mining/gutlunch/grublunch = 1,
	)

	AddComponent(\
		/datum/component/breed,\
		can_breed_with = partner_paths,\
		baby_paths = baby_paths,\
		breed_timer = 3 MINUTES,\
	)

// Male gutlunch. They're smaller and more colorful!
/mob/living/basic/mining/gutlunch/gubbuck
	name = "gubbuck"
	gender = MALE
	ai_controller = /datum/ai_controller/basic_controller/gutlunch/gubbuck

/mob/living/basic/mining/gutlunch/gubbuck/Initialize(mapload)
	. = ..()
	add_atom_colour(pick("#E39FBB", "#D97D64", "#CF8C4A"), FIXED_COLOUR_PRIORITY)
	resize = 0.85
	update_transform()

/// Lady gutlunch. They make the babby.
/mob/living/basic/mining/gutlunch/guthen
	name = "guthen"
	gender = FEMALE
	ai_controller = /datum/ai_controller/basic_controller/gutlunch/guthen

/// Baby gutlunch
/mob/living/basic/mining/gutlunch/grublunch
	name = "grublunch"
	food_types = list() //They don't eat.
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/gutlunch/gutlunch_baby
	var/growth = 0

/mob/living/basic/mining/gutlunch/grublunch/Initialize(mapload)
	. = ..()
	add_atom_colour("#9E9E9E", FIXED_COLOUR_PRIORITY) // Somewhat hidden
	resize = 0.45
	update_transform()

/mob/living/basic/mining/gutlunch/grublunch/Life()
	..()
	growth++
	if(growth > 50) //originally used a timer for this but was more problem that it's worth.
		growUp()

/mob/living/basic/mining/gutlunch/grublunch/proc/growUp()
	var/mob/living/L
	if(prob(45))
		L = new /mob/living/basic/mining/gutlunch/gubbuck(loc)
	else
		L = new /mob/living/basic/mining/gutlunch/guthen(loc)
	mind?.transfer_to(L)
	L.faction = faction.Copy()
	L.setDir(dir)
	visible_message("<span class='notice'>[src] grows up into [L].</span>")
	qdel(src)
