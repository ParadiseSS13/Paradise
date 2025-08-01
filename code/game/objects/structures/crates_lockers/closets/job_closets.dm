/* Closets for specific jobs
 * Contains:
 *		Bartender
*		Chef
 *		Janitor
 *		Paramedic
 */

/*
 * Bartender
 */
/obj/structure/closet/gmcloset
	name = "formal closet"
	desc = "It's a storage unit for formal clothing."
	closed_door_sprite = "black"

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
	closed_door_sprite = "black"


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
	new /obj/item/clothing/head/soft/white(src)
	new /obj/item/clothing/head/soft/white(src)
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
	closed_door_sprite = "mixed"


/obj/structure/closet/jcloset/populate_contents()
	new /obj/item/flashlight(src)
	new /obj/item/flashlight(src)
	new /obj/item/melee/flyswatter(src)
	new /obj/item/melee/flyswatter(src)
	new /obj/item/soap(src)
	new /obj/item/soap(src)
	new /obj/item/holosign_creator/janitor(src)
	new /obj/item/holosign_creator/janitor(src)
	new /obj/item/watertank/janitor(src)
	new /obj/item/watertank/janitor(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/cartridge/janitor(src)
	new /obj/item/cartridge/janitor(src)
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/reagent_containers/glass/bucket(src)
