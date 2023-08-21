/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = TRUE
	pressure_resistance = 2*ONE_ATMOSPHERE
	container_type = DRAINABLE | AMOUNT_VISIBLE
	max_integrity = 300
	/// How much this dispenser can hold (In units)
	var/tank_volume = 1000
	/// The ID of the reagent that the dispenser uses
	var/reagent_id = "water"
	/// The last person to rig this fuel tank - Stored with the object. Only the last person matters for investigation
	var/lastrigger = ""
	/// Can this tank be unwrenched
	var/can_be_unwrenched = TRUE
	/// If the dispenser is being blown up already. Used to avoid multiple boom calls due to itself exploding etc
	var/went_boom = FALSE

/obj/structure/reagent_dispensers/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		if(tank_volume && (damage_flag == BULLET || damage_flag == LASER))
			boom(FALSE, TRUE)

/obj/structure/reagent_dispensers/attackby(obj/item/I, mob/user, params)
	if(I.is_refillable())
		return FALSE //so we can refill them via their afterattack.
	return ..()

/obj/structure/reagent_dispensers/Initialize(mapload)
	. = ..()
	create_reagents(tank_volume)
	reagents.add_reagent(reagent_id, tank_volume)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/reagent_dispensers/wrench_act(mob/user, obj/item/I)
	if(!can_be_unwrenched)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/reagent_dispensers/examine(mob/user)
	. = ..()
	if(can_be_unwrenched)
		. += "<span class='notice'>The wheels look like they can be <b>[anchored ? "unlocked" : "locked in place"]</b> with a <b>wrench</b>."

/obj/structure/reagent_dispensers/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(reagents)
		for(var/i in 1 to 8)
			if(reagents)
				reagents.temperature_reagents(exposed_temperature)

/obj/structure/reagent_dispensers/proc/boom(rigtrigger = FALSE, log_attack = FALSE)
	if(went_boom)
		return
	went_boom = TRUE
	do_boom(rigtrigger, log_attack)

/obj/structure/reagent_dispensers/proc/do_boom(rigtrigger = FALSE, log_attack = FALSE)
	visible_message("<span class='danger'>[src] ruptures!</span>")
	chem_splash(loc, 5, list(reagents))
	qdel(src)

/obj/structure/reagent_dispensers/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!disassembled)
			boom(FALSE, TRUE)
	else
		qdel(src)

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "water tank"
	desc = "A water tank."
	icon_state = "water"
	pull_speed = 0

/obj/structure/reagent_dispensers/watertank/high
	name = "high-capacity water tank"
	desc = "A highly-pressurized water tank made to hold gargantuan amounts of water.."
	icon_state = "water_high" //I was gonna clean my room...
	tank_volume = 100000


/obj/structure/reagent_dispensers/oil
	name = "oil tank"
	desc = "A tank of oil, commonly used to by robotics to fix leaking IPCs or just to loosen up those rusted underused parts."
	icon_state = "oil"
	reagent_id = "oil"
	tank_volume = 3000
	pull_speed = 0

/obj/structure/reagent_dispensers/fueltank
	name = "fuel tank"
	desc = "A tank full of industrial welding fuel. Do not consume."
	icon_state = "fuel"
	reagent_id = "fuel"
	tank_volume = 4000
	anchored = TRUE
	pull_speed = 0
	var/obj/item/assembly_holder/rig = null
	var/accepts_rig = 1

/obj/structure/reagent_dispensers/fueltank/Destroy()
	QDEL_NULL(rig)
	return ..()

/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/item/projectile/P)
	var/will_explode = !QDELETED(src) && !P.nodamage && (P.damage_type == BURN || P.damage_type == BRUTE)

	if(will_explode) // Log here while you have the information needed
		add_attack_logs(P.firer, src, "shot with [P.name]", ATKLOG_FEW)
		log_game("[key_name(P.firer)] triggered a fueltank explosion with [P.name] at [COORD(loc)]")
		investigate_log("[key_name(P.firer)] triggered a fueltank explosion with [P.name] at [COORD(loc)]", INVESTIGATE_BOMB)
	..()

/obj/structure/reagent_dispensers/fueltank/do_boom(rigtrigger = FALSE, log_attack = FALSE) // Prevent case where someone who rigged the tank is blamed for the explosion when the rig isn't what triggered the explosion
	if(rigtrigger) // If the explosion is triggered by an assembly holder
		log_game("A fueltank, last rigged by [lastrigger], triggered at [COORD(loc)]")
		add_attack_logs(lastrigger, src, "rigged fuel tank exploded", ATKLOG_FEW)
		investigate_log("A fueltank, last rigged by [lastrigger], triggered at [COORD(loc)]", INVESTIGATE_BOMB)
	if(log_attack)
		add_attack_logs(usr, src, "blew up", ATKLOG_FEW)
	if(reagents)
		reagents.set_reagent_temp(1000) //uh-oh
	qdel(src)

/obj/structure/reagent_dispensers/fueltank/blob_act(obj/structure/blob/B)
	boom()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	boom()

/obj/structure/reagent_dispensers/fueltank/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	boom()

/obj/structure/reagent_dispensers/fueltank/zap_act(power, zap_flags)
	. = ..() //extend the zap
	if(ZAP_OBJ_DAMAGE & zap_flags)
		boom()

/obj/structure/reagent_dispensers/fueltank/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2 && rig)
		. += "<span class='notice'>There is some kind of device rigged to the tank.</span>"

/obj/structure/reagent_dispensers/fueltank/attack_hand()
	if(rig)
		usr.visible_message("<span class='notice'>[usr] begins to detach [rig] from [src].</span>", "<span class='notice'>You begin to detach [rig] from [src].</span>")
		if(do_after(usr, 20, target = src))
			usr.visible_message("<span class='notice'>[usr] detaches [rig] from [src].</span>", "<span class='notice'>You detach [rig] from [src].</span>")
			rig.forceMove(get_turf(usr))
			rig = null
			lastrigger = null
			overlays.Cut()

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly_holder) && accepts_rig)
		if(rig)
			to_chat(user, "<span class='warning'>There is another device in the way.</span>")
			return ..()
		user.visible_message("[user] begins rigging [I] to [src].", "You begin rigging [I] to [src]")
		if(do_after(user, 20, target = src))
			user.visible_message("<span class='notice'>[user] rigs [I] to [src].</span>", "<span class='notice'>You rig [I] to [src].</span>")

			var/obj/item/assembly_holder/H = I
			if(istype(H.a_left, /obj/item/assembly/igniter) || istype(H.a_right, /obj/item/assembly/igniter))
				log_game("[key_name(user)] rigged [src.name] with [I.name] for explosion at [COORD(loc)]")
				add_attack_logs(user, src, "rigged fuel tank with [I.name] for explosion", ATKLOG_FEW)
				investigate_log("[key_name(user)] rigged [src.name] with [I.name] for explosion at [COORD(loc)]", INVESTIGATE_BOMB)

				lastrigger = "[key_name(user)]"
				rig = H
				user.drop_item()
				H.forceMove(src)
				var/icon/test = getFlatIcon(H)
				test.Shift(NORTH, 1)
				test.Shift(EAST, 6)
				overlays += test
	else
		return ..()

/obj/structure/reagent_dispensers/fueltank/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!reagents.has_reagent("fuel"))
		to_chat(user, "<span class='warning'>[src] is out of fuel!</span>")
		return
	if(I.tool_enabled && I.use_tool(src, user, volume = I.tool_volume)) //check it's enabled first to prevent duplicate messages when refuelling
		user.visible_message("<span class='danger'>[user] catastrophically fails at refilling [user.p_their()] [I]!</span>", "<span class='userdanger'>That was stupid of you.</span>")
		message_admins("[key_name_admin(user)] triggered a fueltank explosion at [COORD(loc)]")
		log_game("[key_name(user)] triggered a fueltank explosion at [COORD(loc)]")
		add_attack_logs(user, src, "hit with lit welder")
		investigate_log("[key_name(user)] triggered a fueltank explosion at [COORD(loc)]", INVESTIGATE_BOMB)
		boom()
	else
		I.refill(user, src, reagents.get_reagent_amount("fuel")) //Try dump all fuel into the welder


/obj/structure/reagent_dispensers/fueltank/Move()
	..()
	if(rig)
		rig.process_movement()

/obj/structure/reagent_dispensers/fueltank/HasProximity(atom/movable/AM)
	if(rig)
		rig.HasProximity(AM)

/obj/structure/reagent_dispensers/fueltank/Crossed(atom/movable/AM, oldloc)
	if(rig)
		rig.Crossed(AM, oldloc)

/obj/structure/reagent_dispensers/fueltank/hear_talk(mob/living/M, list/message_pieces)
	if(rig)
		rig.hear_talk(M, message_pieces)

/obj/structure/reagent_dispensers/fueltank/hear_message(mob/living/M, msg)
	if(rig)
		rig.hear_message(M, msg)

/obj/structure/reagent_dispensers/fueltank/Bump()
	..()
	if(rig)
		rig.process_movement()


/obj/structure/reagent_dispensers/peppertank
	name = "pepper spray refiller"
	desc = "Contains condensed capsaicin for use in law \"enforcement.\""
	icon_state = "pepper"
	density = FALSE
	can_be_unwrenched = FALSE
	anchored = TRUE
	reagent_id = "condensedcapsaicin"

/obj/structure/reagent_dispensers/water_cooler
	name = "liquid cooler"
	desc = "A machine that dispenses liquid to drink."
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	tank_volume = 500
	reagent_id = "water"
	anchored = TRUE
	var/paper_cups = 25 //Paper cups left from the cooler

/obj/structure/reagent_dispensers/water_cooler/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += "There are [paper_cups ? paper_cups : "no"] paper cups left."

/obj/structure/reagent_dispensers/water_cooler/attack_hand(mob/living/user)
	if(!paper_cups)
		to_chat(user, "<span class='warning'>There aren't any cups left!</span>")
		return
	user.visible_message("<span class='notice'>[user] takes a cup from [src].</span>", "<span class='notice'>You take a paper cup from [src].</span>")
	var/obj/item/reagent_containers/food/drinks/sillycup/S = new(get_turf(src))
	user.put_in_hands(S)
	paper_cups--

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "Beer is liquid bread, it's good for you..."
	icon_state = "beer"
	reagent_id = "beer"

/obj/structure/reagent_dispensers/beerkeg/blob_act(obj/structure/blob/B)
	explosion(loc, 0, 3, 5, 7, 10)
	if(!QDELETED(src))
		qdel(src)

/obj/structure/reagent_dispensers/beerkeg/nuke
	name = "Nanotrasen-brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Nanotrasen Corporate Warfare Division, their nuclear fission explosives are renowned for being cheap \
	to produce and devestatingly effective. Signs explain that though this is just a model, every Nanotrasen station is equipped with one, just in case. \
	All Captains carefully guard the disk needed to detonate them - at least, the sign says they do. There seems to be a tap on the back."
	icon = 'icons/obj/nuclearbomb.dmi'
	icon_state = "nuclearbomb0"
	anchored = TRUE
	pull_speed = 0

/obj/structure/reagent_dispensers/beerkeg/nuke/update_overlays()
	. = ..()
	if(anchored)
		. += "nukebolts"

/obj/structure/reagent_dispensers/virusfood
	name = "virus food dispenser"
	desc = "A dispenser of low-potency virus mutagenic."
	icon_state = "virus_food"
	can_be_unwrenched = FALSE
	anchored = TRUE
	density = FALSE
	reagent_id = "virusfood"

/obj/structure/reagent_dispensers/spacecleanertank
	name = "space cleaner refiller"
	desc = "Refills space cleaner bottles."
	icon_state = "cleaner"
	can_be_unwrenched = FALSE
	anchored = TRUE
	density = FALSE
	tank_volume = 5000
	reagent_id = "cleaner"

/obj/structure/reagent_dispensers/fueltank/chem
	icon_state = "fuel_chem"
	can_be_unwrenched = FALSE
	density = FALSE
	accepts_rig = FALSE
	tank_volume = 1000
