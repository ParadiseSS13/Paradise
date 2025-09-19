/obj/structure/grille
	desc = "A robust framework of metal rods. Commonly used for reinforcing high-security windows, and for building protective screens to intercept meteors and space debris."
	name = "grille"
	icon_state = "grille"
	density = TRUE
	anchored = TRUE
	flags = CONDUCT
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = BELOW_OBJ_LAYER
	level = 3
	armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 100, BOMB = 10, RAD = 100, FIRE = 0, ACID = 0)
	integrity_failure = 100
	cares_about_temperature = TRUE
	rad_insulation_beta = RAD_BETA_BLOCKER
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2
	var/rods_broken = 1
	var/grille_type
	var/broken_type = /obj/structure/grille/broken
	var/shockcooldown = 0
	var/my_shockcooldown = 2 SECONDS

/obj/structure/grille/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A powered wire underneath this will cause the grille to shock anyone who touches the grill. An electric shock may leap forth if the grill is damaged.</span>"
	. += "<span class='notice'>Use <b>wirecutters</b> to deconstruct this item.</span>"
	if(anchored)
		. += "<span class='notice'>It's secured in place with <b>screws</b>. The rods look like they could be <b>cut</b> through.</span>"
	else
		. += "<span class='notice'>The anchoring screws are <i>unscrewed</i>. The rods look like they could be <b>cut</b> through.</span>"

/obj/structure/grille/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/structure/grille/update_icon_state()
	if(QDELETED(src) || broken)
		return

	var/ratio = obj_integrity / max_integrity

	if(ratio > 0.5)
		return
	icon_state = "grille50_[rand(0,3)]"

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user))
		if(!(shockcooldown <= world.time))
			return
		shock(user, 70)
		shockcooldown = world.time + my_shockcooldown

/obj/structure/grille/attack_animal(mob/living/simple_animal/user)
	. = ..()
	if(!. || QDELETED(src) || shock(user, 70))
		return

	if(user.environment_smash >= ENVIRONMENT_SMASH_STRUCTURES)
		playsound(src, 'sound/effects/grillehit.ogg', 80, TRUE)
		obj_break()
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>", "<span class='notice'>You smash through [src].</span>")
		return

	take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/grille/handle_basic_attack(mob/living/basic/attacker, modifiers)
	. = ..()
	if(!. || QDELETED(src) || shock(attacker, 70))
		return

	if(attacker.environment_smash >= ENVIRONMENT_SMASH_STRUCTURES)
		playsound(src, 'sound/effects/grillehit.ogg', 80, TRUE)
		obj_break()
		attacker.visible_message("<span class='danger'>[attacker] smashes through [src]!</span>", "<span class='notice'>You smash through [src].</span>")
		return

	take_damage(rand(5, 10), BRUTE, MELEE, 1)

/obj/structure/grille/hulk_damage()
	return 60

/obj/structure/grille/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		if(!shock(user, 70))
			..(user, TRUE)
		return TRUE

/obj/structure/grille/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message("<span class='warning'>[user] hits [src].</span>")
	if(!shock(user, 70))
		take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/grille/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>")
	if(!shock(user, 70))
		take_damage(20, BRUTE, MELEE, 1)

/obj/structure/grille/CanPass(atom/movable/mover, border_dir)
	. = !density
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return TRUE
	if(isprojectile(mover))
		return (prob(30) || !density)

/obj/structure/grille/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	. = !density
	if(pass_info.is_movable)
		. = . || pass_info.pass_flags & PASSGRILLE

/obj/structure/grille/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(istype(I, /obj/item/stack/rods) && broken)
		repair(user, I)
		return ITEM_INTERACT_COMPLETE

//window placing begin
	else if(is_glass_sheet(I))
		build_window(I, user)
		return ITEM_INTERACT_COMPLETE
//window placing end

	else if((!istype(I, /obj/item/shard)) && shock(user, 70))
		return ITEM_INTERACT_COMPLETE

/obj/structure/grille/proc/repair(mob/user, obj/item/stack/rods/R)
	if(R.get_amount() >= 1)
		user.visible_message("<span class='notice'>[user] rebuilds the broken grille.</span>",
			"<span class='notice'>You rebuild the broken grille.</span>")
		new grille_type(loc)
		R.use(1)
		qdel(src)

/obj/structure/grille/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(shock(user, 100))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct()

/obj/structure/grille/screwdriver_act(mob/user, obj/item/I)
	if(!(anchored || issimulatedturf(loc) || locate(/obj/structure/lattice) in get_turf(src)))
		return
	. = TRUE
	if(shock(user, 90))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	anchored = !anchored
	var/support = locate(/obj/structure/lattice) in get_turf(src)
	if(!support)
		support = get_turf(src)
	user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] [src].</span>", \
							"<span class='notice'>You [anchored ? "fasten [src] to" : "unfasten [src] from"] \the [support].</span>")

/obj/structure/grille/proc/build_window(obj/item/stack/sheet/S, mob/user)
	var/dir_to_set = SOUTHWEST
	if(!istype(S) || !user)
		return
	if(broken)
		to_chat(user, "<span class='warning'>You must repair or replace [src] first!</span>")
		return
	if(S.get_amount() < 2)
		to_chat(user, "<span class='warning'>You need at least two sheets of glass for that!</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] needs to be fastened to the floor first!</span>")
		return
	for(var/obj/structure/window/WINDOW in loc)
		to_chat(user, "<span class='warning'>There is already a window there!</span>")
		return
	to_chat(user, "<span class='notice'>You start placing the window...</span>")
	if(do_after(user, 20, target = src))
		if(!loc || !anchored) //Grille destroyed or unanchored while waiting
			return
		for(var/obj/structure/window/WINDOW in loc) //checking this for a 2nd time to check if a window was made while we were waiting.
			to_chat(user, "<span class='warning'>There is already a window there!</span>")
			return
		var/obj/structure/window/W = new S.full_window(drop_location())
		W.setDir(dir_to_set)
		W.ini_dir = dir_to_set
		W.anchored = FALSE
		recalculate_atmos_connectivity()
		W.update_nearby_icons()
		W.state = WINDOW_OUT_OF_FRAME
		S.use(2)
		to_chat(user, "<span class='notice'>You place [W] on [src].</span>")


/obj/structure/grille/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/grillehit.ogg', 80, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/grille/deconstruct(disassembled = TRUE)
	if(!loc) //if already qdel'd somehow, we do nothing
		return
	if(!(flags & NODECONSTRUCT))
		var/obj/R = new rods_type(drop_location(), rods_amount)
		transfer_fingerprints_to(R)
		qdel(src)
	..()

/obj/structure/grille/obj_break()
	if(!broken && !(flags & NODECONSTRUCT))
		new broken_type(loc)
		var/obj/R = new rods_type(drop_location(), rods_broken)
		transfer_fingerprints_to(R)
		qdel(src)

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || broken)		// unanchored/broken grilles are never connected
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, 1, TRUE))
			do_sparks(3, 1, src)
			return TRUE
		else
			return FALSE
	return FALSE

/obj/structure/grille/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(!broken)
		if(exposed_temperature > T0C + 1500)
			take_damage(1, BURN, 0, 0)

/obj/structure/grille/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && anchored && !broken)
			var/obj/O = AM
			if(O.throwforce != 0)//don't want to let people spam tesla bolts, this way it will break after time
				var/turf/T = get_turf(src)
				var/obj/structure/cable/C = T.get_cable_node()
				if(C)
					playsound(src, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
					tesla_zap(src, 3, C.get_queued_available_power() * 0.01, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_ALLOW_DUPLICATES) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
					C.add_queued_power_demand(C.get_queued_available_power() * 0.0375) // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock.
	return ..()

/// Pre-broken grilles for map placement
/obj/structure/grille/broken
	icon_state = "brokengrille"
	density = FALSE
	obj_integrity = 20
	broken = TRUE
	rods_amount = 1
	rods_broken = 0
	grille_type = /obj/structure/grille
	broken_type = null

/obj/structure/grille/ratvar
	icon_state = "ratvargrille"
	name = "cog grille"
	desc = "A strangely-shaped grille."
	broken_type = /obj/structure/grille/ratvar/broken

/obj/structure/grille/ratvar/Initialize(mapload)
	. = ..()
	if(broken)
		new /obj/effect/temp_visual/ratvar/grille/broken(get_turf(src))
	else
		new /obj/effect/temp_visual/ratvar/grille(get_turf(src))
		new /obj/effect/temp_visual/ratvar/beam/grille(get_turf(src))

/obj/structure/grille/ratvar/narsie_act()
	take_damage(rand(1, 3), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/structure/grille/ratvar/broken
	icon_state = "brokenratvargrille"
	density = FALSE
	obj_integrity = 20
	broken = TRUE
	rods_amount = 1
	rods_broken = 0
	grille_type = /obj/structure/grille/ratvar
	broken_type = null
