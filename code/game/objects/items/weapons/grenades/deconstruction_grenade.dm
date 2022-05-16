/obj/item/grenade/deconstruction
	name = "R3 material repossession device"
	desc = "Designed by NT to remove unwanted constructions from their stations, and reclaim the materials from it. Can be configured to deconstruct walls and windows as well."
	atom_say_verb = "beeps"
	bubble_icon = "swarmer"
	det_time = 10 SECONDS //While an antag can (and will) use this, because of the suddden deconstruction with it primarly being an engineering tool, longer prime time.
	var/obj/item/assembly/signaler/anomaly/grav/core = null
	var/recycle = FALSE //If true, it will consume all the building materials dropped from deconstruction that have mineral value, and recycle them. A configureable option, incase someone wants the stock parts or something else inside.
	var/consume_all = FALSE //If true, this will consumue EVERY ITEM that is not indestructable. Good for cleaning... or sabatoge.
	var/deconstrtuct_walls = FALSE
	var/deconstruct_doors = FALSE
	var/deconstruct_windows = FALSE
	var/on_cooldown = FALSE

/obj/item/grenade/deconstruction/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_PLASMA, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_PLASTIC, MAT_BLUESPACE), 0, TRUE, null, null, null, TRUE)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = 150000 //stack is 100000, so yeah. Should be fine.

/obj/item/grenade/deconstruction/attack_self(mob/user as mob)
	if(!core)
		atom_say("ERROR. No vortex core detected. Activation faliure.")
		return
	if(active)
		unprime()
		atom_say("Repossession cancled. Have a Nanotrasen Day.")
		return
	else if(on_cooldown)
		atom_say("Internal capacitors still recharging. Please hold.")
		return
	else
		atom_say("Area repossession commencing. Please clear the area.") // sound / visuals after
	return ..()

/obj/item/grenade/deconstruction/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/assembly/signaler/anomaly/grav))
		if(core)
			to_chat(user, "<span class='notice'>[src] already has a [O]!</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[O] is stuck to your hand!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [O] into [src], and [src] starts to warm up.</span>")
		O.forceMove(src)
		core = O
		update_icon()

/obj/item/grenade/deconstruction/prime()
	if(get_turf(src) == level_name_to_num(CENTCOMM))
		atom_say("Activation denied: Area does not need repossession ")
		unprime()
		return
	deconstruct_obj(3)
	unprime()
	addtimer(CALLBACK(src, .proc/reboot), 60 SECONDS)
	on_cooldown = TRUE

/obj/item/grenade/deconstruction/proc/deconstruct_obj(loops = 0) //We want structures fully deconstructed, no frames or anything, so multiple go arounds.
	for(var/turf/T in view(7, src))
	for(var/obj/O in view(7, src))
		if(istype(O, /obj/item))
			continue
		if(O.resistance_flags & INDESTRUCTIBLE)
			continue
		if(safety_check(O) && !emagged)
			continue
		O.deconstruct(TRUE)
	if(loops)
		deconstruct_obj(loops -= 1)
	else if(recycle || consume_all)
		deconstruct_items()

/obj/item/grenade/deconstruction/proc/deconstruct_items()
	for(var/obj/item/I in oview(7, src))
		if(I.resistance_flags & INDESTRUCTIBLE) //No eating objective items, thank you.
			continue
		if(length(I.materials) || consume_all)
			I.forceMove(loc)
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/material_amount = materials.get_item_material_amount(I)
			if(!material_amount)
				qdel(I)
				continue
			materials.insert_item(I, multiplier = 0.95) //Slight material loss, but still incredibly good.
			qdel(I)
			materials.retrieve_all()

/obj/item/grenade/deconstruction/proc/safety_check(var/atom/A)
	for(var/turf/T in range(1, src))
		var/area/A = get_area(T)
		if(isspaceturf(T) || (!isonshuttle && (istype(A, /area/shuttle) || istype(A, /area/space))) || (isonshuttle && !istype(A, /area/shuttle)))
			return TRUE

/obj/item/grenade/deconstruction/proc/reboot()
	on_cooldown = FALSE
	atom_say("Capacitors charged. Atomic repossession system rebooted.")


//TODO: CONFIGURE VISUALS / NOISE, OPTION TO DECON WALLS / WINDOWS / DOORS (MAYBE ATMOS SWARMER CHECK) RESPECT WALL VISION IF WALLS OFF.
