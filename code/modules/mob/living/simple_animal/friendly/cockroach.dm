/mob/living/simple_animal/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach"
	health = 1
	maxHealth = 1
	turns_per_move = 5
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	mob_size = MOB_SIZE_TINY
	response_help  = "pokes"
	response_disarm = "shoos"
	response_harm   = "splats"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	var/squish_chance = 50
	loot = list(/obj/effect/decal/cleanable/insectguts)
	del_on_death = TRUE

/mob/living/simple_animal/cockroach/can_die()
	return ..() && !SSticker.cinematic //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.

/mob/living/simple_animal/cockroach/Initialize(mapload) //Lizards are a great way to deal with cockroaches
	. = ..()
	ADD_TRAIT(src, TRAIT_EDIBLE_BUG, "edible_bug")
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/cockroach/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(isliving(entered))
		var/mob/living/A = entered
		if(A.mob_size > MOB_SIZE_SMALL)
			if(prob(squish_chance))
				A.visible_message("<span class='notice'>\The [A] squashed \the [name].</span>", "<span class='notice'>You squashed \the [name].</span>")
				death()
			else
				visible_message("<span class='notice'>\The [name] avoids getting crushed.</span>")
	else if(isstructure(entered))
		visible_message("<span class='notice'>As \the [entered] moved over \the [name], it was crushed.</span>")
		death()

/mob/living/simple_animal/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return

//mining pet
/mob/living/simple_animal/cockroach/brad
	name = "Brad"
	desc = "Lavaland's most resilient cockroach. Seeing this little guy walk through the wastes almost makes you wish for nuclear winter."
	response_help = "carefully pets"
	weather_immunities = list("ash")
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
