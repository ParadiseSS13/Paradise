/* CONTENTS:
* 1. PULSE RIFLE
* 2. PULSE CARBINE
* 3. PULSE PISTOL
* 4. PULSE DESTROYER
* 5. PULSE ANNIHILATOR
* 6. M1911-P
* 7. PULSE TURRET
*/
//////////////////////////////
// MARK: PULSE RIFLE
//////////////////////////////
/obj/item/gun/energy/pulse
	name = "pulse rifle"
	desc = "An experimental energy rifle, it's extremely heavy and faintly hums with unstable energy. The absolute bleeding edge of NT weapon development. The fire selector has three settings: 'stun', 'kill', 'DESTROY'."
	icon_state = "pulse"
	worn_icon_state = null
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	modifystate = TRUE
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	cell_type = /obj/item/stock_parts/cell/energy_gun/pulse
	execution_speed = 2 SECONDS

/obj/item/gun/energy/pulse/examine_more(mob/user)
	..()
	. = list()
	. += "The pulse rifle is the realisation of intense efforts by Nanotrasen weapon R&D to push laser technology to its absolute limits. \
	Each one is a hand-made prototype constructed out of the most advanced components available. The custom nature of these rifles makes them ruinously expensive to manufacture."
	. += ""
	. += "An adaptive optical assembly works in conjunction with an overclocked laser pump and experimental gain medium to produce beams that effortlessly burn through almost any material. \
	The extreme heat produced by the weapon is pulled away from sensitive components with actively pumped coolant and dumped into heatsinks spanning most of the weapon's length. \
	A generously sized experimental power cell allows it to fire hundreds of times before becoming spent."
	. += ""
	. += "Issues noted with the weapon in field tests include its extreme weight, heft, and the rapid degradation of its internal components from a combination of thermal warping (despite the cooling system) \
	and the laser itself causing cumulative damage to all the components it passes through. \
	Both of these factors mean that the rifle has to be rebuilt after every deployment to continue operating properly. Despite all these shortcomings, it is the final word in man-portable laser firepower."

/obj/item/gun/energy/pulse/emp_act(severity)
	return

/obj/item/gun/energy/pulse/cyborg
	name = "mounted pulse rifle"
	desc = "A modified pulse rifle that draws power directly from your internal energy cell. Neither it, you, nor the warranty officially exists."

/obj/item/gun/energy/pulse/cyborg/newshot()
	..()
	robocharge()

//////////////////////////////
// MARK: PULSE CARBINE
//////////////////////////////
/obj/item/gun/energy/pulse/carbine
	name = "pulse carbine"
	desc = "A lighter, more compact version of the pulse rifle. Easier to store and transport, but has fewer shots. It has a mounting point for a flashlight. The fire selector has three settings: 'stun', 'kill', 'DESTROY'."
	icon_state = "pulse_carbine"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	cell_type = /obj/item/stock_parts/cell/energy_gun/pulse/carbine
	can_flashlight = TRUE
	flight_x_offset = 18
	flight_y_offset = 12

/obj/item/gun/energy/pulse/carbine/examine_more(mob/user)
	..()
	. = list()
	. += "The pulse carbine is an iteration of the pulse rifle that trades off endurance for practicality. \
	The power cell has been downsized and the internals have been jammed closer together, allowing the frame to be reduced in size and also mass."
	. += ""
	. += "The output of the laser remains identical to the full-sized pulse rifle, so it depletes the power cell faster. \
	The wear and tear suffered by the internals is also increased due to the close proximity of the internal components. Thankfully it will remain in optimal condition for the duration of a mission. Just."

//////////////////////////////
// MARK: PULSE PISTOL
//////////////////////////////
/obj/item/gun/energy/pulse/pistol
	name = "pulse pistol"
	desc = "A pulse gun miniaturised into a pistol-sized form factor. Easy to conceal, but has a low capacity. The fire selector has three settings: 'stun', 'kill', 'DESTROY'."
	icon_state = "pulse_pistol"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	can_holster = TRUE
	cell_type = /obj/item/stock_parts/cell/energy_gun/pulse/pistol
	can_charge = FALSE

/obj/item/gun/energy/pulse/pistol/examine(mob/user)
	. = ..()
	. += "<span class='warning'>The power cell of this weapon cannot be recharged!</span>"

/obj/item/gun/energy/pulse/pistol/examine_more(mob/user)
	..()
	. = list()
	. += "The pulse pistol was the result of Nanotrasen R&D trying their best to miniaturise the pulse rifle as much as possible. \
	Miraculously, it works! It fits nicely into pockets, holsters, and any other place one may hide a traditional pistol."
	. += ""
	. += "All the miniaturisation came at a cost. The power cell has been shrunk down so much that the gun can only get off a limited number of shots before becoming spent. \
	The pistol's anaemic heatsink prevents it from efficiently rejecting the heat from firing, causing severe cumulative damage with every shot. \
	The power cell generally starts to malfunction first (usually on the first shot), preventing recharging in the field. \
	Significant damage to the other components quickly follows until the internals of the weapon are completely destroyed, rendering it useless."
	. += ""
	. += "These are no longer manufactured, but a large stockpile of old units still remain. Nanotrasen occasionally issues them for dealing with severe threats, but otherwise they see little use. \
	The knowledge gleaned from the pulse pistol's development was not wasted, however, as lessons learned were later put to use in creating the more successful Model 1911-P."

//////////////////////////////
// MARK: PULSE DESTROYER
//////////////////////////////
/obj/item/gun/energy/pulse/destroyer
	name = "pulse destroyer"
	desc = "A pulse rifle for particularly aggressive users. The fire selector has three settings, and they are all 'DESTROY'."
	cell_type = /obj/item/stock_parts/cell/infinite
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse)

/obj/item/gun/energy/pulse/destroyer/attack_self__legacy__attackchain(mob/living/user)
	to_chat(user, "<span class='notice'>[src] is now set to DESTROY.</span>")

//////////////////////////////
// MARK: PULSE ANNIHILATOR
//////////////////////////////
/obj/item/gun/energy/pulse/destroyer/annihilator
	name = "pulse ANNIHILATOR"
	desc = "A pulse rifle fitted with a heavy duty prism, spreading a cone of destruction in front of the user. The fire selector has three settings, and they are all 'ANNIHILATE'."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter/pulse)

/obj/item/gun/energy/pulse/destroyer/annihilator/attack_self__legacy__attackchain(mob/living/user)
	to_chat(user, "<span class='boldannounceic'>[src] is now set to ANNIHILATE.</span>")

//////////////////////////////
// MARK: M1911-P
//////////////////////////////
/obj/item/gun/energy/pulse/pistol/m1911
	name = "\improper M1911-P"
	desc = "A compact pulse core in a classic handgun frame for Nanotrasen officers. It's not the size of the gun that matters, it's the size of the hole it puts through people."
	icon_state = "m1911"
	worn_icon_state = "gun"
	inhand_icon_state = "gun"
	cell_type = /obj/item/stock_parts/cell/infinite

/obj/item/gun/energy/pulse/pistol/m1911/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] contains a highly experimental power cell that consatntly generates energy seemingly out of nowhere. It will never run out of charge.</span>"

/obj/item/gun/energy/pulse/pistol/m1911/examine_more(mob/user)
	..()
	. = list()
	. += "The M1911-P is Nanotrasen's contribution to the time-honoured tradition of modifying John Browning's iconic pistol. Aside from some finagling to make everything fit in the shape of the frame, \
	the internals are very similar to the pulse pistol that came before it. However, special thermal composites and experimental plasma-treated optics were utilised to massively increase the gun's durability, \
	giving it endurance similar to a conventional laserarm. \
	However, all the special materials used in the 1911-P make it almost thirteen times more expensive to produce than a regular pulse rifle (an already extremely expensive design)."
	. += ""
	. += "These prestigious laser arms were originally conceived as part of a grand rollout of Nanotrasen's pulse weapon technology onto the galactic market, intended to deliver the firepower of a pulse laser \
	to those with an appreciation for the aesthetic of traditional firearms."
	. += ""
	. += "When it became clear that manufacturing costs for pulse weaponry would not come down any time soon, production of the pistol was halted, but not before the first batch of ten thousand was finished. \
	Eventually it was decided to gift these pistols to high-ranking Nanotrasen officials, who use them both as functional fashion statements and very effective personal defence weapons."

//////////////////////////////
// MARK: PULSE TURRET
//////////////////////////////
/obj/item/gun/energy/pulse/turret
	name = "pulse turret gun"
	desc = "A heavy pulse cannon made for mounted emplacements. The fire selector has two settings: 'stun', and 'DESTROY'."
	icon_state = "turretlaser"
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser/pulse)
	weapon_weight = WEAPON_MEDIUM
	trigger_guard = TRIGGER_GUARD_NONE

/obj/item/gun/energy/pulse/turret/examine(mob/user)
	. = ..()
	. += "<span class='warning'>This weapon has no internal power source. It cannot function without being mounted in a turret frame!</span>"

/obj/item/gun/energy/pulse/turret/examine_more(mob/user)
	..()
	. = list()
	. += "Most of the issues that affect pulse weaponry are negated or massively reduced when they are employed in emplacements. Significantly larger cooling systems and additional spacing between \
the components avoids the issue of thermal damage, and the mass of the weapon largely becomes a non-issue when it doesn't have to be lugged around. \
Whilst the laser does still cause damage to the optical assembly over time, the service life is still leaps and bounds ahead of handheld versions. This also makes them significantly cheaper to maintain."
