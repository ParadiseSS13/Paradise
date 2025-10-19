/obj/item/storage/bag/garment
	name = "garment bag"
	desc = "A bag for storing extra clothes and shoes."
	icon_state = "garment_bag"
	slot_flags = NONE
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	display_contents_with_number = FALSE
	max_combined_w_class = 200
	storage_slots = 27
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
	new /obj/item/clothing/head/caphat/parade/white(src)
	new /obj/item/clothing/head/beret/captain(src)
	new /obj/item/clothing/head/beret/captain/white(src)
	new /obj/item/clothing/head/crown/fancy(src)
	new /obj/item/clothing/neck/cloak/captain(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/jacket(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/jacket/tunic(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/coat(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/coat/white(src)
	new /obj/item/clothing/neck/cloak/captain_mantle(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/rank/captain/skirt(src)
	new /obj/item/clothing/under/rank/captain/white(src)
	new /obj/item/clothing/under/rank/captain/skirt/white(src)
	new /obj/item/clothing/under/rank/captain/parade(src)
	new /obj/item/clothing/under/rank/captain/dress(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/captain(src)
	new /obj/item/clothing/under/plasmaman/captain(src)

/obj/item/storage/bag/garment/head_of_personnel
	name = "head of personnel's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of personnel."

/obj/item/storage/bag/garment/head_of_personnel/populate_contents()
	new /obj/item/clothing/head/hop(src)
	new /obj/item/clothing/head/beret/hop(src)
	new /obj/item/clothing/neck/cloak/head_of_personnel(src)
	new /obj/item/clothing/neck/cloak/hop_mantle(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/suit/hopcoat(src)
	new /obj/item/clothing/suit/hooded/wintercoat/hop(src)
	new /obj/item/clothing/under/rank/civilian/hop(src)
	new /obj/item/clothing/under/rank/civilian/hop/skirt(src)
	new /obj/item/clothing/under/rank/civilian/hop/dress(src)
	new /obj/item/clothing/under/rank/civilian/hop/formal(src)
	new /obj/item/clothing/under/rank/civilian/hop/oldman(src)
	new /obj/item/clothing/under/suit/female(src)
	new /obj/item/clothing/under/rank/civilian/hop/turtleneck(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/leather(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/hop(src)
	new /obj/item/clothing/under/plasmaman/hop(src)

/obj/item/storage/bag/garment/head_of_security
	name = "head of security's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of security."

/obj/item/storage/bag/garment/head_of_security/populate_contents()
	new /obj/item/clothing/head/hos(src)
	new /obj/item/clothing/head/beret/hos(src)
	new /obj/item/clothing/neck/cloak/head_of_security(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/suit/armor/hos/alt(src)
	new /obj/item/clothing/neck/cloak/hos_mantle(src)
	new /obj/item/clothing/under/rank/security/head_of_security(src)
	new /obj/item/clothing/under/rank/security/formal/head_of_security(src)
	new /obj/item/clothing/under/rank/security/head_of_security/corporate(src)
	new /obj/item/clothing/under/rank/security/head_of_security/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/skirt/corporate(src)
	new /obj/item/clothing/under/rank/security/head_of_security/turtleneck(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/security/hos(src)
	new /obj/item/clothing/under/plasmaman/security/hos(src)

/obj/item/storage/bag/garment/research_director
	name = "research director's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the research director."

/obj/item/storage/bag/garment/research_director/populate_contents()
	new /obj/item/clothing/head/rd (src)
	new /obj/item/clothing/head/beret/rd(src)
	new /obj/item/clothing/neck/cloak/research_director(src)
	new /obj/item/clothing/under/rank/rnd/rd(src)
	new /obj/item/clothing/under/rank/rnd/rd/skirt(src)
	new /obj/item/clothing/under/rank/rnd/rd/turtleneck(src)
	new /obj/item/clothing/suit/storage/labcoat/rd(src)
	new /obj/item/clothing/neck/cloak/rd_mantle(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/glasses/science(src)
	new /obj/item/clothing/glasses/welding/superior(src)
	new /obj/item/clothing/glasses/hud/diagnostic/sunglasses(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/rd(src)
	new /obj/item/clothing/under/plasmaman/rd(src)


/obj/item/storage/bag/garment/chief_medical_officer
	name = "chief medical officer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief medical officer."

/obj/item/storage/bag/garment/chief_medical_officer/populate_contents()
	new /obj/item/clothing/head/cmo (src)
	new /obj/item/clothing/head/beret/cmo (src)
	new /obj/item/clothing/head/surgery/blue(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/head/surgery/purple(src)
	new /obj/item/clothing/neck/cloak/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/medical/cmo(src)
	new /obj/item/clothing/under/rank/medical/cmo/skirt(src)
	new /obj/item/clothing/under/rank/medical/cmo/turtleneck(src)
	new /obj/item/clothing/under/rank/medical/scrubs(src)
	new /obj/item/clothing/under/rank/medical/scrubs/green(src)
	new /obj/item/clothing/under/rank/medical/scrubs/purple(src)
	new /obj/item/clothing/suit/storage/labcoat/cmo(src)
	new /obj/item/clothing/neck/cloak/cmo_mantle(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/brown	(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/cmo(src)
	new /obj/item/clothing/under/plasmaman/cmo(src)

/obj/item/storage/bag/garment/chief_engineer
	name = "chief engineer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief engineer."

/obj/item/storage/bag/garment/chief_engineer/populate_contents()
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/head/beret/ce(src)
	new /obj/item/clothing/head/beret/eng(src)
	new /obj/item/clothing/neck/cloak/chief_engineer(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck(src)
	new /obj/item/clothing/neck/cloak/ce_mantle(src)
	new /obj/item/clothing/suit/storage/hazardvest/ce(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/glasses/welding/superior(src)
	new /obj/item/clothing/glasses/meson/sunglasses(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/engineering/ce(src)
	new /obj/item/clothing/under/plasmaman/engineering/ce(src)

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
	new /obj/item/clothing/head/helmet/space/plasmaman/white(src)
	new /obj/item/clothing/under/plasmaman/enviroslacks(src)

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
	new /obj/item/clothing/head/helmet/space/plasmaman/white(src)
	new /obj/item/clothing/under/plasmaman/enviroslacks(src)

/obj/item/storage/bag/garment/blueshield
	name = "blueshield's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the blueshield."

/obj/item/storage/bag/garment/blueshield/populate_contents()
	new /obj/item/clothing/head/beret/centcom/officer(src)
	new /obj/item/clothing/head/beret/centcom/officer/navy(src)
	new /obj/item/clothing/under/rank/procedure/blueshield(src)
	new /obj/item/clothing/under/rank/procedure/blueshield/skirt(src)
	new /obj/item/clothing/under/rank/procedure/blueshield/formal(src)
	new /obj/item/clothing/under/rank/procedure/blueshield/turtleneck(src)
	new /obj/item/clothing/suit/armor/vest/blueshield(src)
	new /obj/item/clothing/suit/storage/blueshield(src)
	new /obj/item/clothing/shoes/centcom(src)
	new /obj/item/clothing/shoes/jackboots/jacksandals(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses(src)
	new /obj/item/clothing/neck/tie/blue(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/blueshield(src)
	new /obj/item/clothing/under/plasmaman/blueshield(src)

/obj/item/storage/bag/garment/quartermaster
	name = "quartermaster's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the quartermaster."

/obj/item/storage/bag/garment/quartermaster/populate_contents()
	new /obj/item/clothing/under/rank/cargo/qm(src)
	new /obj/item/clothing/under/rank/cargo/qm/skirt(src)
	new /obj/item/clothing/under/rank/cargo/qm/dress(src)
	new /obj/item/clothing/under/rank/cargo/qm/formal(src)
	new /obj/item/clothing/under/rank/cargo/qm/whimsy(src)
	new /obj/item/clothing/under/rank/cargo/qm/turtleneck(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/head/qm(src)
	new /obj/item/clothing/head/beret/qm(src)
	new /obj/item/clothing/neck/cloak/quartermaster(src)
	new /obj/item/clothing/head/hardhat/orange(src)
	new /obj/item/clothing/suit/qmcoat(src)
	new /obj/item/clothing/neck/cloak/qm_mantle(src)
	new /obj/item/clothing/suit/storage/hazardvest/qm(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/cargo(src)
	new /obj/item/clothing/under/plasmaman/cargo(src)

/obj/item/storage/bag/garment/warden
	name = "warden's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the warden."

/obj/item/storage/bag/garment/warden/populate_contents()
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/warden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/head/beret/warden(src)
	new /obj/item/clothing/under/rank/security/warden(src)
	new /obj/item/clothing/under/rank/security/formal/warden(src)
	new /obj/item/clothing/under/rank/security/warden/corporate(src)
	new /obj/item/clothing/under/rank/security/warden/skirt(src)
	new /obj/item/clothing/under/rank/security/warden/skirt/corporate(src)
	new /obj/item/clothing/under/rank/security/warden/turtleneck(src)
	new /obj/item/clothing/mask/gas/sechailer/swat/warden(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/security/warden(src)
	new /obj/item/clothing/under/plasmaman/security/warden(src)

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
	new /obj/item/clothing/neck/tie/black(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/clothing/glasses/sunglasses/yeah(src)

/obj/item/storage/bag/garment/chaplain
	name = "chaplain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chaplain."

/obj/item/storage/bag/garment/chaplain/populate_contents()
	new /obj/item/clothing/suit/hooded/dark_robes(src)
	new /obj/item/clothing/head/helmet/riot/knight/templar(src)
	new /obj/item/clothing/suit/armor/riot/knight/templar(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/chaplain/green(src)
	new /obj/item/clothing/under/plasmaman/chaplain/green(src)

/obj/item/storage/bag/garment/librarian
	name = "librarian's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the librarian."

/obj/item/storage/bag/garment/librarian/populate_contents()
	new /obj/item/clothing/under/rank/civilian/librarian(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/suit/librarian(src)
	new /obj/item/clothing/suit/librarian/argyle(src)
	new /obj/item/clothing/suit/armor/vest/press(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/librarian(src)
	new /obj/item/clothing/under/plasmaman/librarian(src)

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
	new /obj/item/clothing/neck/tie/blue(src)
	new /obj/item/clothing/head/helmet/space/plasmaman(src)
	new /obj/item/clothing/under/plasmaman(src)

/obj/item/storage/bag/garment/paramedic
	name = "paramedic's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the paramedic."

/obj/item/storage/bag/garment/paramedic/populate_contents()
	new /obj/item/clothing/under/rank/medical/paramedic(src)
	new /obj/item/clothing/under/rank/medical/paramedic/skirt(src)
	new /obj/item/clothing/head/soft/paramedic(src)
	new /obj/item/clothing/head/beret/paramedic(src)
	new /obj/item/clothing/suit/storage/labcoat/emt(src)
	new /obj/item/clothing/suit/storage/hazardvest/paramedic(src)
	new /obj/item/clothing/suit/hooded/wintercoat/medical/paramedic(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/medical(src)
	new /obj/item/clothing/under/plasmaman/medical(src)

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

/obj/item/storage/bag/garment/smith
	name = "smith's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the smith."

/obj/item/storage/bag/garment/smith/populate_contents()
	new /obj/item/clothing/under/rank/cargo/smith(src)
	new /obj/item/clothing/under/rank/cargo/smith/skirt(src)
	new /obj/item/clothing/under/rank/cargo/smith/overalls(src)
	new /obj/item/clothing/suit/apron/smith(src)
	new /obj/item/clothing/suit/jacket/bomber/smith(src)
	new /obj/item/clothing/head/soft/smith(src)
	new /obj/item/clothing/head/beret/smith(src)
	new /obj/item/clothing/gloves/smithing(src)
	new /obj/item/clothing/shoes/workboots/smithing(src)
	new /obj/item/clothing/under/plasmaman/smith(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/smith(src)

/obj/item/storage/bag/garment/syndie
	name = "suspicious garment bag"
	icon_state = "garment_bag_syndie"
	desc = "A bag for storing extra clothes and shoes. Judging by the colors, this one belongs to someone with malicious intent."

/obj/item/storage/bag/garment/syndie/populate_contents()
	new /obj/item/clothing/under/syndicate/tacticool(src)
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/under/syndicate/combat(src)
	new /obj/item/clothing/under/syndicate/greyman(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/clothing/suit/storage/iaa/blackjacket(src)
	new /obj/item/clothing/suit/blacktrenchcoat(src)
	new /obj/item/clothing/suit/hooded/wintercoat/syndicate(src)
	new /obj/item/clothing/head/beret/syndicate(src)
	new /obj/item/clothing/glasses/syndie(src)
	new /obj/item/clothing/neck/cloak/syndicate(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/shoes/laceup(src)
