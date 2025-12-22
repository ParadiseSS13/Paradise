#define BEE_TRAY_RECENT_VISIT 20 SECONDS /// How long in deciseconds until a tray can be visited by a bee again
#define BEE_DEFAULT_COLOUR "#e5e500" /// the colour we make the stripes of the bee if our reagent has no colour (or we have no reagent)
#define BEE_POLLINATE_YIELD_CHANCE 33 /// chance to increase yield of plant
#define BEE_POLLINATE_PEST_CHANCE 33 /// chance to decrease pest of plant
#define BEE_POLLINATE_POTENCY_CHANCE 50 /// chance to increase potancy of plant
#define BEE_FOODGROUPS RAW | MEAT | GORE | BUGS /// the bee food contents

/mob/living/basic/bee
	name = "bee"
	desc = "Buzzy buzzy bee, stingy sti- Ouch!"
	icon_state = ""
	icon = 'icons/mob/bees.dmi'
	gender = FEMALE
	speak_emote = list("buzzes")

	melee_damage_lower = 1
	melee_damage_upper = 1
	attack_verb_continuous = "stings"
	attack_verb_simple = "sting"
	response_help_continuous = "shoos"
	response_help_simple = "shoo"
	response_disarm_continuous = "swats away"
	response_disarm_simple = "swat away"
	response_harm_continuous = "squashes"
	response_harm_simple = "squash"

	speed = 0.5
	maxHealth = 10
	health = 10
	melee_damage_lower = 1
	melee_damage_upper = 1
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_sound = null // Stings are quiet
	faction = list("hostile")
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	density = FALSE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	gold_core_spawnable = FRIENDLY_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	initial_traits = list(TRAIT_FLYING)
	ai_controller = /datum/ai_controller/basic_controller/bee
	/// the reagent the bee has
	var/datum/reagent/beegent = null
	/// the house we live in
	var/obj/structure/beebox/beehome = null
	/// our icon base
	var/icon_base = "bee"
	/// Icon creation
	var/static/list/bee_icons = list()
	/// the bee is a queen?
	var/is_queen = FALSE
	/// Is this a syndibee?
	var/bee_syndicate = FALSE

/mob/living/basic/bee/Initialize(mapload)
	. = ..()
	generate_bee_visuals()
	AddComponent(/datum/component/swarming)

/mob/living/basic/bee/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/bee/examine(mob/user)
	. = ..()
	if(!bee_syndicate && !beehome)
		. += SPAN_WARNING("This bee is homeless!")

/mob/living/basic/bee/Destroy()
	if(beehome)
		beehome.bees -= src
		beehome = null
	beegent = null
	return ..()

/mob/living/basic/bee/death(gibbed)
	. = ..()
	if(!.)
		return
	if(beehome)
		if(beehome.bees)
			beehome.bees.Remove(src)
		beehome = null

// All bee sprites are made up of overlays. They do not have any special sprite overlays for items placed on them, such as collars, so this proc is unneeded.
/mob/living/basic/bee/regenerate_icons()
	return

/mob/living/basic/bee/proc/generate_bee_visuals()
	overlays.Cut()

	var/col = BEE_DEFAULT_COLOUR
	if(beegent && beegent.color)
		col = beegent.color

	var/image/base
	if(!bee_icons["[icon_base]_base"])
		bee_icons["[icon_base]_base"] = image(icon = 'icons/mob/bees.dmi', icon_state = "[icon_base]_base")
	base = bee_icons["[icon_base]_base"]
	overlays += base

	var/image/greyscale
	if(!bee_icons["[icon_base]_grey_[col]"])
		bee_icons["[icon_base]_grey_[col]"] = image(icon = 'icons/mob/bees.dmi', icon_state = "[icon_base]_grey")
	greyscale = bee_icons["[icon_base]_grey_[col]"]
	greyscale.color = col
	overlays += greyscale

	var/image/wings
	if(!bee_icons["[icon_base]_wings"])
		bee_icons["[icon_base]_wings"] = image(icon = 'icons/mob/bees.dmi', icon_state = "[icon_base]_wings")
	wings = bee_icons["[icon_base]_wings"]
	overlays += wings

/mob/living/basic/bee/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/hydro = target
		pollinate(hydro)
		return FALSE

	if(istype(target, /obj/structure/beebox))
		var/obj/structure/beebox/hive = target
		handle_habitation(hive)
		return FALSE

	. = ..()
	if(. && isliving(target) && (!client || a_intent == INTENT_HARM))
		make_opaque()
		var/mob/living/L = target
		if(L.reagents)
			if(beegent)
				beegent.reaction_mob(L, REAGENT_INGEST)
				L.reagents.add_reagent(beegent.id, rand(1, 5))
			else
				L.reagents.add_reagent("spidertoxin", 5)

/mob/living/basic/bee/proc/make_opaque()
	// If a bee attacks someone, make it very easy to hit for a while
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/mob/living/basic/bee/proc/handle_habitation(obj/structure/beebox/hive)
	if(hive == beehome) // if its our home, we enter or exit it
		var/drop_location = (src in beehome.contents) ? get_turf(beehome) : beehome
		forceMove(drop_location)
		return
	if(!isnull(hive.queen_bee) && is_queen) // if we are queen and house already have a queen, dont inhabit
		return
	if(!hive.habitable(src) || !isnull(beehome)) // if not habitable or we already have a home
		return
	beehome = hive
	beehome.bees += src
	if(is_queen)
		beehome.queen_bee = src

/mob/living/basic/bee/proc/reagent_incompatible(mob/living/basic/bee/ruler)
	if(!ruler)
		return FALSE
	if(ruler.beegent?.type != beegent?.type)
		return TRUE
	return FALSE

/mob/living/basic/bee/proc/pollinate(obj/machinery/hydroponics/Hydro)
	if(!istype(Hydro) || !Hydro.myseed || Hydro.dead || Hydro.recent_bee_visit || Hydro.lid_closed)
		return

	Hydro.recent_bee_visit = TRUE
	addtimer(VARSET_CALLBACK(Hydro, recent_bee_visit, FALSE), BEE_TRAY_RECENT_VISIT)

	var/growth = health // Health also means how many bees are in the swarm, roughly.
	// better healthier plants!
	Hydro.adjustHealth(growth*0.5)
	if(prob(BEE_POLLINATE_PEST_CHANCE))
		Hydro.adjustPests(-10)
	if(prob(BEE_POLLINATE_YIELD_CHANCE) && !Hydro.self_sustaining)
		Hydro.yieldmod = 2

	if(beehome)
		beehome.bee_resources = min(beehome.bee_resources + growth, 100)

/mob/living/basic/bee/proc/assign_reagent(datum/reagent/R)
	if(istype(R))
		beegent = R
		name = "[initial(name)] ([R.name])"
		generate_bee_visuals()

/mob/living/basic/bee/queen
	name = "queen bee"
	desc = "She's the queen of bees, BZZ BZZ!"
	icon_base = "queen"
	is_queen = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	ai_controller = /datum/ai_controller/basic_controller/queen_bee

// leave pollination for the peasent bees
/mob/living/basic/bee/queen/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(. && beegent && isliving(target))
		var/mob/living/L = target
		beegent.reaction_mob(L, REAGENT_TOUCH)
		L.reagents.add_reagent(beegent.id, rand(1, 5))

/mob/living/basic/bee/queen/pollinate()
	return

/obj/item/queen_bee
	name = "queen bee"
	desc = "She's the queen of bees, BZZ BZZ!"
	icon = 'icons/mob/bees.dmi'
	icon_state = "queen_item"
	gender = FEMALE
	new_attack_chain = TRUE
	/// Associated bee mob
	var/mob/living/basic/bee/queen/queen

/obj/item/queen_bee/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(!istype(I, /obj/item/reagent_containers/syringe))
		return ..()
	var/obj/item/reagent_containers/syringe/S = I
	if(S.reagents.has_reagent("royal_bee_jelly")) // We check it twice because if we use an if/else statement, it won't catch the check for blacklisted chemicals below
		if(!S.reagents.has_reagent("royal_bee_jelly", 5))
			to_chat(user, SPAN_WARNING("You don't have enough royal bee jelly to split a bee in two!"))
			return
		S.reagents.remove_reagent("royal_bee_jelly", 5)
		var/obj/item/queen_bee/qb = new(user.drop_location())
		qb.queen = new(qb)
		if(queen?.beegent)
			qb.queen.assign_reagent(queen.beegent) //Bees use the global singleton instances of reagents, so we don't need to worry about one bee being deleted and her copies losing their reagents.
		user.put_in_active_hand(qb)
		user.visible_message(SPAN_NOTICE("[user] injects [src] with royal bee jelly, causing it to split into two bees, MORE BEES!"), SPAN_WARNING("You inject [src] with royal bee jelly, causing it to split into two bees, MORE BEES!"))
		return

	var/datum/reagent/R = GLOB.chemical_reagents_list[S.reagents.get_master_reagent_id()]
	if(R && S.reagents.has_reagent(R.id, 5))
		S.reagents.remove_reagent(R.id, 5) // Whether or not the chemical is blocked, we want it gone just because you tried to
		if(R.id in GLOB.blocked_chems)
			to_chat(user, SPAN_WARNING("The [src]'s immune system rejects [R.name]!"))
			return
		queen.assign_reagent(R)
		user.visible_message(SPAN_WARNING("[user] injects [src]'s genome with [R.name], mutating its DNA!"), SPAN_WARNING("You inject [src]'s genome with [R.name], mutating its DNA!"))
		name = queen.name
	else
		to_chat(user, SPAN_WARNING("You don't have enough units of that chemical to modify the bee's DNA!"))

/obj/item/queen_bee/bought/Initialize(mapload)
	. = ..()
	queen = new(src)

/obj/item/queen_bee/Destroy()
	QDEL_NULL(queen)
	return ..()

// Syndicate Bees
/mob/living/basic/bee/syndi
	name = "syndi-bee"
	desc = "The result of a large influx of BEES!"
	melee_damage_lower = 5
	melee_damage_upper = 5
	maxHealth = 25
	health = 25
	faction = list("hostile", "syndicate")
	bee_syndicate = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	ai_controller = /datum/ai_controller/basic_controller/syndibee

/mob/living/basic/bee/syndi/Initialize(mapload)
	. = ..()
	beegent = GLOB.chemical_reagents_list["facid"] // Prepare to die

/mob/living/basic/bee/syndi/assign_reagent(datum/reagent/R)
	return

/mob/living/basic/bee/syndi/pollinate() // No Pollination
	return

#undef BEE_TRAY_RECENT_VISIT
#undef BEE_DEFAULT_COLOUR
#undef BEE_POLLINATE_YIELD_CHANCE
#undef BEE_POLLINATE_PEST_CHANCE
#undef BEE_POLLINATE_POTENCY_CHANCE
#undef BEE_FOODGROUPS
