/obj/structure/closet/crate/necropolis/ancient
	name = "ancient supply cache"

/obj/structure/closet/crate/necropolis/ancient/populate_contents()
	new /obj/item/pinpointer/tendril(src) // in pinpointers, with the rest of them
	var/list/common_ore = list(
		/obj/item/stack/ore/uranium,
		/obj/item/stack/ore/silver,
		/obj/item/stack/ore/gold,
		/obj/item/stack/ore/plasma,
		/obj/item/stack/ore/titanium
	)

	for(var/res in common_ore)
		var/obj/item/stack/R = new res(src)
		R.amount = rand(15, 30)

	var/list/rare_ore = list(
		/obj/item/stack/ore/diamond,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stack/sheet/mineral/abductor // few ruins of it often spawn, should be fine.
	)

	for(var/res in rare_ore)
		var/obj/item/stack/R = new res(src)
		R.amount = rand(10, 15) //ash drakes drop 5, this is perfectly fine

	var/list/exquisite_ore = list(
		/obj/item/stack/ore/platinum, // The vetus can have some, as a treat
		/obj/item/stack/ore/iridium,
		/obj/item/stack/ore/palladium
	)

	for(var/ore in exquisite_ore)
		new ore(src, rand(5, 10)) // Don't want mining to step too much on explorer's toes.

/obj/structure/closet/crate/necropolis/ancient/ex_act(severity)
	return

/obj/structure/closet/crate/necropolis/ancient/crusher
	name = "alloyed ancient supply cache"

/obj/structure/closet/crate/necropolis/ancient/crusher/populate_contents()
	. = ..()
	new /obj/item/crusher_trophy/adaptive_intelligence_core(src)

