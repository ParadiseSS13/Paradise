/obj/item/barrel
	name = "barrel"
	desc = "A simple barrel. Caution: may explode when materials inside are volatile."
	w_class = WEIGHT_CLASS_GIGANTIC
	/// Max amount of fluids
	var/max_amount = 250
	/// Internal fluid tank datum
	var/datum/fluid_datum

/obj/item/barrel/Initialize(mapload)
	. = ..()


/obj/item/barrel/examine(mob/user)
	. = ..()
	. += "Can store up to [max_amount] units of a single fluid."

/obj/item/barrel
