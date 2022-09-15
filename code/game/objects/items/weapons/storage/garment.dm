/obj/item/storage/bag/garment
	name = "garment bag"
	desc = "A bag for storing extra clothes and shoes."
	icon_state = "garment_bag"
	slot_flags = NONE
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	display_contents_with_number = FALSE
	max_combined_w_class = 200
	storage_slots = 21
	resistance_flags = FLAMMABLE
	can_hold = list(/obj/item/clothing)
	cant_hold = list(
		/obj/item/storage,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/mask/cigarette,
		/obj/item/clothing/mask/facehugger, //Why would you do this
		/obj/item/clothing/accessory/medal,
		/obj/item/clothing/suit/armor/riot,
		/obj/item/clothing/suit/armor/reactive,
		/obj/item/clothing/suit/armor/laserproof,
		/obj/item/clothing/suit/hooded/ablative,
		/obj/item/clothing/gloves/color/black/krav_maga,
	)

/obj/item/storage/bag/garment/captain
	name = "captain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the captain."

/obj/item/storage/bag/garment/captain/populate_contents()
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/suit/captunic/capjacket(src)
	new /obj/item/clothing/suit/mantle/armor/captain(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/alt(src)
	new /obj/item/clothing/under/captainparade(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/dress/dress_cap(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/glasses/sunglasses(src)

/obj/item/storage/bag/garment/head_of_personnel
	name = "head of personnel's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of personnel."

/obj/item/storage/bag/garment/head_of_personnel/populate_contents()
	new /obj/item/clothing/head/hopcap(src)
	new /obj/item/clothing/suit/mantle/armor/head_of_personnel(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/under/rank/head_of_personnel(src)
	new /obj/item/clothing/under/dress/dress_hop(src)
	new /obj/item/clothing/under/dress/dress_hr(src)
	new /obj/item/clothing/under/lawyer/female(src)
	new /obj/item/clothing/under/lawyer/black(src)
	new /obj/item/clothing/under/lawyer/red(src)
	new /obj/item/clothing/under/lawyer/oldman(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/leather(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses(src)

/obj/item/storage/bag/garment/head_of_security
	name = "head of security's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of security."

/obj/item/storage/bag/garment/head_of_security/populate_contents()
	new /obj/item/clothing/head/HoS(src)
	new /obj/item/clothing/head/HoS/beret(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/suit/armor/hos/alt(src)
	new /obj/item/clothing/suit/mantle/armor(src)
	new /obj/item/clothing/under/rank/head_of_security(src)
	new /obj/item/clothing/under/rank/head_of_security/formal(src)
	new /obj/item/clothing/under/rank/head_of_security/corp(src)
	new /obj/item/clothing/under/rank/head_of_security/skirt(src)
	new /obj/item/clothing/under/rank/head_of_security/skirt/corp(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)

/obj/item/storage/bag/garment/research_director
	name = "research director's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the research director."

/obj/item/storage/bag/garment/research_director/populate_contents()
	new /obj/item/clothing/under/rank/research_director(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/mantle/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/color/latex(src)


/obj/item/storage/bag/garment/chief_medical_officer
	name = "chief medical officer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief medical officer."

/obj/item/storage/bag/garment/chief_medical_officer/populate_contents()
	new /obj/item/clothing/head/surgery/blue(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/head/surgery/purple(src)
	new /obj/item/clothing/under/rank/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/suit/storage/labcoat/cmo(src)
	new /obj/item/clothing/suit/mantle/labcoat/chief_medical_officer(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/brown	(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)

/obj/item/storage/bag/garment/chief_engineer
	name = "chief engineer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief engineer."

/obj/item/storage/bag/garment/chief_engineer/populate_contents()
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/head/beret/ce(src)
	new /obj/item/clothing/head/beret/eng(src)
	new /obj/item/clothing/under/rank/chief_engineer(src)
	new /obj/item/clothing/under/rank/chief_engineer/skirt(src)
	new /obj/item/clothing/suit/mantle/chief_engineer(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/glasses/welding/superior(src)
	new /obj/item/clothing/gloves/color/yellow(src)
