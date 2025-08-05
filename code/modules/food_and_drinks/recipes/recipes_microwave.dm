/datum/recipe/microwave/warmdonkpocket
	duplicate = FALSE
	items = list(
		/obj/item/food/donkpocket
	)
	result = /obj/item/food/warmdonkpocket

/datum/recipe/microwave/reheatwarmdonkpocket
	duplicate = FALSE
	items = list(
		/obj/item/food/warmdonkpocket
	)
	result = /obj/item/food/warmdonkpocket

/// This recipe exists solely so that placing a brain in a microwave destroys it
/// for the purpose of round-removing antag assassination targets. Because an
/// effect can never be inserted into a microwave by hand, one hopes, the recipe
/// itself cannot be completed. However, it accepts a brain as an ingredient, so
/// microwaves can take that as input.
/datum/recipe/microwave/brain_disposal_method
	duplicate = FALSE
	items = list(
		/obj/item/organ/internal/brain,
		/obj/effect
	)
	result = /obj/item/food/badrecipe
