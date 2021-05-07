/obj/item/stack/sheet/cartiplaz
	name = "plazmite cartilage"
	icon = 'icons/hispania/obj/lavaland/artefacts.dmi'
	desc = "Strong filaments from plazmite toxic chamber, seems to be glowing."
	singular_name = "plazmite cartilage"
	icon_state = "plazcart"
	item_state = "plazcart"
	origin_tech = "biotech=5"

GLOBAL_LIST_INIT(cartiplaz_recipes, list ( \
	new/datum/stack_recipe("digested plasma", /obj/item/dig_plasma, 2, on_floor = 1)))

/obj/item/stack/sheet/cartiplaz/New(loc, amount=null)
	recipes = GLOB.cartiplaz_recipes
	return ..()
