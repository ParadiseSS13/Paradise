// This item can be attached to /obj/item/card/id
/// When an ID makes a purchase with the right shoppers_card in its contents, it gets a discount
/obj/item/shoppers_card
	name = "shoppers card"
	desc = "A small, company loyalty chip, attachable to identification cards. You can get a discount on your purchases with this!"
	icon = 'icons/obj/card.dmi'	// Need unique stuff
	var/parent_company	// This is still a bad varname

/obj/item/shoppers_card/Initialize(mapload)
	. = ..()
	if(parent_company)
		name = "[initial(name)] ([parent_company])"

/obj/item/shoppers_card/nanotrasen
	parent_company = COMPANY_NANOTRASEN

/obj/item/shoppers_card/syndicate
	parent_company = COMPANY_SYNDICATE

/obj/item/shoppers_card/mrchangs
	parent_company = COMPANY_MRCHANGS

/obj/item/shoppers_card/donkco
	parent_company = COMPANY_DONKCO
