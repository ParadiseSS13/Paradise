//This proc is called in master-controller, and updates the color of all windows and windoors on the map
var/global/wcBar
var/global/wcBrig
var/global/wcCommon
var/global/wcColored
/proc/color_windows_init()
	var/list/bar = list("#0d8395", "#58b5c3", "#58c366", "#90d79a", "#ffffff")
	var/list/brig = list("#aa0808", "#7f0606", "#ff0000")
	var/list/common = list("#379963", "#0d8395", "#58b5c3", "#49e46e", "#8fcf44", "#ffffff")

	wcBar = pick(bar)
	wcBrig = pick(brig)
	wcCommon = pick(common)

/obj/proc/color_windows(var/obj/W as obj)
	if(!wcColored)
		sleep(50) // Sleeping to make sure the glass has initialized on the map
		wcColored = 1

	var/list/wcBarAreas = list(/area/crew_quarters/bar)
	var/list/wcBrigAreas = list(/area/security,/area/security/main,/area/security/lobby,/area/security/brig,/area/security/permabrig,/area/security/prison,/area/security/prison/cell_block/A,/area/security/prison/cell_block/B,/area/security/prison/cell_block/C,/area/security/execution,/area/security/processing,/area/security/interrogation,/area/security/interrogationobs,/area/security/evidence,/area/security/prisonlockers,/area/security/medbay,/area/security/processing,/area/security/warden,/area/security/armoury,/area/security/securearmoury,/area/security/armoury/gamma,/area/security/securehallway,/area/security/hos,/area/security/podbay,/area/security/detectives_office,/area/security/range,/area/security/nuke_storage,/area/security/customs,/area/security/customs2,/area/security/checkpoint,/area/security/checkpoint2,/area/security/checkpoint2,/area/security/checkpoint/supply,/area/security/checkpoint/engineering,/area/security/checkpoint/medical,/area/security/checkpoint/science,/area/security/vacantoffice2,/area/prison,/area/prison/arrival_airlock,/area/prison/control,/area/prison/crew_quarters,/area/prison/rec_room,/area/prison/closet,/area/prison/hallway/fore,/area/prison/hallway/aft,/area/prison/hallway/port,/area/prison/hallway/starboard,/area/prison/morgue,/area/prison/medical_research,/area/prison/medical,/area/prison/solar,/area/prison/podbay,/area/prison/solar_control,/area/prison/solitary,/area/prison/cell_block,/area/prison/cell_block/A,/area/prison/cell_block/B,/area/prison/cell_block/C,/area/shuttle/gamma/space,/area/shuttle/gamma/station,/area/security/prisonershuttle)

	var/newcolor
	for(var/A in wcBarAreas)
		if(W.areaMaster == locate(A))
			newcolor = wcBar
			break

	for(var/A in wcBrigAreas)
		if(W.areaMaster == locate(A))
			newcolor = wcBrig
			break

	if(!newcolor)
		newcolor = wcCommon

	return newcolor

/obj/structure/window
	name = "window"
	desc = "A window."
	icon = 'icons/obj/structures.dmi'
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER
	var/health = 14.0
	var/ini_dir = null
	var/state = 2
	var/reinf = 0
	var/basestate
	var/shardtype = /obj/item/weapon/shard
	var/glasstype = /obj/item/stack/sheet/glass
	var/disassembled = 0
	var/sheets = 1 // Number of sheets needed to build this window (determines how much shit is spawned by destroy())
//	var/silicate = 0 // number of units of silicate
//	var/icon/silicateIcon = null // the silicated icon

/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
		update_nearby_icons()
	..()
	if(health <= 0)
		var/pdiff=performWallPressureCheck(src.loc)
		if(pdiff>0)
			message_admins("Window destroyed by [Proj.firer.name] ([formatPlayerPanel(Proj.firer,Proj.firer.ckey)]) via \an [Proj]! pdiff = [pdiff] at [formatJumpTo(loc)]!")
			log_admin("Window destroyed by ([Proj.firer.ckey]) via \an [Proj]! pdiff = [pdiff] at [loc]!")
		destroy()
	return

// This should result in the same materials used to make the window.
/obj/structure/window/proc/destroy()
	for(var/i=0;i<sheets;i++)
		getFromPool(shardtype, loc)

		if(reinf)
			new /obj/item/stack/rods(loc)
	qdel(src)

/obj/structure/window/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			destroy()
			return
		if(3.0)
			if(prob(50))
				destroy()
				return


/obj/structure/window/blob_act()
	destroy()

/obj/structure/window/meteorhit()
	destroy()

/obj/structure/window/CheckExit(var/atom/movable/O, var/turf/target)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return !density
	return 1

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/window/hitby(AM as mob|obj)
	..()
	visible_message("<span class='danger'>[src] was hit by [AM].</span>")
	var/tforce = 0
	var/mob/M=null
	if(ismob(AM))
		tforce = 40
		M=AM
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	if(reinf) tforce *= 0.25
	playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
	health = max(0, health - tforce)
	if(health <= 7 && !reinf)
		anchored = 0
		update_nearby_icons()
		step(src, get_dir(AM, src))
		var/pdiff=performWallPressureCheck(src.loc)
		if(pdiff>0)
			if(M)
				message_admins("Window with pdiff [pdiff] at [formatJumpTo(loc)] deanchored by [M.real_name] ([formatPlayerPanel(M,M.ckey)])!")
				log_admin("Window with pdiff [pdiff] at [loc] deanchored by [M.real_name] ([M.ckey])!")
			else
				message_admins("Window with pdiff [pdiff] at [formatJumpTo(loc)] deanchored by [AM]!")
				log_admin("Window with pdiff [pdiff] at [loc] deanchored by [AM]!")
	if(health <= 0)
		var/pdiff=performWallPressureCheck(src.loc)
		if(pdiff>0)
			if(M)
				message_admins("Window with pdiff [pdiff] at [formatJumpTo(loc)] destroyed by [M.real_name] ([formatPlayerPanel(M,M.ckey)])!")
				log_admin("Window with pdiff [pdiff] at [loc] destroyed by [M.real_name] ([M.ckey])!")
			else
				message_admins("Window with pdiff [pdiff] at [formatJumpTo(loc)] destroyed by [AM]!")
				log_admin("Window with pdiff [pdiff] at [loc] destroyed by [AM]!")
		destroy()


/obj/structure/window/attack_hand(mob/user as mob)
	if(M_HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
		var/pdiff=performWallPressureCheck(src.loc)
		if(pdiff>0)
			message_admins("Window destroyed by hulk [user.real_name] ([formatPlayerPanel(user,user.ckey)]) with pdiff [pdiff] at [formatJumpTo(loc)]!")
			log_admin("Window destroyed by hulk [user.real_name] ([user.ckey]) with pdiff [pdiff] at [loc]!")
		destroy()
	else if (usr.a_intent == "harm")
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 80, 1)
		usr.visible_message("\red [usr.name] bangs against the [src.name]!", \
							"\red You bang against the [src.name]!", \
							"You hear a banging sound.")
	else
		playsound(src.loc, 'sound/effects/glassknock.ogg', 80, 1)
		usr.visible_message("[usr.name] knocks on the [src.name].", \
							"You knock on the [src.name].", \
							"You hear a knocking sound.")
	return


/obj/structure/window/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/window/proc/attack_generic(mob/user as mob, damage = 0)	//used by attack_alien, attack_animal, and attack_slime
	health -= damage
	if(health <= 0)
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
		var/pdiff=performWallPressureCheck(src.loc)
		if(pdiff>0)
			message_admins("Window destroyed by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) with pdiff [pdiff] at [formatJumpTo(loc)]!")
		destroy()
	else	//for nicer text~
		user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)


/obj/structure/window/attack_alien(mob/user as mob)
	if(islarva(user)) return
	attack_generic(user, 15)

/obj/structure/window/attack_animal(mob/user as mob)
	if(!isanimal(user)) return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0) return
	attack_generic(M, M.melee_damage_upper)


/obj/structure/window/attack_slime(mob/user as mob)
	var/mob/living/carbon/slime/S = user
	if (!S.is_adult)
		return
	attack_generic(user, rand(10, 15))


/obj/structure/window/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!istype(W)) return//I really wish I did not need this
	if(W.flags & NOBLUDGEON) return

	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if (istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			var/state = G.state
			del(W)	//gotta delete it here because if window breaks, it won't get deleted
			switch (state)
				if(1)
					M.apply_damage(7)
					hit(10)
					visible_message("\red [user] slams [M] against \the [src]!")
				if(2)
					if (prob(50))
						M.Weaken(1)
					M.apply_damage(10)
					hit(25)
					visible_message("\red <b>[user] bashes [M] against \the [src]!</b>")
				if(3)
					M.Weaken(5)
					M.apply_damage(20)
					hit(50)
					visible_message("\red <big><b>[user] crushes [M] against \the [src]!</b></big>")
				if(4)
					M.Weaken(5)
					M.apply_damage(30)
					hit(75)
					visible_message("\red <big><b>[user] smashes [M] against \the [src]!</b></big>")
			return
	if(istype(W, /obj/item/weapon/screwdriver))
		if(reinf && state >= 1)
			state = 3 - state
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (state == 1 ? "<span class='notice'>You have unfastened the window from the frame.</span>" : "<span class='notice'>You have fastened the window to the frame.</span>")
		else if(reinf && state == 0)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (anchored ? "<span class='notice'>You have fastened the frame to the floor.</span>" : "<span class='notice'>You have unfastened the frame from the floor.</span>")
			if(!anchored)
				var/pdiff=performWallPressureCheck(src.loc)
				if(pdiff>0)
					message_admins("Window with pdiff [pdiff] deanchored by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)]!")
					log_admin("Window with pdiff [pdiff] deanchored by [user.real_name] ([user.ckey]) at [loc]!")
		else if(!reinf)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (anchored ? "<span class='notice'>You have fastened the window to the floor.</span>" : "<span class='notice'>You have unfastened the window.</span>")
			if(!anchored)
				var/pdiff=performWallPressureCheck(src.loc)
				if(pdiff>0)
					message_admins("Window with pdiff [pdiff] deanchored by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)]!")
					log_admin("Window with pdiff [pdiff] deanchored by [user.real_name] ([user.ckey]) at [loc]!")
	else if(istype(W, /obj/item/weapon/crowbar) && reinf && state <= 1)
		state = 1 - state
		playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
		user << (state ? "<span class='notice'>You have pried the window into the frame.</span>" : "<span class='notice'>You have pried the window out of the frame.</span>")
	else if(istype(W, /obj/item/weapon/wrench) && !anchored && health > 7) //Disassemble deconstructed window into parts
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		for(var/i=0;i<sheets;i++)
			var/obj/item/stack/sheet/glass/NG = getFromPool(glasstype, src.loc)
			for (var/obj/item/stack/sheet/glass/G in src.loc) //Stack em up
				if(G==NG)
					continue
				if(G.amount>=G.max_amount)
					continue
				G.attackby(NG, user)

			if (reinf)
				var/obj/item/stack/rods/NR = new (src.loc)
				for (var/obj/item/stack/rods/R in src.loc)
					if(R==NR)
						continue
					if(R.amount>=R.max_amount)
						continue
					R.attackby(NR, user)

		user << "<span class='notice'>You have disassembled the window.</span>"
		disassembled = 1
		density = 0
		update_nearby_tiles()
		update_nearby_icons()
		del(src)
	else
		if(W.damtype == BRUTE || W.damtype == BURN)
			hit(W.force)
			if(health <= 7)
				anchored = 0
				update_nearby_icons()
				step(src, get_dir(user, src))
				var/pdiff=performWallPressureCheck(src.loc)
				if(pdiff>0)
					message_admins("Window with pdiff [pdiff] deanchored by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)]!")
					log_admin("Window with pdiff [pdiff] deanchored by [user.real_name] ([user.ckey]) at [loc]!")
		else
			playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		..()
	return


/obj/structure/window/mech_melee_attack(obj/mecha/M)
	if(..())
		hit(M.force, 1)

/obj/structure/window/proc/hit(var/damage, var/sound_effect = 1)
	if(reinf) damage *= 0.5
	health = max(0, health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	if(health <= 0)
		var/pdiff=performWallPressureCheck(src.loc)
		if(pdiff>0)
			message_admins("Window with pdiff [pdiff] broken at [formatJumpTo(loc)]!")
		destroy()
		return


/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = null
	set src in oview(1)

	if(anchored)
		usr << "It is fastened to the floor therefore you can't rotate it!"
		return 0

	update_nearby_tiles(need_rebuild=1) //Compel updates before
	dir = turn(dir, 90)
//	updateSilicate()
	update_nearby_tiles(need_rebuild=1)
	ini_dir = dir
	return


/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = null
	set src in oview(1)

	if(anchored)
		usr << "It is fastened to the floor therefore you can't rotate it!"
		return 0

	update_nearby_tiles(need_rebuild=1) //Compel updates before
	dir = turn(dir, 270)
//	updateSilicate()
	update_nearby_tiles(need_rebuild=1)
	ini_dir = dir
	return


/*
/obj/structure/window/proc/updateSilicate()
	if(silicateIcon && silicate)
		icon = initial(icon)

		var/icon/I = icon(icon,icon_state,dir)

		var/r = (silicate / 100) + 1
		var/g = (silicate / 70) + 1
		var/b = (silicate / 50) + 1
		I.SetIntensity(r,g,b)
		icon = I
		silicateIcon = I
*/

/obj/structure/window/New(Loc,re=0)
	..()
	ini_dir = dir
	if(!color && !istype(src,/obj/structure/window/plasmabasic) && !istype(src,/obj/structure/window/plasmareinforced))
		color = color_windows(src)
	update_nearby_tiles(need_rebuild=1)
	update_nearby_icons()
	return

/obj/structure/window/Destroy()
	density = 0
	update_nearby_tiles()
	if(loc && !disassembled)
		playsound(get_turf(src), "shatter", 70, 1)
	update_nearby_icons()
	..()


/obj/structure/window/Move()
	update_nearby_tiles(need_rebuild=1)
	..()
	dir = ini_dir
	update_nearby_tiles(need_rebuild=1)


//This proc has to do with airgroups and atmos, it has nothing to do with smoothwindows, that's update_nearby_tiles().
/obj/structure/window/proc/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0
	air_master.mark_for_update(get_turf(src))

	return 1

//checks if this window is full-tile one
/obj/structure/window/proc/is_fulltile()
	if(dir & (dir - 1))
		return 1
	return 0

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window/proc/update_nearby_icons()
	if(!loc) return 0
	update_icon()
	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(src,direction) )
			W.update_icon()

/obj/structure/window/update_icon()
	return

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		hit(round(exposed_volume / 100), 0)
	..()

/obj/structure/window/basic
	icon_state = "window"
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."
	basestate = "window"

/obj/structure/window/plasmabasic
	name = "plasma window"
	desc = "A plasma-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	basestate = "plasmawindow"
	icon_state = "plasmawindow"
	shardtype = /obj/item/weapon/shard/plasma
	glasstype = /obj/item/stack/sheet/plasmaglass
	health = 120

/obj/structure/window/plasmabasic/New(Loc,re=0)
	..()
	ini_dir = dir
	update_nearby_tiles(need_rebuild=1)
	update_nearby_icons()
	return

/obj/structure/window/plasmabasic/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 32000)
		hit(round(exposed_volume / 1000), 0)
	..()

/obj/structure/window/plasmareinforced
	name = "reinforced plasma window"
	desc = "A plasma-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic plasma windows are insanely fireproof."
	basestate = "plasmarwindow"
	icon_state = "plasmarwindow"
	shardtype = /obj/item/weapon/shard/plasma
	glasstype = /obj/item/stack/sheet/plasmaglass
	reinf = 1
	health = 160
	explosion_resistance = 4


/obj/structure/window/plasmareinforced/New(Loc,re=0)
	..()
	ini_dir = dir
	update_nearby_tiles(need_rebuild=1)
	update_nearby_icons()
	return

/obj/structure/window/plasmareinforced/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	reinf = 1
	basestate = "rwindow"
	health = 40
	explosion_resistance = 1

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	basestate = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	desc = "It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	basestate = "fwindow"
	health = 30