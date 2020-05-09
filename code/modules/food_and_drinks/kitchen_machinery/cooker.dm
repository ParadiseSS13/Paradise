/obj/machinery/cooker
	name = "cooker"
	desc = "You shouldn't be seeing this!"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	var/on = 0
	var/onicon = null
	var/officon = null
	var/openicon = null
	var/thiscooktype = null
	var/burns = 0				// whether a machine burns something - if it does, you probably want to add the cooktype to /snacks/badrecipe
	var/firechance = 0
	var/cooktime = 0
	var/foodcolor = null
	var/has_specials = 0		//Set to 1 if the machine has specials to check, otherwise leave it at 0
	var/upgradeable = 0			//Set to 1 if the machine supports upgrades / deconstruction, or else it will ignore stuff like screwdrivers and parts exchangers

// checks if the snack has been cooked in a certain way
/obj/machinery/cooker/proc/checkCooked(obj/item/reagent_containers/food/snacks/D)
	if(D.cooktype[thiscooktype])
		return 1
	return 0

// Sets the new snack's cooktype list to the same as the old one - no more cooking something in the same machine more than once!
/obj/machinery/cooker/proc/setCooked(obj/item/reagent_containers/food/snacks/oldtypes, obj/item/reagent_containers/food/snacks/newtypes)
	var/ct
	for(ct in oldtypes.cooktype)
		newtypes.cooktype[ct] = oldtypes.cooktype[ct]

// transfers reagents
/obj/machinery/cooker/proc/setRegents(obj/item/reagent_containers/OldReg, obj/item/reagent_containers/NewReg)
	OldReg.reagents.trans_to(NewReg, OldReg.reagents.total_volume)

// check if you can put it in the machine
/obj/machinery/cooker/proc/checkValid(obj/item/check, mob/user)
	if(on)
		to_chat(user, "<span class='notice'>[src] is still active!</span>")
		return 0
	if(istype(check, /obj/item/reagent_containers/food/snacks))
		return 1
	if(istype(check, /obj/item/grab))
		return special_attack(check, user)
	if(has_specials && checkSpecials(check))
		return TRUE
	to_chat(user, "<span class ='notice'>You can only process food!</span>")
	return 0

/obj/machinery/cooker/proc/setIcon(obj/item/copyme, obj/item/copyto)
	copyto.color = foodcolor
	copyto.icon = copyme.icon
	copyto.icon_state = copyme.icon_state
	copyto.overlays += copyme.overlays

/obj/machinery/cooker/proc/turnoff(obj/item/olditem)
	icon_state = officon
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	on = 0
	qdel(olditem)
	return

// Burns the food with a chance of starting a fire - for if you try cooking something that's already been cooked that way
// if burns = 0 then it'll just tell you that the item is already that foodtype and it would do nothing
// if you wanted a different side effect set burns to 1 and override burn_food()
/obj/machinery/cooker/proc/burn_food(mob/user, obj/item/reagent_containers/props)
	var/obj/item/reagent_containers/food/snacks/badrecipe/burnt = new(get_turf(src))
	setRegents(props, burnt)
	to_chat(user, "<span class='warning'>You smell burning coming from the [src]!</span>")
	var/datum/effect_system/smoke_spread/bad/smoke = new    // burning things makes smoke!
	smoke.set_up(5, 0, src)
	smoke.start()
	if(prob(firechance))
		var/turf/location = get_turf(src)
		var/obj/effect/decal/cleanable/liquid_fuel/oil = new(location)
		oil.name = "fat"
		oil.desc = "uh oh, looks like some fat from the [src]"
		oil.loc = location
		location.hotspot_expose(700, 50, 1)
		//TODO have a chance of setting the tile on fire

/obj/machinery/cooker/proc/changename(obj/item/name, obj/item/setme)
	setme.name = "[thiscooktype] [name.name]"
	setme.desc = "[name.desc]. It has been [thiscooktype]"

/obj/machinery/cooker/proc/putIn(obj/item/tocook, mob/chef)
	icon_state = onicon
	to_chat(chef, "<span class='notice'>You put [tocook] into [src].</span>")
	on = 1
	chef.drop_item()
	tocook.loc = src

// Override this with the correct snack type
/obj/machinery/cooker/proc/gettype()
	var/obj/item/reagent_containers/food/snacks/type = new(get_turf(src))
	return type

/obj/machinery/cooker/attackby(obj/item/I, mob/user, params)
	if(upgradeable)
	//Not all cooker types currently support build/upgrade stuff, so not all of it will work well with this
	//Until we decide whether or not we want to bring back the cereal maker or old grill/oven in some form, this initial check will have to suffice
		if(istype(I, /obj/item/storage/part_replacer))
			exchange_parts(user, I)
			return
	if(stat & (NOPOWER|BROKEN))
		return
	if(panel_open)
		to_chat(user, "<span class='warning'>Close the panel first!</span>")
		return
	if(!checkValid(I, user))
		return
	if(!burns)
		if(istype(I, /obj/item/reagent_containers/food/snacks))
			if(checkCooked(I))
				to_chat(user, "<span class='warning'>That is already [thiscooktype], it would do nothing!</span>")
				return
	putIn(I, user)
	sleep(cooktime)
	if(I && I.loc == src)
		//New interaction to allow special foods to be made/cooked via deepfryer without removing original functionality
		//Define the foods/results on the specific machine		--FalseIncarnate
		if(has_specials)						//Checks if the machine has any special recipes that should be checked
			var/special = checkSpecials(I)		//Checks if the inserted item is one of the specials
			if(special)							//If the inserted item is not special, it will skip this and run normally
				cookSpecial(special)			//Handle cooking the item as appropriate
				turnoff(I)						//Shut off the machine and qdel the original item
				return
		if(istype(I, /obj/item/reagent_containers/food/snacks))
			if(checkCooked(I))
				burn_food(user, I)
				turnoff(I)
				return
		var/obj/item/reagent_containers/food/snacks/newfood = gettype()
		setIcon(I, newfood)
		changename(I, newfood)
		if(istype(I, /obj/item/reagent_containers))
			setRegents(I, newfood)
		if(istype(I, /obj/item/reagent_containers/food/snacks))
			setCooked(I, newfood)
		newfood.cooktype[thiscooktype] = 1
		turnoff(I)
		//qdel(I)

/obj/machinery/cooker/crowbar_act(mob/user, obj/item/I)
	if(!upgradeable)
		return
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/cooker/screwdriver_act(mob/user, obj/item/I)
	if(!upgradeable)
		return
	if(default_deconstruction_screwdriver(user, openicon, officon, I))
		return TRUE



/obj/machinery/cooker/proc/special_attack(obj/item/grab/G, mob/user)
	return 0

// MAKE SURE TO OVERRIDE THESE ON THE MACHINE IF IT HAS SPECIAL FOOD INTERACTIONS!
// FAILURE TO OVERRIDE WILL RESULT IN FAILURE TO PROPERLY HANDLE SPECIAL INTERACTIONS!		--FalseIncarnate
/obj/machinery/cooker/proc/checkSpecials(obj/item/I)
	if(!I)
		return 0
	return 0

/obj/machinery/cooker/proc/cookSpecial(var/special)
	return
