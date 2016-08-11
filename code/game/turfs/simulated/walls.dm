/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	var/mineral = "metal"
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

	var/walltype = "metal"
	var/hardness = 40 //lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/engraving, engraving_quality //engraving on the wall

	canSmoothWith = list(
	/turf/simulated/wall,
	/turf/simulated/wall/r_wall,
	/obj/structure/falsewall,
	/obj/structure/falsewall/reinforced,
	/turf/simulated/wall/rust,
	/turf/simulated/wall/r_wall/rust,
	/turf/simulated/wall/r_wall/coated)
	smooth = SMOOTH_TRUE

/turf/simulated/wall/BeforeChange()
	for(var/obj/effect/E in src)
		// such quality code
		if(E.name == "Wallrot")
			qdel(E)
	. = ..()

//Appearance

/turf/simulated/wall/examine(mob/user)
	. = ..(user)

	if(!damage)
		to_chat(user, "<span class='notice'>It looks fully intact.</span>")
	else
		var/dam = damage / damage_cap
		if(dam <= 0.3)
			to_chat(user, "<span class='warning'>It looks slightly damaged.</span>")
		else if(dam <= 0.6)
			to_chat(user, "<span class='warning'>It looks moderately damaged.</span>")
		else
			to_chat(user, "<span class='danger'>It looks heavily damaged.</span>")

	if(rotting)
		to_chat(user, "<span class='warning'>There is fungus growing on [src].</span>")

/turf/simulated/wall/proc/update_icon()
	if(!damage_overlays[1]) //list hasn't been populated
		generate_overlays()

	smooth_icon(src)
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

/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(istype(src,/turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/structure/girder/reinforced(src)
			new /obj/item/stack/sheet/plasteel( src )
		else
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/plasteel( src )
	else if(istype(src,/turf/simulated/wall/cult))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/structure/cultgirder(src)
		else
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/effect/decal/remains/human(src)

	else
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/structure/girder(src)
			if(mineral == "metal")
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M( src )
				new M( src )
		else
			if(mineral == "metal")
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M( src )
				new M( src )
				new /obj/item/stack/sheet/metal( src )

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src

	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ChangeTurf(/turf/space)
			return
		if(2.0)
			if(prob(50))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1,1)
		if(3.0)
			take_damage(rand(0, 250))
		else
	return

/turf/simulated/wall/blob_act()
	if(prob(50))
		dismantle_wall()

/turf/simulated/wall/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[src] has been hit by [M.name].</span>")
		if(prob(5) && M.force > 20)
			dismantle_wall(1)
			M.occupant_message("<span class='warning'>You smash through the wall.</span>")
			visible_message("<span class='warning'>[src.name] smashes through the wall!</span>")
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(!rotting)
		rotting = 1

		var/number_rots = rand(2,3)
		for(var/i=0, i<number_rots, i++)
			var/obj/effect/overlay/O = new/obj/effect/overlay( src )
			O.name = "Wallrot"
			O.desc = "Ick..."
			O.icon = 'icons/effects/wallrot.dmi'
			O.pixel_x += rand(-10, 10)
			O.pixel_y += rand(-10, 10)
			O.anchored = 1
			O.density = 1
			O.layer = 5
			O.mouse_opacity = 0

/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	if(mineral == "diamond")
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
	F.icon_state = "wall_thermite"
	to_chat(user, "<span class='warning'>The thermite starts melting through the wall.</span>")

	spawn(100)
		if(O)	qdel(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return

//Interactions

/turf/simulated/wall/attack_animal(var/mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.environment_smash >= 2)
		if(M.environment_smash == 3)
			dismantle_wall(1)
			to_chat(M, "<span class='info'>You smash through the wall.</span>")
		else
			to_chat(M, text("<span class='notice'>You smash against the wall.</span>"))
			take_damage(rand(25, 75))
			return

	to_chat(M, "\blue You push the wall but nothing happens!")
	return

/turf/simulated/wall/attack_hand(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	if(HULK in user.mutations)
		if(prob(hardness) || rotting)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			to_chat(user, text("<span class='notice'>You smash through the wall.</span>"))
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			dismantle_wall(1)
			return
		else
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
			to_chat(user, text("<span class='notice'>You punch the wall.</span>"))
			return

	if(rotting)
		if(hardness <= 10)
			to_chat(user, "<span class='notice'>This wall feels rather unstable.</span>")
			return
		else
			to_chat(user, "<span class='notice'>The wall crumbles under your touch.</span>")
			dismantle_wall()
			return

	to_chat(user, "<span class='notice'>You push the wall but nothing happens!</span>")
	playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	..()
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	//get the user's location
	if(!istype(user.loc, /turf))	return	//can't do this stuff whilst inside objects and such

	if(rotting)
		if(istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				to_chat(user, "<span class='notice'>You burn away the fungi with \the [WT].</span>")
				playsound(src, 'sound/items/Welder.ogg', 10, 1)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					qdel(E)
				rotting = 0
				return
		else if(!is_sharp(W) && W.force >= 10 || W.force >= 20)
			to_chat(user, "<span class='notice'>\The [src] crumbles away under the force of your [W.name].</span>")
			src.dismantle_wall(1)
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				thermitemelt(user)
				return

		else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
			thermitemelt(user)
			return

		else if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			to_chat(user, "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>")
			playsound(src, "sparks", 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)

			thermitemelt(user)
			return

	//DECONSTRUCTION
	if(istype(W, /obj/item/weapon/weldingtool))

		var/response = "Dismantle"
		if(damage)
			response = alert(user, "Would you like to repair or dismantle [src]?", "[src]", "Repair", "Dismantle")

		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0,user))
			if(response == "Repair")
				to_chat(user, "<span class='notice'>You start repairing the damage to [src].</span>")
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				if(do_after(user, max(5, damage / 5), target = src) && WT && WT.isOn())
					to_chat(user, "<span class='notice'>You finish repairing the damage to [src].</span>")
					take_damage(-damage)

			else if(response == "Dismantle")
				to_chat(user, "<span class='notice'>You begin slicing through the outer plating.</span>")
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 100, target = src) && WT && WT.isOn())
					to_chat(user, "<span class='notice'>You remove the outer plating.</span>")
					dismantle_wall()

				else
					to_chat(user, "<span class='warning'>You stop slicing through [src].</span>")
					return

		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return

	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))

		to_chat(user, "<span class='notice'>You begin slicing through the outer plating.</span>")
		playsound(src, 'sound/items/Welder.ogg', 100, 1)

		if(do_after(user, mineral == "diamond" ? 120 : 60, target = src))
			to_chat(user, "<span class='notice'>You remove the outer plating.</span>")
			dismantle_wall()
			visible_message("<span class='warning'>[user] slices apart \the [src]!</span>","<span class='warning'>You hear metal being sliced apart.</span>")

	//DRILLING
	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamonddrill))

		to_chat(user, "<span class='notice'>You begin to drill though the wall.</span>")

		if(do_after(user, mineral == "diamond" ? 120 : 60, target = src))
			to_chat(user, "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>")
			dismantle_wall()
			visible_message("<span class='warning'>[user] drills through \the [src]!</span>","<span class='warning'>You hear the grinding of metal.</span>")

	else if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))

		to_chat(user, "<span class='notice'>You begin to disintegrates the wall.</span>")

		if(do_after(user, mineral == "diamond" ? 60 : 30, target = src))
			to_chat(user, "<span class='notice'>Your jackhammer disintegrate the reinforced plating.</span>")
			dismantle_wall()
			visible_message("<span class='warning'>[user] disintegrates \the [src]!</span>","<span class='warning'>You hear the grinding of metal.</span>")

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/obj/item/weapon/melee/energy/blade/EB = W

		EB.spark_system.start()
		to_chat(user, "<span class='notice'>You stab \the [EB] into the wall and begin to slice it apart.</span>")
		playsound(src, "sparks", 50, 1)

		if(do_after(user, mineral == "diamond" ? 140 : 70, target = src))
			EB.spark_system.start()
			playsound(src, "sparks", 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)
			dismantle_wall(1)
			visible_message("<span class='warning'>[user] slices apart \the [src]!</span>","<span class='warning'>You hear metal being sliced apart and sparks flying.</span>")

	else if(istype(W,/obj/item/mounted)) //if we place it, we don't want to have a silly message
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/contraband/poster))
		place_poster(W,user)
		return

	//Bone White - Place pipes on walls
	else if(istype(W,/obj/item/pipe))
		var/obj/item/pipe/V = W
		if(V.pipe_type != -1) // ANY PIPE
			var/obj/item/pipe/P = W

			playsound(get_turf(src), 'sound/weapons/circsawhit.ogg', 50, 1)
			user.visible_message( \
				"[user] starts drilling a hole in \the [src].", \
				"\blue You start drilling a hole in \the [src].", \
				"You hear ratchet.")
			if(do_after(user, 80, target = src))
				user.visible_message( \
					"[user] drills a hole in \the [src] and pushes \a [P] into the void", \
					"\blue You have finished drilling in \the [src] and push the [P] into the void.", \
					"You hear ratchet.")

				user.drop_item()
				if(P.is_bent_pipe())  // bent pipe rotation fix see construction.dm
					P.dir = 5
					if(user.dir == 1)
						P.dir = 6
					else if(user.dir == 2)
						P.dir = 9
					else if(user.dir == 4)
						P.dir = 10
				else
					P.dir = user.dir
				P.x = src.x
				P.y = src.y
				P.z = src.z
				P.loc = src
				P.level = 2
		return
	// The magnetic gripper does a separate attackby, so bail from this one
	else if(istype(W, /obj/item/weapon/gripper))
		return

	else
		return attack_hand(user)
	return

/turf/simulated/wall/singularity_pull(S, current_size)
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
