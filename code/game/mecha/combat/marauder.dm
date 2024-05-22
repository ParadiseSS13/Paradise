/obj/mecha/combat/marauder
	desc = "Heavy-duty, combat exosuit, developed after the Durand model. Rarely found among civilian populations."
	name = "Marauder"
	icon_state = "marauder"
	initial_icon = "marauder"
	step_in = 5
	max_integrity = 500
	deflect_chance = 25
	armor = list(MELEE = 50, BULLET = 55, LASER = 40, ENERGY = 30, BOMB = 30, RAD = 60, FIRE = 100, ACID = 100)
	max_temperature = 60000
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	infra_luminosity = 3
	operation_req_access = list(ACCESS_CENT_SPECOPS)
	wreckage = /obj/structure/mecha_wreckage/marauder
	add_req_access = 0
	internal_damage_threshold = 25
	force = 45
	max_equip = 6
	starting_voice = /obj/item/mecha_modkit/voice/nanotrasen
	destruction_sleep_duration = 2 SECONDS
	emag_proof = TRUE //no stealing CC mechs.

/obj/mecha/combat/marauder/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	smoke_action.Grant(user, src)
	zoom_action.Grant(user, src)

/obj/mecha/combat/marauder/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	smoke_action.Remove(user)
	zoom_action.Remove(user)

/obj/mecha/combat/marauder/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/xray(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/thrusters
	ME.attach(src)

/obj/mecha/combat/marauder/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/obj/mecha/combat/marauder/ares
	name = "Ares"
	desc = "Heavy-duty, combat exosuit, adapted from rejected early versions of the Marauder to serve as a biohazard containment exosuit. This model, albeit rare, can be found among civilian populations."
	icon_state = "ares"
	initial_icon = "ares"
	operation_req_access = list(ACCESS_SECURITY)
	max_integrity = 450
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	armor = list(melee = 50, bullet = 40, laser = 20, energy = 20, bomb = 20, rad = 60, fire = 100, acid = 75)
	max_temperature = 40000
	wreckage = /obj/structure/mecha_wreckage/ares
	max_equip = 5
	emag_proof = FALSE //Gamma armory can be stolen however.

/obj/mecha/combat/marauder/ares/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/xray(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/thrusters
	ME.attach(src)

/obj/mecha/combat/marauder/seraph
	desc = "Heavy-duty, command-type exosuit. This is a custom model, utilized only by high-ranking military personnel."
	name = "Seraph"
	icon_state = "seraph"
	initial_icon = "seraph"
	operation_req_access = list(ACCESS_CENT_COMMANDER)
	step_in = 3
	max_integrity = 550
	wreckage = /obj/structure/mecha_wreckage/seraph
	internal_damage_threshold = 20
	force = 80
	max_equip = 8

/obj/mecha/combat/marauder/seraph/loaded/Initialize(mapload)
	. = ..()  //Let it equip whatever is needed.
	var/obj/item/mecha_parts/mecha_equipment/ME
	if(length(equipment))//Now to remove it and equip anew.
		for(ME in equipment)
			equipment -= ME
			qdel(ME)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/xray/triple(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/dual(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter/precise(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/thrusters
	ME.attach(src)

/obj/mecha/combat/marauder/mauler
	desc = "Heavy-duty, combat exosuit, developed off of the existing Marauder model."
	name = "Mauler"
	icon_state = "mauler"
	initial_icon = "mauler"
	operation_req_access = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/mauler
	starting_voice = /obj/item/mecha_modkit/voice/syndicate
	emag_proof = FALSE //The crew can steal a syndicate mech. As a treat.

/obj/mecha/combat/marauder/mauler/trader
	operation_req_access = list() //Jailbroken mech

/obj/mecha/combat/marauder/mauler/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/thrusters
	ME.attach(src)
