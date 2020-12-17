/obj/item/gun/energy/kinetic_accelerator/premiumka
	name = "Premium kinetic accelerator"
	desc = "A premium kinetic accelerator fitted with an extended barrel and increased pressure tank."
	icon = 'icons/hispania/obj/guns/energy.dmi'
	icon_state = "premiumgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/premium)

	empty_state = "premiumgun_empty"

/obj/item/ammo_casing/energy/kinetic/premium
	projectile_type = /obj/item/projectile/kinetic/premium

/obj/item/projectile/kinetic/premium
	icon_state = null
	damage = 50
	damage_type = BRUTE
	flag = "bomb"
	range = 4
	log_override = TRUE

//Rapid KA
/obj/item/gun/energy/kinetic_accelerator/premiumka/rapid
	name = "Rapid kinetic accelerator"
	desc = "A Kinetic Accelerator featuring an overclocked charger and a smaller pressure tank."
	icon_state = "rapidka"
	overheat_time = 8
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/premium/rapid)
	max_mod_capacity = 60

	empty_state = "rapidka_empty"

/obj/item/ammo_casing/energy/kinetic/premium/rapid
	projectile_type = /obj/item/projectile/kinetic/premium/rapid

/obj/item/projectile/kinetic/premium/rapid
	name = "Rapid kinetic force"
	damage = 28
	range = 3

//Heavy KA
/obj/item/gun/energy/kinetic_accelerator/premiumka/heavy
	name = "Heavy kinetic accelerator"
	desc = "A robust Kinetic Accelerator capable of shots strongs blasts of kinetic force in close range."
	icon_state = "heavyka"
	flight_x_offset = 12
	flight_y_offset = 11
	overheat_time = 35
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/premium/heavy)
	max_mod_capacity = 30
	knife_x_offset = 15
	knife_y_offset = 8

	empty_state = "heavyka_empty"

/obj/item/ammo_casing/energy/kinetic/premium/heavy
	projectile_type = /obj/item/projectile/kinetic/premium/heavy


/obj/item/projectile/kinetic/premium/heavy
	name = "Heavy kinetic force"
	damage = 170
	range = 2
	pressure_decrease = 0.05


//Precise KA
/obj/item/gun/energy/kinetic_accelerator/premiumka/precise
	name = "Precise kinetic accelerator"
	desc = "A modified Accelerator. This one has been zeroed in with a choked down barrel to give a longer range"
	icon_state = "preciseka"
	flight_x_offset = 16
	flight_y_offset = 13
	overheat_time = 30
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/premium/precise)
	max_mod_capacity = 80
	knife_x_offset = 21
	knife_y_offset = 13
	zoomable = TRUE
	zoom_amt = 7

	empty_state = "preciseka_empty"

/obj/item/ammo_casing/energy/kinetic/premium/precise
	projectile_type = /obj/item/projectile/kinetic/premium/precise

/obj/item/projectile/kinetic/premium/precise
	name = "Precise kinetic force"
	damage = 45
	range = 10

//Modular KA
/obj/item/gun/energy/kinetic_accelerator/premiumka/modular
	name = "Modular kinetic accelerator"
	desc = "A rather bare-bones kinetic accelerator capable of forming to one's preferences."
	icon_state = "modularka"
	flight_x_offset = 15
	flight_y_offset = 21
	overheat_time = 45
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/premium/modular)
	max_mod_capacity = 240
	knife_x_offset = 14
	knife_y_offset = 14

	empty_state = "modularka_empty"

/obj/item/ammo_casing/energy/kinetic/premium/modular
	projectile_type = /obj/item/projectile/kinetic/premium/modular

/obj/item/projectile/kinetic/premium/modular
	name = "Modular kinetic force"
	damage = 15
	range = 3

//BYOKA
/obj/item/gun/energy/kinetic_accelerator/premiumka/byoka
	name = "Custom kinetic accelerator"
	desc = "You're not sure how it's made, but it is truly a kinetic accelerator fit for a clown. Its handle smells faintly of bananas."
	icon_state = "byoka"
	flight_x_offset = 15
	flight_y_offset = 21
	knife_x_offset = 14
	knife_y_offset = 14
	overheat_time = 27
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/premium/byoka)
	max_mod_capacity = 330

/obj/item/ammo_casing/energy/kinetic/premium/byoka
	projectile_type = /obj/item/projectile/kinetic/premium/byoka

/obj/item/projectile/kinetic/premium/byoka
	name = "Odd kinetic force"
	damage = 0
	range = 1

//Bloody KA
/obj/item/gun/energy/kinetic_accelerator/premiumka/bloody
	name = "bloody accelerator"
	desc = "This Kinetic Accelerator are covered in blood and flesh, looks corrupted and cursed."
	icon_state = "bdpka"
	item_state = "kineticgun"
	overheat_time = 9
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/premium/bloody)
	max_mod_capacity = 0
	flags = NODROP

	empty_state = "modularka_empty"

/obj/item/ammo_casing/energy/kinetic/premium/bloody
	projectile_type = /obj/item/projectile/kinetic/premium/bloody

/obj/item/projectile/kinetic/premium/bloody
	name = "bloody kinetic force"
	icon = 'icons/hispania/obj/projectiles.dmi'
	icon_state = "ka_tracer"
	color = "#FF0000"
	damage = 25
	range = 4
	pressure_decrease = 1

