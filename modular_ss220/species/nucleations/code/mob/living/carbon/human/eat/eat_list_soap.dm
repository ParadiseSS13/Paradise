/obj/item/soap/afterattack__legacy__attackchain(atom/target, mob/user, proximity)
	if(!proximity) return
	if(try_item_eat(target, user))
		return FALSE
	. = ..()


//===== Drask food =====
//Soap
/obj/item/soap/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_SOAP
	bites_limit = 6
	nutritional_value = 15
	is_only_grab_intent = TRUE

/obj/item/soap/homemade/Initialize(mapload)
	. = ..()
	nutritional_value = 30

/obj/item/soap/deluxe/Initialize(mapload)
	. = ..()
	nutritional_value = 60

/obj/item/soap/syndie/Initialize(mapload)
	. = ..()
	nutritional_value = 100

/obj/item/soap/nanotrasen/Initialize(mapload)
	. = ..()
	bites_limit = 12
	nutritional_value = 15

/obj/item/soap/ducttape/Initialize(mapload)
	. = ..()
	bites_limit = 2
	nutritional_value = 10
