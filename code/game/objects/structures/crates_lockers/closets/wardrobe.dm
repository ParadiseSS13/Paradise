/obj/structure/closet/wardrobe
	name = "wardrobe"
	desc = "It's a storage unit for standard-issue Nanotrasen attire."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/wardrobe/generic
	// Identical to the base wardrobe, aside from containing some stuff.

/obj/structure/closet/wardrobe/generic/New()
	..()
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/brown(src)


/obj/structure/closet/wardrobe/red
	name = "security wardrobe"
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/wardrobe/red/New()
	..()
	new /obj/item/storage/backpack/duffel/security(src)
	new /obj/item/storage/backpack/duffel/security(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/under/rank/security(src)
	new /obj/item/clothing/under/rank/security(src)
	new /obj/item/clothing/under/rank/security(src)
	new /obj/item/clothing/under/rank/security/formal(src)
	new /obj/item/clothing/under/rank/security/formal(src)
	new /obj/item/clothing/under/rank/security/formal(src)
	new /obj/item/clothing/under/rank/security/skirt(src)
	new /obj/item/clothing/under/rank/security/skirt(src)
	new /obj/item/clothing/under/rank/security/skirt(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/shoes/jackboots/jacksandals(src)
	new /obj/item/clothing/shoes/jackboots/jacksandals(src)
	new /obj/item/clothing/shoes/jackboots/jacksandals(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/officer(src)
	new /obj/item/clothing/head/officer(src)
	new /obj/item/clothing/head/officer(src)

/obj/structure/closet/redcorp
	name = "corporate security wardrobe"
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/redcorp/New()
	..()
	new /obj/item/clothing/under/rank/security/corp(src)
	new /obj/item/clothing/under/rank/security/corp(src)
	new /obj/item/clothing/under/rank/security/corp(src)
	new /obj/item/clothing/head/soft/sec/corp(src)
	new /obj/item/clothing/head/soft/sec/corp(src)
	new /obj/item/clothing/head/soft/sec/corp(src)

/obj/structure/closet/wardrobe/pink
	name = "pink wardrobe"
	icon_state = "pink"
	icon_closed = "pink"

/obj/structure/closet/wardrobe/pink/New()
	..()
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/brown(src)

/obj/structure/closet/wardrobe/black
	name = "black wardrobe"
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/black/New()
	..()
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/under/color/black(src)
	if(prob(25))
		new /obj/item/clothing/suit/jacket/leather(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)

/obj/structure/closet/wardrobe/green
	name = "green wardrobe"
	icon_state = "green"
	icon_closed = "green"

/obj/structure/closet/wardrobe/green/New()
	..()
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)

/obj/structure/closet/wardrobe/xenos
	name = "xenos wardrobe"
	icon_state = "green"
	icon_closed = "green"

/obj/structure/closet/wardrobe/xenos/New()
	..()
	new /obj/item/clothing/suit/unathi/mantle(src)
	new /obj/item/clothing/suit/unathi/robe(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/footwraps(src)
	new /obj/item/clothing/shoes/footwraps(src)
	new /obj/item/clothing/shoes/footwraps(src)


/obj/structure/closet/wardrobe/orange
	name = "prison wardrobe"
	desc = "It's a storage unit for Nanotrasen-regulation prisoner attire."
	icon_state = "orange"
	icon_closed = "orange"

/obj/structure/closet/wardrobe/orange/New()
	..()
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)


/obj/structure/closet/wardrobe/yellow
	name = "yellow wardrobe"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/yellow/New()
	..()
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)


/obj/structure/closet/wardrobe/atmospherics_yellow
	name = "atmospherics wardrobe"
	icon_state = "atmostech"
	icon_closed = "atmostech"

/obj/structure/closet/wardrobe/atmospherics_yellow/New()
	..()
	new /obj/item/clothing/under/rank/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/atmospheric_technician/skirt(src)
	new /obj/item/clothing/under/rank/atmospheric_technician/skirt(src)
	new /obj/item/clothing/under/rank/atmospheric_technician/skirt(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/clothing/head/beret/atmos(src)
	new /obj/item/clothing/head/beret/atmos(src)
	new /obj/item/clothing/head/beret/atmos(src)



/obj/structure/closet/wardrobe/engineering_yellow
	name = "engineering wardrobe"
	icon_state = "engineer"
	icon_closed = "engineer"

/obj/structure/closet/wardrobe/engineering_yellow/New()
	..()
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineer/skirt(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/head/hardhat(src)
	new /obj/item/clothing/head/hardhat(src)
	new /obj/item/clothing/head/hardhat(src)
	new /obj/item/clothing/head/beret/eng(src)
	new /obj/item/clothing/head/beret/eng(src)
	new /obj/item/clothing/head/beret/eng(src)


/obj/structure/closet/wardrobe/white
	name = "white wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/white/New()
	..()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)

/obj/structure/closet/wardrobe/medical_white
	name = "medical doctor's wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/medical_white/New()
	..()
	new /obj/item/clothing/under/rank/nursesuit (src)
	new /obj/item/clothing/head/nursehat (src)
	new /obj/item/clothing/under/rank/nurse(src)
	new /obj/item/clothing/under/rank/orderly(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/head/surgery/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/head/surgery/purple(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)

/obj/structure/closet/wardrobe/pjs
	name = "Pajama wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/pjs/New()
	..()
	new /obj/item/clothing/under/pj/red(src)
	new /obj/item/clothing/under/pj/red(src)
	new /obj/item/clothing/under/pj/blue(src)
	new /obj/item/clothing/under/pj/blue(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/slippers(src)
	new /obj/item/clothing/shoes/slippers(src)


/obj/structure/closet/wardrobe/toxins_white
	name = "toxins wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/toxins_white/New()
	..()
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist/skirt(src)
	new /obj/item/clothing/under/rank/scientist/skirt(src)
	new /obj/item/clothing/under/rank/scientist/skirt(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/slippers
	new /obj/item/clothing/shoes/slippers
	new /obj/item/clothing/shoes/slippers


/obj/structure/closet/wardrobe/robotics_black
	name = "robotics wardrobe"
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/robotics_black/New()
	..()
	new /obj/item/clothing/under/rank/roboticist(src)
	new /obj/item/clothing/under/rank/roboticist(src)
	new /obj/item/clothing/under/rank/roboticist/skirt(src)
	new /obj/item/clothing/under/rank/roboticist/skirt(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)


/obj/structure/closet/wardrobe/chemistry_white
	name = "chemistry wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/chemistry_white/New()
	..()
	new /obj/item/clothing/under/rank/chemist(src)
	new /obj/item/clothing/under/rank/chemist(src)
	new /obj/item/clothing/under/rank/chemist/skirt(src)
	new /obj/item/clothing/under/rank/chemist/skirt(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/suit/storage/labcoat/chemist(src)
	new /obj/item/clothing/suit/storage/labcoat/chemist(src)
	new /obj/item/storage/backpack/chemistry(src)
	new /obj/item/storage/backpack/chemistry(src)
	new /obj/item/storage/backpack/satchel_chem(src)
	new /obj/item/storage/backpack/satchel_chem(src)
	new /obj/item/storage/bag/chemistry(src)
	new /obj/item/storage/bag/chemistry(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)


/obj/structure/closet/wardrobe/genetics_white
	name = "genetics wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/genetics_white/New()
	..()
	new /obj/item/clothing/under/rank/geneticist(src)
	new /obj/item/clothing/under/rank/geneticist(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/suit/storage/labcoat/genetics(src)
	new /obj/item/clothing/suit/storage/labcoat/genetics(src)
	new /obj/item/storage/backpack/genetics(src)
	new /obj/item/storage/backpack/genetics(src)
	new /obj/item/storage/backpack/satchel_gen(src)
	new /obj/item/storage/backpack/satchel_gen(src)


/obj/structure/closet/wardrobe/virology_white
	name = "virology wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/virology_white/New()
	..()
	new /obj/item/clothing/under/rank/virologist(src)
	new /obj/item/clothing/under/rank/virologist(src)
	new /obj/item/clothing/under/rank/virologist/skirt(src)
	new /obj/item/clothing/under/rank/virologist/skirt(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/suit/storage/labcoat/virologist(src)
	new /obj/item/clothing/suit/storage/labcoat/virologist(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/storage/backpack/virology(src)
	new /obj/item/storage/backpack/virology(src)
	new /obj/item/storage/backpack/satchel_vir(src)
	new /obj/item/storage/backpack/satchel_vir(src)


/obj/structure/closet/wardrobe/medic_white
	name = "medical wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/medic_white/New()
	..()
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/head/headmirror(src)
	new /obj/item/clothing/head/headmirror(src)


/obj/structure/closet/wardrobe/grey
	name = "grey wardrobe"
	icon_state = "grey"
	icon_closed = "grey"

/obj/structure/closet/wardrobe/grey/New()
	..()
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/head/soft/grey(src)
	new /obj/item/clothing/head/soft/grey(src)
	new /obj/item/clothing/head/soft/grey(src)
	if(prob(50))
		new /obj/item/storage/backpack/duffel(src)
	if(prob(40))
		new /obj/item/clothing/under/assistantformal(src)
	if(prob(40))
		new /obj/item/clothing/under/assistantformal(src)


/obj/structure/closet/wardrobe/mixed
	name = "mixed wardrobe"
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/wardrobe/mixed/New()
	..()
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/dress/plaid_blue(src)
	new /obj/item/clothing/under/dress/plaid_red(src)
	new /obj/item/clothing/under/dress/plaid_purple(src)
	new /obj/item/clothing/shoes/blue(src)
	new /obj/item/clothing/shoes/yellow(src)
	new /obj/item/clothing/shoes/green(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/purple(src)
	new /obj/item/clothing/shoes/leather(src)

/obj/structure/closet/wardrobe/coroner
	name = "coroner wardrobe"
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/coroner/New()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/suit/storage/labcoat/mortician(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/under/rank/medical/mortician(src)
	new /obj/item/clothing/head/surgery/black(src)
