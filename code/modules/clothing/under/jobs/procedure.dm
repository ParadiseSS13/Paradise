/obj/item/clothing/under/rank/procedure
	icon = 'icons/obj/clothing/under/procedure.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/procedure.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/procedure.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/procedure.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/procedure.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/procedure.dmi'
		)

/obj/item/clothing/under/rank/procedure/representative
	name = "\improper Nanotrasen representative's uniform"
	desc = "Fine black cotton pants and white shirt, with blue and gold trim."
	icon_state = "ntrep"
	item_state = "ntrep"
	item_color = "ntrep"

/obj/item/clothing/under/rank/procedure/representative/skirt
	name = "\improper Nanotrasen representative's skirt"
	desc = "A silky black skirt and white shirt, with blue and gold trim."
	icon_state = "ntrep_skirt"
	item_state = "ntrep_skirt"
	item_color = "ntrep_skirt"

/obj/item/clothing/under/rank/procedure/representative/formal
	name = "formal Nanotrasen representative's uniform"
	desc = "A formal black suit with gold trim and a blue tie, this uniform bears \"N.S.S. Cyberiad\" on the left shoulder."
	icon_state = "ntrep_formal"
	item_state = "ntrep_formal"
	item_color = "ntrep_formal"
	displays_id = FALSE

/obj/item/clothing/under/rank/procedure/representative/formal/Initialize(mapload)
	. = ..()
	desc = "A formal black suit with gold trim and a blue tie, this uniform bears [station_name()] on the left shoulder."

/obj/item/clothing/under/rank/procedure/magistrate
	name = "magistrate's uniform"
	desc = "Fine black cotton pants and white shirt, with a black tie and gold trim."
	icon_state = "magistrate"
	item_state = "magistrate"
	item_color = "magistrate"

/obj/item/clothing/under/rank/procedure/magistrate/skirt
	name = "magistrate's skirt"
	desc = "A silky black skirt and white shirt, with a black tie and gold trim."
	icon_state = "magistrate_skirt"
	item_state = "magistrate_skirt"
	item_color = "magistrate_skirt"

/obj/item/clothing/under/rank/procedure/magistrate/formal
	name = "formal magistrate's uniform"
	desc = "A formal black suit with gold trim and a snazzy red tie, this uniform displays the rank of \"Magistrate\" and bears \"N.S.S. Cyberiad\" on the left shoulder."
	icon_state = "magistrate_formal"
	item_state = "magistrate_formal"
	item_color = "magistrate_formal"
	displays_id = FALSE

/obj/item/clothing/under/rank/procedure/magistrate/formal/Initialize(mapload)
	. = ..()
	desc = "A formal black suit with gold trim and a snazzy red tie, this uniform displays the rank of \"Magistrate\" and bears [station_name()] on the left shoulder."

/obj/item/clothing/under/rank/procedure/blueshield
	name = "blueshield's uniform"
	desc = "A short-sleeved black uniform, paired with grey armored cargo pants, all made out of a sturdy material. Blueshield standard issue."
	icon_state = "blueshield"
	item_state = "blueshield"
	item_color = "blueshield"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/procedure/blueshield/skirt
	name = "blueshield's skirt"
	desc = "A short, black and grey with blue markings skirted uniform. For the feminine Blueshield."
	icon_state = "blueshield_skirt"
	item_state = "blueshield_skirt"
	item_color = "blueshield_skirt"

/obj/item/clothing/under/rank/procedure/blueshield/formal
	name = "formal blueshield's uniform"
	desc = "A formal black suit with blue trim and tie, this uniform bears \"Close Protection\" on the left shoulder. It has exotic materials for protection."
	icon_state = "blueshield_formal"
	item_state = "blueshield_formal"
	item_color = "blueshield_formal"
	displays_id = FALSE

/obj/item/clothing/under/rank/procedure/iaa
	name = "Internal Affairs uniform"
	desc = "The plain, professional attire of an Internal Affairs Agent. The collar is <i>immaculately</i> starched."
	icon_state = "iaa"
	item_state = "iaa"
	item_color = "iaa"

/obj/item/clothing/under/rank/procedure/iaa/purple
	name = "purple suit"
	desc = "A fancy set of purple slacks with a black waistcoat and puffy white tie. Exquisite."
	icon_state = "iaa_purple"
	item_state = "iaa_purple"
	item_color = "iaa_purple"

/obj/item/clothing/under/rank/procedure/iaa/blue
	name = "blue suit"
	desc = "Classy blue suit pants, white ironed shirt and a red tie. Professional."
	icon_state = "iaa_blue"
	item_state = "iaa_blue"
	item_color = "iaa_blue"

/obj/item/clothing/under/rank/procedure/lawyer
	name = "lawyer suit"
	desc = "Slick threads."

/obj/item/clothing/under/rank/procedure/lawyer/black
	icon_state = "lawyer_black"
	item_state = "lawyer_black"
	item_color = "lawyer_black"

/obj/item/clothing/under/rank/procedure/lawyer/black/skirt
	name = "lawyer skirt"
	icon_state = "lawyer_black_skirt"
	item_state = "lawyer_black_skirt"
	item_color = "lawyer_black_skirt"

/obj/item/clothing/under/rank/procedure/lawyer/red
	name = "lawyer red suit"
	icon_state = "lawyer_red"
	item_state = "lawyer_red"
	item_color = "lawyer_red"

/obj/item/clothing/under/rank/procedure/lawyer/red/skirt
	name = "lawyer red skirt"
	icon_state = "lawyer_red_skirt"
	item_state = "lawyer_red_skirt"
	item_color = "lawyer_red_skirt"

/obj/item/clothing/under/rank/procedure/lawyer/blue
	name = "lawyer blue suit"
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"
	item_color = "lawyer_blue"

/obj/item/clothing/under/rank/procedure/lawyer/blue/skirt
	name = "lawyer blue skirt"
	icon_state = "lawyer_blue_skirt"
	item_state = "lawyer_blue_skirt"
	item_color = "lawyer_blue_skirt"

/obj/item/clothing/under/rank/procedure/lawyer/goodman
	name = "criminal lawyer suit"
	desc = "It's all good, man!"
	icon_state = "lawyer_goodman"
	item_state = "lawyer_goodman"
	item_color = "lawyer_goodman"

/obj/item/clothing/under/rank/procedure/lawyer/goodman/skirt
	name = "criminal lawyer skirt"
	icon_state = "lawyer_goodman_skirt"
	item_state = "lawyer_goodman_skirt"
	item_color = "lawyer_goodman_skirt"
