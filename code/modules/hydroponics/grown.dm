// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

// Base type. Subtypes are found in /grown dir.
/obj/item/food/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	/// The seed of this plant. Starts as a type path, gets converted to an item on New()
	var/obj/item/seeds/seed = null
	/// The unsorted seed of this plant, if any. Used by the seed extractor.
	var/obj/item/unsorted_seeds/unsorted_seed = null
	var/plantname = ""
	var/bitesize_mod = 0 	// If set, bitesize = 1 + round(reagents.total_volume / bitesize_mod)
	var/splat_type = /obj/effect/decal/cleanable/plant_smudge
	var/can_distill = TRUE //If FALSE, this object cannot be distilled into an alcohol.
	var/distill_reagent //If NULL and this object can be distilled, it uses a generic fruit_wine reagent and adjusts its variables.
	var/wine_flavor //If NULL, this is automatically set to the fruit's flavor. Determines the flavor of the wine if distill_reagent is NULL.
	var/wine_power = 0.1 //Determines the boozepwr of the wine if distill_reagent is NULL. Uses 0.1 - 1.2 not tg's boozepower (divide by 100) else you'll end up with 1000% proof alcohol!
	dried_type = -1 // Saves us from having to define each stupid grown's dried_type as itself. If you don't want a plant to be driable (watermelons) set this to null in the time definition.
	origin_tech = "biotech=1"

/obj/item/food/grown/Initialize(mapload, obj/new_seed = null)
	. = ..()
	if(!tastes)
		tastes = list("[name]" = 1)

	if(istype(new_seed, /obj/item/seeds))
		var/obj/item/seeds/S = new_seed
		seed = S.Copy()
	else if(istype(new_seed, /obj/item/unsorted_seeds))
		var/obj/item/unsorted_seeds/S = new_seed
		unsorted_seed = S.Copy()
		seed = S.seed_data.original_seed.Copy()
	else if(seed)
		seed = new seed

	scatter_atom()

	if(dried_type == -1)
		dried_type = type

	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			T.on_new(src)
		seed.prepare_result(src)
		transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5 //Makes the resulting produce's sprite larger or smaller based on potency!
		add_juice()
		if(seed.variant)
			name += " \[[seed.variant]]"

/obj/item/food/grown/Destroy()
	QDEL_NULL(seed)
	return ..()

/obj/item/food/grown/proc/add_juice()
	if(reagents)
		if(bitesize_mod)
			bitesize = 1 + round(reagents.total_volume / bitesize_mod)
		return 1
	return 0

/obj/item/food/grown/examine(user)
	. = ..()
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			if(T.examine_line)
				. += T.examine_line

/obj/item/food/grown/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(slices_num && slice_path)
		var/inaccurate = TRUE
		if(used.sharp)
			if(istype(used, /obj/item/kitchen/knife) || istype(used, /obj/item/scalpel))
				inaccurate = FALSE

			if(!isturf(loc) || !(locate(/obj/structure/table) in loc) && !(locate(/obj/machinery/optable) in loc) && !(locate(/obj/item/storage/bag/tray) in loc))
				to_chat(user, "<span class='warning'>You cannot slice [src] here! You need a table or at least a tray to do it.</span>")
				return ITEM_INTERACT_COMPLETE

			var/slices_lost = 0
			if(!inaccurate)
				user.visible_message(
			"<span class='notice'>[user] slices [src] with [used].</span>",
			"<span class='notice'>You slice [src] with [used].</span>"
				)
			else
				user.visible_message(
					"<span class='notice'>[user] crudely slices [src] with [used], destroying some in the process!</span>",
					"<span class='notice'>You crudely slice [src] with [used], destroying some in the process!</span>"
				)
				slices_lost = rand(1, min(1, round(slices_num / 2)))

			var/reagents_per_slice = reagents.total_volume/slices_num
			for(var/i = 1 to (slices_num - slices_lost))
				var/obj/slice = new slice_path (loc)
				reagents.trans_to(slice, reagents_per_slice)
				slice.scatter_atom()
			qdel(src)
			return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/plant_analyzer))
		send_plant_details(user)
		return ITEM_INTERACT_COMPLETE

	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			if(T.on_attackby(src, used, user))
				return ITEM_INTERACT_COMPLETE

	return NONE


// Various gene procs
/obj/item/food/grown/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(seed && seed.get_gene(/datum/plant_gene/trait/squash))
		squash(user)

/obj/item/food/grown/throw_impact(atom/hit_atom)
	if(!..()) //was it caught by a mob?
		if(seed)
			log_action(locateUID(thrownby), hit_atom, "Thrown [src] at")
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_throw_impact(src, hit_atom)
			if(seed.get_gene(/datum/plant_gene/trait/squash))
				squash(hit_atom)

/obj/item/food/grown/proc/squash(atom/target)
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

/obj/item/food/grown/On_Consume(mob/M, mob/user)
	if(iscarbon(M))
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_consume(src, M)
	..()

/obj/item/food/grown/after_slip(mob/living/carbon/human/H)
	if(!seed)
		return
	for(var/datum/plant_gene/trait/T in seed.genes)
		T.on_slip(src, H)

// Glow gene procs
/obj/item/food/grown/generate_trash(atom/location)
	if(trash && ispath(trash, /obj/item/grown))
		. = new trash(location, seed)
		trash = null
		return
	return ..()

/obj/item/food/grown/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		C.stored_comms["wood"] += 4
		qdel(src)
		return TRUE
	return ..()

// For item-containing growns such as eggy or gatfruit
/obj/item/food/grown/shell/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(!do_after(user, 1.5 SECONDS, target = user))
		return ITEM_INTERACT_COMPLETE

	user.unequip(src)
	if(trash)
		var/obj/item/T = generate_trash()
		user.put_in_hands(T)
		to_chat(user, "<span class='notice'>You deshell [src], revealing \a [T].</span>")
	qdel(src)
	return ITEM_INTERACT_COMPLETE

// Diona Nymphs can eat these as well as weeds to gain nutrition.
/obj/item/food/grown/attack_animal(mob/living/simple_animal/M)
	if(isnymph(M))
		var/mob/living/basic/diona_nymph/D = M
		D.consume(src)
	else
		return ..()

/obj/item/food/grown/proc/log_action(mob/user, atom/target, what_done)
	var/reagent_str = reagents.log_list()
	var/genes_str = "No genes"
	if(seed && length(seed.genes))
		var/list/plant_gene_names = list()
		for(var/thing in seed.genes)
			var/datum/plant_gene/G = thing
			if(G.dangerous)
				plant_gene_names += G.name
		genes_str = english_list(plant_gene_names)

	add_attack_logs(user, target, "[what_done] ([reagent_str] | [genes_str])")

/obj/item/food/grown/extinguish_light(force)
	if(seed.get_gene(/datum/plant_gene/trait/glow/shadow))
		return
	set_light(0)

/obj/item/food/grown/proc/send_plant_details(mob/user)
	var/msg = "<span class='notice'>This is \a </span><span class='name'>[src].</span>\n"
	if(seed)
		msg += seed.get_analyzer_text()
	var/reag_txt = ""
	if(seed)
		for(var/reagent_id in seed.reagents_add)
			var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
			var/amt = reagents.get_reagent_amount(reagent_id)
			reag_txt += "\n<span class='notice'>- [R.name]: [amt]</span>"

	if(reag_txt)
		msg += reag_txt
	to_chat(user, msg)

/obj/item/food/grown/attack_ghost(mob/dead/observer/user)
	if(!istype(user)) // Make sure user is actually an observer. Revenents also use attack_ghost, but do not have the toggle plant analyzer var.
		return
	if(user.ghost_flags & GHOST_PLANT_ANALYZER)
		send_plant_details(user)

/obj/item/food/grown/fire_act()
	if(!..()) //Checks for if its unburnable
		return
	if(!reagents)
		return
	var/datum/effect_system/smoke_spread/bad/smoke = new()
	var/smokes_to_make = clamp(round(reagents.total_volume / 10), 1, 10) //Each grown object can make up to 10 smokes each but the global limit stops it from getting too laggy
	smoke.set_up(smokes_to_make, FALSE, src, null, reagents)
	smoke.start()
