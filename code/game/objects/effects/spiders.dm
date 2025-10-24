/obj/structure/spider
	name = "web"
	desc = "it's stringy and sticky."
	icon = 'icons/effects/effects.dmi'
	icon_state = "stickyweb1"
	anchored = TRUE
	max_integrity = 15
	cares_about_temperature = TRUE
	var/mob/living/carbon/human/master_commander = null

/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)//the stickiness of the web mutes all attack sounds except fire damage type
		playsound(loc, 'sound/items/welder.ogg', 100, TRUE)


/obj/structure/spider/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BURN)
				damage_amount *= 2
			if(BRUTE)
				damage_amount *= 0.25
	. = ..()

/obj/structure/spider/Destroy()
	master_commander = null
	return ..()

/obj/structure/spider/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/spider/stickyweb

/obj/structure/spider/stickyweb/Initialize(mapload)
	. = ..()
	if(prob(50))
		icon_state = "stickyweb2"

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_atom_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/spider/stickyweb/proc/on_atom_exit(datum/source, atom/exiter)
	if(istype(exiter, /mob/living/basic/giant_spider) || isterrorspider(exiter))
		return
	if(isliving(exiter) && prob(50))
		to_chat(exiter, "<span class='danger'>You get stuck in [src] for a moment.</span>")
		return COMPONENT_ATOM_BLOCK_EXIT
	if(isprojectile(exiter) && prob(30))
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	icon_state = "eggs"
	var/amount_grown = 0
	var/player_spiders = FALSE
	var/list/faction = list("spiders")
	flags_2 = CRITICAL_ATOM_2

/obj/structure/spider/eggcluster/Initialize(mapload)
	. = ..()
	pixel_x = rand(3,-3)
	pixel_y = rand(3,-3)
	START_PROCESSING(SSobj, src)

/obj/structure/spider/eggcluster/process()
	if(SSmobs.xenobiology_mobs > MAX_GOLD_CORE_MOBS - 10) //eggs gonna chill out until there is less spiders
		return

	amount_grown += rand(0, 2)

	if(amount_grown >= 100)
		var/num = rand(3, 12)
		for(var/i in 1 to num)
			var/mob/living/basic/spiderling/S = new /mob/living/basic/spiderling(loc)
			S.faction = faction.Copy()
			S.master_commander = master_commander
			if(player_spiders)
				S.player_spiders = TRUE
		qdel(src)

/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	max_integrity = 60

/obj/structure/spider/cocoon/Initialize(mapload)
	. = ..()
	icon_state = pick("cocoon1","cocoon2","cocoon3")

/obj/structure/spider/cocoon/Destroy()
	visible_message("<span class='danger'>[src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
	return ..()
