#define WALL_DENT_HIT 1
#define WALL_DENT_SHOT 2
#define MAX_DENT_DECALS 15

/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	var/rotting = 0

	var/damage = 0
	var/damage_cap = 100 //Wall will break down to girders if damage reaches this point

	var/damage_overlay
	var/global/damage_overlays[8]

	var/max_temperature = 1800 //K, walls will take damage if they're next to a fire hotter than this

	opacity = 1
	density = 1
	blocks_air = 1
	explosion_block = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/can_dismantle_with_welder = TRUE
	var/hardness = 40 //lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/slicing_duration = 100
	var/engraving //engraving on the wall
	var/engraving_quality
	var/list/dent_decals
	var/sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amount = 2
	var/girder_type = /obj/structure/girder
	var/obj/item/stack/sheet/builtin_sheet = null

	canSmoothWith = list(
	/turf/simulated/wall,
	/turf/simulated/wall/r_wall,
	/obj/structure/falsewall,
	/obj/structure/falsewall/reinforced,
	/turf/simulated/wall/rust,
	/turf/simulated/wall/r_wall/rust,
	/turf/simulated/wall/r_wall/coated)
	smooth = SMOOTH_TRUE

/turf/simulated/wall/New()
	..()
	builtin_sheet = new sheet_type

/turf/simulated/wall/BeforeChange()
	for(var/obj/effect/overlay/wall_rot/WR in src)
		qdel(WR)
	. = ..()

//Appearance
/turf/simulated/wall/examine(mob/user)
	. = ..()

	if(!damage)
		. += "<span class='notice'>It looks fully intact.</span>"
	else
		var/dam = damage / damage_cap
		if(dam <= 0.3)
			. += "<span class='warning'>It looks slightly damaged.</span>"
		else if(dam <= 0.6)
			. += "<span class='warning'>It looks moderately damaged.</span>"
		else
			. += "<span class='danger'>It looks heavily damaged.</span>"

	if(rotting)
		. += "<span class='warning'>There is fungus growing on [src].</span>"

/turf/simulated/wall/proc/update_icon()
	if(!damage_overlays[1]) //list hasn't been populated
		generate_overlays()

	queue_smooth(src)
	if(!damage)
		if(damage_overlay)
			overlays -= damage_overlays[damage_overlay]
			damage_overlay = 0
		return

	var/overlay = round(damage / damage_cap * damage_overlays.len) + 1
	if(overlay > damage_overlays.len)
		overlay = damage_overlays.len

	if(damage_overlay && overlay == damage_overlay) //No need to update.
		return
	if(damage_overlay)
		overlays -= damage_overlays[damage_overlay]
	overlays += damage_overlays[overlay]
	damage_overlay = overlay

/turf/simulated/wall/proc/generate_overlays()
	var/alpha_inc = 256 / damage_overlays.len

	for(var/i = 1; i <= damage_overlays.len; i++)
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

	return

/turf/simulated/wall/proc/adjacent_fire_act(turf/simulated/wall, radiated_temperature)
	if(radiated_temperature > max_temperature)
		take_damage(rand(10, 20) * (radiated_temperature / max_temperature))

/turf/simulated/wall/handle_ricochet(obj/item/projectile/P)			//A huge pile of shitcode!
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	if(abs(incidence_s) > 90 && abs(incidence_s) < 270)
		return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	return TRUE

/turf/simulated/wall/proc/dismantle_wall(devastated = 0, explode = 0)
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

/turf/simulated/wall/proc/break_wall()
	new sheet_type(src, sheet_amount)
	return new girder_type(src)

/turf/simulated/wall/proc/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/metal(src)

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			ChangeTurf(baseturf)
			return
		if(2.0)
			if(prob(50))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1, 1)
		if(3.0)
			take_damage(rand(0, 250))
		else
	return

/turf/simulated/wall/blob_act(obj/structure/blob/B)
	if(prob(50))
		dismantle_wall()
	else
		add_dent(WALL_DENT_HIT)

/turf/simulated/wall/rpd_act(mob/user, obj/item/rpd/our_rpd)
	if(our_rpd.mode == RPD_ATMOS_MODE)
		if(!our_rpd.ranged)
			playsound(src, "sound/weapons/circsawhit.ogg", 50, 1)
			user.visible_message("<span class='notice'>[user] starts drilling a hole in [src]...</span>", "<span class='notice'>You start drilling a hole in [src]...</span>", "<span class='warning'>You hear drilling.</span>")
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
			M.visible_message("<span class='danger'>[M.name] hits [src]!</span>", "<span class='danger'>You hit [src]!</span>")
			if(prob(hardness + M.force) && M.force > 20)
				dismantle_wall(1)
				playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
			else
				add_dent(WALL_DENT_HIT)
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
	ChangeTurf(/turf/simulated/floor)

/turf/simulated/wall/proc/thermitemelt(mob/user as mob, speed)
	var/wait = 100
	if(speed)
		wait = speed
	if(istype(sheet_type, /obj/item/stack/sheet/mineral/diamond))
		return

	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	F.burn_tile()
	F.icon_state = "plating"
	if(user)
		to_chat(user, "<span class='warning'>The thermite starts melting through the wall.</span>")

	spawn(wait)
		if(O)	qdel(O)
	return

//Interactions

/turf/simulated/wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if((M.environment_smash & ENVIRONMENT_SMASH_WALLS) || (M.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		if(M.environment_smash & ENVIRONMENT_SMASH_RWALLS)
			dismantle_wall(1)
			to_chat(M, "<span class='info'>You smash through the wall.</span>")
		else
			to_chat(M, text("<span class='notice'>You smash against the wall.</span>"))
			take_damage(rand(25, 75))
			return

	to_chat(M, "<span class='notice'>You push the wall but nothing happens!</span>")
	return

/turf/simulated/wall/attack_hulk(mob/user, does_attack_animation = FALSE)
	..(user, TRUE)

	if(prob(hardness) || rotting)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		dismantle_wall(TRUE)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		add_dent(WALL_DENT_HIT)
		to_chat(user, text("<span class='notice'>You punch the wall.</span>"))
	return TRUE

/turf/simulated/wall/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(rotting)
		if(hardness <= 10)
			to_chat(user, "<span class='notice'>This wall feels rather unstable.</span>")
			return
		else
			to_chat(user, "<span class='notice'>The wall crumbles under your touch.</span>")
			dismantle_wall()
			return

	to_chat(user, "<span class='notice'>You push the wall but nothing happens!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
	add_fingerprint(user)
	return ..()

/turf/simulated/wall/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)

	if(!isturf(user.loc))
		return // No touching walls unless you're on a turf (pretty sure attackby can't be called anyways but whatever)

	if(rotting && try_rot(I, user, params))
		return

	if(try_decon(I, user, params))
		return

	if(try_destroy(I, user, params))
		return

	if(try_wallmount(I, user, params))
		return
	// The magnetic gripper does a separate attackby, so bail from this one
	if(istype(I, /obj/item/gripper))
		return

	return ..()

/turf/simulated/wall/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(thermite && I.use_tool(src, user, volume = I.tool_volume))
		thermitemelt(user)
		return
	if(rotting)
		if(I.use_tool(src, user, volume = I.tool_volume))
			for(var/obj/effect/overlay/wall_rot/WR in src)
				qdel(WR)
			rotting = FALSE
			to_chat(user, "<span class='notice'>You burn off the fungi with [I].</span>")
		return

	if(!I.tool_use_check(user, 0)) //Wall repair stuff
		return

	var/time_required = slicing_duration
	var/intention
	if(can_dismantle_with_welder)
		intention = "Dismantle"
	if(damage || LAZYLEN(dent_decals))
		intention = "Repair"
		if(can_dismantle_with_welder)
			var/moved_away = user.loc
			intention = alert(user, "Would you like to repair or dismantle [src]?", "[src]", "Repair", "Dismantle")
			if(user.loc != moved_away)
				to_chat(user, "<span class='notice'>Stay still while doing this!</span>")
				return
			if(intention == "Repair")
				time_required = max(5, damage / 5)
	if(!intention)
		return
	if(intention == "Dismantle")
		WELDER_ATTEMPT_SLICING_MESSAGE
	else
		WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, time_required, volume = I.tool_volume))
		if(intention == "Dismantle")
			WELDER_SLICING_SUCCESS_MESSAGE
			dismantle_wall()
		else
			WELDER_REPAIR_SUCCESS_MESSAGE
			cut_overlay(dent_decals)
			dent_decals?.Cut()
			take_damage(-damage)

/turf/simulated/wall/proc/try_rot(obj/item/I, mob/user, params)
	if((!is_sharp(I) && I.force >= 10) || I.force >= 20)
		to_chat(user, "<span class='notice'>[src] crumbles away under the force of your [I.name].</span>")
		dismantle_wall(1)
		return TRUE
	return FALSE

/turf/simulated/wall/proc/try_decon(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/gun/energy/plasmacutter))
		to_chat(user, "<span class='notice'>You begin slicing through the outer plating.</span>")
		playsound(src, I.usesound, 100, 1)

		if(do_after(user, istype(sheet_type, /obj/item/stack/sheet/mineral/diamond) ? 120 * I.toolspeed : 60 * I.toolspeed, target = src))
			to_chat(user, "<span class='notice'>You remove the outer plating.</span>")
			dismantle_wall()
			visible_message("<span class='warning'>[user] slices apart [src]!</span>", "<span class='warning'>You hear metal being sliced apart.</span>")
			return TRUE

	return FALSE

/turf/simulated/wall/proc/try_destroy(obj/item/I, mob/user, params)
	var/isdiamond = istype(sheet_type, /obj/item/stack/sheet/mineral/diamond) // snowflake bullshit

	if(istype(I, /obj/item/pickaxe/drill/diamonddrill))
		to_chat(user, "<span class='notice'>You begin to drill though the wall.</span>")

		if(do_after(user, isdiamond ? 480 * I.toolspeed : 240 * I.toolspeed, target = src)) // Diamond pickaxe has 0.25 toolspeed, so 120/60
			to_chat(user, "<span class='notice'>Your [I.name] tears though the last of the reinforced plating.</span>")
			dismantle_wall()
			visible_message("<span class='warning'>[user] drills through [src]!</span>", "<span class='warning'>You hear the grinding of metal.</span>")
			return TRUE

	else if(istype(I, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, "<span class='notice'>You begin to disintegrates the wall.</span>")

		if(do_after(user, isdiamond ? 600 * I.toolspeed : 300 * I.toolspeed, target = src)) // Jackhammer has 0.1 toolspeed, so 60/30
			to_chat(user, "<span class='notice'>Your [I.name] disintegrates the reinforced plating.</span>")
			dismantle_wall()
			visible_message("<span class='warning'>[user] disintegrates [src]!</span>","<span class='warning'>You hear the grinding of metal.</span>")
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
				"<span class='notice'>[user] starts drilling a hole in [src].</span>",
				"<span class='notice'>You start drilling a hole in [src].</span>",
				"<span class='notice'>You hear a drill.</span>")

			if(do_after(user, 80 * P.toolspeed, target = src))
				user.visible_message(
					"<span class='notice'>[user] drills a hole in [src] and pushes [P] into the void.</span>",
					"<span class='notice'>You finish drilling [src] and push [P] into the void.</span>",
					"<span class='notice'>You hear a ratchet.</span>")

				user.drop_item()
				if(P.is_bent_pipe())  // bent pipe rotation fix see construction.dm
					P.setDir(5)
					if(user.dir == 1)
						P.setDir(6)
					else if(user.dir == 2)
						P.setDir(9)
					else if(user.dir == 4)
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
		if(WALL_DENT_SHOT)
			decal.icon_state = "bullet_hole"
		if(WALL_DENT_HIT)
			decal.icon_state = "impact[rand(1, 3)]"

	decal.pixel_x = x
	decal.pixel_y = y

	if(LAZYLEN(dent_decals))
		cut_overlay(dent_decals)
		dent_decals += decal
	else
		dent_decals = list(decal)

	add_overlay(dent_decals)

#undef MAX_DENT_DECALS