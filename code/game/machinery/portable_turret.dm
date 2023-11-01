/*		Portable Turrets:
		Constructed from metal, a gun of choice, and a prox sensor.
		This code is slightly more documented than normal, as requested by XSI on IRC.
*/

/obj/machinery/porta_turret
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = TRUE
	density = FALSE
	idle_power_consumption = 50		//when inactive, this turret takes up constant 50 Equipment power
	active_power_consumption = 300	//when active, this turret takes up constant 300 Equipment power
	power_channel = PW_CHANNEL_EQUIPMENT	//drains power from the EQUIPMENT channel
	armor = list(melee = 50, bullet = 30, laser = 30, energy = 30, bomb = 30, rad = 0, fire = 90, acid = 90)
	var/raised = FALSE			//if the turret cover is "open" and the turret is raised
	var/raising= FALSE			//if the turret is currently opening or closing its cover
	var/health = 80			//the turret's health
	var/locked = TRUE			//if the turret's behaviour control access is locked
	var/controllock = FALSE		//if the turret responds to control panels. TRUE = does NOT respond

	var/installation = /obj/item/gun/energy/gun/turret		//the type of weapon installed
	var/gun_charge = 0		//the charge of the gun inserted
	var/projectile = null	//holder for bullettype
	var/eprojectile = null	//holder for the shot when emagged
	var/reqpower = 500		//holder for power needed
	var/iconholder = null	//holder for the icon_state. 1 for orange sprite, null for blue.
	var/egun = null			//holder to handle certain guns switching bullettypes

	var/last_fired = 0		//1: if the turret is cooling down from a shot, 0: turret is ready to fire
	var/shot_delay = 15		//1.5 seconds between each shot

	var/targetting_is_configurable = TRUE // if false, you cannot change who this turret attacks via its UI
	var/check_arrest = TRUE	//checks if the perp is set to arrest
	var/check_records = TRUE	//checks if a security record exists at all
	var/check_weapons = FALSE	//checks if it can shoot people that have a weapon they aren't authorized to have
	var/check_access = TRUE	//if this is active, the turret shoots everything that does not meet the access requirements
	var/check_anomalies = TRUE	//checks if it can shoot at unidentified lifeforms (ie xenos)
	var/check_synth	 = FALSE 	//if active, will shoot at anything not an AI or cyborg
	var/check_borgs = FALSE //if TRUE, target all cyborgs.
	var/ailock = FALSE 			// if TRUE, AI cannot use this

	var/attacked = FALSE		//if set to 1, the turret gets pissed off and shoots at people nearby (unless they have sec access!)

	var/enabled = TRUE				//determines if the turret is on
	var/lethal = FALSE			//whether in lethal or stun mode
	var/lethal_is_configurable = TRUE // if false, its lethal setting cannot be changed
	var/disabled = FALSE

	var/shot_sound 			//what sound should play when the turret fires
	var/eshot_sound			//what sound should play when the emagged turret fires

	var/datum/effect_system/spark_spread/spark_system	//the spark system, used for generating... sparks?

	var/wrenching = FALSE
	var/last_target //last target fired at, prevents turrets from erratically firing at all valid targets in range

	var/one_access = FALSE // Determines if access control is set to req_one_access or req_access
	var/region_min = REGION_GENERAL
	var/region_max = REGION_COMMAND

	var/syndicate = FALSE		//is the turret a syndicate turret?
	var/faction = ""
	var/emp_vulnerable = TRUE // Can be empd
	var/scan_range = 7
	var/always_up = FALSE		//Will stay active
	var/has_cover = TRUE		//Hides the cover
	/// Deployment override to allow turret popup on/under dense turfs/objects, for admin/CC turrets
	var/deployment_override = FALSE
	/// What lethal mode projectile with the turret start with?
	var/initial_eprojectile = null
	/// What non-lethal mode projectile with the turret start with?
	var/initial_projectile = null


/obj/machinery/porta_turret/Initialize(mapload)
	. = ..()
	if(req_access && req_access.len)
		req_access.Cut()
	req_one_access = list(ACCESS_SECURITY, ACCESS_HEADS)
	one_access = TRUE

	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	setup()

/obj/machinery/porta_turret/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/porta_turret/centcom/Initialize(mapload)
	. = ..()
	if(req_one_access && req_one_access.len)
		req_one_access.Cut()
	req_access = list(ACCESS_CENT_SPECOPS)
	one_access = FALSE

/obj/machinery/porta_turret/proc/setup()
	var/obj/item/gun/energy/E = new installation	//All energy-based weapons are applicable
	var/obj/item/ammo_casing/shottype = E.ammo_type[1]

	projectile = shottype.projectile_type
	eprojectile = projectile
	shot_sound = shottype.fire_sound
	eshot_sound = shot_sound

	weapon_setup(installation)

/obj/machinery/porta_turret/proc/weapon_setup(guntype)
	switch(guntype)
		if(/obj/item/gun/energy/laser/practice)
			lethal_is_configurable = FALSE
			iconholder = 1
			eprojectile = /obj/item/projectile/beam

		if(/obj/item/gun/energy/laser/retro)
			iconholder = 1

		if(/obj/item/gun/energy/laser/captain)
			iconholder = 1

		if(/obj/item/gun/energy/lasercannon)
			iconholder = 1

		if(/obj/item/gun/energy/taser)
			lethal_is_configurable = FALSE
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
			eprojectile = /obj/item/projectile/beam/pulse/hitscan
			eshot_sound = 'sound/weapons/pulse.ogg'
	if(initial_eprojectile)
		eprojectile = initial_eprojectile
	if(initial_projectile)
		projectile = initial_projectile

GLOBAL_LIST_EMPTY(turret_icons)
/obj/machinery/porta_turret/update_icon_state()
	if(!GLOB.turret_icons)
		GLOB.turret_icons = list()
		GLOB.turret_icons["open"] = image(icon, "openTurretCover")

	underlays.Cut()
	underlays += GLOB.turret_icons["open"]

	if(stat & BROKEN)
		icon_state = "destroyed_target_prism"
	else if(raised || raising)
		if(has_power() && enabled)
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

/obj/machinery/porta_turret/proc/HasController()
	var/area/A = get_area(src)
	return A && A.turret_controls.len > 0

/obj/machinery/porta_turret/proc/access_is_configurable()
	return targetting_is_configurable && !HasController()

/obj/machinery/porta_turret/proc/isLocked(mob/user)
	if(HasController())
		return TRUE
	if(isrobot(user) || isAI(user))
		if(ailock)
			to_chat(user, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")
			return TRUE
		else
			return FALSE
	if(isobserver(user))
		if(user.can_admin_interact())
			return FALSE
		else
			return TRUE
	if(locked)
		return TRUE
	return FALSE

/obj/machinery/porta_turret/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/porta_turret/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/porta_turret/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/porta_turret/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(HasController())
		to_chat(user, "<span class='notice'>[src] can only be controlled using the assigned turret controller.</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='notice'>[src] has to be secured first!</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PortableTurret", name, 500, access_is_configurable() ? 800 : 400)
		ui.open()

/obj/machinery/porta_turret/ui_data(mob/user)
	var/list/data = list(
		"locked" = isLocked(user), // does the current user have access?
		"on" = enabled,
		"targetting_is_configurable" = targetting_is_configurable, // If false, targetting settings don't show up
		"lethal" = lethal,
		"lethal_is_configurable" = lethal_is_configurable,
		"check_weapons" = check_weapons,
		"neutralize_noaccess" = check_access,
		"one_access" = one_access,
		"selectedAccess" = one_access ? req_one_access : req_access,
		"access_is_configurable" = access_is_configurable(),
		"neutralize_norecord" = check_records,
		"neutralize_criminals" = check_arrest,
		"neutralize_all" = check_synth,
		"neutralize_unidentified" = check_anomalies,
		"neutralize_cyborgs" = check_borgs
	)
	return data

/obj/machinery/porta_turret/ui_static_data(mob/user)
	var/list/data = list()
	data["regions"] = get_accesslist_static_data(region_min, region_max)
	return data

/obj/machinery/porta_turret/ui_act(action, params)
	if(..())
		return
	if(isLocked(usr))
		return
	. = TRUE
	switch(action)
		if("power")
			enabled = !enabled
		if("lethal")
			if(lethal_is_configurable)
				lethal = !lethal
	if(targetting_is_configurable)
		switch(action)
			if("authweapon")
				check_weapons = !check_weapons
			if("authaccess")
				check_access = !check_access
			if("authnorecord")
				check_records = !check_records
			if("autharrest")
				check_arrest = !check_arrest
			if("authxeno")
				check_anomalies = !check_anomalies
			if("authsynth")
				check_synth = !check_synth
			if("authborgs")
				check_borgs = !check_borgs
			if("set")
				var/access = text2num(params["access"])
				if(one_access)
					if(!(access in req_one_access))
						req_one_access += access
					else
						req_one_access -= access
				else
					if(!(access in req_access))
						req_access += access
					else
						req_access -= access
	if(access_is_configurable())
		switch(action)
			if("grant_region")
				var/region = text2num(params["region"])
				if(isnull(region))
					return
				if(one_access)
					req_one_access |= get_region_accesses(region)
				else
					req_access |= get_region_accesses(region)
			if("deny_region")
				var/region = text2num(params["region"])
				if(isnull(region))
					return
				if(one_access)
					req_one_access -= get_region_accesses(region)
				else
					req_access -= get_region_accesses(region)
			if("clear_all")
				if(one_access)
					req_one_access = list()
				else
					req_access = list()
			if("grant_all")
				if(one_access)
					req_one_access = get_all_accesses()
				else
					req_access = get_all_accesses()
			if("one_access")
				if(one_access)
					req_one_access = list()
				else
					req_access = list()
				one_access = !one_access

/obj/machinery/porta_turret/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)


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
						Gun.cell.charge = gun_charge
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

		wrenching = TRUE
		if(do_after(user, 50 * I.toolspeed, target = src))
			//This code handles moving the turret around. After all, it's a portable turret!
			playsound(loc, I.usesound, 100, 1)
			anchored = !anchored
			update_icon(UPDATE_ICON_STATE)
			to_chat(user, "<span class='notice'>You [anchored ? "" : "un"]secure the exterior bolts on the turret.</span>")
		wrenching = FALSE

	else if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))
		if(HasController())
			to_chat(user, "<span class='notice'>Turrets regulated by a nearby turret controller are not unlockable.</span>")
		else if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>Access denied.</span>")

	else
		//if the turret was attacked with the intention of harming it:
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, 'sound/weapons/smash.ogg', 60, 1)
		if(I.force * 0.5 > 1) //if the force of impact dealt at least 1 damage, the turret gets pissed off
			if(!attacked && !emagged)
				attacked = TRUE
				spawn(60)
					attacked = FALSE

		..()

/obj/machinery/porta_turret/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0 || (M.melee_damage_type != BRUTE && M.melee_damage_type != BURN))
		return
	if(!(stat & BROKEN))
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>")
		..()
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
		emagged = TRUE
		iconholder = 1
		controllock = TRUE
		enabled = FALSE //turns off the turret temporarily
		sleep(60) //6 seconds for the traitor to gtfo of the area before the turret decides to ruin his shit
		enabled = TRUE //turns it back on. The cover pop_up() pop_down() are automatically called in process(), no need to define it here


/obj/machinery/porta_turret/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration_flat = 0, armour_penetration_percentage = 0)
	damage_amount = run_obj_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration_flat, armour_penetration_percentage)
	if(stat & BROKEN)
		return
	if(!raised && !raising)
		damage_amount = damage_amount / 8
		if(damage_amount < 5)
			return

	health -= damage_amount
	if(damage_amount > 5 && prob(45) && spark_system && damage_flag != FIRE)
		spark_system.start()
	if(health <= 0)
		die()	//the death process :(

/obj/machinery/porta_turret/bullet_act(obj/item/projectile/Proj)
	if(Proj.damage_type == STAMINA)
		return

	if(enabled)
		if(!attacked && !emagged)
			attacked = TRUE
			spawn(60)
				attacked = FALSE

	return ..()

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
			emagged = TRUE

		enabled=0
		spawn(rand(60, 600))
			if(!enabled)
				enabled = TRUE

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
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/porta_turret/process()
	//the main machinery process

	if(stat & (NOPOWER|BROKEN))
		if(!always_up)
			//if the turret has no power or is broken, make the turret pop down if it hasn't already
			pop_down()
		return

	if(!enabled)
		if(!always_up)
			//if the turret is off, make it pop down
			pop_down()
		return

	var/list/targets = list()			//list of primary targets
	var/list/secondarytargets = list()	//targets that are least important
	var/static/things_to_scan = typecacheof(list(/obj/mecha, /obj/vehicle, /mob/living, /obj/structure/blob))

	for(var/A in typecache_filter_list(view(scan_range, src), things_to_scan))
		var/atom/AA = A

		if(AA.invisibility > SEE_INVISIBLE_LIVING) //Let's not do typechecks and stuff on invisible things
			continue

		if(ismecha(A))
			var/obj/mecha/ME = A
			assess_and_assign(ME.occupant, targets, secondarytargets)

		else if(istype(A, /obj/vehicle))
			var/obj/vehicle/T = A
			if(T.has_buckled_mobs())
				for(var/m in T.buckled_mobs)
					var/mob/living/buckled_mob = m
					assess_and_assign(buckled_mob, targets, secondarytargets)

		else
			// Handles living and obj cases
			assess_and_assign(A, targets, secondarytargets)

	if(!tryToShootAt(targets))
		if(!tryToShootAt(secondarytargets)) // if no valid targets, go for secondary targets
			if(!always_up)
				pop_down() // no valid targets, close the cover

/obj/machinery/porta_turret/proc/in_faction(mob/living/target)
	if(!(faction in target.faction))
		return 0
	return 1

/obj/machinery/porta_turret/proc/assess_and_assign(atom/movable/AM, list/targets, list/secondarytargets)
	var/target_priority
	if(isliving(AM))
		target_priority = assess_living(AM)
	else if(isobj(AM))
		target_priority = assess_obj(AM)
	else
		CRASH("A non-living and non-obj atom (name:[AM], type:[AM.type]) was considered for turret assessment.")
	switch(target_priority)
		if(TURRET_PRIORITY_TARGET)
			targets += AM
		if(TURRET_SECONDARY_TARGET)
			secondarytargets += AM

/obj/machinery/porta_turret/proc/pre_assess_checks(atom/movable/AM)
	if(!AM)
		return TURRET_PREASSESS_INVALID

	if(get_turf(AM) == get_turf(src))
		return TURRET_PREASSESS_INVALID

	if(get_dist(src, AM) > scan_range)	//if it's too far away, why bother?
		return TURRET_PREASSESS_INVALID

	if(lethal && locate(/mob/living/silicon/ai) in get_turf(AM))		//don't accidentally kill the AI!
		return TURRET_PREASSESS_INVALID

	return TURRET_PREASSESS_VALID

/obj/machinery/porta_turret/proc/assess_living(mob/living/L)
	if(pre_assess_checks(L) == TURRET_PREASSESS_INVALID)
		return TURRET_NOT_TARGET

	if(!emagged && !syndicate && (issilicon(L) || isbot(L)))
		return (check_borgs && isrobot(L)) ? TURRET_PRIORITY_TARGET : TURRET_NOT_TARGET

	if(L.stat && !emagged)		//if the perp is dead/dying, no need to bother really
		return TURRET_NOT_TARGET	//move onto next potential victim!

	if(emagged)		// If emagged not even the dead get a rest
		return L.stat ? TURRET_SECONDARY_TARGET : TURRET_PRIORITY_TARGET

	if(in_faction(L))
		return TURRET_NOT_TARGET

	if(check_synth)	//If it's set to attack all non-silicons, target them!
		if(IS_HORIZONTAL(L))
			return TURRET_SECONDARY_TARGET
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

	if(HAS_TRAIT(L, TRAIT_FLOORED)) // if the perp is floored, they aren't a threat. unless we are putting them down for good
		if(lethal)
			return TURRET_SECONDARY_TARGET
		else
			return TURRET_NOT_TARGET

	return TURRET_PRIORITY_TARGET	//if the perp has passed all previous tests, congrats, it is now a "shoot-me!" nominee

/obj/machinery/porta_turret/proc/assess_obj(obj/O)
	if(pre_assess_checks(O) == TURRET_PREASSESS_INVALID)
		return TURRET_NOT_TARGET

	if(istype(O, /obj/structure/blob))
		return check_anomalies ? TURRET_SECONDARY_TARGET : TURRET_NOT_TARGET

	return TURRET_NOT_TARGET

/obj/machinery/porta_turret/proc/tryToShootAt(list/mob/living/targets)
	if(targets.len && last_target && (last_target in targets) && target(last_target))
		return 1

	while(targets.len > 0)
		var/mob/living/M = pick(targets)
		targets -= M
		if(target(M))
			return 1

/obj/machinery/porta_turret/proc/check_pop_up()
	/// Whitelist to determine what objects can be put over turrets while letting them deploy
	var/static/list/deployment_whitelist = typecacheof(list(
		/obj/structure/window/reinforced,
		/obj/structure/window/basic,
		/obj/structure/window/plasmabasic,
		/obj/structure/window/plasmareinforced,
		/obj/machinery/door/window,
		/obj/structure/railing,
	))
	if(disabled)
		return
	if(raising || raised)
		return
	if(stat & BROKEN)
		return
	if(deployment_override)
		pop_up()
	// check if anything's preventing us from raising
	var/turf/T = get_turf(src)
	for(var/atom/A in T)
		if(A == src)
			continue
		if(A.density)
			if(is_type_in_typecache(A, deployment_whitelist))
				continue
			return
	pop_up()

/obj/machinery/porta_turret/proc/pop_up()	//pops the turret up
	set_raised_raising(raised, TRUE)
	playsound(get_turf(src), 'sound/effects/turret/open.wav', 60, 1)
	update_icon(UPDATE_ICON_STATE)

	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	flick_holder.layer = layer + 0.1
	flick("popup", flick_holder)
	sleep(10)
	qdel(flick_holder)

	set_raised_raising(TRUE, FALSE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/porta_turret/proc/pop_down()	//pops the turret down
	last_target = null
	if(disabled)
		return
	if(raising || !raised)
		return
	if(stat & BROKEN)
		return
	set_raised_raising(raised, TRUE)
	playsound(get_turf(src), 'sound/effects/turret/open.wav', 60, 1)
	update_icon(UPDATE_ICON_STATE)

	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	flick_holder.layer = layer + 0.1
	flick("popdown", flick_holder)
	sleep(10)
	qdel(flick_holder)

	set_raised_raising(FALSE, FALSE)
	set_angle(0)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/porta_turret/on_assess_perp(mob/living/carbon/human/perp)
	if((check_access || attacked) && !allowed(perp))
		//if the turret has been attacked or is angry, target all non-authorized personnel, see req_access
		return 10

	return ..()

/obj/machinery/porta_turret/proc/set_raised_raising(is_raised, is_raising)
	raised = is_raised
	raising = is_raising
	density = is_raised || is_raising

/obj/machinery/porta_turret/proc/target(mob/living/target)
	if(disabled)
		return
	if(target)
		last_target = target
		if(has_cover)
			check_pop_up()				//pop the turret up if it's not already up.
		// Set angle
		set_angle(get_angle(src, target))
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

	update_icon(UPDATE_ICON_STATE)
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
		A.starting = loc
		A.fire()
	else
		A.throw_at(target, scan_range, 1)
	return A

/obj/machinery/porta_turret/ai_turret
	initial_eprojectile = /obj/item/projectile/beam/laser/ai_turret

/obj/machinery/porta_turret/ai_turret/disable
	name = "hallway turret"
	initial_projectile = /obj/item/projectile/beam/disabler

/obj/machinery/porta_turret/centcom
	name = "\improper Centcomm turret"
	enabled = FALSE
	ailock = TRUE
	check_synth	 = FALSE
	check_access = TRUE
	check_arrest = TRUE
	check_records = TRUE
	check_weapons = TRUE
	check_anomalies = TRUE
	region_max = REGION_CENTCOMM // Non-turretcontrolled turrets at CC can have their access customized to check for CC accesses.
	deployment_override = TRUE

/obj/machinery/porta_turret/centcom/pulse
	name = "pulse turret"
	health = 200
	enabled = TRUE
	lethal = TRUE
	lethal_is_configurable = FALSE
	req_access = list(ACCESS_CENT_COMMANDER)
	installation = /obj/item/gun/energy/pulse/turret

/datum/turret_checks
	var/enabled
	var/lethal
	var/check_synth
	var/check_access
	var/check_records
	var/check_arrest
	var/check_weapons
	var/check_anomalies
	var/check_borgs
	var/ailock

/obj/machinery/porta_turret/proc/setState(datum/turret_checks/TC)
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
	check_borgs = TC.check_borgs
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
				anchored = TRUE
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
				anchored = FALSE
				build_step = 0
				return


		if(2)
			if(istype(I, /obj/item/wrench))
				playsound(loc, I.usesound, 100, 1)
				to_chat(user, "<span class='notice'>You bolt the metal armor into place.</span>")
				build_step = 3
				return

		if(3)
			if(istype(I, /obj/item/gun/energy)) //the gun installation part

				if(isrobot(user))
					return
				var/obj/item/gun/energy/E = I //typecasts the item to an energy gun
				if(!user.unEquip(I))
					to_chat(user, "<span class='notice'>\the [I] is stuck to your hand, you cannot put it in \the [src]</span>")
					return
				if(!E.can_fit_in_turrets)
					to_chat(user, "<span class='notice'>[I] will not operate correctly in [src].</span>")
					return
				installation = I.type //installation becomes I.type
				gun_charge = E.cell.charge //the gun's charge is stored in gun_charge
				to_chat(user, "<span class='notice'>You add [I] to the turret.</span>")

				if(istype(E, /obj/item/gun/energy/laser/tag/blue))
					target_type = /obj/machinery/porta_turret/tag/blue
				else if(istype(E, /obj/item/gun/energy/laser/tag/red))
					target_type = /obj/machinery/porta_turret/tag/red
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
			return
			//screwdriver_act() handles screwing the panel closed
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

		if(7)
			if(istype(I, /obj/item/crowbar))
				playsound(loc, I.usesound, 75, 1)
				to_chat(user, "<span class='notice'>You pry off the turret's exterior armor.</span>")
				new /obj/item/stack/sheet/metal(loc, 2)
				build_step = 6
				return

	if(is_pen(I))	//you can rename turrets like bots!
		var/t = input(user, "Enter new turret name", name, finish_name) as text
		t = sanitize(copytext(t, 1, MAX_MESSAGE_LEN))
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return

		finish_name = t
		return
	..()

/obj/machinery/porta_turret_construct/screwdriver_act(mob/living/user, obj/item/I)
	if(build_step != 6 && build_step != 5)
		return

	if(build_step == 5)
		build_step = 6
		to_chat(user, "<span class='notice'>You close the internal access hatch.</span>")
	else
		build_step = 5
		to_chat(user, "<span class='notice'>You open the internal access hatch.</span>")

	I.play_tool_sound(src)
	return TRUE

/obj/machinery/porta_turret_construct/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(build_step == 2)
		if(!I.use_tool(src, user, 20, 5, volume = I.tool_volume))
			return
		if(build_step != 2)
			return
		build_step = 1
		to_chat(user, "<span class='notice'>You remove the turret's interior metal armor.</span>")
		new /obj/item/stack/sheet/metal(drop_location(), 2)
	else if(build_step == 7)
		if(!I.use_tool(src, user, 50, amount = 5, volume = I.tool_volume))
			return
		if(build_step != 7)
			return
		build_step = 8
		to_chat(user, "<span class='notice'>You weld the turret's armor down.</span>")

		//The final step: create a full turret
		var/obj/machinery/porta_turret/Turret = new target_type(loc)
		Turret.name = finish_name
		Turret.installation = installation
		Turret.gun_charge = gun_charge
		Turret.enabled = FALSE
		Turret.setup()

		qdel(src)

/obj/machinery/porta_turret_construct/attack_hand(mob/user)
	switch(build_step)
		if(4)
			if(!installation)
				return
			build_step = 3

			var/obj/item/gun/energy/Gun = new installation(loc)
			Gun.cell.charge = gun_charge
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
	anchored = TRUE

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

	syndicate = TRUE
	installation = null
	always_up = TRUE
	requires_power = FALSE
	power_state = NO_POWER_USE
	has_cover = FALSE
	raised = TRUE
	scan_range = 9

	faction = "syndicate"
	emp_vulnerable = FALSE

	lethal = TRUE
	lethal_is_configurable = FALSE
	targetting_is_configurable = FALSE
	check_arrest = FALSE
	check_records = FALSE
	check_weapons = FALSE
	check_access = FALSE
	check_anomalies = TRUE
	check_synth	= TRUE
	ailock = TRUE
	var/area/syndicate_depot/core/depotarea

/obj/machinery/porta_turret/syndicate/CanPass(atom/A)
	return ((stat & BROKEN) || !isliving(A))

/obj/machinery/porta_turret/syndicate/CanPathfindPass(obj/item/card/id/ID, to_dir, atom/movable/caller, no_id = FALSE)
	return ((stat & BROKEN) || !isliving(caller))

/obj/machinery/porta_turret/syndicate/die()
	. = ..()
	if(istype(depotarea))
		depotarea.turret_died()

/obj/machinery/porta_turret/syndicate/shootAt(mob/living/target)
	if(istype(depotarea))
		depotarea.list_add(target, depotarea.hostile_list)
		depotarea.declare_started()
	return ..(target)

/obj/machinery/porta_turret/syndicate/Initialize(mapload)
	. = ..()
	if(req_one_access && req_one_access.len)
		req_one_access.Cut()
	req_access = list(ACCESS_SYNDICATE)
	one_access = FALSE

/obj/machinery/porta_turret/syndicate/update_icon_state()
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

/obj/machinery/porta_turret/syndicate/pod/nuke_ship_interior
	health = 100
