/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats"
	icon_state = "ionrifle"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/IonRifle.ogg'
	origin_tech = "combat=2;magnets=4"
	w_class = 5
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	ammo_x_offset = 3
	flight_x_offset = 17
	flight_y_offset = 9

/obj/item/weapon/gun/energy/ionrifle/emp_act(severity)
	return

/obj/item/weapon/gun/energy/ionrifle/carbine
	name = "ion carbine"
	desc = "The MK.II Prototype Ion Projector is a lightweight carbine version of the larger ion rifle, built to be ergonomic and efficient."
	icon_state = "ioncarbine"
	origin_tech = "combat=4;magnets=4;materials=4"
	w_class = 3
	slot_flags = SLOT_BELT
	ammo_x_offset = 2
	flight_x_offset = 18
	flight_y_offset = 11

/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	fire_sound = 'sound/weapons/pulse3.ogg'
	origin_tech = "combat=5;materials=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	ammo_x_offset = 1

/obj/item/weapon/gun/energy/decloner/update_icon()
	..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(power_supply.charge > shot.e_cost)
		overlays += "decloner_spin"

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	item_state = "gun"
	fire_sound = 'sound/effects/stealthoff.ogg'
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = 1
	ammo_x_offset = 1
	selfcharge = 1

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = 4
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = /obj/item/weapon/stock_parts/cell/potato
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	selfcharge = 1

/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = 1

/obj/item/weapon/gun/energy/mindflayer
	name = "\improper Mind Flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)
	ammo_x_offset = 2

/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "In the year 2544, only a year after the discovery of a potentially \
		world-changing substance, now colloquially referred to as plasma, the \
		Nanotrasen-UEG mining conglomerate introduced a prototype of a gun-like \
		device intended for quick, effective mining of plasma in the low \
		pressures of the solar system. Included in this presentation were \
		demonstrations of the gun being fired at collections of rocks contained \
		in vacuumed environments, obliterating them instantly while maintaining \
		the structure of the ores buried within them. Additionally, volunteers \
		were called from the crowd to have the gun used on them, only proving that \
		the gun caused little harm to objects in standard pressure. \n\
		An official from an unnamed, now long dissipated company observed this \
		presentation and offered to share their self-recharger cells, powered \
		by the user's bioelectrical field, another new and unknown technology. \
		They warned that the cells were incredibly experimental and several times \
		had injured workers, but the scientists as Nanotrasen were unable to resist \
		the money-saving potential of self recharging cells. Upon accepting this \
		offer, it took only a matter of days to prove the volatility of these cells, \
		as they exploded left and right whenever inserted into the prototype devices, \
		only throwing more money in the bin. \n\
		Whenever the Nanotrasen scientists were on the edge of giving up, a \
		breakthrough was made by head researcher Miles Parks McCollum, who \
		demonstrated that the cells could be stabilized when exposed to radium \
		then cooled with cryostylane. After this discovery, the low pressure gun, \
		now named the Kinetic Accelerator, was hastily completed and made compatible \
		with the self-recharging cells. As a result of poor testing, the currently \
		used guns lose their charge when not in use, and when two Kinetic Accelerators \
		come in proximity of one another, they will interfere with each other. Despite \
		this, the shoddy guns still see use in the mining of plasma to this day."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = /obj/item/weapon/stock_parts/cell/emproof
	// Apparently these are safe to carry? I'm sure goliaths would disagree.
	needs_permit = 0
	unique_rename = 1
	origin_tech = "combat=3;powerstorage=3;engineering=3"
	weapon_weight = WEAPON_LIGHT
	can_flashlight = 1
	flight_x_offset = 15
	flight_y_offset = 9
	var/overheat_time = 16
	var/holds_charge = FALSE
	var/unique_frequency = FALSE // modified by KA modkits
	var/overheat = FALSE

/obj/item/weapon/gun/energy/kinetic_accelerator/super
	name = "super-kinetic accelerator"
	desc = "An upgraded, superior version of the proto-kinetic accelerator."
	icon_state = "kineticgun_u"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/super)
	overheat_time = 15
	origin_tech = "combat=3;powerstorage=2"

/obj/item/weapon/gun/energy/kinetic_accelerator/hyper
	name = "hyper-kinetic accelerator"
	desc = "An upgraded, even more superior version of the proto-kinetic accelerator."
	icon_state = "kineticgun_h"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/hyper)
	overheat_time = 14
	origin_tech = "combat=4;powerstorage=3"

/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/weapon/gun/energy/kinetic_accelerator/hyper/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/weapon/gun/energy/kinetic_accelerator/New()
	. = ..()
	if(!holds_charge)
		empty()

/obj/item/weapon/gun/energy/kinetic_accelerator/shoot_live_shot()
	. = ..()
	attempt_reload()

/obj/item/weapon/gun/energy/kinetic_accelerator/equipped(mob/user)
	. = ..()
	if(!can_shoot())
		attempt_reload()

/obj/item/weapon/gun/energy/kinetic_accelerator/dropped()
	. = ..()
	if(!holds_charge)
		// Put it on a delay because moving item from slot to hand
		// calls dropped().
		spawn(1)
			if(!ismob(loc))
				empty()

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/empty()
	power_supply.use(5000)
	update_icon()

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/attempt_reload()
	if(overheat)
		return
	overheat = TRUE

	var/carried = 0
	if(!unique_frequency)
		for(var/obj/item/weapon/gun/energy/kinetic_accelerator/K in \
			loc.GetAllContents())

			carried++

		carried = max(carried, 1)
	else
		carried = 1

	spawn(overheat_time * carried)
		reload()
		overheat = FALSE

/obj/item/weapon/gun/energy/kinetic_accelerator/emp_act(severity)
	return

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/reload()
	power_supply.give(5000)
	if(!suppressed)
		playsound(loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else if(ismob(loc))
		to_chat(loc, "<span class='warning'>[src] silently charges up.<span>")
	update_icon()

/obj/item/weapon/gun/energy/kinetic_accelerator/update_icon()
	if(!can_shoot())
		icon_state = "[initial(icon_state)]_empty"
	else
		icon_state = initial(icon_state)

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists."
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = 2
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=2;magnets=2;syndicate=5"
	suppressed = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	weapon_weight = WEAPON_LIGHT
	unique_rename = 0
	overheat_time = 20
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/ninja
	name = "energy dart thrower"
	ammo_type = list(/obj/item/ammo_casing/energy/dart)

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/large
	name = "energy crossbow"
	desc = "A reverse engineered weapon using syndicate technology."
	icon_state = "crossbowlarge"
	w_class = 3
	materials = list(MAT_METAL=4000)
	origin_tech = "combat=2;magnets=2;syndicate=3" //can be further researched for more syndie tech
	suppressed = 0
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/large)

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/large/cyborg
	desc = "One and done!"
	icon_state = "crossbowlarge"
	origin_tech = null
	materials = list()

/obj/item/weapon/gun/energy/kinetic_accelerator/suicide_act(mob/user)
	if(!suppressed)
		playsound(loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	user.visible_message("<span class='suicide'>[user] cocks the [name] and pretends to blow \his brains out! It looks like \he's trying to commit suicide!</b></span>")
	shoot_live_shot()
	return (OXYLOSS)

/obj/item/weapon/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	modifystate = -1
	origin_tech = "combat=1;materials=3;magnets=2;plasmatech=2;engineering=1"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	fire_sound = 'sound/weapons/laser.ogg'
	flags = CONDUCT | OPENCONTAINER
	attack_verb = list("attacked", "slashed", "cut", "sliced")
	force = 12
	sharp = 1
	edge = 1
	can_charge = 0

/obj/item/weapon/gun/energy/plasmacutter/examine(mob/user)
	..()
	if(power_supply)
		to_chat(user, "<span class='notice'>[src] is [round(power_supply.percent())]% charged.</span>")

/obj/item/weapon/gun/energy/plasmacutter/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/sheet/S = A
		S.use(1)
		power_supply.give(10000)
		to_chat(user, "<span class='notice'>You insert [A] in [src], recharging it.</span>")
	else if(istype(A, /obj/item/weapon/ore/plasma))
		qdel(A)
		power_supply.give(5000)
		to_chat(user, "<span class='notice'>You insert [A] in [src], recharging it.</span>")
	else
		..()

/obj/item/weapon/gun/energy/plasmacutter/update_icon()
	return

/obj/item/weapon/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	icon_state = "adv_plasmacutter"
	modifystate = "adv_plasmacutter"
	origin_tech = "combat=3;materials=4;magnets=3;plasmatech=3;engineering=2"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)
	force = 15

/obj/item/weapon/gun/energy/wormhole_projector
	name = "bluespace wormhole projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	item_state = null
	icon_state = "wormhole_projector1"
	var/obj/effect/portal/blue
	var/obj/effect/portal/orange


/obj/item/weapon/gun/energy/wormhole_projector/update_icon()
	icon_state = "wormhole_projector[select]"
	item_state = icon_state
	return

/obj/item/weapon/gun/energy/wormhole_projector/process_chamber()
	..()
	select_fire()

/obj/item/weapon/gun/energy/wormhole_projector/proc/portal_destroyed(obj/effect/portal/P)
	if(P.icon_state == "portal")
		blue = null
		if(orange)
			orange.target = null
	else
		orange = null
		if(blue)
			blue.target = null

/obj/item/weapon/gun/energy/wormhole_projector/proc/create_portal(obj/item/projectile/beam/wormhole/W)
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

/obj/item/weapon/gun/energy/printer
	name = "cyborg lmg"
	desc = "A machinegun that fires 3d-printed flachettes slowly regenerated using a cyborg's internal power source."
	icon_state = "l6closed0"
	icon = 'icons/obj/guns/projectile.dmi'
	cell_type = /obj/item/weapon/stock_parts/cell/secborg
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	can_charge = 0

/obj/item/weapon/gun/energy/printer/update_icon()
	return

/obj/item/weapon/gun/energy/printer/emp_act()
	return

/obj/item/weapon/gun/energy/printer/newshot()
	..()
	robocharge()

/obj/item/weapon/gun/energy/laser/instakill
	name = "instakill rifle"
	icon_state = "instagib"
	item_state = "instagib"
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit."
	ammo_type = list(/obj/item/ammo_casing/energy/instakill)
	force = 60
	origin_tech = null

/obj/item/weapon/gun/energy/laser/instakill/emp_act() //implying you could stop the instagib
	return

/obj/item/weapon/gun/energy/laser/instakill/red
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a red design."
	icon_state = "instagibred"
	item_state = "instagibred"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/red)

/obj/item/weapon/gun/energy/laser/instakill/blue
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a blue design."
	icon_state = "instagibblue"
	item_state = "instagibblue"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/blue)

/obj/item/weapon/gun/energy/clown
	name = "HONK Rifle"
	desc = "Clown Planet's finest."
	icon_state = "disabler"
	ammo_type = list(/obj/item/ammo_casing/energy/clown)
	clumsy_check = 0
	ammo_x_offset = 3

/obj/item/weapon/gun/energy/toxgun
	name = "plasma pistol"
	desc = "A specialized firearm designed to fire lethal bolts of toxins."
	icon_state = "toxgun"
	fire_sound = 'sound/effects/stealthoff.ogg'
	w_class = 3
	origin_tech = "combat=4;plasmatech=3"
	ammo_type = list(/obj/item/ammo_casing/energy/toxplasma)
	shaded_charge = 1

/obj/item/weapon/gun/energy/sniperrifle
	name = "L.W.A.P. Sniper Rifle"
	desc = "A rifle constructed of lightweight materials, fitted with a SMART aiming-system scope."
	icon_state = "esniper"
	origin_tech = "combat=6;materials=5;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/sniper)
	slot_flags = SLOT_BACK
	w_class = 4
	zoomable = TRUE
	zoom_amt = 7 //Long range, enough to see in front of you, but no tiles behind you.
	shaded_charge = 1

/obj/item/weapon/gun/energy/temperature
	name = "temperature gun"
	icon = 'icons/obj/guns/gun_temperature.dmi'
	icon_state = "tempgun_4"
	item_state = "tempgun_4"
	slot_flags = SLOT_BACK
	w_class = 4
	fire_sound = 'sound/weapons/pulse3.ogg'
	desc = "A gun that changes the body temperature of its targets."
	var/temperature = 300
	var/target_temperature = 300
	var/e_cost = 1000
	origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"

	ammo_type = list(/obj/item/ammo_casing/energy/temp)
	selfcharge = 1
	cell_type = /obj/item/weapon/stock_parts/cell

	var/powercost = ""
	var/powercostcolor = ""

	var/emagged = 0			//ups the temperature cap from 500 to 1000, targets hit by beams over 500 Kelvin will burst into flames
	var/dat = ""

/obj/item/weapon/gun/energy/temperature/New()
	..()
	update_icon()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/temperature/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/gun/energy/temperature/newshot()
	..()

/obj/item/weapon/gun/energy/temperature/attack_self(mob/living/user as mob)
	user.set_machine(src)
	update_dat()
	user << browse("<TITLE>Temperature Gun Configuration</TITLE><HR>[dat]", "window=tempgun;size=510x120")
	onclose(user, "tempgun")

/obj/item/weapon/gun/energy/temperature/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		emagged = 1
		to_chat(user, "<span class='caution'>You double the gun's temperature cap! Targets hit by searing beams will burst into flames!</span>")
		desc = "A gun that changes the body temperature of its targets. Its temperature cap has been hacked."

/obj/item/weapon/gun/energy/temperature/Topic(href, href_list)
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

/obj/item/weapon/gun/energy/temperature/process()
	..()
	var/obj/item/ammo_casing/energy/temp/T = ammo_type[select]
	T.temp = temperature
	switch(temperature)
		if(0 to 100)
			T.e_cost = 3000
			powercost = "High"
		if(100 to 250)
			T.e_cost = 2000
			powercost = "Medium"
		if(251 to 300)
			T.e_cost = 1000
			powercost = "Low"
		if(301 to 400)
			T.e_cost = 2000
			powercost = "Medium"
		if(401 to 1000)
			T.e_cost = 3000
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
			var /mob/living/carbon/M = loc
			if(src == M.machine)
				update_dat()
				M << browse("<TITLE>Temperature Gun Configuration</TITLE><HR>[dat]", "window=tempgun;size=510x102")
	return

/obj/item/weapon/gun/energy/temperature/proc/update_dat()
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

/obj/item/weapon/gun/energy/temperature/proc/update_temperature()
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

/obj/item/weapon/gun/energy/temperature/update_icon()
	overlays = 0
	update_temperature()
	update_user()
	update_charge()

/obj/item/weapon/gun/energy/temperature/proc/update_user()
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/M = loc
		M.update_inv_back()
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/weapon/gun/energy/temperature/proc/update_charge()
	var/charge = power_supply.charge
	switch(charge)
		if(9000 to INFINITY)		overlays += "900"
		if(8000 to 9000)			overlays += "800"
		if(7000 to 8000)			overlays += "700"
		if(6000 to 7000)			overlays += "600"
		if(5000 to 6000)			overlays += "500"
		if(4000 to 5000)			overlays += "400"
		if(3000 to 4000)			overlays += "300"
		if(2000 to 3000)			overlays += "200"
		if(1000 to 2002)			overlays += "100"
		if(-INFINITY to 1000)	overlays += "0"

/obj/item/weapon/gun/energy/mimicgun
	name = "mimic gun"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse. Why does this one have teeth?"
	icon_state = "disabler"
	ammo_type = list(/obj/item/ammo_casing/energy/mimic)
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	selfcharge = 1
	ammo_x_offset = 3
	var/mimic_type = /obj/item/weapon/gun/projectile/automatic/pistol //Setting this to the mimicgun type does exactly what you think it will.

/obj/item/weapon/gun/energy/mimicgun/newshot()
	var/obj/item/ammo_casing/energy/mimic/M = ammo_type[select]
	M.mimic_type = mimic_type
	..()
