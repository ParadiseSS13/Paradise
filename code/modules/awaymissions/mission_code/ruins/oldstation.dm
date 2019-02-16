// items
/obj/item/storage/firstaid/ancient
	icon_state = "firstaid"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/firstaid/ancient/New()
	..()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)

/obj/item/card/id/away/old
	name = "A perfectly retrograde identification card"
	desc = "A perfectly retrograde identification card. Looks like it could use some flavor."
	icon = 'icons/obj/card.dmi'
	icon_state = "retro"
	access = list(access_away01)

/obj/item/card/id/away/old/sec
	name = "Security Officer ID"
	desc = "A clip on ID Badge, has one of those fancy new magnetic strips built in. This one is encoded for the Security Dept."
	icon_state = "retro_security"

/obj/item/card/id/away/old/sci
	name = "Scientist ID"
	desc = "A clip on ID Badge, has one of those fancy new magnetic strips built in. This one is encoded for the Science Dept."
	icon_state = "retro_research"

/obj/item/card/id/away/old/med
	name = "Medical ID"
	desc = "A clip on ID Badge, has one of those fancy new magnetic strips built in. This one is encoded for the Medical Dept."
	icon_state = "retro_medical"

/obj/item/card/id/away/old/eng
	name = "Engineer ID"
	desc = "A clip on ID Badge, has one of those fancy new magnetic strips built in. This one is encoded for the Engineering Dept."
	icon_state = "retro_engineering"

/obj/item/card/id/away/old/apc
	name = "APC Access ID"
	desc = "A special ID card that allows access to APC terminals."
	icon_state = "centcom_old"
	access = list(access_engine_equip)

/obj/item/storage/backpack/old
	max_combined_w_class = 12

// Equipment
/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "Engineering Void Helmet"
	desc = "A CentCom engineering dark red space suit helmet. While old and dusty, it still gets the job done."
	icon_state = "void-red"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid/old
	name = "Engineering Voidsuit"
	icon_state = "void-red"
	item_state = "void"
	desc = "A CentCom engineering dark red space suit. Age has degraded the suit making is difficult to move around in."
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/multitool)

/obj/item/clothing/head/helmet/old
	name = "degrading helmet"
	desc = "Standard issue security helmet. Due to degradation the helmet's visor obstructs the users ability to see long distances."
	tint = 2

/obj/item/clothing/suit/armor/vest/old
	name = "degrading armor vest"
	desc = "Older generation Type 1 armored vest. Due to degradation over time the vest is far less maneuverable to move in."
	icon_state = "armor"
	item_state = "armor"
	slowdown = 1

/obj/item/gun/energy/laser/retro/old
	name ="laser gun"
	icon_state = "retro"
	desc = "First generation lasergun, developed by Nanotrasen. Suffers from ammo issues but its unique ability to recharge its ammo without the need of a magazine helps compensate. You really hope someone has developed a better lasergun while you were in cryo."
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/old)
	ammo_x_offset = 3

/obj/item/ammo_casing/energy/lasergun/old
	projectile_type = /obj/item/projectile/beam/laser
	e_cost = 200
	select_name = "kill"

/obj/item/gun/energy/e_gun/old
	name = "prototype energy gun"
	desc = "NT-P:01 Prototype Energy Gun. Early stage development of a unique laser rifle that has multifaceted energy lens allowing the gun to alter the form of projectile it fires on command."
	icon_state = "protolaser"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode/old)

/obj/item/ammo_casing/energy/electrode/old
	e_cost = 1000

// Papers
/obj/item/paper/fluff/ruins/oldstation
	name = "Cryo Awakening Alert"
	info = "<B>**WARNING**</B><BR><BR>Catastrophic damage sustained to station. Powernet exhausted to reawaken crew.<BR><BR>Immediate Objectives<br><br>1: Activate emergency power generator<br>2: Lift station lockdown on the bridge<br><br>Please locate the 'Damage Report' on the bridge for a detailed situation report."

/obj/item/paper/fluff/ruins/oldstation/damagereport
	name = "Damage Report"
	info = "<b>*Damage Report*</b><br><br><b>Alpha Station</b> - Destroyed<br><br><b>Beta Station</b> - Catastrophic Damage. Medical, destroyed. Atmospherics, partially destroyed. Engine Core, destroyed.<br><br><b>Charlie Station</b> - Intact. Loss of oxygen to eastern side of main corridor.<br><br><b>Delta Station</b> - Intact. <b>WARNING</b>: Unknown force occupying Delta Station. Intent unknown. Species unknown. Numbers unknown.<br><br>Recommendation - Reestablish station powernet via solar array. Reestablish station atmospherics system to restore air."

/obj/item/paper/fluff/ruins/oldstation/protosuit
	name = "B01-RIG Hardsuit Report"
	info = "<b>*Prototype Hardsuit*</b><br><br>The B01-RIG Hardsuit is a prototype powered exoskeleton. Based off of a recovered pre-void war era united Earth government powered military \
	exosuit, the RIG Hardsuit is a breakthrough in Hardsuit technology, and is the first post-void war era Hardsuit that can be safely used by an operator.<br><br>The B01 however suffers \
	a myriad of constraints. It is slow and bulky to move around, it lacks any significant armor plating against direct attacks and its internal heads up display is unfinished,  \
	resulting in the user being unable to see long distances.<br><br>The B01 is unlikely to see any form of mass production, but will serve as a base for future Hardsuit developments."

/obj/item/paper/fluff/ruins/oldstation/protohealth
	name = "Health Analyser Report"
	info = "<b>*Health Analyser*</b><br><br>The portable Health Analyser is essentially a handheld variant of a health analyser. Years of research have concluded with this device which is \
	capable of diagnosing even the most critical, obscure or technical injuries any humanoid entity is suffering in an easy to understand format that even a non-trained health professional \
	can understand.<br><br>The health analyser is expected to go into full production as standard issue medical kit."

/obj/item/paper/fluff/ruins/oldstation/protogun
	name = "K14 Energy Gun Report"
	info = "<b>*K14-Multiphase Energy Gun*</b><br><br>The K14 Prototype Energy Gun is the first Energy Rifle that has been successfully been able to not only hold a larger ammo charge \
	than other gun models, but is capable of swapping between different energy projectile types on command with no incidents.<br><br>The weapon still suffers several drawbacks, its alternative, \
	non laser fire mode, can only fire one round before exhausting the energy cell, the weapon also remains prohibitively expensive, nonetheless NT Market Research fully believe this weapon \
	will form the backbone of our Energy weapon catalogue.<br><br>The K14 is expected to undergo revision to fix the ammo issues, the K15 is expected to replace the 'stun' setting with a \
	'disable' setting in an attempt to bypass the ammo issues."

/obj/item/paper/fluff/ruins/oldstation/protosing
	name = "Singularity Generator"
	info = "<b>*Singularity Generator*</b><br><br>Modern power generation typically comes in two forms, a Fusion Generator or a Fission Generator. Fusion provides the best space to power \
	ratio, and is typically seen on military or high security ships and stations, however Fission reactors require the usage of expensive, and rare, materials in its construction.. Fission generators are massive and bulky, and require a large reserve of uranium to power, however they are extremely cheap to operate and oft need little maintenance once \
	operational.<br><br>The Singularity aims to alter this, a functional Singularity is essentially a controlled Black Hole, a Black Hole that generates far more power than Fusion or Fission \
	generators can ever hope to produce. "

/obj/item/paper/fluff/ruins/oldstation/protoinv
	name = "Laboratory Inventory"
	info = "<b>*Inventory*</b><br><br>(1) Prototype Hardsuit<br><br>(1)Health Analyser<br><br>(1)Prototype Energy Gun<br><br>(1)Singularity Generation Disk<br><br><b>DO NOT REMOVE WITHOUT \
	THE CAPTAIN AND RESEARCH DIRECTOR'S AUTHORISATION</b>"

/obj/item/paper/fluff/ruins/oldstation/report
	name = "Crew Reawakening Report"
	info = "Artificial Program's report to surviving crewmembers.<br><br>Crew were placed into cryostasis on March 10th, 2445.<br><br>Crew were awoken from cryostasis around June, 2557.<br><br> \
	<b>SIGNIFICANT EVENTS OF NOTE</b><br>1: The primary radiation detectors were taken offline after 112 years due to power failure, secondary radiation detectors showed no residual \
	radiation on station. Deduction, primarily detector was malfunctioning and was producing a radiation signal when there was none.<br><br>2: A data burst from a nearby Nanotrasen Space \
	Station was received, this data burst contained research data that has been uploaded to our RnD labs.<br><br>3: Unknown invasion force has occupied Delta station."

/obj/item/paper/fluff/ruins/oldstation/generator_manual
	name = "S.U.P.E.R.P.A.C.M.A.N.-type portable generator manual"
	info = "You can barely make out a faded sentence... <br><br> Wrench down the generator on top of a wire node connected to either a SMES input terminal or the power grid."


	//Old Prototype Hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/ancient
	name = "prototype RIG hardsuit helmet"
	desc = "Early prototype RIG hardsuit helmet, designed to quickly shift over a user's head. Design constraints of the helmet mean it has no inbuilt cameras, thus it restricts the users visability."
	icon_state = "hardsuit0-ancient"
	item_state = "anc_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 75)
	item_color = "ancient"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ancient
	name = "prototype RIG hardsuit"
	desc = "Prototype powered RIG hardsuit. Provides excellent protection from the elements of space while being comfortable to move around in, thanks to the powered locomotives. Remains very bulky however."
	icon_state = "hardsuit-ancient"
	item_state = "anc_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 75)
	slowdown = 3
	resistance_flags = FIRE_PROOF
	var/footstep = 1

/obj/item/clothing/suit/space/hardsuit/ancient/on_mob_move()
	var/mob/living/carbon/human/H = loc
	if(!istype(H) || H.wear_suit != src)
		return
	if(footstep > 1)
		playsound(src, 'sound/effects/servostep.ogg', 100, 1)
		footstep = 0
	else
		footstep++
	..()

// Chemical bottles
/obj/item/reagent_containers/glass/bottle/aluminum
	name = "aluminum bottle"
	list_reagents = list("aluminum" = 30)

/obj/item/reagent_containers/glass/bottle/hydrogen
	name = "hydrogen bottle"
	list_reagents = list("hydrogen" = 30)

/obj/item/reagent_containers/glass/bottle/lithium
	name = "lithium bottle"
	list_reagents = list("lithium" = 30)

/obj/item/reagent_containers/glass/bottle/carbon
	name = "carbon bottle"
	list_reagents = list("carbon" = 30)

/obj/item/reagent_containers/glass/bottle/nitrogen
	name = "nitrogen bottle"
	list_reagents = list("nitrogen" = 30)

/obj/item/reagent_containers/glass/bottle/oxygen
	name = "oxygen bottle"
	list_reagents = list("oxygen" = 30)

/obj/item/reagent_containers/glass/bottle/fluorine
	name = "fluorine bottle"
	list_reagents = list("fluorine" = 30)

/obj/item/reagent_containers/glass/bottle/sodium
	name = "sodium bottle"
	list_reagents = list("sodium" = 30)

/obj/item/reagent_containers/glass/bottle/silicon
	name = "silicon bottle"
	list_reagents = list("silicon" = 30)

/obj/item/reagent_containers/glass/bottle/phosphorus
	name = "phosphorus bottle"
	list_reagents = list("phosphorus" = 30)

/obj/item/reagent_containers/glass/bottle/sulfur
	name = "sulfur bottle"
	list_reagents = list("sulfur" = 30)

/obj/item/reagent_containers/glass/bottle/chlorine
	name = "chlorine bottle"
	list_reagents = list("chlorine" = 30)

/obj/item/reagent_containers/glass/bottle/potassium
	name = "potassium bottle"
	list_reagents = list("potassium" = 30)

/obj/item/reagent_containers/glass/bottle/iron
	name = "iron bottle"
	list_reagents = list("iron" = 30)

/obj/item/reagent_containers/glass/bottle/copper
	name = "copper bottle"
	list_reagents = list("copper" = 30)

/obj/item/reagent_containers/glass/bottle/mercury
	name = "mercury bottle"
	list_reagents = list("mercury" = 30)

/obj/item/reagent_containers/glass/bottle/radium
	name = "radium bottle"
	list_reagents = list("radium" = 30)

/obj/item/reagent_containers/glass/bottle/water
	name = "water bottle"
	list_reagents = list("water" = 30)

/obj/item/reagent_containers/glass/bottle/ethanol
	name = "ethanol bottle"
	list_reagents = list("ethanol" = 30)

/obj/item/reagent_containers/glass/bottle/sugar
	name = "sugar bottle"
	list_reagents = list("sugar" = 30)

/obj/item/reagent_containers/glass/bottle/sacid
	name = "sulphuric acid bottle"
	list_reagents = list("sacid" = 30)

/obj/item/reagent_containers/glass/bottle/welding_fuel
	name = "welding fuel bottle"
	list_reagents = list("fuel" = 30)

/obj/item/reagent_containers/glass/bottle/silver
	name = "silver bottle"
	list_reagents = list("silver" = 30)

/obj/item/reagent_containers/glass/bottle/iodine
	name = "iodine bottle"
	list_reagents = list("iodine" = 30)

/obj/item/reagent_containers/glass/bottle/bromine
	name = "bromine bottle"
	list_reagents = list("bromine" = 30)

// Engines
/obj/structure/shuttle/engine/large
	name = "engine"
	opacity = 1
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	desc = "A very large bluespace engine used to propel very large ships."
	bound_width = 64
	bound_height = 64
	appearance_flags = 0

// areas
//Ruin of ancient Space Station

/area/ruin/space/ancientstation
	name = "Charlie Station Main Corridor"
	icon_state = "green"
	has_gravity = TRUE

/area/ruin/space/ancientstation/powered
	name = "Powered Tile"
	icon_state = "teleporter"
	requires_power = FALSE

/area/ruin/space/ancientstation/space
	name = "Exposed To Space"
	icon_state = "teleporter"
	has_gravity = FALSE

/area/ruin/space/ancientstation/atmo
	name = "Beta Station Atmospherics"
	icon_state = "red"
	has_gravity = FALSE

/area/ruin/space/ancientstation/betanorth
	name = "Beta Station North Corridor"
	icon_state = "blue"

/area/ruin/space/ancientstation/solar
	name = "Station Solar Array"
	icon_state = "panelsAP"

/area/ruin/space/ancientstation/engi
	name = "Charlie Station Engineering"
	icon_state = "engine"

/area/ruin/space/ancientstation/comm
	name = "Charlie Station Command"
	icon_state = "captain"

/area/ruin/space/ancientstation/hydroponics
	name = "Charlie Station Hydroponics"
	icon_state = "garden"

/area/ruin/space/ancientstation/kitchen
	name = "Charlie Station Kitchen"
	icon_state = "kitchen"

/area/ruin/space/ancientstation/sec
	name = "Charlie Station Security"
	icon_state = "red"

/area/ruin/space/ancientstation/deltacorridor
	name = "Delta Station Main Corridor"
	icon_state = "green"

/area/ruin/space/ancientstation/proto
	name = "Delta Station Prototype Lab"
	icon_state = "toxlab"

/area/ruin/space/ancientstation/rnd
	name = "Delta Station Research and Development"
	icon_state = "toxlab"

/area/ruin/space/ancientstation/hivebot
	name = "Hivebot Mothership"
	icon_state = "teleporter"