/obj/item/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon_state = "tome"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tome/New()
	if(SSticker.mode)
		icon_state = SSticker.cultdat.tome_icon
	..()

/obj/item/melee/cultblade
	name = "cult blade"
	desc = "An arcane weapon wielded by the followers of a cult."
	icon = 'icons/obj/cult.dmi'
	icon_state = "blood_blade"
	item_state = "blood_blade"
	w_class = WEIGHT_CLASS_BULKY
	force = 30
	throwforce = 10
	sharp = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sprite_sheets_inhand = list("Skrell" = 'icons/mob/species/skrell/held.dmi') // To stop skrell stabbing themselves in the head

/obj/item/melee/cultblade/New()
	if(SSticker.mode)
		icon_state = SSticker.cultdat.sword_icon
		item_state = SSticker.cultdat.sword_icon
	..()

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!iscultist(user))
		user.Weaken(5)
		user.unEquip(src, 1)
		user.visible_message("<span class='warning'>A powerful force shoves [user] away from [target]!</span>",
							 "<span class='cultlarge'>\"You shouldn't play with sharp things. You'll poke someone's eye out.\"</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick("l_arm", "r_arm"))
		else
			user.adjustBruteLoss(rand(force/2, force))
		return
	..()

/obj/item/melee/cultblade/pickup(mob/living/user)
	. = ..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
		to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
		user.Confused(10)
		user.Jitter(6)

	if(HULK in user.mutations)
		to_chat(user, "<span class='danger'>You can't seem to hold the blade properly!</span>")
		return FALSE

/obj/item/restraints/legcuffs/bola/cult
	name = "runed bola"
	desc = "A strong bola, bound with dark magic. Throw it to trip and slow your victim. Will not hit fellow cultists."
	icon = 'icons/obj/items.dmi'
	icon_state = "bola_cult"
	breakouttime = 45
	weaken = 1

/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscultist(hit_atom))
		hit_atom.visible_message("<span class='warning'>[src] bounces off of [hit_atom], as if repelled by an unseen force!</span>")
		return
	. = ..()

/obj/item/clothing/head/hooded/culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "A hood worn by the followers of a cult."
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	magical = TRUE

/obj/item/clothing/head/hooded/culthood/alt
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"


/obj/item/clothing/suit/hooded/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of a cult."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/culthood
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT
	magical = TRUE

/obj/item/clothing/suit/hooded/cultrobes/alt
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"
	hoodtype = /obj/item/clothing/head/hooded/culthood/alt

/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of a cult."
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list("melee" = 70, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 75)
	magical = TRUE

/obj/item/clothing/suit/space/cult
	name = "cult armor"
	icon_state = "cult_armour"
	item_state = "cult_armour"
	desc = "A bulky suit of armor, bristling with spikes. It looks space proof."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade, /obj/item/tank)
	slowdown = 1
	armor = list("melee" = 70, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 75)
	magical = TRUE

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist robes"
	desc = "An empowered garb which creates a powerful shield around the user."
	icon_state = "cult_armour"
	item_state = "cult_armour"
	w_class = WEIGHT_CLASS_BULKY
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 50, "acid" = 60)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie
	var/current_charges = 3
	var/shield_state = "shield-cult"
	var/shield_on = "shield-cult"

/obj/item/clothing/head/hooded/cult_hoodie
	name = "empowered cultist hood"
	desc = "An empowered garb which creates a powerful shield around the user."
	icon_state = "cult_hoodalt"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40,"energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	body_parts_covered = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	magical = TRUE

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user)) // Todo: Make this only happen when actually equipped to the correct slot. (For all cult items)
		to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
		to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
		user.unEquip(src, 1)
		user.Confused(10)
		user.Weaken(5)

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(current_charges)
		owner.visible_message("<span class='danger'>[attack_text] is deflected in a burst of blood-red sparks!</span>")
		current_charges--
		playsound(loc, "sparks", 100, TRUE)
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		if(!current_charges)
			owner.visible_message("<span class='danger'>The runed shield around [owner] suddenly disappears!</span>")
			shield_state = "broken"
			owner.update_inv_wear_suit()
		return TRUE
	return FALSE

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/special_overlays()
	return mutable_appearance('icons/effects/cult_effects.dmi', shield_state, MOB_LAYER + 0.01)

/obj/item/clothing/suit/hooded/cultrobes/flagellant_robe
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "flagellantrobe"
	item_state = "flagellantrobe"
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list("melee" = -50, "bullet" = -50, "laser" = -50,"energy" = -50, "bomb" = -50, "bio" = -50, "rad" = -50, "fire" = 0, "acid" = 0)
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Drask" = 'icons/mob/species/drask/suit.dmi',
		"Grey" = 'icons/mob/species/grey/suit.dmi'
		)
	hoodtype = /obj/item/clothing/head/hooded/flagellant_hood


/obj/item/clothing/suit/hooded/cultrobes/flagellant_robe/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
		to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
		user.unEquip(src, 1)
		user.Confused(10)
		user.Weaken(5)
	else if(slot == slot_wear_suit)
		user.status_flags |= GOTTAGOFAST

/obj/item/clothing/suit/hooded/cultrobes/flagellant_robe/dropped(mob/user)
	. = ..()
	if(user)
		user.status_flags &= ~GOTTAGOFAST

/obj/item/clothing/head/hooded/flagellant_hood
	name = "flagellant's robes"
	desc = "Blood-soaked garb infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "flagellanthood"
	item_state = "flagellanthood"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi',
		"Drask" = 'icons/mob/species/drask/head.dmi',
		"Grey" = 'icons/mob/species/grey/head.dmi'
		)

/obj/item/whetstone/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	icon_state = "cult_sharpener"
	increment = 5
	max = 40
	prefix = "darkened"
	claw_damage_increase = 4

/obj/item/whetstone/cult/update_icon()
	icon_state = "cult_sharpener[used ? "_used" : ""]"

/obj/item/whetstone/cult/attackby(obj/item/I, mob/user, params)
	..()
	if(used)
		to_chat(user, "<span class='notice'>[src] crumbles to ashes.</span>")
		qdel(src)

/obj/item/reagent_containers/food/drinks/bottle/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers; this water renews and reinvigorates the faithful of a cult."
	icon_state = "holyflask"
	color = "#333333"
	list_reagents = list("unholywater" = 40)

/obj/item/clothing/glasses/hud/health/night/cultblind
	name = "zealot's blindfold"
	desc = "May the master guide you through the darkness and shield you from the light."
	icon_state = "blindfold"
	item_state = "blindfold"
	see_in_dark = 8
	invis_override = SEE_INVISIBLE_HIDDEN_RUNES
	flash_protect = TRUE
	prescription = TRUE
	origin_tech = null

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/user, slot)
	..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"You want to be blind, do you?\"</span>")
		user.unEquip(src, 1)
		user.Confused(30)
		user.Weaken(5)
		user.EyeBlind(30)

/obj/item/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the escape shuttle."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shuttlecurse"
	var/global/curselimit = 0

/obj/item/shuttle_curse/attack_self(mob/user)
	if(!iscultist(user))
		user.unEquip(src, 1)
		user.Weaken(5)
		to_chat(user, "<span class='warning'>A powerful force shoves you away from [src]!</span>")
		return
	if(curselimit > 1)
		to_chat(user, "<span class='notice'>We have exhausted our ability to curse the shuttle.</span>")
		return
	if(locate(/obj/singularity/narsie) in GLOB.poi_list || locate(/mob/living/simple_animal/slaughter/cult) in GLOB.mob_list)
		to_chat(user, "<span class='danger'>Nar'Sie or her avatars are already on this plane, there is no delaying the end of all things.</span>")
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 3 MINUTES
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		SSshuttle.emergency.setTimer(timer)
		to_chat(user,"<span class='danger'>You shatter the orb! A dark essence spirals into the air, then disappears.</span>")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, TRUE)
		curselimit++
		var/message = pick(CULT_CURSES)
		GLOB.command_announcement.Announce("[message] The shuttle will be delayed by [cursetime / 600] minute\s.", "System Failure", 'sound/misc/notice1.ogg')
		qdel(src)

/obj/item/cult_shift
	name = "veil shifter"
	desc = "This relic teleports you forward by a medium distance."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shifter"
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += "<span class='cult'>It has [uses] use\s remaining.</span>"
	else
		. += "<span class='cult'>It seems drained.</span>"

/obj/item/cult_shift/proc/handle_teleport_grab(turf/T, mob/user)
	var/mob/living/carbon/C = user
	if(C.pulling)
		var/atom/movable/pulled = C.pulling
		pulled.forceMove(T)
		. = pulled

/obj/item/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user, "<span class='warning'>[src] is dull and unmoving in your hands.</span>")
		return
	if(!iscultist(user))
		user.unEquip(src, 1)
		step(src, pick(GLOB.alldirs))
		to_chat(user, "<span class='warning'>[src] flickers out of your hands, too eager to move!</span>")
		return

	var/outer_tele_radius = 9

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/list/turfs = new/list()
	for(var/turf/T in range(user, outer_tele_radius))
		if(!is_teleport_allowed(T.z))
			break
		if(get_dir(C, T) != C.dir)
			continue
		if(T == mobloc)
			continue
		if(istype(T, /turf/space))
			continue
		if(T.x > world.maxx-outer_tele_radius || T.x < outer_tele_radius)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy-outer_tele_radius || T.y < outer_tele_radius)
			continue

		turfs += T

	if(turfs)
		uses--
		var/turf/destination = pick(turfs)
		if(uses <= 0)
			icon_state ="shifter_drained"
		playsound(mobloc, "sparks", 50, TRUE)
		new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, C.dir)

		var/atom/movable/pulled = handle_teleport_grab(destination, C)
		C.forceMove(destination)
		if(pulled)
			C.start_pulling(pulled) //forcemove resets pulls, so we need to re-pull

		new /obj/effect/temp_visual/dir_setting/cult/phase(destination, C.dir)
		playsound(destination, 'sound/effects/phasein.ogg', 25, TRUE)
		playsound(destination, "sparks", 50, TRUE)

	else
		to_chat(C, "<span class='danger'>The veil cannot be torn here!</span>")

/obj/item/melee/cultblade/ghost
	name = "eldritch sword"
	force = 15
	flags = NODROP | DROPDEL

/obj/item/clothing/head/hooded/culthood/alt/ghost
	flags = NODROP | DROPDEL

/obj/item/clothing/suit/cultrobesghost
	name = "ghostly cult robes"
	desc = "A set of ethereal armored robes worn by the undead followers of a cult."
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50, energy = 20, bomb = 25, bio = 10, rad = 0, fire = 10, acid = 10)
	flags_inv = HIDEJUMPSUIT
	flags = NODROP | DROPDEL


/obj/item/clothing/shoes/cult/ghost
	flags = NODROP | DROPDEL

/obj/item/clothing/under/color/black/ghost
	flags = NODROP | DROPDEL

/datum/outfit/ghost_cultist
	name = "Cultist Ghost"

	uniform = /obj/item/clothing/under/color/black/ghost
	suit = /obj/item/clothing/suit/cultrobesghost
	shoes = /obj/item/clothing/shoes/cult/ghost
	head = /obj/item/clothing/head/hooded/culthood/alt/ghost
	r_hand = /obj/item/melee/cultblade/ghost

/obj/item/shield/mirror
	name = "mirror shield"
	desc = "An infamous shield used by eldritch sects to confuse and disorient their enemies."
	icon = 'icons/obj/cult.dmi'
	icon_state = "mirror_shield"
	item_state = "mirror_shield"
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 3
	attack_verb = list("bumped", "prodded")
	hitsound = 'sound/weapons/smash.ogg'
	/// Chance that energy projectiles will be reflected
	var/reflect_chance = 70
	/// The number of clone illusions remaining
	var/illusions = 2

	// Any damage higher than these values will have a chance to shatter the shield
	/// Shatter threshold for Ballistic weapons
	var/ballistic_threshold = 10
	/// Shatter threshold for Energy weapons
	var/energy_threshold = 20

/**
  * Reflect/Block/Shatter proc.
  *
  * Projectiles:
  * If you have been hit by a projectile, the 'threshold' will be set depending on the damage type.
  * By default, energy weapons have a 70% chance of being reflected, so you're going to want to use ballistics against mirror shields. (Reflection is calculated beforehand in [/mob/living/carbon/human/bullet_act])
  * For every point of damage above the threshold, the shield will have a 3% chance to shatter. (Up to a maximum of 75%)
  * If a ballistic projectile doesn't shatter the shield, it will move on to the melee section.
  *
  * Melee and blocked projectiles:
  * Melee attacks and bullets have a 50|50 chance of being blocked by the mirror shield. (Based on the 'block_chance' variable)
  * If they are blocked, and the shield has an illusion charge, an illusion will be spawned at src.
  * The illusion has a 60% chance to be hostile and attack non-cultists, and a 40% chance to just run away from the user.
  */
/obj/item/shield/mirror/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(iscultist(owner)) // Cultist holding the shield

		// Hit by a projectile
		if(istype(hitby, /obj/item/projectile))
			var/obj/item/projectile/P = hitby
			var/shatter_chance = 0 // Percent chance of the shield shattering on a projectile hit
			var/threshold // Depends on the damage Type (Brute or Burn)
			if(P.damage_type == BRUTE)
				threshold = ballistic_threshold
			else if(P.damage_type == BURN)
				threshold = energy_threshold
			else
				return FALSE
			// Assuming the projectile damage is 20 (WT-550), 'shatter_chance' will be 10
			// 10 * 3 gives it a 30% chance to shatter per hit.
			shatter_chance = min((P.damage - threshold) * 3, 75) // Maximum of 75% chance

			if(prob(shatter_chance))
				var/turf/T = get_turf(owner)
				T.visible_message("<span class='warning'>The sheer force from [P] shatters the mirror shield!</span>")
				new /obj/effect/temp_visual/cult/sparks(T)
				playsound(T, 'sound/effects/glassbr3.ogg', 100)
				owner.Weaken(3)
				qdel(src)
				return FALSE

			if(P.is_reflectable)
				return FALSE //To avoid reflection chance double-dipping with block chance

		// Hit by a melee weapon or blocked a projectile
		. = ..()
		if(.) // 50|50 chance
			playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
			if(illusions > 0)
				illusions--
				addtimer(CALLBACK(src, .proc/readd), 45 SECONDS)
				if(prob(60))
					spawn_illusion(owner, TRUE) // Hostile illusion
				else
					spawn_illusion(owner, FALSE) // Running illusion
			return TRUE

	else // Non-cultist holding the shield
		if(prob(50))
			spawn_illusion(owner, TRUE, TRUE)
		return FALSE

/obj/item/shield/mirror/proc/spawn_illusion(mob/living/carbon/human/user, hostile, betray)
	if(hostile)
		var/mob/living/simple_animal/hostile/illusion/cult/H = new(user.loc)
		H.faction = list("cult")
		if(!betray)
			H.Copy_Parent(user, 70, 10, 5)
		else
			H.Copy_Parent(user, 100, 20, 5)
			H.GiveTarget(user)
			to_chat(user, "<span class='danger'>[src] betrays you!</span>")
	else
		var/mob/living/simple_animal/hostile/illusion/escape/cult/E = new(user.loc)
		E.Copy_Parent(user, 70, 10)
		E.GiveTarget(user)
		E.Goto(user, E.move_to_delay, E.minimum_distance)

/obj/item/shield/mirror/proc/readd()
	if(illusions < initial(illusions))
		illusions++
	else if(isliving(loc))
		var/mob/living/holder = loc
		if(iscultist(holder))
			to_chat(holder, "<span class='cultitalic'>The shield's illusions are back at full strength!</span>")
		else
			to_chat(holder, "<span class='warning'>[src] vibrates slightly, and starts glowing.")

/obj/item/shield/mirror/IsReflect()
	if(prob(reflect_chance))
		return TRUE
	return FALSE

/obj/item/twohanded/cult_spear
	name = "blood halberd"
	desc = "A sickening spear composed entirely of crystallized blood."
	icon = 'icons/obj/cult.dmi'
	icon_state = "bloodspear0"
	slot_flags = 0
	force = 17
	force_unwielded = 17
	force_wielded = 24
	throwforce = 40
	throw_speed = 2
	armour_penetration = 30
	block_chance = 30
	attack_verb = list("attacked", "impaled", "stabbed", "torn", "gored")
	sharp = TRUE
	no_spin_thrown = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	needs_permit = TRUE
	var/datum/action/innate/cult/spear/spear_act

/obj/item/twohanded/cult_spear/Destroy()
	if(spear_act)
		qdel(spear_act)
	..()

/obj/item/twohanded/cult_spear/update_icon()
	icon_state = "bloodspear[wielded]"

/obj/item/twohanded/cult_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(iscultist(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(!L.restrained() && L.put_in_active_hand(src))
				L.visible_message("<span class='warning'>[L] catches [src] out of the air!</span>")
			else
				L.visible_message("<span class='warning'>[src] bounces off of [L], as if repelled by an unseen force!</span>")
		else if(!..())
			if(!L.null_rod_check())
				L.Weaken(3)
			break_spear(T)
	else
		..()

/obj/item/twohanded/cult_spear/proc/break_spear(turf/T)
	if(!T)
		T = get_turf(src)
	if(T)
		T.visible_message("<span class='warning'>[src] shatters and melts back into blood!</span>")
		new /obj/effect/temp_visual/cult/sparks(T)
		new /obj/effect/decal/cleanable/blood/splatter(T)
		playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/obj/item/twohanded/cult_spear/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		final_block_chance *= 2
	if(prob(final_block_chance))
		if(attack_type == PROJECTILE_ATTACK)
			owner.visible_message("<span class='danger'>[owner] deflects [attack_text] with [src]!</span>")
			playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, TRUE)
			return TRUE
		else
			playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
			owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
			return TRUE
	return FALSE

/datum/action/innate/cult/spear
	name = "Bloody Bond"
	desc = "Call the blood spear back to your hand!"
	background_icon_state = "bg_cult"
	button_icon_state = "bloodspear"
	var/obj/item/twohanded/cult_spear/spear
	var/cooldown = 0

/datum/action/innate/cult/spear/Grant(mob/user, obj/blood_spear)
	. = ..()
	spear = blood_spear

/datum/action/innate/cult/spear/Activate()
	if(owner == spear.loc || cooldown > world.time)
		return
	var/ST = get_turf(spear)
	var/OT = get_turf(owner)
	if(get_dist(OT, ST) > 10)
		to_chat(owner,"<span class='warning'>The spear is too far away!</span>")
	else
		cooldown = world.time + 20
		if(isliving(spear.loc))
			var/mob/living/L = spear.loc
			L.unEquip(spear)
			L.visible_message("<span class='warning'>An unseen force pulls the blood spear from [L]'s hands!</span>")
		spear.throw_at(owner, 10, 2, null)

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "Blood for blood."
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	color = "#ff0000"
	guns_left = 24
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'
	flags = NOBLUDGEON | DROPDEL

/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/blood

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/item/projectile/magic/arcane_barrage/blood
	muzzle_flash_effect = /obj/effect/temp_visual/emp/cult

/obj/item/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "blood_bolt"
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter
	hitsound = 'sound/effects/splat.ogg'

/obj/item/projectile/magic/arcane_barrage/blood/prehit(atom/target)
	if(iscultist(target))
		damage = 0
		nodamage = TRUE
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != DEAD)
				H.reagents.add_reagent("unholywater", 4)
		if(isshade(target) || isconstruct(target))
			var/mob/living/simple_animal/M = target
			if(M.health + 5 < M.maxHealth)
				M.adjustHealth(-5)
		new /obj/effect/temp_visual/cult/sparks(target)
	..()

/obj/item/blood_orb
	name = "orb of blood"
	icon = 'icons/obj/cult.dmi'
	icon_state = "summoning_orb"
	item_state = "summoning_orb"
	desc = "It's an orb of crystalized blood. Can be used to transfer blood between cultists."
	var/blood = 50

