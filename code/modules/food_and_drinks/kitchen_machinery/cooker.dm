/obj/machinery/cooker
	name = "cooker"
	desc = "You shouldn't be seeing this!"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 5
	var/on = FALSE
	var/onicon = null
	var/officon = null
	var/openicon = null
	var/thiscooktype = null
	/// whether a machine burns something - if it does, you probably want to add the cooktype to /snacks/badrecipe
	var/burns = FALSE
	var/firechance = 0
	var/cooktime = 0
	var/foodcolor = null
	///Set to TRUE if the machine has specials to check, otherwise leave it at FALSE
	var/has_specials = FALSE
	///Set to TRUE if the machine supports upgrades / deconstruction, or else it will ignore stuff like screwdrivers and parts exchangers
	var/upgradeable = FALSE
	var/datum/looping_sound/kitchen/deep_fryer/soundloop
	/// Time between special attacks
	var/special_attack_cooldown_time = 5 SECONDS
	/// Whether or not a special attack can be performed right now
	var/special_attack_on_cooldown = FALSE

/obj/machinery/cooker/Initialize(mapload)
	. = ..()
	soundloop = new(list(src), FALSE) // cereal machine, screw off

/obj/machinery/cooker/Destroy()
	QDEL_NULL(soundloop)
	return ..()

// checks if the snack has been cooked in a certain way
/obj/machinery/cooker/proc/checkCooked(obj/item/food/D)
	if(D.cooktype[thiscooktype])
		return 1
	return 0

// Sets the new snack's cooktype list to the same as the old one - no more cooking something in the same machine more than once!
/obj/machinery/cooker/proc/setCooked(obj/item/food/oldtypes, obj/item/food/newtypes)
	var/ct
	for(ct in oldtypes.cooktype)
		newtypes.cooktype[ct] = oldtypes.cooktype[ct]

// transfers reagents
/obj/machinery/cooker/proc/setRegents(obj/item/reagent_containers/OldReg, obj/item/reagent_containers/NewReg)
	OldReg.reagents.trans_to(NewReg, OldReg.reagents.total_volume)

/**
 * Perform the special grab interaction.
 * Return TRUE to drop the grab or FALSE to keep the grab afterwards.
 */
/obj/machinery/cooker/proc/special_attack(mob/user, mob/living/carbon/target, obj/item/grab/G)
	to_chat(user, "<span class='alert'>This is ridiculous. You can not fit [target] in this [src].</span>")
	return FALSE

/obj/machinery/cooker/shove_impact(mob/living/target, mob/living/attacker)
	if(special_attack_on_cooldown)
		return FALSE

	if(!on)
		// only do a special interaction if it's actually cooking something
		return FALSE

	. = special_attack_shove(target, attacker)
	addtimer(VARSET_CALLBACK(src, special_attack_on_cooldown, FALSE), special_attack_cooldown_time)

/**
 * Perform a special shove attack.
 * The return value of this proc gets passed up to shove_impact, so returning TRUE will prevent any further shove handling (like knockdown).
 */
/obj/machinery/cooker/proc/special_attack_shove(mob/living/target, mob/living/attacker)
	return FALSE

/**
 * Verify if we would be able to perform our grab attack.
 */
/obj/machinery/cooker/proc/can_grab_attack(obj/item/grab/G, mob/user, verbose = FALSE)
	if(special_attack_on_cooldown)
		return FALSE
	if(!istype(G))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='danger'>Slamming [G.affecting] into [src] might hurt them!</span>")
		return FALSE
	if(!iscarbon(G.affecting))
		if(verbose)
			to_chat(user, "<span class='warning'>You can't shove that in there!</span>")
		return FALSE
	if(G.state < GRAB_AGGRESSIVE)
		if(verbose)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
		return FALSE
	return TRUE

/obj/machinery/cooker/proc/special_attack_grab(obj/item/grab/G, mob/user)
	if(!can_grab_attack(G, user, FALSE))  // do it silently, but still make sure this isn't called without sanity checking first
		return FALSE
	var/result = special_attack(user, G.affecting, G)
	user.changeNext_move(CLICK_CD_MELEE)
	special_attack_on_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, special_attack_on_cooldown, FALSE), special_attack_cooldown_time)
	if(result && !isnull(G) && !QDELETED(G))
		qdel(G)

	return TRUE  // end the attack chain

// check if you can put it in the machine
/obj/machinery/cooker/proc/checkValid(obj/item/check, mob/user)
	if(on)
		to_chat(user, "<span class='notice'>[src] is still active!</span>")
		return FALSE
	if(has_specials && checkSpecials(check))
		return TRUE
	if(istype(check, /obj/item/food) || emagged)
		if(istype(check, /obj/item/disk/nuclear)) //(1984 voice) you will not deep fry the NAD
			to_chat(user, "<span class='notice'>The disk is more useful raw than [thiscooktype].</span>")
			return FALSE
		var/obj/item/disk/nuclear/datdisk = locate() in check
		if(datdisk)
			to_chat(user, "<span class='notice'>You get the feeling that something very important is inside this. Something that shouldn't be [thiscooktype].</span>")
			return FALSE
		if(check.flags & (ABSTRACT | DROPDEL | NODROP)) //you will not deep fry the armblade
			return FALSE
		return TRUE
	to_chat(user, "<span class='notice'>You can only process food!</span>")
	return FALSE

/obj/machinery/cooker/proc/setIcon(obj/item/copyme, obj/item/copyto)
	copyto.color = foodcolor
	copyto.icon = copyme.icon
	copyto.icon_state = copyme.icon_state
	copyto.overlays += copyme.overlays

/obj/machinery/cooker/proc/turnoff(obj/item/olditem)
	icon_state = officon
	soundloop.stop()
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	on = FALSE
	qdel(olditem)
	return

// Burns the food with a chance of starting a fire - for if you try cooking something that's already been cooked that way
// if burns = FALSE then it'll just tell you that the item is already that foodtype and it would do nothing
// if you wanted a different side effect set burns to 1 and override burn_food()
/obj/machinery/cooker/proc/burn_food(mob/user, obj/item/reagent_containers/props)
	var/obj/item/food/badrecipe/burnt = new(get_turf(src))
	setRegents(props, burnt)
	soundloop.stop()
	to_chat(user, "<span class='warning'>You smell burning coming from [src]!</span>")
	var/datum/effect_system/smoke_spread/bad/smoke = new    // burning things makes smoke!
	smoke.set_up(5, FALSE, src)
	smoke.start()
	if(prob(firechance))
		var/turf/location = get_turf(src)
		var/obj/effect/decal/cleanable/liquid_fuel/oil = new(location)
		oil.name = "fat"
		oil.desc = "Uh oh, looks like some fat from [src]!"
		oil.loc = location
		location.hotspot_expose(700, 1)

/obj/machinery/cooker/proc/changename(obj/item/name, obj/item/setme)
	setme.name = "[thiscooktype] [name.name]"
	setme.desc = "[name.desc] It has been [thiscooktype]."

/obj/machinery/cooker/proc/putIn(obj/item/tocook, mob/chef)
	icon_state = onicon
	to_chat(chef, "<span class='notice'>You put [tocook] into [src].</span>")
	soundloop.start()
	on = TRUE
	chef.drop_item()
	tocook.loc = src

// Override this with the correct snack type
/obj/machinery/cooker/proc/gettype()
	var/obj/item/food/type = new(get_turf(src))
	return type

/obj/machinery/cooker/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(upgradeable)
	//Not all cooker types currently support build/upgrade stuff, so not all of it will work well with this
	//Until we decide whether or not we want to bring back the cereal maker or old grill/oven in some form, this initial check will have to suffice
		if(istype(used, /obj/item/storage/part_replacer))
			exchange_parts(user, used)
			return ITEM_INTERACT_COMPLETE
	if(stat & (NOPOWER|BROKEN))
		return ITEM_INTERACT_COMPLETE
	if(panel_open)
		to_chat(user, "<span class='warning'>Close the panel first!</span>")
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/grab))
		if(special_attack_grab(used, user))
			return ITEM_INTERACT_COMPLETE
	if(!checkValid(used, user))
		return ITEM_INTERACT_COMPLETE
	if(!burns)
		if(istype(used, /obj/item/food))
			if(checkCooked(used))
				to_chat(user, "<span class='warning'>That is already [thiscooktype], it would do nothing!</span>")
				return ITEM_INTERACT_COMPLETE
	putIn(used, user)
	for(var/mob/living/L in used.contents) //Emagged cookers - Any mob put in will not survive the trip
		if(L.stat != DEAD)
			if(ispAI(L)) //Snowflake check because pAIs are weird
				var/mob/living/silicon/pai/P = L
				P.death(cleanWipe = TRUE)
			else
				L.death()
		break

	addtimer(CALLBACK(src, PROC_REF(finish_cook), used, user), cooktime)
	return ITEM_INTERACT_COMPLETE

/obj/machinery/cooker/proc/finish_cook(obj/item/I, mob/user, params)
	if(QDELETED(I)) //For situations where the item being cooked gets deleted mid-cook (primed grenades)
		turnoff()
		return
	if(I && I.loc == src)
		//New interaction to allow special foods to be made/cooked via deepfryer without removing original functionality
		//Define the foods/results on the specific machine		--FalseIncarnate
		if(has_specials)						//Checks if the machine has any special recipes that should be checked
			var/special = checkSpecials(I)		//Checks if the inserted item is one of the specials
			if(special)							//If the inserted item is not special, it will skip this and run normally
				cookSpecial(special)			//Handle cooking the item as appropriate
				turnoff(I)						//Shut off the machine and qdel the original item
				return
		if(istype(I, /obj/item/food))
			if(checkCooked(I))
				burn_food(user, I)
				turnoff(I)
				return
		var/obj/item/food/newfood = gettype()
		setIcon(I, newfood)
		changename(I, newfood)
		if(istype(I, /obj/item/reagent_containers))
			setRegents(I, newfood)
		if(istype(I, /obj/item/food))
			setRegents(I, newfood)
			setCooked(I, newfood)
		newfood.cooktype[thiscooktype] = TRUE
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

// MAKE SURE TO OVERRIDE THESE ON THE MACHINE IF IT HAS SPECIAL FOOD INTERACTIONS!
// FAILURE TO OVERRIDE WILL RESULT IN FAILURE TO PROPERLY HANDLE SPECIAL INTERACTIONS!		--FalseIncarnate
/obj/machinery/cooker/proc/checkSpecials(obj/item/I)
	if(!I)
		return 0
	return 0

/obj/machinery/cooker/proc/cookSpecial(special)
	return
