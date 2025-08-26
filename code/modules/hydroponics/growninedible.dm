// **********************
// Other harvested materials from plants (that are not food)
// **********************

/// Grown weapons
/obj/item/grown
	name = "grown_weapon"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	resistance_flags = FLAMMABLE
	/// The seed of this plant. Starts as a type path, gets converted to an item on New()
	var/obj/item/seeds/seed = null
	/// The unsorted seed of this plant, if any. Used by the seed extractor.
	var/obj/item/unsorted_seeds/unsorted_seed = null

/obj/item/grown/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	create_reagents(50)

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
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			T.on_new(src)

		if(istype(src, seed.product)) // no adding reagents if it is just a trash item
			seed.prepare_result(src)
		transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5
		add_juice()

/obj/item/grown/Destroy()
	QDEL_NULL(seed)
	return ..()

/obj/item/grown/attackby__legacy__attackchain(obj/item/O, mob/user, params)
	..()
	if(istype(O, /obj/item/plant_analyzer))
		send_plant_details(user)

/obj/item/grown/proc/add_juice()
	if(reagents)
		return 1
	return 0

/obj/item/grown/after_slip(mob/living/carbon/human/H)
	if(!seed)
		return
	for(var/datum/plant_gene/trait/T in seed.genes)
		T.on_slip(src, H)

/obj/item/grown/throw_impact(atom/hit_atom)
	if(!..()) //was it caught by a mob?
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_throw_impact(src, hit_atom)

/obj/item/grown/extinguish_light(force = FALSE)
	if(!force)
		return
	if(seed.get_gene(/datum/plant_gene/trait/glow/shadow))
		return
	set_light(0)

/obj/item/grown/proc/send_plant_details(mob/user)
	var/msg = "<span class='notice'>This is \a </span><span class='name'>[src]</span>\n"
	if(seed)
		msg += seed.get_analyzer_text()
	msg += "</span>"
	to_chat(usr, msg)
	return

/obj/item/grown/attack_ghost(mob/dead/observer/user)
	if(!istype(user)) // Make sure user is actually an observer. Revenents also use attack_ghost, but do not have the toggle plant analyzer var.
		return
	if(user.ghost_flags & GHOST_PLANT_ANALYZER)
		send_plant_details(user)
