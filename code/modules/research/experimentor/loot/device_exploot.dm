//////////////////////////////DEVICE DEFINITION////////////////////////////////
// Re-implements the old strange object code in order to finish the proof of concept.
// Loot and name lists are defined in _loot_definer.dm for each object type.

#define RARITY_COMMON 0
#define RARITY_UNCOMMON 1
#define RARITY_RARE 2
#define RARITY_VERYRARE 3

/obj/item/discovered_tech
	name = "Discovered Technology"
	desc = "A strange device. Its function is not immediately apparent."
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	var/techProc = "nothing"
	var/list/iconlist = list("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	var/cooldownMax = 60
	var/cooldown = FALSE
	var/stability = 0
	var/potency = 0
	var/raritylevel = 0
	var/base_name = "Unknown"
	// Empty variable in case one of the device types need it.
	var/extra_data

/obj/item/discovered_tech/New(var/stability_in, var/potency_in, var/rare_level, var/item_type)
	stability = stability_in
	potency = potency_in
	raritylevel = rare_level
	techProc = item_type
	icon_state = pick(iconlist)
	cooldownMax = choosecooldown()
	if(techProc != null)
		initializeProc()

/obj/item/discovered_tech/attack_self(mob/user)
	if(cooldown)
		to_chat(user, "<span class='warning'>The [src] does not react!</span>")
		return
	else if(src.loc == user)
		cooldown = TRUE
		call(src,techProc)(user)
		spawn(cooldownMax)
			cooldown = FALSE

// Choose the cooldown timer for the device. Add multipliers here.
/obj/item/discovered_tech/proc/choosecooldown()
	switch(techProc)
		if("rapiddupe")
			//			 |Base CD	  |Rarity Multiplier	|Stability Multiplier
			return round(rand(150,300)*(1.4-0.2*raritylevel)*(1.4-0.2*(stability/20)),1)
		if("teleport")
			return round(rand(150,300)*(1.4-0.2*raritylevel)*(1.4-0.2*(stability/20)),1)
		if("clean")
			return round(rand(150,300)*(1.4-0.2*raritylevel)*(1.4-0.2*(stability/20)),1)
		if("flash")
			return round(rand(150,300)*(1.4-0.2*raritylevel)*(1.4-0.2*(stability/20)),1)


//////////////////////////////////PROC INITIALIZER//////////////////////////////////////
// If the selected proc needs data to function, all of that is initialized here.

/obj/item/discovered_tech/proc/initializeProc()
	switch(techProc)
		if("floofcannon")
			extra_data = pick(/mob/living/simple_animal/pet/corgi, /mob/living/simple_animal/pet/cat, /mob/living/simple_animal/pet/fox, /mob/living/simple_animal/mouse, /mob/living/simple_animal/pet/pug, /mob/living/simple_animal/lizard, /mob/living/simple_animal/diona, /mob/living/simple_animal/butterfly, /mob/living/carbon/human/monkey)



///////////////////////////////DEVICE FUNCTION PROCS////////////////////////////////////
// Borrowed from the old relics for testing purposes.

/obj/item/discovered_tech/proc/nothing(mob/user)
	to_chat(user, "<span class='notice'>The [src] fizzles and sparks. It doesn't seem to work.</span>")

/obj/item/discovered_tech/proc/throwSmoke(turf/where)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(potency/25,0, where, 0)
	smoke.start()

/obj/item/discovered_tech/proc/floofcannon(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/mob/living/C = new extra_data(get_turf(user))
	C.throw_at(pick(oview(10,user)),10,rand(3,8))
	throwSmoke(get_turf(C))
	warn_admins(user, "Floof Cannon", 0)

/obj/item/discovered_tech/proc/explode(mob/user)
	to_chat(user, "<span class='danger'>[src] begins to heat up!</span>")
	spawn(rand(max(stability,35),100))
		if(raritylevel >= RARITY_RARE || src.loc == user)
			visible_message("<span class='notice'>The [src]'s top opens, releasing a powerful blast!</span>")
			explosion(src.loc, -1, rand(potency/50,potency/30), rand(potency/30,potency/20), rand(potency/20,potency/15), flame_range = potency/25)
			warn_admins(user, "Explosion")
			qdel(src) //Comment this line to produce a light grenade (the bomb that keeps on exploding when used)!!

/obj/item/discovered_tech/proc/clean(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/obj/item/grenade/chem_grenade/cleaner/CL = new/obj/item/grenade/chem_grenade/cleaner(get_turf(user))
	CL.prime()
	warn_admins(user, "Cleaning Foam", 0)

/obj/item/discovered_tech/proc/flash(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(get_turf(user))
	CB.range = rand(stability/25, max(potency/10, 4))
	CB.prime()
	warn_admins(user, "Flashbang")

/obj/item/discovered_tech/proc/rapiddupe(mob/user)
	if(raritylevel >= RARITY_UNCOMMON)
		audible_message("[src] emits a loud pop and sprays dangerous projectiles everywhere!")
		warn_admins(user, "Dangerous Rapid Duplicator")
	else
		audible_message("[src] emits a loud pop!")
		warn_admins(user, "Rapid Duplicator", 0)
	var/list/dupes = list()
	var/counter
	var/max = rand(stability/20, max(potency/5, 5))
	for(counter = 1; counter < max; counter++)
		var/obj/item/discovered_tech/R = new src.type(get_turf(src))
		R.icon_state = icon_state
		R.name = name
		R.desc = desc
		R.throwforce = ((potency/10)*raritylevel)+1
		dupes |= R
		spawn()
			R.throw_at(pick(oview(4+potency/20,get_turf(src))),10,1)
	counter = 0
	spawn(rand(stability/10,stability))
		for(counter = 1; counter <= dupes.len; counter++)
			var/obj/item/discovered_tech/R = dupes[counter]
			qdel(R)

/obj/item/discovered_tech/proc/teleport(mob/user)
	to_chat(user, "<span class='notice'>The [src] begins to vibrate!</span>")
	spawn(rand((15-stability/10),30-stability/5))
		var/turf/userturf = get_turf(user)
		if(src.loc != user || is_teleport_allowed(userturf.z) == FALSE)
			return
		visible_message("<span class='notice'>The [src] twists and bends, relocating itself!</span>")
		do_teleport(user, userturf, round(potency/10, 1), asoundin = 'sound/effects/phasein.ogg')
		warn_admins(user, "Teleport", 0)

/obj/item/discovered_tech/proc/petSpray(mob/user)
	var/message = "<span class='danger'>[src] begins to shake, and in the distance the sound of rampaging animals arises!</span>"
	visible_message(message)
	to_chat(user, message)
	var/animals = rand(stability/20, max(potency/10, 5))
	var/counter
	var/list/valid_animals = list(/mob/living/simple_animal/parrot,/mob/living/simple_animal/butterfly,/mob/living/simple_animal/pet/cat,/mob/living/simple_animal/pet/corgi,/mob/living/simple_animal/crab,/mob/living/simple_animal/pet/fox)
	// Moves a couple of harmless spawns to a low potency check to make hostile mobs more likely (~1/3 instead of 1/4) on very high potency.
	if(potency<80)
		valid_animals.Add(/mob/living/simple_animal/lizard,/mob/living/simple_animal/mouse,/mob/living/simple_animal/pet/pug)
	// Moves the dangerous spawns to high potency only.
	if(potency>60)
		valid_animals.Add(/mob/living/simple_animal/hostile/bear,/mob/living/simple_animal/hostile/poison/bees,/mob/living/simple_animal/hostile/carp)
		warn_admins(user, "Mass Mob Spawn")
	else
		warn_admins(user, "Harmless Mass Mob Spawn", 0)
	for(counter = 1; counter < animals; counter++)
		var/mobType = pick(valid_animals)
		new mobType(get_turf(src))
	if(prob(100-(stability/2+15)))
		to_chat(user, "<span class='warning'>[src] falls apart!</span>")
		qdel(src)

//Admin Warning Procs
/obj/item/discovered_tech/proc/warn_admins(mob/user, ItemType, priority = 1)
	var/turf/T = get_turf(src)
	var/log_msg = "[techProc] experimentor tech used by [key_name(user)] in ([T.x],[T.y],[T.z])"
	if(priority) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[techProc] experimentor tech activated by [key_name_admin(user)] in ([T.x], [T.y], [T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
	log_game(log_msg)
	investigate_log(log_msg, "experimentor")