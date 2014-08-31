/obj/item/weapon/mining_scanner
	name = "ore detector"
	desc = "A complex device used to locate ore deep underground."
	icon = 'icons/obj/device.dmi'
	icon_state = "forensic0-old" //GET A BETTER SPRITE.
	item_state = "electronic"
//	matter = list("metal" = 150)

	origin_tech = "magnets=1;engineering=1"

/obj/item/weapon/mining_scanner/attack_self(mob/user as mob)

	user << "You begin sweeping \the [src] about, scanning for metal deposits."

	if(!do_after(user,50)) return

	if(!user || !src) return

	var/list/metals = list(
		"surface minerals" = 0,
		"precious metals" = 0,
		"nuclear fuel" = 0,
		"exotic matter" = 0
		)

	for(var/turf/T in oview(3,get_turf(user)))

		if(!T.has_resources)
			continue

		for(var/metal in T.resources)

			var/ore_type

			switch(metal)
				if("silicates" || "carbonaceous rock" || "iron") ore_type = "surface minerals"
				if("gold" || "silver" || "diamond")              ore_type = "precious metals"
				if("uranium")                                    ore_type = "nuclear fuel"
				if("phoron" || "osmium" || "hydrogen")           ore_type = "exotic matter"

			if(ore_type) metals[ore_type] += T.resources[metal]

	user << "\icon[src] \blue The scanner beeps and displays a readout."

	for(var/ore_type in metals)

		var/result = "no sign"

		switch(metals[ore_type])
			if(1 to 50) result = "trace amounts"
			if(51 to 150) result = "significant amounts"
			if(151 to INFINITY) result = "huge quantities"

		user << "- [result] of [ore_type]."