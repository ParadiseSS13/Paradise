//Cloaks. No, not THAT kind of cloak.

/obj/item/clothing/neck/cloak
	name = "grey cloak"
	desc = "It's a cloak that can be worn around your neck in a pretty dull color."
	icon_state = "cloak"
	body_parts_covered = UPPER_TORSO | ARMS

/obj/item/clothing/neck/cloak/head_of_security
	name = "head of security's cloak"
	desc = "Worn by the leader of Brigston, ruling the station with an iron fist."
	icon_state = "hoscloak"

/obj/item/clothing/neck/cloak/quartermaster
	name = "quartermaster's cloak"
	desc = "Worn by the God-emperor of Cargonia, supplying the station with the necessary tools for survival."
	icon_state = "qmcloak"

/obj/item/clothing/neck/cloak/chief_medical_officer
	name = "chief medical officer's cloak"
	desc = "Worn by the leader of Medistan, the valiant men and women keeping pestilence at bay."
	icon_state = "cmocloak"

/obj/item/clothing/neck/cloak/chief_engineer
	name = "chief engineer's cloak"
	desc = "Worn by the leader of both Atmosia and Delamistan, wielder of unlimited power."
	icon_state = "cecloak"

/obj/item/clothing/neck/cloak/research_director
	name = "research director's cloak"
	desc = "Worn by the leader of Scientopia, the greatest thaumaturgist and researcher of rapid unexpected self disassembly."
	icon_state = "rdcloak"

/obj/item/clothing/neck/cloak/captain
	name = "captain's cloak"
	desc = "Worn by the supreme leader of Space Station 13."
	icon_state = "capcloak"

/obj/item/clothing/neck/cloak/captain/Initialize(mapload)
	. = ..()
	desc = "Worn by the supreme leader of [station_name()]."

/obj/item/clothing/neck/cloak/head_of_personnel
	name = "head of personnel's cloak"
	desc = "Worn by the Head of Personnel. It smells faintly of bureaucracy."
	icon_state = "hopcloak"

/obj/item/clothing/neck/cloak/syndicate
	name = "suspicious cloak"
	desc = "A half-cloak worn around the neck, featuring a color scheme that's both suspicious and stylish."
	icon_state = "syndiecloak"

//Mantles.

/obj/item/clothing/neck/cloak/mantle
	name = "mantle"
	desc = "A heavy quilted mantle, for keeping your shoulders warm and stylish."
	icon_state = "mantle"

/obj/item/clothing/neck/cloak/regal
	name = "regal shawl"
	desc = "A fancy shawl for nobility, made from high quality materials."
	icon_state = "regal_mantle"

/obj/item/clothing/neck/cloak/old
	name = "old wrap"
	desc = "A tattered fabric wrap, faded over the years. Smells faintly of cigars."
	icon_state = "old_mantle"

/obj/item/clothing/neck/cloak/unathi
	name = "hide mantle"
	desc = "A rather grisly selection of cured hides and skin, sewn together to form a ragged mantle."
	icon_state = "mantle-unathi"
	inhand_icon_state = "old_mantle"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/neck.dmi')

/obj/item/clothing/neck/cloak/captain_mantle
	name = "captain's mantle"
	desc = "A piece of fashion for the ruling elite."
	icon_state = "capmantle"

/obj/item/clothing/neck/cloak/hos_mantle
	name = "head of security's shawl"
	desc = "An unarmored shawl, worn by the Head of Security. Do you dare take up their mantle?"
	icon_state = "hosmantle"

/obj/item/clothing/neck/cloak/hop_mantle
	name = "head of personnel's shawl"
	desc = "A shawl for the head of personnel. It's remarkably well kept."
	icon_state = "hopmantle"

/obj/item/clothing/neck/cloak/ce_mantle
	name = "chief engineer's mantle"
	desc = "A slick, authoritative mantle designed for the Chief Engineer."
	icon_state = "cemantle"

/obj/item/clothing/neck/cloak/cmo_mantle
	name = "chief medical officer's mantle"
	desc = "An absorbent, clean cover found around the neck of the Chief Medical Officer."
	icon_state = "cmomantle"

/obj/item/clothing/neck/cloak/qm_mantle
	name = "quartermaster's mantle"
	desc = "A shawl for the quartermaster. Keeps the breeze from the vents away from your neck."
	icon_state = "qmmantle"
	inhand_icon_state = "mantle"

/obj/item/clothing/neck/cloak/rd_mantle
	name = "research director's mantle"
	desc = "A tweed mantle, worn by the Research Director. Smells like science."
	icon_state = "rdmantle"

/obj/item/clothing/neck/cloak/tallit
	name = "tallit"
	desc = "A Jewish prayer shawl."
	icon_state = "tallit"

	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/neck.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/neck.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/neck.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/neck.dmi'
	)
