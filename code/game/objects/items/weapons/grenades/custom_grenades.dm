/obj/item/grenade/chem_grenade/dirt
	payload_name = "dirt"
	desc = "From the makers of BLAM! brand foaming space cleaner, this bomb guarantees steady work for any janitor."
	stage = 2

/obj/item/grenade/chem_grenade/dirt/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/list/muck = list("blood","carbon","flour","radium")
	var/filth = pick(muck - "radium") // not usually radioactive

	B1.reagents.add_reagent(filth,25)
	if(prob(25))
		B1.reagents.add_reagent(pick(muck - filth,25)) // but sometimes...

	beakers += B1


/obj/item/grenade/chem_grenade/meat
	payload_name = "meat"
	desc = "Not always as messy as the name implies."
	stage = 2


/obj/item/grenade/chem_grenade/meat/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("blood",60)
	if(prob(5))
		B1.reagents.add_reagent("blood",1) // Quality control problems, causes a mess
	B2.reagents.add_reagent("cryoxadone",30)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/holywater
	payload_name = "holy water"
	desc = "Then shalt thou count to three, no more, no less."
	stage = 2
	det_time = 30

/obj/item/grenade/chem_grenade/holywater/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/large/B = new(src)
	B.reagents.add_reagent("holywater",100)
	beakers += B

/obj/item/grenade/chem_grenade/hellwater
	payload_name = "hell water"
	desc = "And he struck them down with an unholy fury that burn like one-thousands badmins."
	stage = 2
	det_time = 30

/obj/item/grenade/chem_grenade/hellwater/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)
	B1.reagents.add_reagent("hell_water",80)
	B1.reagents.add_reagent("sugar",20)
	B2.reagents.add_reagent("hell_water", 60)
	B2.reagents.add_reagent("potassium", 20)
	B2.reagents.add_reagent("phosphorus", 20)


/obj/item/grenade/chem_grenade/drugs
	payload_name = "miracle"
	desc = "How does it work?"
	stage = 2

/obj/item/grenade/chem_grenade/drugs/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("space_drugs", 25)
	B1.reagents.add_reagent("lsd", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/grenade/chem_grenade/ethanol
	payload_name = "ethanol"
	desc = "Ach, that hits the spot."
	stage = 2

/obj/item/grenade/chem_grenade/ethanol/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("ethanol", 75)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)
	B2.reagents.add_reagent("ethanol", 25)

	beakers += B1
	beakers += B2
	update_icon()

// -------------------------------------
// Grenades using new grenade assemblies
// -------------------------------------
/obj/item/grenade/chem_grenade/lube
	payload_name = "lubricant"
	stage = 2

/obj/item/grenade/chem_grenade/lube/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	B1.reagents.add_reagent("lube",50)
	beakers += B1

/obj/item/grenade/chem_grenade/lube/remote/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/lube/prox/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)

/obj/item/grenade/chem_grenade/lube/tripwire/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/infra)


// Basic explosion grenade
/obj/item/grenade/chem_grenade/explosion
	payload_name = "conventional"
	stage = 2

/obj/item/grenade/chem_grenade/explosion/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)
	B1.reagents.add_reagent("glycerol",30) // todo: someone says NG is overpowered, test.
	B1.reagents.add_reagent("sacid",15)
	B2.reagents.add_reagent("sacid",15)
	B2.reagents.add_reagent("facid",30)
	beakers += B1
	beakers += B2

// Assembly Variants
/obj/item/grenade/chem_grenade/explosion/remote/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/explosion/prox/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)

/obj/item/grenade/chem_grenade/explosion/mine/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/mousetrap)

/obj/item/grenade/chem_grenade/explosion/mine_armed/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/mousetrap/armed)


// Water + Potassium = Boom

/obj/item/grenade/chem_grenade/waterpotassium
	payload_name = "chem explosive"
	stage = 2

/obj/item/grenade/chem_grenade/waterpotassium/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)
	B1.reagents.add_reagent("water",100)
	B2.reagents.add_reagent("potassium",100)
	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/waterpotassium/remote/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/waterpotassium/prox/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)


/obj/item/grenade/chem_grenade/waterpotassium/tripwire/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/infra)

/obj/item/grenade/chem_grenade/waterpotassium/tripwire_armed/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/infra/armed)

/obj/item/grenade/chem_grenade/waterpotassium/tripwire_armed_stealth/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/infra/armed/stealth)




// Basic EMP grenade
/obj/item/grenade/chem_grenade/emp
	payload_name = "EMP"
	stage = 2

/obj/item/grenade/chem_grenade/emp/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)
	B1.reagents.add_reagent("uranium",50)
	B2.reagents.add_reagent("iron",50)
	beakers += B1
	beakers += B2

// Assembly Variants
/obj/item/grenade/chem_grenade/emp/remote/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/emp/prox/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)

/obj/item/grenade/chem_grenade/emp/mine/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/mousetrap)

/obj/item/grenade/chem_grenade/large/monster
	payload_name = "gold slime"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

/obj/item/grenade/chem_grenade/large/monster/New()
	..()
	var/obj/item/slime_extract/gold/B1 = new(src)
	B1.Uses = rand(1,3)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)
	B2.reagents.add_reagent("plasma",5 * B1.Uses)
	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/large/monster/prox/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)

/obj/item/grenade/chem_grenade/large/monster/mine/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/mousetrap)

/obj/item/grenade/chem_grenade/large/monster/remote/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/large/feast
	payload_name = "silver slime"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

/obj/item/grenade/chem_grenade/large/feast/New()
	..()
	var/obj/item/slime_extract/silver/B1 = new(src)
	B1.Uses = rand(1,3)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)
	B2.reagents.add_reagent("plasma",5 * B1.Uses)
	beakers += B1
	beakers += B2

// --------------------------------------
//  Syndie Kits
// --------------------------------------

/obj/item/storage/box/syndie_kit/remotegrenade
	name = "Remote Grenade Kit"

/obj/item/storage/box/syndie_kit/remotegrenade/New()
	..()
	new /obj/item/grenade/chem_grenade/explosion/remote(src)
	new /obj/item/multitool(src) // used to adjust the chemgrenade's signaller
	new /obj/item/assembly/signaler(src)
	return

/obj/item/storage/box/syndie_kit/remoteemp
	name = "Remote EMP Kit"

/obj/item/storage/box/syndie_kit/remoteemp/New()
	..()
	new /obj/item/grenade/chem_grenade/emp/remote(src)
	new /obj/item/multitool(src) // used to adjust the chemgrenade's signaller
	new /obj/item/assembly/signaler(src)
	return

/obj/item/storage/box/syndie_kit/remotelube
	name = "Remote Lube Kit"

/obj/item/storage/box/syndie_kit/remotelube/New()
	..()
	new /obj/item/grenade/chem_grenade/lube(src)
	new /obj/item/multitool(src) // used to adjust the chemgrenade's signaller
	new /obj/item/assembly/signaler(src)
	return

// --------------------------------------
//  BSA Signaller
// --------------------------------------

/obj/item/grenade/bsa
	name = "bluespace artillery signal beacon"
	desc = "Call in a one time strike with bluespace artillery. It is filled with various biometric security measures."
	icon_state = "bsa_beacon"
	item_state = "bsa_beacon"
	req_one_access = list(access_cent_commander)
	det_time= 8 //in seconds, we multiply by 10 below so we can use this var in the messages we send. so a value of 8 here would be a value of 80 for the timer.
	var/arm_time = 40 //in deciseconds, so 40 would equal 4 seconds.
	var/caller
	var/centcom_cancast = FALSE //incase admin wants to varedit to allow on Z 2 for whatever reason.
	var/ex_power = 3
	var/authorized_special_roles = list(SPECIAL_ROLE_ERT, SPECIAL_ROLE_DEATHSQUAD)
	var/ID_access_override = TRUE
	var/require_mindshield = TRUE

/obj/item/grenade/bsa/proc/authenticate(var/mob/user, var/mindshield_check, var/role_check, var/access_check)
	//mindshield check
	if(mindshield_check && !ismindshielded(user))
		return FALSE
	//access check
	if(access_check && !allowed(user))
		return FALSE
	//special role check
	if(role_check)
		var/role = FALSE
		for(var/R in authorized_special_roles)
			if(user.mind.special_role == R)
				role = TRUE
				break
		if(!role)
			return FALSE
	return TRUE

/obj/item/grenade/bsa/attack_self()
	var/mob/user = usr
	var/turf/bombturf = get_turf(src)
	if(active)
		return
	if(is_admin_level(bombturf.z) && !centcom_cancast)
		to_chat(user, "<span class = 'warning'>The strike craft isn't authorized to fire near Central Command!</span>")
		return
	if(!authenticate(user, require_mindshield, authorized_special_roles, FALSE) && (ID_access_override && !authenticate(user, FALSE, FALSE, TRUE))) //if is not mindshielded, not an ERT/DS AND does not have high level CC access. naval officers have access_cent_commander, but not special role so we don't want to lock them out.
		to_chat(user, "<span class = 'warning'>Unauthorized user detected.</span>")
		return
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	item_state = initial(item_state) + "_active"
	var/area/A = get_area(bombturf)
	to_chat(user, "<span class = 'warning'>Calibrating GPS, remain still to continue with the strike.</span>")
	//tell admins and ghosts we are initiating a strike
	message_admins("[key_name_admin(user)] is initiating a Bluespace Artillery Strike at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>") 
	notify_ghosts("[user] is initiating a Bluespace Artillery Strike in [get_area(src)]!", source = src)
	log_game("[key_name_admin(user)] is initiating a Bluespace Artillery Strike at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>")
	
	playsound(src, 'sound/effects/bsainit.ogg', 50, 0)
	
	//make sure they stay still, if they move it's cancelled
	if(do_after(user, arm_time, target = user))
		playsound(src, 'sound/effects/bsainbound.ogg', 70, 0, 6, 3)
		light_power = 8
		light_color = "blue"
		light_range = 10
		update_light()
		priority_announcement.Announce("This is NDV Brutus, we've received your strike signal loud and clear, [user]! Bluespace Artillery Strike incoming near [A.name]!", "Bluespace Artillery Strike", 'sound/effects/engine_alert2.ogg')
		to_chat(user, "<span class = 'warning'>Strike sequence initiated! Deploy beacon to target! [det_time] seconds!</span>")
		caller = user
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.throw_mode_on()
		addtimer(CALLBACK(src, .proc/prime), det_time * 10)
	else
		active = FALSE
		to_chat(user, "<span class = 'warning'>Calibration cancelled. Strike sequence aborted.</span>")
		message_admins("[key_name_admin(user)] has cancelled a Bluespace Artillery Strike at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>")
		icon_state = initial(icon_state)
		item_state = initial(item_state)

/obj/item/grenade/bsa/prime()
	var/turf/bombturf = get_turf(src)
	var/area/A = get_area(bombturf)
	explosion(get_turf(src), ex_power * 2, ex_power * 5, ex_power * 6)
	message_admins("[key_name_admin(caller)] has sucessfully called a Bluespace Artillery Strike at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>")
	log_game("[key_name_admin(caller)] has sucessfully called a Bluespace Artillery Strike at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>")
	investigate_log("[key_name(caller)] has sucessfully called a Bluespace Artillery Strike at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])", INVESTIGATE_BOMB)
	qdel(src)

/obj/item/grenade/bsa/blob_act()
	return
