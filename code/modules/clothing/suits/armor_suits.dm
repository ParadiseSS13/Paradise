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
	name = "armor"
	desc = "An armored vest that protects against some damage."
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
	)
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/armor/vest/jacket
	name = "military jacket"
	desc = "An old military jacket, it has armoring."
	icon_state = "militaryjacket"
	item_state = "militaryjacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/armor/vest/combat
	name = "combat vest"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor-combat"
	item_state = "bulletproof"
	blood_overlay_type = "armor"

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	desc = "An armored vest that protects against some damage. This one has a clip for a holobadge."
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
	)
	icon_state = "armor"
	item_state = "armor"
	var/obj/item/clothing/accessory/holobadge/attached_badge

/obj/item/clothing/suit/armor/vest/security/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/accessory/holobadge))
		if(user.unEquip(I))
			add_fingerprint(user)
			I.forceMove(src)
			attached_badge = I
			var/datum/action/A = new /datum/action/item_action/remove_badge(src)
			A.Grant(user)
			icon_state = "armorsec"
			user.update_inv_wear_suit()
			desc = "An armored vest that protects against some damage. This one has [attached_badge] attached to it."
			to_chat(user, "<span class='notice'>You attach [attached_badge] to [src].</span>")
		return
	..()

/obj/item/clothing/suit/armor/vest/security/attack_self(mob/user)
	if(attached_badge)
		add_fingerprint(user)
		user.put_in_hands(attached_badge)

		QDEL_LIST_CONTENTS(actions)

		icon_state = "armor"
		user.update_inv_wear_suit()
		desc = "An armored vest that protects against some damage. This one has a clip for a holobadge."
		to_chat(user, "<span class='notice'>You remove [attached_badge] from [src].</span>")
		attached_badge = null

		return
	..()

/obj/item/clothing/suit/armor/vest/street_judge
	name = "judge's security armor"
	desc = "Perfect for when you're looking to send a message rather than performing your actual duties."
	icon_state = "streetjudgearmor"

/obj/item/clothing/suit/armor/vest/blueshield
	name = "blueshield's security armor"
	desc = "An armored vest with the badge of a Blueshield Lieutenant."
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
	)
	icon_state = "blueshield"
	item_state = "blueshield"

/obj/item/clothing/suit/armor/vest/bloody
	name = "bloodied security armor"
	desc = "A vest drenched in the blood of Greytide. It has seen better days."
	icon_state = "bloody_armor"
	item_state = "bloody_armor"
	sprite_sheets = null

/obj/item/clothing/suit/armor/secjacket
	name = "security jacket"
	desc = "A sturdy black jacket with reinforced fabric. Bears insignia of NT corporate security."
	icon_state = "secjacket_open"
	item_state = "hos"
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


/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A trench coat enhanced with a special alloy for some protection and style."
	icon_state = "hos"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 115, ACID = 450)
	flags_inv = HIDEJUMPSUIT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	strip_delay = 80
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/armor/hos/alt
	name = "armored trenchcoat"
	desc = "A trenchcoat enhanced with a special lightweight kevlar. The epitome of tactical plainclothes."
	icon_state = "hostrench_open"
	item_state = "hostrench_open"
	flags_inv = 0
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/openclose)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/armor/hos/jensen
	name = "armored trenchcoat"
	desc = "A trenchcoat augmented with a special alloy for some protection and style."
	icon_state = "jensencoat"
	item_state = "jensencoat"
	flags_inv = 0
	sprite_sheets = null

/obj/item/clothing/suit/armor/vest/warden
	name = "warden's armored jacket"
	desc = "An armored jacket with silver rank pips and livery."
	icon_state = "warden_jacket"
	item_state = "armor"
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
	desc = "A navy-blue armored jacket with blue shoulder designations and '/Warden/' stitched into one of the chest pockets."
	icon_state = "warden_jacket_alt"

//Captain
/obj/item/clothing/suit/armor/vest/capcarapace
	name = "captain's carapace"
	desc = "An armored vest reinforced with ceramic plates and pauldrons to provide additional protection whilst still offering maximum mobility and flexibility. Issued only to the station's finest, although it does chafe your nipples."
	icon_state = "captain_carapace"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(MELEE = 50, BULLET = 35, LASER = 50, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = INFINITY, ACID = 450)
	dog_fashion = null
	resistance_flags = FIRE_PROOF
	allowed = list(/obj/item/disk, /obj/item/stamp, /obj/item/reagent_containers/food/drinks/flask, /obj/item/melee, /obj/item/storage/lockbox/medal, /obj/item/flash, /obj/item/storage/box/matches, /obj/item/lighter, /obj/item/clothing/mask/cigarette, /obj/item/storage/fancy/cigarettes, /obj/item/tank/internals/emergency_oxygen, /obj/item/gun/energy, /obj/item/gun/projectile)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
	)

/obj/item/clothing/suit/armor/vest/capcarapace/jacket
	name = "captain's jacket"
	desc = "A less formal jacket for everyday captain use."
	icon_state = "captain_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(MELEE = 40, BULLET = 20, LASER = 25, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = INFINITY, ACID = 450)
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/armor/vest/capcarapace/jacket/tunic
	name = "captain's tunic"
	desc = "Worn by a Captain to show their class."
	icon_state = "captain_tunic"

/obj/item/clothing/suit/armor/vest/capcarapace/coat
	name = "captain's formal coat"
	desc = "For when an armored vest isn't fashionable enough."
	icon_state = "captain_formal"
	armor = list(MELEE = 35, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = INFINITY, ACID = 450)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/armor/vest/capcarapace/coat/white
	name = "captain's long white tunic"
	desc = "An old style captain tunic. Makes you look and feel like you're wearing a cardboard box with arm holes cut in it but looks like it would be great for a wedding... or a funeral."
	icon_state = "captain_white"

	sprite_sheets = list( //Drask look fine in the regular human version
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
	)

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 50, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 200, ACID = 200)
	flags_inv = HIDEJUMPSUIT
	strip_delay = 80
	put_on_delay = 60
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/armor/riot/sec
	name = "security riot suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement. This one has security markings on it."
	icon_state = "riot-sec"
	item_state = "swat_suit"

/obj/item/clothing/suit/armor/riot/knight
	name = "plate armour"
	desc = "A classic suit of plate armour, highly effective at stopping melee attacks."
	icon_state = "knight_green"
	item_state = "knight_green"
	slowdown = 1
	sprite_sheets = list()

/obj/item/clothing/suit/armor/riot/knight/yellow
	icon_state = "knight_yellow"
	item_state = "knight_yellow"

/obj/item/clothing/suit/armor/riot/knight/blue
	icon_state = "knight_blue"
	item_state = "knight_blue"

/obj/item/clothing/suit/armor/riot/knight/red
	icon_state = "knight_red"
	item_state = "knight_red"

/obj/item/clothing/suit/armor/riot/knight/templar
	name = "crusader armour"
	desc = "God wills it!"
	icon_state = "knight_templar"
	item_state = "knight_templar"
	allowed = list(/obj/item/nullrod/claymore, /obj/item/storage/bible)
	armor = list(MELEE = 15, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 200, ACID = 200)

/obj/item/clothing/suit/armor/vest/durathread
	name = "durathread vest"
	desc = "A vest made of durathread with strips of leather acting as trauma plates."
	icon_state = "durathread"
	item_state = "durathread"
	strip_delay = 60
	max_integrity = 200
	resistance_flags = FLAMMABLE
	armor = list(MELEE = 10, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 35, ACID = 50)

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof vest"
	desc = "A bulletproof vest that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "bulletproof"
	item_state = "armor"
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
	name = "security bulletproof vest"
	desc = "A bulletproof vest that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent. This one has security markings on it."
	icon_state = "bulletproof-sec"
	item_state = "armor"
	blood_overlay_type = "armor"

/obj/item/clothing/suit/armor/swat
	name = "SWAT armor"
	desc = "Tactical SWAT armor."
	icon_state = "heavy"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 50,RAD = 10, FIRE = INFINITY, ACID = INFINITY)
	strip_delay = 12 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/armor/laserproof
	name = "ablative armor vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles. Projects an energy field around the user, allowing a chance of energy projectile deflection no matter where on the user it would hit."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
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
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
	)
	icon_state = "detective-armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/tank/internals/emergency_oxygen,/obj/item/reagent_containers/spray/pepper,/obj/item/flashlight,/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/storage/fancy/cigarettes,/obj/item/lighter,/obj/item/detective_scanner,/obj/item/taperecorder)
	resistance_flags = FLAMMABLE
	dog_fashion = null

//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "reactive armor"
	desc = "Doesn't seem to do much for some reason."
	var/active = FALSE
	/// Is the armor disabled, and prevented from reactivating temporarly?
	var/disabled = FALSE
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = INFINITY, ACID = INFINITY)
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hit_reaction_chance = 50
	/// The cell reactive armor uses.
	var/obj/item/stock_parts/cell/emproof/reactive/cell
	/// Cost multiplier for armor. "Stronger" armors use 200 charge, other armors use 120.
	var/energy_cost = 120
	/// Is the armor in the one second grace period, to prevent rubbershot / buckshot from draining significant cell useage.
	var/in_grace_period = FALSE


/obj/item/clothing/suit/armor/reactive/Initialize(mapload, ...)
	. = ..()
	cell = new(src)
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(alert_admins_on_destroy))

/obj/item/clothing/suit/armor/reactive/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/clothing/suit/armor/reactive/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>The armor is [round(cell.percent())]% charged.</span>"

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user)
	active = !(active)
	if(disabled)
		to_chat(user, "<span class='warning'>[src] is disabled and rebooting!</span>")
		return
	if(active)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
		icon_state = "reactive"
		item_state = "reactive"
	else
		to_chat(user, "<span class='notice'>[src] is now inactive.</span>")
		icon_state = "reactiveoff"
		item_state = "reactiveoff"
		add_fingerprint(user)
	user.update_inv_wear_suit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

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
	item_state = "reactiveoff"
	addtimer(CALLBACK(src, PROC_REF(reboot)), disable_time SECONDS)
	if(ishuman(loc))
		var/mob/living/carbon/human/C = loc
		C.update_inv_wear_suit()

/obj/item/clothing/suit/armor/reactive/proc/reboot()
	disabled = FALSE
	active = TRUE
	icon_state = "reactive"
	item_state = "reactive"
	if(ishuman(loc))
		var/mob/living/carbon/human/C = loc
		C.update_inv_wear_suit()

/obj/item/clothing/suit/armor/reactive/proc/reaction_check(hitby)
	if(prob(hit_reaction_chance))
		if(istype(hitby, /obj/item/projectile))
			var/obj/item/projectile/P = hitby
			if(istype(P, /obj/item/projectile/ion))
				return FALSE
			if(!P.nodamage || P.stun || P.weaken)
				return TRUE
		else
			return TRUE

//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "reactive teleport armor"
	desc = "Someone separated our Research Director from his own head!"
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
	desc = "This armor uses the power of a pyro anomaly core to shoot protective jets of fire, in addition to absorbing all damage from fire."
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/armor/reactive/fire/equipped(mob/user, slot)
	..()
	if(slot != SLOT_HUD_OUTER_SUIT)
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
	desc = "This armor harnesses a cryogenic anomaly core to defend its user from the cold and attacks alike. Its unstable thermal regulation system occasionally vents gasses."

/obj/item/clothing/suit/armor/reactive/cryo/equipped(mob/user, slot)
	..()
	if(slot != SLOT_HUD_OUTER_SUIT)
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
	desc = "This armor uses an anomaly core combined with holographic projectors to make the user invisible temporarly, and make a fake image of the user."
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
	desc = "This armor uses the power of a flux anomaly core to protect the user in shocking ways."

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
			playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)
			add_attack_logs(owner, M, "[M] was shocked by [owner]'s [src]", ATKLOG_ALMOSTALL)
		disable(rand(2, 5)) // let's not have buckshot set it off 4 times and do 80 burn damage.
		return TRUE

/obj/item/clothing/suit/armor/reactive/repulse
	name = "reactive repulse armor"
	desc = "An experimental suit of armor that violently throws back attackers with the power of a gravitational anomaly core."
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

		for(var/am in thrown_atoms)
			var/atom/movable/AM = am
			if(AM == owner || AM.anchored)
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

/obj/item/clothing/suit/armor/reactive/random //Spawner for random reactive armor
	name = "Random Reactive Armor"

/obj/item/clothing/suit/armor/reactive/random/Initialize(mapload)
	. = ..()
	var/spawnpath = pick(subtypesof(/obj/item/clothing/suit/armor/reactive) - /obj/item/clothing/suit/armor/reactive/random)
	new spawnpath(loc)
	UnregisterSignal(src, COMSIG_PARENT_QDELETING)
	return INITIALIZE_HINT_QDEL

//All of the armor below is mostly unused


/obj/item/clothing/suit/armor/centcomm
	name = "Cent. Com. armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/gun/energy,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/tank/internals/emergency_oxygen)
	flags = THICKMATERIAL
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	sprite_sheets = null
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = 450, ACID = 450)

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = 450, ACID = 450)
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.90
	flags = THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hide_tail_by_species = list("Vox")

/obj/item/clothing/suit/armor/tdome
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = 450, ACID = 450)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	flags = THICKMATERIAL
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	hide_tail_by_species = list("Vox")

/obj/item/clothing/suit/armor/tdome/red
	name = "red Thunderdome armor"
	desc = "Armor worn by the red Thunderdome team."
	icon_state = "tdred"
	item_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "green Thunderdome armor"
	desc = "Armor worn by the green Thunderdome team."
	icon_state = "tdgreen"
	item_state = "tdgreen"

//Non-hardsuit ERT armor.
/obj/item/clothing/suit/armor/vest/ert
	name = "emergency response team armor"
	desc = "A set of armor worn by members of the Nanotrasen Emergency Response Team."
	icon_state = "ertarmor_cmd"
	item_state = "armor"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 10, RAD = 0, FIRE = 50, ACID = 50)

//Commander
/obj/item/clothing/suit/armor/vest/ert/command
	name = "emergency response team commander armor"
	desc = "A set of armor worn by the commander of a Nanotrasen Emergency Response Team. Has blue highlights."

//Security
/obj/item/clothing/suit/armor/vest/ert/security
	name = "emergency response team security armor"
	desc = "A set of armor worn by security members of the Nanotrasen Emergency Response Team. Has red highlights."
	icon_state = "ertarmor_sec"


/obj/item/clothing/suit/armor/vest/ert/security/paranormal
	name = "emergency response team paranormal armor"
	desc = "A set of armor worn by paranormal members of the Nanotrasen Emergency Response Team. Has crusader sigils."
	icon_state = "knight_templar"
	item_state = "knight_templar"

//Engineer
/obj/item/clothing/suit/armor/vest/ert/engineer
	name = "emergency response team engineer armor"
	desc = "A set of armor worn by engineering members of the Nanotrasen Emergency Response Team. Has orange highlights."
	icon_state = "ertarmor_eng"

//Medical
/obj/item/clothing/suit/armor/vest/ert/medical
	name = "emergency response team medical armor"
	desc = "A set of armor worn by medical members of the Nanotrasen Emergency Response Team. Has red and white highlights."
	icon_state = "ertarmor_med"

//Janitorial
/obj/item/clothing/suit/armor/vest/ert/janitor
	name = "emergency response team janitor armor"
	desc = "A set of armor worn by janitorial members of the Nanotrasen Emergency Response Team. Has red and white highlights."
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
	icon_state = "dragon"
	item_state = "dragon"
	desc = "A suit of armour fashioned from the remains of an ash drake."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/spear)
	armor = list(MELEE = 115, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 150, RAD = 25, FIRE = INFINITY, ACID = INFINITY)
	hoodtype = /obj/item/clothing/head/hooded/drake
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/hooded/drake
	name = "drake helmet"
	icon_state = "dragon"
	item_state = "dragon"
	desc = "The skull of a dragon."
	armor = list(MELEE = 115, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 150, RAD = 25, FIRE = INFINITY, ACID = INFINITY)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/suit/hooded/goliath
	name = "goliath cloak"
	icon_state = "goliath_cloak"
	item_state = "goliath_cloak"
	desc = "A staunch, practical cape made out of numerous monster materials, it is coveted amongst exiles & hermits."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/spear, /obj/item/organ/internal/regenerative_core/legion, /obj/item/kitchen/knife/combat/survival)
	armor = list(MELEE = 25, BULLET = 5, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 75, ACID = 75) //a fair alternative to bone armor, requiring alternative materials and gaining a suit slot
	hoodtype = /obj/item/clothing/head/hooded/goliath
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/head/hooded/goliath
	name = "goliath cloak hood"
	icon_state = "golhood"
	item_state = "golhood"
	desc = "A protective & concealing hood."
	armor = list(MELEE = 25, BULLET = 5, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 75, ACID = 75)
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/suit/armor/bone
	name = "bone armor"
	desc = "A tribal armor plate, crafted from animal bone."
	icon_state = "bonearmor"
	item_state = "bonearmor"
	blood_overlay_type = "armor"
	armor = list(MELEE = 25, BULLET = 15, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
