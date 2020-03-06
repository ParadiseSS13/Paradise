/obj/item/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher0"
	item_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags = CONDUCT
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 7
	force = 10
	container_type = AMOUNT_VISIBLE
	materials = list(MAT_METAL=90)
	attack_verb = list("slammed", "whacked", "bashed", "thunked", "battered", "bludgeoned", "thrashed")
	dog_fashion = /datum/dog_fashion/back
	resistance_flags = FIRE_PROOF
	var/max_water = 50
	var/last_use = 1.0
	var/safety = 1
	var/refilling = FALSE
	var/sprite_name = "fire_extinguisher"
	var/power = 5 //Maximum distance launched water will travel
	var/precision = 0 //By default, turfs picked from a spray are random, set to 1 to make it always have at least one water effect per row
	var/cooling_power = 2 //Sets the cooling_temperature of the water reagent datum inside of the extinguisher when it is refilled

/obj/item/extinguisher/mini
	name = "pocket fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	flags = null //doesn't CONDUCT
	throwforce = 2
	w_class = WEIGHT_CLASS_SMALL
	force = 3.0
	materials = list()
	max_water = 30
	sprite_name = "miniFE"
	dog_fashion = null

/obj/item/extinguisher/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The safety is [safety ? "on" : "off"].</span>"


/obj/item/extinguisher/New()
	..()
	create_reagents(max_water)
	reagents.add_reagent("water", max_water)

/obj/item/extinguisher/attack_self(mob/user as mob)
	safety = !safety
	src.icon_state = "[sprite_name][!safety]"
	src.desc = "The safety is [safety ? "on" : "off"]."
	to_chat(user, "The safety is [safety ? "on" : "off"].")
	return

/obj/item/extinguisher/attack_obj(obj/O, mob/living/user)
	if(AttemptRefill(O, user))
		refilling = TRUE
		return FALSE
	else
		return ..()

/obj/item/extinguisher/proc/AttemptRefill(atom/target, mob/user)
	if(istype(target, /obj/structure/reagent_dispensers/watertank) && target.Adjacent(user))
		var/safety_save = safety
		safety = 1
		if(reagents.total_volume == reagents.maximum_volume)
			to_chat(user, "<span class='notice'>\The [src] is already full!</span>")
			safety = safety_save
			return 1
		var/obj/structure/reagent_dispensers/watertank/W = target
		var/transferred = W.reagents.trans_to(src, max_water)
		if(transferred > 0)
			to_chat(user, "<span class='notice'>\The [src] has been refilled by [transferred] units</span>")
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			for(var/datum/reagent/water/R in reagents.reagent_list)
				R.cooling_temperature = cooling_power
		else
			to_chat(user, "<span class='notice'>\The [W] is empty!</span>")
		safety = safety_save
		return 1
	else
		return 0

/obj/item/extinguisher/afterattack(atom/target, mob/user , flag)
	. = ..()
	//TODO; Add support for reagents in water.
	if(target.loc == user)//No more spraying yourself when putting your extinguisher away
		return

	if(refilling)
		refilling = FALSE
		return

	if(!safety)
		if(src.reagents.total_volume < 1)
			to_chat(usr, "<span class='danger'>\The [src] is empty.</span>")
			return

		if(world.time < src.last_use + 20)
			return

		src.last_use = world.time

		playsound(src.loc, 'sound/effects/extinguish.ogg', 75, 1, -3)

		var/direction = get_dir(src,target)

		if(usr.buckled && isobj(usr.buckled) && !usr.buckled.anchored )
			spawn(0)
				var/obj/structure/chair/C = null
				if(istype(usr.buckled, /obj/structure/chair))
					C = usr.buckled
				var/obj/B = usr.buckled
				var/movementdirection = turn(direction,180)
				if(C)	C.propelled = 4
				step(B, movementdirection)
				sleep(1)
				step(B, movementdirection)
				if(C)	C.propelled = 3
				sleep(1)
				step(B, movementdirection)
				sleep(1)
				step(B, movementdirection)
				if(C)	C.propelled = 2
				sleep(2)
				step(B, movementdirection)
				if(C)	C.propelled = 1
				sleep(2)
				step(B, movementdirection)
				if(C)	C.propelled = 0
				sleep(3)
				step(B, movementdirection)
				sleep(3)
				step(B, movementdirection)
				sleep(3)
				step(B, movementdirection)

		else user.newtonian_move(turn(direction, 180))

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))
		var/list/the_targets = list(T,T1,T2)
		if(precision)
			var/turf/T3 = get_step(T1, turn(direction, 90))
			var/turf/T4 = get_step(T2,turn(direction, -90))
			the_targets = list(T,T1,T2,T3,T4)

		for(var/a=0, a<5, a++)
			spawn(0)
				var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water( get_turf(src) )
				var/turf/my_target = pick(the_targets)
				if(precision)
					the_targets -= my_target
				var/datum/reagents/R = new/datum/reagents(5)
				if(!W) return
				W.reagents = R
				R.my_atom = W
				if(!W || !src) return
				src.reagents.trans_to(W,1)
				for(var/b=0, b<5, b++)
					step_towards(W,my_target)
					if(!W || !W.reagents) return
					W.reagents.reaction(get_turf(W))
					for(var/atom/atm in get_turf(W))
						if(!W) return
						W.reagents.reaction(atm)
						if(isliving(atm)) //For extinguishing mobs on fire
							var/mob/living/M = atm
							M.ExtinguishMob()

					if(W.loc == my_target) break
					sleep(2)
	else
		return ..()
