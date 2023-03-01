//Mantles!

/obj/item/clothing/neck/mantle
	name = "mantle"
	desc = "A heavy quilted mantle, for keeping your shoulders warm and stylish."
	icon_state = "mantle"
	body_parts_covered = UPPER_TORSO | ARMS
	cold_protection = UPPER_TORSO | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/neck/mantle/regal
	name = "regal shawl"
	desc = "A fancy shawl for nobility, made from high quality materials."
	icon_state = "regal_mantle"

/obj/item/clothing/neck/mantle/old
	name = "old scarf"
	desc = "A tattered fabric wrap, faded over the years. Smells faintly of cigars."
	icon_state = "old_mantle"

//Mantles of the heads

/obj/item/clothing/neck/mantle/captain
	name = "captain's mantle"
	desc = "An piece of fashion for the ruling elite. Protect your upper half in style."
	icon_state = "capmantle"

/obj/item/clothing/neck/mantle/chief_engineer
	name = "chief engineer's mantle"
	desc = "A slick, authoritative cloak designed for the Chief Engineer."
	icon_state = "cemantle"

/obj/item/clothing/neck/mantle/chief_medical_officer
	name = "chief medical officer's mantle"
	desc = "An absorbent, clean cover found on the shoulders of the Chief Medical Officer."
	icon_state = "cmomantle"

/obj/item/clothing/neck/mantle/head_of_security
	name = "head of security's mantle"
	desc = "A cloak worn by the Head of Security. Do you dare take up their mantle?"
	icon_state = "hosmantle"

/obj/item/clothing/neck/mantle/head_of_personnel
	name = "head of personnel's mantle"
	desc = "An cloak for the head of personnel. It's remarkably well kept."
	icon_state = "hopmantle"

//Research Director
/obj/item/clothing/neck/mantle/research_director
	name = "research director's mantle"
	desc = "A tweed mantle, worn by the Research Director. Smells like science."
	icon_state = "rdmantle"

/obj/item/clothing/neck/mantle/New()
	..()
	AddComponent(/datum/component/spraycan_paintable)
	START_PROCESSING(SSobj, src)
	update_icon()
