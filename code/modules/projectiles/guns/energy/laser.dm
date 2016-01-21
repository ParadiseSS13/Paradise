/obj/item/weapon/gun/energy/laser
	name = "laser gun"
	desc = "a basic weapon designed kill with concentrated energy bolts"
	icon_state = "laser"
	item_state = "laser"
	fire_sound = 'sound/weapons/Laser.ogg'
	charge_cost = 760
	w_class = 3.0
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=3;magnets=2"
	projectile_type = "/obj/item/projectile/beam"

/obj/item/weapon/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	projectile_type = "/obj/item/projectile/practice"
	clumsy_check = 0

obj/item/weapon/gun/energy/laser/retro
	name ="retro laser gun"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."


/obj/item/weapon/gun/energy/laser/captain
	name = "captain's antique laser gun"
	icon_state = "caplaser"
	item_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	origin_tech = null

	self_recharge = 1


/obj/item/weapon/gun/energy/laser/cyborg
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"

/obj/item/weapon/gun/energy/laser/cyborg/process()
	return 1

/obj/item/weapon/gun/energy/laser/cyborg/process_chambered()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell && R.cell.charge >= 83)
			R.cell.use(83)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0

/obj/item/weapon/gun/energy/laser/cyborg/emp_act()
	return


/obj/item/weapon/gun/energy/lasercannon
	name = "laser cannon"
	desc = "With the L.A.S.E.R. cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	icon_state = "lasercannon"
	item_state = "laser"
	w_class = 4.0
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	origin_tech = "combat=4;materials=3;powerstorage=3"
	projectile_type = "/obj/item/projectile/beam/heavylaser"

	isHandgun()
		return 0

/obj/item/weapon/gun/energy/lasercannon/mounted
	name = "mounted laser cannon"
	self_recharge = 1
	use_external_power = 1
	recharge_time = 10


/obj/item/weapon/gun/energy/lasercannon/cyborg/process_chambered()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(250)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0

/obj/item/weapon/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts."
	icon_state = "xray"
	fire_sound = 'sound/weapons/laser3.ogg'
	origin_tech = "combat=5;materials=3;magnets=2;syndicate=2"
	projectile_type = "/obj/item/projectile/beam/xray"
	charge_cost = 500


////////Laser Tag////////////////////

/obj/item/weapon/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "Standard issue weapon of the Imperial Guard"
	projectile_type = "/obj/item/projectile/lasertag/blue"
	origin_tech = "combat=1;magnets=2"
	clumsy_check = 0

	self_recharge = 1

/obj/item/weapon/gun/energy/laser/bluetag/special_check(var/mob/living/carbon/human/M)
	if(ishuman(M))
		if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
			return 1
		M << "\red You need to be wearing your laser tag vest!"
	return 0

/obj/item/weapon/gun/energy/laser/redtag
	name = "laser tag gun"
	icon_state = "redtag"
	desc = "Standard issue weapon of the Imperial Guard"
	projectile_type = "/obj/item/projectile/lasertag/red"
	origin_tech = "combat=1;magnets=2"
	clumsy_check = 0

	self_recharge = 1

/obj/item/weapon/gun/energy/laser/redtag/special_check(var/mob/living/carbon/human/M)
	if(ishuman(M))
		if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
			return 1
		M << "\red You need to be wearing your laser tag vest!"
	return 0