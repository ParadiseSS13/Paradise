
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/cell/crap"

/obj/item/weapon/gun/energy/taser/cyborg
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	fire_sound = 'sound/weapons/Taser.ogg'
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/cell/secborg"
	var/charge_tick = 0
	var/recharge_time = 10 //Time it takes for shots to recharge (in ticks)

/obj/item/weapon/gun/energy/taser/cyborg/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/taser/cyborg/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/taser/cyborg/process() //Every [recharge_time] ticks, recharge a shot for the cyborg
	return 1

/obj/item/weapon/gun/energy/taser/cyborg/process_chambered()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell && R.cell.charge >= 250)
			R.cell.use(250)
			in_chamber = new /obj/item/projectile/energy/electrode(src)
			return 1
	return 0


/obj/item/weapon/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires internal, reusable stun cartidges in a revolving cylinder. Holds twice as much ammo as a standard taser."
	icon_state = "stunrevolver"
	fire_sound = "sound/weapons/gunshot.ogg"
	origin_tech = "combat=3;materials=3;powerstorage=2"
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/cell"



/obj/item/weapon/gun/energy/crossbow
	name = "mini energy-crossbow"
	desc = "A weapon favored by many of the syndicates stealth specialists."
	icon_state = "crossbow"
	w_class = 2.0
	item_state = "crossbow"
	m_amt = 2000
	origin_tech = "combat=2;magnets=2;syndicate=5"
	silenced = 1
	fire_sound = 'sound/weapons/Genhit.ogg'
	projectile_type = "/obj/item/projectile/energy/bolt"
	cell_type = "/obj/item/weapon/cell/crap"
	var/charge_tick = 0

/obj/item/weapon/gun/energy/crossbow/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/gun/energy/crossbow/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/crossbow/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(1000)
	return 1

/obj/item/weapon/gun/energy/crossbow/update_icon()
	return

/obj/item/weapon/gun/energy/crossbow/cyborg
	desc = "An energy-based crossbow that draws power from the cyborg's internal energy cell directly."

/obj/item/weapon/gun/energy/crossbow/cyborg/process()
	return 1

/obj/item/weapon/gun/energy/crossbow/cyborg/process_chambered()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell && R.cell.charge >= 250)
			R.cell.use(250)
			in_chamber = new /obj/item/projectile/energy/bolt(src)
			return 1
	return 0

/obj/item/weapon/gun/energy/crossbow/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favored by syndicate carp hunters."
	icon_state = "crossbowlarge"
	silenced = 0
	w_class = 3.0
	force = 10
	m_amt = 4000
	projectile_type = "/obj/item/projectile/energy/bolt/large"


