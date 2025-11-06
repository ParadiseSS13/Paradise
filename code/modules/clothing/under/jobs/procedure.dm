/obj/item/clothing/under/rank/procedure
	icon = 'icons/obj/clothing/under/procedure.dmi'
	worn_icon = 'icons/mob/clothing/under/procedure.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/procedure.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/procedure.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/procedure.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/procedure.dmi'
	)

/obj/item/clothing/under/rank/procedure/representative
	name = "\improper Nanotrasen representative's uniform"
	desc = "Fine black cotton pants and white shirt, with blue and gold trim."
	icon_state = "ntrep"

/obj/item/clothing/under/rank/procedure/representative/skirt
	name = "\improper Nanotrasen representative's skirt"
	desc = "A silky black skirt and white shirt, with blue and gold trim."
	icon_state = "ntrep_skirt"

/obj/item/clothing/under/rank/procedure/representative/formal
	name = "formal Nanotrasen representative's uniform"
	desc = "A formal black suit with gold trim and a blue tie, this uniform bears \"N.S.S. Cyberiad\" on the left shoulder."
	icon_state = "ntrep_formal"
	displays_id = FALSE

/obj/item/clothing/under/rank/procedure/representative/formal/Initialize(mapload)
	. = ..()
	desc = "A formal black suit with gold trim and a blue tie, this uniform bears [station_name()] on the left shoulder."

/obj/item/clothing/under/rank/procedure/magistrate
	name = "magistrate's uniform"
	desc = "Fine black cotton pants and white shirt, with a black tie and gold trim."
	icon_state = "magistrate"

/obj/item/clothing/under/rank/procedure/magistrate/skirt
	name = "magistrate's skirt"
	desc = "A silky black skirt and white shirt, with a black tie and gold trim."
	icon_state = "magistrate_skirt"

/obj/item/clothing/under/rank/procedure/magistrate/formal
	name = "formal magistrate's uniform"
	desc = "A formal black suit with gold trim and a snazzy red tie, this uniform displays the rank of \"Magistrate\" and bears \"N.S.S. Cyberiad\" on the left shoulder."
	icon_state = "magistrate_formal"
	displays_id = FALSE

/obj/item/clothing/under/rank/procedure/magistrate/formal/Initialize(mapload)
	. = ..()
	desc = "A formal black suit with gold trim and a snazzy red tie, this uniform displays the rank of \"Magistrate\" and bears [station_name()] on the left shoulder."

/obj/item/clothing/under/rank/procedure/blueshield
	name = "blueshield's uniform"
	desc = "A short-sleeved black uniform, paired with grey armored cargo pants, all made out of a sturdy material. Blueshield standard issue."
	icon_state = "blueshield"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/procedure/blueshield/skirt
	name = "blueshield's skirt"
	desc = "A short, black and grey with blue markings skirted uniform. For the feminine Blueshield."
	icon_state = "blueshield_skirt"

/obj/item/clothing/under/rank/procedure/blueshield/formal
	name = "formal blueshield's uniform"
	desc = "A formal black suit with blue trim and tie, this uniform bears \"Close Protection\" on the left shoulder. It has exotic materials for protection."
	icon_state = "blueshield_formal"
	displays_id = FALSE

/obj/item/clothing/under/rank/procedure/blueshield/turtleneck
	name = "blueshield's turtleneck"
	desc = "A fancy turtleneck designed to keep the wearer cozy in a cold bridge. Due to budget cuts, the material does not offer any external protection."
	icon_state = "bs_turtle"

/obj/item/clothing/under/rank/procedure/iaa
	name = "Internal Affairs uniform"
	desc = "The plain, professional attire of an Internal Affairs Agent. The collar is <i>immaculately</i> starched."
	icon_state = "iaa"

/obj/item/clothing/under/rank/procedure/iaa/purple
	name = "purple suit"
	desc = "A fancy set of purple slacks with a black waistcoat and puffy white tie. Exquisite."
	icon_state = "iaa_purple"

/obj/item/clothing/under/rank/procedure/iaa/blue
	name = "blue suit"
	desc = "Classy blue suit pants, white ironed shirt and a red tie. Professional."
	icon_state = "iaa_blue"

/obj/item/clothing/under/rank/procedure/iaa/formal
	name = "Internal Affairs formal uniform"
	desc = "Slick threads, for the Internal Affairs Agent with ambitions of grandeur."

/obj/item/clothing/under/rank/procedure/iaa/formal/black
	icon_state = "iaa_formal_black"

/obj/item/clothing/under/rank/procedure/iaa/formal/black/skirt
	name = "Internal Affairs formal skirt"
	icon_state = "iaa_formal_black_skirt"

/obj/item/clothing/under/rank/procedure/iaa/formal/red
	name = "Internal Affairs formal red suit"
	icon_state = "iaa_formal_red"

/obj/item/clothing/under/rank/procedure/iaa/formal/red/skirt
	name = "Internal Affairs formal red skirt"
	icon_state = "iaa_formal_red_skirt"

/obj/item/clothing/under/rank/procedure/iaa/formal/blue
	name = "Internal Affairs formal blue suit"
	icon_state = "iaa_formal_blue"

/obj/item/clothing/under/rank/procedure/iaa/formal/blue/skirt
	name = "Internal Affairs formal blue skirt"
	icon_state = "iaa_formal_blue_skirt"

/obj/item/clothing/under/rank/procedure/iaa/formal/goodman	// You get ONE lawyer reference, IAA...
	name = "criminal lawyer suit"
	desc = "It's all good, man!"
	icon_state = "iaa_formal_goodman"

/obj/item/clothing/under/rank/procedure/iaa/formal/goodman/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Now all you need is a law degree and a job that actually deals with the law...</span>"	// But don't get any ideas about it meaning anything.

/obj/item/clothing/under/rank/procedure/iaa/formal/goodman/skirt
	name = "criminal lawyer skirt"
	icon_state = "iaa_formal_goodman_skirt"

/obj/item/clothing/under/rank/procedure/nct
	name = "\improper NT Career Trainer's uniform"
	desc = "A neatly pressed olive green shirt paired with black jeans, worn by those dedicated to shaping the future of the workforce."
	icon_state = "trainer"

/obj/item/clothing/under/rank/procedure/nct/skirt
	name = "\improper NT Career Trainer's skirt"
	desc = "A neatly pressed olive green shirt paired with a sleek black skirt, worn by those committed to mentoring the next generation."
	icon_state = "trainer_skirt"
