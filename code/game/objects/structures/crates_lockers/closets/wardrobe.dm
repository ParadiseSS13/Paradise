/obj/structure/closet/wardrobe
	name = "wardrobe"
	desc = "It's a storage unit for standard-issue Nanotrasen attire."
	closed_door_sprite = "blue"


/obj/structure/closet/wardrobe/generic
	// Identical to the base wardrobe, aside from containing some stuff.

/obj/structure/closet/wardrobe/generic/populate_contents()
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/jumpskirt/blue(src)
	new /obj/item/clothing/under/color/jumpskirt/blue(src)
	new /obj/item/clothing/under/color/jumpskirt/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/brown(src)


/obj/structure/closet/wardrobe/red
	name = "security wardrobe"
	closed_door_sprite = "red"


/obj/structure/closet/wardrobe/populate_contents()
	new /obj/item/storage/backpack/duffel/security(src)
	new /obj/item/storage/backpack/duffel/security(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/under/rank/security/officer(src)
	new /obj/item/clothing/under/rank/security/officer(src)
	new /obj/item/clothing/under/rank/security/officer(src)
	new /obj/item/clothing/under/rank/security/formal(src)
	new /obj/item/clothing/under/rank/security/formal(src)
	new /obj/item/clothing/under/rank/security/formal(src)
	new /obj/item/clothing/under/rank/security/officer/skirt(src)
	new /obj/item/clothing/under/rank/security/officer/skirt(src)
	new /obj/item/clothing/under/rank/security/officer/skirt(src)
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
	closed_door_sprite = "red"

/obj/structure/closet/redcorp/populate_contents()
	new /obj/item/clothing/under/rank/security/officer/corporate(src)
	new /obj/item/clothing/under/rank/security/officer/corporate(src)
	new /obj/item/clothing/under/rank/security/officer/corporate(src)
	new /obj/item/clothing/head/soft/sec/corp(src)
	new /obj/item/clothing/head/soft/sec/corp(src)
	new /obj/item/clothing/head/soft/sec/corp(src)

/obj/structure/closet/wardrobe/pink
	name = "pink wardrobe"
	closed_door_sprite = "pink"

/obj/structure/closet/wardrobe/pink/populate_contents()
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/jumpskirt/pink(src)
	new /obj/item/clothing/under/color/jumpskirt/pink(src)
	new /obj/item/clothing/under/color/jumpskirt/pink(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/brown(src)

/obj/structure/closet/wardrobe/black
	name = "black wardrobe"
	closed_door_sprite = "black"

/obj/structure/closet/wardrobe/black/populate_contents()
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/under/color/jumpskirt/black(src)
	new /obj/item/clothing/under/color/jumpskirt/black(src)
	new /obj/item/clothing/under/color/jumpskirt/black(src)
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
	closed_door_sprite = "green"

/obj/structure/closet/wardrobe/green/populate_contents()
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/jumpskirt/green(src)
	new /obj/item/clothing/under/color/jumpskirt/green(src)
	new /obj/item/clothing/under/color/jumpskirt/green(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)

/obj/structure/closet/wardrobe/xenos
	name = "xenos wardrobe"
	closed_door_sprite = "green"

/obj/structure/closet/wardrobe/xenos/populate_contents()
	new /obj/item/clothing/neck/cloak/unathi(src)
	new /obj/item/clothing/suit/unathi/robe(src)
	new /obj/item/clothing/gloves/handwraps(src)
	new /obj/item/clothing/gloves/handwraps(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/footwraps(src)
	new /obj/item/clothing/shoes/footwraps(src)
	new /obj/item/clothing/shoes/footwraps(src)


/obj/structure/closet/wardrobe/orange
	name = "orange wardrobe"
	closed_door_sprite = "orange"

/obj/structure/closet/wardrobe/orange/populate_contents()
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/under/color/jumpskirt/orange(src)
	new /obj/item/clothing/under/color/jumpskirt/orange(src)
	new /obj/item/clothing/under/color/jumpskirt/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)

/obj/structure/closet/wardrobe/orange/prison
	name = "prison wardrobe"
	desc = "It's a storage unit for Nanotrasen-regulation prisoner attire."

/obj/structure/closet/wardrobe/orange/prison/populate_contents()
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/under/color/jumpskirt/orange/prison(src)
	new /obj/item/clothing/under/color/jumpskirt/orange/prison(src)
	new /obj/item/clothing/under/color/jumpskirt/orange/prison(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)

/obj/structure/closet/wardrobe/yellow
	name = "yellow wardrobe"
	closed_door_sprite = "yellow"

/obj/structure/closet/wardrobe/yellow/populate_contents()
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/jumpskirt/yellow(src)
	new /obj/item/clothing/under/color/jumpskirt/yellow(src)
	new /obj/item/clothing/under/color/jumpskirt/yellow(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)


/obj/structure/closet/wardrobe/atmospherics_yellow
	name = "atmospherics wardrobe"
	closed_door_sprite = "atmos_wardrobe"

/obj/structure/closet/wardrobe/atmospherics_yellow/populate_contents()
	new /obj/item/clothing/under/rank/engineering/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/engineering/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/engineering/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt(src)
	new /obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt(src)
	new /obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt(src)
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
	closed_door_sprite = "yellow"

/obj/structure/closet/wardrobe/engineering_yellow/populate_contents()
	new /obj/item/clothing/under/rank/engineering/engineer(src)
	new /obj/item/clothing/under/rank/engineering/engineer(src)
	new /obj/item/clothing/under/rank/engineering/engineer(src)
	new /obj/item/clothing/under/rank/engineering/engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineering/engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineering/engineer/skirt(src)
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
	closed_door_sprite = "white"

/obj/structure/closet/wardrobe/white/populate_contents()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/jumpskirt/white(src)
	new /obj/item/clothing/under/color/jumpskirt/white(src)
	new /obj/item/clothing/under/color/jumpskirt/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)

/obj/structure/closet/wardrobe/medical_white
	name = "medical doctor's wardrobe"
	closed_door_sprite = "white"

/obj/structure/closet/wardrobe/medical_white/populate_contents()
	new /obj/item/clothing/under/rank/medical/nursesuit (src)
	new /obj/item/clothing/head/nursehat (src)
	new /obj/item/clothing/under/rank/medical/nurse(src)
	new /obj/item/clothing/under/rank/medical/orderly(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/under/rank/medical/scrubs(src)
	new /obj/item/clothing/head/surgery/blue(src)
	new /obj/item/clothing/under/rank/medical/scrubs/green(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/under/rank/medical/scrubs/purple(src)
	new /obj/item/clothing/under/rank/medical/doctor/skirt(src)
	new /obj/item/clothing/under/rank/medical/doctor/skirt(src)
	new /obj/item/clothing/head/surgery/purple(src)
	new /obj/item/clothing/under/rank/medical/gown(src)
	new /obj/item/clothing/under/rank/medical/gown(src)
	new /obj/item/clothing/under/rank/medical/gown(src)
	new /obj/item/clothing/under/rank/medical/gown(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)

/obj/structure/closet/wardrobe/pjs
	name = "Pajama wardrobe"
	closed_door_sprite = "white"

/obj/structure/closet/wardrobe/pjs/populate_contents()
	new /obj/item/clothing/under/misc/pj/red(src)
	new /obj/item/clothing/under/misc/pj/red(src)
	new /obj/item/clothing/under/misc/pj/blue(src)
	new /obj/item/clothing/under/misc/pj/blue(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/slippers(src)
	new /obj/item/clothing/shoes/slippers(src)


/obj/structure/closet/wardrobe/toxins_white
	name = "toxins wardrobe"
	closed_door_sprite = "white"

/obj/structure/closet/wardrobe/toxins_white/populate_contents()
	new /obj/item/clothing/under/rank/rnd/scientist(src)
	new /obj/item/clothing/under/rank/rnd/scientist(src)
	new /obj/item/clothing/under/rank/rnd/scientist(src)
	new /obj/item/clothing/under/rank/rnd/scientist/skirt(src)
	new /obj/item/clothing/under/rank/rnd/scientist/skirt(src)
	new /obj/item/clothing/under/rank/rnd/scientist/skirt(src)
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
	closed_door_sprite = "black"

/obj/structure/closet/wardrobe/robotics_black/populate_contents()
	new /obj/item/clothing/under/rank/rnd/roboticist(src)
	new /obj/item/clothing/under/rank/rnd/roboticist(src)
	new /obj/item/clothing/under/rank/rnd/roboticist/skirt(src)
	new /obj/item/clothing/under/rank/rnd/roboticist/skirt(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)


/obj/structure/closet/wardrobe/chemistry_white
	name = "chemistry wardrobe"
	closed_door_sprite = "white"

/obj/structure/closet/wardrobe/chemistry_white/populate_contents()
	new /obj/item/clothing/under/rank/medical/chemist(src)
	new /obj/item/clothing/under/rank/medical/chemist(src)
	new /obj/item/clothing/under/rank/medical/chemist/skirt(src)
	new /obj/item/clothing/under/rank/medical/chemist/skirt(src)
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
	closed_door_sprite = "white"

/obj/structure/closet/wardrobe/genetics_white/populate_contents()
	new /obj/item/clothing/under/rank/rnd/geneticist(src)
	new /obj/item/clothing/under/rank/rnd/geneticist(src)
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
	closed_door_sprite = "white"

/obj/structure/closet/wardrobe/virology_white/populate_contents()
	new /obj/item/clothing/under/rank/medical/virologist(src)
	new /obj/item/clothing/under/rank/medical/virologist(src)
	new /obj/item/clothing/under/rank/medical/virologist/skirt(src)
	new /obj/item/clothing/under/rank/medical/virologist/skirt(src)
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
	closed_door_sprite = "white"

/obj/structure/closet/wardrobe/medic_white/populate_contents()
	new /obj/item/clothing/under/rank/medical/doctor(src)
	new /obj/item/clothing/under/rank/medical/doctor(src)
	new /obj/item/clothing/under/rank/medical/doctor/skirt(src)
	new /obj/item/clothing/under/rank/medical/doctor/skirt(src)
	new /obj/item/clothing/under/rank/medical/scrubs(src)
	new /obj/item/clothing/under/rank/medical/scrubs/green(src)
	new /obj/item/clothing/under/rank/medical/scrubs/purple(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/under/rank/medical/gown(src)
	new /obj/item/clothing/under/rank/medical/gown(src)
	new /obj/item/clothing/under/rank/medical/gown(src)
	new /obj/item/clothing/under/rank/medical/gown(src)
	new /obj/item/clothing/head/headmirror(src)
	new /obj/item/clothing/head/headmirror(src)


/obj/structure/closet/wardrobe/grey
	name = "grey wardrobe"
	closed_door_sprite = "grey"

/obj/structure/closet/wardrobe/grey/populate_contents()
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/under/color/jumpskirt/grey(src)
	new /obj/item/clothing/under/color/jumpskirt/grey(src)
	new /obj/item/clothing/under/color/jumpskirt/grey(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/clothing/head/soft(src)
	if(prob(50))
		new /obj/item/storage/backpack/duffel(src)
	if(prob(40))
		new /obj/item/clothing/under/misc/assistantformal(src)
	if(prob(40))
		new /obj/item/clothing/under/misc/assistantformal(src)


/obj/structure/closet/wardrobe/mixed
	name = "mixed wardrobe"
	closed_door_sprite = "mixed"

/obj/structure/closet/wardrobe/mixed/populate_contents()
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/jumpskirt/blue(src)
	new /obj/item/clothing/under/color/jumpskirt/yellow(src)
	new /obj/item/clothing/under/color/jumpskirt/green(src)
	new /obj/item/clothing/under/color/jumpskirt/orange(src)
	new /obj/item/clothing/under/color/jumpskirt/pink(src)
	new /obj/item/clothing/shoes/blue(src)
	new /obj/item/clothing/shoes/yellow(src)
	new /obj/item/clothing/shoes/green(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/purple(src)
	new /obj/item/clothing/shoes/leather(src)

/obj/structure/closet/wardrobe/coroner
	name = "coroner wardrobe"
	closed_door_sprite = "black"

/obj/structure/closet/wardrobe/coroner/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/suit/storage/labcoat/mortician(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/under/rank/medical/scrubs/coroner(src)
	new /obj/item/clothing/head/surgery/black(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/formaldehyde(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/healthanalyzer(src)
