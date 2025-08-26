
//holographic signs and barriers

/obj/structure/holosign
	name = "holo sign"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	max_integrity = 1
	armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	var/obj/item/holosign_creator/projector

/obj/structure/holosign/Initialize(mapload, source_projector)
	. = ..()
	if(source_projector)
		projector = source_projector
		projector.signs += src

/obj/structure/holosign/Destroy()
	if(projector)
		projector.signs -= src
		projector = null
	return ..()

/obj/structure/holosign/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(5 , BRUTE, MELEE, 1)

/obj/structure/holosign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)

/obj/structure/holosign/wetsign
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon_state = "holosign"

/obj/structure/holosign/wetsign/proc/wet_timer_start(obj/item/holosign_creator/HS_C)
	addtimer(CALLBACK(src, PROC_REF(wet_timer_finish), HS_C), 82 SECONDS, TIMER_UNIQUE)

/obj/structure/holosign/wetsign/proc/wet_timer_finish(obj/item/holosign_creator/HS_C)
	playsound(HS_C.loc, 'sound/machines/chime.ogg', 20, 1)
	qdel(src)

/obj/structure/holosign/barrier
	name = "holo barrier"
	desc = "A short holographic barrier which can only be passed by walking."
	icon_state = "holosign_sec"
	pass_flags_self = LETPASSTHROW | PASSTAKE
	density = TRUE
	max_integrity = 20
	var/allow_walk = TRUE //can we pass through it on walk intent

/obj/structure/holosign/barrier/CanPass(atom/movable/mover, border_dir)
	if(!density)
		return TRUE
	if(mover.pass_flags & (PASSGLASS|PASSTABLE|PASSGRILLE))
		return TRUE
	if(isliving(mover))
		var/mob/living/walker = mover
		if(allow_walk && (walker.m_intent == MOVE_INTENT_WALK || (walker.pulledby && walker.pulledby.m_intent == MOVE_INTENT_WALK)))
			return TRUE

/obj/structure/holosign/barrier/engineering
	icon_state = "holosign_engi"
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	rad_insulation_beta = RAD_LIGHT_INSULATION

/obj/structure/holosign/barrier/atmos
	name = "holo firelock"
	desc = "A holographic barrier resembling a firelock. Though it does not prevent solid objects from passing through, gas is kept out."
	icon_state = "holo_firelock"
	density = FALSE
	layer = ABOVE_MOB_LAYER
	alpha = 150
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	rad_insulation_beta = RAD_LIGHT_INSULATION
	resistance_flags = UNACIDABLE | ACID_PROOF

/obj/structure/holosign/barrier/atmos/Initialize(mapload)
	. = ..()
	recalculate_atmos_connectivity()

// Airtight.
/obj/structure/holosign/barrier/atmos/CanAtmosPass(direction)
	return FALSE

// Heatproof.
/obj/structure/holosign/barrier/atmos/get_superconductivity(direction)
	return 0

/obj/structure/holosign/barrier/atmos/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.recalculate_atmos_connectivity()

/obj/structure/holosign/barrier/cyborg
	name = "Energy Field"
	desc = "A fragile energy field that blocks movement. Excels at blocking lethal projectiles."
	max_integrity = 10
	allow_walk = FALSE

/obj/structure/holosign/barrier/cyborg/bullet_act(obj/item/projectile/P)
	take_damage((P.damage / 5) , BRUTE, MELEE, 1)	//Doesn't really matter what damage flag it is.
	if(istype(P, /obj/item/projectile/energy/electrode))
		take_damage(10, BRUTE, MELEE, 1)	//Tasers aren't harmful.
	if(istype(P, /obj/item/projectile/beam/disabler))
		take_damage(5, BRUTE, MELEE, 1)	//Disablers aren't harmful.

/obj/structure/holosign/barrier/cyborg/hacked
	name = "Charged Energy Field"
	desc = "A powerful energy field that blocks movement. Energy arcs off it."
	max_integrity = 20
	var/shockcd = 0

/obj/structure/holosign/barrier/cyborg/hacked/bullet_act(obj/item/projectile/P)
	take_damage(P.damage, BRUTE, MELEE, 1)	//Yeah no this doesn't get projectile resistance.

/obj/structure/holosign/barrier/cyborg/hacked/proc/cooldown()
	shockcd = FALSE

/obj/structure/holosign/barrier/cyborg/hacked/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!shockcd)
		if(isliving(user))
			var/mob/living/M = user
			M.electrocute_act(15, "Energy Barrier")
			shockcd = TRUE
			addtimer(CALLBACK(src, PROC_REF(cooldown)), 5)

/obj/structure/holosign/barrier/cyborg/hacked/Bumped(atom/movable/AM)
	if(shockcd)
		return

	if(!isliving(AM))
		return

	var/mob/living/M = AM
	M.electrocute_act(15, "Energy Barrier")
	shockcd = TRUE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), 5)

/obj/structure/holosign/barrier/cyborg/hacked/detective
	name = "investigation barrier"
	desc = "An authoritive holographic barrier proclaiming a crime scene. Energy arcs off of it."
	icon_state = "holosign_det"
