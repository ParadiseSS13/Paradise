/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats"
	icon_state = "ionrifle"
	item_state = null	//so the human update icon uses the icon_state instead.
	icon_override = 'icons/mob/in-hand/guns.dmi'
	fire_sound = 'sound/weapons/IonRifle.ogg'
	origin_tech = "combat=2;magnets=4"
	w_class = 5.0
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	projectile_type = "/obj/item/projectile/ion"

/obj/item/weapon/gun/energy/ionrifle/emp_act(severity)
	return

/obj/item/weapon/gun/energy/ionrifle/carbine
	name = "ion carbine"
	desc = "The MK.II Prototype Ion Projector is a lightweight carbine version of the larger ion rifle, built to be ergonomic and efficient."
	icon_state = "ioncarbine"
	item_state = "ioncarbine"
	origin_tech = "combat=4;magnets=4;materials=4"
	w_class = 3
	slot_flags = SLOT_BELT

/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	fire_sound = 'sound/weapons/pulse3.ogg'
	origin_tech = "combat=5;materials=4;powerstorage=3"
	projectile_type = "/obj/item/projectile/energy/declone"


/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "floramut100"
	item_state = "obj/item/gun.dmi"
	fire_sound = 'sound/effects/stealthoff.ogg'
	projectile_type = "/obj/item/projectile/energy/floramut"
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = "floramut"
	var/charge_tick = 0
	var/mode = 0 //0 = mutate, 1 = yield boost

/obj/item/weapon/gun/energy/floragun/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/gun/energy/floragun/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/gun/energy/floragun/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	power_supply.give(1000)
	update_icon()
	return 1

/obj/item/weapon/gun/energy/floragun/attack_self(mob/living/user as mob)
	switch(mode)
		if(0)
			mode = 1
			charge_cost = 1000
			user << "\red The [src.name] is now set to increase yield."
			projectile_type = "/obj/item/projectile/energy/florayield"
			modifystate = "florayield"
		if(1)
			mode = 0
			charge_cost = 1000
			user << "\red The [src.name] is now set to induce mutations."
			projectile_type = "/obj/item/projectile/energy/floramut"
			modifystate = "floramut"
	update_icon()
	return


/obj/item/weapon/gun/energy/floragun/afterattack(obj/target, mob/user, flag)

	if(flag && istype(target,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/tray = target
		if(process_chambered())
			user.visible_message("\red <b> \The [user] fires \the [src] into \the [tray]!</b>")
			Fire(target,user)
		return

	..()

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = 4
	projectile_type = "/obj/item/projectile/meteor"
	cell_type = "/obj/item/weapon/stock_parts/cell/potato"
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in ticks)

	New()
		..()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		return ..()

	process()
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(1000)

	update_icon()
		return


/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	w_class = 1


/obj/item/weapon/gun/energy/mindflayer
	name = "mind flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	projectile_type = "/obj/item/projectile/beam/mindflayer"
	fire_sound = 'sound/weapons/Laser.ogg'

obj/item/weapon/gun/energy/staff/focus
	name = "mental focus"
	desc = "An artefact that channels the will of the user into destructive bolts of force. If you aren't careful with it, you might poke someone's brain out."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "focus"
	item_state = "focus"
	projectile_type = "/obj/item/projectile/forcebolt"
	/*
	attack_self(mob/living/user as mob)
		if(projectile_type == "/obj/item/projectile/forcebolt")
			charge_cost = 200
			user << "\red The [src.name] will now strike a small area."
			projectile_type = "/obj/item/projectile/forcebolt/strong"
		else
			charge_cost = 100
			user << "\red The [src.name] will now strike only a single person."
			projectile_type = "/obj/item/projectile/forcebolt"
	*/

/obj/item/weapon/gun/energy/clown
	name = "HONK Rifle"
	desc = "Clown Planet's finest."
	icon_state = "energy"
	projectile_type = "/obj/item/projectile/clown"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	clumsy_check = 0



/obj/item/weapon/gun/energy/toxgun
	name = "plasma pistol"
	desc = "A specialized firearm designed to fire lethal bolts of toxins."
	icon_state = "toxgun"
	fire_sound = 'sound/effects/stealthoff.ogg'
	w_class = 3.0
	origin_tech = "combat=5;plasmatech=4"
	projectile_type = "/obj/item/projectile/energy/plasma"

/obj/item/weapon/gun/energy/sniperrifle
	name = "L.W.A.P. Sniper Rifle"
	desc = "A rifle constructed of lightweight materials, fitted with a SMART aiming-system scope."
	icon = 'icons/obj/gun.dmi'
	icon_state = "sniper"
	fire_sound = 'sound/weapons/marauder.ogg'
	origin_tech = "combat=6;materials=5;powerstorage=4"
	projectile_type = "/obj/item/projectile/beam/sniper"
	slot_flags = SLOT_BACK
	charge_cost = 2500
	fire_delay = 50
	w_class = 4.0
	var/zoom = 0

/obj/item/weapon/gun/energy/sniperrifle/dropped(mob/user)
	user.client.view = world.view



/*
This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/

/obj/item/weapon/gun/energy/sniperrifle/verb/zoom()
	set category = "Object"
	set name = "Use Sniper Scope"
	set popup_menu = 0
	if(usr.stat || !(istype(usr,/mob/living/carbon/human)))
		usr << "You are unable to focus down the scope of the rifle."
		return
	if(!zoom && usr.get_active_hand() != src)
		usr << "You are too distracted to look down the scope, perhaps if it was in your active hand this might work better"
		return

	if(usr.client.view == world.view)
		if(!usr.hud_used.hud_shown)
			usr.button_pressed_F12(1)	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
		usr.button_pressed_F12(1)
		usr.client.view = 12
		zoom = 1
	else
		usr.client.view = world.view
		if(!usr.hud_used.hud_shown)
			usr.button_pressed_F12(1)
		zoom = 0
	usr << "<font color='[zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>"


/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "According to Nanotrasen accounting, this is mining equipment. It's been modified for extreme power output to crush rocks, but often serves as a miner's first defense against hostile alien life; it's not very powerful unless used in a low pressure environment."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	icon_override = 'icons/mob/in-hand/guns.dmi'
	projectile_type = "/obj/item/projectile/kinetic"
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'
	charge_cost = 5000
	cell_type = "/obj/item/weapon/stock_parts/cell/emproof"
	fire_delay = 16 //Because guncode is bad and you can bug the reload for rapid fire otherwise.
	var/overheat = 0
	var/overheat_time = 16
	var/recent_reload = 1

/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg
	flags = NODROP

/obj/item/weapon/gun/energy/kinetic_accelerator/Fire()
	overheat = 1
	spawn(overheat_time)
		overheat = 0
		recent_reload = 0
	..()

/obj/item/weapon/gun/energy/kinetic_accelerator/emp_act(severity)
	return

/obj/item/weapon/gun/energy/kinetic_accelerator/attack_self(var/mob/living/user/L)
	if(overheat || recent_reload)
		return
	power_supply.give(5000)
	if(!silenced)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else
		usr << "<span class='warning'>You silently charge [src].<span>"
	recent_reload = 1
	update_icon()
	return

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists."
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = 2
	m_amt = 2000
	origin_tech = "combat=2;magnets=2;syndicate=5"
	silenced = 1
	projectile_type = "/obj/item/projectile/energy/bolt"
	fire_sound = 'sound/weapons/Genhit.ogg'
	overheat_time = 20
	fire_delay = 20

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/large
	name = "energy crossbow"
	desc = "A reverse engineered weapon using syndicate technology."
	icon_state = "crossbowlarge"
	w_class = 3
	m_amt = 4000
	origin_tech = "combat=2;magnets=2;syndicate=3" //can be further researched for more syndie tech
	silenced = 0
	projectile_type = "/obj/item/projectile/energy/bolt/large"

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/large/cyborg
	desc = "One and done!"
	icon_state = "crossbowlarge"
	origin_tech = null
	m_amt = 0

/obj/item/weapon/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	modifystate = "plasmacutter"
	origin_tech = "combat=1;materials=3;magnets=2;plasmatech=2;engineering=1"
	projectile_type = /obj/item/projectile/plasma
	fire_sound = 'sound/weapons/laser.ogg'
	flags = CONDUCT | OPENCONTAINER
	attack_verb = list("attacked", "slashed", "cut", "sliced")
	charge_cost = 250
	fire_delay = 10
	icon_override = 'icons/mob/in-hand/guns.dmi'
	can_charge = 0

/obj/item/weapon/gun/energy/plasmacutter/examine(mob/user)
	..()
	if(power_supply)
		user <<"<span class='notice'>[src] is [round(power_supply.percent())]% charged.</span>"

/obj/item/weapon/gun/energy/plasmacutter/attackby(var/obj/item/A, var/mob/user)
	if(istype(A, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/sheet/S = A
		S.use(1)
		power_supply.give(10000)
		user << "<span class='notice'>You insert [A] in [src], recharging it.</span>"
	else if(istype(A, /obj/item/weapon/ore/plasma))
		qdel(A)
		power_supply.give(5000)
		user << "<span class='notice'>You insert [A] in [src], recharging it.</span>"
	else
		..()

/obj/item/weapon/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	icon_state = "adv_plasmacutter"
	modifystate = "adv_plasmacutter"
	origin_tech = "combat=3;materials=4;magnets=3;plasmatech=3;engineering=2"
	projectile_type = /obj/item/projectile/plasma/adv
	fire_delay = 8
	charge_cost = 100

/obj/item/weapon/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	item_state = null
	projectile_type = /obj/item/projectile/beam/disabler
	fire_sound = 'sound/weapons/taser2.ogg'
	cell_type = "/obj/item/weapon/stock_parts/cell"
	charge_cost = 500

/obj/item/weapon/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	var/charge_tick = 0
	var/recharge_time = 2.5

/obj/item/weapon/gun/energy/disabler/cyborg/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/disabler/cyborg/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/gun/energy/disabler/cyborg/process() //Every [recharge_time] ticks, recharge a shot for the cyborg
	if(power_supply.charge == power_supply.maxcharge)
		return 0
	charge_tick++
	if(charge_tick < recharge_time)
		return 0
	charge_tick = 0

	if(!power_supply) return 0 //sanity
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			if(R.cell.use(charge_cost/10)) 		//Take power from the borg...
				power_supply.give(charge_cost)	//... to recharge the shot

	update_icon()
	return 1

// Telegun for Tator RDs

/obj/item/weapon/gun/energy/telegun
	name = "Teleporter Gun"
	desc = "An extremely high-tech bluespace energy gun capable of teleporting targets to far off locations."
	icon_state = "telegun"
	item_state = "ionrifle"
	icon_override = 'icons/mob/in-hand/guns.dmi'
	fire_sound = 'sound/weapons/wave.ogg'
	origin_tech = "combat=6;materials=7;powerstorage=5;bluespace=5;syndicate=4"
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"
	projectile_type = "/obj/item/projectile/energy/teleport"
	charge_cost = 1250

/* 3d printer 'pseudo guns' for borgs */

/obj/item/weapon/gun/energy/printer
	name = "cyborg lmg"
	desc = "A machinegun that fires 3d-printed flachettes slowly regenerated using a cyborg's internal power source."
	icon_state = "l6closed0"
	icon = 'icons/obj/gun.dmi'
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	cell_type = "/obj/item/weapon/stock_parts/cell/secborg"
	projectile_type = "/obj/item/projectile/bullet/midbullet3"
	charge_cost = 200 //Yeah, let's NOT give them a 300 round clip that recharges, 20 is more reasonable and will actually hurt the borg's battery for overuse.
	var/charge_tick = 0
	var/recharge_time = 5

/obj/item/weapon/gun/energy/printer/update_icon()
	return

/obj/item/weapon/gun/energy/printer/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/gun/energy/printer/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/gun/energy/printer/process()
	if(power_supply.charge == power_supply.maxcharge)
		return 0
	charge_tick++
	if(charge_tick < recharge_time)
		return 0
	charge_tick = 0

	if(!power_supply) return 0 //sanity
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			if(R.cell.use(charge_cost/10)) 		//Take power from the borg...
				power_supply.give(charge_cost)	//...to recharge the shot
	return 1