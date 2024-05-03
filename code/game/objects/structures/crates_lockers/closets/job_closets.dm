/* Closets for specific jobs
 * Contains:
 *		Bartender
 *		Janitor
 *		Lawyer
 */

/*
 * Bartender
 */
/obj/structure/closet/gmcloset
	name = "formal closet"
	desc = "It's a storage unit for formal clothing."
	icon_state = "black"
	icon_opened = "generic_open"
	open_door_sprite = "generic_door"

/obj/structure/closet/gmcloset/populate_contents()
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/clothing/head/hairflower
	new /obj/item/clothing/under/misc/sl_suit(src)
	new /obj/item/clothing/under/misc/sl_suit(src)
	new /obj/item/clothing/under/rank/civilian/bartender(src)
	new /obj/item/clothing/under/rank/civilian/bartender(src)
	new /obj/item/clothing/under/dress/dress_saloon
	new /obj/item/clothing/suit/wcoat(src)
	new /obj/item/clothing/suit/wcoat(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)

/*
 * Chef
 */
/obj/structure/closet/chefcloset
	name = "chef's closet"
	desc = "It's a storage unit for foodservice garments."
	icon_state = "black"
	icon_opened = "generic_open"
	open_door_sprite = "generic_door"

/obj/structure/closet/chefcloset/populate_contents()
	new /obj/item/clothing/under/misc/waiter(src)
	new /obj/item/clothing/under/misc/waiter(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/storage/box/mousetraps(src)
	new /obj/item/storage/box/mousetraps(src)
	new /obj/item/clothing/under/rank/civilian/chef(src)
	new /obj/item/clothing/head/chefhat(src)
	new /obj/item/reagent_containers/glass/rag(src)

/*
 * Janitor
 */
/obj/structure/closet/jcloset
	name = "custodial closet"
	desc = "It's a storage unit for janitorial clothes and gear."
	icon_state = "mixed"
	icon_opened = "generic_open"
	open_door_sprite = "generic_door"

/obj/structure/closet/jcloset/populate_contents()
	new /obj/item/flashlight(src)
	new /obj/item/flashlight(src)
	new /obj/item/melee/flyswatter(src)
	new /obj/item/melee/flyswatter(src)
	new /obj/item/soap(src)
	new /obj/item/soap(src)
	new /obj/item/reagent_containers/spray/cleaner(src)
	new /obj/item/caution(src)
	new /obj/item/caution(src)
	new /obj/item/caution(src)
	new /obj/item/caution(src)
	new /obj/item/push_broom(src)
	new /obj/item/push_broom(src)
	new /obj/item/storage/bag/trash(src)
	new /obj/item/storage/bag/trash(src)
	new /obj/item/lightreplacer(src)
	new /obj/item/lightreplacer(src)
	new /obj/item/holosign_creator/janitor(src)
	new /obj/item/holosign_creator/janitor(src)
	new /obj/item/watertank/janitor(src)
	new /obj/item/watertank/janitor(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/cartridge/janitor(src)
	new /obj/item/cartridge/janitor(src)

//Paramedic

/obj/structure/closet/paramedic
	name = "paramedic wardrobe"
	desc = "It's a storage unit for paramedic equipment."
	icon_state = "blue"
	icon_opened = "generic_open"
	open_door_sprite = "generic_door"


/obj/structure/closet/paramedic/populate_contents()
	new /obj/item/clothing/under/rank/medical/paramedic(src)
	new /obj/item/clothing/under/rank/medical/paramedic(src)
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/clothing/head/soft/blue(src)
	new /obj/item/clothing/head/soft/blue(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/suit/storage/paramedic(src)
	new /obj/item/clothing/suit/storage/paramedic(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/clothing/suit/storage/labcoat/emt(src)
	new /obj/item/clothing/suit/storage/labcoat/emt(src)
