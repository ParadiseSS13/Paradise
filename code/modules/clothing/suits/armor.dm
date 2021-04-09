/obj/item/clothing/suit/armor
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/melee/classic_baton/telescopic,/obj/item/kitchen/knife)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 40
	max_integrity = 250
	resistance_flags = NONE
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/armor/vest
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back
	hispania_icon = TRUE
	sprite_sheets = list(
		"Vox" = 'icons/hispania/mob/species/vox/suit.dmi',
		"Grey" = 'icons/hispania/mob/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/armor/vest/jacket
	name = "military jacket"
	desc = "An old military jacket, it has armoring."
	icon_state = "militaryjacket"
	item_state = "militaryjacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	hispania_icon = FALSE
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/armor/vest/combat
	name = "combat vest"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor-combat"
	item_state = "bulletproof"
	blood_overlay_type = "armor"
	hispania_icon = FALSE
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	desc = "An armored vest that protects against some damage. This one has a clip for a holobadge."
	sprite_sheets = list(
		"Grey" = 'icons/mob/species/grey/suit.dmi'
	)
	icon_state = "armor"
	item_state = "armor"
	var/obj/item/clothing/accessory/holobadge/attached_badge
	hispania_icon = TRUE

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
	name = "blueshield's security armor"
	desc = "An armored vest with the badge of a Blueshield Lieutenant."
	icon_state = "blueshield"
	item_state = "blueshield"
	hispania_icon = FALSE
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/armor/vest/bloody
	name = "bloodied security armor"
	desc = "A vest drenched in the blood of Greytide. It has seen better days."
	icon_state = "bloody_armor"
	item_state = "bloody_armor"
	sprite_sheets = null
	hispania_icon = FALSE
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/armor/secjacket
	name = "security jacket"
	desc = "A sturdy black jacket with reinforced fabric. Bears insignia of NT corporate security."
	icon_state = "secjacket_open"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 15, bullet = 10, laser = 15, energy = 5, bomb = 15, bio = 0, rad = 0, fire = 30, acid = 30)
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
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	strip_delay = 80

/obj/item/clothing/suit/armor/hos/alt
	name = "armored trenchoat"
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
	hispania_icon = FALSE
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/armor/vest/warden/alt
	name = "warden's jacket"
	desc = "A navy-blue armored jacket with blue shoulder designations and '/Warden/' stitched into one of the chest pockets."
	icon_state = "warden_jacket_alt"
	hispania_icon = TRUE

/obj/item/clothing/suit/armor/vest/capcarapace
	name = "captain's carapace"
	desc = "An armored vest reinforced with ceramic plates and pauldrons to provide additional protection whilst still offering maximum mobility and flexibility. Issued only to the station's finest, although it does chafe your nipples."
	icon_state = "capcarapace"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 90)
	dog_fashion = null
	resistance_flags = FIRE_PROOF
	hispania_icon = FALSE
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/armor/vest/capcarapace/alt
	name = "captain's parade jacket"
	desc = "For when an armored vest isn't fashionable enough."
	icon_state = "capformal"
	item_state = "capspacesuit"

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "riot"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 50, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	flags_inv = HIDEJUMPSUIT
	strip_delay = 80
	put_on_delay = 60
	hide_tail_by_species = list("Vox")
	hispania_icon = TRUE

/obj/item/clothing/suit/armor/riot/knight
	name = "plate armour"
	desc = "A classic suit of plate armour, highly effective at stopping melee attacks."
	icon_state = "knight_green"
	item_state = "knight_green"
	slowdown = 1
	hispania_icon = FALSE

/obj/item/clothing/suit/armor/riot/knight/yellow
	icon_state = "knight_yellow"
	item_state = "knight_yellow"
	hispania_icon = FALSE

/obj/item/clothing/suit/armor/riot/knight/blue
	icon_state = "knight_blue"
	item_state = "knight_blue"
	hispania_icon = FALSE

/obj/item/clothing/suit/armor/riot/knight/red
	icon_state = "knight_red"
	item_state = "knight_red"
	hispania_icon = FALSE

/obj/item/clothing/suit/armor/riot/knight/templar
	name = "crusader armour"
	desc = "God wills it!"
	icon_state = "knight_templar"
	item_state = "knight_templar"
	allowed = list(/obj/item/nullrod/claymore)
	armor = list(melee = 25, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 80)
	hispania_icon = FALSE

/obj/item/clothing/suit/armor/vest/durathread
	name = "durathread vest"
	desc = "A vest made of durathread with strips of leather acting as trauma plates."
	hispania_icon = TRUE
	icon_state = "durathread_vest"
	item_state = "durathread_vest"
	strip_delay = 60
	max_integrity = 200
	resistance_flags = FLAMMABLE
	armor = list("melee" = 20, "bullet" = 10, "laser" = 30, "energy" = 5, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof vest"
	desc = "A bulletproof vest that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "bulletproof"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list("melee" = 15, "bullet" = 60, "laser" = 10, "energy" = 10, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	strip_delay = 70
	put_on_delay = 50

/obj/item/clothing/suit/armor/laserproof
	name = "ablative armor vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles. Projects an energy field around the user, allowing a chance of energy projectile deflection no matter where on the user it would hit."
	icon = 'icons/hispania/mob/suit.dmi'
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	var/hit_reflect_chance = 50
	hispania_icon = TRUE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 60, "energy" = 60, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/armor/laserproof/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return FALSE
	if(prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/suit/armor/vest/det_suit
	name = "armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/tank/internals/emergency_oxygen,/obj/item/reagent_containers/spray/pepper,/obj/item/flashlight,/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/storage/fancy/cigarettes,/obj/item/lighter,/obj/item/detective_scanner,/obj/item/taperecorder)
	resistance_flags = FLAMMABLE
	dog_fashion = null
	hispania_icon = FALSE
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

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
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hit_reaction_chance = 50

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
	disable(emp_power)
	..()

/obj/item/clothing/suit/armor/reactive/proc/disable(disable_time = 0)
	active = FALSE
	disabled = TRUE
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/C = loc
		C.update_inv_wear_suit()
		addtimer(CALLBACK(src, .proc/reboot), disable_time SECONDS)

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
			if(!P.nodamage)
				return TRUE
		else
			return TRUE

//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "reactive teleport armor"
	desc = "An experimental suit of armor that will teleport the user a short distance on detection of imminent harm."
	var/tele_range = 6

/obj/item/clothing/suit/armor/reactive/teleport/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return 0
	if(reaction_check(hitby))
		var/mob/living/carbon/human/H = owner
		owner.visible_message("<span class='danger'>The reactive teleport system flings [H] clear of [attack_text]!</span>")
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
		H.forceMove(picked)
		return TRUE
	return FALSE

/obj/item/clothing/suit/armor/reactive/fire
	name = "reactive incendiary armor"
	desc = "This armor uses the power of a pyro anomaly core to shoot protective jets of fire."

/obj/item/clothing/suit/armor/reactive/fire/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(reaction_check(hitby))
		owner.visible_message("<span class='danger'>The [src] blocks the [attack_text], sending out jets of flame!</span>")
		for(var/mob/living/carbon/C in range(6, owner))
			if(C != owner)
				C.fire_stacks += 8
				C.IgniteMob()
		owner.fire_stacks = -20
		return TRUE
	return FALSE


/obj/item/clothing/suit/armor/reactive/stealth
	name = "reactive stealth armor"
	desc = "This armor uses an anomaly core combined with holographic projectors to make the user invisible temporarly, and make a fake image of the user."

/obj/item/clothing/suit/armor/reactive/stealth/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(reaction_check(hitby))
		var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
		E.Copy_Parent(owner, 50)
		E.GiveTarget(owner) //so it starts running right away
		E.Goto(owner, E.move_to_delay, E.minimum_distance)
		owner.alpha = 0
		owner.visible_message("<span class='danger'>[owner] is hit by [attack_text] in the chest!</span>") //We pretend to be hit, since blocking it would stop the message otherwise
		spawn(40)
			owner.alpha = initial(owner.alpha)
		return TRUE

/obj/item/clothing/suit/armor/reactive/tesla
	name = "reactive tesla armor"
	desc = "This armor uses the power of a flux anomaly core to protect the user in shocking ways."

/obj/item/clothing/suit/armor/reactive/tesla/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(reaction_check(hitby))
		owner.visible_message("<span class='danger'>The [src] blocks the [attack_text], sending out arcs of lightning!</span>")
		for(var/mob/living/M in view(6, owner))
			if(M == owner)
				continue
			owner.Beam(M,icon_state="lightning[rand(1, 12)]",icon='icons/effects/effects.dmi',time=5)
			M.adjustFireLoss(20)
			playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)
		disable(rand(2, 5)) // let's not have buckshot set it off 4 times and do 80 burn damage.
		return TRUE

/obj/item/clothing/suit/armor/reactive/repulse
	name = "reactive repulse armor"
	desc = "An experimental suit of armor that violently throws back attackers with the power of a gravitational anomaly core."
	///How strong the reactive armor is for throwing
	var/repulse_power = 3
	/// How far away are we finding things to throw
	var/repulse_range = 5

/obj/item/clothing/suit/armor/reactive/repulse/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(reaction_check(hitby))
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], converting the attack into a wave of force!</span>")
		var/list/thrownatoms = list()
		for(var/turf/T in range(repulse_range, owner)) //Done this way so things don't get thrown all around hilariously.
			for(var/atom/movable/AM in T)
				thrownatoms += AM

		for(var/am in thrownatoms)
			var/atom/movable/AM = am
			if(AM == owner || AM.anchored)
				continue

			var/throwtarget = get_edge_target_turf(owner, get_dir(owner, get_step_away(AM, owner)))
			var/distfromuser = get_dist(owner, AM)
			if(distfromuser == 0)
				if(isliving(AM))
					var/mob/living/M = AM
					M.Weaken(3)
					to_chat(M, "<span class='userdanger'>You're slammed into the floor by [owner]'s reactive armor!</span>")
			else
				if(isliving(AM))
					var/mob/living/M = AM
					to_chat(M, "<span class='userdanger'>You're thrown back by the [owner]'s reactive armor!</span>")
				spawn(0)
					AM.throw_at(throwtarget, ((clamp((repulse_power - (clamp(distfromuser - 2, 0, distfromuser))), 3, repulse_power))), 1)//So stuff gets tossed around at the same time.
		disable(rand(2, 5))
		return TRUE

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
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90)

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90)
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.90
	flags = THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hide_tail_by_species = list("Vox")

/obj/item/clothing/suit/armor/tdome
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90)
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
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 20, bio = 0, rad = 0, fire = 50, acid = 50)
	hispania_icon = FALSE
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

//Commander
/obj/item/clothing/suit/armor/vest/ert/command
	name = "emergency response team commander armor"
	desc = "A set of armor worn by the commander of a Nanotrasen Emergency Response Team. Has blue highlights."
	sprite_sheets = list()

//Security
/obj/item/clothing/suit/armor/vest/ert/security
	name = "emergency response team security armor"
	desc = "A set of armor worn by security members of the Nanotrasen Emergency Response Team. Has red highlights."
	icon_state = "ertarmor_sec"
	sprite_sheets = list()

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
/obj/item/clothing/suit/storage/lawyer/blackjacket/armored
	desc = "A snappy dress jacket, reinforced with a layer of armor protecting the torso."
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/gun/projectile/revolver, /obj/item/gun/projectile/automatic/pistol)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor = list(melee = 25, bullet = 15, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0, fire = 40, acid = 40)

//LAVALAND!

/obj/item/clothing/suit/hooded/drake
	name = "drake armour"
	icon_state = "dragon"
	item_state = "dragon"
	desc = "A suit of armour fashioned from the remains of an ash drake."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/spear)
	armor = list("melee" = 70, "bullet" = 30, "laser" = 50, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100)
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
	armor = list("melee" = 70, "bullet" = 30, "laser" = 50, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100)
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
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/twohanded/spear, /obj/item/organ/internal/regenerative_core/legion, /obj/item/kitchen/knife/combat/survival)
	armor = list("melee" = 35, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60) //a fair alternative to bone armor, requiring alternative materials and gaining a suit slot
	hoodtype = /obj/item/clothing/head/hooded/goliath
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/head/hooded/goliath
	name = "goliath cloak hood"
	icon_state = "golhood"
	item_state = "golhood"
	desc = "A protective & concealing hood."
	armor = list("melee" = 35, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/suit/armor/bone
	name = "bone armor"
	desc = "A tribal armor plate, crafted from animal bone."
	icon_state = "bonearmor"
	item_state = "bonearmor"
	blood_overlay_type = "armor"
	armor = list("melee" = 35, "bullet" = 25, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
