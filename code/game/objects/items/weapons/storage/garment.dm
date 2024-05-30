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
	new /obj/item/clothing/head/beret/captain(src)
	new /obj/item/clothing/head/beret/captain/white(src)
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
	new /obj/item/clothing/head/hop(src)
	new /obj/item/clothing/head/beret/hop(src)
	new /obj/item/clothing/suit/mantle/armor/hop(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/suit/hopcoat(src)
	new /obj/item/clothing/under/rank/civilian/hop(src)
	new /obj/item/clothing/under/rank/civilian/hop/skirt(src)
	new /obj/item/clothing/under/rank/civilian/hop/dress(src)
	new /obj/item/clothing/under/rank/civilian/hop/formal(src)
	new /obj/item/clothing/under/rank/civilian/hop/oldman(src)
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
	new /obj/item/clothing/head/beret/hos(src)
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
	new /obj/item/clothing/head/beret/sci(src)
	new /obj/item/clothing/under/rank/rnd/research_director(src)
	new /obj/item/clothing/suit/storage/labcoat/rd(src)
	new /obj/item/clothing/suit/mantle/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/glasses/science(src)
	new /obj/item/clothing/glasses/welding/superior(src)
	new /obj/item/clothing/glasses/hud/diagnostic/sunglasses(src)


/obj/item/storage/bag/garment/chief_medical_officer
	name = "chief medical officer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief medical officer."

/obj/item/storage/bag/garment/chief_medical_officer/populate_contents()
	new /obj/item/clothing/head/surgery/blue(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/head/surgery/purple(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/skirt(src)
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
	new /obj/item/clothing/suit/storage/hazardvest/ce(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/glasses/welding/superior(src)
	new /obj/item/clothing/glasses/meson/sunglasses(src)
	new /obj/item/clothing/gloves/color/yellow(src)

/obj/item/storage/bag/garment/nanotrasen_representative
	name = "\improper Nanotrasen representative's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the Nanotrasen representative."

/obj/item/storage/bag/garment/nanotrasen_representative/populate_contents()
	new /obj/item/clothing/head/ntrep(src)
	new /obj/item/clothing/under/rank/procedure/representative(src)
	new /obj/item/clothing/under/rank/procedure/representative/skirt(src)
	new /obj/item/clothing/under/rank/procedure/representative/formal(src)
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
	new /obj/item/clothing/under/rank/procedure/magistrate(src)
	new /obj/item/clothing/under/rank/procedure/magistrate/skirt(src)
	new /obj/item/clothing/under/rank/procedure/magistrate/formal(src)
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
	new /obj/item/clothing/under/rank/procedure/blueshield(src)
	new /obj/item/clothing/under/rank/procedure/blueshield/skirt(src)
	new /obj/item/clothing/under/rank/procedure/blueshield/formal(src)
	new /obj/item/clothing/suit/armor/vest/blueshield(src)
	new /obj/item/clothing/suit/storage/blueshield(src)
	new /obj/item/clothing/shoes/centcom(src)
	new /obj/item/clothing/shoes/jackboots/jacksandals(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses(src)
	new /obj/item/clothing/accessory/blue(src)

/obj/item/storage/bag/garment/quartermaster
	name = "quartermaster's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the quartermaster."

/obj/item/storage/bag/garment/quartermaster/populate_contents()
	new /obj/item/clothing/under/rank/cargo/qm(src)
	new /obj/item/clothing/under/rank/cargo/qm/skirt(src)
	new /obj/item/clothing/under/rank/cargo/qm/dress(src)
	new /obj/item/clothing/under/rank/cargo/qm/formal(src)
	new /obj/item/clothing/under/rank/cargo/qm/whimsy(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/head/qm(src)
	new /obj/item/clothing/head/beret/qm(src)
	new /obj/item/clothing/head/hardhat/orange(src)
	new /obj/item/clothing/suit/qmcoat(src)
	new /obj/item/clothing/suit/mantle/qm(src)
	new /obj/item/clothing/suit/storage/hazardvest/qm(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)

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

/obj/item/storage/bag/garment/chaplain
	name = "chaplain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chaplain."

/obj/item/storage/bag/garment/chaplain/populate_contents()
	new /obj/item/clothing/under/rank/civilian/chaplain(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/suit/hooded/abaya(src)
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

/obj/item/storage/bag/garment/paramedic
	name = "paramedic's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the paramedic."

/obj/item/storage/bag/garment/paramedic/populate_contents()
	new /obj/item/clothing/under/rank/medical/paramedic(src)
	new /obj/item/clothing/head/soft/blue(src)
	new /obj/item/clothing/suit/storage/labcoat/emt(src)
	new /obj/item/clothing/suit/storage/paramedic(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/shoes/black(src)

/obj/item/storage/bag/garment/explorer
	name = "explorer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the explorer."

/obj/item/storage/bag/garment/explorer/populate_contents()
	new /obj/item/clothing/under/rank/cargo/expedition(src)
	new /obj/item/clothing/under/rank/cargo/expedition/overalls(src)
	new /obj/item/clothing/head/soft/expedition(src)
	new /obj/item/clothing/head/beret/expedition(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/mask/gas/explorer(src)
