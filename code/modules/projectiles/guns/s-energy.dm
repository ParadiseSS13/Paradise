/obj/item/weapon/gun/projectile/automatic/senergy
	icon_state = "lasgun"
	name = "Las gun"
	desc = "A laser gun with removable battery."
	icon = 'icons/obj/guns/senergy.dmi'
	fire_sound_text = "laser blast"
	fire_sound = 'sound/weapons/Laser.ogg'
	icon_state = "lasgun"
	item_state = "arg"
	can_suppress = 0
	burst_size = 1
	fire_delay = 5
	var/list/ammo_types = list(/obj/item/ammo_casing/caseless/energy/stun,/obj/item/ammo_casing/caseless/energy)
	var/list/ammo_name = list("stun","kill")
	select = 1
	var/charge_sections = 4
	var/charge_tick = 0
	var/charge_delay = 4
	var/shot = null
	actions_types = list(/datum/action/item_action/toggle_firemode)
	mag_type = /obj/item/ammo_box/magazine/energy
	var/empty = null
	var/ratio = null

/obj/item/weapon/gun/projectile/automatic/senergy/New()
	..()
	shot = ammo_name[select]
	ammo_change()
	update_icon()

/obj/item/weapon/gun/projectile/automatic/senergy/ui_action_click()
	select_fire()

/obj/item/weapon/gun/projectile/automatic/senergy/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()
	ammo_change()


/obj/item/weapon/gun/projectile/automatic/senergy/proc/ammo_change()
	if(chambered.BB != ammo_types[select])
		var/temp = ammo_types[select]
		chambered = new temp(src)
		fire_sound = chambered.fire_sound
	return

/obj/item/weapon/gun/projectile/automatic/senergy/proc/select_fire(mob/living/user)
	select++
	if(select > ammo_types.len)
		select = 1
	ammo_change()
	shot = ammo_name[select]
	to_chat(user, "<span class='notice'>[src] is now set to [shot].</span>")
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/senergy/update_icon()
	overlays.Cut()
	if(!magazine)
		empty = "-e"
		ratio = 0
	else
		ratio = Ceiling((magazine.ammo_count()*charge_sections/magazine.max_ammo))
		empty = ""
	icon_state = "[initial(icon_state)][empty]"
	overlays += "[initial(icon_state)]-[shot]-[ratio]"
	return

/obj/item/weapon/gun/projectile/automatic/senergy/attackby(var/obj/item/A as obj, mob/user as mob, params)
	..()
	ammo_change()

//////////////////////////////////////
//				guns				//
//////////////////////////////////////

/obj/item/weapon/gun/projectile/automatic/senergy/car
	name = "IK-59 Laser Carbine"
	desc = "An rather short laser carbine. Uses removable magazines."
	mag_type = /obj/item/ammo_box/magazine/energy/car
	ammo_types = list(/obj/item/ammo_casing/caseless/energy)
	ammo_name = list("kill")
	charge_sections = 4
	icon_state = "lasercarbine"
	item_state = "laser"
	actions_types = list()

/obj/item/weapon/gun/projectile/automatic/senergy/SG
	name = "SG-17"
	desc = "A laser rifle used by Sol Gov for space operations."
	mag_type = /obj/item/ammo_box/magazine/energy/SG
	charge_sections = 3
	icon_state = "SG"

/obj/item/weapon/gun/projectile/automatic/senergy/lasgun
	name = "Mark 5 Laser Carbine"
	desc = "For the Emperor"
	mag_type = /obj/item/ammo_box/magazine/energy/SG
//////////////////////////////////////
//				mags				//
//////////////////////////////////////

/obj/item/ammo_box/magazine/energy
	name = "power pack"
	ammo_type = /obj/item/ammo_casing/caseless/energy
	icon_state = "lasgun"
	caliber = "energy"
	max_ammo = 20
	var/charge = 1
	var/energy = 1000

/obj/item/ammo_box/magazine/energy/update_icon()
	desc = "[initial(desc)] It has [stored_ammo.len] shot\s left."
	icon_state = "[initial(icon_state)]-[Ceiling((ammo_count()*2/max_ammo))]"


/obj/item/ammo_box/magazine/energy/attack_self()
 	return

/obj/item/ammo_box/magazine/energy/SG

/obj/item/ammo_box/magazine/energy/car
	icon_state = "car_bat"
//////////////////////////////////////
//				ammo				//
//////////////////////////////////////

/obj/item/ammo_casing/caseless/energy
	desc = "An energy unit."
	caliber = "energy"
	projectile_type = /obj/item/projectile/beam/laser
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/ammo_casing/caseless/energy/stun
	desc = "An energy unit."
	caliber = "energy"
	projectile_type = /obj/item/projectile/energy/electrode
	fire_sound = 'sound/weapons/taser.ogg'