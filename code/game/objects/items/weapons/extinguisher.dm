/obj/item/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher0"
	item_state = "fire_extinguisher"
	base_icon_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags = CONDUCT
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 7
	force = 10
	container_type = AMOUNT_VISIBLE
	materials = list(MAT_METAL = 200)
	attack_verb = list("slammed", "whacked", "bashed", "thunked", "battered", "bludgeoned", "thrashed")
	dog_fashion = /datum/dog_fashion/back
	resistance_flags = FIRE_PROOF
	var/max_water = 50
	var/safety = TRUE
	var/refilling = FALSE
	/// FALSE by default, turfs picked from a spray are random, set to TRUE to make it always have at least one water effect per row
	var/precision = FALSE
	var/cooling_power = 2 //Sets the cooling_temperature of the water reagent datum inside of the extinguisher when it is refilled
	COOLDOWN_DECLARE(last_use)

/obj/item/extinguisher/mini
	name = "pocket fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	item_state = "miniFE"
	base_icon_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	flags = null //doesn't CONDUCT
	throwforce = 2
	w_class = WEIGHT_CLASS_SMALL
	force = 3
	materials = list()
	max_water = 30
	dog_fashion = null

/obj/item/extinguisher/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The safety is [safety ? "on" : "off"].</span>"


/obj/item/extinguisher/Initialize(mapload)
	. = ..()
	if(!reagents)
		create_reagents(max_water)
		reagents.add_reagent("water", max_water)
	ADD_TRAIT(src, TRAIT_CAN_POINT_WITH, ROUNDSTART_TRAIT)

/obj/item/extinguisher/attack_self(mob/user as mob)
	safety = !safety
	icon_state = "[base_icon_state][!safety]"
	to_chat(user, "<span class='notice'>You [safety ? "enable" : "disable"] [src]'s safety.</span>")

/obj/item/extinguisher/attack_obj(obj/O, mob/living/user, params)
	if(AttemptRefill(O, user))
		refilling = TRUE
		return FALSE
	else
		return ..()

/obj/item/extinguisher/proc/AttemptRefill(atom/target, mob/user)
	if(!istype(target, /obj/structure/reagent_dispensers/watertank) || !target.Adjacent(user))
		return FALSE
	var/old_safety = safety
	safety = TRUE
	if(reagents.total_volume == reagents.maximum_volume)
		to_chat(user, "<span class='notice'>\The [src] is already full!</span>")
		safety = old_safety
		return TRUE
	var/obj/structure/reagent_dispensers/watertank/W = target
	var/transferred = W.reagents.trans_to(src, max_water)
	if(transferred > 0)
		to_chat(user, "<span class='notice'>\The [src] has been refilled by [transferred] units.</span>")
		playsound(loc, 'sound/effects/refill.ogg', 50, TRUE, -6)
		for(var/datum/reagent/water/R in reagents.reagent_list)
			R.cooling_temperature = cooling_power
	else
		to_chat(user, "<span class='notice'>\The [W] is empty!</span>")
	safety = old_safety
	return TRUE

/obj/item/extinguisher/afterattack(atom/target, mob/user, flag)
	. = ..()
	//TODO; Add support for reagents in water.
	if(target.loc == user)//No more spraying yourself when putting your extinguisher away
		return

	if(refilling)
		refilling = FALSE
		return

	if(safety)
		return ..()
	if(reagents.total_volume < 1)
		to_chat(user, "<span class='danger'>[src] is empty.</span>")
		return

	if(!COOLDOWN_FINISHED(src, last_use))
		return

	COOLDOWN_START(src, last_use, 2 SECONDS)

	if(reagents.chem_temp > 300 || reagents.chem_temp < 280)
		add_attack_logs(user, target, "Sprayed with superheated or cooled fire extinguisher at Temperature [reagents.chem_temp]K")
	playsound(loc, 'sound/effects/extinguish.ogg', 75, TRUE, -3)

	var/direction = get_dir(src, target)

	if(isobj(user.buckled) && !user.buckled.anchored && !istype(user.buckled, /obj/vehicle))
		INVOKE_ASYNC(src, PROC_REF(buckled_speed_move), user.buckled, direction)
	else
		user.newtonian_move(turn(direction, 180))

	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T, turn(direction, 90))
	var/turf/T2 = get_step(T, turn(direction, -90))
	var/list/the_targets = list(T, T1, T2)
	if(precision)
		var/turf/T3 = get_step(T1, turn(direction, 90))
		var/turf/T4 = get_step(T2, turn(direction, -90))
		the_targets = list(T, T1, T2, T3, T4)

	for(var/a in 1 to 5)
		var/obj/effect/particle_effect/water/water = new /obj/effect/particle_effect/water(get_turf(src))
		water.create_reagents(5)
		reagents.trans_to(water, 1)
		var/turf/new_target = pick(the_targets)
		if(precision)
			the_targets -= new_target
		INVOKE_ASYNC(water, TYPE_PROC_REF(/obj/effect/particle_effect/water, extinguish_move), new_target)

/obj/item/extinguisher/cyborg_recharge(coeff, emagged)
	reagents.check_and_add("water", max_water, 5 * coeff)

/obj/item/extinguisher/proc/buckled_speed_move(obj/structure/chair/buckled_to, direction) // Buckled_to may not be a chair here, but we're assuming so because it makes it easier to typecheck
	var/movementdirection = turn(direction, 180)
	if(istype(buckled_to))
		buckled_to.propelled = 4
	step(buckled_to, movementdirection)
	sleep(1)
	step(buckled_to, movementdirection)
	if(istype(buckled_to))
		buckled_to.propelled = 3
	sleep(1)
	step(buckled_to, movementdirection)
	sleep(1)
	step(buckled_to, movementdirection)
	if(istype(buckled_to))
		buckled_to.propelled = 2
	sleep(2)
	step(buckled_to, movementdirection)
	if(istype(buckled_to))
		buckled_to.propelled = 1
	sleep(2)
	step(buckled_to, movementdirection)
	if(istype(buckled_to))
		buckled_to.propelled = 0
	sleep(3)
	step(buckled_to, movementdirection)
	sleep(3)
	step(buckled_to, movementdirection)
	sleep(3)
	step(buckled_to, movementdirection)
