#warn AA TODO - Refactor all this shit

/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold?"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "prox-radio1"  // it is immediately overriden in New, but setting it here makes it show in mapeditor
	/// What this will be called when its discovered
	var/real_name = "defined object"
	/// Has this been discovered?
	var/revealed = FALSE
	/// What is the real function of this object
	var/realProc
	var/cooldownMax = 60
	var/cooldown
	var/list/spawnable_pets

/obj/item/relic/Initialize(mapload)
	. = ..()
	icon_state = pick("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	realName = "[pick("broken","twisted","spun","improved","silly","regular","badly made")] [pick("device","object","toy","suspicious tech","gear")]"
	floof = pick(/mob/living/simple_animal/pet/dog/corgi, /mob/living/simple_animal/pet/cat, /mob/living/simple_animal/pet/dog/fox, /mob/living/simple_animal/mouse, /mob/living/simple_animal/pet/dog/pug, /mob/living/simple_animal/lizard, /mob/living/simple_animal/diona, /mob/living/simple_animal/butterfly, /mob/living/carbon/human/monkey)


/obj/item/relic/proc/reveal()
	if(revealed) //Re-rolling your relics seems a bit overpowered, yes?
		return

	revealed = TRUE
	name = realName
	cooldownMax = rand(60, 300)
	realProc = pick("teleport","explode","rapidDupe","petSpray","flash","clean","floofcannon")
	origin_tech = pick("engineering=[rand(2,5)]","magnets=[rand(2,5)]","plasmatech=[rand(2,5)]","programming=[rand(2,5)]","powerstorage=[rand(2,5)]")

/obj/item/relic/attack_self(mob/user)
	if(revealed)
		if(cooldown)
			to_chat(user, "<span class='warning'>[src] does not react!</span>")
			return
		else if(loc == user)
			cooldown = TRUE
			call(src,realProc)(user)
			spawn(cooldownMax)
				cooldown = FALSE
	else
		to_chat(user, "<span class='notice'>You aren't quite sure what to do with this, yet.</span>")

//////////////// RELIC PROCS /////////////////////////////

/obj/item/relic/proc/throwSmoke(turf/where)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, FALSE, where)
	smoke.start()

/obj/item/relic/proc/floofcannon(mob/user)
	playsound(loc, "sparks", rand(25, 50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/mob/living/C = new floof(get_turf(user))
	C.throw_at(pick(oview(10,user)),10,rand(3,8))
	throwSmoke(get_turf(C))
	warn_admins(user, "Floof Cannon", 0)

/obj/item/relic/proc/clean(mob/user)
	playsound(loc, "sparks", rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/chem_grenade/cleaner/CL = new/obj/item/grenade/chem_grenade/cleaner(get_turf(user))
	CL.prime()
	warn_admins(user, "Smoke", 0)

/obj/item/relic/proc/flash(mob/user)
	playsound(loc, "sparks", rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(get_turf(user))
	CB.prime()
	warn_admins(user, "Flash")

/obj/item/relic/proc/petSpray(mob/user)
	var/message = "<span class='danger'>[src] begins to shake, and in the distance the sound of rampaging animals arises!</span>"
	visible_message(message)
	to_chat(user, message)
	var/animals = rand(1,25)
	var/counter
	var/list/valid_animals = list(/mob/living/simple_animal/parrot,/mob/living/simple_animal/butterfly,/mob/living/simple_animal/pet/cat,/mob/living/simple_animal/pet/dog/corgi,/mob/living/simple_animal/crab,/mob/living/simple_animal/pet/dog/fox,/mob/living/simple_animal/lizard,/mob/living/simple_animal/mouse,/mob/living/simple_animal/pet/dog/pug,/mob/living/simple_animal/hostile/bear,/mob/living/simple_animal/hostile/poison/bees,/mob/living/simple_animal/hostile/carp)
	for(counter = 1; counter < animals; counter++)
		var/mobType = pick(valid_animals)
		new mobType(get_turf(src))
	warn_admins(user, "Mass Mob Spawn")
	if(prob(60))
		to_chat(user, "<span class='warning'>[src] falls apart!</span>")
		qdel(src)

/obj/item/relic/proc/rapidDupe(mob/user)
	audible_message("[src] emits a loud pop!")
	var/list/dupes = list()
	var/counter
	var/max = rand(5,10)
	for(counter = 1; counter < max; counter++)
		var/obj/item/relic/R = new type(get_turf(src))
		R.name = name
		R.desc = desc
		R.realName = realName
		R.realProc = realProc
		R.revealed = TRUE
		dupes |= R
		spawn()
			R.throw_at(pick(oview(7,get_turf(src))),10,1)
	counter = 0
	spawn(rand(10, 100))
		for(counter = 1; counter <= dupes.len; counter++)
			var/obj/item/relic/R = dupes[counter]
			qdel(R)
	warn_admins(user, "Rapid duplicator", 0)

/obj/item/relic/proc/explode(mob/user)
	to_chat(user, "<span class='danger'>[src] begins to heat up!</span>")
	spawn(rand(35,100))
		if(loc == user)
			visible_message("<span class='notice'>[src]'s top opens, releasing a powerful blast!</span>")
			explosion(user.loc, -1, rand(1,5), rand(1,5), rand(1,5), rand(1,5), flame_range = 2)
			warn_admins(user, "Explosion")
			qdel(src) //Comment this line to produce a light grenade (the bomb that keeps on exploding when used)!!

/obj/item/relic/proc/teleport(mob/user)
	to_chat(user, "<span class='notice'>[src] begins to vibrate!</span>")
	spawn(rand(10, 30))
		var/turf/userturf = get_turf(user)
		if(loc == user && is_teleport_allowed(userturf.z)) //Because Nuke Ops bringing this back on their shuttle, then looting the ERT area is 2fun4you!
			visible_message("<span class='notice'>[src] twists and bends, relocating itself!</span>")
			throwSmoke(userturf)
			do_teleport(user, userturf, 8, sound_in = 'sound/effects/phasein.ogg')
			throwSmoke(get_turf(user))
			warn_admins(user, "Teleport", 0)

//Admin Warning proc for relics
/obj/item/relic/proc/warn_admins(mob/user, RelicType, priority = 1)
	var/turf/T = get_turf(src)
	var/log_msg = "[RelicType] relic used by [key_name(user)] in ([T.x],[T.y],[T.z])"
	if(priority) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[RelicType] relic activated by [key_name_admin(user)] in ([T.x], [T.y], [T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
	log_game(log_msg)

