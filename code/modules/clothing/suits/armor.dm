/obj/item/clothing/suit/armor
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs,/obj/item/device/flashlight/seclite,/obj/item/weapon/melee/classic_baton/telescopic,/obj/item/weapon/kitchen/knife/combat)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 40
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/armor/vest
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	flags_size = ONESIZEFITSALL
	armor = list(melee = 25, bullet = 15, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0)

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
	flags_size = ONESIZEFITSALL

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	desc = "An armored vest that protects against some damage. This one has a clip for a holobadge."
	icon_state = "armor"
	item_state = "armor"
	var/obj/item/clothing/accessory/holobadge/attached_badge

/obj/item/clothing/suit/armor/vest/security/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/clothing/accessory/holobadge))
		if(user.unEquip(W))
			add_fingerprint(user)
			W.forceMove(src)
			attached_badge = W

			var/datum/action/A = new /datum/action/item_action/remove_badge(src)
			A.Grant(user)
			icon_state = "armorsec"
			user.update_inv_wear_suit()
			desc = "An armored vest that protects against some damage. This one has [attached_badge] attached to it."
			to_chat(user, "<span class='notice'>You attach [attached_badge] to [src].</span>")
		return
	..()

/obj/item/clothing/suit/armor/vest/security/attack_self(mob/user as mob)
	if(attached_badge)
		add_fingerprint(user)
		user.put_in_hands(attached_badge)

		for(var/X in actions)
			var/datum/action/A = X
			A.Remove(user)

		icon_state = "armor"
		user.update_inv_wear_suit()
		desc = "An armored vest that protects against some damage. This one has a clip for a holobadge."
		to_chat(user, "<span class='notice'>You remove [attached_badge] from [src].</span>")

		attached_badge = null

		return

	..()

/obj/item/clothing/suit/armor/vest/blueshield
	name = "blueshield security armor"
	desc = "An armored vest with the badge of a Blueshield Lieutenant."
	icon_state = "blueshield"
	item_state = "blueshield"

/obj/item/clothing/suit/armor/vest/bloody
	name = "bloodied security armor"
	desc = "A vest drenched in the blood of Greytide. It has seen better days."
	icon_state = "bloody_armor"
	item_state = "bloody_armor"
	species_fit = null
	sprite_sheets = null

/obj/item/clothing/suit/armor/secjacket
	name = "security jacket"
	desc = "A sturdy black jacket with reinforced fabric. Bears insignia of NT corporate security."
	icon_state = "secjacket_open"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 15, bullet = 10, laser = 15, energy = 5, bomb = 15, bio = 0, rad = 0)
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/openclose)
	adjust_flavour = "unzip"

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A trench coat enhanced with a special alloy for some protection and style."
	icon_state = "hos"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	strip_delay = 80

/obj/item/clothing/suit/armor/hos/alt
	name = "armored trenchoat"
	desc = "A trenchcoat enchanced with a special lightweight kevlar. The epitome of tactical plainclothes."
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
	species_fit = null
	sprite_sheets = null

/obj/item/clothing/suit/armor/vest/warden
	name = "Warden's armored jacket"
	desc = "An armoured jacket with silver rank pips and livery."
	icon_state = "warden_jacket"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|HANDS
	strip_delay = 70

/obj/item/clothing/suit/armor/vest/warden/alt
	name = "warden's jacket"
	desc = "A navy-blue armored jacket with blue shoulder designations and '/Warden/' stitched into one of the chest pockets."
	icon_state = "warden_jacket_alt"

/obj/item/clothing/suit/armor/vest/capcarapace
	name = "captain's carapace"
	desc = "An armored vest reinforced with ceramic plates and pauldrons to provide additional protection whilst still offering maximum mobility and flexibility. Issued only to the station's finest, although it does chafe your nipples."
	icon_state = "capcarapace"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 50, bullet = 40, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/riot
	name = "Riot Suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 50, bullet = 10, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	strip_delay = 80
	put_on_delay = 60
	hide_tail_by_species = list("Vox")

/obj/item/clothing/suit/armor/riot/knight
	name = "plate armour"
	desc = "A classic suit of plate armour, highly effective at stopping melee attacks."
	icon_state = "knight_green"
	item_state = "knight_green"
	slowdown = 1

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
	allowed = list(/obj/item/weapon/nullrod/claymore)

/obj/item/clothing/suit/armor/bulletproof
	name = "Bulletproof Vest"
	desc = "A bulletproof vest that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "bulletproof"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 15, bullet = 80, laser = 10, energy = 10, bomb = 40, bio = 0, rad = 0)
	strip_delay = 70
	put_on_delay = 50

/obj/item/clothing/suit/armor/laserproof
	name = "Ablative Armor Vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	armor = list(melee = 10, bullet = 10, laser = 60, energy = 50, bomb = 0, bio = 0, rad = 0)
	var/hit_reflect_chance = 40

/obj/item/clothing/suit/armor/laserproof/IsReflect(var/def_zone)
	if(!(def_zone in list("chest", "groin"))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return 0
	if(prob(hit_reflect_chance))
		return 1

/obj/item/clothing/suit/armor/vest/det_suit
	name = "armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	flags_size = ONESIZEFITSALL
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/device/flashlight,/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)


//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "reactive armor"
	desc = "Doesn't seem to do much for some reason."
	var/active = 0
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	actions_types = list(/datum/action/item_action/toggle)
	unacidable = 1
	hit_reaction_chance = 50

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user)
	active = !(active)
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
	active = 0
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/C = loc
		C.update_inv_wear_suit()
	..()

//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "reactive teleport armor"
	desc = "Someone seperated our Research Director from his own head!"
	var/tele_range = 6

/obj/item/clothing/suit/armor/reactive/teleport/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		var/mob/living/carbon/human/H = owner
		owner.visible_message("<span class='danger'>The reactive teleport system flings [H] clear of [attack_text], shutting itself off in the process!</span>")
		var/list/turfs = new/list()
		for(var/turf/T in orange(tele_range, H))
			if(istype(T, /turf/space))
				continue
			if(T.density)
				continue
			if(T.x>world.maxx-tele_range || T.x<tele_range)
				continue
			if(T.y>world.maxy-tele_range || T.y<tele_range)
				continue
			turfs += T
		if(!turfs.len)
			turfs += pick(/turf in orange(tele_range, H))
		var/turf/picked = pick(turfs)
		if(!isturf(picked))
			return
		if(H.buckled)
			H.buckled.unbuckle_mob()
		H.forceMove(picked)
		return 1
	return 0

/obj/item/clothing/suit/armor/reactive/fire
	name = "reactive incendiary armor"

/obj/item/clothing/suit/armor/reactive/fire/hit_reaction(mob/living/carbon/human/owner, attack_text)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		owner.visible_message("<span class='danger'>The [src] blocks the [attack_text], sending out jets of flame!</span>")
		for(var/mob/living/carbon/C in range(6, owner))
			if(C != owner)
				C.fire_stacks += 8
				C.IgniteMob()
		owner.fire_stacks = -20
		return 1
	return 0


/obj/item/clothing/suit/armor/reactive/stealth
	name = "reactive stealth armor"

/obj/item/clothing/suit/armor/reactive/stealth/hit_reaction(mob/living/carbon/human/owner, attack_text)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
		E.Copy_Parent(owner, 50)
		E.GiveTarget(owner) //so it starts running right away
		E.Goto(owner, E.move_to_delay, E.minimum_distance)
		owner.alpha = 0
		owner.visible_message("<span class='danger'>[owner] is hit by [attack_text] in the chest!</span>") //We pretend to be hit, since blocking it would stop the message otherwise
		spawn(40)
			owner.alpha = initial(owner.alpha)
		return 1

/obj/item/clothing/suit/armor/reactive/tesla
	name = "reactive tesla armor"

/obj/item/clothing/suit/armor/reactive/tesla/hit_reaction(mob/living/carbon/human/owner, attack_text)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		owner.visible_message("<span class='danger'>The [src] blocks the [attack_text], sending out arcs of lightning!</span>")
		for(var/mob/living/M in view(6, owner))
			if(M == owner)
				continue
			owner.Beam(M,icon_state="lightning[rand(1, 12)]",icon='icons/effects/effects.dmi',time=5)
			M.adjustFireLoss(25)
			playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)
		return 1

//All of the armor below is mostly unused


/obj/item/clothing/suit/armor/centcomm
	name = "Cent. Com. armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = 4//bulky item
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	flags = THICKMATERIAL
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	species_fit = null
	sprite_sheets = null
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100)

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100)
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	flags = THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hide_tail_by_species = list("Vox")

/obj/item/clothing/suit/armor/tdome
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	flags = THICKMATERIAL
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	hide_tail_by_species = list("Vox")

/obj/item/clothing/suit/armor/tdome/red
	name = "Red Thunderdome Armor"
	desc = "Armor worn by the red Thunderodome team"
	icon_state = "tdred"
	item_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "Green Thunderdome Armor"
	desc = "Armor worn by the green Thunderodome team"
	icon_state = "tdgreen"
	item_state = "tdgreen"

//Non-hardsuit ERT armor.
/obj/item/clothing/suit/armor/vest/ert
	name = "emergency response team armor"
	desc = "A set of armor worn by members of the Nanotrasen Emergency Response Team."
	icon_state = "ertarmor_cmd"
	item_state = "armor"
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 20, bio = 0, rad = 0)

//Commander
/obj/item/clothing/suit/armor/vest/ert/command
	name = "emergency response team commander armor"
	desc = "A set of armor worn by the commander of a Nanotrasen Emergency Response Team. Has blue highlights."

//Security
/obj/item/clothing/suit/armor/vest/ert/security
	name = "emergency response team security armor"
	desc = "A set of armor worn by security members of the Nanotrasen Emergency Response Team. Has red highlights."
	icon_state = "ertarmor_sec"

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
