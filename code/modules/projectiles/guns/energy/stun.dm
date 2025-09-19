/* CONTENTS:
* 1. TASER
* 2. HYBRID TASER
* 3. DISABLER
* 4. DISABLER SMG
* 5. U-ION SILENCER
* 6. ARC REVOLVER
*/
//////////////////////////////
// MARK: TASER
//////////////////////////////
/obj/item/gun/energy/taser
	name = "\improper X-260 taser"
	desc = "A less-lethal pistol that fires electrodes to incapacitate targets."
	icon_state = "taser"
	inhand_icon_state = null
	origin_tech = "combat=3"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3
	can_holster = TRUE  // Pistol size

/obj/item/gun/energy/taser/examine_more(mob/user)
	..()
	. = list()
	. += "The X-270 is produced by Shellguard Munitions, based on a long line of similar less-lethal weapon systems that go back centuries. \
	It is designed to allow law enforcement to take down noncompliant targets at a distance without having to resort to lethal force."
	. += ""
	. += "They work by firing a pair of electrodes into the target and then transmitting an electrical current through them. This electrical current is specifically modulated to interfere with the neuromuscular junction, \
	stimulating it and forcing the muscle into the contracted position, disabling movement."
	. += ""
	. += "Disablers have mostly replaced these weapons across known space, although the remain in certain specific niches where the immediate stopping power is desired."

//////////////////////////////
// MARK: HYBRID TASER
//////////////////////////////
/obj/item/gun/energy/gun/advtaser
	name = "\improper XD-2600 hybrid taser"
	desc = "An upgrade to Shellguard Munitions' X-260 that adds an integrated disabler for long-range takedowns. The fire selector has two settings: 'stun', and 'disable'."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	origin_tech = "combat=4"
	flight_x_offset = 15
	shaded_charge = FALSE
	can_holster = TRUE

/obj/item/gun/energy/gun/advtaser/examine_more(mob/user)
	..()
	. = list()
	. += "The XD-2600 is a high-end less-lethal weapon system offered by Shellguard for those echelons that still \
	make use of their original X-260s but also wish for the longer range offered by the disabler by simply combining both into a singular package."
	. += ""
	. += "Whilst tasers have been largely phased out by most law enforcement across known space, Shellguard continues to make a tidy profit providing these to those enforcement agencies that have not, \
	as well as private individuals seeking a potent less-lethal self defence tool, mostly in the corporate world."

/obj/item/gun/energy/gun/advtaser/cyborg
	name = "mounted XD-2600 hybrid taser"
	desc = "A modified XD-2600 hybrid taser that draws power directly from your internal energy cell. It contains a limiter to prevent your cell from overheating. The warranty expired two weeks ago."
	can_flashlight = FALSE
	can_charge = FALSE

/obj/item/gun/energy/gun/advtaser/cyborg/newshot()
	..()
	robocharge()

//////////////////////////////
// MARK: DISABLER
//////////////////////////////
/obj/item/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	inhand_icon_state = null
	origin_tech = "combat=3"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 10
	can_holster = TRUE
	execution_speed = 5 SECONDS

/obj/item/gun/energy/disabler/examine_more(mob/user)
	..()
	. = list()
	. += "The disabler is a less-than-lethal weapon designed to incapacitate targets without causing lasting harm. It was designed by Shellguard Munitions as an alternative to electroshock-based LTL weapons. \
	Its chief advantages are the longer ranges and massively reduced incidences of accidental fatalities."
	. += ""
	. += "It functions by emitting a precisely tuned ionised particle beam that is accelerated out of the barrel by a short electromagnetic coil stack. When the beam hits an organic target, \
	it selectively disrupts ATP binding sites in the myosin heads of the myofibrils in the skeletal musculature. \
	This initially causes slowdown of muscle contractions, but continued attack will result in almost complete paralysis of most voluntary skeletal muscle groups, along with feelings of extreme lethargy and fatigue. \
	These effects are temporary and will subside soon after, causing no lasting harm. By a massive stroke of coincidence, these same particle beams also exhibit a similar effect on the motors of IPC limbs."
	. += ""
	. += "The safety and efficiency of the disabler has caused it to rapidly replace tasers in police and security forces across most of known space, \
	although the lack of immediate stopping power has prevented a complete replacement."

/obj/item/gun/energy/disabler/Initialize(mapload)
	. = ..()
	cell.maxcharge = 800
	cell.charge = 800

/obj/item/gun/energy/disabler/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	var/obj/item/gun/energy/disabler/offhand_disabler = user.get_inactive_hand()
	if(istype(offhand_disabler) && offhand_disabler.semicd && (user.a_intent != INTENT_HARM))
		return

	return ..()

/obj/item/gun/energy/disabler/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the barrel of [src] in [user.p_their()] mouth. It looks like [user.p_theyre()] trying to shirk [user.p_their()] responsibilities!</span>")
	sleep(25)
	if(user.is_holding(src))
		if(can_shoot())
			playsound(loc, fire_sound, 50, TRUE, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			cell.use(shot.e_cost)
			update_icon()
		else
			playsound(loc, 'sound/weapons/empty.ogg', 50, TRUE, -1)
	else
		user.visible_message("<span class='suicide'>[user] fumbles [src]! [user.p_they(TRUE)] can't even get this right!</span>")
	return SHAME

//////////////////////////////
// MARK: DISABLER SMG
//////////////////////////////
/obj/item/gun/energy/disabler/smg
	name = "disabler SMG"
	desc = "An automatic disabler variant, as opposed to the conventional model. Boasts a higher ammunition capacity at the cost of slightly reduced beam effectiveness."
	icon_state = "disabler_smg"
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/smg)
	shaded_charge = TRUE
	can_holster = FALSE

/obj/item/gun/energy/disabler/smg/examine_more(mob/user)
	..()
	. = list()
	. += "The disabler SMG is an upscaled version of Shellguard Munitions' regular disabler, featuring the ability to pepper a large area with incapacitating shots. \
	It was designed specifically to be utilised for crowd suppression and riot control by small teams of officers."
	. += ""
	. += "Its bulkier nature and reduced accuracy has prevented it from achieving the same level of market penetration as its smaller brother, but it is still a common sight in correctional facilities."

/obj/item/gun/energy/disabler/smg/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.20 SECONDS, allow_akimbo = FALSE)

/obj/item/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "A modified disabler that draws power directly from your internal energy cell. It contains a limiter to prevent your cell from overheating. The warranty information has been disabled."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/cyborg)
	can_charge = FALSE

/obj/item/gun/energy/disabler/cyborg/newshot()
	..()
	robocharge()

//////////////////////////////
// MARK: U-ION SILENCER
//////////////////////////////
/obj/item/gun/energy/disabler/silencer
	name = "u-ION Silencer"
	desc = "Nanotrasen's take on silenced weapons. A quiet lethal disabler, designed to make the death look like a natural cause."
	icon_state = "tesla"
	inhand_icon_state = "tesla"
	origin_tech = "combat=6;syndicate=2"
	shaded_charge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/silencer_ammo)
	suppressed = TRUE
	execution_speed = 4 SECONDS

/obj/item/gun/energy/disabler/silencer/examine_more(mob/user)
	..()
	. = list()
	. += "Whilst the disabler is a very safe weapon that is in widespread use across the known galaxy, there are a handful of accidental fatalities that have been reported, \
	usually due to respiratory or cardiac arrest. Nanotrasen saw these exceptional cases and saw the potential to develop a very special weapon."
	. += ""
	. += "The result of their efforts was the u-ION Silencer. Like the disabler it is based on, it utilises an ionised particle beam to efficiently paralyse targets by disrupting ATP binding in specific parts of the musculature. \
	However, it has been fine-tuned to go several steps further, and block ALL sites of ATP binding, causing subjects to rapidly expire in a similar way to if they had been given a massive dose of cyanide. \
	Critically however, the temporary nature of this disruption and the lack of any lingering chemical reagent means that the cause of death will be unclear afterwards. \
	Whilst the paralytic nature of the weapon still functions against IPCs, it will not kill them, due to a lack of a metabolism to inhibit."
	. += ""
	. += "Agents of Nanotrasen employ this weapon to \"remove\" problematic individuals without it being immediately obvious that foul play was involved."

//////////////////////////////
// MARK: ARC REVOLVER
//////////////////////////////
/obj/item/gun/energy/arc_revolver
	name = "arc revolver"
	desc = "A high-tech revolver that fires internal, 3D printed shock cartridges in a revolving cylinder. \
		The cartridges can be recharged using conventional rechargers. These shots charge whatever they hit, causing arcs of electricity to form between them."
	icon_state = "stunrevolver"
	origin_tech = "combat=4;materials=4;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/arc_revolver)
	can_holster = TRUE

/obj/item/gun/energy/arc_revolver/examine_more(mob/user)
	. = ..()
	. = list()
	. += "The arc revolver is a highly unusual design from Nanotrasen R&D. It fires simple metal spikes containing disposable high-energy capacitors. \
	These spikes will discharge their contained energy in an electrical arc between any other such spikes that are nearby. \
	New spikes are synthesised and 3D printed into the cylinder using energy supplied when the gun is being recharged."
