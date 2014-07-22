/obj/machinery/cooker
	name = "cooker"
	desc = "You shouldn't be seeing this!"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	var/on = 0
	var/onicon = null
	var/officon = null
	var/thiscooktype = null
	var/burns = 0				// whether a machine burns something - if it does, you probably want to add the cooktype to /snacks/badrecipe
	var/firechance = 0
	var/cooktime = 0
	var/foodcolor = null


// checks if the snack has been cooked in a certain way
obj/machinery/cooker/proc/checkCooked(obj/item/weapon/reagent_containers/food/snacks/D)
	if (D.cooktype[thiscooktype])
		return 1
	return 0

// Sets the new snack's cooktype list to the same as the old one - no more cooking something in the same machine more than once!
obj/machinery/cooker/proc/setCooked(obj/item/weapon/reagent_containers/food/snacks/oldtypes, obj/item/weapon/reagent_containers/food/snacks/newtypes)
	var/ct
	for(ct in oldtypes.cooktype)
		newtypes.cooktype[ct] = oldtypes.cooktype[ct]

// transfers reagents
obj/machinery/cooker/proc/setRegents(obj/item/weapon/reagent_containers/OldReg, obj/item/weapon/reagent_containers/NewReg)
	OldReg.reagents.trans_to(NewReg, OldReg.reagents.total_volume)

// check if you can put it in the machine
obj/machinery/cooker/proc/checkValid(obj/item/check, mob/user)
	if(on)
		user << "<span class='notice'>[src] is still active!</span>"
		return 0
	if(istype(check, /obj/item/weapon/grab) || istype(check, /obj/item/tk_grab))
		user << "<span class='warning'>That isn't going to fit.</span>"
		return 0
	if(istype(check, /obj/item/weapon/reagent_containers/glass))
		user << "<span class='warning'>That would probably break [src].</span>"
		return 0
	if(istype(check, /obj/item/weapon/disk/nuclear))
		user << "Central command would kill you if you [thiscooktype] that."
		return 0
	if(istype(check, /obj/item/flag))
		user << "<span class='warning'>That isn't going to fit.</span>"
		return 0
	return 1

obj/machinery/cooker/proc/setIcon(obj/item/copyme, obj/item/copyto)
	copyto.color = foodcolor
	copyto.icon = copyme.icon
	copyto.icon_state = copyme.icon_state
	copyto.overlays += copyme.overlays

obj/machinery/cooker/proc/turnoff(obj/item/olditem)
	icon_state = officon
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	on = 0
	del(olditem)
	return

// Burns the food with a chance of starting a fire - for if you try cooking something that's already been cooked that way
// if burns = 0 then it'll just tell you that the item is already that foodtype and it would do nothing
// if you wanted a different side effect set burns to 1 and override burn()
obj/machinery/cooker/proc/burn(mob/user, obj/item/weapon/reagent_containers/props)
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/burnt = new(get_turf(src))
	setRegents(props, burnt)
	user << "<span class='warning'>You smell burning coming from the [src]!</span>"
	var/datum/effect/effect/system/bad_smoke_spread/smoke = new /datum/effect/effect/system/bad_smoke_spread()    // burning things makes smoke!
	smoke.set_up(5, 0, src)
	smoke.start()
	if (prob(firechance))
		var/turf/location = get_turf(src)
		var/obj/effect/decal/cleanable/liquid_fuel/oil = new(location)
		oil.name = "fat"
		oil.desc = "uh oh, looks like some fat from the [src]"
		oil.loc = location
		location.hotspot_expose(700, 50, 1)
		//TODO have a chance of setting the tile on fire

obj/machinery/cooker/proc/changename(obj/item/name, obj/item/setme)
	setme.name = "[thiscooktype] [name.name]"
	setme.desc = "[name.desc]. It has been [thiscooktype]"

obj/machinery/cooker/proc/putIn(obj/item/tocook, mob/chef)
	icon_state = onicon
	chef << "<span class='notice'>You put [tocook] into [src].</span>"
	on = 1
	chef.drop_item()
	tocook.loc = src

// Override this with the correct snack type
obj/machinery/cooker/proc/gettype()
	var/obj/item/weapon/reagent_containers/food/snacks/type = new(get_turf(src))
	return type

obj/machinery/cooker/attackby(obj/item/I, mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if (!checkValid(I, user))
		return
	if(!burns)
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
			if(checkCooked(I))
				user << "<span class='warning'>That is already [thiscooktype], it would do nothing!</span>"
				return
	putIn(I, user)
	sleep(cooktime)
	if(I && I.loc == src)
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
			if(checkCooked(I))
				burn(user, I)
				turnoff(I)
				return
		var/obj/item/weapon/reagent_containers/food/snacks/newfood = gettype()
		setIcon(I, newfood)
		changename(I, newfood)
		if(istype(I, /obj/item/weapon/reagent_containers))
			setRegents(I, newfood)
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
			setCooked(I, newfood)
		newfood.cooktype[thiscooktype] = 1
		turnoff(I)
		//del(I)



