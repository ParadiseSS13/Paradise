/obj/mecha/combat/phazon
	name = "Phazon"
	desc = "An experimental, phase-shifting exosuit developed by Nanotrasen's research division."
	icon_state = "phazon"
	initial_icon = "phazon"
	step_in = 2
	step_energy_drain = 3
	normal_step_energy_drain = 3
	max_integrity = 200
	deflect_chance = 30
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, RAD = 50, FIRE = 100, ACID = 75)
	infra_luminosity = 3
	wreckage = /obj/structure/mecha_wreckage/phazon
	//operation_req_access = list()
	internal_damage_threshold = 25
	force = 15
	phase_state = "phazon-phase"

/obj/mecha/combat/phazon/GrantActions(mob/living/user, human_occupant = 0)
	..()
	phasing_action.Grant(user, src)
	switch_damtype_action.Grant(user, src)

/obj/mecha/combat/phazon/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	phasing_action.Remove(user)
	switch_damtype_action.Remove(user)

/obj/mecha/combat/phazon/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/rcd
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/gravcatapult
	ME.attach(src)

/obj/mecha/combat/phazon/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='byond://?src=[UID()];switch_damtype=1'>Change melee damage type</a><br>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/combat/phazon/examine_more(mob/user)
	. = ..()
	. += "<i>The Phazon is an experimental Nanotrasen combat design, using a Bluespace Anomaly Core as its heart. \
	This odd crystal allows the mech to phase part way out of reality, allowing it to pass through walls, floors, and other structures as if they never existed in the first place. \
	Designed by an NT research team, the design has recently been distributed to their science stations for testing and preliminary production.</i>"
	. += ""
	. += "<i>Due to the nature of finding Anomaly Cores, Phazons are exceedingly rare. \
	It seems to hum with stored energy, the edges of its chassis blurry in the eyes of others, even at rest. \
	Early test pilots report strange hallucinations and “visions” after extensive use of the phasing ability.</i>"
