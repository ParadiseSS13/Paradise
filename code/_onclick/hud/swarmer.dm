
////HUD NONSENSE////
/obj/screen/swarmer
	icon = 'icons/mob/swarmer.dmi'

/obj/screen/swarmer/FabricateTrap
	icon_state = "ui_trap"
	name = "Crear una trampa (Cuesta 5 recursos)"
	desc = "Creates a trap that will nonlethally shock any non-swarmer that attempts to cross it. (Cuesta 5 recursos)"

/obj/screen/swarmer/FabricateTrap/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateTrap()

/obj/screen/swarmer/Barricade
	icon_state = "ui_barricade"
	name = "Crear una barricada (Cuesta 5 recursos)"
	desc = "Crea una barricada destruible que prohibira a cualquiera no swarmer atravesarla. Ademas, permite que los disparos de disabler la atraviesen. (Cuesta 5 recursos)"

/obj/screen/swarmer/Barricade/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateBarricade()

/obj/screen/swarmer/Replicate
	icon_state = "ui_replicate"
	name = "Replicar (Cuesta 50 recursos)"
	desc = "Crea a otro de nuestro tipo."

/obj/screen/swarmer/Replicate/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateSwarmer()

/obj/screen/swarmer/RepairSelf
	icon_state = "ui_self_repair"
	name = "Auto Repararse"
	desc = "Repara los danos de nuestro cuerpo."

/obj/screen/swarmer/RepairSelf/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.RepairSelf()

/obj/screen/swarmer/ToggleLight
	icon_state = "ui_light"
	name = "Linterna"
	desc = "Enciende o apaga nuestra luz exterior."

/obj/screen/swarmer/ToggleLight/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ToggleLight()

/obj/screen/swarmer/ContactSwarmers
	icon_state = "ui_contact_swarmers"
	name = "Contactar con Swarmers"
	desc = "Envia un mensaje a todos los demas swarmers, deberian existir."

/obj/screen/swarmer/ContactSwarmers/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ContactSwarmers()

/mob/living/simple_animal/hostile/swarmer/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/swarmer(src)

/datum/hud/swarmer/New(mob/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/swarmer/FabricateTrap()
	using.screen_loc = ui_rhand
	static_inventory += using

	using = new /obj/screen/swarmer/Barricade()
	using.screen_loc = ui_lhand
	static_inventory += using

	using = new /obj/screen/swarmer/Replicate()
	using.screen_loc = ui_zonesel
	static_inventory += using

	using = new /obj/screen/swarmer/RepairSelf()
	using.screen_loc = ui_storage1
	static_inventory += using

	using = new /obj/screen/swarmer/ToggleLight()
	using.screen_loc = ui_back
	static_inventory += using

	using = new /obj/screen/swarmer/ContactSwarmers()
	using.screen_loc = ui_inventory
	static_inventory += using

