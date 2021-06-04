/*
///////////////////////////////////////
/////////Weapon System///////////////////
///////////////////////////////////////
*/

// MINING LASERS

/obj/item/spacepod_equipment/weaponry/plasmacutterpod  ///Cortador de Plasma
	name = "plasma cutter system"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demloishing solid obstacles."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_plasmacutter"
	projectile_type = /obj/item/projectile/plasma/adv/mech
	shot_cost = 150
	fire_delay = 30
	fire_sound = 'sound/weapons/laser.ogg'

//Actual guns PIU PIU!

/obj/item/spacepod_equipment/weaponry/inmolationpod  ///Proyectil de fuego
	name = "ZFI Immolation Beam System"
	desc = "A weapon for spacepods. Fires beams of extreme heat that set targets on fire."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_laser"
	projectile_type = /obj/item/projectile/beam/immolator
	shot_cost = 200
	fire_delay = 35
	fire_sound = 'sound/weapons/laser3.ogg'
	harmful = TRUE

/obj/item/spacepod_equipment/weaponry/ionsystempod ///Rifle de Iones
	name = "Ion Breach System"
	desc = "A weapon for spacepods. Fires beams of energy that destroy machinery and electrical systems."
	icon_state = "mecha_ion"
	projectile_type = /obj/item/projectile/ion
	shot_cost = 300
	fire_delay = 15
	fire_sound = 'sound/weapons/laser.ogg'
	harmful = TRUE

/obj/item/spacepod_equipment/weaponry/lmgpod /// LMG
	name = "LMG System"
	desc = "A weapon for spacepods design to kill xeno threads."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_uac2"
	projectile_type = /obj/item/projectile/bullet/weakbullet3
	shot_cost = 100
	fire_delay = 1 //ES UNA JODIDA LMG
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	harmful = TRUE
/*
///////////////////////////////////////
/////////Misc. System///////////////////
///////////////////////////////////////
*/

/obj/item/fluff/plates_spacepod //Placas de refuerzo
	name = "spacepod reinforced engine"
	desc = "A bunch of plates that can be install near the engine to make it more robust."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_abooster_ccw"
	var/vida = 500
	var/peso = 3
	var/modelo = TRUE
	var/new_name = "heavy duty spacepod"
	var/nuevoicon = "pod_industrial"
	var/pintura = FALSE

/obj/item/fluff/plates_spacepod/velocity //Motor de Velocidad
	name = "spacepod modified engine"
	desc = "A bunch of diagrams on how to make it faster but more easy to break."
	icon = 'icons/obj/paintkit.dmi'
	icon_state = "paintkit"
	vida = 60
	peso = 1
	new_name = "light burst spacepod"
	nuevoicon = "pod_black"

/obj/item/fluff/plates_spacepod/basic_engine //Motor de Velocidad
	name = "spacepod standard engine"
	desc = "A bunch of diagrams on how to revert any changes to your engine."
	icon = 'icons/obj/paintkit.dmi'
	icon_state = "paintkit"
	vida = 250
	peso = 2
	modelo = FALSE
	new_name = "spacepod"
	nuevoicon = "pod_civ"
	pintura = TRUE

/obj/item/fluff/plates_spacepod/afterattack(atom/target, mob/user, proximity, params)
	if(!istype(target, /obj/spacepod))
		to_chat(user, "<span class='warning'>You can't use this on [target]!</span>")
		return
	var/obj/spacepod/pod = target
	if(!pod.unique_model || istype(src, /obj/item/fluff/plates_spacepod/basic_engine))
		to_chat(user, "<span class='notice'>You start to work on [target].</span>")
		if(!do_after(user, 40, target = src))
			return TRUE
		to_chat(user, "<span class='notice'>You install the items on [target] based on the kit blueprints and repair all damage to the pod.</span>")
		pod.health = vida
		pod.move_delay = peso
		pod.unique_model = modelo
		pod.name = new_name
		pod.icon_state = nuevoicon
		pod.can_paint = pintura
		pod.maxhealth = vida
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You can't modify this kind of engine anymore!</span>")
/*
///////////////////////////////////////
/////////Cargo System//////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/sec_cargo/chair_triple //3 personas por space pod
	name = "dual seat system"
	desc = "A system for two more seats for a spacepod."
	icon_state = "sec_cargo_chair"
	occupant_mod = 2

/obj/item/spacepod_equipment/sec_cargo/chair_cuadro  //4 personas por space pod
	name = "triple seat system"
	desc = "A system for three more seats for a spacepod."
	icon_state = "sec_cargo_chair"
	occupant_mod = 3

/*
///////////////////////////////////////
/////////Secondary Cargo System////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/sec_cargo/bs_loot_box //Mucho espacio para cosas
	name = "bluespace loot box system"
	desc = "A prototype bluespace lootbox compartment to store valuables."
	icon_state = "sec_cargo_loot"
	storage_mod = list("slots" = 14, "w_class" = 28)
