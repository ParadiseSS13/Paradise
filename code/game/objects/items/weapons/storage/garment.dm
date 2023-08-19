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
	new /obj/item/clothing/head/caphat(src)
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/head/caphat/beret(src)
	new /obj/item/clothing/head/caphat/beret/white(src)
	new /obj/item/clothing/head/crown/fancy(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/jacket(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/jacket/tunic(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/coat(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/coat/white(src)
	new /obj/item/clothing/suit/mantle/armor/captain(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/rank/captain/parade(src)
	new /obj/item/clothing/under/rank/captain/dress(src)
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
	new /obj/item/clothing/under/rank/civilian/head_of_personnel(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/dress(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/dress_hr(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/black(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/red(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/oldman(src)
	new /obj/item/clothing/under/suit/female(src)
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
	new /obj/item/clothing/under/rank/security/head_of_security(src)
	new /obj/item/clothing/under/rank/security/formal/head_of_security(src)
	new /obj/item/clothing/under/rank/security/head_of_security/corporate(src)
	new /obj/item/clothing/under/rank/security/head_of_security/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/skirt/corporate(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)

/obj/item/storage/bag/garment/research_director
	name = "research director's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the research director."

/obj/item/storage/bag/garment/research_director/populate_contents()
	new /obj/item/clothing/under/rank/rnd/research_director(src)
	new /obj/item/clothing/suit/storage/labcoat/rd(src)
	new /obj/item/clothing/suit/mantle/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/color/latex(src)


/obj/item/storage/bag/garment/chief_medical_officer
	name = "chief medical officer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief medical officer."

/obj/item/storage/bag/garment/chief_medical_officer/populate_contents()
	new /obj/item/clothing/head/surgery/blue(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/head/surgery/purple(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/medical/scrubs(src)
	new /obj/item/clothing/under/rank/medical/scrubs/green(src)
	new /obj/item/clothing/under/rank/medical/scrubs/purple(src)
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
	new /obj/item/clothing/under/rank/engineering/chief_engineer(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/skirt(src)
	new /obj/item/clothing/suit/mantle/chief_engineer(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/glasses/welding/superior(src)
	new /obj/item/clothing/gloves/color/yellow(src)

/obj/item/storage/bag/garment/nanotrasen_representative
	name = "\improper Nanotrasen representative's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the Nanotrasen representative."

/obj/item/storage/bag/garment/nanotrasen_representative/populate_contents()
	new /obj/item/clothing/head/ntrep(src)
	new /obj/item/clothing/under/rank/centcom/representative(src)
	new /obj/item/clothing/under/rank/centcom/representative/skirt(src)
	new /obj/item/clothing/under/rank/centcom/representative/formal(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/oldman(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/black(src)
	new /obj/item/clothing/under/suit/female(src)
	new /obj/item/clothing/shoes/centcom(src)
	new /obj/item/clothing/shoes/sandal/fancy(src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/gloves/color/white(src)

/obj/item/storage/bag/garment/magistrate
	name = "magistrate's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the magistrate."

/obj/item/storage/bag/garment/magistrate/populate_contents()
	new /obj/item/clothing/head/justice_wig(src)
	new /obj/item/clothing/head/powdered_wig(src)
	new /obj/item/clothing/under/rank/centcom/magistrate(src)
	new /obj/item/clothing/under/rank/centcom/magistrate/skirt(src)
	new /obj/item/clothing/under/rank/centcom/magistrate/formal(src)
	new /obj/item/clothing/suit/magirobe(src)
	new /obj/item/clothing/shoes/centcom(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/gloves/color/white(src)

/obj/item/storage/bag/garment/blueshield
	name = "blueshield's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the blueshield."

/obj/item/storage/bag/garment/blueshield/populate_contents()
	new /obj/item/clothing/head/beret/centcom/officer(src)
	new /obj/item/clothing/head/beret/centcom/officer/navy(src)
	new /obj/item/clothing/under/rank/centcom/blueshield(src)
	new /obj/item/clothing/under/rank/centcom/blueshield/skirt(src)
	new /obj/item/clothing/under/rank/centcom/blueshield/formal(src)
	new /obj/item/clothing/suit/armor/vest/blueshield(src)
	new /obj/item/clothing/suit/storage/blueshield(src)
	new /obj/item/clothing/shoes/centcom(src)
	new /obj/item/clothing/shoes/jackboots/jacksandals(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/read_only(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses(src)
	new /obj/item/clothing/accessory/blue(src)

/obj/item/storage/bag/garment/quartermaster
	name = "quartermaster's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the quartermaster."

/obj/item/storage/bag/garment/quartermaster/populate_contents()
	new /obj/item/clothing/under/rank/cargo/quartermaster(src)
	new /obj/item/clothing/under/rank/cargo/quartermaster/skirt(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/tank/internals/emergency_oxygen(src)

/obj/item/storage/bag/garment/warden
	name = "warden's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the warden."

/obj/item/storage/bag/garment/warden/populate_contents()
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/warden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/head/beret/sec/warden(src)
	new /obj/item/clothing/under/rank/security/warden(src)
	new /obj/item/clothing/under/rank/security/formal/warden(src)
	new /obj/item/clothing/under/rank/security/warden/corporate(src)
	new /obj/item/clothing/under/rank/security/warden/skirt(src)
	new /obj/item/clothing/under/rank/security/warden/skirt/corporate(src)
	new /obj/item/clothing/mask/gas/sechailer/warden(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)

/obj/item/storage/bag/garment/detective
	name = "detective's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the detective."

/obj/item/storage/bag/garment/detective/populate_contents()
	new /obj/item/clothing/under/rank/security/detective(src)
	new /obj/item/clothing/suit/storage/det_suit(src)
	new /obj/item/clothing/suit/storage/det_suit/forensics/blue(src)
	new /obj/item/clothing/suit/storage/det_suit/forensics/red(src)
	new /obj/item/clothing/gloves/color/black/forensics(src)
	new /obj/item/clothing/head/det_hat(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/suit/armor/vest/det_suit(src)
	new /obj/item/clothing/accessory/black(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/clothing/glasses/sunglasses/yeah(src)

/obj/item/storage/bag/garment/iaa
	name = "internal affairs agent's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the internal affairs agent."

/obj/item/storage/bag/garment/iaa/populate_contents()
	new /obj/item/clothing/under/rank/civilian/lawyer/black(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/red(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/blue(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/purple(src)
	new /obj/item/clothing/under/rank/civilian/lawyer/bluesuit(src)
	new /obj/item/clothing/under/suit/female(src)
	new /obj/item/clothing/suit/storage/lawyer/bluejacket(src)
	new /obj/item/clothing/suit/storage/lawyer/purpjacket(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/under/rank/civilian/internalaffairs(src)
	new /obj/item/clothing/suit/storage/internalaffairs(src)
	new /obj/item/clothing/glasses/sunglasses/big(src)
	new /obj/item/clothing/glasses/sunglasses/big(src)

/obj/item/storage/bag/garment/chaplain
	name = "chaplain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chaplain."

/obj/item/storage/bag/garment/chaplain/populate_contents()
	new /obj/item/clothing/under/rank/civilian/chaplain(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/suit/hooded/nun(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/monk(src)
	new /obj/item/clothing/suit/witchhunter(src)
	new /obj/item/clothing/head/witchhunter_hat(src)
	new /obj/item/clothing/suit/holidaypriest(src)
	new /obj/item/clothing/under/dress/wedding/bride_white(src)
	new /obj/item/clothing/head/helmet/riot/knight/templar(src)
	new /obj/item/clothing/suit/armor/riot/knight/templar(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/gold(src)
	new /obj/item/clothing/gloves/ring/gold(src)

/obj/item/storage/bag/garment/psychologist
	name = "psychologist's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the psychologist."

/obj/item/storage/bag/garment/psychologist/populate_contents()
	new /obj/item/clothing/under/rank/medical/psych(src)
	new /obj/item/clothing/under/rank/medical/psych/turtleneck(src)
	new /obj/item/clothing/under/rank/medical/doctor(src)
	new /obj/item/clothing/under/rank/medical/doctor/skirt(src)
	new /obj/item/clothing/suit/storage/labcoat/psych(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/glasses/hud/skills(src)
	new /obj/item/clothing/accessory/blue(src)
