/obj/item/clothing/suit/armor
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/melee/classic_baton/telescopic,/obj/item/kitchen/knife/combat)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 40
	max_integrity = 250
	resistance_flags = NONE
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/armor/vest
	name = "armor vest"
	desc = "A mass-produced Level II soft armor vest that provides light protection against most sources of damage."
	icon_state = "armor"
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
	)

/obj/item/clothing/suit/armor/vest/jacket
	name = "military jacket"
	desc = "An old Federal Army surplus jacket. Armor panels sewn into the sides provide some protection against impacts and laser fire."
	icon_state = "militaryjacket"
	inhand_icon_state = null
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/armor/vest/combat
	name = "combat vest"
	desc = "A soft armor vest suitable for stopping minor impacts."
	icon_state = "armor-combat"

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	desc = "A Level II soft armor vest used by Nanotrasen corporate security. Offers light protection against kinetic impacts and lasers, and has a clip for a holobadge."
	var/obj/item/clothing/accessory/holobadge/attached_badge

/obj/item/clothing/suit/armor/vest/security/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/accessory/holobadge))
		if(user.transfer_item_to(I, src))
			add_fingerprint(user)
			attached_badge = I
			var/datum/action/A = new /datum/action/item_action/remove_badge(src)
			A.Grant(user)
			icon_state = "armorsec"
			user.update_inv_wear_suit()
			desc = "A Level II soft armor vest used by Nanotrasen corporate security, offering light protection against kinetic impacts and lasers. This one has [attached_badge] attached to it."
			to_chat(user, "<span class='notice'>You attach [attached_badge] to [src].</span>")
		return
	..()

/obj/item/clothing/suit/armor/vest/security/attack_self__legacy__attackchain(mob/user)
	if(attached_badge)
		add_fingerprint(user)
		user.put_in_hands(attached_badge)

		QDEL_LIST_CONTENTS(actions)

		icon_state = "armor"
		user.update_inv_wear_suit()
		desc = "A Level II soft armor vest used by Nanotrasen corporate security. Offers light protection against kinetic impacts and lasers, and has a clip for a holobadge."
		to_chat(user, "<span class='notice'>You remove [attached_badge] from [src].</span>")
		attached_badge = null

		return
	..()

/obj/item/clothing/suit/armor/vest/street_judge
	name = "judge's security armor"
	desc = "A standard Nanotrasen security vest with some decidedly non-standard decorations attached. Being made of cheap plastic, these decorations do not improve armor performance."
	icon_state = "streetjudgearmor"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
	)

/obj/item/clothing/suit/armor/vest/blueshield
	name = "blueshield's security armor"
	desc = "A Level II soft armor vest used by Nanotrasen's Blueshield bodyguard corps. Provides identical protection to standard Security soft vests."
	icon_state = "blueshield"

/obj/item/clothing/suit/armor/vest/bloody
	name = "bloodied security armor"
	desc = "An old, gore-covered security vest with a face crudely drawn on the chest. Where the hell did they even find this?"
	icon_state = "bloody_armor"
	sprite_sheets = null

/obj/item/clothing/suit/armor/vest/press
	name = "press vest"
	desc = "A sturdy vest that should keep you protected from the dangers of the station."
	icon_state = "press_vest"

/obj/item/clothing/suit/armor/secjacket
	name = "security jacket"
	desc = "A stylish black jacket used by Nanotrasen corporate security. Basic kevlar weave offers minor protection, but far less than a typical Security vest."
	icon_state = "secjacket_open"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 20, ACID = 20)
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/openclose)
	adjust_flavour = "unzip"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/armor/secponcho
	name = "security poncho"
	desc = "A stylish black and red poncho used by Nanotrasen corporate security. Basic kevlar weave provides minor protection against most sources of damage."
	icon_state = "security_poncho"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 20, ACID = 20)
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "An intimidating black greatcoat reinforced with Level II plate inserts for moderate protection."
	icon_state = "hos"
	inhand_icon_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 115, ACID = 450)
	flags_inv = HIDEJUMPSUIT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	strip_delay = 80
	insert_max = 2
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/armor/hos/alt
	name = "armored trenchcoat"
	desc = "A a stylish black trenchcoat fitted with Level II armored inserts for moderate protection without sacrificing aesthetics."
	icon_state = "hostrench_open"
	flags_inv = 0
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/openclose)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/armor/hos/jensen
	name = "armored trenchcoat"
	desc = "A trenchcoat augmented with a special alloy for some protection and style."
	icon_state = "jensencoat"
	flags_inv = 0
	sprite_sheets = null

/obj/item/clothing/suit/armor/vest/warden
	name = "warden's armored jacket"
	desc = "A comfortable armored jacket fitted with Level II plate inserts for moderate protection. This one has silver livery on the shoulders to denote rank."
	icon_state = "warden_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|HANDS
	strip_delay = 70
	resistance_flags = FLAMMABLE
	dog_fashion = null
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/armor/vest/warden/alt
	name = "warden's jacket"
	desc = "A large navy-blue jacket fitted with Level II armored inserts. There are silver rank insignia on the shoulders."
	icon_state = "warden_jacket_alt"

//Captain
/obj/item/clothing/suit/armor/vest/capcarapace
	name = "captain's carapace"
	desc = "A fancy blue & gold dragonscale armor vest fitted with Level III and IV armor panelling. Offers excellent protection against melee attacks, kinetic impacts, and laser discharges. "
	icon_state = "captain_carapace"
	armor = list(MELEE = 50, BULLET = 35, LASER = 50, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = INFINITY, ACID = 450)
	dog_fashion = null
	resistance_flags = FIRE_PROOF
	allowed = list(/obj/item/disk, /obj/item/stamp, /obj/item/reagent_containers/drinks/flask, /obj/item/melee, /obj/item/storage/lockbox/medal, /obj/item/flash, /obj/item/storage/fancy/matches, /obj/item/lighter, /obj/item/clothing/mask/cigarette, /obj/item/storage/fancy/cigarettes, /obj/item/tank/internals/emergency_oxygen, /obj/item/gun/energy, /obj/item/gun/projectile)
	insert_max = 3

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
	)

/obj/item/clothing/suit/armor/vest/capcarapace/jacket
	name = "captain's jacket"
	desc = "A comfy semiformal jacket for the Captain on the move. Embedded kevlar weave and Level II armor panels provide moderate protection without sacrificing class."
	icon_state = "captain_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(MELEE = 40, BULLET = 20, LASER = 25, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = INFINITY, ACID = 450)

/obj/item/clothing/suit/armor/vest/capcarapace/jacket/tunic
	name = "captain's tunic"
	desc = "A snappy blue dress tunic for Captains of class. Kevlar weave and sewn-in Level II armor plates provide moderate protection in all areas."
	icon_state = "captain_tunic"

/obj/item/clothing/suit/armor/vest/capcarapace/coat
	name = "captain's formal coat"
	desc = "A large, fancy, and exquisately tailored dress coat for the most image-conscious of Nanotrasen Captains. Level II armor plates and impact gel panels sewn into the fabric provide light protection against most damage types."
	icon_state = "captain_formal"
	armor = list(MELEE = 35, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = INFINITY, ACID = 450)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/armor/vest/capcarapace/coat/white
	name = "captain's long white tunic"
	desc = "A beautiful dress white tunic for Captains of demanding taste. A mix of kevlar weave and Level II armor inserts provide basic protection against most threats."
	icon_state = "captain_white"

	// Drask look fine in the regular human version
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
	)

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	desc = "A bulky, full-body suit of layered armor and impact cushions that provides outstanding protection against blunt trauma, fire, and corrosive substances. Much less effective against all other forms of damage, however."
	icon_state = "riot"
	inhand_icon_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 50, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 200, ACID = 200)
	strip_delay = 80
	put_on_delay = 60
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/armor/riot/sec
	name = "security riot suit"
	desc = "A full-body suit of riot gear that provides excellent protection against blunt force trauma, fire, and corrosive substances, but little protection otherwise. This suit is covered in red Security stripes."
	icon_state = "riot-sec"

/obj/item/clothing/suit/armor/riot/knight
	name = "plate armour"
	desc = "A full suit of steel plate armor, it looks like it came right out of a documentary about the Middle Ages. The plating offers excellent protection against melee, and the asbestos-lined padding provides excellent protection against fire and corrosive substances, but it won't be stopping any weapon designed in the last half-millennium."
	icon_state = "knight_green"
	inhand_icon_state = null
	slowdown = 1
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')
	hide_tail_by_species = list("Vox")

/obj/item/clothing/suit/armor/riot/knight/yellow
	icon_state = "knight_yellow"

/obj/item/clothing/suit/armor/riot/knight/blue
	icon_state = "knight_blue"

/obj/item/clothing/suit/armor/riot/knight/red
	icon_state = "knight_red"

/obj/item/clothing/suit/armor/riot/knight/templar
	name = "crusader armour"
	desc = "A heavy suit of cosplay-grade armor that vaguely resembles something from a low-quality documentary about the crusades. Whilst the plating provides mediocre protection against melee attacks and little else, the asbestos-lined padding does hold up quite well to fire and corrosive substances."
	icon_state = "knight_templar"
	allowed = list(/obj/item/nullrod/claymore, /obj/item/storage/bible)
	armor = list(MELEE = 15, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 200, ACID = 200)

/obj/item/clothing/suit/armor/vest/durathread
	name = "durathread vest"
	desc = "A comfortable and low-profile vest made of durathread, reinforced with panels of tanned leather. Offers decent protection against laser discharges, but won't be stopping a bullet any time soon."
	icon_state = "durathread"
	max_integrity = 200
	resistance_flags = FLAMMABLE
	armor = list(MELEE = 10, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 35, ACID = 50)

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof armor"
	desc = "A full-body suit of armor fitted with Level IV ballistic armor inserts and panelling across the body. Will stop most low-caliber kinetic projectiles and help resist the concussive force of explosions, but it does little against melee and energy attacks."
	icon_state = "bulletproof"
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	armor = list(MELEE = 10, BULLET = 50, LASER = 5, ENERGY = 5, BOMB = 35, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 8 SECONDS
	put_on_delay = 6 SECONDS
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/armor/bulletproof/sec
	name = "security bulletproof armor"
	desc = "A full-body suit of armor fitted with Level IV ballistic inserts and panelling. Will stop most low-caliber kinetic rounds and resist the concussive force of explosions somewhat, but it does little against melee and energy attacks. This suit is covered in red Security stripes."
	icon_state = "bulletproof-sec"

/obj/item/clothing/suit/armor/swat
	name = "SWAT armor"
	desc = "A large, bulky suit of tactical armor commonly used by specialized police units. Offers moderate protection in all areas. It has a surface coating that completely resists harm from fire and corrosive attacks."
	icon_state = "heavy"
	inhand_icon_state = "swat_suit"
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 50,RAD = 10, FIRE = INFINITY, ACID = INFINITY)
	strip_delay = 12 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/armor/laserproof
	name = "ablative armor vest"
	desc = "A high-tech armor vest specializing against energy attacks. A miniaturized energy shielding system deflects incoming shots on a short cooldown, while a reflective outer shell and \
		specialized heat dissipation materials protect against direct energy impacts. Unfortunately, it offers little in the way of defense against solid projectiles or melee weapons."
	icon_state = "armor_reflec"
	blood_overlay_type = "armor"
	armor = list(MELEE = 5, BULLET = 5, LASER = 75, ENERGY = 50, BOMB = 0, RAD = 0, FIRE = INFINITY, ACID = INFINITY)
	var/last_reflect_time
	var/reflect_cooldown = 5 SECONDS

/obj/item/clothing/suit/armor/laserproof/IsReflect()
	var/mob/living/carbon/human/user = loc
	if(user.wear_suit != src)
		return 0
	if(world.time - last_reflect_time >= reflect_cooldown)
		last_reflect_time = world.time
		return 1
	if(world.time - last_reflect_time <= 1) // This is so if multiple energy projectiles hit at once, they're all reflected
		return 1
	return 0

/obj/item/clothing/suit/armor/vest/det_suit
	name = "armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	allowed = list(/obj/item/tank/internals/emergency_oxygen,/obj/item/reagent_containers/spray/pepper,/obj/item/flashlight,/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/storage/fancy/cigarettes,/obj/item/lighter,/obj/item/detective_scanner,/obj/item/taperecorder)
	resistance_flags = FLAMMABLE
	dog_fashion = null

//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "reactive armor"
	desc = "A massive, complex, and currently entirely worthless vest that forms the basis of a reactive armor system. Requires an anomaly core to actually work."
	/// Is the armor turned on?
	var/active = FALSE
	/// Is the armor disabled, and prevented from reactivating temporarly?
	var/disabled = FALSE
	icon_state = "reactiveoff"
	blood_overlay_type = "armor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = INFINITY, ACID = INFINITY)
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hit_reaction_chance = 50
	insert_max = 2
	/// The cell reactive armor uses.
	var/obj/item/stock_parts/cell/emproof/reactive/cell
	/// Cost multiplier for armor. "Stronger" armors use 200 charge, other armors use 120.
	var/energy_cost = 120
	/// Is the armor in the one second grace period, to prevent rubbershot / buckshot from draining significant cell useage.
	var/in_grace_period = FALSE


/obj/item/clothing/suit/armor/reactive/Initialize(mapload, ...)
	. = ..()
	cell = new(src)
	AddElement(/datum/element/high_value_item)

/obj/item/clothing/suit/armor/reactive/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/clothing/suit/armor/reactive/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>The armor is [round(cell.percent())]% charged.</span>"

/obj/item/clothing/suit/armor/reactive/examine_more(mob/user)
	. = ..()
	. += "Reactive armor systems are one of the uses that Nanotasen has found for the anomaly cores that can be recovered from the anomalous phenomena that occur in the area of space near Lavaland. \
	The effects of these armor units can be unpredictable or undesirable in certain situations, so Nanotrasen advises only activating them when the user is in danger."
	. += ""
	. += "Outside of the strange effects caused by the anomaly core, the armor provides no protection against conventional attacks. \
	Nanotrasen cannot be held liable for injury and/or death due to misuse or proper operation of the reactive armor."

/obj/item/clothing/suit/armor/reactive/attack_self__legacy__attackchain(mob/user)
	active = !(active)
	if(disabled)
		to_chat(user, "<span class='warning'>[src] is disabled and rebooting!</span>")
		return
	if(active)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
		icon_state = "reactive"
	else
		to_chat(user, "<span class='notice'>[src] is now inactive.</span>")
		icon_state = "reactiveoff"
		add_fingerprint(user)
	user.update_inv_wear_suit()
	update_action_buttons()

/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	var/emp_power = 5 + (severity-1 ? 0 : 5)
	if(!disabled) //We want ions to drain power, but we do not want it to drain all power in one go, or be one shot via ion scatter
		cell.use(energy_cost * 4 / severity)
	disable(emp_power)
	..()

/obj/item/clothing/suit/armor/reactive/proc/use_power()
	if(in_grace_period)
		return TRUE
	if(!cell.use(energy_cost)) //No working if cells are dry
		return FALSE
	in_grace_period = TRUE
	addtimer(VARSET_CALLBACK(src, in_grace_period, FALSE), 1 SECONDS)
	return TRUE

/obj/item/clothing/suit/armor/reactive/get_cell()
	return cell

/obj/item/clothing/suit/armor/reactive/proc/disable(disable_time = 0)
	active = FALSE
	disabled = TRUE
	icon_state = "reactiveoff"
	addtimer(CALLBACK(src, PROC_REF(reboot)), disable_time SECONDS)
	if(ishuman(loc))
		var/mob/living/carbon/human/C = loc
		C.update_inv_wear_suit()

/obj/item/clothing/suit/armor/reactive/proc/reboot()
	disabled = FALSE
	active = TRUE
	icon_state = "reactive"
	if(ishuman(loc))
		var/mob/living/carbon/human/C = loc
		C.update_inv_wear_suit()

/obj/item/clothing/suit/armor/reactive/proc/reaction_check(hitby)
	if(prob(hit_reaction_chance))
		if(isprojectile(hitby))
			var/obj/item/projectile/P = hitby
			if(istype(P, /obj/item/projectile/ion))
				return FALSE
			if(!P.nodamage || P.stun || P.weaken)
				return TRUE
		else
			return TRUE

//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "reactive teleportation armor"
	desc = "A reactive armor vest fitted with a bluespace anomaly core, allowing it to teleport its wearer away from danger. Looking directly at the core fills you with a sense of vertigo."
	energy_cost = 200
	var/tele_range = 6

/obj/item/clothing/suit/armor/reactive/teleport/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return 0
	if(reaction_check(hitby) && is_teleport_allowed(owner.z) && use_power())
		var/mob/living/carbon/human/H = owner
		if(do_teleport(owner, owner, 6, safe_turf_pick = TRUE)) //Teleport on the same spot with a precision of 6 gets a random tile near the owner.
			owner.visible_message("<span class='danger'>The reactive teleport system flings [H] clear of [attack_text]!</span>")
			return TRUE
		return FALSE
	return FALSE

/obj/item/clothing/suit/armor/reactive/fire
	name = "reactive incendiary armor"
	desc = "A reactive armor vest fitted with a pyroclastic anomaly core, which sprays jets of flame when its wearer is threatened, as well as protecting the wearer from extreme heat. A gentle warmth emanates from the core."
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/armor/reactive/fire/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_OUTER_SUIT)
		return
	ADD_TRAIT(user, TRAIT_RESISTHEAT, "[UID()]")

/obj/item/clothing/suit/armor/reactive/fire/dropped(mob/user, silent)
	..()
	REMOVE_TRAIT(user, TRAIT_RESISTHEAT, "[UID()]")

/obj/item/clothing/suit/armor/reactive/fire/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(reaction_check(hitby) && use_power())
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], sending out jets of flame!</span>")
		for(var/mob/living/carbon/C in range(6, owner))
			if(C != owner)
				C.fire_stacks += 8
				C.IgniteMob()
				add_attack_logs(owner, C, "[C] was ignited by [owner]'s [src]", ATKLOG_ALMOSTALL) //lord have mercy on almost_all attack log admins
		return TRUE
	return FALSE

/obj/item/clothing/suit/armor/reactive/cryo
	name = "reactive gelidic armor" //is "gelidic" a word? probably not, but it sounds cool
	desc = "A reactive armor vest fitted with a cryogenic anomaly core, which vents supercooled gasses at threats to its wearer. A faint wind can be heard near the core."

/obj/item/clothing/suit/armor/reactive/cryo/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_OUTER_SUIT)
		return
	ADD_TRAIT(user, TRAIT_RESISTCOLD, "[UID()]")

/obj/item/clothing/suit/armor/reactive/cryo/dropped(mob/user, silent)
	..()
	REMOVE_TRAIT(user, TRAIT_RESISTCOLD, "[UID()]")

/obj/item/clothing/suit/armor/reactive/cryo/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(reaction_check(hitby) && use_power())
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], sending out freezing bolts!</span>")

		for(var/mob/living/M in oview(get_turf(src), 7))
			shootAt(M)

		if(prob(10)) //rarely vent gasses
			owner.visible_message("<span class='warning'>[src] vents excess coolant!</span>")
			playsound(loc, 'sound/effects/refill.ogg', 50, TRUE)

			var/turf/simulated/T = get_turf(src)
			if(istype(T))
				T.atmos_spawn_air(LINDA_SPAWN_COLD | LINDA_SPAWN_N2O | LINDA_SPAWN_CO2, 20)

		disable(rand(1, 3))

		return TRUE
	return FALSE

/obj/item/clothing/suit/armor/reactive/cryo/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U)
		return
	var/obj/item/projectile/temp/basilisk/O = new /obj/item/projectile/temp/basilisk(T)
	playsound(get_turf(src), 'sound/weapons/taser2.ogg', 75, TRUE)
	O.current = T
	O.yo = U.y - T.y
	O.xo = U.x - T.x
	O.fire()


/obj/item/clothing/suit/armor/reactive/stealth
	name = "reactive stealth armor"
	desc = "A reactive armor vest fitted with a vortex anomaly core, which can turns its wearer invisible at the first sign of danger. The air around the core seems to shimmer and shift."
	energy_cost = 200

/obj/item/clothing/suit/armor/reactive/stealth/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(reaction_check(hitby) && use_power())
		var/mob/living/simple_animal/hostile/illusion/escape/stealth/E = new(owner.loc)
		E.Copy_Parent(owner, 50)
		E.GiveTarget(owner) //so it starts running right away
		E.Goto(owner, E.move_to_delay, E.minimum_distance)
		owner.visible_message("<span class='danger'>[owner] is hit by [attack_text] in the chest!</span>") //We pretend to be hit, since blocking it would stop the message otherwise
		owner.make_invisible()
		disable(rand(4, 5)) //No blocking while invisible
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, reset_visibility)), 4 SECONDS)
		return TRUE

/obj/item/clothing/suit/armor/reactive/tesla
	name = "reactive tesla armor"
	desc = "A reactive armor vest fitted with an electrical anomaly core, which fires lethal bolts of electricty at threats to its wearer. The air around the core smells of ozone."

/obj/item/clothing/suit/armor/reactive/tesla/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(reaction_check(hitby) && use_power())
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], sending out arcs of lightning!</span>")
		for(var/mob/living/M in view(6, owner))
			if(M == owner)
				continue
			owner.Beam(M,icon_state="lightning[rand(1, 12)]",icon='icons/effects/effects.dmi',time=5)
			M.adjustFireLoss(20)
			playsound(M, 'sound/machines/defib_zap.ogg', 50, TRUE, -1)
			add_attack_logs(owner, M, "[M] was shocked by [owner]'s [src]", ATKLOG_ALMOSTALL)
		disable(rand(2, 5)) // let's not have buckshot set it off 4 times and do 80 burn damage.
		return TRUE

/obj/item/clothing/suit/armor/reactive/repulse
	name = "reactive repulse armor"
	desc = "A reactive armor vest fitted with a gravitational anomaly core, which violently repels threats to its wearer. The core pulses with light, akin to a heartbeat."
	///How strong the reactive armor is for throwing
	var/repulse_power = 3
	/// How far away are we finding things to throw
	var/repulse_range = 5
	/// What the sparkles looks like
	var/sparkle_path = /obj/effect/temp_visual/gravpush
	energy_cost = 200

/obj/item/clothing/suit/armor/reactive/repulse/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(reaction_check(hitby) && use_power())
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], converting the attack into a wave of force!</span>")
		use_power()
		var/list/thrown_atoms = list()
		for(var/turf/T in range(repulse_range, owner)) //Done this way so things don't get thrown all around hilariously.
			for(var/atom/movable/AM in T)
				thrown_atoms += AM

		for(var/atom/movable/AM as anything in thrown_atoms)
			if(AM == owner || AM.anchored || (ismob(AM) && !isliving(AM)))
				continue

			var/throw_target = get_edge_target_turf(owner, get_dir(owner, get_step_away(AM, owner)))
			var/dist_from_user = get_dist(owner, AM)
			if(dist_from_user == 0)
				if(isliving(AM))
					var/mob/living/M = AM
					M.Weaken(6 SECONDS)
					to_chat(M, "<span class='userdanger'>You're slammed into the floor by [owner]'s reactive armor!</span>")
					add_attack_logs(owner, M, "[M] was thrown by [owner]'s [src]", ATKLOG_ALMOSTALL)
			else
				new sparkle_path(get_turf(AM), get_dir(owner, AM))
				if(isliving(AM))
					var/mob/living/M = AM
					to_chat(M, "<span class='userdanger'>You're thrown back by [owner]'s reactive armor!</span>")
					add_attack_logs(owner, M, "[M] was thrown by [owner]'s [src]", ATKLOG_ALMOSTALL)
				INVOKE_ASYNC(AM, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, ((clamp((repulse_power - (clamp(dist_from_user - 2, 0, dist_from_user))), 3, repulse_power))), 1) //So stuff gets tossed around at the same time.
		disable(rand(2, 5))
		return TRUE

/obj/effect/spawner/reactive_armor
	name = "Random Reactive Armor"
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "reactiveoff"

/obj/effect/spawner/reactive_armor/Initialize(mapload)
	. = ..()
	var/spawnpath = pick(subtypesof(/obj/item/clothing/suit/armor/reactive))
	new spawnpath(loc)
	return INITIALIZE_HINT_QDEL

//All of the armor below is mostly unused

/obj/item/clothing/suit/armor/centcomm
	name = "Cent. Com. armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/gun/energy,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/tank/internals/emergency_oxygen)
	flags = THICKMATERIAL
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	sprite_sheets = null
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = 450, ACID = 450)
	flags_2 = RAD_PROTECT_CONTENTS_2
	insert_max = 5

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A generic suit of heavy armor. Protects against damage, to the surprise of none."
	icon_state = "heavy"
	inhand_icon_state = "swat_suit"
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = 450, ACID = 450)
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.90
	flags = THICKMATERIAL
	flags_2 = RAD_PROTECT_CONTENTS_2
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv = HIDEGLOVES|HIDEJUMPSUIT
	hide_tail_by_species = list("Vox")

/obj/item/clothing/suit/armor/tdome
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = 450, ACID = 450)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDEJUMPSUIT
	flags = THICKMATERIAL
	flags_2 = RAD_PROTECT_CONTENTS_2
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	hide_tail_by_species = list("Vox")

/obj/item/clothing/suit/armor/tdome/red
	name = "red Thunderdome armor"
	desc = "Armor worn by the red Thunderdome team."
	icon_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "green Thunderdome armor"
	desc = "Armor worn by the green Thunderdome team."
	icon_state = "tdgreen"

//Federation
/obj/item/clothing/suit/armor/federation/marine
	name = "\improper Federation marine combat armor"
	desc = "A full-body suit of semi-powered assault armor used by the Trans-Solar Marine Corps. Offers excellent protection in all areas without impairing movement."
	icon_state = "fedarmor_marine"
	armor = list(MELEE = 40, BULLET = 45, LASER = 45, ENERGY = 40, BOMB = 100, RAD = 25, FIRE = INFINITY, ACID = 100)
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/rcd, /obj/item/crowbar, \
					/obj/item/screwdriver, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/wrench, /obj/item/multitool, \
					/obj/item/radio, /obj/item/analyzer, /obj/item/gun, /obj/item/melee/baton, /obj/item/reagent_containers/spray/pepper, \
					/obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/restraints/handcuffs)
	flags = THICKMATERIAL | STOPSPRESSUREDMAGE
	strip_delay = 12 SECONDS

/obj/item/clothing/suit/armor/federation/marine/officer
	name = "\improper Federation marine officer's armor"
	icon_state = "fedarmor_marine_officer"
	desc = "A full-body suit of semi-powered assault armor used by the Trans-Solar Marine Corps. Offers excellent protection in all areas without impairing movement. This suit has golden stripes instead of the typical white."

/obj/item/clothing/suit/armor/federation/marine/export
	name = "\improper Federation marine combat armor (E)"
	desc = "An export-grade suit of semi-powered assault armor commonly sold or given to allies of the Trans-Solar Federation. It has moderately reduced capabilites compared to a standard suit."
	armor = list(MELEE = 30, BULLET = 35, LASER = 35, ENERGY = 30, BOMB = 50, RAD = 0, FIRE = 100, ACID = 50)

//Non-hardsuit ERT armor.
/obj/item/clothing/suit/armor/vest/ert
	name = "emergency response team armor"
	desc = "A mid-quality protective vest produced by Citadel Armories. Additional polymer paneling over the chest and shoulders offers moderately improved energy protection compared to standard kevlar vests."
	icon_state = "ertarmor_cmd"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 10, RAD = 0, FIRE = 50, ACID = 50)

//Commander
/obj/item/clothing/suit/armor/vest/ert/command
	name = "emergency response team commander armor"
	desc = "A mid-quality protective vest produced by Citadel Armories. Additional polymer paneling over the chest and shoulders offers moderately improved energy protection compared to standard kevlar vests. This one has chipped blue Command insignia on the shoulders."

//Security
/obj/item/clothing/suit/armor/vest/ert/security
	name = "emergency response team security armor"
	desc = "A mid-quality protective vest produced by Citadel Armories. Additional polymer paneling over the chest and shoulders offers moderately improved energy protection compared to standard kevlar vests. This one has chipped red Security insignia on the shoulders."
	icon_state = "ertarmor_sec"

//Paranormal
/obj/item/clothing/suit/armor/vest/ert/security/paranormal
	name = "emergency response team paranormal armor"
	desc = "A full suit of medieval plate armor, kitted out in crusader colors. Where the hell did they even find this? There are chipped black insignia on the shoulders."
	icon_state = "knight_templar"
	inhand_icon_state = null

//Engineer
/obj/item/clothing/suit/armor/vest/ert/engineer
	name = "emergency response team engineer armor"
	desc = "A mid-quality protective vest produced by Citadel Armories. Additional polymer paneling over the chest and shoulders offers moderately improved energy protection compared to standard kevlar vests. This one has chipped orange Engineering insignia on the shoulders."
	icon_state = "ertarmor_eng"

//Medical
/obj/item/clothing/suit/armor/vest/ert/medical
	name = "emergency response team medical armor"
	desc = "A mid-quality protective vest produced by Citadel Armories. Additional polymer paneling over the chest and shoulders offers moderately improved energy protection compared to standard kevlar vests. This one has chipped white Medical insignia on the shoulders."
	icon_state = "ertarmor_med"

//Janitorial
/obj/item/clothing/suit/armor/vest/ert/janitor
	name = "emergency response team janitor armor"
	desc = "A mid-quality protective vest produced by Citadel Armories. Additional polymer paneling over the chest and shoulders offers moderately improved energy protection compared to standard kevlar vests. This one has chipped purple Janitorial insignia on the shoulders."
	icon_state = "ertarmor_jan"

//same defense as basic sec armor
/obj/item/clothing/suit/storage/iaa/blackjacket/armored
	desc = "A snappy dress jacket, reinforced with a layer of armor protecting the torso."
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/gun/projectile/revolver, /obj/item/gun/projectile/automatic/pistol)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 35, ACID = 35)

//LAVALAND!

/obj/item/clothing/suit/hooded/drake
	name = "drake armour"
	desc = "A suit of armour fashioned from the remains of an ash drake."
	icon_state = "dragon"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/spear)
	armor = list(MELEE = 115, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 150, RAD = 25, FIRE = INFINITY, ACID = INFINITY)
	hoodtype = /obj/item/clothing/head/hooded/drake
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/hooded/drake
	name = "drake helmet"
	desc = "The skull of a dragon."
	icon_state = "dragon"
	armor = list(MELEE = 115, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 150, RAD = 25, FIRE = INFINITY, ACID = INFINITY)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/suit/hooded/goliath
	name = "goliath cloak"
	desc = "A staunch, practical cape made out of numerous monster materials, it is coveted amongst exiles & hermits."
	icon_state = "goliath_cloak"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/spear, /obj/item/organ/internal/regenerative_core/legion, /obj/item/kitchen/knife/combat/survival)
	armor = list(MELEE = 25, BULLET = 5, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 75, ACID = 75) //a fair alternative to bone armor, requiring alternative materials and gaining a suit slot
	hoodtype = /obj/item/clothing/head/hooded/goliath
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/head/hooded/goliath
	name = "goliath cloak hood"
	desc = "A protective & concealing hood."
	icon_state = "golhood"
	armor = list(MELEE = 25, BULLET = 5, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 75, ACID = 75)
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'

/obj/item/clothing/suit/hooded/bone_light
	name = "light bone armor"
	desc = "A lightweight set of bone armor, crafted crudely from animal products."
	icon_state = "light_bone_armor"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/spear)
	armor = list(MELEE = 15, BULLET = 10, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 50, ACID = 50)
	hoodtype = /obj/item/clothing/head/hooded/bone_light
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
	)

/obj/item/clothing/head/hooded/bone_light
	name = "light bone helmet"
	desc = "A crude helmet crafted from the bones of animals."
	icon_state = "light_bone_helmet"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 15, BULLET = 10, LASER = 10, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES
	heat_protection = HEAD
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
	)

/obj/item/clothing/suit/armor/bone
	name = "bone armor"
	desc = "A tribal armor plate, crafted from animal bone."
	icon_state = "bonearmor"
	blood_overlay_type = "armor"
	armor = list(MELEE = 25, BULLET = 15, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
