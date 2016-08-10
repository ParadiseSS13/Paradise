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
	icon_closed = "black"

/obj/structure/closet/gmcloset/New()
	..()
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/device/radio/headset/headset_service(src)
	new /obj/item/device/radio/headset/headset_service(src)
	new /obj/item/clothing/head/hairflower
	new /obj/item/clothing/under/sl_suit(src)
	new /obj/item/clothing/under/sl_suit(src)
	new /obj/item/clothing/under/rank/bartender(src)
	new /obj/item/clothing/under/rank/bartender(src)
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
	icon_closed = "black"

/obj/structure/closet/chefcloset/New()
	..()
	new /obj/item/clothing/under/waiter(src)
	new /obj/item/clothing/under/waiter(src)
	new /obj/item/device/radio/headset/headset_service(src)
	new /obj/item/device/radio/headset/headset_service(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/weapon/storage/box/mousetraps(src)
	new /obj/item/weapon/storage/box/mousetraps(src)
	new /obj/item/clothing/under/rank/chef(src)
	new /obj/item/clothing/head/chefhat(src)
	new /obj/item/weapon/reagent_containers/glass/rag(src)

/*
 * Janitor
 */
/obj/structure/closet/jcloset
	name = "custodial closet"
	desc = "It's a storage unit for janitorial clothes and gear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/jcloset/New()
	..()
	new /obj/item/clothing/under/rank/janitor(src)
	new /obj/item/device/radio/headset/headset_service(src)
	new /obj/item/weapon/cartridge/janitor(src)
	new /obj/item/device/flashlight(src)
	new /obj/item/clothing/shoes/galoshes(src)
	new /obj/item/weapon/soap(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/storage/bag/trash(src)
	new /obj/item/device/lightreplacer(src)
	new /obj/item/weapon/holosign_creator(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/head/soft/purple(src)
	new /obj/item/weapon/watertank/janitor(src)
	new /obj/item/weapon/storage/belt/janitor(src)

/*
 * Lawyer
 */
/obj/structure/closet/lawcloset
	name = "legal closet"
	desc = "It's a storage unit for courtroom apparel and items."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/lawcloset/New()
	..()
	new /obj/item/weapon/storage/box/tapes(src)
	new /obj/item/weapon/book/manual/faxes(src)
	new /obj/item/clothing/under/lawyer/female(src)
	new /obj/item/clothing/under/lawyer/black(src)
	new /obj/item/clothing/under/lawyer/red(src)
	new /obj/item/clothing/under/lawyer/bluesuit(src)
	new /obj/item/clothing/suit/storage/lawyer/bluejacket(src)
	new /obj/item/clothing/under/lawyer/purpsuit(src)
	new /obj/item/clothing/suit/storage/lawyer/purpjacket(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/glasses/sunglasses/big(src)
	new /obj/item/clothing/glasses/sunglasses/big(src)

//Paramedic

/obj/structure/closet/paramedic
	name = "paramedic wardrobe"
	desc = "It's a storage unit for paramedic equipment."
	icon_state = "blue"
	icon_closed = "blue"


/obj/structure/closet/paramedic/New()
	new /obj/item/clothing/under/rank/medical/paramedic(src)
	new /obj/item/clothing/under/rank/medical/paramedic(src)
	new /obj/item/device/radio/headset/headset_med(src)
	new /obj/item/device/radio/headset/headset_med(src)
	new /obj/item/clothing/head/soft/blue(src)
	new /obj/item/clothing/head/soft/blue(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/head/soft/blue(src)
	new /obj/item/clothing/head/soft/blue(src)
	new /obj/item/clothing/suit/storage/paramedic(src)
	new /obj/item/clothing/suit/storage/paramedic(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)
	new /obj/item/key/ambulance(src)
