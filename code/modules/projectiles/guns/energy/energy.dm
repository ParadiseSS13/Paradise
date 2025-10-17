/* CONTENTS:
* 1. ENERGY GUN
* 2. MINI ENERGY GUN
* 3. X-01 ENERGY GUN
* 4. ENERGY REVOLVER
* 5. PDW-9 PISTOL
* 6. HYBRID TURRET GUN
* 7. ADVANCED ENERGY GUN
* 8. ENERGY SHOTGUN
*/
//////////////////////////////
// MARK: ENERGY GUN
//////////////////////////////
/obj/item/gun/energy/gun
	name = "\improper EG-7 energy gun"
	desc = "A hybrid fire energy gun manufactured by Shellguard Munitions Co. It has a mounting point for a flashlight. The fire selector has two settings: 'disable', and 'kill'."
	inhand_icon_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	origin_tech = "combat=4;magnets=3"
	modifystate = 2
	can_flashlight = TRUE
	flight_x_offset = 20
	flight_y_offset = 10
	shaded_charge = TRUE
	execution_speed = 5 SECONDS

/obj/item/gun/energy/gun/examine_more(mob/user)
	..()
	. = list()
	. += "A hybrid fire laser gun designed and patentend by Shellguard Munitions Co. Initally designed after market demand for a versatile weapon that merges disabler and laser \
	functions without the need for switching weapons during active threats. This would cause the company to experiment and produce a weapon to fit between Shellguard's own disabler and LG series weapons. \
	This led to the creation of the EG series, positioning the EG-7 as a flagship model intended to eventually replace Shellguard's disabler pistols and LG series weapons."
	. += ""
	. += "Its design is an evolution of the disabler pistol frame, featuring a rotating lens within its firing chamber to toggle between non-lethal and lethal shots. \
	Further modifications include an extension of the weapon's length, using elements from the LG series, and a transition to carbon composites for a sleeker, modern look. \
	This design shift would evolve Shellguard’s traditional military style, aligning more with the aesthetics preferred by corporations which value clean, sharp, and modern looking weapons."
	. += ""
	. += "In modern times, the EG-7 is staple weapon among corporate security forces thanks to its relatively low price, dual fire modes, and customization potential (despite Shellguard's disclaimer that \
	tampering with the weapon void's its warranty and can potentially damage the gun itself)."

/obj/item/gun/energy/gun/cyborg
	name = "mounted EG-7 energy gun"
	desc = "A frame-mounted EG-7 laser gun that draws power directly from your internal energy cell. This probably voids the gun's warranty. The fire selector has two settings: 'disable', and 'kill'."

/obj/item/gun/energy/gun/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/gun/cyborg/emp_act()
	return

//////////////////////////////
// MARK: MINI ENERGY GUN
//////////////////////////////
/obj/item/gun/energy/gun/mini
	name = "\improper EG-8 miniature energy gun"
	desc = "A pistol-sized energy gun with a built-in flashlight. The power cell is smaller too. Issued for self-defence purposes. The fire selector has two settings: 'disable', and 'kill'."
	icon_state = "mini"
	w_class = WEIGHT_CLASS_SMALL
	charge_sections = 3
	inhand_charge_sections = 3
	can_flashlight = FALSE // Can't attach or detach the flashlight, and override it's icon update
	actions_types = list(/datum/action/item_action/toggle_gunlight)
	shaded_charge = FALSE
	can_holster = TRUE  // Pistol sized, so it should fit into a holster
	execution_speed = 4 SECONDS

/obj/item/gun/energy/gun/mini/examine_more(mob/user)
	..()
	. = list()
	. += "The EG-8 is a compacted version of Shellguard Munitions' EG-7 Energy Gun, specifically designed as an easily concealable personal defence weapon. \
	It is is commonly found in the pockets of private individuals and corporate management alike."
	. += ""
	. += "The pistol packs the same punch as its bigger brother, but the compact frame has come at the cost of a smaller power cell, making it less suitable for extended engagements. \
	Despite this, it is responsible for thwarting numerous attempted muggings, kidnappings, and assassinations across the Sector ever year."

/obj/item/gun/energy/gun/mini/Initialize(mapload, ...)
	gun_light = new /obj/item/flashlight/seclite(src)
	. = ..()
	cell.maxcharge = 600
	cell.charge = 600

/obj/item/gun/energy/gun/mini/update_overlays()
	. = ..()
	if(gun_light && gun_light.on)
		. += "mini-light"

//////////////////////////////
// MARK: X-01 ENERGY GUN
//////////////////////////////
/obj/item/gun/energy/gun/hos
	name = "\improper X-01 MultiPhase Energy Gun"
	desc = "This is an expensive, modern recreation of an antique laser gun. The fire selector has three settings: 'disable', 'ion', 'kill'. Unfortunately, it has lost the ability to recharge over time."
	cell_type = /obj/item/stock_parts/cell/energy_gun/hos_gun
	icon_state = "hoslaser"
	origin_tech = null
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/ion/hos)
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	shaded_charge = FALSE
	can_holster = TRUE

/obj/item/gun/energy/gun/hos/examine_more(mob/user)
	..()
	. = list()
	. += "The X-01 MultiPhase Energy Gun is one of a handful of newly-minted prototypes created by Nanotrasen's weaponry R&D division. \
	The frame is based on that of the custom-made antique laser gun, also found in this facility. \
	Just like the antique laser that inspired it, the X-01 is a testbed for the latest advances in energy weapon technology."
	. += ""
	. += "The pistol manages to combine the functions of a disabler, laser, and ion gun into a single pistol-sized package using a unique hybrid optical-electromagnetic projection assembly that can seamlessly \
	transition between the weapon's different firing modes. This assembly is also excruciatingly difficult to manufacture - even the slightest deviation from the design's demanding tolerances \
	results in a non-functional paperweight. Nonetheless, the promises of compact versatility it brings has kept the X-01 project's finances flowing for now."
	. += ""
	. += "Unfortunately, the micro-fission reactor used to self-charge the power cell of the antique gun could not be replicated, and so this feature is absent in the X-01's current design. \
	Continued research into the technology is ongoing. Heads of Security throughout the Epsilon Eridani sector have been issued the various X-01 prototypes for field testing, \
	and are to issue a report on their findings after any shift in which they employ the weapon."

/obj/item/gun/energy/gun/hos/Initialize(mapload, ...)
	. = ..()
	AddElement(/datum/element/high_value_item)

//////////////////////////////
// MARK: ENERGY REVOLVER
//////////////////////////////
/obj/item/gun/energy/gun/blueshield
	name = "\improper EG-14 advanced energy revolver"
	desc = "An advanced, pistol sized energy gun. It looks stylish, and the design makes it slightly better at bludgeoning. The fire selector has two settings: 'disable', and 'kill'."
	icon_state = "bsgun"
	cell_type = /obj/item/stock_parts/cell/energy_gun/hos_gun
	force = 7
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/hos, /obj/item/ammo_casing/energy/laser/hos)
	ammo_x_offset = 1
	can_holster = TRUE

/obj/item/gun/energy/gun/blueshield/examine_more(mob/user)
	..()
	. = list()
	. += "The EG-14 is Shellguard Munitions' premium offering in the energy weapons market. It is equal to or superior to the EG-7 in every way, boasting the same fire rate, \
	stopping power, and cell capacity, whilst also being better suited as an improvised melee weapon thanks to superior ergonomics and weight distribution - all offered in a pistol-sized form factor."
	. += ""
	. += "The revolver's cylinder does indeed rotate with every shot, and it can be spun just like the cylinder of a ballistic revolver - although this has no bearing on the actual functionality of the weapon, \
	and is included purely as a stylistic embellishment."
	. += ""
	. += "The price of the EG-14 puts it out of reach of a large portion of the market, but it sells very well among bodyguards and bountyhunters."

//////////////////////////////
// MARK: PDW-9 PISTOL
//////////////////////////////
/obj/item/gun/energy/gun/blueshield/pdw9
	name = "\improper PDW-9 energy pistol"
	desc = "A military-grade energy pistol favored by mercenaries and militia forces. The fire selector has two settings: 'disable', and 'kill'."
	icon_state = "pdw9pistol"
	inhand_icon_state = "gun"

/obj/item/gun/energy/gun/blueshield/pdw9/examine_more(mob/user)
	..()
	. = list()
	. += "The PDW-9 is a ruggedized energy pistol made by Shellguard Munitions as a sidearm for military customers. \
	It utilizes much of the same technology as the EG-14, and is indeed just as effective, but the frills and embellishments have been discarded in favour of a more utilitarian design."
	. += ""
	. += "Whilst it can occasionally be found in civilian settings, it's most likely to be seen in the holster of a soldier, mercenary, or elite corporate security."

//////////////////////////////
// MARK: HYBRID TURRET GUN
//////////////////////////////
/obj/item/gun/energy/gun/turret
	name = "\improper AG(H)-22 hybrid turret gun"
	desc = "A heavy hybrid energy cannon made for mounted emplacements. The fire selector has two settings: 'stun', and 'kill'."
	icon_state = "turretlaser"
	inhand_icon_state = "turretlaser"
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	weapon_weight = WEAPON_HEAVY
	can_flashlight = FALSE
	trigger_guard = TRIGGER_GUARD_NONE
	shaded_charge = FALSE
	execution_speed = 8 SECONDS

/obj/item/gun/energy/gun/turret/examine(mob/user)
	. = ..()
	. += "<span class='warning'>This weapon has no internal power source. It cannot function without being mounted in a turret frame!</span>"

/obj/item/gun/energy/gun/turret/examine_more(mob/user)
	..()
	. = list()
	. += "The AG(H)-22 is part of a long line of developments in automated weapon emplacement technology, manufactured by Shellguard Munitions for static area defence."
	. += ""
	. += "A high-powered laser with an electrode gun bolted onto it to allow a choice of lethal or less-than-lethal response to unauthorised access. Freed from the requirement to be mobile, \
	this weapon and others like it offload many of their operational requirements such as cooling or power to external hardware, dramatically increasing reliability and reducing the technical \
	know-how to make a functioning unit."
	. += ""
	. += "Just don't expect to pick one up and be able to shoot it in your hands."

//////////////////////////////
// MARK: ADVANCED ENERGY GUN
//////////////////////////////
/obj/item/gun/energy/gun/nuclear
	name = "advanced energy gun"
	desc = "An energy gun with an experimental miniaturized nuclear reactor that automatically charges the internal power cell."
	icon_state = "nucgun"
	origin_tech = "combat=4;magnets=4;powerstorage=4"
	var/fail_tick = 0
	charge_delay = 5
	can_charge = FALSE
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/disabler)
	selfcharge = TRUE
	shaded_charge = FALSE

/obj/item/gun/energy/gun/nuclear/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] contains a miniturised nuclear reactor that will slowly reacharge its power cell at all times. It can still be put into a gun charger for faster charging.</span>"
	. += "<span class='notice'>Known to drive people mad by forcing them to wait for shots to recharge.</span>"

/obj/item/gun/energy/gun/nuclear/examine_more(mob/user)
	..()
	. = list()
	. += "The Advanced Energy Gun project is part of Nanotrasen R&D's attempts to recreate the micro-fission reactor of the Antique Energy Gun."
	. += ""
	. += "Intense efforts have been partially successful - Nanotrasen is now capable of creating sufficiently small reactors to fit in a rifle-sized weapon at a reasonable cost of credits and material. \
	However, the ultimate goal of making an affordable recreation at the scale of the original Antique have thus far still failed."
	. += ""
	. += "Nonetheless, Nanotrasen Marketing is very pleased with the current product, and hopes that it can soon be sold on the galactic market to customers that wish to employ energy weapons \
	free from the logistical constraints of recharging stations."

//////////////////////////////
// MARK: ENERGY SHOTGUN
//////////////////////////////
/obj/item/gun/energy/gun/shotgun
	name = "ES-9 Energy Scatterbeam"
	desc = "A hybrid fire energy shotgun manufactured by Shellguard Munitions Co. The pump changes the modes between 'disable' and 'kill'."
	icon_state = "eshotgun"
	origin_tech = "combat=5;magnets=5"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	var/fail_tick = 0
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/eshotgun, /obj/item/ammo_casing/energy/laser/eshotgun)
	lens_damage_cap = 1.5 // Caps at 90 stamina damage, to prevent one shot stamina crits.
	var/pump_time = 1 SECONDS
	COOLDOWN_DECLARE(pump_cooldown)

/obj/item/gun/energy/gun/shotgun/select_fire(mob/living/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, pump_cooldown))
		return
	playsound(user, 'sound/weapons/gun_interactions/shotgunpump.ogg', 60, TRUE)
	COOLDOWN_START(src, pump_cooldown, pump_time)

/obj/item/gun/energy/gun/shotgun/examine_more(mob/user)
	..()
	. = list()
	. += "The ES-9 is a larger and heavier version of Shellguard Munitions' EG-7 Energy Gun. Featuring a heavier power core and a set of prisms for splitting the primary beam into multiple shots, this energy weapon emulates the common shotgun."
	. += ""
	. += "This scatter-beam technology allows for more energy output per trigger pull, however the increased heat on the focusing lens has resulted in a decreased fire rate compared to the standard fare. \
	It is a Nanotrasen officer's best friend, allowing them to stop crime one trigger pull at a time."

/obj/item/gun/energy/gun/shotgun/cyborg
	name = "Energy Scatterbeam"
	desc = "An energy emitter that fires spread-fire laser shells."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/eshotgun/cyborg)

/obj/item/gun/energy/gun/shotgun/newshot()
	..()
	robocharge()

/obj/item/gun/energy/emitter/gun/shotgun/emp_act()
	return

// MARK: FAKE ENERGY GUN
/obj/item/gun/energy/gun/fake
	name = "replica EG-7 energy gun"
	desc = "It's a laser tag gun redesigned with a few pieces of cheap plastic to look like an EG-7 energy gun, so you won't harm anyone. This one isn't even sanctioned for laser tag, sad."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/fake)
	can_flashlight = FALSE
	selfcharge = TRUE
	can_charge = FALSE
	throwforce = 0
