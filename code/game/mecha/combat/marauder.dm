/obj/mecha/combat/marauder
	desc = "Heavy-duty, combat exosuit, developed after the Durand model. Rarely found among civilian populations."
	name = "Marauder"
	icon_state = "marauder"
	initial_icon = "marauder"
	step_in = 5
	max_integrity = 500
	deflect_chance = 25
	armor = list("melee" = 50, "bullet" = 55, "laser" = 40, "energy" = 30, "bomb" = 30, "bio" = 0, "rad" = 60, "fire" = 100, "acid" = 100)
	max_temperature = 60000
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	infra_luminosity = 3
	operation_req_access = list(ACCESS_CENT_SPECOPS)
	wreckage = /obj/structure/mecha_wreckage/marauder
	add_req_access = 0
	internal_damage_threshold = 25
	force = 45
	max_equip = 5
	starting_voice = /obj/item/mecha_modkit/voice/nanotrasen
	destruction_sleep_duration = 1

/obj/mecha/combat/marauder/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	thrusters_action.Grant(user, src)
	smoke_action.Grant(user, src)
	zoom_action.Grant(user, src)

/obj/mecha/combat/marauder/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	thrusters_action.Remove(user)
	smoke_action.Remove(user)
	zoom_action.Remove(user)

/obj/mecha/combat/marauder/loaded/New()
	..()
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

/obj/mecha/combat/marauder/seraph/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/obj/mecha/combat/marauder/seraph/loaded/New()
	..()//Let it equip whatever is needed.
	var/obj/item/mecha_parts/mecha_equipment/ME
	if(equipment.len)//Now to remove it and equip anew.
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


/obj/mecha/combat/marauder/mauler
	desc = "Heavy-duty, combat exosuit, developed off of the existing Marauder model."
	name = "Mauler"
	icon_state = "mauler"
	initial_icon = "mauler"
	operation_req_access = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/mauler
	starting_voice = /obj/item/mecha_modkit/voice/syndicate

/obj/mecha/combat/marauder/mauler/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
