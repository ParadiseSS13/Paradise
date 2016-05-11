//THE CANCER GOES WILD
//Fully customizable and working VAPE - initially you have choice with 4 carcases (which do nothing) and 3 RDAs
//(which do various amount of smoke clouds)
//This shit need battery for work

var/global/list/obj/item/device/vape/vapes = list()

/obj/item/device/vape
	name = "Vape case"
	desc = "The new, better age of smoking."
	icon = 'icons/obj/vape.dmi'
	icon_state = "vape"
	w_class = 2.0
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=20)
	var/obj/item/weapon/stock_parts/cell/battery = null
	var/obj/item/weapon/RDA/drip = null
	var/use = 25
	var/on = 0
	var/spamcheck = 0					//for spam prevention

/obj/item/device/vape/New()								//Here the whole customization goes
	..()
	vapes += src
	vapes = sortAtom(vapes)
	if(drip)
		drip = new drip(src)
		updateicon()
	if(battery)
		battery = new battery(src)

/obj/item/device/vape/proc/updateicon()					//Here the visible customization goes
	if(!drip)
		icon_state = "[initial(icon_state)][on ? "-on" : ""]"
	else
		icon_state = "[initial(icon_state)][drip.rdain][on ? "-on" : ""]"

/obj/item/device/vape/attackby(obj/item/weapon/C as obj, mob/user as mob, params)  //You can insert batteries and RDAs
	if(istype(C, /obj/item/weapon/stock_parts/cell))
		if(battery)
			to_chat(user, "There is a battery already installed.")
		else
			user.drop_item()
			C.loc = src
			battery = C
			to_chat(user, "You insert the battery.")
	if(istype(C, /obj/item/weapon/RDA))
		if(drip)
			to_chat(user, "There is a RDA already installed.")
		else
			user.drop_item()
			C.loc = src
			to_chat(user, "You insert the RDA.")
			drip = C
	updateicon()

/obj/item/device/vape/attack_self(mob/user)
	if(!battery)
		to_chat(user, "There is no battery in [name]!")
	else if(battery.charge <= 0)
		to_chat(user, "There is no energy in [name]'s battery!")
		return
	else
		on = !on
		updateicon()
	return 1

/obj/item/device/vape/attack(var/mob/living/carbon/M, mob/user as mob, def_zone)
	if (spamcheck)
		to_chat(user, "Recharging vape block...")
		return
	if(battery.charge <= 0)
		on = 0
		updateicon()
		to_chat(user, "Your [name] shuts down due to lack of energy!")
	if(!drip)
		to_chat(user, "You realized that you can't vape without RDA")
		return
	if(M == user)
		to_chat(user, "You inhaling content of [name]...")
		spawn(10)
		if(on)
			battery.charge -= use
			var/datum/effect/system/harmless_smoke_spread/smoke = new   //FATTEST CLOUDS
			smoke.set_up(drip.clouds, 0, usr.loc)
			smoke.start()
			user.visible_message("<span class='notice'>[user] vaping here with [name]!</span>")
			playsound(usr.loc, 'sound/effects/bamf.ogg', 50, 2)
			M.adjustCloneLoss(5)		//Vapers MUST DIE
			spamcheck = 1
			spawn(20)
			spamcheck = 0
		else
			to_chat(user, "You must turn your [name] ON!")
			spamcheck = 1
			spawn(10)
			spamcheck = 0
		return 1
	else
		return ..()
	return 0

/obj/item/device/vape/proc/can_use()
	if(!ismob(loc))
		return 0

	var/mob/M = loc
	if(M.incapacitated())
		return 0
	if((src in M.contents) || ( istype(loc, /turf) && in_range(src, M) ))
		return 1
	else
		return 0


/obj/item/device/vape/verb/verb_remove_RDA()
	set category = "Object"
	set name = "Remove RDA"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		var/obj/item/weapon/RDA/O = locate() in src
		if(O)
			if (istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O)
					to_chat(usr, "<span class='notice'>You remove \the [O] from \the [src].</span>")
					drip = null
					updateicon()
					return
			O.forceMove(get_turf(src))
		else
			to_chat(usr, "<span class='notice'>This [name] does not have a RDA in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/device/vape/verb/verb_remove_battery()
	set category = "Object"
	set name = "Remove Battery"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		if(battery)
			if (istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(battery)
					to_chat(usr, "<span class='notice'>You remove \the [battery] from \the [src].</span>")
					battery.add_fingerprint(usr)
					battery.updateicon()
					on = 0
					updateicon()
					src.battery = null
					return
			battery.forceMove(get_turf(src))
		else
			to_chat(usr, "<span class='notice'>This [name] does not have a battery in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")