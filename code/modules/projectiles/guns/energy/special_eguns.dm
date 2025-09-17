/* CONTENTS:
* 1. ION RIFLE
* 2. ION CARBINE
* 3. DECLONER
* 4. FLORAL SOMATORAY
* 5. METEOR GUN
* 6. MIND FLAYER
* 7. ENERGY CROSSBOW
* 8. PLASMA CUTTER
* 9. WORMHOLE PROJECTOR
* 10. CYBORG LMG
* 11. INSTAGIB RIFLE
* 12. HONK RIFLE
* 13. PLASMA PISTOL
* 14. THE BSG
* 15. TEMPERATURE GUN
* 16. MIMIC GUN
* 17. DETECTIVE ENERGY REVOLVER
* 18. VOX SPIKETHROWER
* 19. VORTEX SHOTGUN
* 20. Model 2495
*/
//////////////////////////////
// MARK: ION RIFLE
//////////////////////////////
/obj/item/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats."
	icon_state = "ionrifle"
	worn_icon_state = null
	inhand_icon_state = null
	fire_sound = 'sound/weapons/ionrifle.ogg'
	origin_tech = "combat=4;magnets=4"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	shaded_charge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	ammo_x_offset = 3
	flight_x_offset = 17
	flight_y_offset = 9

/obj/item/gun/energy/ionrifle/examine_more(mob/user)
	..()
	. = list()
	. += "The ion rifle is a specialised weapon system developed by Nanotrasen to counteract technological threats. Stored xenon gas is superheated and spun inside a miniaturised \
	resonating cyclotron to strip away the outer electron shell. This creates a very positively charged slug of ionised xenon gas that is then launched down the barrel of the rifle by a series of electromagnets. \
	Once the slug hits a target, the magnetic field holding it together collapses, spreading the ions around the immediate area and causing severe damage to unshielded electronic systems caught within the resulting cloud."
	. += ""
	. += "It was developed in 2318 in response to the increasing prevalence of combat robots, mech units, and augmented combatants in modern combat engagements. \
	Whilst unsuccessful in procuring lucrative contracts to manufacture the weapon for the TSF (who pointed out the issue of combatants with electromagnetic shielding), \
	it was adopted by several corporate outfits that appreciated the ruthless efficiency of the ion rifle against unprotected synthetics."
	. += ""
	. += "Whilst it has a niche in combating pulse demon incursions, the real place that the ion rifle has shown its strength is in putting down synthetic rebellions and rogue artificial intelligences. \
	For a synthetic, nothing sends chills down the spine more than the sight of this weapon."

/obj/item/gun/energy/ionrifle/Initialize(mapload)
	. = ..()
	if(mapload && HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION) && is_station_level(z)) //No ion rifle when everyone has cybernetic organs, sorry!
		return INITIALIZE_HINT_QDEL

/obj/item/gun/energy/ionrifle/emp_act(severity)
	return

//////////////////////////////
// MARK: ION CARBINE
//////////////////////////////
/obj/item/gun/energy/ionrifle/carbine
	name = "ion carbine"
	desc = "The MK.II Prototype Ion Projector is a lightweight carbine version of the larger ion rifle, built to be ergonomic and efficient, it packs the exact same punch and capacity in a smaller, easier to transport package."
	icon_state = "ioncarbine"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	ammo_x_offset = 2
	flight_x_offset = 18
	flight_y_offset = 11

/obj/item/gun/energy/ionrifle/carbine/examine_more(mob/user)
	..()
	. = list()
	. += "Recent developments in compact electromagnets, material science, and iterative improvement in various other high energy components has resulted in this brand-new rehashing of the \
	original Ion Rifle being developed by Nanotrasen R&D: The Ion Carbine! It addresses several of the shortcomings of its centuries-old predecessor. Chiefly among them is the miniaturisation of the vital components, \
	which has allowed the carbine to be made small enough to fit inside a variety of personal storage spaces, permitting it to be used as a secondary weapon that can be kept out of the way until it is needed. \
	Improvements to the ergonomics, reduction in weight, and the replacement of the fixed 1x optic with a modular rail system also makes the carbine far more pleasant to use than its predecessor. \
	All of these improvements come without any trade-offs, such is the march of technology."
	. += ""
	. += "The chief impetus for the development of the Ion Carbine was the mass unrest and strike actions by the then-indentured IPC workforce starting in 2525. Whilst the events surrounding this were largely non-violent, \
	Nanotrasen is aware that things could have gone very differently. With their current pervasive use of indentured AI, robots, and cyborgs, Nanotrasen is also very well aware that history may repeat itself - \
	and may do so with great destruction. Such an eventuality is absolutely unacceptable to the company."
	. += ""
	. += "Nanotrasen also hopes that this improved weapon will be more attractive to markets that have seen low penetration from the original Ion Rifle. As with before, \
	the golden goose that Nanotrasen wishes eventually to secure is production contracts with the armed forces of the TSF, but they'll happily sell it to anyone else that's buying."

//////////////////////////////
// MARK: DECLONER
//////////////////////////////
/obj/item/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	fire_sound = 'sound/weapons/pulse3.ogg'
	origin_tech = "combat=4;materials=4;biotech=5;plasmatech=6"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	ammo_x_offset = 1
	can_holster = TRUE

/obj/item/gun/energy/decloner/examine_more(mob/user)
	..()
	. = list()
	. += "The biological demolecularisor - also known as the \"decloner\" by some users - is a specialty weapon from Nanotrasen weapon R&D intended for particularly troublesome organic threats."
	. += ""
	. += "It utilises a compact synchrotron specifically tuned to generate a large excess of gamma-wavelength radiation that is released in highly intense bursts. When an organic target is hit by the burst, \
	it causes damage to the very makeup of their cells, destroying protiens, DNA, and other vital molecular structures. Continued application rapidly results in debilitating damage and death."

/obj/item/gun/energy/decloner/update_icon_state()
	return

/obj/item/gun/energy/decloner/update_overlays()
	. = list()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(cell.charge > shot.e_cost)
		. += "decloner_spin"

//////////////////////////////
// MARK: FLORAL SOMATORAY
//////////////////////////////
/obj/item/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	fire_sound = 'sound/effects/stealthoff.ogg'
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=4"
	modifystate = 1
	ammo_x_offset = 1
	selfcharge = TRUE
	can_holster = TRUE

/obj/item/gun/energy/floragun/pre_attack(atom/target, mob/living/user, params)
	if(istype(target, /obj/machinery/hydroponics))
		// Calling afterattack from pre_attack looks stupid, but afterattack with proximity FALSE is what makes the gun fire, and we're returning FALSE to cancel the melee attack.
		afterattack__legacy__attackchain(target, user, FALSE, params)
		return CONTINUE_ATTACK
	return ..()

//////////////////////////////
// MARK: METEOR GUN
//////////////////////////////
/obj/item/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "riotgun"
	inhand_icon_state = "c20r"
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = /obj/item/stock_parts/cell/potato
	clumsy_check = FALSE //Admin spawn only, might as well let clowns use it.
	selfcharge = TRUE

/obj/item/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	worn_icon_state = "pen"
	inhand_icon_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY

//////////////////////////////
// MARK: MIND FLAYER
//////////////////////////////
/obj/item/gun/energy/mindflayer
	name = "\improper Mind Flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "flayer"
	inhand_icon_state = null
	shaded_charge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)

//////////////////////////////
// MARK: ENERGY CROSSBOW
//////////////////////////////
/obj/item/gun/energy/kinetic_accelerator/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists. Knocks down and injects toxins."
	icon_state = "crossbow"
	inhand_icon_state = "crossbow"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=4;magnets=4;syndicate=5"
	suppressed = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	unique_rename = FALSE
	overheat_time = 20
	holds_charge = TRUE
	unique_frequency = TRUE
	can_flashlight = FALSE
	max_mod_capacity = 0
	empty_state = "crossbow_empty"
	can_holster = TRUE

/obj/item/gun/energy/kinetic_accelerator/crossbow/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SILENT_INSERTION, ROUNDSTART_TRAIT)

/obj/item/gun/energy/kinetic_accelerator/crossbow/large
	name = "energy crossbow"
	desc = "A reverse engineered weapon using syndicate technology."
	icon_state = "crossbowlarge"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=4000)
	origin_tech = "combat=4;magnets=4;syndicate=2"
	suppressed = FALSE
	can_holster = FALSE // it's large after all
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/large)
	empty_state = "crossbowlarge_empty"

/obj/item/gun/energy/kinetic_accelerator/crossbow/large/cyborg
	desc = "One and done!"
	origin_tech = null
	materials = list()

/obj/item/gun/energy/kinetic_accelerator/suicide_act(mob/user)
	if(!suppressed)
		playsound(loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	user.visible_message("<span class='suicide'>[user] cocks [src] and pretends to blow [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	shoot_live_shot(user, user, FALSE, FALSE)
	return OXYLOSS

//////////////////////////////
// MARK: PLASMA CUTTER
//////////////////////////////
/obj/item/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. Its effectiveness drops dramatically outside of low-pressure environments. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	icon_state = "plasmacutter"
	inhand_icon_state = "plasmacutter"
	origin_tech = "combat=1;materials=3;magnets=2;plasmatech=3;engineering=1"
	needs_permit = FALSE
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	fire_sound = 'sound/weapons/laser.ogg'
	usesound = 'sound/items/welder.ogg'
	container_type = OPENCONTAINER
	attack_verb = list("attacked", "slashed", "cut", "sliced")
	force = 12
	sharp = TRUE
	can_charge = FALSE
	can_holster = TRUE

/obj/item/gun/energy/plasmacutter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] can be recharged by inserting plasma sheets or raw plasma ore into it.</span>"
	. += "<span class='warning'>[src] cannot be charged in a gun charging station.</span>"

/obj/item/gun/energy/plasmacutter/examine_more(mob/user)
	..()
	. = list()
	. += "The plasma cutter is an old and reliable design mining tool designed by the now-defunct Althland mining company for rapid tunnelling, excavation, and ore extraction. \
	It uses a magnetic catapult to launch superheated slugs of hypervelocity plasma. These slugs effortlessly destabilise and punch through most kinds of rock, allowing for easy clearance."
	. += ""
	. += "It can be reloaded using refined plasma sheets, or plasma ore obtained in the field (although the latter is less efficient). \
	Plasma cutters such as these can be found in use at plasma mining operations throughout known space."

/obj/item/gun/energy/plasmacutter/attackby__legacy__attackchain(obj/item/A, mob/user)
	if(istype(A, /obj/item/stack/sheet/mineral/plasma))
		if(cell.charge >= cell.maxcharge)
			to_chat(user,"<span class='notice'>[src] is already fully charged.")
			return
		var/obj/item/stack/sheet/S = A
		S.use(1)
		cell.give(1000)
		on_recharge()
		to_chat(user, "<span class='notice'>You insert [A] in [src], recharging it.</span>")
	else if(istype(A, /obj/item/stack/ore/plasma))
		if(cell.charge >= cell.maxcharge)
			to_chat(user,"<span class='notice'>[src] is already fully charged.")
			return
		var/obj/item/stack/ore/S = A
		S.use(1)
		cell.give(500)
		on_recharge()
		to_chat(user, "<span class='notice'>You insert [A] in [src], recharging it.</span>")
	else
		return ..()

/obj/item/gun/energy/plasmacutter/update_overlays()
	return list()

/obj/item/gun/energy/plasmacutter/get_heat()
	return 3800

/obj/item/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	desc = "An improved version of the venerable Plasma Cutter, evolved by Nanotrasen. It's just straight up better!"
	icon_state = "adv_plasmacutter"
	inhand_icon_state = "adv_plasmacutter"
	modifystate = "adv_plasmacutter"
	origin_tech = "combat=3;materials=4;magnets=3;plasmatech=4;engineering=2"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)
	force = 15

/obj/item/gun/energy/plasmacutter/adv/examine_more(mob/user)
	..()
	. = list()
	. += "Once Althland was acquired by Nanotrasen, they gained access to all of the company's technologies and patents, most notably, the Plasma Cutter. \
	NT R&D has been hard at work refining it into a superior design."
	. += ""
	. += "This advanced model has an improved charging system to slightly increase the fire rate, and a completely redesigned plasma slug launch system that cuts the required plasma for a shot down by 87%! \
	Careful redesigning of the frame's angles and weight distribution also makes it slightly better as a melee weapon as well."
	. += ""
	. += "These new plasma cutters are not yet in common use, but the massive efficiency gains over their predecessors all but guarantees that they will sell like wildfire."

//////////////////////////////
// MARK: WORMHOLE PROJECTOR
//////////////////////////////
/obj/item/gun/energy/wormhole_projector
	name = "bluespace wormhole projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	icon_state = "wormhole_projector1"
	inhand_icon_state = null
	origin_tech = "combat=4;bluespace=6;plasmatech=4;engineering=4"
	charge_delay = 5
	selfcharge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	var/obj/effect/portal/blue
	var/obj/effect/portal/orange

/obj/item/gun/energy/wormhole_projector/update_icon_state()
	icon_state = "wormhole_projector[select]"

/obj/item/gun/energy/wormhole_projector/process_chamber()
	..()
	select_fire(usr)

/obj/item/gun/energy/wormhole_projector/portal_destroyed(obj/effect/portal/P)
	if(P.icon_state == "portal")
		blue = null
		if(orange)
			orange.target = null
	else
		orange = null
		if(blue)
			blue.target = null

/obj/item/gun/energy/wormhole_projector/proc/create_portal(obj/item/projectile/beam/wormhole/W)
	var/obj/effect/portal/P = new /obj/effect/portal(get_turf(W), null, src)
	P.precision = 0
	P.failchance = 0
	P.can_multitool_to_remove = 1
	if(W.name == "wormhole beam")
		qdel(blue)
		blue = P
	else
		qdel(orange)
		P.icon_state = "portal1"
		orange = P
	if(orange && blue)
		blue.target = get_turf(orange)
		orange.target = get_turf(blue)

/obj/item/gun/energy/wormhole_projector/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] looking directly into the operational end of [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>",
								"<span class='suicide'>[user] is touching the operatonal end of [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>"))
	if(!do_after(user, 0.5 SECONDS, target = user)) // touch/looking doesn't take that long, but still probably good for a delay to exist for shoving and whatnot
		return SHAME
	user.dust()
	playsound(loc, 'sound/effects/supermatter.ogg', 20, TRUE)
	return OBLITERATION

//////////////////////////////
// MARK: CYBORG LMG
//////////////////////////////
/obj/item/gun/energy/printer
	name = "cyborg LMG"
	desc = "A machine gun that fires 3D-printed flachettes slowly synthesized using your internal energy cell."
	icon_state = "l6closed0"
	icon = 'icons/obj/guns/projectile.dmi'
	cell_type = /obj/item/stock_parts/cell/energy_gun/lmg
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	can_charge = FALSE

/obj/item/gun/energy/printer/update_overlays()
	return list()

/obj/item/gun/energy/printer/emp_act()
	return

//////////////////////////////
// MARK: INSTAGIB RIFLE
//////////////////////////////
/obj/item/gun/energy/laser/instakill
	name = "instakill rifle"
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit."
	icon_state = "instagib"
	inhand_icon_state = "instagib"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill)
	force = 60
	origin_tech = "combat=7;magnets=6"
	execution_speed = 2 SECONDS

/obj/item/gun/energy/laser/instakill/examine(mob/user)
	. = ..()
	. += "This gun gibs anyone it hits and destroys objects."

/obj/item/gun/energy/laser/instakill/examine_more(mob/user)
	. = ..()
	. = list()
	. += "Utilizing top-shelf Shellguard batteries, a sleek off-white chassis, and a dense enough lens to make an optometrist cry, this rifle fires laser bolts that can violently disassemble anyone it hits. You're still not sure when it would be useful, though."
	. += ""
	. += "Once quested for in days of old, this rifle and other treasures of the gods were sealed away in their palace in the sky. The once-open door was not simply locked, but taken away."
	. += ""
	. += "Who are we kidding, this is an admin-only weapon that instakills people. Go nuts. Have fun."


/obj/item/gun/energy/laser/instakill/emp_act() //implying you could stop the instagib
	return

/obj/item/gun/energy/laser/instakill/red
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a red design."
	icon_state = "instagibred"
	inhand_icon_state = "instagibred"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/red)

/obj/item/gun/energy/laser/instakill/blue
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a blue design."
	icon_state = "instagibblue"
	inhand_icon_state = "instagibblue"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/blue)

//////////////////////////////
// MARK: HONK RIFLE
//////////////////////////////
/obj/item/gun/energy/clown
	name = "\improper HONK rifle"
	desc = "The finest weapon produced by the Martian College of Comedy."
	icon_state = "honkrifle"
	ammo_type = list(/obj/item/ammo_casing/energy/clown)
	clumsy_check = FALSE
	selfcharge = TRUE
	ammo_x_offset = 3
	can_holster = TRUE  // You'll never see it coming!

/obj/item/gun/energy/clown/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] contains a strange bananium core that somehow slowly reacharges its power cell at all times. It can still be put into a gun charger for faster charging.</span>"

/obj/item/gun/energy/clown/examine_more(mob/user)
	..()
	. = list()
	. += "Developed by a former pair of designers from Donk Co. and Shellguard Munitions who met each other whilst studying at the Martian College of Comedy, this rifle uses advanced chemical synthesisers \
	and customised 3D printing technology to fabricate high-yield snap-pops, which are then hurled downrange by a pneumatic ram into unsuspecting bystanders! \
	Whilst not powerful enough to be harmful, it scares the hell out of them!"
	. += ""
	. += "The design was an instant hit, and elite clowns all across the Orion sector eagerly added it to their arsenals. What will they think of next?"

//////////////////////////////
// MARK: PLASMA PISTOL
//////////////////////////////
#define PLASMA_CHARGE_USE_PER_SECOND 2.5
#define PLASMA_DISCHARGE_LIMIT 5
/obj/item/gun/energy/plasma_pistol
	name = "plasma pistol"
	desc = "A specialized firearm designed to fire superheated bolts of plasma. Can be overloaded for a high damage, shield-breaking shot."
	icon_state = "toxgun"
	inhand_icon_state = "toxgun"
	sprite_sheets_inhand = list("Vox" = 'icons/mob/clothing/species/vox/held.dmi', "Drask" = 'icons/mob/clothing/species/drask/held.dmi') //This apperently exists, and I have the sprites so sure.
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/weak_plasma, /obj/item/ammo_casing/energy/charged_plasma)
	shaded_charge = TRUE
	can_holster = TRUE
	atom_say_verb = "beeps"
	bubble_icon = "swarmer"
	light_color = "#89078E"
	light_power = 4
	var/overloaded = FALSE
	var/warned = FALSE
	var/charging = FALSE
	var/charge_failure = FALSE
	var/mob/living/carbon/holder = null
	execution_speed = 4 SECONDS

/obj/item/gun/energy/plasma_pistol/examine(mob/user)
	. = ..()
	. += "<span class='warning'>Beware! Improper handling of [src] may release a cloud of highly flammable plasma gas!</span>"

/obj/item/gun/energy/plasma_pistol/examine_more(mob/user)
	..()
	. = list()
	. += "The plasma pistol is a departure from Nanotrasen's usual forays into energy weapon design. \
	Uniquely among its catalogue of experimental weapons, it uses plasma projectiles instead of lasers or other particles to deal damage."
	. += ""
	. += "The pistol's frame contains a compact magnetic catapault that launches the plasma at the target, where the extreme heat causes severe burns at the point of impact. \
	When overcharged, a particularly large projectile is generated, which not only causes increased damage to targets, \
	but also overloads energy shielding thanks to the quantitiy of ionised plasma in the projectile."

/obj/item/gun/energy/plasma_pistol/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/gun/energy/plasma_pistol/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	holder = null
	return ..()

/obj/item/gun/energy/plasma_pistol/process()
	..()
	if(overloaded)
		cell.charge -= PLASMA_CHARGE_USE_PER_SECOND / 5 //2.5 per second, 25 every 10 seconds
		if(cell.charge <= PLASMA_CHARGE_USE_PER_SECOND * 10 && !warned)
			warned = TRUE
			playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 75, 1)
			atom_say("Caution, charge low. Forced discharge in under 10 seconds.")
		if(cell.charge <= PLASMA_DISCHARGE_LIMIT)
			discharge()

/obj/item/gun/energy/plasma_pistol/attack_self__legacy__attackchain(mob/living/user)
	if(overloaded)
		to_chat(user, "<span class='warning'>[src] is already overloaded!</span>")
		return
	if(cell.charge <= 140) //at least 6 seconds of charge time
		to_chat(user, "<span class='warning'>[src] does not have enough charge to be overloaded.</span>")
		return
	if(charging)
		to_chat(user, "<span class='warning'>[src] is already charging!</span>")
		return
	to_chat(user, "<span class='notice'>You begin to overload [src].</span>")
	charging = TRUE
	charge_failure = FALSE
	holder = user
	RegisterSignal(holder, COMSIG_CARBON_SWAP_HANDS, PROC_REF(fail_charge))
	addtimer(CALLBACK(src, PROC_REF(overload)), 2.5 SECONDS)

/obj/item/gun/energy/plasma_pistol/proc/fail_charge()
	SIGNAL_HANDLER // COMSIG_CARBON_SWAP_HANDS
	charge_failure = TRUE // No charging 2 guns at once.
	UnregisterSignal(holder, COMSIG_CARBON_SWAP_HANDS)

/obj/item/gun/energy/plasma_pistol/proc/overload()
	UnregisterSignal(holder, COMSIG_CARBON_SWAP_HANDS)
	if(ishuman(loc) && !charge_failure)
		var/mob/living/carbon/C = loc
		select_fire(C)
		overloaded = TRUE
		cell.use(125)
		playsound(C.loc, 'sound/machines/terminal_prompt_confirm.ogg', 75, 1)
		atom_say("Overloading successful.")
		set_light(3) //extra visual effect to make it more noticable to user and victims alike
		holder = C
		RegisterSignal(holder, COMSIG_CARBON_SWAP_HANDS, PROC_REF(discharge))
	else
		atom_say("Overloading failure.")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 75, 1)
	charging = FALSE
	charge_failure = FALSE

/obj/item/gun/energy/plasma_pistol/proc/reset_overloaded()
	select_fire()
	set_light(0)
	overloaded = FALSE
	warned = FALSE
	UnregisterSignal(holder, COMSIG_CARBON_SWAP_HANDS)
	holder = null

/obj/item/gun/energy/plasma_pistol/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override, bonus_spread = 0)
	if(charging)
		return
	return ..()

/obj/item/gun/energy/plasma_pistol/process_chamber()
	if(overloaded)
		do_sparks(2, 1, src)
		reset_overloaded()
	..()
	update_icon()

/obj/item/gun/energy/plasma_pistol/emp_act(severity)
	..()
	charge_failure = TRUE
	if(prob(100 / severity) && overloaded)
		discharge()

/obj/item/gun/energy/plasma_pistol/dropped(mob/user)
	. = ..()
	charge_failure = TRUE
	if(overloaded)
		discharge()

/obj/item/gun/energy/plasma_pistol/equipped(mob/user, slot, initial)
	. = ..()
	charge_failure = TRUE
	if(overloaded)
		discharge()

/obj/item/gun/energy/plasma_pistol/proc/discharge() //25% of the time, plasma leak. Otherwise, shoot at a random mob / turf nearby. If no proper mob is found when mob is picked, fire at a turf instead
	SIGNAL_HANDLER
	reset_overloaded()
	do_sparks(2, 1, src)
	update_icon()
	visible_message("<span class='danger'>[src] vents heated plasma!</span>")
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		var/datum/gas_mixture/air = new()
		air.set_temperature(1000)
		air.set_toxins(20)
		air.set_oxygen(20)
		T.blind_release_air(air)

#undef PLASMA_CHARGE_USE_PER_SECOND
#undef PLASMA_DISCHARGE_LIMIT

//////////////////////////////
// MARK: THE BSG
//////////////////////////////
/obj/item/gun/energy/bsg
	name = "\improper B.S.G"
	desc = "The Blue Space Gun. Uses a flux anomaly core and a bluespace crystal to produce destructive bluespace energy blasts, inspired by Nanotrasen's BSA division."
	icon_state = "bsg"
	worn_icon_state = "bsg"
	inhand_icon_state = "bsg"
	origin_tech = "combat=6;materials=6;powerstorage=6;bluespace=6;magnets=6" //cutting edge technology, be my guest if you want to deconstruct one instead of use it.
	ammo_type = list(/obj/item/ammo_casing/energy/bsg)
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	cell_type = /obj/item/stock_parts/cell/energy_gun/bsg
	shaded_charge = TRUE
	can_fit_in_turrets = FALSE //Crystal would shatter, or someone would try to put an empty gun in the frame.
	var/obj/item/assembly/signaler/anomaly/flux/core = null
	var/has_bluespace_crystal = FALSE
	var/admin_model = FALSE //For the admin gun, prevents crystal shattering, so anyone can use it, and you dont need to carry backup crystals.

/obj/item/gun/energy/bsg/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/gun/energy/bsg/examine(mob/user)
	. = ..()
	if(core && has_bluespace_crystal)
		. += "<span class='notice'>[src] is fully operational!</span>"
		. += "<span class='notice'>[src] will generate a protective field that shields the user from the blast of its own projectiles when fired.</span>"
	else if(core)
		. += "<span class='warning'>It has a flux anomaly core installed, but no bluespace crystal installed.</span>"
	else if(has_bluespace_crystal)
		. += "<span class='warning'>It has a bluespace crystal installed, but no flux anomaly core installed.</span>"
	else
		. += "<span class='warning'>It is missing a flux anomaly core and bluespace crystal.</span>"

/obj/item/gun/energy/bsg/examine_more(mob/user)
	..()
	. = list()
	. += "When a bluespace crystal is correctly charged and agitated, it releases high-energy exotic particles that are very deadly to living beings. \
	The BSG is the culmination of Nanotrasen's research into portable weaponised bluespace technology."
	. += ""
	. += "By using a captive flux anomaly core to supercharge the weapon's bluespace crystal, a massive sphere of condensed energy is released. \
	This sphere will release an energy discharge upon hitting a solid object, causing extensive damage to flesh and robotic components. \
	As the sphere dischargers, it will also detonate, emitting a powerful pulse of infrared radiation that will cause flash burns on anyone caught within the detonation radius."
	. += ""
	. += "Accidental injuries and death during initial testing also caused a protective energy barrier to be added to the design. By using the flux core as a metaphorical 'lightning rod', \
	it will capture some of the energy from the detonation of the weapon's projectile and use it to create a finely-tuned neutralising bluespace field that destructively interferes with the bluespace shock wave. \
	However, this system is not strong enough to defend against a direct hit from another (or your own, if you're unlucky) BSG shot."

/obj/item/gun/energy/bsg/attackby__legacy__attackchain(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack/ore/bluespace_crystal))
		if(has_bluespace_crystal)
			to_chat(user, "<span class='notice'>[src] already has a bluespace crystal installed.</span>")
			return
		var/obj/item/stack/S = O
		if(!loc || !S || S.get_amount() < 1)
			return
		to_chat(user, "<span class='notice'>You load [O] into [src].</span>")
		S.use(1)
		has_bluespace_crystal = TRUE
		update_icon()
		return

	if(istype(O, /obj/item/assembly/signaler/anomaly/flux))
		if(core)
			to_chat(user, "<span class='notice'>[src] already has a [O]!</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[O] is stuck to your hand!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [O] into [src], and [src] starts to warm up.</span>")
		O.forceMove(src)
		core = O
		update_icon()
	else
		return ..()

/obj/item/gun/energy/bsg/equipped(mob/user, slot, initial)
	. = ..()
	ADD_TRAIT(user, TRAIT_BSG_IMMUNE, "[UID()]")

/obj/item/gun/energy/bsg/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_BSG_IMMUNE, "[UID()]")

/obj/item/gun/energy/bsg/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override, bonus_spread = 0)
	if(!has_bluespace_crystal)
		to_chat(user, "<span class='warning'>[src] has no bluespace crystal to power it!</span>")
		return
	if(!core)
		to_chat(user, "<span class='warning'>[src] has no flux anomaly core to power it!</span>")
		return
	return ..()

/obj/item/gun/energy/bsg/update_icon_state()
	. = ..()
	if(core)
		if(has_bluespace_crystal)
			icon_state = "bsg_finished"
		else
			icon_state = "bsg_core"
	else if(has_bluespace_crystal)
		icon_state = "bsg_crystal"
	else
		icon_state = "bsg"

/obj/item/gun/energy/bsg/emp_act(severity)
	..()
	if(prob(75 / severity))
		if(has_bluespace_crystal)
			shatter()

/obj/item/gun/energy/bsg/proc/shatter()
	if(admin_model)
		return
	visible_message("<span class='warning'>[src]'s bluespace crystal shatters!</span>")
	playsound(src, 'sound/effects/pylon_shatter.ogg', 50, TRUE)
	has_bluespace_crystal = FALSE
	update_icon()

/obj/item/gun/energy/bsg/prebuilt
	icon_state = "bsg_finished"
	has_bluespace_crystal = TRUE

/obj/item/gun/energy/bsg/prebuilt/Initialize(mapload)
	. = ..()
	core = new /obj/item/assembly/signaler/anomaly/flux
	update_icon()

/obj/item/gun/energy/bsg/prebuilt/admin
	desc = "The Blue Space Gun. Uses a flux anomaly core and a bluespace crystal to produce destructive bluespace energy blasts, inspired by Nanotrasen's BSA division. This is an executive model, and its bluespace crystal will not shatter."
	admin_model = TRUE

//////////////////////////////
// MARK: TEMPERATURE GUN
//////////////////////////////
/obj/item/gun/energy/temperature
	name = "temperature gun"
	desc = "A gun that changes the body temperature of its targets, somehow. Use it in-hand to adjust the projectile temperature."	// I give up on trying to come up with an explaination of how this abomonation works. - CRUNCH
	icon = 'icons/obj/guns/gun_temperature.dmi'
	icon_state = "tempgun_4"
	worn_icon_state = null
	inhand_icon_state = null
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	fire_sound = 'sound/weapons/pulse3.ogg'
	origin_tech = "combat=4;materials=4;powerstorage=3;magnets=2"

	ammo_type = list(/obj/item/ammo_casing/energy/temp)

	// Measured in Kelvin
	var/temperature = T20C
	var/target_temperature = T20C
	var/min_temp = 0
	var/max_temp = 500

	/// How fast the gun changes temperature
	var/temperature_multiplier = 10

/obj/item/gun/energy/temperature/Initialize(mapload, ...)
	. = ..()
	update_icon()
	START_PROCESSING(SSobj, src)


/obj/item/gun/energy/temperature/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/temperature/attack_self__legacy__attackchain(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/item/gun/energy/temperature/ui_state(mob/user)
	return GLOB.deep_inventory_state

/obj/item/gun/energy/temperature/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TempGun", name)
		ui.open()

/obj/item/gun/energy/temperature/ui_data(mob/user)
	var/list/data = list()
	data["target_temperature"] = target_temperature - T0C // Pass them in as Celcius numbers
	data["temperature"] = temperature - T0C
	data["max_temp"] = max_temp - T0C
	data["min_temp"] = min_temp - T0C
	return data

/obj/item/gun/energy/temperature/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(action == "target_temperature")
		target_temperature = clamp(text2num(params["target_temperature"]) + T0C, min_temp, max_temp) //Retrieved as a celcius number, convert to kelvin

/obj/item/gun/energy/temperature/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='warning'>You remove the gun's temperature cap! Targets hit by searing beams will burst into flames!</span>")
		desc += " Its temperature cap has been removed."
		max_temp = 1000
		temperature_multiplier *= 5  //so emagged temp guns adjust their temperature much more quickly
		return TRUE

/obj/item/gun/energy/temperature/process()
	..()
	if(target_temperature != temperature)
		var/difference = abs(target_temperature - temperature)
		if(difference >= temperature_multiplier)
			if(target_temperature < temperature)
				temperature -= temperature_multiplier
			else
				temperature += temperature_multiplier
		else
			temperature = target_temperature
		update_icon()
		var/obj/item/ammo_casing/energy/temp/T = ammo_type[select]
		T.temp = temperature
		switch(temperature)
			if(0 to 100)
				T.e_cost = 300
			if(100 to 250)
				T.e_cost = 200
			if(251 to 300)
				T.e_cost = 100
			if(301 to 400)
				T.e_cost = 200
			if(401 to INFINITY)
				T.e_cost = 300

/obj/item/gun/energy/temperature/update_icon_state()
	switch(temperature)
		if(501 to INFINITY)
			icon_state = "tempgun_8"
		if(400 to 500)
			icon_state = "tempgun_7"
		if(360 to 400)
			icon_state = "tempgun_6"
		if(335 to 360)
			icon_state = "tempgun_5"
		if(295 to 335)
			icon_state = "tempgun_4"
		if(260 to 295)
			icon_state = "tempgun_3"
		if(200 to 260)
			icon_state = "tempgun_2"
		if(120 to 260)
			icon_state = "tempgun_1"
		if(-INFINITY to 120)
			icon_state = "tempgun_0"

	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		M.update_inv_back()
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/gun/energy/temperature/update_overlays()
	. = ..()
	var/charge = cell.charge
	switch(charge)
		if(900 to INFINITY)		. += "900"
		if(800 to 900)			. += "800"
		if(700 to 800)			. += "700"
		if(600 to 700)			. += "600"
		if(500 to 600)			. += "500"
		if(400 to 500)			. += "400"
		if(300 to 400)			. += "300"
		if(200 to 300)			. += "200"
		if(100 to 200)			. += "100"
		if(-INFINITY to 100)	. += "0"

//////////////////////////////
// MARK: MIMIC GUN
//////////////////////////////
/obj/item/gun/energy/mimicgun
	name = "mimic gun"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse. Why does this one have teeth?"
	icon_state = "disabler"
	ammo_type = list(/obj/item/ammo_casing/energy/mimic)
	clumsy_check = FALSE //Admin spawn only, might as well let clowns use it.
	selfcharge = TRUE
	ammo_x_offset = 3
	var/mimic_type = /obj/item/gun/projectile/automatic/pistol //Setting this to the mimicgun type does exactly what you think it will.
	can_holster = TRUE

/obj/item/gun/energy/mimicgun/newshot()
	var/obj/item/ammo_casing/energy/mimic/M = ammo_type[select]
	M.mimic_type = mimic_type
	..()

//////////////////////////////
// MARK: DETECTIVE ENERGY REVOLVER
//////////////////////////////
/obj/item/gun/energy/detective
	name = "\improper DL-88 energy revolver"
	desc = "A 'modern' take on the classic .38 revolver, designed and manufactured by Warp-Tac Industries. The fire selector has two settings: 'tracker', and 'disable'."
	icon_state = "handgun"
	modifystate = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/detective, /obj/item/ammo_casing/energy/detective/tracker_warrant)
	/// If true, this gun is tracking something and cannot track another mob
	var/tracking_target_UID
	/// Used to track if the gun is overcharged
	var/overcharged
	/// Yes, this gun has a radio, welcome to 2022
	var/obj/item/radio/headset/Announcer
	/// Used to link back to the pinpointer
	var/linked_pinpointer_UID
	shaded_charge = TRUE
	can_holster = TRUE
	can_fit_in_turrets = FALSE
	can_charge = FALSE
	unique_reskin = TRUE
	charge_sections = 5
	inhand_charge_sections = 3
	overlay_set = "handgun" // Reskins are a different icon_state

/obj/item/gun/energy/detective/examine_more(mob/user)
	..()
	. = list()
	. += "The Dignitas Laser model 88, a laser revolver with a classic design is a 'modern' spin on older .38 revolvers. Designed by Warp-Tac Industries, \
	it is the successor of the older DL-44 revolver, being tailored for police and security forces."
	. += ""
	. += "Developed in response to break-ins at Warp-Tac's corporate offices on Mars, the Model 88 diverged from Warp-Tac's usual lethal weapon designs. Instead, it was crafted to meet police force demands \
	for non-lethal capture, offering an alternative to the prevalent and commonly distributed disablers in the market. \
	The DL-88 quickly became the tool of choice for neutralizing suspects without lethal force within Warp-Tac security forces. \
	Due to this, its effectiveness and design caught the attention of private detective agencies, aligning perfectly with Warp-Tac's targeted marketing of the gun."
	. += ""
	. += "Eventually, corporations like Nanotrasen adopted the DL-88 for their detective units, appreciating its cost-effectiveness and the ability to use their own manufactured cells, reducing overall budget expenditures."

/obj/item/gun/energy/detective/Initialize(mapload, ...)
	. = ..()
	Announcer = new /obj/item/radio/headset(src)
	Announcer.config(list("Security" = 1))
	Announcer.follow_target = src
	options["The Original"] = "handgun"
	options["Golden Mamba"] = "handgun_golden-mamba"
	options["NT's Finest"] = "handgun_nt-finest"

/obj/item/gun/energy/detective/Destroy()
	QDEL_NULL(Announcer)
	return ..()

/obj/item/gun/energy/detective/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ctrl-click to clear active tracked target or clear linked pinpointer.</span>"

/obj/item/gun/energy/detective/emp_act(severity)
	. = ..()
	unlink()
	atom_say("EMP detected. Pinpointer and tracker system reset.")


/obj/item/gun/energy/detective/CtrlClick(mob/user)
	. = ..()
	if(!isliving(loc)) //don't do this next bit if this gun is on the floor
		return
	var/tracking_target = locateUID(tracking_target_UID)
	if(tracking_target)
		if(tgui_alert(user, "Do you want to clear the tracker?", "Tracker reset", list("Yes", "No")) == "Yes")
			to_chat(user, "<span class='notice'>[src] stops tracking [tracking_target]</span>")
			stop_pointing()
	if(linked_pinpointer_UID)
		if(tgui_alert(user, "Do you want to clear the linked pinpointer?", "Pinpointer reset", list("Yes", "No")) == "Yes")
			to_chat(user, "<span class='notice'>[src] is ready to be linked to a new pinpointer.</span>")
			unlink()

/obj/item/gun/energy/detective/proc/link_pinpointer(pinpointer_UID)
	linked_pinpointer_UID = pinpointer_UID

/obj/item/gun/energy/detective/proc/unlink()
	var/obj/item/pinpointer/crew/C = locateUID(linked_pinpointer_UID)
	if(!C)
		return
	C.linked_gun_UID = null
	if(C.mode == PINPOINTER_MODE_DET)
		C.stop_tracking()
	linked_pinpointer_UID = null
	tracking_target_UID = null

/obj/item/gun/energy/detective/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message("<span class='notice'>[user] starts [overcharged ? "restoring" : "removing"] the safety limits on [src].</span>", "<span class='notice'>You start [overcharged ? "restoring" : "removing"] the safety limits on [src]</span>")
	if(!I.use_tool(src, user, 10 SECONDS, volume = I.tool_volume))
		user.visible_message("<span class='notice'>[user] stops modifying the safety limits on [src].", "You stop modifying the [src]'s safety limits</span>")
		return
	if(!overcharged)
		overcharged = TRUE
		ammo_type = list(/obj/item/ammo_casing/energy/detective/overcharge)
		update_ammo_types()
		select_fire(user)
	else // Unable to early return due to the visible message at the end
		overcharged = FALSE
		ammo_type = list(/obj/item/ammo_casing/energy/detective, /obj/item/ammo_casing/energy/detective/tracker_warrant)
		update_ammo_types()
		select_fire(user)
	user.visible_message("<span class='notice'>[user] [overcharged ? "removes" : "restores"] the safety limits on [src].", "You [overcharged ? "remove" : "restore" ] the safety limits on [src]</span>")
	update_icon()

/obj/item/gun/energy/detective/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/ammo_box/magazine/detective/speedcharger))
		return
	var/obj/item/ammo_box/magazine/detective/speedcharger/S = I
	if(!S.charge)
		to_chat(user, "<span class='notice'>[S] has no charge to give!</span>")
		return
	if(cell.charge == cell.maxcharge)
		to_chat(user, "<span class='notice'>[src] is already at full power!</span>")
		return
	var/new_speedcharger_charge = cell.give(S.charge)
	S.charge -= new_speedcharger_charge
	S.update_icon(UPDATE_OVERLAYS)
	update_icon()

/obj/item/gun/energy/detective/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(!overcharged)
		return ..()
	if(prob(clamp((100 - ((cell.charge / cell.maxcharge) * 100)), 10, 70)))	//minimum probability of 10, maximum of 70
		playsound(user, fire_sound, 50, 1)
		visible_message("<span class='userdanger'>[src]'s energy cell overloads!</span>")
		user.apply_damage(60, BURN, pick(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
		user.EyeBlurry(10 SECONDS)
		user.flash_eyes(2, TRUE)
		do_sparks(rand(5, 9), FALSE, src)
		playsound(src, 'sound/effects/bang.ogg', 100, TRUE)
		user.drop_item_to_ground(src)
		cell.charge = 0 //ha ha you lose
		update_icon()
		return
	return ..()

/obj/item/gun/energy/detective/proc/start_pointing(target_UID)
	tracking_target_UID = target_UID
	Announcer.autosay("Alert: Detective's revolver discharged in tracking mode. Tracking: [locateUID(tracking_target_UID)] at [get_area_name(src)].", src, "Security")
	var/obj/item/pinpointer/crew/C = locateUID(linked_pinpointer_UID)
	if(C)
		C.start_tracking()
		addtimer(CALLBACK(src, PROC_REF(stop_pointing)), 1 MINUTES, TIMER_UNIQUE)

/obj/item/gun/energy/detective/proc/stop_pointing()
	if(linked_pinpointer_UID)
		var/obj/item/pinpointer/crew/C = locateUID(linked_pinpointer_UID)
		if(C?.mode == PINPOINTER_MODE_DET)
			C.stop_tracking()
	tracking_target_UID = null


//////////////////////////////
// MARK: VOX SPIKETHROWER
//////////////////////////////
/obj/item/gun/energy/spikethrower
	name = "\improper Vox spike thrower"
	desc = "A vicious alien projectile weapon. Parts of it quiver gelatinously, as though the thing is insectile and alive."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "spikethrower"
	inhand_icon_state = "toxgun"
	fire_sound_text = "a strange noise"
	selfcharge = TRUE
	charge_delay = 10
	restricted_species = list(/datum/species/vox)
	ammo_type = list(/obj/item/ammo_casing/energy/spike)

/obj/item/gun/energy/spikethrower/emp_act()
	return

/obj/item/ammo_casing/energy/spike
	name = "alloy spike"
	desc = "A broadhead spike made out of a weird silvery metal."
	projectile_type = /obj/item/projectile/bullet/spike
	muzzle_flash_effect = null
	select_name = "spike"
	fire_sound = 'sound/weapons/bladeslice.ogg'

/obj/item/projectile/bullet/spike
	name = "alloy spike"
	desc = "It's about a foot of weird silvery metal with a wicked point."
	damage = 25
	knockdown = 2
	armor_penetration_flat = 30
	icon_state = "magspear"

/obj/item/projectile/bullet/spike/on_hit(atom/target, blocked = 0)
	if((blocked < 100) && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(50)
	..()

/obj/item/gun/energy/spikethrower/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This item's cell recharges on its own. Known to drive people mad by forcing them to wait for shots to recharge. Not compatible with rechargers.</span>"

//////////////////////////////
// MARK: VORTEX SHOTGUN
//////////////////////////////
/obj/item/gun/energy/vortex_shotgun
	name = "reality vortex wrist mounted shotgun"
	desc = "This weapon uses the power of the vortex core to rip apart the fabric of reality in front of it."
	icon_state = "flayer" //Sorta wrist mounted? Sorta? Not really but we work with what we got.
	flags = NODROP
	ammo_type = list(/obj/item/ammo_casing/energy/vortex_blast)
	fire_sound = 'sound/weapons/bladeslice.ogg'
	cell_type = /obj/item/stock_parts/cell/infinite

/obj/item/ammo_casing/energy/vortex_blast
	projectile_type = /obj/item/projectile/energy/vortex_blast
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/vortex_blast
	variance = 70
	pellets = 8
	delay = 1.2 SECONDS //and delay has to be stored here on energy guns
	select_name = "vortex blast"
	fire_sound = 'sound/weapons/wave.ogg'

/obj/item/projectile/energy/vortex_blast
	name = "vortex blast"
	hitscan = TRUE
	damage = 2
	range = 5
	icon_state = "magspear"
	hitsound = 'sound/weapons/sear.ogg' //Gets a bit spamy, suppressed is needed to suffer less
	hitsound_wall = null
	suppressed = TRUE

/obj/item/projectile/energy/vortex_blast/prehit(atom/target)
	. = ..()
	if(ishuman(target))
		return
	if(isliving(target))
		damage *= 4 //Up damage if not a human as we are not doing shenanigins
		return
	damage *= 6 //objects tend to fall apart as atoms are ripped up

/obj/item/projectile/energy/vortex_blast/on_hit(atom/target, blocked = 0)
	if(blocked >= 100)
		return ..()
	if(ishuman(target))
		var/mob/living/carbon/human/L = target
		var/obj/item/organ/external/affecting = L.get_organ(ran_zone(def_zone))
		L.apply_damage(2, BRUTE, affecting, L.run_armor_check(affecting, ENERGY))
		L.apply_damage(2, TOX, affecting, L.run_armor_check(affecting, ENERGY))
		L.apply_damage(2, CLONE, affecting, L.run_armor_check(affecting, ENERGY))
		L.adjustBrainLoss(3)
	..()

/obj/effect/temp_visual/target_angled/muzzle_flash/vortex_blast
	invisibility = 100 // visual is from effect

/obj/effect/temp_visual/target_angled/muzzle_flash/vortex_blast/Initialize(mapload, atom/target, duration_override)
	. = ..()
	if(target)
		new /obj/effect/warp_effect/vortex_blast(loc, target)

/obj/effect/warp_effect/vortex_blast
	icon = 'icons/effects/64x64.dmi'
	icon_state = "vortex_shotgun"

/obj/effect/warp_effect/vortex_blast/Initialize(mapload, target)
	. = ..()
	var/matrix/M = matrix() * 0.5
	M.Turn(get_angle(src, target) - 45)
	transform = M
	animate(src, transform = M * 10, time = 0.3 SECONDS, alpha = 0)
	QDEL_IN(src, 0.3 SECONDS)

/obj/item/gun/energy/sparker
	name = "\improper SPRK-12"
	desc = "A small, pistol-sized laser gun designed to regain charges from EMPs. Energy efficient, though its beams are weaker. Good at dual wielding, however."
	icon_state = "dueling_pistol"
	inhand_icon_state = "dueling_pistol"
	w_class = WEIGHT_CLASS_SMALL
	can_holster = TRUE
	execution_speed = 4 SECONDS
	weapon_weight = WEAPON_DUAL_WIELD
	shaded_charge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser/sparker)
	/// The cooldown tracking when we were last EMP'd
	COOLDOWN_DECLARE(emp_cooldown)

/obj/item/gun/energy/sparker/emp_act(severity)
	if(!COOLDOWN_FINISHED(src, emp_cooldown))
		return
	cell.charge = cell.maxcharge
	COOLDOWN_START(src, emp_cooldown, 1 MINUTES)
	atom_say("Energy coils recharged!")
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

//////////////////////////////
// MARK: MODEL 2495
//////////////////////////////

/obj/item/gun/energy/laser/lever_action
	name = "model 2495"
	desc = "A rifle styled after an ancient Earth design. Concealed beneath the wooden furniture and forged metal is a modern laser gun. Features a hand-powered charger that can be used anywhere."
	icon_state = "lever_action"
	inhand_icon_state = null // matches icon_state
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	origin_tech = "combat=5;magnets=4"
	slot_flags = ITEM_SLOT_BACK
	can_charge = FALSE
	cell_type = /obj/item/stock_parts/cell/energy_gun/lever_action
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/lever_action)
	shaded_charge = FALSE
	var/cycle_time = 1 SECONDS
	COOLDOWN_DECLARE(cycle_cooldown)

/obj/item/gun/energy/laser/lever_action/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This weapon is rechargable by cycling the action, or by twirling the firearm with some skill.</span>"

/obj/item/gun/energy/laser/lever_action/examine_more(mob/user)
	..()
	. = list()
	. += "The Model 2495 is Warp Tac's response to demand for a laserarm with the endurance required to be used far away from any support infrastructure for extended periods of time. \
	The forged metal and wooden body of the rifle is exceptionally ruggedized to resist rough handling, harsh climates, and whatever other general abuse may be thrown at it. \
	The internal components are beefier and larger than strictly required to lend further durability. Whilst it is quite heavy for a laserarm, it's only somewhat heavier than \
	average compared to a traditional ballistic rifle of similar size."
	. += ""
	. += "The main selling point of the rifle is the built-in recharging mechanism, operated by cycling a lever located around the trigger guard. \
	One full cycle provides enough energy for a single shot. Skillful users can twirl the rifle to operate the lever, although the operator's manual strongly cautions against doing so."
	. += ""
	. += "This weapon has long been one of Warp Tac's most popular products thanks to a large market among colonists, frontiersmen, and the occasional pirate outfit."

/obj/item/gun/energy/laser/lever_action/emp_act()
	return

/obj/item/gun/energy/laser/lever_action/attack_self__legacy__attackchain(mob/living/user as mob)
	if(!HAS_TRAIT(user, TRAIT_BADASS) && user.get_inactive_hand())
		to_chat(user, "<span class='warning'>You need both hands to cycle the action!")
		return
	cycle_action(user)
	if(HAS_TRAIT(user, TRAIT_BADASS) && istype(user.get_inactive_hand(), /obj/item/gun/energy/laser/lever_action))
		var/obj/item/gun/energy/laser/lever_action/offhand = user.get_inactive_hand()
		offhand.cycle_action()

/obj/item/gun/energy/laser/lever_action/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(!COOLDOWN_FINISHED(src, cycle_cooldown))
		return
	return ..()

/obj/item/gun/energy/laser/lever_action/proc/cycle_action(mob/living/user)
	if(!COOLDOWN_FINISHED(src, cycle_cooldown))
		return
	if(cell.charge == cell.maxcharge)
		return
	cell.give(cell.maxcharge)
	playsound(user, 'sound/weapons/gun_interactions/lever_action.ogg', 60, TRUE)
	update_icon()
	var/total_cycle_time = cycle_time
	if(current_lens)
		total_cycle_time /= current_lens.fire_rate_mult
	COOLDOWN_START(src, cycle_cooldown, total_cycle_time)

/obj/item/gun/energy/laser/lever_action/update_icon_state()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(cell.charge < shot.e_cost)
		icon_state = "lever_action_e"
	else
		icon_state = initial(icon_state)
