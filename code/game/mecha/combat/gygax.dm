/obj/mecha/combat/gygax
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "Gygax"
	icon_state = "gygax"
	initial_icon = "gygax"
	step_in = 3
	dir_in = 1 //Facing North.
	health = 250
	deflect_chance = 5
	damage_absorption = list("brute"=0.75,"fire"=1,"bullet"=0.8,"laser"=0.7,"energy"=0.85,"bomb"=1)
	max_temperature = 25000
	infra_luminosity = 6
	var/overload = 0
	var/overload_coeff = 2
	wreckage = /obj/effect/decal/mecha_wreckage/gygax
	internal_damage_threshold = 35
	max_equip = 3
	maxsize = 2
	step_energy_drain = 3

/obj/mecha/combat/gygax/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	ME.attach(src)

/obj/mecha/combat/gygax/dark
	desc = "A lightweight exosuit, painted in a dark scheme. This model appears to have some modifications."
	name = "Dark Gygax"
	icon_state = "darkgygax"
	initial_icon = "darkgygax"
	health = 300
	deflect_chance = 15
	damage_absorption = list("brute"=0.6,"fire"=0.8,"bullet"=0.6,"laser"=0.5,"energy"=0.65,"bomb"=0.8)
	max_temperature = 35000
	overload_coeff = 1
	operation_req_access = list(access_syndicate)
	wreckage = /obj/effect/decal/mecha_wreckage/gygax/dark
	max_equip = 4
	maxsize = 2

/obj/mecha/combat/gygax/dark/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)

/obj/mecha/combat/gygax/dark/add_cell(var/obj/item/weapon/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 30000
	cell.maxcharge = 30000


/obj/mecha/combat/gygax/verb/overload()
	set category = "Exosuit Interface"
	set name = "Toggle leg actuators overload"
	set src = usr.loc
	set popup_menu = 0
	if(usr != occupant)
		return
	if(overload)
		overload = 0
		step_in = initial(step_in)
		step_energy_drain = initial(step_energy_drain)
		occupant_message("<font color='blue'>You disable leg actuators overload.</font>")
	else
		overload = 1
		step_in = min(1, round(step_in/2))
		step_energy_drain = step_energy_drain*overload_coeff
		occupant_message("<font color='red'>You enable leg actuators overload.</font>")
	log_message("Toggled leg actuators overload.")

/obj/mecha/combat/gygax/domove(direction)
	if(!..())
		return
	if(overload)
		health--
		if(health < initial(health) - initial(health) / 3)
			overload = 0
			step_in = initial(step_in)
			step_energy_drain = initial(step_energy_drain)
			occupant_message("<font color='red'>Leg actuators damage threshold exceded. Disabling overload.</font>")


/obj/mecha/combat/gygax/get_stats_part()
	var/output = ..()
	output += "<b>Leg actuators overload: [overload?"on":"off"]</b>"
	return output

/obj/mecha/combat/gygax/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=[UID()];toggle_leg_overload=1'>Toggle leg actuators overload</a>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/combat/gygax/Topic(href, href_list)
	..()
	if(href_list["toggle_leg_overload"])
		overload()