#define PLASMA_CHARGE_USE_PER_SECOND 2.5
#define PLASMA_DISCHARGE_LIMIT 5

// Ion Rifles //
/obj/item/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats"
	icon_state = "ionrifle"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/ionrifle.ogg'
	origin_tech = "combat=4;magnets=4"
	w_class = WEIGHT_CLASS_HUGE
	can_holster = FALSE
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	ammo_x_offset = 3
	flight_x_offset = 17
	flight_y_offset = 9

/obj/item/gun/energy/ionrifle/emp_act(severity)
	return

/obj/item/gun/energy/ionrifle/carbine
	name = "ion carbine"
	desc = "The MK.II Prototype Ion Projector is a lightweight carbine version of the larger ion rifle, built to be ergonomic and efficient."
	icon_state = "ioncarbine"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_BELT
	ammo_x_offset = 2
	flight_x_offset = 18
	flight_y_offset = 11

// Decloner //
/obj/item/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	fire_sound = 'sound/weapons/pulse3.ogg'
	origin_tech = "combat=4;materials=4;biotech=5;plasmatech=6"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	ammo_x_offset = 1
	can_holster = TRUE

/obj/item/gun/energy/decloner/update_icon()
	..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(cell.charge > shot.e_cost)
		add_overlay("decloner_spin")

// Flora Gun //
/obj/item/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	item_state = "gun"
	fire_sound = 'sound/effects/stealthoff.ogg'
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=4"
	modifystate = 1
	ammo_x_offset = 1
	selfcharge = 1
	can_holster = TRUE

// Meteor Gun //
/obj/item/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "riotgun"
	item_state = "c20r"
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = /obj/item/stock_parts/cell/potato
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	selfcharge = 1

/obj/item/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY

// Mind Flayer //
/obj/item/gun/energy/mindflayer
	name = "\improper Mind Flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "flayer"
	item_state = null
	shaded_charge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)

// Energy Crossbows //
/obj/item/gun/energy/kinetic_accelerator/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists."
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=4;magnets=4;syndicate=5"
	suppressed = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	weapon_weight = WEAPON_LIGHT
	unique_rename = FALSE
	overheat_time = 20
	holds_charge = TRUE
	unique_frequency = TRUE
	can_flashlight = 0
	max_mod_capacity = 0
	empty_state = null
	can_holster = TRUE

/obj/item/gun/energy/kinetic_accelerator/crossbow/detailed_examine()
	return "This is an energy weapon. To fire the weapon, have your gun mode set to 'fire', \
			then click where you want to fire."

/obj/item/gun/energy/kinetic_accelerator/crossbow/detailed_examine_antag()
	return "This is a stealthy weapon which fires poisoned bolts at your target. When it hits someone, they will suffer a stun effect, in \
			addition to toxins. The energy crossbow recharges itself slowly, and can be concealed in your pocket or bag."

/obj/item/gun/energy/kinetic_accelerator/crossbow/large
	name = "energy crossbow"
	desc = "A reverse engineered weapon using syndicate technology."
	icon_state = "crossbowlarge"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=4000)
	origin_tech = "combat=4;magnets=4;syndicate=2"
	suppressed = 0
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/large)

/obj/item/gun/energy/kinetic_accelerator/crossbow/large/cyborg
	desc = "One and done!"
	icon_state = "crossbowlarge"
	origin_tech = null
	materials = list()

/obj/item/gun/energy/kinetic_accelerator/suicide_act(mob/user)
	if(!suppressed)
		playsound(loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	user.visible_message("<span class='suicide'>[user] cocks [src] and pretends to blow [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
	shoot_live_shot(user, user, FALSE, FALSE)
	return OXYLOSS

// Plasma Cutters //
/obj/item/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	modifystate = -1
	origin_tech = "combat=1;materials=3;magnets=2;plasmatech=3;engineering=1"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	fire_sound = 'sound/weapons/laser.ogg'
	usesound = 'sound/items/welder.ogg'
	toolspeed = 1
	container_type = OPENCONTAINER
	flags = CONDUCT
	attack_verb = list("attacked", "slashed", "cut", "sliced")
	force = 12
	sharp = 1
	can_charge = 0
	can_holster = TRUE

/obj/item/gun/energy/plasmacutter/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/stack/sheet/mineral/plasma))
		if(cell.charge >= cell.maxcharge)
			to_chat(user,"<span class='notice'>[src] is already fully charged.")
			return
		var/obj/item/stack/sheet/S = A
		S.use(1)
		cell.give(1000)
		on_recharge()
		to_chat(user, "<span class='notice'>You insert [A] in [src], recharging it.</span>")
	else if(istype(A, /obj/item/stack/ore/plasma))
		if(cell.charge >= cell.maxcharge)
			to_chat(user,"<span class='notice'>[src] is already fully charged.")
			return
		var/obj/item/stack/ore/S = A
		S.use(1)
		cell.give(500)
		on_recharge()
		to_chat(user, "<span class='notice'>You insert [A] in [src], recharging it.</span>")
	else
		return ..()

/obj/item/gun/energy/plasmacutter/update_icon()
	return

/obj/item/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	icon_state = "adv_plasmacutter"
	item_state = "plasmacutteradv"
	modifystate = "adv_plasmacutter"
	origin_tech = "combat=3;materials=4;magnets=3;plasmatech=4;engineering=2"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)
	force = 15

// Wormhole Projectors //
/obj/item/gun/energy/wormhole_projector
	name = "bluespace wormhole projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	item_state = null
	icon_state = "wormhole_projector1"
	origin_tech = "combat=4;bluespace=6;plasmatech=4;engineering=4"
	charge_delay = 5
	selfcharge = TRUE
	var/obj/effect/portal/blue
	var/obj/effect/portal/orange


/obj/item/gun/energy/wormhole_projector/update_icon()
	icon_state = "wormhole_projector[select]"
	item_state = icon_state
	return

/obj/item/gun/energy/wormhole_projector/process_chamber()
	..()
	select_fire(usr)

/obj/item/gun/energy/wormhole_projector/portal_destroyed(obj/effect/portal/P)
	if(P.icon_state == "portal")
		blue = null
		if(orange)
			orange.target = null
	else
		orange = null
		if(blue)
			blue.target = null

/obj/item/gun/energy/wormhole_projector/proc/create_portal(obj/item/projectile/beam/wormhole/W)
	var/obj/effect/portal/P = new /obj/effect/portal(get_turf(W), null, src)
	P.precision = 0
	P.failchance = 0
	P.can_multitool_to_remove = 1
	if(W.name == "bluespace beam")
		qdel(blue)
		blue = P
	else
		qdel(orange)
		P.icon_state = "portal1"
		orange = P
	if(orange && blue)
		blue.target = get_turf(orange)
		orange.target = get_turf(blue)

/* 3d printer 'pseudo guns' for borgs */
/obj/item/gun/energy/printer
	name = "cyborg lmg"
	desc = "A machinegun that fires 3d-printed flachettes slowly regenerated using a cyborg's internal power source."
	icon_state = "l6closed0"
	icon = 'icons/obj/guns/projectile.dmi'
	cell_type = /obj/item/stock_parts/cell/secborg
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	can_charge = 0

/obj/item/gun/energy/printer/update_icon()
	return

/obj/item/gun/energy/printer/emp_act()
	return

// Instakill Lasers //
/obj/item/gun/energy/laser/instakill
	name = "instakill rifle"
	icon_state = "instagib"
	item_state = "instagib"
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit."
	ammo_type = list(/obj/item/ammo_casing/energy/instakill)
	force = 60
	origin_tech = "combat=7;magnets=6"

/obj/item/gun/energy/laser/instakill/emp_act() //implying you could stop the instagib
	return

/obj/item/gun/energy/laser/instakill/red
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a red design."
	icon_state = "instagibred"
	item_state = "instagibred"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/red)

/obj/item/gun/energy/laser/instakill/blue
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a blue design."
	icon_state = "instagibblue"
	item_state = "instagibblue"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/blue)

// HONK Rifle //
/obj/item/gun/energy/clown
	name = "\improper HONK rifle"
	desc = "Clown Planet's finest."
	icon_state = "disabler"
	ammo_type = list(/obj/item/ammo_casing/energy/clown)
	clumsy_check = 0
	selfcharge = 1
	ammo_x_offset = 3
	can_holster = TRUE  // you'll never see it coming

/obj/item/gun/energy/plasma_pistol
	name = "plasma pistol"
	desc = "A specialized firearm designed to fire heated bolts of plasma. Can be overloaded for a high damage shield breaking shot."
	icon_state = "toxgun"
	item_state = "toxgun"
	sprite_sheets_inhand = list("Vox" = 'icons/mob/clothing/species/vox/held.dmi', "Drask" = 'icons/mob/clothing/species/drask/held.dmi') //This apperently exists, and I have the sprites so sure.
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/weak_plasma, /obj/item/ammo_casing/energy/charged_plasma)
	shaded_charge = 1
	can_holster = TRUE
	atom_say_verb = "beeps"
	bubble_icon = "swarmer"
	light_color = "#89078E"
	light_power = 4
	var/overloaded = FALSE
	var/warned = FALSE
	var/charging = FALSE
	var/mob/living/carbon/holder = null

/obj/item/gun/energy/plasma_pistol/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/gun/energy/plasma_pistol/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	holder = null
	return ..()

/obj/item/gun/energy/plasma_pistol/process()
	..()
	if(overloaded)
		cell.charge -= PLASMA_CHARGE_USE_PER_SECOND / 5 //2.5 per second, 25 every 10 seconds
		if(cell.charge <= PLASMA_CHARGE_USE_PER_SECOND * 10 && !warned)
			warned = TRUE
			playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 75, 1)
			atom_say("Caution, charge low. Forced discharge in under 10 seconds.")
		if(cell.charge <= PLASMA_DISCHARGE_LIMIT)
			discharge()

/obj/item/gun/energy/plasma_pistol/attack_self(mob/living/user)
	if(overloaded)
		to_chat(user, "<span class='warning'>[src] is already overloaded!</span>")
		return
	if(cell.charge <= 140) //at least 6 seconds of charge time
		to_chat(user, "<span class='warning'>[src] does not have enough charge to be overloaded.</span>")
		return
	if(charging)
		return
	to_chat(user, "<span class='notice'>You begin to overload [src].</span>")
	charging = TRUE
	if(do_after(user, 2.5 SECONDS, target = src))
		select_fire(user)
		overloaded = TRUE
		cell.charge -= 125
		playsound(loc, 'sound/machines/terminal_prompt_confirm.ogg', 75, 1)
		atom_say("Overloading successful.")
		set_light(3) //extra visual effect to make it more noticable to user and victims alike
		holder = user
		RegisterSignal(holder, COMSIG_CARBON_SWAP_HANDS, .proc/discharge)
	charging = FALSE

/obj/item/gun/energy/plasma_pistol/proc/reset_overloaded()
	select_fire()
	set_light(0)
	overloaded = FALSE
	warned = FALSE
	UnregisterSignal(holder, COMSIG_CARBON_SWAP_HANDS)
	holder = null

/obj/item/gun/energy/plasma_pistol/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override, bonus_spread = 0)
	if(charging)
		return
	return ..()

/obj/item/gun/energy/plasma_pistol/process_chamber()
	if(overloaded)
		do_sparks(2, 1, src)
		reset_overloaded()
	..()
	update_icon()

/obj/item/gun/energy/plasma_pistol/emp_act(severity)
	..()
	if(prob(100 / severity) && overloaded)
		discharge()

/obj/item/gun/energy/plasma_pistol/dropped(mob/user)
	. = ..()
	if(overloaded)
		discharge()

/obj/item/gun/energy/plasma_pistol/equipped(mob/user, slot, initial)
	. = ..()
	if(overloaded)
		discharge()

/obj/item/gun/energy/plasma_pistol/proc/discharge() //25% of the time, plasma leak. Otherwise, shoot at a random mob / turf nearby. If no proper mob is found when mob is picked, fire at a turf instead
	SIGNAL_HANDLER
	reset_overloaded()
	do_sparks(2, 1, src)
	update_icon()
	if(prob(25))
		visible_message("<span class='danger'>[src] vents heated plasma!</span>")
		var/turf/simulated/T = get_turf(src)
		if(istype(T))
			T.atmos_spawn_air(LINDA_SPAWN_TOXINS|LINDA_SPAWN_20C,15)
		return
	if(prob(50))
		var/list/mob_targets = list()
		for(var/mob/living/M in oview(get_turf(src), 7))
			mob_targets += M
		if(length(mob_targets))
			var/mob/living/target = pick(mob_targets)
			shootAt(target)
			visible_message("<span class='danger'>[src] discharges a plasma bolt!</span>")
			return

	visible_message("<span class='danger'>[src] discharges a plasma bolt!</span>")
	var/list/turf_targets = list()
	for(var/turf/T in orange(get_turf(src), 7))
		turf_targets += T
	if(length(turf_targets))
		var/turf/target = pick(turf_targets)
		shootAt(target)


/obj/item/gun/energy/plasma_pistol/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U)
		return
	var/obj/item/projectile/energy/charged_plasma/O = new /obj/item/projectile/energy/charged_plasma(T)
	playsound(get_turf(src), 'sound/weapons/marauder.ogg', 75, 1)
	O.current = T
	O.yo = U.y - T.y
	O.xo = U.x - T.x
	O.fire()

/obj/item/gun/energy/bsg
	name = "\improper B.S.G"
	desc = "The Blue Space Gun. Uses a flux anomaly core and a bluespace crystal to produce destructive bluespace energy blasts, inspired by Nanotrasen's BSA division."
	icon_state = "bsg"
	item_state = "bsg"
	origin_tech = "combat=6;materials=6;powerstorage=6;bluespace=6;magnets=6" //cutting edge technology, be my guest if you want to deconstruct one instead of use it.
	ammo_type = list(/obj/item/ammo_casing/energy/bsg)
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_HUGE
	can_holster = FALSE
	slot_flags = SLOT_BACK
	cell_type = /obj/item/stock_parts/cell/bsg
	shaded_charge = TRUE
	can_fit_in_turrets = FALSE //Crystal would shatter, or someone would try to put an empty gun in the frame.
	var/obj/item/assembly/signaler/anomaly/flux/core = null
	var/has_bluespace_crystal = FALSE
	var/admin_model = FALSE //For the admin gun, prevents crystal shattering, so anyone can use it, and you dont need to carry backup crystals.

/obj/item/gun/energy/bsg/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/gun/energy/bsg/examine(mob/user)
	. = ..()
	if(core && has_bluespace_crystal)
		. += "<span class='notice'>[src] is fully operational!</span>"
	else if(core)
		. += "<span class='warning'>It has a flux anomaly core installed, but no bluespace crystal installed.</span>"
	else if(has_bluespace_crystal)
		. += "<span class='warning'>It has a bluespace crystal installed, but no flux anomaly core installed.</span>"
	else
		. += "<span class='warning'>It is missing a flux anomaly core and bluespace crystal to be operational.</span>"

/obj/item/gun/energy/bsg/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack/ore/bluespace_crystal))
		if(has_bluespace_crystal)
			to_chat(user, "<span class='notice'>[src] already has a bluespace crystal installed.</span>")
			return
		var/obj/item/stack/S = O
		if(!loc || !S || S.get_amount() < 1)
			return
		to_chat(user, "<span class='notice'>You load [O] into [src].</span>")
		S.use(1)
		has_bluespace_crystal = TRUE
		update_icon()
		return

	if(istype(O, /obj/item/assembly/signaler/anomaly/flux))
		if(core)
			to_chat(user, "<span class='notice'>[src] already has a [O]!</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[O] is stuck to your hand!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [O] into [src], and [src] starts to warm up.</span>")
		O.forceMove(src)
		core = O
		update_icon()
	else
		return ..()

/obj/item/gun/energy/bsg/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override, bonus_spread = 0)
	if(!has_bluespace_crystal)
		to_chat(user, "<span class='warning'>[src] has no bluespace crystal to power it!</span>")
		return
	if(!core)
		to_chat(user, "<span class='warning'>[src] has no flux anomaly core to power it!</span>")
		return
	return ..()

/obj/item/gun/energy/bsg/process_chamber()
	if(prob(25))
		shatter()
	..()
	update_icon()

/obj/item/gun/energy/bsg/update_icon()
	. = ..()
	if(core)
		if(has_bluespace_crystal)
			icon_state = "bsg_finished"
		else
			icon_state = "bsg_core"
	else if(has_bluespace_crystal)
		icon_state = "bsg_crystal"
	else
		icon_state = "bsg"

/obj/item/gun/energy/bsg/emp_act(severity)
	..()
	if(prob(75 / severity))
		if(has_bluespace_crystal)
			shatter()

/obj/item/gun/energy/bsg/proc/shatter()
	if(admin_model)
		return
	visible_message("<span class='warning'>[src]'s bluespace crystal shatters!</span>")
	playsound(src, 'sound/effects/pylon_shatter.ogg', 50, TRUE)
	has_bluespace_crystal = FALSE
	update_icon()

/obj/item/gun/energy/bsg/prebuilt
	icon_state = "bsg_finished"
	has_bluespace_crystal = TRUE

/obj/item/gun/energy/bsg/prebuilt/Initialize(mapload)
	. = ..()
	core = new /obj/item/assembly/signaler/anomaly/flux
	update_icon()

/obj/item/gun/energy/bsg/prebuilt/admin
	desc = "The Blue Space Gun. Uses a flux anomaly core and a bluespace crystal to produce destructive bluespace energy blasts, inspired by Nanotrasen's BSA division. This is an executive model, and its bluespace crystal will not shatter."
	admin_model = TRUE

// Temperature Gun //
/obj/item/gun/energy/temperature
	name = "temperature gun"
	icon = 'icons/obj/guns/gun_temperature.dmi'
	icon_state = "tempgun_4"
	item_state = "tempgun_4"
	slot_flags = SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	fire_sound = 'sound/weapons/pulse3.ogg'
	desc = "A gun that changes the body temperature of its targets."
	var/temperature = 300
	var/target_temperature = 300
	origin_tech = "combat=4;materials=4;powerstorage=3;magnets=2"

	ammo_type = list(/obj/item/ammo_casing/energy/temp)
	selfcharge = 1

	var/powercost = ""
	var/powercostcolor = ""
	var/dat = ""

/obj/item/gun/energy/temperature/Initialize(mapload, ...)
	. = ..()
	update_icon()
	START_PROCESSING(SSobj, src)


/obj/item/gun/energy/temperature/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/temperature/newshot()
	..()

/obj/item/gun/energy/temperature/attack_self(mob/living/user as mob)
	user.set_machine(src)
	update_dat()
	user << browse("<TITLE>Temperature Gun Configuration</TITLE><HR>[dat]", "window=tempgun;size=510x120")
	onclose(user, "tempgun")

/obj/item/gun/energy/temperature/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='caution'>You double the gun's temperature cap! Targets hit by searing beams will burst into flames!</span>")
		desc = "A gun that changes the body temperature of its targets. Its temperature cap has been hacked."

/obj/item/gun/energy/temperature/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			target_temperature = min((500 + 500*emagged), target_temperature+amount)
		else
			target_temperature = max(0, target_temperature+amount)
	if(istype(loc, /mob))
		attack_self(loc)
	add_fingerprint(usr)
	return

/obj/item/gun/energy/temperature/process()
	..()
	var/obj/item/ammo_casing/energy/temp/T = ammo_type[select]
	T.temp = temperature
	switch(temperature)
		if(0 to 100)
			T.e_cost = 300
			powercost = "High"
		if(100 to 250)
			T.e_cost = 200
			powercost = "Medium"
		if(251 to 300)
			T.e_cost = 100
			powercost = "Low"
		if(301 to 400)
			T.e_cost = 200
			powercost = "Medium"
		if(401 to 1000)
			T.e_cost = 300
			powercost = "High"
	switch(powercost)
		if("High")
			powercostcolor = "orange"
		if("Medium")
			powercostcolor = "green"
		else
			powercostcolor = "blue"
	if(target_temperature != temperature)
		var/difference = abs(target_temperature - temperature)
		if(difference >= (10 + 40*emagged)) //so emagged temp guns adjust their temperature much more quickly
			if(target_temperature < temperature)
				temperature -= (10 + 40*emagged)
			else
				temperature += (10 + 40*emagged)
		else
			temperature = target_temperature
		update_icon()

		if(istype(loc, /mob/living/carbon))
			var/mob/living/carbon/M = loc
			if(src == M.machine)
				update_dat()
				M << browse("<TITLE>Temperature Gun Configuration</TITLE><HR>[dat]", "window=tempgun;size=510x102")
	return

/obj/item/gun/energy/temperature/proc/update_dat()
	dat = ""
	dat += "Current output temperature: "
	if(temperature > 500)
		dat += "<FONT color=red><B>[temperature]</B> ([round(temperature-T0C)]&deg;C)</FONT>"
		dat += "<FONT color=red><B> SEARING!</B></FONT>"
	else if(temperature > (T0C + 50))
		dat += "<FONT color=red><B>[temperature]</B> ([round(temperature-T0C)]&deg;C)</FONT>"
	else if(temperature > (T0C - 50))
		dat += "<FONT color=black><B>[temperature]</B> ([round(temperature-T0C)]&deg;C)</FONT>"
	else
		dat += "<FONT color=blue><B>[temperature]</B> ([round(temperature-T0C)]&deg;C)</FONT>"
	dat += "<BR>"
	dat += "Target output temperature: "	//might be string idiocy, but at least it's easy to read
	dat += "<A href='?src=[UID()];temp=-100'>-</A> "
	dat += "<A href='?src=[UID()];temp=-10'>-</A> "
	dat += "<A href='?src=[UID()];temp=-1'>-</A> "
	dat += "[target_temperature] "
	dat += "<A href='?src=[UID()];temp=1'>+</A> "
	dat += "<A href='?src=[UID()];temp=10'>+</A> "
	dat += "<A href='?src=[UID()];temp=100'>+</A>"
	dat += "<BR>"
	dat += "Power cost: "
	dat += "<FONT color=[powercostcolor]><B>[powercost]</B></FONT>"

/obj/item/gun/energy/temperature/proc/update_temperature()
	switch(temperature)
		if(501 to INFINITY)
			item_state = "tempgun_8"
		if(400 to 500)
			item_state = "tempgun_7"
		if(360 to 400)
			item_state = "tempgun_6"
		if(335 to 360)
			item_state = "tempgun_5"
		if(295 to 335)
			item_state = "tempgun_4"
		if(260 to 295)
			item_state = "tempgun_3"
		if(200 to 260)
			item_state = "tempgun_2"
		if(120 to 260)
			item_state = "tempgun_1"
		if(-INFINITY to 120)
			item_state = "tempgun_0"
	icon_state = item_state

/obj/item/gun/energy/temperature/update_icon()
	overlays = 0
	update_temperature()
	update_user()
	update_charge()

/obj/item/gun/energy/temperature/proc/update_user()
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/M = loc
		M.update_inv_back()
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/gun/energy/temperature/proc/update_charge()
	var/charge = cell.charge
	switch(charge)
		if(900 to INFINITY)		overlays += "900"
		if(800 to 900)			overlays += "800"
		if(700 to 800)			overlays += "700"
		if(600 to 700)			overlays += "600"
		if(500 to 600)			overlays += "500"
		if(400 to 500)			overlays += "400"
		if(300 to 400)			overlays += "300"
		if(200 to 300)			overlays += "200"
		if(100 to 202)			overlays += "100"
		if(-INFINITY to 100)	overlays += "0"

// Mimic Gun //
/obj/item/gun/energy/mimicgun
	name = "mimic gun"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse. Why does this one have teeth?"
	icon_state = "disabler"
	ammo_type = list(/obj/item/ammo_casing/energy/mimic)
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	selfcharge = 1
	ammo_x_offset = 3
	var/mimic_type = /obj/item/gun/projectile/automatic/pistol //Setting this to the mimicgun type does exactly what you think it will.
	can_holster = TRUE

/obj/item/gun/energy/mimicgun/newshot()
	var/obj/item/ammo_casing/energy/mimic/M = ammo_type[select]
	M.mimic_type = mimic_type
	..()

/obj/item/gun/energy/detective
	name = "DL-88 energy revolver"
	desc = "A 'modern' take on the classic projectile revolver."
	icon_state = "handgun"
	item_state = null
	modifystate = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/detective, /obj/item/ammo_casing/energy/detective/tracker_warrant)
	/// If true, this gun is tracking something and cannot track another mob
	var/tracking_target_UID
	/// Used to track if the gun is overcharged
	var/overcharged
	/// Yes, this gun has a radio, welcome to 2022
	var/obj/item/radio/headset/Announcer
	/// Used to link back to the pinpointer
	var/linked_pinpointer_UID
	shaded_charge = TRUE
	can_holster = TRUE
	can_fit_in_turrets = FALSE
	can_charge = FALSE
	unique_reskin = TRUE
	charge_sections = 5
	inhand_charge_sections = 3

/obj/item/gun/energy/detective/Initialize(mapload, ...)
	. = ..()
	Announcer = new /obj/item/radio/headset(src)
	Announcer.config(list("Security" = 1))
	options["The Original"] = "handgun"
	options["Golden Mamba"] = "handgun_golden-mamba"
	options["NT's Finest"] = "handgun_nt-finest"
	options["Cancel"] = null

/obj/item/gun/energy/detective/Destroy()
	QDEL_NULL(Announcer)
	return ..()

/obj/item/gun/energy/detective/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ctrl-click to clear active tracked target or clear linked pinpointer.</span>"

/obj/item/gun/energy/detective/CtrlClick(mob/user)
	. = ..()
	if(!isliving(loc)) //don't do this next bit if this gun is on the floor
		return
	var/tracking_target = locateUID(tracking_target_UID)
	if(tracking_target)
		if(alert("Do you want to clear the tracker?", "Tracker reset", "Yes", "No") == "Yes")
			to_chat(user, "<span class='notice'>[src] stops tracking [tracking_target]</span>")
			stop_pointing()
	if(linked_pinpointer_UID)
		if(alert("Do you want to clear the linked pinpointer?", "Pinpointer reset", "Yes", "No") == "Yes")
			to_chat(user, "<span class='notice'>[src] is ready to be linked to a new pinpointer.</span>")
			var/obj/item/pinpointer/crew/C = locateUID(linked_pinpointer_UID)
			C.linked_gun_UID = null
			if(C.mode == MODE_DET)
				C.stop_tracking()
			linked_pinpointer_UID = null

/obj/item/gun/energy/detective/proc/link_pinpointer(pinpointer_UID)
	linked_pinpointer_UID = pinpointer_UID

/obj/item/gun/energy/detective/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message("<span class='notice'>[user] starts [overcharged ? "restoring" : "removing"] the safety limits on [src].</span>", "<span class='notice'>You start [overcharged ? "restoring" : "removing"] the safety limits on [src]</span>")
	if(!I.use_tool(src, user, 10 SECONDS, volume = I.tool_volume))
		user.visible_message("<span class='notice'>[user] stops modifying the safety limits on [src].", "You stop modifying the [src]'s safety limits</span>")
		return
	if(!overcharged)
		overcharged = TRUE
		ammo_type = list(/obj/item/ammo_casing/energy/detective/overcharge)
		update_ammo_types()
		select_fire(user)
	else // Unable to early return due to the visible message at the end
		overcharged = FALSE
		ammo_type = list(/obj/item/ammo_casing/energy/detective, /obj/item/ammo_casing/energy/detective/tracker_warrant)
		update_ammo_types()
		select_fire(user)
	user.visible_message("<span class='notice'>[user] [overcharged ? "removes" : "restores"] the safety limits on [src].", "You [overcharged ? "remove" : "restore" ] the safety limits on [src]</span>")
	update_icon()

/obj/item/gun/energy/detective/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/ammo_box/magazine/detective/speedcharger))
		return
	var/obj/item/ammo_box/magazine/detective/speedcharger/S = I
	if(!S.charge)
		to_chat(user, "<span class='notice'>[S] has no charge to give!</span>")
		return
	if(cell.charge == cell.maxcharge)
		to_chat(user, "<span class='notice'>[src] is already at full power!</span>")
		return
	var/new_speedcharger_charge = cell.give(S.charge)
	S.charge -= new_speedcharger_charge
	S.update_icon()
	update_icon()

/obj/item/gun/energy/detective/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(!overcharged)
		return ..()
	if(prob(clamp((100 - ((cell.charge / cell.maxcharge) * 100)), 10, 70)))	//minimum probability of 10, maximum of 70
		playsound(user, fire_sound, 50, 1)
		visible_message("<span class='userdanger'>[src]'s energy cell overloads!</span>")
		user.apply_damage(60, BURN, pick(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
		user.EyeBlurry(10 SECONDS)
		user.flash_eyes(2, TRUE)
		do_sparks(rand(5, 9), FALSE, src)
		playsound(src, 'sound/effects/bang.ogg', 100, TRUE)
		user.unEquip(src)
		cell.charge = 0 //ha ha you lose
		update_icon()
		return
	return ..()

/obj/item/gun/energy/detective/proc/start_pointing(target_UID)
	tracking_target_UID = target_UID
	Announcer.autosay("Alert: Detective's revolver discharged in tracking mode. Tracking: [locateUID(tracking_target_UID)] at [get_area_name(src)].", src, "Security")
	var/obj/item/pinpointer/crew/C = locateUID(linked_pinpointer_UID)
	if(C)
		C.start_tracking()
		addtimer(CALLBACK(src, .proc/stop_pointing), 1 MINUTES, TIMER_UNIQUE)

/obj/item/gun/energy/detective/proc/stop_pointing()
	if(linked_pinpointer_UID)
		var/obj/item/pinpointer/crew/C = locateUID(linked_pinpointer_UID)
		if(C?.mode == MODE_DET)
			C.stop_tracking()
	tracking_target_UID = null

#undef PLASMA_CHARGE_USE_PER_SECOND
#undef PLASMA_DISCHARGE_LIMIT
