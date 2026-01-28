#define MAX_DENT_DECALS 15

/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_SIMULATED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REGULAR_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REGULAR_WALLS, SMOOTH_GROUP_REINFORCED_WALLS)

	var/rotting = FALSE

	var/damage = 0
	var/damage_cap = 100 //Wall will break down to girders if damage reaches this point

	var/global/damage_overlays[8]
	var/melting = FALSE //TRUE if wall is currently being melted with thermite

	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	explosion_block = 1

	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	flags_ricochet = RICOCHET_HARD
	rad_insulation_beta = RAD_BETA_BLOCKER
	rad_insulation_gamma = RAD_MEDIUM_INSULATION

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall
	rust_resistance = RUST_RESISTANCE_BASIC
	var/heat_resistance = 5000

	var/can_dismantle_with_welder = TRUE
	var/hardness = 40 //lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/slicing_duration = 10 SECONDS
	var/engraving //engraving on the wall
	var/engraving_quality
	var/list/dent_decals
	var/sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amount = 2
	var/girder_type = /obj/structure/girder
	/// Are we a explodable turf?
	var/explodable = FALSE
	/// Do we have a explodable overlay?
	var/explodable_overlay

/turf/simulated/wall/Initialize(mapload)
	. = ..()
	if(smoothing_flags & SMOOTH_DIAGONAL_CORNERS && fixed_underlay) //Set underlays for the diagonal walls.
		var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER, plane = FLOOR_PLANE)
		if(fixed_underlay["space"])
			underlay_appearance.icon = 'icons/turf/space.dmi'
			underlay_appearance.icon_state = SPACE_ICON_STATE
			underlay_appearance.plane = PLANE_SPACE
		else
			underlay_appearance.icon = fixed_underlay["icon"]
			underlay_appearance.icon_state = fixed_underlay["icon_state"]
		fixed_underlay = string_assoc_list(fixed_underlay)
		underlays += underlay_appearance
	AddComponent(/datum/component/debris, DEBRIS_SPARKS, -20, 10, 1)

/turf/simulated/wall/BeforeChange()
	for(var/obj/effect/overlay/wall_rot/WR in src)
		qdel(WR)
	. = ..()

//Appearance
/turf/simulated/wall/examine(mob/user)	//If you change this, consider changing the examine_status proc of false walls to match
	. = ..()

	if(!damage)
		. += SPAN_NOTICE("It looks fully intact.")
	else
		var/dam = damage / damage_cap
		if(dam <= 0.3)
			. += SPAN_WARNING("It looks slightly damaged.")
		else if(dam <= 0.6)
			. += SPAN_WARNING("It looks moderately damaged.")
		else
			. += SPAN_DANGER("It looks heavily damaged.")

	if(rotting)
		. += SPAN_WARNING("There is fungus growing on [src].")
	if(can_dismantle_with_welder)
		. += SPAN_NOTICE("Using a lit welding tool on this item will allow you to slice through it, eventually removing the outer layer.")

/turf/simulated/wall/update_overlays()
	. = ..()
	if(!damage_overlays[1]) //list hasn't been populated
		generate_overlays()

	QUEUE_SMOOTH(src)

	if(explodable && !explodable_overlay)
		explodable_overlay = icon('icons/turf/overlays.dmi', pick("explodable"), pick(NORTH, SOUTH, EAST, WEST))
		. += explodable_overlay

	if(!damage)
		. += dent_decals
		return

	var/overlay = round(damage / damage_cap * length(damage_overlays)) + 1
	if(overlay > length(damage_overlays))
		overlay = length(damage_overlays)

	if(length(dent_decals))
		. += dent_decals

	. += damage_overlays[overlay]
	. += dent_decals

/turf/simulated/wall/proc/generate_overlays()
	var/alpha_inc = 256 / length(damage_overlays)

	for(var/i = 1; i <= length(damage_overlays); i++)
		var/image/img = image(icon = 'icons/turf/walls.dmi', icon_state = "overlay_damage")
		img.blend_mode = BLEND_MULTIPLY
		img.alpha = (i * alpha_inc) - 1
		damage_overlays[i] = img

//Damage

/turf/simulated/wall/proc/take_damage(dam)
	if(dam)
		damage = max(0, damage + dam)
		update_damage()
	return

/turf/simulated/wall/proc/update_damage()
	var/cap = damage_cap
	if(rotting)
		cap = cap / 10

	if(damage >= cap)
		dismantle_wall()
	else
		update_icon()

/turf/simulated/wall/dismantle_wall(devastated = FALSE, explode = FALSE)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we don't /want/ a girder!
			transfer_fingerprints_to(newgirder)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.forceMove(src)

	ChangeTurf(/turf/simulated/floor/plating)
	return TRUE

/turf/simulated/wall/proc/break_wall()
	new sheet_type(src, sheet_amount)
	return new girder_type(src)

/turf/simulated/wall/proc/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/metal(src)

/turf/simulated/wall/ex_act(severity)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity)
	switch(severity)
		if(1.0)
			ChangeTurf(baseturf)
		if(2.0)
			if(prob(50))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1, 1)
		if(3.0)
			take_damage(rand(0, 250))

/turf/simulated/wall/blob_act(obj/structure/blob/B)
	if(prob(50))
		dismantle_wall()
	else
		add_dent(PROJECTILE_IMPACT_WALL_DENT_HIT)

/turf/simulated/wall/rpd_act(mob/user, obj/item/rpd/our_rpd)
	if(our_rpd.mode == RPD_ATMOS_MODE)
		if(!our_rpd.ranged)
			playsound(src, "sound/weapons/circsawhit.ogg", 50, 1)
			user.visible_message(SPAN_NOTICE("[user] starts drilling a hole in [src]..."), SPAN_NOTICE("You start drilling a hole in [src]..."), SPAN_WARNING("You hear drilling."))
			if(!do_after(user, our_rpd.walldelay, target = src)) //Drilling into walls takes time
				return
		our_rpd.create_atmos_pipe(user, src)
	else if(our_rpd.mode == RPD_DISPOSALS_MODE && !our_rpd.ranged)
		return
	else
		..()

/turf/simulated/wall/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	switch(M.damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			M.visible_message(SPAN_DANGER("[M.name] hits [src]!"), SPAN_DANGER("You hit [src]!"))
			if(prob(hardness + M.force) && M.force > 20)
				dismantle_wall(1)
				playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
			else
				add_dent(PROJECTILE_IMPACT_WALL_DENT_HIT)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)
		if(TOX)
			playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
			return FALSE

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(!rotting)
		rotting = 1

		var/number_rots = rand(2,3)
		for(var/i=0, i<number_rots, i++)
			new /obj/effect/overlay/wall_rot(src)

/turf/simulated/wall/burn_down()
	if(istype(sheet_type, /obj/item/stack/sheet/mineral/diamond))
		return
	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/proc/thermitemelt(mob/user as mob, speed)
	if(melting)
		return
	if(istype(sheet_type, /obj/item/stack/sheet/mineral/diamond))
		return

	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = TRUE
	O.density = TRUE
	O.layer = 5

	if(user)
		to_chat(user, SPAN_WARNING("The thermite starts melting through the wall."))

	if(speed)
		melting = TRUE
		while(speed > 0)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)
			speed = max(0, speed - 1 SECONDS)
			sleep(1)
		burn_down()
		var/turf/simulated/floor/F = src
		F.burn_tile()
		if(O)	qdel(O)
		return

	melting = TRUE
	while(reagents.get_reagent_amount("thermite") > 0)
		reagents.remove_reagent("thermite", 5)
		if(damage_cap - damage <= 30)
			burn_down()

			var/turf/simulated/floor/F = src
			F.burn_tile()
			break
		take_damage(30)
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
		sleep(1 SECONDS)
	if(iswallturf(src))
		melting = FALSE
	if(O)
		qdel(O)
	return

//Interactions

/turf/simulated/wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if((M.environment_smash & ENVIRONMENT_SMASH_WALLS) || (M.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		if(M.environment_smash & ENVIRONMENT_SMASH_RWALLS)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			dismantle_wall(1)
			to_chat(M, SPAN_NOTICE("You smash through the wall."))
		else
			to_chat(M, SPAN_NOTICE("You smash against the wall."))
			take_damage(rand(25, 75))
			return

	to_chat(M, SPAN_NOTICE("You push the wall but nothing happens!"))
	return

/turf/simulated/wall/attack_hulk(mob/user, does_attack_animation = FALSE)
	..(user, TRUE)

	if(prob(hardness) || rotting)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		dismantle_wall(TRUE)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		add_dent(PROJECTILE_IMPACT_WALL_DENT_HIT)
		to_chat(user, SPAN_NOTICE("You punch the wall."))
	return TRUE

/turf/simulated/wall/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(rotting)
		if(hardness <= 10)
			to_chat(user, SPAN_NOTICE("This wall feels rather unstable."))
			return
		else
			to_chat(user, SPAN_NOTICE("The wall crumbles under your touch."))
			dismantle_wall()
			return

	to_chat(user, SPAN_NOTICE("You push the wall but nothing happens!"))
	playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
	add_fingerprint(user)
	return ..()

/turf/simulated/wall/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK

	user.changeNext_move(CLICK_CD_MELEE)

	if(!isturf(user.loc))
		return FINISH_ATTACK // No touching walls unless you're on a turf (pretty sure attackby can't be called anyways but whatever)

	if(rotting && try_rot(attacking, user, params))
		return FINISH_ATTACK

	if(try_decon(attacking, user, params))
		return FINISH_ATTACK

	if(try_destroy(attacking, user, params))
		return FINISH_ATTACK

	if(try_wallmount(attacking, user, params))
		return CONTINUE_ATTACK

	// The cyborg gripper does a separate attackby, so bail from this one
	if(istype(attacking, /obj/item/gripper))
		return CONTINUE_ATTACK

/turf/simulated/wall/welder_act(mob/user, obj/item/I)
	. = ..()
	if(reagents?.get_reagent_amount("thermite") && I.use_tool(src, user, volume = I.tool_volume))
		thermitemelt(user)
		return
	if(rotting)
		if(I.use_tool(src, user, volume = I.tool_volume))
			for(var/obj/effect/overlay/wall_rot/WR in src)
				qdel(WR)
			rotting = FALSE
			to_chat(user, SPAN_NOTICE("You burn off the fungi with [I]."))
		return

	// Wall repair stuff
	if(!I.tool_use_check(user, 0))
		return

	var/repairing
	var/time
	if(user.a_intent == INTENT_HARM) // Harm intent
		if(can_dismantle_with_welder)
			repairing = FALSE
			time = slicing_duration
			WELDER_ATTEMPT_SLICING_MESSAGE
		else
			return

	else // Any other intents
		if(damage || LAZYLEN(dent_decals))
			repairing = TRUE
			time = max(5, damage / 5)
			WELDER_ATTEMPT_REPAIR_MESSAGE
		else
			to_chat(user, SPAN_WARNING("[src] doesn't need repairing."))
			return

	if(I.use_tool(src, user, time, volume = I.tool_volume))
		if(repairing)
			WELDER_REPAIR_SUCCESS_MESSAGE
			dent_decals?.Cut() // I feel like this isn't needed but it can't hurt to keep it in anyway
			update_icon()
			take_damage(-damage)
		else
			WELDER_SLICING_SUCCESS_MESSAGE
			dismantle_wall()

/turf/simulated/wall/proc/try_rot(obj/item/I, mob/user, params)
	if((!I.sharp && I.force >= 10) || I.force >= 20)
		to_chat(user, SPAN_NOTICE("[src] crumbles away under the force of your [I.name]."))
		dismantle_wall(1)
		return TRUE
	return FALSE

/turf/simulated/wall/proc/try_decon(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/gun/energy/plasmacutter))
		to_chat(user, SPAN_NOTICE("You begin slicing through the outer plating."))
		playsound(src, I.usesound, 100, 1)

		if(do_after(user, istype(sheet_type, /obj/item/stack/sheet/mineral/diamond) ? 120 * I.toolspeed : 60 * I.toolspeed, target = src))
			to_chat(user, SPAN_NOTICE("You remove the outer plating."))
			dismantle_wall()
			visible_message(SPAN_WARNING("[user] slices apart [src]!"), SPAN_WARNING("You hear metal being sliced apart."))
			return TRUE

	return FALSE

/turf/simulated/wall/proc/try_destroy(obj/item/I, mob/user, params)
	var/isdiamond = istype(sheet_type, /obj/item/stack/sheet/mineral/diamond) // snowflake bullshit

	if(istype(I, /obj/item/pickaxe/drill/diamonddrill))
		to_chat(user, SPAN_NOTICE("You begin to drill though the wall."))

		if(do_after(user, isdiamond ? 480 * I.toolspeed : 240 * I.toolspeed, target = src)) // Diamond pickaxe has 0.25 toolspeed, so 120/60
			to_chat(user, SPAN_NOTICE("Your [I.name] tears though the last of the reinforced plating."))
			dismantle_wall()
			visible_message(SPAN_WARNING("[user] drills through [src]!"), SPAN_WARNING("You hear the grinding of metal."))
		return TRUE

	else if(istype(I, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, SPAN_NOTICE("You begin to disintegrates the wall."))

		if(do_after(user, isdiamond ? 600 * I.toolspeed : 300 * I.toolspeed, target = src)) // Jackhammer has 0.1 toolspeed, so 60/30
			to_chat(user, SPAN_NOTICE("Your [I.name] disintegrates the reinforced plating."))
			dismantle_wall()
			visible_message(SPAN_WARNING("[user] disintegrates [src]!"),SPAN_WARNING("You hear the grinding of metal."))
		return TRUE

	else if(istype(I, /obj/item/pyro_claws))
		to_chat(user, SPAN_NOTICE("You begin to melt the wall."))

		if(do_after(user, isdiamond ? 60 * I.toolspeed : 30 * I.toolspeed, target = src)) // claws has 0.5 toolspeed, so 3/1.5 seconds
			to_chat(user, SPAN_NOTICE("Your [I.name] melts the reinforced plating."))
			dismantle_wall()
			visible_message(SPAN_WARNING("[user] melts [src]!"),SPAN_WARNING("You hear the hissing of steam."))
		return TRUE

	else if(istype(I, /obj/item/zombie_claw))
		to_chat(user, SPAN_NOTICE("You begin to claw apart the wall."))
		if(do_after(user, isdiamond ? 2 MINUTES * I.toolspeed : 1 MINUTES * I.toolspeed, target = src)) // 120/60 seconds by default
			to_chat(user, SPAN_NOTICE("Your [I.name] rip apart the reinforced plating."))
			dismantle_wall()
			visible_message(SPAN_WARNING("[user] claws through [src]!"),SPAN_WARNING("You hear the grinding of metal and bone."))
		return TRUE
	return FALSE

/turf/simulated/wall/proc/try_wallmount(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mounted))
		return TRUE // We don't want attack_hand running and doing stupid shit with this

	if(istype(I, /obj/item/poster))
		place_poster(I, user)
		return TRUE

	//Bone White - Place pipes on walls // I fucking hate your code with a passion bone
	if(istype(I, /obj/item/pipe))
		var/obj/item/pipe/P = I
		if(P.pipe_type != -1) // ANY PIPE
			playsound(get_turf(src), 'sound/weapons/circsawhit.ogg', 50, 1)
			user.visible_message(
				SPAN_NOTICE("[user] starts drilling a hole in [src]."),
				SPAN_NOTICE("You start drilling a hole in [src]."),
				SPAN_NOTICE("You hear a drill."))

			if(do_after(user, 80 * P.toolspeed, target = src))
				user.visible_message(
					SPAN_NOTICE("[user] drills a hole in [src] and pushes [P] into the void."),
					SPAN_NOTICE("You finish drilling [src] and push [P] into the void."),
					SPAN_NOTICE("You hear a ratchet."))

				user.drop_item()
				if(P.is_bent_pipe())  // bent pipe rotation fix see construction.dm
					P.setDir(5)
					if(user.dir == NORTH)
						P.setDir(6)
					else if(user.dir == SOUTH)
						P.setDir(9)
					else if(user.dir == EAST)
						P.setDir(10)
				else
					P.setDir(user.dir)
				P.forceMove(src)
				P.level = 2
		return TRUE
	return FALSE

/turf/simulated/wall/singularity_pull(S, current_size)
	..()
	wall_singularity_pull(current_size)

/turf/simulated/wall/proc/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()

/turf/simulated/wall/narsie_act()
	if(prob(20))
		ChangeTurf(/turf/simulated/wall/cult)

/turf/simulated/wall/acid_act(acidpwr, acid_volume)
	if(explosion_block >= 2)
		acidpwr = min(acidpwr, 50) //we reduce the power so strong walls never get melted.
	. = ..()

/turf/simulated/wall/acid_melt()
	dismantle_wall(1)

/turf/simulated/wall/proc/add_dent(denttype, x=rand(-8, 8), y=rand(-8, 8))
	if(LAZYLEN(dent_decals) >= MAX_DENT_DECALS)
		return

	var/mutable_appearance/decal = mutable_appearance('icons/effects/effects.dmi', "", BULLET_HOLE_LAYER)
	switch(denttype)
		if(PROJECTILE_IMPACT_WALL_DENT_SHOT)
			decal.icon_state = "bullet_hole"
		if(PROJECTILE_IMPACT_WALL_DENT_HIT)
			decal.icon_state = "impact[rand(1, 3)]"

	decal.pixel_x = x
	decal.pixel_y = y

	if(LAZYLEN(dent_decals))
		dent_decals += decal
	else
		dent_decals = list(decal)

	update_icon()

/turf/simulated/wall/MouseEntered(location, control, params)
	var/datum/hud/active_hud = usr.hud_used // Don't nullcheck this stuff, if it breaks we wanna know it breaks
	var/screentip_mode = usr.client.prefs.screentip_mode
	if(screentip_mode == 0 || (flags & NO_SCREENTIPS))
		active_hud.screentip_text.maptext = ""
		return
	//We inline a MAPTEXT() here, because there's no good way to statically add to a string like this
	active_hud.screentip_text.maptext = "<span class='maptext' style='font-family: sans-serif; text-align: center; font-size: [screentip_mode]px; color: [usr.client.prefs.screentip_color]'>[name]</span>"

/turf/simulated/wall/MouseExited(location, control, params)
	usr.hud_used.screentip_text.maptext = ""

/turf/simulated/wall/magic_rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/simulated/floor/plating)// Did you know most walls baseturf is space?
		return

	return ..()

#undef MAX_DENT_DECALS
