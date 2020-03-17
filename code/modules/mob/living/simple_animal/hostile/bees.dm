#define BEE_IDLE_ROAMING		70 //The value of idle at which a bee in a beebox will try to wander
#define BEE_IDLE_GOHOME			0  //The value of idle at which a bee will try to go home
#define BEE_PROB_GOHOME			35 //Probability to go home when idle is below BEE_IDLE_GOHOME
#define BEE_PROB_GOROAM			5 //Probability to go roaming when idle is above BEE_IDLE_ROAMING
#define BEE_TRAY_RECENT_VISIT	200	//How long in deciseconds until a tray can be visited by a bee again
#define BEE_DEFAULT_COLOUR		"#e5e500" //the colour we make the stripes of the bee if our reagent has no colour (or we have no reagent)

#define BEE_POLLINATE_YIELD_CHANCE		33
#define BEE_POLLINATE_PEST_CHANCE		33
#define BEE_POLLINATE_POTENCY_CHANCE	50

/mob/living/simple_animal/hostile/poison/bees
	name = "bee"
	desc = "Buzzy buzzy bee, stingy sti- Ouch!"
	icon_state = ""
	icon_living = ""
	icon = 'icons/mob/bees.dmi'
	gender = FEMALE
	speak_emote = list("buzzes")
	emote_hear = list("buzzes")
	turns_per_move = 0
	melee_damage_lower = 1
	melee_damage_upper = 1
	attacktext = "stings"
	response_help  = "shoos"
	response_disarm = "swats away"
	response_harm   = "squashes"
	maxHealth = 10
	health = 10
	faction = list("hostile")
	move_to_delay = 0
	obj_damage = 0
	environment_smash = 0
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_TINY
	flying = TRUE
	gold_core_spawnable = HOSTILE_SPAWN
	search_objects = TRUE //have to find those plant trays!

	//Spaceborn beings don't get hurt by space
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	del_on_death = TRUE

	var/datum/reagent/beegent = null //hehe, beegent
	var/obj/structure/beebox/beehome = null
	var/idle = 0
	var/isqueen = FALSE
	var/bee_syndicate = FALSE
	var/icon_base = "bee"
	var/static/list/bee_icons = list()
	var/static/beehometypecache = typecacheof(/obj/structure/beebox)
	var/static/hydroponicstypecache = typecacheof(/obj/machinery/hydroponics)

/mob/living/simple_animal/hostile/poison/bees/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/hostile/poison/bees/New()
	..()
	generate_bee_visuals()

/mob/living/simple_animal/hostile/poison/bees/Destroy()
	beegent = null
	if(beehome)
		if(beehome.bees)
			beehome.bees.Remove(src)
		beehome = null
	return ..()

/mob/living/simple_animal/hostile/poison/bees/death(gibbed)
	. = ..()
	if(!.)
		return
	if(beehome)
		if(beehome.bees)
			beehome.bees.Remove(src)
		beehome = null

/mob/living/simple_animal/hostile/poison/bees/examine(mob/user)
	. = ..()
	if(!bee_syndicate && !beehome)
		. += "<span class='warning'>This bee is homeless!</span>"

/mob/living/simple_animal/hostile/poison/bees/ListTargets() // Bee processing is expessive, so we override them finding targets here.
	if(!search_objects) //In case we want to have purely hostile bees
		return ..()
	else
		. = list() // The following code is only very slightly slower than just returning oview(vision_range, targets_from), but it saves us much more work down the line
		var/list/searched_for = oview(vision_range, targets_from)
		for(var/obj/A in searched_for)
			. += A
		for(var/mob/A in searched_for)
			. += A

/mob/living/simple_animal/hostile/poison/bees/proc/generate_bee_visuals()
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

//We don't attack beekeepers/people dressed as bees//Todo: bee costume
/mob/living/simple_animal/hostile/poison/bees/CanAttack(atom/the_target)
	. = ..()
	if(!.)
		return FALSE
	if(!bee_syndicate && isliving(the_target))
		var/mob/living/H = the_target
		return !H.bee_friendly()

/mob/living/simple_animal/hostile/poison/bees/Found(atom/A)
	if(isliving(A))
		var/mob/living/H = A
		return !H.bee_friendly()
	if(istype(A, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/Hydro = A
		if(Hydro.myseed && !Hydro.dead && !Hydro.recent_bee_visit)
			wanted_objects |= hydroponicstypecache //so we only hunt them while they're alive/seeded/not visisted
			return TRUE
	return FALSE

/mob/living/simple_animal/hostile/poison/bees/AttackingTarget()
 	//Pollinate
	if(istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/Hydro = target
		pollinate(Hydro)
	else if(istype(target, /obj/structure/beebox))
		if(target == beehome)
			var/obj/structure/beebox/BB = target
			forceMove(BB)
			toggle_ai(AI_IDLE)
			target = null
			wanted_objects -= beehometypecache //so we don't attack beeboxes when not going home
		return //no don't attack the goddamm box
	else
		. = ..()
		if(. && isliving(target) && (!client || a_intent == INTENT_HARM))
			var/mob/living/L = target
			if(L.reagents)
				if(beegent)
					beegent.reaction_mob(L, REAGENT_INGEST)
					L.reagents.add_reagent(beegent.id, rand(1, 5))
				else
					L.reagents.add_reagent("spidertoxin", 5)

/mob/living/simple_animal/hostile/poison/bees/proc/assign_reagent(datum/reagent/R)
	if(istype(R))
		beegent = R
		name = "[initial(name)] ([R.name])"
		generate_bee_visuals()

/mob/living/simple_animal/hostile/poison/bees/proc/pollinate(obj/machinery/hydroponics/Hydro)
	if(!istype(Hydro) || !Hydro.myseed || Hydro.dead || Hydro.recent_bee_visit || Hydro.lid_state)
		target = null
		return

	target = null //so we pick a new hydro tray next FindTarget(), instead of loving the same plant for eternity
	wanted_objects -= hydroponicstypecache //so we only hunt them while they're alive/seeded/not visisted
	Hydro.recent_bee_visit = TRUE
	spawn(BEE_TRAY_RECENT_VISIT)
		if(Hydro)
			Hydro.recent_bee_visit = FALSE

	var/growth = health //Health also means how many bees are in the swarm, roughly.
	//better healthier plants!
	Hydro.adjustHealth(growth*0.5)
	if(prob(BEE_POLLINATE_PEST_CHANCE))
		Hydro.adjustPests(-10)
	if(prob(BEE_POLLINATE_YIELD_CHANCE))
		Hydro.myseed.adjust_yield(1)
		Hydro.yieldmod = 2
	if(prob(BEE_POLLINATE_POTENCY_CHANCE))
		Hydro.myseed.adjust_potency(1)

	if(beehome)
		beehome.bee_resources = min(beehome.bee_resources + growth, 100)

/mob/living/simple_animal/hostile/poison/bees/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(!bee_syndicate)
		if(!isqueen)
			if(loc == beehome)
				idle = min(100, ++idle)
				if(idle >= BEE_IDLE_ROAMING && prob(BEE_PROB_GOROAM))
					forceMove(beehome.drop_location())
			else
				idle = max(0, --idle)
				if(idle <= BEE_IDLE_GOHOME && prob(BEE_PROB_GOHOME))
					if(!FindTarget())
						wanted_objects |= beehometypecache //so we don't attack beeboxes when not going home
						target = beehome
		if(!beehome) //add ourselves to a beebox (of the same reagent) if we have no home
			for(var/obj/structure/beebox/BB in view(vision_range, src))
				if(reagent_incompatible(BB.queen_bee) || BB.bees.len >= BB.get_max_bees())
					continue
				BB.bees |= src
				beehome = BB
				break // End loop after the first compatible find.

//Botany Queen Bee
/mob/living/simple_animal/hostile/poison/bees/queen
 	name = "queen bee"
 	desc = "She's the queen of bees, BZZ BZZ"
 	icon_base = "queen"
 	isqueen = TRUE


//the Queen doesn't leave the box on her own, and she CERTAINLY doesn't pollinate by herself
/mob/living/simple_animal/hostile/poison/bees/queen/Found(atom/A)
	return FALSE

//leave pollination for the peasent bees
/mob/living/simple_animal/hostile/poison/bees/queen/AttackingTarget()
	. = ..()
	if(. && beegent && isliving(target))
		var/mob/living/L = target
		beegent.reaction_mob(L, REAGENT_TOUCH)
		L.reagents.add_reagent(beegent.id, rand(1, 5))

//PEASENT BEES
/mob/living/simple_animal/hostile/poison/bees/queen/pollinate()
	return

/mob/living/simple_animal/hostile/poison/bees/proc/reagent_incompatible(mob/living/simple_animal/hostile/poison/bees/B)
	if(!B)
		return FALSE
	if(B.beegent && beegent && B.beegent.id != beegent.id || B.beegent && !beegent || !B.beegent && beegent)
		return TRUE
	return FALSE


/obj/item/queen_bee
	name = "queen bee"
	desc = "She's the queen of bees, BZZ BZZ"
	icon_state = "queen_item"
	item_state = ""
	icon = 'icons/mob/bees.dmi'
	var/mob/living/simple_animal/hostile/poison/bees/queen/queen


/obj/item/queen_bee/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I
		if(S.reagents.has_reagent("royal_bee_jelly")) //checked twice, because I really don't want royal bee jelly to be duped
			if(S.reagents.has_reagent("royal_bee_jelly", 5))
				S.reagents.remove_reagent("royal_bee_jelly", 5)
				var/obj/item/queen_bee/qb = new(user.drop_location())
				qb.queen = new(qb)
				if(queen && queen.beegent)
					qb.queen.assign_reagent(queen.beegent) //Bees use the global singleton instances of reagents, so we don't need to worry about one bee being deleted and her copies losing their reagents.
				user.put_in_active_hand(qb)
				user.visible_message("<span class='notice'>[user] injects [src] with royal bee jelly, causing it to split into two bees, MORE BEES!</span>","<span class ='warning'>You inject [src] with royal bee jelly, causing it to split into two bees, MORE BEES!</span>")
			else
				to_chat(user, "<span class='warning'>You don't have enough royal bee jelly to split a bee in two!</span>")
		else
			var/datum/reagent/R = GLOB.chemical_reagents_list[S.reagents.get_master_reagent_id()]
			if(R && S.reagents.has_reagent(R.id, 5))
				S.reagents.remove_reagent(R.id, 5)
				queen.assign_reagent(R)
				user.visible_message("<span class='warning'>[user] injects [src]'s genome with [R.name], mutating its DNA!</span>", "<span class='warning'>You inject [src]'s genome with [R.name], mutating its DNA!</span>")
				name = queen.name
			else
				to_chat(user, "<span class='warning'>You don't have enough units of that chemical to modify the bee's DNA!</span>")
	else
		return ..()

/obj/item/queen_bee/bought/Initialize(mapload)
	. = ..()
	queen = new(src)

/obj/item/queen_bee/Destroy()
	QDEL_NULL(queen)
	return ..()

/mob/living/simple_animal/hostile/poison/bees/consider_wakeup()
	if(beehome && loc == beehome) // If bees are chilling in their nest, they're not actively looking for targets
		idle = min(100, ++idle)
		if(idle >= BEE_IDLE_ROAMING && prob(BEE_PROB_GOROAM))
			toggle_ai(AI_ON)
			forceMove(beehome.drop_location())
	else
		..()

//Syndicate Bees
/mob/living/simple_animal/hostile/poison/bees/syndi
	name = "syndi-bee"
	desc = "The result of a large influx of BEES!"
	melee_damage_lower = 5
	melee_damage_upper = 5
	maxHealth = 25
	health = 25
	faction = list("hostile", "syndicate")
	search_objects = FALSE //these bees don't care about trivial things like plants, especially when there is havoc to sow
	bee_syndicate = TRUE
	var/list/master_and_friends = list()

/mob/living/simple_animal/hostile/poison/bees/syndi/New()
	beegent = GLOB.chemical_reagents_list["facid"] //Prepare to die
	..()

/mob/living/simple_animal/hostile/poison/bees/syndi/Destroy()
	master_and_friends.Cut()
	return ..()

/mob/living/simple_animal/hostile/poison/bees/syndi/assign_reagent(datum/reagent/R)
	return

/mob/living/simple_animal/hostile/poison/bees/syndi/pollinate() // No Pollination
	return

/mob/living/simple_animal/hostile/poison/bees/syndi/Found(atom/A) //Typical usual hostile mob targeting list
	return

/mob/living/simple_animal/hostile/poison/bees/syndi/CanAttack(atom/the_target)
	. = ..()
	if(!.)
		return FALSE
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H in master_and_friends)
				return FALSE
		return TRUE

/mob/living/simple_animal/hostile/poison/bees/syndi/AttackingTarget()
	. = ..()
	if(. && target && isliving(target))
		var/mob/living/L = target
		if(L.stat)
			LoseTarget()
