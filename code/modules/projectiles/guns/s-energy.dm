/obj/item/weapon/gun/senergy
	icon_state = "lasgun"
	name = "Las gun"
	desc = "A laser gun with removable battery."
	icon = 'icons/obj/guns/senergy.dmi'
	fire_sound_text = "laser blast"
	item_state = "arg"

	var/obj/item/weapon/stock_parts/cell/power_supply //What type of power cell this uses
	var/cell_start = /obj/item/weapon/stock_parts/cell/senergy/lasgun
	var/modifystate = 0
	var/list/ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode)
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/charge_sections = 1
	var/charge_tick = 0
	var/charge_delay = 4
	var/barrel = 0
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/weapon/gun/senergy/emp_act(severity)
	power_supply.use(round(power_supply.charge / severity))
	update_icon()

/obj/item/weapon/gun/senergy/New()
	..()
	if(cell_start)
		power_supply = new cell_start(src)
	else
		power_supply = new(src)
	power_supply.give(power_supply.maxcharge)
	var/obj/item/ammo_casing/energy/shot
	for(var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	update_icon()

/obj/item/weapon/gun/senergy/Destroy()
	return ..()

/obj/item/weapon/gun/senergy/process()
	return

/obj/item/weapon/gun/senergy/attackby(var/obj/item/A as obj, mob/user as mob, params)
	if(istype(A, cell_start))
		if(power_supply)
			to_chat(user, "<span class='notice'>You perform a tactical reload on \the [src], replacing the magazine.</span>")
			power_supply.updateicon()
			power_supply.loc = get_turf(loc)
			power_supply = null
		else
			to_chat(user, "<span class='notice'>You insert the magazine into \the [src].</span>")
		user.remove_from_mob(A)
		power_supply = A
		power_supply.loc = src
		A.update_icon()
		update_icon()
		return 1

/obj/item/weapon/gun/senergy/attack_self(mob/living/user as mob)
	if(power_supply)
		power_supply.updateicon()
		power_supply.loc = get_turf(loc)
		power_supply = null
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
	else
		to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
	update_icon()
	return


/obj/item/weapon/gun/senergy/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, params)
	newshot() //prepare a new shot
	..()

/obj/item/weapon/gun/senergy/can_shoot()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	return power_supply.charge >= shot.e_cost

/obj/item/weapon/gun/senergy/newshot()
	if(!ammo_type || !power_supply)
		return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(power_supply.charge >= shot.e_cost) //if there's enough power in the power_supply cell...
		chambered = shot //...prepare a new shot based on the current ammo type selected
		chambered.newshot()
	return

/obj/item/weapon/gun/senergy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		power_supply.use(shot.e_cost)//... drain the power_supply cell
	chambered = null //either way, released the prepared shot
	return

/obj/item/weapon/gun/senergy/ui_action_click()
	select_fire()

/obj/item/weapon/gun/senergy/proc/select_fire(mob/living/user)
	select++
	if(select > ammo_type.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if(shot.select_name)
		to_chat(user, "<span class='notice'>[src] is now set to [shot.select_name].</span>")
	update_icon()
	return


/obj/item/weapon/gun/senergy/update_icon()
	overlays.Cut()
	if(!power_supply)
		icon_state = "[initial(icon_state)]-no"
	else
		var/ratio = Ceiling((power_supply.charge * charge_sections / power_supply.maxcharge))
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		var/empty = ""
		if(power_supply.charge < shot.e_cost)
			empty = "-e"
			ratio = 0
		icon_state = "[initial(icon_state)][empty]"
		overlays += "[initial(icon_state)]-[shot.select_name]-[ratio]"
		if(barrel)
			if(ratio>0)
				overlays += "[initial(icon_state)]-[shot.select_name]-barrel"
			else
				overlays += "[initial(icon_state)]-[shot.select_name]-barrel-e"
		return


/obj/item/weapon/gun/senergy/suicide_act(mob/user)
	if(can_shoot())
		user.visible_message("<span class='suicide'>[user] is putting the barrel of the [name] in \his mouth.  It looks like \he's trying to commit suicide.</span>")
		sleep(25)
		if(user.l_hand == src || user.r_hand == src)
			user.visible_message("<span class='suicide'>[user] melts \his face off with the [name]!</span>")
			playsound(loc, fire_sound, 50, 1, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			power_supply.use(shot.e_cost)
			update_icon()
			return(FIRELOSS)
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return(OXYLOSS)
	else
		user.visible_message("<span class='suicide'>[user] is pretending to blow \his brains out with the [name]! It looks like \he's trying to commit suicide!</b></span>")
		playsound(loc, 'sound/weapons/empty.ogg', 50, 1, -1)
		return (OXYLOSS)

//////////////////////////////////////
//				guns				//
//////////////////////////////////////
/obj/item/weapon/gun/senergy/AK2381
	name = "Ak-2381"
	desc = "An advance energy gun based of the older Ak-2058."
	cell_start = /obj/item/weapon/stock_parts/cell/senergy/ak
	ammo_type = list(/obj/item/ammo_casing/energy/hardlight, /obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/disabler)
	icon_state = "Ak"
	charge_sections = 4

/obj/item/weapon/gun/senergy/AKarc
	name = "Tesla Rifle"
	desc = "An advance energy gun based of the Ak-2381, it shoots tesla balls."
	cell_start = /obj/item/weapon/stock_parts/cell/senergy/ak
	ammo_type = list(/obj/item/ammo_casing/energy/tesla, /obj/item/ammo_casing/energy/electrode)
//	actions_types = list()
	icon_state = "Akarc"
	charge_sections = 4
	barrel = 1

/obj/item/weapon/gun/senergy/lasgun
	name = "Mk-12"
	desc = "An cheap laser gun."
	cell_start = /obj/item/weapon/stock_parts/cell/senergy/lasgun
	icon_state = "lasgun"

/obj/item/weapon/gun/senergy/SG
	name = "SG-17"
	desc = "A laser rifle used by Sol Gov."
	cell_start = /obj/item/weapon/stock_parts/cell/senergy/lasgun
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser/pulse)
	charge_sections = 3
	icon_state = "SG"
	item_state = "SG"

/obj/item/weapon/gun/senergy/SG/nopulse
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode)

/obj/item/weapon/gun/senergy/car
	name = "IK-59 Laser Carbine"
	desc = "An rather short laser carbine. Uses removable magazines."
	cell_start = /obj/item/weapon/stock_parts/cell/senergy/carbine
	ammo_type = list(/obj/item/ammo_casing/energy/laser)
	charge_sections = 4
	icon_state = "lasercarbine"
	item_state = "laser"
	actions_types = list()

/obj/item/weapon/gun/senergy/pulse
	name = "Rapid Pulse rifle"
	desc = "A very expensive pulse rifle."
	cell_start = /obj/item/weapon/stock_parts/cell/senergy/pulse
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	charge_sections = 1
	icon_state = "pulse"

//////////////////////////////////////
//				mags				//
//////////////////////////////////////

/obj/item/weapon/stock_parts/cell/senergy
	icon = 'icons/obj/guns/senergy.dmi'
	name = "Battery Magazine"
	desc = "It looks like it goes in a gun."
	origin_tech = null
	maxcharge = 25000
	rating = 2

/obj/item/weapon/stock_parts/cell/senergy/updateicon()
	overlays.Cut()
	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		overlays += image('icons/obj/guns/senergy.dmi', "cell-o2")
	else
		overlays += image('icons/obj/guns/senergy.dmi', "cell-o1")

/obj/item/weapon/stock_parts/cell/senergy/ak
	name = "Lasgun battery Magazine"
	desc = "A magasine for the AK-2381."
	icon_state = "akcell"

/obj/item/weapon/stock_parts/cell/senergy/lasgun
	name = "Lasgun battery Magazine"
	desc = "A standard energy cell magizine."

/obj/item/weapon/stock_parts/cell/senergy/pulse
	name = "Pulse battery Magazine"
	desc = "A removable cell for a pulse rifle."
	icon_state = "pulsecell"
	maxcharge = 200000

/obj/item/weapon/stock_parts/cell/senergy/carbine
	name = "Lasgun battery Magazine"
	desc = "A magasine for the IK-59."
	icon_state = "carbine"

//////////////////////////////////////
//				ammo				//
//////////////////////////////////////

/obj/item/ammo_casing/energy/hardlight
	projectile_type = /obj/item/projectile/bullet/hardlight
	select_name = "hard"
	e_cost = 1000

/obj/item/projectile/bullet/hardlight
	damage = 30
	stamina = 20
	armour_penetration = -50
	embed = 0
	sharp = 0

/obj/item/ammo_casing/energy/tesla
	projectile_type = /obj/item/projectile/energy/shock_revolver/russian
	select_name = "tesla"
	e_cost = 2500

/obj/item/projectile/energy/shock_revolver/russian
	damage = 20