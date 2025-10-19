#define STRANGEOBJECT_FUNCTION_TELEPORT 1
#define STRANGEOBJECT_FUNCTION_EXPLODE 2
#define STRANGEOBJECT_FUNCTION_RAPID_DUPE 3
#define STRANGEOBJECT_FUNCTION_MASS_SPAWN 4
#define STRANGEOBJECT_FUNCTION_FLASH 5
#define STRANGEOBJECT_FUNCTION_CLEAN 6
#define STRANGEOBJECT_FUNCTION_PET_SPAWN 7

/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold?"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "prox-radio1"  // it is immediately overriden in New, but setting it here makes it show in mapeditor
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	/// The name this object will get when it is discovered
	var/real_name = "defined object"
	/// Has this object been discovered?
	var/revealed = FALSE
	/// What is the real function of this object?
	var/function_id
	/// Duration of the cooldown
	var/cooldown_duration = 60
	/// Actual cooldown
	var/last_use_time
	/// Mob this object should spawn if [STRANGEOBJECT_FUNCTION_PET_SPAWN] is picked.
	var/petspawn_mob

/obj/item/relic/Initialize(mapload)
	. = ..()

	icon_state = pick(
		"shock_kit",
		"armor-igniter-analyzer",
		"infra-igniter0",
		"infra-igniter1",
		"radio-multitool",
		"prox-radio1",
		"radio-radio",
		"timer-multitool0",
		"radio-igniter-tank",
	)

	var/realname_part1 = pick("broken","twisted","spun","improved","silly","regular","badly made")
	var/realname_part2 = pick("device","object","toy","suspicious tech","gear")

	real_name = "[realname_part1] [realname_part2]"

	petspawn_mob = pick(
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/dog/fox,
		/mob/living/basic/mouse,
		/mob/living/simple_animal/pet/dog/pug,
		/mob/living/basic/lizard,
		/mob/living/basic/diona_nymph,
		/mob/living/basic/butterfly,
		/mob/living/carbon/human/monkey,
	)

	// Assign it a random tech level
	var/list/possible_techs = list("materials", "engineering", "plasmatech", "powerstorage", "bluespace", "biotech", "combat", "magnets", "programming")
	origin_tech = "[pick(possible_techs)]=[rand(2, 5)]"


/obj/item/relic/proc/reveal()
	if(revealed) //Re-rolling your relics seems a bit overpowered, yes?
		return

	revealed = TRUE
	name = real_name
	cooldown_duration = rand(60, 300)

	function_id = pick(
		STRANGEOBJECT_FUNCTION_TELEPORT,
		STRANGEOBJECT_FUNCTION_EXPLODE,
		STRANGEOBJECT_FUNCTION_RAPID_DUPE,
		STRANGEOBJECT_FUNCTION_MASS_SPAWN,
		STRANGEOBJECT_FUNCTION_FLASH,
		STRANGEOBJECT_FUNCTION_CLEAN,
		STRANGEOBJECT_FUNCTION_PET_SPAWN,
	)

	// You discovered it - you gambled your possible fortune! AW DANGIT!
	origin_tech = null


/obj/item/relic/attack_self__legacy__attackchain(mob/user)
	if(revealed)
		if((last_use_time + cooldown_duration) > world.time)
			to_chat(user, "<span class='warning'>[src] does not react!</span>")
			return
		else if(loc == user)
			last_use_time = world.time

			// Figure out our real function
			switch(function_id)
				if(STRANGEOBJECT_FUNCTION_TELEPORT)
					to_chat(user, "<span class='notice'>[src] begins to vibrate!</span>")
					addtimer(CALLBACK(src, PROC_REF(teleport_callback), user), rand(10, 30))

				if(STRANGEOBJECT_FUNCTION_EXPLODE)
					to_chat(user, "<span class='danger'>[src] begins to heat up!</span>")
					addtimer(CALLBACK(src, PROC_REF(explode_callback), user), rand(35, 100))

				if(STRANGEOBJECT_FUNCTION_RAPID_DUPE)
					audible_message("[src] emits a loud pop!")
					for(var/i in 1 to rand(5, 10))
						var/obj/item/relic/R = new type(get_turf(src))
						R.name = name
						R.desc = desc
						R.function_id = function_id
						R.revealed = TRUE
						R.origin_tech = null
						QDEL_IN(R, rand(10, 100))
						INVOKE_ASYNC(R, TYPE_PROC_REF(/atom/movable, throw_at), pick(oview(7, get_turf(src))), 10, 1)

					warn_admins(user, "Rapid duplicator", 0)

				if(STRANGEOBJECT_FUNCTION_MASS_SPAWN)
					// This is the unlucky one
					var/message = "<span class='danger'>[src] begins to shake, and in the distance the sound of rampaging animals arises!</span>"
					visible_message(message)
					to_chat(user, message)
					var/animal_spawncount = rand(1,25)

					var/list/valid_animals = list(
						/mob/living/simple_animal/parrot,
						/mob/living/basic/butterfly,
						/mob/living/simple_animal/pet/cat,
						/mob/living/simple_animal/pet/dog/corgi,
						/mob/living/basic/crab,
						/mob/living/simple_animal/pet/dog/fox,
						/mob/living/basic/lizard,
						/mob/living/basic/mouse,
						/mob/living/simple_animal/pet/dog/pug,
						/mob/living/basic/bear/black,
						/mob/living/basic/bear/brown,
						/mob/living/simple_animal/hostile/poison/bees,
						/mob/living/basic/carp
					)

					for(var/counter in 1 to animal_spawncount)
						var/mob_type = pick(valid_animals)
						new mob_type(get_turf(src))

					warn_admins(user, "Mass Mob Spawn")
					if(prob(60))
						to_chat(user, "<span class='warning'>[src] falls apart!</span>")
						qdel(src)

				if(STRANGEOBJECT_FUNCTION_FLASH)
					playsound(loc, "sparks", rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
					var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(get_turf(user))
					CB.prime()
					warn_admins(user, "Flash")

				if(STRANGEOBJECT_FUNCTION_CLEAN)
					playsound(loc, "sparks", rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
					var/obj/item/grenade/chem_grenade/cleaner/CL = new/obj/item/grenade/chem_grenade/cleaner(get_turf(user))
					CL.prime()
					warn_admins(user, "Clean", 0)

				if(STRANGEOBJECT_FUNCTION_PET_SPAWN)
					playsound(loc, "sparks", rand(25, 50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
					var/mob/living/C = new petspawn_mob(get_turf(user))
					C.throw_at(pick(oview(10,user)),10,rand(3,8))
					throw_smoke(get_turf(C))
					warn_admins(user, "Pet Spawn", 0)

	else
		to_chat(user, "<span class='notice'>You aren't quite sure what to do with this, yet.</span>")


// Callbacks for timers
/obj/item/relic/proc/teleport_callback(mob/user)
	var/turf/userturf = get_turf(user)
	if(loc == user && is_teleport_allowed(userturf.z)) //Because Nuke Ops bringing this back on their shuttle, then looting the ERT area is 2fun4you!
		visible_message("<span class='notice'>[src] twists and bends, relocating itself!</span>")
		throw_smoke(userturf)
		do_teleport(user, userturf, 8, sound_in = 'sound/effects/phasein.ogg')
		throw_smoke(get_turf(user))
		warn_admins(user, "Teleport", 0)


/obj/item/relic/proc/explode_callback(mob/user)
	if(loc == user)
		visible_message("<span class='notice'>[src]'s top opens, releasing a powerful blast!</span>")
		explosion(user.loc, -1, rand(1,5), rand(1,5), rand(1,5), rand(1,5), flame_range = 2, cause = "Exploding relic")
		warn_admins(user, "Explosion")
		qdel(src)


// Admin Warning proc for relics
/obj/item/relic/proc/warn_admins(mob/user, RelicType, alert_admins = TRUE)
	var/turf/T = get_turf(src)
	var/log_msg = "[RelicType] relic used by [key_name(user)] in ([T.x],[T.y],[T.z])"

	if(alert_admins) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[RelicType] relic activated by [key_name_admin(user)] in ([T.x], [T.y], [T.z] - <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)

	log_game(log_msg)
	investigate_log(log_msg, "strangeobjects")


// Make some magic smoke
/obj/item/relic/proc/throw_smoke(turf/where)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, FALSE, where)
	smoke.start()


#undef STRANGEOBJECT_FUNCTION_TELEPORT
#undef STRANGEOBJECT_FUNCTION_EXPLODE
#undef STRANGEOBJECT_FUNCTION_RAPID_DUPE
#undef STRANGEOBJECT_FUNCTION_MASS_SPAWN
#undef STRANGEOBJECT_FUNCTION_FLASH
#undef STRANGEOBJECT_FUNCTION_CLEAN
#undef STRANGEOBJECT_FUNCTION_PET_SPAWN
