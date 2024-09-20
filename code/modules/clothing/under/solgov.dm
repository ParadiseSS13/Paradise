/obj/item/clothing/under/solgov
	name = "\improper TSF marine uniform"
	desc = "A comfortable and durable combat uniform worn by the forces of the Trans-Solar Marine Corps."
	icon_state = "solgov"
	item_state = "ro_suit"
	item_color = "solgov"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

	icon = 'icons/obj/clothing/under/solgov.dmi'
	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/solgov.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/solgov.dmi'
		)

/obj/item/clothing/under/solgov/elite
	name = "\improper MARSOC uniform"
	desc = "A comfortable and durable combat uniform worn by marines of the Trans-Solar Federation's Marine Special Operations Command."
	icon_state = "solgovelite"
	item_color = "solgovelite"

/obj/item/clothing/under/solgov/command
	name = "\improper TSF officer's uniform"
	desc = "A comfortable and durable combat uniform worn by junior officers of the Trans-Solar Marine Corps."
	icon_state = "solgovc"
	item_color = "solgovc"

/obj/item/clothing/under/solgov/command/elite
	name = "\improper MARSOC officer's uniform"
	desc = "A comfortable and durable combat uniform worn by junior officers of the Trans-Solar Federation's Marine Special Operations Command. This one has additional insignia on its shoulders and cuffs."
	icon_state = "solgovcelite"
	item_color = "solgovcelite"

/obj/item/clothing/under/solgov/rep
	name = "\improper TSF representative's uniform"
	desc = "A formal uniform worn by the diplomatic representatives of the Trans-Solar Federation."
	icon_state = "solgovr"
	item_color = "solgovr"

/obj/item/clothing/under/solgov/viper
	name = "\improper Federation infiltrator uniform"
	desc = "An olive drab camouflage uniform used by the elite Viper commandos of the Federal Army."
	color = "#f5cf53" // custom sprites are for losers (this makes it a light green)
