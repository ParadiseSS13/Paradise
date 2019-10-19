// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

// Base type. Subtypes are found in /grown dir.
/obj/item/reagent_containers/food/snacks/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	var/obj/item/seeds/seed = null // type path, gets converted to item on New(). It's safe to assume it's always a seed item.
	var/plantname = ""
	var/bitesize_mod = 0 	// If set, bitesize = 1 + round(reagents.total_volume / bitesize_mod)
	var/splat_type = /obj/effect/decal/cleanable/plant_smudge
	var/can_distill = TRUE //If FALSE, this object cannot be distilled into an alcohol.
	var/distill_reagent //If NULL and this object can be distilled, it uses a generic fruit_wine reagent and adjusts its variables.
	var/wine_flavor //If NULL, this is automatically set to the fruit's flavor. Determines the flavor of the wine if distill_reagent is NULL.
	var/wine_power = 0.1 //Determines the boozepwr of the wine if distill_reagent is NULL. Uses 0.1 - 1.2 not tg's boozepower (divide by 100) else you'll end up with 1000% proof alcohol!
	dried_type = -1 // Saves us from having to define each stupid grown's dried_type as itself. If you don't want a plant to be driable (watermelons) set this to null in the time definition.
	resistance_flags = FLAMMABLE
	origin_tech = "biotech=1"

/obj/item/reagent_containers/food/snacks/grown/New(newloc, var/obj/item/seeds/new_seed = null)
	..()
	if(!tastes)
		tastes = list("[name]" = 1)

	if(new_seed)
		seed = new_seed.Copy()
	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.adjust_potency(50-seed.potency)

	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(dried_type == -1)
		dried_type = type

	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			T.on_new(src, newloc)
		seed.prepare_result(src)
		transform *= TransformUsingVariable(seed.potency, 100, 0.5) //Makes the resulting produce's sprite larger or smaller based on potency!
		add_juice()

/obj/item/reagent_containers/food/snacks/grown/Destroy()
	QDEL_NULL(seed)
	return ..()

/obj/item/reagent_containers/food/snacks/grown/proc/add_juice()
	if(reagents)
		if(bitesize_mod)
			bitesize = 1 + round(reagents.total_volume / bitesize_mod)
		return 1
	return 0

/obj/item/reagent_containers/food/snacks/grown/examine(user)
	. = ..()
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			if(T.examine_line)
				. += T.examine_line

/obj/item/reagent_containers/food/snacks/grown/attackby(obj/item/O, mob/user, params)
	..()
	if(slices_num && slice_path)
		var/inaccurate = TRUE
		if(O.sharp)
			if(istype(O, /obj/item/kitchen/knife) || istype(O, /obj/item/scalpel))
				inaccurate = FALSE

			if(!isturf(loc) || !(locate(/obj/structure/table) in loc) && !(locate(/obj/machinery/optable) in loc) && !(locate(/obj/item/storage/bag/tray) in loc))
				to_chat(user, "<span class='warning'>You cannot slice [src] here! You need a table or at least a tray to do it.</span>")
				return TRUE

			var/slices_lost = 0
			if(!inaccurate)
				user.visible_message("<span class='notice'>[user] slices [src] with [O]!</span>", "<span class='notice'>You slice [src]!</span>")
			else
				user.visible_message("<span class='notice'>[user] crudely slices [src] with [O]!</span>", "<span class='notice'>You crudely slice [src] with your [O]!</span>")
				slices_lost = rand(1, min(1, round(slices_num / 2)))

			var/reagents_per_slice = reagents.total_volume/slices_num
			for(var/i = 1 to (slices_num - slices_lost))
				var/obj/slice = new slice_path (loc)
				reagents.trans_to(slice, reagents_per_slice)
			qdel(src)
			return ..()

	if (istype(O, /obj/item/plant_analyzer))
		var/msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>.\n"
		if(seed)
			msg += seed.get_analyzer_text()
		var/reag_txt = ""
		if(seed)
			for(var/reagent_id in seed.reagents_add)
				var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
				var/amt = reagents.get_reagent_amount(reagent_id)
				reag_txt += "\n<span class='info'>- [R.name]: [amt]</span>"

		if(reag_txt)
			msg += reag_txt
			msg += "<br><span class='info'>*---------*</span>"
		to_chat(user, msg)
	else
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_attackby(src, O, user)


// Various gene procs
/obj/item/reagent_containers/food/snacks/grown/attack_self(mob/user)
	if(seed && seed.get_gene(/datum/plant_gene/trait/squash))
		squash(user)
	..()

/obj/item/reagent_containers/food/snacks/grown/throw_impact(atom/hit_atom)
	if(!..()) //was it caught by a mob?
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_throw_impact(src, hit_atom)
			if(seed.get_gene(/datum/plant_gene/trait/squash))
				squash(hit_atom)

/obj/item/reagent_containers/food/snacks/grown/proc/squash(atom/target)
	var/turf/T = get_turf(target)
	if(ispath(splat_type, /obj/effect/decal/cleanable/plant_smudge))
		if(filling_color)
			var/obj/O = new splat_type(T)
			O.color = filling_color
			O.name = "[name] smudge"
	else if(splat_type)
		new splat_type(T)

	if(trash)
		generate_trash(T)

	visible_message("<span class='warning'>[src] has been squashed.</span>","<span class='italics'>You hear a smack.</span>")
	if(seed)
		for(var/datum/plant_gene/trait/trait in seed.genes)
			trait.on_squash(src, target)

	reagents.reaction(T)
	for(var/A in T)
		if(reagents)
			reagents.reaction(A)

	qdel(src)

/obj/item/reagent_containers/food/snacks/grown/On_Consume()
	if(iscarbon(usr))
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_consume(src, usr)
	..()

/obj/item/reagent_containers/food/snacks/grown/Crossed(atom/movable/AM, oldloc)
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			T.on_cross(src, AM)
	..()

/obj/item/reagent_containers/food/snacks/grown/on_trip(mob/living/carbon/human/H)
	. = ..()
	if(. && seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			T.on_slip(src, H)

// Glow gene procs
/obj/item/reagent_containers/food/snacks/grown/generate_trash(atom/location)
	if(trash && ispath(trash, /obj/item/grown))
		. = new trash(location, seed)
		trash = null
		return
	return ..()

// For item-containing growns such as eggy or gatfruit
/obj/item/reagent_containers/food/snacks/grown/shell/attack_self(mob/user)
	user.unEquip(src)
	if(trash)
		var/obj/item/T = generate_trash()
		user.put_in_hands(T)
		to_chat(user, "<span class='notice'>You open [src]\'s shell, revealing \a [T].</span>")
	qdel(src)
