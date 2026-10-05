/obj/structure/grille/flock
	desc = "A robust framework of gnesis tubules."
	icon = 'icons/goonstation/mob/featherzone.dmi'
	icon_state = "barricade-0"
	armor = list(MELEE = -20, BULLET = -20, LASER = 80, ENERGY = 80, BOMB = 0, RAD = 100, FIRE = 80, ACID = 100)
	pass_flags = PASSFLOCK
	flags = CONDUCT | NODECONSTRUCT
	rods_type = null
	rods_amount = 0
	rods_broken = 0
	broken_type = /obj/structure/grille/flock/broken

/obj/structure/grille/flock/Initialize(mapload)
	. = ..()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_crossed),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)
	ADD_TRAIT(src, TRAIT_FLOCK_EXAMINE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)

/obj/structure/grille/flock/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> Barricade"),
		SPAN_FLOCKSAY("<b>System Integrity:</b> [get_integrity_percentage()]%"),
		SPAN_FLOCKSAY("<b>###=-</b>")
	)

/obj/structure/grille/flock/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/structure/grille/flock/update_icon_state()
	if(QDELETED(src) || broken)
		return

	var/ratio = obj_integrity / max_integrity

	if(ratio > 0.5)
		return
	icon_state = "barricade-[rand(1,3)]"

/obj/structure/grille/flock/Bumped(atom/user)
	if(isliving(user))
		if(!(shockcooldown <= world.time))
			return
		if(!anchored || broken)		// unanchored/broken grilles are never connected
			return
		if(!prob(70))
			return
		if(!in_range(src, user))// To prevent TK and mech users from getting shocked
			return
		var/mob/living/M = user
		var/siemens = 1
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				siemens = G.siemens_coefficient
		M.electrocute_act(30, src, siemens)
		shockcooldown = world.time + my_shockcooldown

/obj/structure/grille/flock/temperature_expose(exposed_temperature, exposed_volume)
	if(!broken)
		if(exposed_temperature > T0C + 32000)
			take_damage(1, BURN, 0, 0)

/obj/structure/grille/flock/shock(mob/user, prb)
	if(!anchored || broken)		// unanchored/broken grilles are never connected
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user))// To prevent TK and mech users from getting shocked
		return FALSE
	if(isflockmob(user))
		return FALSE
	var/mob/living/M = user
	var/siemens = 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			siemens = G.siemens_coefficient
	M.electrocute_act(20, src, siemens)
	do_sparks(3, 1, src)
	return TRUE

/obj/structure/grille/flock/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && anchored && !broken)
			var/obj/O = AM
			if(O.throwforce != 0)// don't want to let people spam tesla bolts, this way it will break after time
				playsound(src, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
				tesla_zap(src, 3, 12000, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_ALLOW_DUPLICATES)
	return ..()

/obj/structure/grille/flock/obj_break()
	if(!broken)
		new broken_type(loc)
		qdel(src)

/obj/structure/grille/flock/proc/on_crossed(atom/source, atom/movable/crosser)
	SIGNAL_HANDLER

	if(!isflockdrone(crosser) || broken)
		return

	if(!HAS_TRAIT(crosser, TRAIT_FLOCKPHASE))
		animate_flockpass(crosser)

/obj/structure/grille/flock/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return .

	if(!isflockdrone(mover))
		return .

	var/mob/living/basic/flock/drone/bird = mover
	if(HAS_TRAIT(bird, TRAIT_FLOCKPHASE))
		return TRUE

	if(bird.can_flockphase())
		return TRUE

/obj/structure/grille/flock/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	var/atom/M = locateUID(pass_info.caller_uid)
	if(!M)
		return ..()
	if(!isflockdrone(M))
		return ..()
	var/mob/living/basic/flock/drone/bird = M
	if(!bird.can_flockphase())
		return ..()
	return TRUE

/obj/structure/grille/flock/broken
	desc = "A broken framework of gnesis tubules."
	icon_state = "barricade-cut"
	armor = list(MELEE = -20, BULLET = -20, LASER = 80, ENERGY = 80, BOMB = 0, RAD = 100, FIRE = 80, ACID = 100)
	density = FALSE
	obj_integrity = 20
	broken = TRUE
	grille_type = /obj/structure/grille/flock
	broken_type = null


/obj/structure/grille/flock/try_flock_convert(datum/flock/flock, force)
	return
