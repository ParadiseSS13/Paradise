/obj/item/gun/energy/pulse
	name = "pulse rifle"
	desc = "An experimental energy rifle, it's extremely heavy and faintly hums with unstable energy. The absolute bleeding edge of NT weapon development. It has 3 modes: stun, kill, DESTROY."
	icon_state = "pulse"
	item_state = null
	w_class = WEIGHT_CLASS_BULKY
	can_holster = FALSE
	force = 10
	modifystate = TRUE
	flags =  CONDUCT
	slot_flags = SLOT_FLAG_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	cell_type = /obj/item/stock_parts/cell/pulse
	execution_speed = 2 SECONDS

/obj/item/gun/energy/pulse/examine_more(mob/user)
	. = ..()
	. += "The pulse rifle is the realisation of intense efforts by Nanotrasen weapon R&D to push laser technology to its absolute limits. Each one is a hand-made prototype constructed out of the most advanced components available. \
	The custom nature of these rifles makes them ruinously expensive to manufacture. \
	An adaptive optical assembly works in conjunction with an overclocked laser pump and experimental gain medium to produce beams that effortlessly burn through almost any material. \
	The extreme heat produced by the weapon is pulled away from sensitive components with actively pumped refrigerant and dumped into heatsinks spanning most of the weapon's length. \
	A generously sized experimental power cell allows it to fire hundreds of times before becoming spent. \
	Issues noted with the weapon in field tests include its extreme weight, heft, and the rapid degradation of its internal components from a combination of thermal warping (despite the cooling system) and the laser itself causing cumulative damage to all the components it passes through. \
	Both of these factors mean that the rifle has to be rebuilt after every deployment to continue operating properly. Despite all these shortcomings, it is the final word in man-portable firepower."

/obj/item/gun/energy/pulse/emp_act(severity)
	return

/obj/item/gun/energy/pulse/cyborg

/obj/item/gun/energy/pulse/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/pulse/carbine
	name = "pulse carbine"
	desc = "A lighter, more compact version of the pulse rifle. Easier to store and transport, but has fewer shots. It has 3 modes: stun, kill, DESTROY."
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_FLAG_BELT
	icon_state = "pulse_carbine"
	item_state = null
	cell_type = /obj/item/stock_parts/cell/pulse/carbine
	can_flashlight = TRUE
	flight_x_offset = 18
	flight_y_offset = 12

/obj/item/gun/energy/pulse/carbine/examine_more(mob/user)
	. = ..()
	. += "The pulse carbine an iteration of the pulse rifle that trades off endurance for practicality. \
	The power cell has been downsized and the internals have been jammed closer together, allowing the frame to be reduced in size and also mass. The output of the laser remains identical to the full-sized pulse rifle, so it depletes the power cell faster. \
	The wear and tear suffered by the internals is also increased due to the close proximity of the internal components. Thankfully it will remain in optimal condition for the duration of a mission. Just."

/obj/item/gun/energy/pulse/pistol
	name = "pulse pistol"
	desc = "A pulse gun miniaturised into a pistol-sized form factor. Easy to conceal, but has a low capacity. It has 3 modes: stun, kill, DESTROY."
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_FLAG_BELT
	icon_state = "pulse_pistol"
	item_state = null
	can_holster = TRUE
	cell_type = /obj/item/stock_parts/cell/pulse/pistol
	can_charge = FALSE

/obj/item/gun/energy/pulse/pistol/examine_more(mob/user)
	. = ..()
	. += "The pulse pistol is the final result of Nanotrasen R&D trying their best to miniaturise the pulse rifle as much as possible.  Miraculously, it works! It fits nicely into pockets, holsters, and any other place one may hide a traditional pistol. \
	All the miniaturisation comes at a cost. The power cell has been shrunk down so much that the gun can only get off a limited number of shots before becoming spent. \
	The pistol's anaemic heatsink is somewhat made up for by the low capacity of the power cell - it runs out of energy before it starts causing major damage to its internals. The wear and tear is still significant enough for it to require servicing after seeing use."

/obj/item/gun/energy/pulse/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty, pulse-based energy weapon."
	cell_type = /obj/item/stock_parts/cell/infinite
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse)

/obj/item/gun/energy/pulse/destroyer/attack_self(mob/living/user)
	to_chat(user, "<span class='danger'>[name] has three settings, and they are all DESTROY.</span>")

/obj/item/gun/energy/pulse/destroyer/annihilator
	name = "pulse ANNIHILATOR"
	desc = "For when the situation calls for a little more than a pulse destroyer."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter/pulse)

/obj/item/gun/energy/pulse/pistol/m1911
	name = "\improper M1911-P"
	desc = "A compact pulse core in a classic handgun frame for Nanotrasen officers. It's not the size of the gun, it's the size of the hole it puts through people."
	icon_state = "m1911"
	item_state = "gun"
	can_holster = TRUE
	cell_type = /obj/item/stock_parts/cell/infinite

/obj/item/gun/energy/pulse/pistol/m1911/examine_more(mob/user)
	. = ..()
	. += "The M1911-P is Nanotrasen's contribution to the time-honoured tradition of modifying John Browning iconic pistol. Aside from some finagling to make everything fit in the shape of the frame, the internals are essentially identical to a regular pulse pistol. \
	These laser arms were originally conceived as part of a grand rollout of Nanotrasen's pulse weapon technology onto the galactic market, intended to deliver the firepower of a pulse laser to those with an appreciation for the aesthetic of traditional firearms. \
	When it became clear that manufacturing costs would not come down, production of the pistol was halted, but not before the first batch of ten thousand was finished. \
	Eventually it was decided to gift these pistols to high-ranking Nanotrasen officials, who use them both as functional fashion statements and very effective personal defence weapons."

/obj/item/gun/energy/pulse/turret
	name = "pulse turret gun"
	desc = "A heavy, turret-mounted pulse energy cannon."
	icon_state = "turretlaser"
	item_state = "turretlaser"
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser/pulse)
	weapon_weight = WEAPON_MEDIUM
	can_flashlight = FALSE
	trigger_guard = TRIGGER_GUARD_NONE
	ammo_x_offset = 2
