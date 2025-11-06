/* CONTENTS:
* 1. ID BADGES
* 2. EQUIPMENT
* 3. PAPERS
* 4. RIG MODSUIT
* 5. CHEMICAL BOTTLES
* 6. ENGINES
* 7. AREAS
*/
//////////////////////////////
// MARK: ID BADGES
//////////////////////////////
/obj/item/card/id/away/old
	name = "A perfectly retrograde identification card"
	desc = "A perfectly retrograde identification card. Looks like it could use some flavor."
	icon_state = "retro"
	access = list(ACCESS_THETA_STATION)

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
	icon_state = "retro_engineering"
	access = list(ACCESS_ENGINE_EQUIP)

/obj/item/storage/backpack/old
	max_combined_w_class = 12

//////////////////////////////
// MARK: EQUIPMENT
//////////////////////////////
/obj/item/storage/firstaid/ancient
	name = "first-aid kit"
	icon_state = "firstaid_regular"
	inhand_icon_state = "firstaid_regular"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/firstaid/ancient/populate_contents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)

/obj/item/clothing/head/helmet/space/void/old
	name = "Antique Engineering Void Helmet"
	desc = "An old helmet meant for EVA engineering work. Any insignia it had has long since worn away. While old and dusty, it still gets the job done."

/obj/item/clothing/suit/space/void/old
	name = "Antique Engineering Void Suit"
	desc = "An old softsuit meant for engineering work. Any insignia it had has long since worn away. Age has degraded the suit making it difficult to move around in."
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

/obj/item/clothing/head/helmet/old
	name = "degrading helmet"
	desc = "Standard issue security helmet. Due to degradation the helmet's visor obstructs the users ability to see long distances."
	tint = FLASH_PROTECTION_WELDER

/obj/item/clothing/suit/armor/vest/old
	name = "degrading armor vest"
	desc = "Older generation Type 1 armored vest. Due to degradation over time the vest is far less maneuverable to move in."
	slowdown = 1

/obj/item/gun/energy/laser/retro/old
	name = "degrading L-1 laser gun"
	desc = "A first-generation lasergun developed by Maiman Photonics. It has a unique rechargable internal cell that cannot be removed. \
	Due to degredation over time, the battery cannot hold as much charge as it used to. You really hope someone has developed a better laser gun while you were in cryo."
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/old)

/obj/item/ammo_casing/energy/lasergun/old
	e_cost = 200

/obj/item/gun/energy/e_gun/old
	name = "\improper NT-EW-P:01 prototype energy gun"
	desc = "A long-lost prototype energy gun developed by Nanotrasen's Theta R&D team. The fire selector has two settings: 'stun', and 'kill'."
	icon_state = "protolaser"
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode/old)

/obj/item/gun/energy/e_gun/old/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Despite the passage of time, [src] looks remarkably well-preserved.</span>"

/obj/item/gun/energy/e_gun/old/examine_more(mob/user)
	..()
	. = list()
	. += "The Nanotrasen Energy Weapon Prototype 1, also officially designated \"NT-EW-P:01\", is a unique hand-built weapon that was developed by Nanotrasen's Theta R&D division prior to the station going dark. \
	The computerised schematics have long-since been corrupted, so only this singular example remains."
	. += ""
	. += "For its time, it was a groundbreaking design, both able to efficiently fire damaging lasers, as well as launch an incapacitating electrical discharge at a target - although the latter mode uncontrollably drained \
	the gun's battery, an issue that the team hoped to solve in later models."
	. += ""
	. += "With the loss of this prototype and the research surrounding it, Nanotrasen lost the race to be the first into the advanced energy weapons market to Shellguard Munitions when they released their EG series. \
	Since then Nanotrasen has been working tirelessly to close the research gap so it can establish dominance in the market with its extensive line of experimental weapons in development."

/obj/item/ammo_casing/energy/electrode/old
	e_cost = 1000

//////////////////////////////
// MARK: PAPERS
//////////////////////////////
/obj/item/paper/fluff/ruins/oldstation/protosuit
	name = "\improper B01-RIG Hardsuit Report"
	info = "<b>*Prototype Hardsuit*</b><br><br>The B01-RIG Hardsuit is a prototype powered exoskeleton. Based off of a recovered pre-void war era united Earth government powered military \
	exosuit, the RIG Hardsuit is a breakthrough in Hardsuit technology, and is the first post-void war era Hardsuit that can be safely used by an operator.<br><br>The B01 however suffers \
	a myriad of constraints. It is slow and bulky to move around, it lacks any significant armor plating against direct attacks and its internal heads up display is unfinished,  \
	resulting in the user being unable to see long distances.<br><br>The B01 is unlikely to see any form of mass production, but will serve as a base for future Hardsuit developments."

/obj/item/paper/fluff/ruins/oldstation/protohealth
	name = "\improper Health Analyser Report"
	info = "<b>*Health Analyser*</b><br><br>The portable Health Analyser is essentially a handheld variant of a health analyser. Years of research have concluded with this device which is \
	capable of diagnosing even the most critical, obscure or technical injuries any humanoid entity is suffering in an easy to understand format that even a non-trained health professional \
	can understand.<br><br>The health analyser is expected to go into full production as standard issue medical kit."

/obj/item/paper/fluff/ruins/oldstation/protogun
	name = "\improper NT-EW-P:01 Prototype Energy Gun Report"
	info = "<b>*Nanotrasen Energy Weapon Prototype 1*</b><br>\
	<br>\
	The NT-EW-P:01 energy rifle has successfully demonstrated a greater ammunition capacity than contemporary laser arms, and is capable of swapping between different energy projectile types on command, with no incidents.\
	<br>\
	The weapon still suffers drawbacks. Its alternative, non-laser fire mode can only fire one round before exhausting the energy cell, the weapon also remains prohibitively expensive. \
	Nonetheless, NT Market Research fully believes this weapon will form the backbone of our energy weapon catalogue once these issues can be ironed out.<br>\
	<br>\
	R&D expects that they should be able to fix the energy drain of the alternate fire mode in the next revision. There are also plans to testbed a so-called \"disabler\" mode further down the line, which may reduce costs."

/obj/item/paper/fluff/ruins/oldstation/protosing
	name = "\improper Singularity Generator"
	info = "<b>*Singularity Generator*</b><br><br>Modern power generation typically comes in two forms, a Fusion Generator or a Fission Generator. Fusion provides the best space to power \
	ratio, and is typically seen on military or high security ships and stations, however Fission reactors require the usage of expensive, and rare, materials in its construction.. Fission generators are massive and bulky, and require a large reserve of uranium to power, however they are extremely cheap to operate and oft need little maintenance once \
	operational.<br><br>The Singularity aims to alter this, a functional Singularity is essentially a controlled Black Hole, a Black Hole that generates far more power than Fusion or Fission \
	generators can ever hope to produce. "

/obj/item/paper/fluff/ruins/oldstation/protoinv
	name = "\improper Laboratory Inventory"
	info = "<b>*Inventory*</b><br><br>(1) Prototype Hardsuit<br><br>(1)Health Analyser<br><br>(1)Prototype Energy Gun<br><br>(1)Singularity Generation Disk<br><br><b>DO NOT REMOVE WITHOUT \
	THE CAPTAIN AND RESEARCH DIRECTOR'S AUTHORISATION</b>"

/obj/item/paper/fluff/ruins/oldstation/generator_manual
	name = "S.U.P.E.R.P.A.C.M.A.N.-type portable generator manual"
	info = "You can barely make out a faded sentence... <br><br> Wrench down the generator on top of a wire node connected to either a SMES input terminal or the power grid."


//////////////////////////////
// MARK: RIG MODSUIT
//////////////////////////////
/obj/item/clothing/head/helmet/space/hardsuit/ancient
	name = "prototype RIG hardsuit helmet"
	desc = "Early prototype RIG hardsuit helmet, designed to quickly shift over a user's head. Design constraints of the helmet mean it has no inbuilt cameras, thus it restricts the users visability."
	icon_state = "hardsuit0-ancient"
	armor = list(MELEE = 30, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 50, RAD = INFINITY, FIRE = INFINITY, ACID = 75)
	base_icon_state = "ancient"
	resistance_flags = FIRE_PROOF
	flags_2 = RAD_PROTECT_CONTENTS_2
	sprite_sheets = null

/obj/item/clothing/suit/space/hardsuit/ancient
	name = "prototype RIG hardsuit"
	desc = "Prototype powered RIG hardsuit. Provides excellent protection from the elements of space while being comfortable to move around in, thanks to the powered locomotives. Remains very bulky however."
	icon_state = "hardsuit-ancient"
	armor = list(MELEE = 30, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 50, RAD = INFINITY, FIRE = INFINITY, ACID = 75)
	slowdown = 3
	resistance_flags = FIRE_PROOF
	flags_2 = RAD_PROTECT_CONTENTS_2
	sprite_sheets = null
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ancient
	var/footstep = 1

/obj/item/clothing/suit/space/hardsuit/ancient/on_mob_move(dir, mob/mob)
	var/mob/living/carbon/human/H = mob
	if(!istype(H) || H.wear_suit != src || !isturf(H.loc))
		return
	if(footstep > 1)
		playsound(src, 'sound/effects/servostep.ogg', 100, 1)
		footstep = 0
	else
		footstep++
	..()

//////////////////////////////
// MARK: CHEMICAL BOTTLES
//////////////////////////////
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

/// Secure Crates: Access locked to Theta crew. Cannot be moved, destroyed,
/// emagged or EMPed because gamers can't be trusted not to game.
/obj/structure/closet/crate/secure/oldstation
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	req_access = list(ACCESS_THETA_STATION)

/// Allow Theta crew to move the crates once unlocked so they don't get in the way
/obj/structure/closet/crate/secure/oldstation/togglelock(mob/user)
	if(!..())
		return

	anchored = locked

	if(anchored)
		to_chat(user, "<span class='notice'>The crate reanchors itself to the ground.</span>")
	else
		to_chat(user, "<span class='notice'>The crate unanchors itself from the ground.</span>")

/obj/structure/closet/crate/secure/oldstation/emag_act(mob/user)
	// var/can_be_emaged works in mysterious ways so screw it
	return

/obj/structure/closet/crate/secure/oldstation/emp_act(severity)
	return

/obj/structure/closet/crate/secure/oldstation/security
	name = "security equipment crate"
	desc = "A crate containing various security equipment."
	icon_state = "secgearcrate"
	icon_opened = "secgearcrate_open"
	icon_closed = "secgearcrate"

/obj/structure/closet/crate/secure/oldstation/security/populate_contents()
	new /obj/item/gun/energy/laser/retro/old(src)
	new /obj/item/gun/energy/laser/retro/old(src)
	new /obj/item/clothing/suit/armor/vest/old(src)
	new /obj/item/clothing/head/helmet/old(src)

/obj/structure/closet/crate/secure/oldstation/rechargers
	name = "recharger crate"
	desc = "A crate containing the components to build weapon rechargers."

/obj/structure/closet/crate/secure/oldstation/rechargers/populate_contents()
	new /obj/item/circuitboard/recharger(src)
	new /obj/item/circuitboard/recharger(src)
	new /obj/item/stock_parts/capacitor(src)
	new /obj/item/stock_parts/capacitor(src)
	new /obj/item/stack/cable_coil/ten(src)
	new /obj/item/stack/sheet/metal/ten(src)
	new /obj/item/screwdriver(src)

/obj/structure/closet/crate/secure/oldstation/research
	name = "research crate"
	desc = "A crate containing the components necessary to perform research."
	icon_state = "scisecurecrate"
	icon_opened = "scisecurecrate_open"
	icon_closed = "scisecurecrate"

/obj/structure/closet/crate/secure/oldstation/research/populate_contents()
	new /obj/item/circuitboard/circuit_imprinter(src)
	new /obj/item/circuitboard/scientific_analyzer(src)
	new /obj/item/circuitboard/protolathe(src)
	new /obj/item/circuitboard/rdconsole/public(src)
	new /obj/item/circuitboard/rnd_network_controller(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/micro_laser(src)
	new /obj/item/stock_parts/scanning_module(src)

/obj/structure/closet/crate/secure/oldstation/surgery
	name = "surgery crate"
	desc = "A crate containing surgical tools and equipment."
	icon_state = "medicalsecurecrate"
	icon_opened = "medicalsecurecrate_open"
	icon_closed = "medicalsecurecrate"

/obj/structure/closet/crate/secure/oldstation/surgery/populate_contents()
	new /obj/item/circular_saw(src)
	new /obj/item/retractor(src)
	new /obj/item/hemostat(src)
	new /obj/item/scalpel(src)
	new /obj/item/cautery(src)
	new /obj/item/fix_o_vein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)

//////////////////////////////
// MARK: ENGINES
//////////////////////////////
/obj/structure/shuttle/engine/large
	opacity = TRUE
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	desc = "A very large sublight engine used to propel very large ships."
	bound_width = 64
	bound_height = 64
	appearance_flags = LONG_GLIDE

/obj/structure/shuttle/engine/huge
	icon = 'icons/obj/3x3.dmi'
	icon_state = "huge_engine"
	desc = "An extremely large bluespace engine used to propel extremely large ships."
	opacity = TRUE
	bound_width = 96
	bound_height = 96
	appearance_flags = LONG_GLIDE

//////////////////////////////
// MARK: AREAS
//////////////////////////////
//Ruin of ancient Space Station
/area/ruin/ancientstation
	name = "Charlie Station Main Corridor"
	icon_state = "green"

/area/ruin/ancientstation/powered
	name = "Powered Tile"
	icon_state = "teleporter"
	requires_power = FALSE

/area/ruin/ancientstation/atmo
	name = "Beta Station Atmospherics"
	icon_state = "red"
	has_gravity = FALSE
	ambientsounds = ENGINEERING_SOUNDS

/area/ruin/ancientstation/betanorth
	name = "Beta Station North Corridor"
	icon_state = "purple"

/area/ruin/ancientstation/engi
	name = "Charlie Station Engineering"
	icon_state = "engine"
	ambientsounds = ENGINEERING_SOUNDS

/area/ruin/ancientstation/comm
	name = "Charlie Station Command"
	icon_state = "captain"

/area/ruin/ancientstation/hydroponics
	name = "Charlie Station Hydroponics"
	icon_state = "hydro"

/area/ruin/ancientstation/kitchen
	name = "Charlie Station Kitchen"
	icon_state = "kitchen"

/area/ruin/ancientstation/sec
	name = "Charlie Station Security"
	icon_state = "red"

/area/ruin/ancientstation/thetacorridor
	name = "Theta Station Main Corridor"

/area/ruin/ancientstation/proto
	name = "Theta Station Prototype Lab"
	icon_state = "scilab"

/area/ruin/ancientstation/rnd
	name = "Theta Station Research and Development"
	icon_state = "rnd"

/area/ruin/ancientstation/hivebot
	name = "Hivebot Mothership"
	icon_state = "teleporter"
	requires_power = FALSE

// MARK: LORE CONSOLES

/obj/machinery/computer/loreconsole/oldstation/damage_report
	entries = list(
		new/datum/lore_console_entry(
			"Damage Report",
			{"**Alpha Station** - Destroyed.

**Beta Station** - Catastrophic Damage. Medical, destroyed. Atmospherics, partially destroyed. Engine Core, destroyed.

**Charlie Station** - Intact. Loss of oxygen to eastern side of main corridor.

**Theta Station** - Intact. **WARNING**: Unknown force occupying Theta Station. Intent unknown. Species unknown. Numbers unknown.

Recommendation - Reestablish station powernet via solar array. Reestablish station atmospherics system to restore air."}))

/obj/machinery/computer/loreconsole/oldstation/crew_awakening_report
	entries = list(
		new/datum/lore_console_entry(
			"Crew Awakening Report",
			{"## WARNING

Catastrophic damage sustained to station.
Powernet exhausted to reawaken crew.

## Immediate Objectives

1. Activate emergency power generator.
2. Lift station lockdown on the bridge.

Please locate the 'Damage Report' on the bridge for a detailed situation report."}))

/obj/machinery/computer/loreconsole/oldstation/report
	name = "\improper Crew Reawakening Report"

/obj/machinery/computer/loreconsole/oldstation/report/Initialize(mapload)
	. = ..()
	init_current_date_string()
	entries += new/datum/lore_console_entry(
		"Crew Reawakening Report",
		{"Artificial Program's report to surviving crewmembers.

Crew were placed into cryostasis 10 March, 2445.

Crew were awoken from cryostasis [GLOB.current_date_string].

**SIGNIFICANT EVENTS OF NOTE**

1. The primary radiation detectors were taken offline after [GLOB.game_year - 2445] years due to power failure.
	Secondary radiation detectors showed no residual radiation on station.
	Deduction: primarily detector was malfunctioning and was producing a radiation signal when there was none.
2. A data burst from a nearby Nanotrasen Space Station was received, this data burst contained research data that has been uploaded to our RnD labs.
3. Unknown invasion force has occupied Theta station."})

