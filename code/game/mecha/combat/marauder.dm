/obj/mecha/combat/marauder
	desc = "Heavy-duty, combat exosuit, developed after the Durand model. Rarely found among civilian populations."
	name = "Marauder"
	icon_state = "marauder"
	initial_icon = "marauder"
	step_in = 5
	health = 500
	deflect_chance = 25
	damage_absorption = list("brute"=0.5,"fire"=0.7,"bullet"=0.45,"laser"=0.6,"energy"=0.7,"bomb"=0.7)
	max_temperature = 60000
	burn_state = LAVA_PROOF
	infra_luminosity = 3
	var/zoom = 0
	var/thrusters = 0
	var/smoke = 5
	var/smoke_ready = 1
	var/smoke_cooldown = 100
	var/datum/effect/system/harmless_smoke_spread/smoke_system = new
	operation_req_access = list(access_cent_specops)
	wreckage = /obj/effect/decal/mecha_wreckage/marauder
	add_req_access = 0
	internal_damage_threshold = 25
	force = 45
	max_equip = 4


/obj/mecha/combat/marauder/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	smoke_system.set_up(3, 0, src)
	smoke_system.attach(src)

/obj/mecha/combat/marauder/seraph
	desc = "Heavy-duty, command-type exosuit. This is a custom model, utilized only by high-ranking military personnel."
	name = "Seraph"
	icon_state = "seraph"
	initial_icon = "seraph"
	operation_req_access = list(access_cent_commander)
	step_in = 3
	health = 550
	wreckage = /obj/effect/decal/mecha_wreckage/seraph
	internal_damage_threshold = 20
	force = 55
	max_equip = 5

/obj/mecha/combat/marauder/seraph/loaded/New()
	..()//Let it equip whatever is needed.
	var/obj/item/mecha_parts/mecha_equipment/ME
	if(equipment.len)//Now to remove it and equip anew.
		for(ME in equipment)
			equipment -= ME
			qdel(ME)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter(src)
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
	operation_req_access = list(access_syndicate)
	wreckage = /obj/effect/decal/mecha_wreckage/mauler

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
	smoke_system.set_up(3, 0, src)
	smoke_system.attach(src)


/obj/mecha/combat/marauder/relaymove(mob/user,direction)
	if(zoom)
		if(world.time - last_message > 20)
			occupant_message("Unable to move while in zoom mode.")
			last_message = world.time
		return 0
	return ..()

/obj/mecha/combat/marauder/Process_Spacemove(var/movement_dir = 0)
	if(..())
		return 1
	if(thrusters && movement_dir && use_power(step_energy_drain))
		return 1
	return 0

/obj/mecha/combat/marauder/verb/toggle_thrusters()
	set category = "Exosuit Interface"
	set name = "Toggle thrusters"
	set src = usr.loc
	set popup_menu = 0
	if(usr != occupant)
		return
	if(occupant)
		if(get_charge() > 0)
			thrusters = !thrusters
			log_message("Toggled thrusters.")
			occupant_message("<font color='[thrusters?"blue":"red"]'>Thrusters [thrusters?"en":"dis"]abled.")


/obj/mecha/combat/marauder/verb/smoke()
	set category = "Exosuit Interface"
	set name = "Smoke"
	set src = usr.loc
	set popup_menu = 0
	if(usr != occupant)
		return
	if(smoke_ready && smoke>0)
		smoke_system.start()
		smoke--
		smoke_ready = 0
		spawn(smoke_cooldown)
			smoke_ready = 1

/obj/mecha/combat/marauder/verb/zoom()
	set category = "Exosuit Interface"
	set name = "Zoom"
	set src = usr.loc
	set popup_menu = 0
	if(usr != occupant)
		return
	if(occupant.client)
		zoom = !zoom
		log_message("Toggled zoom mode.")
		occupant_message("<font color='[zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>")
		if(zoom)
			occupant.client.view = 12
			to_chat(occupant, sound('sound/mecha/imag_enh.ogg',volume=50))
		else
			occupant.client.view = initial(occupant.client.view)



/obj/mecha/combat/marauder/get_stats_part()
	var/output = ..()
	output += {"<b>Smoke:</b> [smoke]
					<br>
					<b>Thrusters:</b> [thrusters?"on":"off"]
					"}
	return output


/obj/mecha/combat/marauder/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=[UID()];toggle_thrusters=1'>Toggle thrusters</a><br>
						<a href='?src=[UID()];toggle_zoom=1'>Toggle zoom mode</a><br>
						<a href='?src=[UID()];smoke=1'>Smoke</a>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/combat/marauder/Topic(href, href_list)
	..()
	if(href_list["toggle_thrusters"])
		toggle_thrusters()
	if(href_list["smoke"])
		smoke()
	if(href_list["toggle_zoom"])
		zoom()