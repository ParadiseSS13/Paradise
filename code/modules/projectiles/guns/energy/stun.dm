
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"
	fire_delay = 15

/obj/item/weapon/gun/energy/taser/mounted
	name = "mounted taser gun"
	self_recharge = 1
	use_external_power = 1

/obj/item/weapon/gun/energy/taser/cyborg
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	fire_sound = 'sound/weapons/Taser.ogg'
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/stock_parts/cell/secborg"

	self_recharge = 1
	recharge_time = 10 //Time it takes for shots to recharge (in ticks)

/obj/item/weapon/gun/energy/shock_revolver
	name = "tesla revolver"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers."
	icon_state = "stunrevolver"
	item_state = "gun"
	fire_sound = 'sound/weapons/gunshot.ogg'
	projectile_type = "/obj/item/projectile/shock_revolver"
	charge_cost = 2000
	can_flashlight = 0

/obj/item/projectile/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	var/chain

/obj/item/projectile/shock_revolver/OnFired()
	spawn(1)
		chain = Beam(firer, icon_state="purple_lightning", icon = 'icons/effects/effects.dmi',time=1000, maxdistance = 30)

/obj/item/projectile/shock_revolver/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		tesla_zap(src, 3, 10000)
	qdel(chain)

/obj/item/weapon/gun/energy/crossbow
	name = "mini energy-crossbow"
	desc = "A weapon favored by many of the syndicates stealth specialists."
	icon_state = "crossbow"
	w_class = 2.0
	item_state = "crossbow"
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=2;magnets=2;syndicate=5"
	silenced = 1
	fire_sound = 'sound/weapons/Genhit.ogg'
	projectile_type = "/obj/item/projectile/energy/bolt"
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"

	self_recharge = 1

/obj/item/weapon/gun/energy/crossbow/ninja
	name = "energy dart thrower"
	projectile_type = /obj/item/projectile/energy/dart

/obj/item/weapon/gun/energy/crossbow/update_icon()
	return
/obj/item/weapon/gun/energy/crossbow/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favored by syndicate carp hunters."
	icon_state = "crossbowlarge"
	silenced = 0
	w_class = 3.0
	force = 10
	materials = list(MAT_METAL=4000)
	projectile_type = "/obj/item/projectile/energy/bolt/large"


