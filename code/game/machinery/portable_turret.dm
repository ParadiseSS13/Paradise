/*		Portable Turrets:
		Constructed from metal, a gun of choice, and a prox sensor.
		This code is slightly more documented than normal, as requested by XSI on IRC.
*/

/obj/machinery/porta_turret
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = 1
	density = 0
	use_power = IDLE_POWER_USE				//this turret uses and requires power
	idle_power_usage = 50		//when inactive, this turret takes up constant 50 Equipment power
	active_power_usage = 300	//when active, this turret takes up constant 300 Equipment power
	power_channel = EQUIP	//drains power from the EQUIPMENT channel
	armor = list(melee = 50, bullet = 30, laser = 30, energy = 30, bomb = 30, bio = 0, rad = 0)
	var/raised = 0			//if the turret cover is "open" and the turret is raised
	var/raising= 0			//if the turret is currently opening or closing its cover
	var/health = 80			//the turret's health
	var/locked = 1			//if the turret's behaviour control access is locked
	var/controllock = 0		//if the turret responds to control panels

	var/installation = /obj/item/gun/energy/gun/turret		//the type of weapon installed
	var/gun_charge = 0		//the charge of the gun inserted
	var/projectile = null	//holder for bullettype
	var/eprojectile = null	//holder for the shot when emagged
	var/reqpower = 500		//holder for power needed
	var/iconholder = null	//holder for the icon_state. 1 for orange sprite, null for blue.
	var/egun = null			//holder to handle certain guns switching bullettypes

	var/last_fired = 0		//1: if the turret is cooling down from a shot, 0: turret is ready to fire
	var/shot_delay = 15		//1.5 seconds between each shot

	var/check_arrest = 1	//checks if the perp is set to arrest
	var/check_records = 1	//checks if a security record exists at all
	var/check_weapons = 0	//checks if it can shoot people that have a weapon they aren't authorized to have
	var/check_access = 1	//if this is active, the turret shoots everything that does not meet the access requirements
	var/check_anomalies = 1	//checks if it can shoot at unidentified lifeforms (ie xenos)
	var/check_synth	 = 0 	//if active, will shoot at anything not an AI or cyborg
	var/ailock = 0 			// AI cannot use this

	var/attacked = 0		//if set to 1, the turret gets pissed off and shoots at people nearby (unless they have sec access!)

	var/enabled = 1				//determines if the turret is on
	var/lethal = 0			//whether in lethal or stun mode
	var/disabled = 0

	var/shot_sound 			//what sound should play when the turret fires
	var/eshot_sound			//what sound should play when the emagged turret fires

	var/datum/effect_system/spark_spread/spark_system	//the spark system, used for generating... sparks?

	var/wrenching = 0
	var/last_target //last target fired at, prevents turrets from erratically firing at all valid targets in range

	var/screen = 0 // Screen 0: main control, screen 1: access levels
	var/one_access = 0 // Determines if access control is set to req_one_access or req_access

	var/syndicate = 0		//is the turret a syndicate turret?
	var/faction = ""
	var/emp_vulnerable = 1 // Can be empd
	var/scan_range = 7
	var/always_up = 0		//Will stay active
	var/has_cover = 1		//Hides the cover

/obj/machinery/porta_turret/centcom
	name = "Centcom Turret"
	enabled = 0
	ailock = 1
	check_synth	 = 0
	check_access = 1
	check_arrest = 1
	check_records = 1
	check_weapons = 1
	check_anomalies = 1

/obj/machinery/porta_turret/centcom/pulse
	name = "Pulse Turret"
	health = 200
	enabled = 1
	lethal = 1
	req_access = list(access_cent_commander)
	installation = /obj/item/gun/energy/pulse/turret

/obj/machinery/porta_turret/stationary
	ailock = 1
	lethal = 1
	installation = /obj/item/gun/energy/laser

/obj/machinery/porta_turret/New()
	..()
	if(req_access && req_access.len)
		req_access.Cut()
	req_one_access = list(access_security, access_heads)
	one_access = 1

	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	setup()

/obj/machinery/porta_turret/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/porta_turret/centcom/New()
	..()
	if(req_one_access && req_one_access.len)
		req_one_access.Cut()
	req_access = list(access_cent_specops)
	one_access = 0

/obj/machinery/porta_turret/proc/setup()
	var/obj/item/gun/energy/E = new installation	//All energy-based weapons are applicable
	var/obj/item/ammo_casing/shottype = E.ammo_type[1]

	projectile = shottype.projectile_type
	eprojectile = projectile
	shot_sound = shottype.fire_sound
	eshot_sound = shot_sound

	weapon_setup(installation)

/obj/machinery/porta_turret/proc/weapon_setup(var/guntype)
	switch(guntype)
		if(/obj/item/gun/energy/laser/practice)
			iconholder = 1
			eprojectile = /obj/item/projectile/beam

		if(/obj/item/gun/energy/laser/retro)
			iconholder = 1

		if(/obj/item/gun/energy/laser/captain)
			iconholder = 1

		if(/obj/item/gun/energy/lasercannon)
			iconholder = 1

		if(/obj/item/gun/energy/taser)
			eprojectile = /obj/item/projectile/beam
			eshot_sound = 'sound/weapons/laser.ogg'

		if(/obj/item/gun/energy/gun)
			eprojectile = /obj/item/projectile/beam	//If it has, going to kill mode
			eshot_sound = 'sound/weapons/laser.ogg'
			egun = 1

		if(/obj/item/gun/energy/gun/nuclear)
			eprojectile = /obj/item/projectile/beam	//If it has, going to kill mode
			eshot_sound = 'sound/weapons/laser.ogg'
			egun = 1

		if(/obj/item/gun/energy/gun/turret)
			eprojectile = /obj/item/projectile/beam	//If it has, going to copypaste mode
			eshot_sound = 'sound/weapons/laser.ogg'
			egun = 1

		if(/obj/item/gun/energy/pulse/turret)
			eprojectile = /obj/item/projectile/beam/pulse
			eshot_sound = 'sound/weapons/pulse.ogg'

var/list/turret_icons
/obj/machinery/porta_turret/update_icon()
	if(!turret_icons)
		turret_icons = list()
		turret_icons["open"] = image(icon, "openTurretCover")

	underlays.Cut()
	underlays += turret_icons["open"]

	if(stat & BROKEN)
		icon_state = "destroyed_target_prism"
	else if(raised || raising)
		if(powered() && enabled)
			if(iconholder)
				//lasers have a orange icon
				icon_state = "orange_target_prism"
			else
				//almost everything has a blue icon
				icon_state = "target_prism"
		else
			icon_state = "grey_target_prism"
	else
		icon_state = "turretCover"

/obj/machinery/porta_turret/proc/isLocked(mob/user)
	if(ailock && (isrobot(user) || isAI(user)))
		to_chat(user, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")
		return 1

	if(locked && !(isrobot(user) || isAI(user) || isobserver(user)))
		to_chat(user, "<span class='notice'>Access denied.</span>")
		return 1

	return 0

/obj/machinery/porta_turret/attack_ai(mob/user)
	if(isLocked(user))
		return

	ui_interact(user)

/obj/machinery/porta_turret/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/porta_turret/attack_hand(mob/user)
	if(isLocked(user))
		return

	ui_interact(user)

/obj/machinery/porta_turret/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "turret_control.tmpl", "Turret Controls", 500, 320)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/porta_turret/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["access"] = !isLocked(user)
	data["screen"] = screen
	data["locked"] = locked
	data["enabled"] = enabled
	data["lethal_control"] = !syndicate ? 1 : 0
	data["lethal"] = lethal

	if(data["access"] && !syndicate)
		var/settings[0]
		settings[++settings.len] = list("category" = "Neutralize All Non-Synthetics", "setting" = "check_synth", "value" = check_synth)
		settings[++settings.len] = list("category" = "Check Weapon Authorization", "setting" = "check_weapons", "value" = check_weapons)
		settings[++settings.len] = list("category" = "Check Security Records", "setting" = "check_records", "value" = check_records)
		settings[++settings.len] = list("category" = "Check Arrest Status", "setting" = "check_arrest", "value" = check_arrest)
		settings[++settings.len] = list("category" = "Check Access Authorization", "setting" = "check_access", "value" = check_access)
		settings[++settings.len] = list("category" = "Check Misc. Lifeforms", "setting" = "check_anomalies", "value" = check_anomalies)
		data["settings"] = settings

	if(!syndicate)
		data["one_access"] = one_access
		var/accesses[0]
		var/list/access_list = get_all_accesses()
		for(var/access in access_list)
			var/name = get_access_desc(access)
			var/active
			if(one_access)
				active = (access in req_one_access)
			else
				active = (access in req_access)
			accesses[++accesses.len] = list("name" = name, "active" = active, "number" = access)
		data["accesses"] = accesses
	return data

/obj/machinery/porta_turret/proc/HasController()
	var/area/A = get_area(src)
	return A && A.turret_controls.len > 0

/obj/machinery/porta_turret/CanUseTopic(var/mob/user)
	if(HasController())
		to_chat(user, "<span class='notice'>Turrets can only be controlled using the assigned turret controller.</span>")
		return STATUS_CLOSE

	if(isLocked(user))
		return STATUS_CLOSE

	if(!anchored)
		to_chat(usr, "<span class='notice'>\The [src] has to be secured first!</span>")
		return STATUS_CLOSE

	return ..()

/obj/machinery/porta_turret/Topic(href, href_list, var/nowindow = 0)
	if(..())
		return 1

	if(href_list["command"] && href_list["value"])
		var/value = text2num(href_list["value"])
		if(href_list["command"] == "enable")
			enabled = value
		else if(syndicate)
			return 1
		else if(href_list["command"] == "screen")
			screen = value
		else if(href_list["command"] == "lethal")
			lethal = value
		else if(href_list["command"] == "check_synth")
			check_synth = value
		else if(href_list["command"] == "check_weapons")
			check_weapons = value
		else if(href_list["command"] == "check_records")
			check_records = value
		else if(href_list["command"] == "check_arrest")
			check_arrest = value
		else if(href_list["command"] == "check_access")
			check_access = value
		else if(href_list["command"] == "check_anomalies")
			check_anomalies = value

	if(!syndicate)
		if(href_list["one_access"])
			toggle_one_access(href_list["one_access"])

		if(href_list["access"])
			toggle_access(href_list["access"])

	return 1

/obj/machinery/porta_turret/proc/toggle_one_access(var/access)
	one_access = text2num(access)

	if(one_access == 1)
		req_one_access = req_access.Copy()
		req_access.Cut()
	else if(one_access == 0)
		req_access = req_one_access.Copy()
		req_one_access.Cut()

/obj/machinery/porta_turret/proc/toggle_access(var/access)
	var/required = text2num(access)
	if(!(required in get_all_accesses()))
		return

	if(one_access)
		if((required in req_one_access))
			req_one_access -= required
		else
			req_one_access += required
	else
		if((required in req_access))
			req_access -= required
		else
			req_access += required

/obj/machinery/porta_turret/power_change()
	if(powered() || !use_power)
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			update_icon()


/obj/machinery/porta_turret/attackby(obj/item/I, mob/user)
	if((stat & BROKEN) && !syndicate)
		if(istype(I, /obj/item/crowbar))
			//If the turret is destroyed, you can remove it with a crowbar to
			//try and salvage its components
			to_chat(user, "<span class='notice'>You begin prying the metal coverings off.</span>")
			if(do_after(user, 20 * I.toolspeed, target = src))
				if(prob(70))
					to_chat(user, "<span class='notice'>You remove the turret and salvage some components.</span>")
					if(installation)
						var/obj/item/gun/energy/Gun = new installation(loc)
						Gun.power_supply.charge = gun_charge
						Gun.update_icon()
					if(prob(50))
						new /obj/item/stack/sheet/metal(loc, rand(1,4))
					if(prob(50))
						new /obj/item/assembly/prox_sensor(loc)
				else
					to_chat(user, "<span class='notice'>You remove the turret but did not manage to salvage anything.</span>")
				qdel(src) // qdel

	else if((istype(I, /obj/item/wrench)))
		if(enabled || raised)
			to_chat(user, "<span class='warning'>You cannot unsecure an active turret!</span>")
			return
		if(wrenching)
			to_chat(user, "<span class='warning'>Someone is already [anchored ? "un" : ""]securing the turret!</span>")
			return
		if(!anchored && isinspace())
			to_chat(user, "<span class='warning'>Cannot secure turrets in space!</span>")
			return

		user.visible_message( \
				"<span class='warning'>[user] begins [anchored ? "un" : ""]securing the turret.</span>", \
				"<span class='notice'>You begin [anchored ? "un" : ""]securing the turret.</span>" \
			)

		wrenching = 1
		if(do_after(user, 50 * I.toolspeed, target = src))
			//This code handles moving the turret around. After all, it's a portable turret!
			if(!anchored)
				playsound(loc, I.usesound, 100, 1)
				anchored = 1
				update_icon()
				to_chat(user, "<span class='notice'>You secure the exterior bolts on the turret.</span>")
			else if(anchored)
				playsound(loc, I.usesound, 100, 1)
				anchored = 0
				to_chat(user, "<span class='notice'>You unsecure the exterior bolts on the turret.</span>")
				update_icon()
		wrenching = 0

	else if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))
		if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>Access denied.</span>")

	else
		//if the turret was attacked with the intention of harming it:
		user.changeNext_move(CLICK_CD_MELEE)
		take_damage(I.force * 0.5)
		playsound(src.loc, 'sound/weapons/smash.ogg', 60, 1)
		if(I.force * 0.5 > 1) //if the force of impact dealt at least 1 damage, the turret gets pissed off
			if(!attacked && !emagged)
				attacked = 1
				spawn(60)
					attacked = 0

		..()

/obj/machinery/porta_turret/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0 || (M.melee_damage_type != BRUTE && M.melee_damage_type != BURN))
		return
	if(!(stat & BROKEN))
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>")
		take_damage(M.melee_damage_upper)
	else
		to_chat(M, "<span class='danger'>That object is useless to you.</span>")
	return

/obj/machinery/porta_turret/attack_alien(mob/living/carbon/alien/humanoid/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(!(stat & BROKEN))
		playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1, -1)
		visible_message("<span class='danger'>[M] has slashed at [src]!</span>")
		take_damage(15)
	else
		to_chat(M, "<span class='noticealien'>That object is useless to you.</span>")
	return

/obj/machinery/porta_turret/emag_act(user as mob)
	if(!emagged)
		//Emagging the turret makes it go bonkers and stun everyone. It also makes
		//the turret shoot much, much faster.
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s threat assessment circuits.</span>")
			visible_message("[src] hums oddly...")
		emagged = 1
		iconholder = 1
		controllock = 1
		enabled = 0 //turns off the turret temporarily
		sleep(60) //6 seconds for the traitor to gtfo of the area before the turret decides to ruin his shit
		enabled = 1 //turns it back on. The cover popUp() popDown() are automatically called in process(), no need to define it here

/obj/machinery/porta_turret/take_damage(force)
	if(!raised && !raising)
		force = force / 8
		if(force < 5)
			return

	health -= force
	if(force > 5 && prob(45) && spark_system)
		spark_system.start()
	if(health <= 0)
		die()	//the death process :(

/obj/machinery/porta_turret/bullet_act(obj/item/projectile/Proj)
	if(Proj.damage_type == STAMINA)
		return

	if(enabled)
		if(!attacked && !emagged)
			attacked = 1
			spawn(60)
				attacked = 0

	..()

	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		take_damage(Proj.damage)

/obj/machinery/porta_turret/emp_act(severity)
	if(enabled && emp_vulnerable)
		//if the turret is on, the EMP no matter how severe disables the turret for a while
		//and scrambles its settings, with a slight chance of having an emag effect
		check_arrest = prob(50)
		check_records = prob(50)
		check_weapons = prob(50)
		check_access = prob(20)	// check_access is a pretty big deal, so it's least likely to get turned on
		check_anomalies = prob(50)
		if(prob(5))
			emagged = 1

		enabled=0
		spawn(rand(60,600))
			if(!enabled)
				enabled=1

	..()

/obj/machinery/porta_turret/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(25))
				qdel(src)
			else
				take_damage(initial(health) * 8) //should instakill most turrets
		if(3)
			take_damage(initial(health) * 8 / 3)

/obj/machinery/porta_turret/proc/die()	//called when the turret dies, ie, health <= 0
	health = 0
	stat |= BROKEN	//enables the BROKEN bit
	if(spark_system)
		spark_system.start()	//creates some sparks because they look cool
	update_icon()

/obj/machinery/porta_turret/process()
	//the main machinery process

	set background = BACKGROUND_ENABLED

	if(stat & (NOPOWER|BROKEN))
		if(!always_up)
			//if the turret has no power or is broken, make the turret pop down if it hasn't already
			popDown()
		return

	if(!enabled)
		if(!always_up)
			//if the turret is off, make it pop down
			popDown()
		return

	var/list/targets = list()			//list of primary targets
	var/list/secondarytargets = list()	//targets that are least important
	var/static/things_to_scan = typecacheof(list(/obj/mecha, /obj/spacepod, /obj/vehicle, /mob/living))

	for(var/A in typecache_filter_list(view(scan_range, src), things_to_scan))
		var/atom/AA = A

		if(AA.invisibility > SEE_INVISIBLE_LIVING) //Let's not do typechecks and stuff on invisible things
			continue

		if(istype(A, /obj/mecha))
			var/obj/mecha/ME = A
			assess_and_assign(ME.occupant, targets, secondarytargets)

		if(istype(A, /obj/spacepod))
			var/obj/spacepod/SP = A
			assess_and_assign(SP.pilot, targets, secondarytargets)

		if(istype(A, /obj/vehicle))
			var/obj/vehicle/T = A
			assess_and_assign(T.buckled_mob, targets, secondarytargets)

		if(isliving(A))
			var/mob/living/C = A
			assess_and_assign(C, targets, secondarytargets)

	if(!tryToShootAt(targets))
		if(!tryToShootAt(secondarytargets)) // if no valid targets, go for secondary targets
			if(!always_up)
				popDown() // no valid targets, close the cover

/obj/machinery/porta_turret/proc/in_faction(mob/living/target)
	if(!(faction in target.faction))
		return 0
	return 1

/obj/machinery/porta_turret/proc/assess_and_assign(mob/living/L, list/targets, list/secondarytargets)
	switch(assess_living(L))
		if(TURRET_PRIORITY_TARGET)
			targets += L
		if(TURRET_SECONDARY_TARGET)
			secondarytargets += L

/obj/machinery/porta_turret/proc/assess_living(mob/living/L)
	if(!L)
		return TURRET_NOT_TARGET

	if(get_turf(L) == get_turf(src))
		return TURRET_NOT_TARGET

	if(!emagged && !syndicate && (issilicon(L) || isbot(L)))	// Don't target silica
		return TURRET_NOT_TARGET

	if(L.stat && !emagged)		//if the perp is dead/dying, no need to bother really
		return TURRET_NOT_TARGET	//move onto next potential victim!

	if(get_dist(src, L) > scan_range)	//if it's too far away, why bother?
		return TURRET_NOT_TARGET

	if(emagged)		// If emagged not even the dead get a rest
		return L.stat ? TURRET_SECONDARY_TARGET : TURRET_PRIORITY_TARGET

	if(in_faction(L))
		return TURRET_NOT_TARGET

	if(lethal && locate(/mob/living/silicon/ai) in get_turf(L))		//don't accidentally kill the AI!
		return TURRET_NOT_TARGET

	if(check_synth)	//If it's set to attack all non-silicons, target them!
		if(L.lying)
			return lethal ? TURRET_SECONDARY_TARGET : TURRET_NOT_TARGET
		return TURRET_PRIORITY_TARGET

	if(iscuffed(L)) // If the target is handcuffed, leave it alone
		return TURRET_NOT_TARGET

	if(isanimal(L) || issmall(L)) // Animals are not so dangerous
		return check_anomalies ? TURRET_SECONDARY_TARGET : TURRET_NOT_TARGET

	if(isalien(L)) // Xenos are dangerous
		return check_anomalies ? TURRET_PRIORITY_TARGET	: TURRET_NOT_TARGET

	if(ishuman(L))	//if the target is a human, analyze threat level
		if(assess_perp(L, check_access, check_weapons, check_records, check_arrest) < 4)
			return TURRET_NOT_TARGET	//if threat level < 4, keep going

	if(L.lying)		//if the perp is lying down, it's still a target but a less-important target
		return lethal ? TURRET_SECONDARY_TARGET : TURRET_NOT_TARGET

	return TURRET_PRIORITY_TARGET	//if the perp has passed all previous tests, congrats, it is now a "shoot-me!" nominee

/obj/machinery/porta_turret/proc/tryToShootAt(var/list/mob/living/targets)
	if(targets.len && last_target && (last_target in targets) && target(last_target))
		return 1

	while(targets.len > 0)
		var/mob/living/M = pick(targets)
		targets -= M
		if(target(M))
			return 1

/obj/machinery/porta_turret/proc/popUp()	//pops the turret up
	if(disabled)
		return
	if(raising || raised)
		return
	if(stat & BROKEN)
		return
	set_raised_raising(raised, 1)
	playsound(get_turf(src), 'sound/effects/turret/open.wav', 60, 1)
	update_icon()

	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	flick_holder.layer = layer + 0.1
	flick("popup", flick_holder)
	sleep(10)
	qdel(flick_holder)

	set_raised_raising(1, 0)
	update_icon()

/obj/machinery/porta_turret/proc/popDown()	//pops the turret down
	last_target = null
	if(disabled)
		return
	if(raising || !raised)
		return
	if(stat & BROKEN)
		return
	set_raised_raising(raised, 1)
	playsound(get_turf(src), 'sound/effects/turret/open.wav', 60, 1)
	update_icon()

	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	flick_holder.layer = layer + 0.1
	flick("popdown", flick_holder)
	sleep(10)
	qdel(flick_holder)

	set_raised_raising(0, 0)
	update_icon()

/obj/machinery/porta_turret/on_assess_perp(mob/living/carbon/human/perp)
	if((check_access || attacked) && !allowed(perp))
		//if the turret has been attacked or is angry, target all non-authorized personnel, see req_access
		return 10

	return ..()

/obj/machinery/porta_turret/proc/set_raised_raising(var/is_raised, var/is_raising)
	raised = is_raised
	raising = is_raising
	density = is_raised || is_raising

/obj/machinery/porta_turret/proc/target(mob/living/target)
	if(disabled)
		return
	if(target)
		last_target = target
		if(has_cover)
			popUp()				//pop the turret up if it's not already up.
		setDir(get_dir(src, target))	//even if you can't shoot, follow the target
		shootAt(target)
		return TRUE

/obj/machinery/porta_turret/proc/shootAt(mob/living/target)
	if(!raised && has_cover) //the turret has to be raised in order to fire - makes sense, right?
		return

	if(!emagged)	//if it hasn't been emagged, cooldown before shooting again
		if((last_fired + shot_delay > world.time) || !raised)
			return
		last_fired = world.time

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return

	update_icon()
	var/obj/item/projectile/A
	if(emagged || lethal)
		if(eprojectile)
			A = new eprojectile(loc)
			playsound(loc, eshot_sound, 75, 1)
	else
		if(projectile)
			A = new projectile(loc)
			playsound(loc, shot_sound, 75, 1)

	// Lethal/emagged turrets use twice the power due to higher energy beams
	// Emagged turrets again use twice as much power due to higher firing rates
	use_power(reqpower * (2 * (emagged || lethal)) * (2 * emagged))

	if(istype(A))
		A.original = target
		A.current = T
		A.yo = U.y - T.y
		A.xo = U.x - T.x
		A.fire()
	else
		A.throw_at(target, scan_range, 1)
	return A

/datum/turret_checks
	var/enabled
	var/lethal
	var/check_synth
	var/check_access
	var/check_records
	var/check_arrest
	var/check_weapons
	var/check_anomalies
	var/ailock

/obj/machinery/porta_turret/proc/setState(var/datum/turret_checks/TC)
	if(controllock)
		return
	enabled = TC.enabled
	lethal = TC.lethal
	iconholder = TC.lethal

	check_synth = TC.check_synth
	check_access = TC.check_access
	check_records = TC.check_records
	check_arrest = TC.check_arrest
	check_weapons = TC.check_weapons
	check_anomalies = TC.check_anomalies
	ailock = TC.ailock

	power_change()

/*
		Portable turret constructions
		Known as "turret frame"s
*/

/obj/machinery/porta_turret_construct
	name = "turret frame"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turret_frame"
	density=1
	var/target_type = /obj/machinery/porta_turret	// The type we intend to build
	var/build_step = 0			//the current step in the building process
	var/finish_name="turret"	//the name applied to the product turret
	var/installation = null		//the gun type installed
	var/gun_charge = 0			//the gun charge of the gun type installed


/obj/machinery/porta_turret_construct/attackby(obj/item/I, mob/user)
	//this is a bit unwieldy but self-explanatory
	switch(build_step)
		if(0)	//first step
			if(istype(I, /obj/item/wrench) && !anchored)
				playsound(loc, I.usesound, 100, 1)
				to_chat(user, "<span class='notice'>You secure the external bolts.</span>")
				anchored = 1
				build_step = 1
				return

			else if(istype(I, /obj/item/crowbar) && !anchored)
				playsound(loc, I.usesound, 75, 1)
				to_chat(user, "<span class='notice'>You dismantle the turret construction.</span>")
				new /obj/item/stack/sheet/metal( loc, 5)
				qdel(src) // qdel
				return

		if(1)
			if(istype(I, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/M = I
				if(M.use(2))
					to_chat(user, "<span class='notice'>You add some metal armor to the interior frame.</span>")
					build_step = 2
					icon_state = "turret_frame2"
				else
					to_chat(user, "<span class='warning'>You need two sheets of metal to continue construction.</span>")
				return

			else if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 75, 1)
				to_chat(user, "<span class='notice'>You unfasten the external bolts.</span>")
				anchored = 0
				build_step = 0
				return


		if(2)
			if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 100, 1)
				to_chat(user, "<span class='notice'>You bolt the metal armor into place.</span>")
				build_step = 3
				return

			else if(istype(I, /obj/item/weldingtool))
				var/obj/item/weldingtool/WT = I
				if(!WT.isOn())
					return
				if(WT.get_fuel() < 5) //uses up 5 fuel.
					to_chat(user, "<span class='notice'>You need more fuel to complete this task.</span>")
					return

				playsound(loc, WT.usesound, 50, 1)
				if(do_after(user, 20 * WT.toolspeed, target = src))
					if(!src || !WT.remove_fuel(5, user)) return
					build_step = 1
					to_chat(user, "You remove the turret's interior metal armor.")
					new /obj/item/stack/sheet/metal( loc, 2)
					return


		if(3)
			if(istype(I, /obj/item/gun/energy)) //the gun installation part

				if(isrobot(user))
					return
				var/obj/item/gun/energy/E = I //typecasts the item to an energy gun
				if(!user.unEquip(I))
					to_chat(user, "<span class='notice'>\the [I] is stuck to your hand, you cannot put it in \the [src]</span>")
					return
				installation = I.type //installation becomes I.type
				gun_charge = E.power_supply.charge //the gun's charge is stored in gun_charge
				to_chat(user, "<span class='notice'>You add [I] to the turret.</span>")

				if(istype(installation, /obj/item/gun/energy/laser/tag/blue) || istype(installation, /obj/item/gun/energy/laser/tag/red))
					target_type = /obj/machinery/porta_turret/tag
				else
					target_type = /obj/machinery/porta_turret

				build_step = 4
				qdel(I) //delete the gun :( qdel
				return

			else if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 100, 1)
				to_chat(user, "<span class='notice'>You remove the turret's metal armor bolts.</span>")
				build_step = 2
				return

		if(4)
			if(isprox(I))
				if(!user.unEquip(I))
					to_chat(user, "<span class='notice'>\the [I] is stuck to your hand, you cannot put it in \the [src]</span>")
					return
				build_step = 5
				qdel(I) // qdel
				to_chat(user, "<span class='notice'>You add the prox sensor to the turret.</span>")
				return

			//attack_hand() removes the gun

		if(5)
			if(istype(I, /obj/item/screwdriver))
				playsound(loc, I.usesound, 100, 1)
				build_step = 6
				to_chat(user, "<span class='notice'>You close the internal access hatch.</span>")
				return

			//attack_hand() removes the prox sensor

		if(6)
			if(istype(I, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/M = I
				if(M.use(2))
					to_chat(user, "<span class='notice'>You add some metal armor to the exterior frame.</span>")
					build_step = 7
				else
					to_chat(user, "<span class='warning'>You need two sheets of metal to continue construction.</span>")
				return

			else if(istype(I, /obj/item/screwdriver))
				playsound(loc, I.usesound, 100, 1)
				build_step = 5
				to_chat(user, "<span class='notice'>You open the internal access hatch.</span>")
				return

		if(7)
			if(istype(I, /obj/item/weldingtool))
				var/obj/item/weldingtool/WT = I
				if(!WT.isOn()) return
				if(WT.get_fuel() < 5)
					to_chat(user, "<span class='notice'>You need more fuel to complete this task.</span>")

				playsound(loc, WT.usesound, 50, 1)
				if(do_after(user, 30 * WT.toolspeed, target = src))
					if(!src || !WT.remove_fuel(5, user))
						return
					build_step = 8
					to_chat(user, "<span class='notice'>You weld the turret's armor down.</span>")

					//The final step: create a full turret
					var/obj/machinery/porta_turret/Turret = new target_type(loc)
					Turret.name = finish_name
					Turret.installation = installation
					Turret.gun_charge = gun_charge
					Turret.enabled = 0
					Turret.setup()

					qdel(src) // qdel

			else if(istype(I, /obj/item/crowbar))
				playsound(loc, I.usesound, 75, 1)
				to_chat(user, "<span class='notice'>You pry off the turret's exterior armor.</span>")
				new /obj/item/stack/sheet/metal(loc, 2)
				build_step = 6
				return

	if(istype(I, /obj/item/pen))	//you can rename turrets like bots!
		var/t = input(user, "Enter new turret name", name, finish_name) as text
		t = sanitize(copytext(t, 1, MAX_MESSAGE_LEN))
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return

		finish_name = t
		return
	..()


/obj/machinery/porta_turret_construct/attack_hand(mob/user)
	switch(build_step)
		if(4)
			if(!installation)
				return
			build_step = 3

			var/obj/item/gun/energy/Gun = new installation(loc)
			Gun.power_supply.charge = gun_charge
			Gun.update_icon()
			installation = null
			gun_charge = 0
			to_chat(user, "<span class='notice'>You remove [Gun] from the turret frame.</span>")

		if(5)
			to_chat(user, "<span class='notice'>You remove the prox sensor from the turret frame.</span>")
			new /obj/item/assembly/prox_sensor(loc)
			build_step = 4

/obj/machinery/porta_turret_construct/attack_ai()
	return

/atom/movable/porta_turret_cover
	icon = 'icons/obj/turrets.dmi'

// Syndicate turrets
/obj/machinery/porta_turret/syndicate
	projectile = /obj/item/projectile/bullet
	eprojectile = /obj/item/projectile/bullet
	// Syndicate turrets *always* operate in lethal mode.
	// So, nothing, not even emagging them, makes them switch bullet type.
	// So, its best to always have their projectile and eprojectile settings be the same. That way, you know what they will shoot.
	// Otherwise, you end up with situations where one of the two bullet types will never be used.
	shot_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	eshot_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'

	icon_state = "syndieturret0"
	var/icon_state_initial = "syndieturret0"
	var/icon_state_active = "syndieturret1"
	var/icon_state_destroyed = "syndieturret2"

	syndicate = 1
	installation = null
	always_up = 1
	use_power = NO_POWER_USE
	has_cover = 0
	raised = 1
	scan_range = 9

	faction = "syndicate"
	emp_vulnerable = 0

	lethal = 1
	check_arrest = 0
	check_records = 0
	check_weapons = 0
	check_access = 0
	check_anomalies = 1
	check_synth	= 1
	ailock = 1
	var/area/syndicate_depot/core/depotarea

/obj/machinery/porta_turret/syndicate/die()
	. = ..()
	if(istype(depotarea))
		depotarea.turret_died()

/obj/machinery/porta_turret/syndicate/shootAt(mob/living/target)
	if(istype(depotarea))
		depotarea.list_add(target, depotarea.hostile_list)
		depotarea.declare_started()
	return ..(target)

/obj/machinery/porta_turret/syndicate/New()
	..()
	if(req_one_access && req_one_access.len)
		req_one_access.Cut()
	req_access = list(access_syndicate)
	one_access = 0

/obj/machinery/porta_turret/syndicate/update_icon()
	if(stat & BROKEN)
		icon_state = icon_state_destroyed
	else if(enabled)
		icon_state = icon_state_active
	else
		icon_state = icon_state_initial

/obj/machinery/porta_turret/syndicate/setup()
	return

/obj/machinery/porta_turret/syndicate/assess_perp(mob/living/carbon/human/perp)
	return 10 //Syndicate turrets shoot everything not in their faction

/obj/machinery/porta_turret/syndicate/pod
	health = 40
	projectile = /obj/item/projectile/bullet/weakbullet3
	eprojectile = /obj/item/projectile/bullet/weakbullet3

/obj/machinery/porta_turret/syndicate/interior
	name = "machine gun turret (.45)"
	desc = "Syndicate interior defense turret chambered for .45 rounds. Designed to down intruders without damaging the hull."
	projectile = /obj/item/projectile/bullet/midbullet
	eprojectile = /obj/item/projectile/bullet/midbullet

/obj/machinery/porta_turret/syndicate/exterior
	name = "machine gun turret (7.62)"
	desc = "Syndicate exterior defense turret chambered for 7.62 rounds. Designed to down intruders with heavy calliber bullets."
	projectile = /obj/item/projectile/bullet
	eprojectile = /obj/item/projectile/bullet

/obj/machinery/porta_turret/syndicate/grenade
	name = "mounted grenade launcher (40mm)"
	desc = "Syndicate 40mm grenade launcher defense turret. If you've had this much time to look at it, you're probably already dead."
	projectile = /obj/item/projectile/bullet/a40mm
	eprojectile = /obj/item/projectile/bullet/a40mm

/obj/machinery/porta_turret/syndicate/assault_pod
	name = "machine gun turret (4.6x30mm)"
	desc = "Syndicate exterior defense turret chambered for 4.6x30mm rounds. Designed to be fitted to assault pods, it uses low calliber bullets to save space."
	health = 100
	projectile = /obj/item/projectile/bullet/weakbullet3
	eprojectile = /obj/item/projectile/bullet/weakbullet3
