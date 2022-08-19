//The chests dropped by mob spawner tendrils. Also contains associated loot.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	icon_opened = "necrocrate_open"
	icon_closed = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/populate_contents()
	var/loot = rand(1, 24)
	switch(loot)
		if(1)
			new /obj/item/shared_storage/red(src)
		if(2)
			new /obj/item/clothing/head/helmet/space/cult(src)
			new /obj/item/clothing/suit/space/cult(src)
		if(3)
			new /obj/item/soulstone/anybody(src)
		if(4)
			new /obj/item/katana/cursed(src)
		if(5)
			new /obj/item/clothing/glasses/godeye(src)
		if(6)
			new /obj/item/pickaxe/diamond(src)
		if(7)
			new /obj/item/clothing/suit/hooded/cultrobes(src)
			new /obj/item/bedsheet/cult(src)
		if(8)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disk/resonator_blast(src)
			else
				new /obj/item/disk/design_disk/modkit_disk/rapid_repeater(src)
		if(9)
			new /obj/item/rod_of_asclepius(src)
		if(10)
			new /obj/item/organ/internal/heart/cursed/wizard(src)
		if(11)
			new /obj/item/ship_in_a_bottle(src)
		if(12)
			new /obj/item/clothing/suit/hooded/berserker(src)
		if(13)
			new /obj/item/nullrod/scythe/talking(src)
		if(14)
			new /obj/item/nullrod/armblade/mining(src)
		if(15)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disk/mob_and_turf_aoe(src)
			else
				new /obj/item/disk/design_disk/modkit_disk/bounty(src)
		if(16)
			new /obj/item/warp_cube/red(src)
		if(17)
			new /obj/item/wisp_lantern(src)
		if(18)
			new /obj/item/immortality_talisman(src)
		if(19)
			new /obj/item/gun/magic/hook(src)
		if(20)
			new /obj/item/grenade/clusterbuster/inferno(src)
		if(21)
			new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
		if(22)
			new /obj/item/spellbook/oneuse/summonitem(src)
		if(23)
			new /obj/item/book_of_babel(src)
		if(24)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)

/obj/structure/closet/crate/necropolis/puzzle
	name = "puzzling chest"

/obj/structure/closet/crate/necropolis/puzzle/populate_contents()
	var/loot = rand(1,2)
	switch(loot)
		if(1)
			new /obj/item/soulstone/anybody(src)
		if(2)
			new /obj/item/wisp_lantern(src)

//KA modkit design discs
/obj/item/disk/design_disk/modkit_disk
	name = "\improper KA mod disk"
	desc = "A design disk containing the design for a unique kinetic accelerator modkit. It's compatible with a research console."
	icon_state = "datadisk1"
	var/modkit_design

/obj/item/disk/design_disk/modkit_disk/New()
	. = ..()
	if(modkit_design)
		blueprint = new modkit_design

/obj/item/disk/design_disk/modkit_disk/mob_and_turf_aoe
	name = "\improper KA mod disk (Offensive mining explosion)"
	modkit_design = /datum/design/offensive_turf_aoe_modkit

/obj/item/disk/design_disk/modkit_disk/rapid_repeater
	name = "\improper KA mod disk (Rapid repeater)"
	modkit_design = /datum/design/rapid_repeater_modkit

/obj/item/disk/design_disk/modkit_disk/resonator_blast
	name = "\improper KA mod disk (Resonator blast)"
	modkit_design = /datum/design/resonator_blast_modkit

/obj/item/disk/design_disk/modkit_disk/bounty
	name = "\improper KA mod disk (Death syphon)"
	modkit_design = /datum/design/bounty_modkit

/datum/design/offensive_turf_aoe_modkit
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(MAT_METAL = 7000, MAT_GLASS = 3000, MAT_SILVER= 3000, MAT_GOLD = 3000, MAT_DIAMOND = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	category = list("Mining", "Cyborg Upgrade Modules")
	build_type = PROTOLATHE | MECHFAB

/datum/design/rapid_repeater_modkit
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_URANIUM = 8000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater
	category = list("Mining", "Cyborg Upgrade Modules")
	build_type = PROTOLATHE | MECHFAB

/datum/design/resonator_blast_modkit
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_SILVER= 5000, MAT_URANIUM = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts
	category = list("Mining", "Cyborg Upgrade Modules")
	build_type = PROTOLATHE | MECHFAB

/datum/design/bounty_modkit
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	id = "bountymod"
	materials = list(MAT_METAL = 4000, MAT_SILVER = 4000, MAT_GOLD = 4000, MAT_BLUESPACE = 4000)
	reagents_list = list("blood" = 40)
	build_path = /obj/item/borg/upgrade/modkit/bounty
	category = list("Mining", "Cyborg Upgrade Modules")
	build_type = PROTOLATHE | MECHFAB

//Spooky special loot

// Beserker armor

#define MAX_BERSERK_CHARGE 100
#define PROJECTILE_HIT_MULTIPLIER 1.5
#define DAMAGE_TO_CHARGE_SCALE 0.75
#define CHARGE_DRAINED_PER_SECOND 5
#define BERSERK_DAMAGE_REDUCTION 0.6
#define BERSERK_ATTACK_SPEED_MODIFIER 0.5
#define BERSERK_COLOUR rgb(149, 10, 10)

/obj/item/clothing/suit/hooded/berserker
	name = "champion's hardsuit"
	desc = "Voices echo from the hardsuit, driving the user insane. Is not space proof"
	icon_state = "hardsuit-berserker"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/spear)
	armor = list(MELEE = 30, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 150, BIO = 0, RAD = 0, FIRE = INFINITY, ACID = INFINITY)
	hoodtype = /obj/item/clothing/head/hooded/berserker
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	respects_nodrop = TRUE
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)
	hide_tail_by_species = list("Unathi, Tajaran, Vox, Vulpkanin")

/obj/item/clothing/head/hooded/berserker
	name = "berserker helmet"
	desc = "Peering into the eyes of the helmet is enough to seal damnation."
	icon_state = "hardsuit0-berserker"
	item_color = "berserker"
	actions_types = list(/datum/action/item_action/berserk_mode)
	armor = list(MELEE = 30, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 150, BIO = 0, RAD = 0, FIRE = INFINITY, ACID = INFINITY)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi'
		)
	/// Current charge of berserk, goes from 0 to 100
	var/berserk_charge = 0
	/// Status of berserk
	var/berserk_active = FALSE


/obj/item/clothing/head/hooded/berserker/examine()
	. = ..()
	. += ("<span class='notice'>Berserk mode is [berserk_charge]% charged.</span>")

/obj/item/clothing/head/hooded/berserker/process()
	if(berserk_active)
		berserk_charge = clamp(berserk_charge - CHARGE_DRAINED_PER_SECOND * 2, 0, MAX_BERSERK_CHARGE)
	if(!berserk_charge)
		if(ishuman(loc))
			end_berserk(loc)

/obj/item/clothing/head/hooded/berserker/dropped(mob/user)
	. = ..()
	end_berserk(user)

/obj/item/clothing/head/hooded/berserker/Destroy()
	end_berserk()
	return ..()


/obj/item/clothing/head/hooded/berserker/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(berserk_active)
		return
	if(istype(hitby, /obj/item/projectile))
		var/obj/item/projectile/P = hitby
		if(P.damage_type != BRUTE && P.damage_type != BURN)
			return //no disabler rage
	var/berserk_value = damage * DAMAGE_TO_CHARGE_SCALE
	if(attack_type == PROJECTILE_ATTACK)
		berserk_value *= PROJECTILE_HIT_MULTIPLIER
	berserk_charge = clamp(round(berserk_charge + berserk_value), 0, MAX_BERSERK_CHARGE)
	if(berserk_charge >= MAX_BERSERK_CHARGE)
		to_chat(owner, "<span class='notice'>Berserk mode is fully charged.</span>")

/// Starts berserk, giving the wearer 40 armor, doubled attacking speed, NOGUNS trait, and colours them blood red.
/obj/item/clothing/head/hooded/berserker/proc/berserk_mode(mob/living/carbon/human/user)
	to_chat(user, "<span class='warning'>You enter berserk mode.</span>")
	playsound(user, 'sound/magic/staff_healing.ogg', 50)
	user.dna.species.burn_mod *= BERSERK_DAMAGE_REDUCTION
	user.dna.species.brute_mod *= BERSERK_DAMAGE_REDUCTION
	user.next_move_modifier *= BERSERK_ATTACK_SPEED_MODIFIER
	user.add_atom_colour(BERSERK_COLOUR, TEMPORARY_COLOUR_PRIORITY)
	ADD_TRAIT(user, TRAIT_CHUNKYFINGERS, BERSERK_TRAIT)
	flags |= NODROP
	suit.flags |= NODROP
	berserk_active = TRUE
	START_PROCESSING(SSobj, src)

/// Ends berserk, reverting the changes from the proc [berserk_mode]
/obj/item/clothing/head/hooded/berserker/proc/end_berserk(mob/living/carbon/human/user)
	if(!berserk_active)
		return
	berserk_active = FALSE
	if(QDELETED(user))
		return
	to_chat(user, "<span class='warning'>You exit berserk mode.</span>")
	playsound(user, 'sound/magic/summonitems_generic.ogg', 50)
	user.dna.species.burn_mod /= BERSERK_DAMAGE_REDUCTION
	user.dna.species.brute_mod /= BERSERK_DAMAGE_REDUCTION
	user.next_move_modifier /= BERSERK_ATTACK_SPEED_MODIFIER
	user.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, BERSERK_COLOUR)
	REMOVE_TRAIT(user, TRAIT_CHUNKYFINGERS, BERSERK_TRAIT)
	flags &= ~NODROP
	suit.flags &= ~NODROP
	STOP_PROCESSING(SSobj, src)

/datum/action/item_action/berserk_mode
	name = "Berserk"
	desc = "Increase your movement and melee speed while also increasing your melee armor for a short amount of time."

/datum/action/item_action/berserk_mode/Trigger(trigger_flags)
	if(istype(target, /obj/item/clothing/head/hooded/berserker))
		var/obj/item/clothing/head/hooded/berserker/berzerk = target
		if(berzerk.berserk_active)
			to_chat(owner, "<span class='warning'>You are already berserk!</span>")
			return
		if(berzerk.berserk_charge < 100)
			to_chat(owner, "<span class='warning'>You don't have a full charge.</span>")
			return
		berzerk.berserk_mode(owner)
		return
	return ..()

#undef MAX_BERSERK_CHARGE
#undef PROJECTILE_HIT_MULTIPLIER
#undef DAMAGE_TO_CHARGE_SCALE
#undef CHARGE_DRAINED_PER_SECOND
#undef BERSERK_DAMAGE_REDUCTION
#undef BERSERK_ATTACK_SPEED_MODIFIER
#undef BERSERK_COLOUR


//Rod of Asclepius
#define RIGHT_HAND 0
#define LEFT_HAND 1

/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "A wooden rod about the size of your forearm with a snake carved around it, winding its way up the sides of the rod. Something about it seems to inspire in you the responsibilty and duty to help others."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "asclepius_dormant"
	var/activated = FALSE
	var/usedHand
	var/mob/living/carbon/owner

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, "<span class='warning'>The snake carving seems to come alive, if only for a moment, before returning to its dormant state, almost as if it finds you incapable of holding its oath.</span>")
		return
	var/mob/living/carbon/itemUser = user
	if(itemUser.l_hand == src)
		usedHand = LEFT_HAND
	if(itemUser.r_hand == src)
		usedHand = RIGHT_HAND
	if(itemUser.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH))
		to_chat(user, "<span class='warning'>You can't possibly handle the responsibility of more than one rod!</span>")
		return
	var/failText = "<span class='warning'>The snake seems unsatisfied with your incomplete oath and returns to its previous place on the rod, returning to its dormant, wooden state. You must stand still while completing your oath!</span>"
	to_chat(itemUser, "<span class='notice'>The wooden snake that was carved into the rod seems to suddenly come alive and begins to slither down your arm! The compulsion to help others grows abnormally strong...</span>")
	if(do_after_once(itemUser, 40, target = itemUser))
		itemUser.say("I swear to fulfill, to the best of my ability and judgment, this covenant:")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 20, target = itemUser))
		itemUser.say("I will apply, for the benefit of the sick, all measures that are required, avoiding those twin traps of overtreatment and therapeutic nihilism.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("I will remember that I remain a member of society, with special obligations to all my fellow human beings, those sound of mind and body as well as the infirm.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("If I do not violate this oath, may I enjoy life and art, respected while I live and remembered with affection thereafter. May I always act so as to preserve the finest traditions of my calling and may I long experience the joy of healing those who seek my help.")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, "<span class='notice'>The snake, satisfied with your oath, attaches itself and the rod to your forearm with an inseparable grip. Your thoughts seem to only revolve around the core idea of helping others, and harm is nothing more than a distant, wicked memory...</span>")

	activated(itemUser)

/obj/item/rod_of_asclepius/Destroy()
	owner = null
	return ..()

/obj/item/rod_of_asclepius/dropped(mob/user, silent)
	..()
	if(!activated)
		return
	addtimer(CALLBACK(src, .proc/try_attach_to_owner), 0) // Do this once the drop call stack is done. The holding limb might be getting removed

/obj/item/rod_of_asclepius/proc/try_attach_to_owner()
	if(ishuman(owner) && !QDELETED(owner))
		if(ishuman(loc))
			var/mob/living/carbon/human/thief = loc
			thief.unEquip(src, TRUE, TRUE) // You're not my owner!
		if(owner.stat == DEAD)
			qdel(src) // Oh no! Oh well a new rod will be made from the STATUS_EFFECT_HIPPOCRATIC_OATH
			return
		flags |= NODROP // Readd the nodrop
		var/mob/living/carbon/human/H = owner
		var/limb_regrown = FALSE
		if(usedHand == LEFT_HAND)
			limb_regrown = H.regrow_external_limb_if_missing("l_arm")
			limb_regrown = H.regrow_external_limb_if_missing("l_hand") || limb_regrown
			H.drop_l_hand(TRUE)
			H.put_in_l_hand(src, TRUE)
		else
			limb_regrown = H.regrow_external_limb_if_missing("r_arm")
			limb_regrown = H.regrow_external_limb_if_missing("r_hand") || limb_regrown
			H.drop_r_hand(TRUE)
			H.put_in_r_hand(src, TRUE)
		if(!limb_regrown)
			to_chat(H, "<span class='notice'>The Rod of Asclepius suddenly grows back out of your arm!</span>")
		else
			H.update_body() // Update the limb sprites
			to_chat(H, "<span class='notice'>Your arm suddenly grows back with the Rod of Asclepius still attached!</span>")
	else
		deactivate()

/obj/item/rod_of_asclepius/proc/activated(mob/living/carbon/new_owner)
	owner = new_owner
	flags = NODROP
	desc = "A short wooden rod with a mystical snake inseparably gripping itself and the rod to your forearm. It flows with a healing energy that disperses amongst yourself and those around you. "
	icon_state = "asclepius_active"
	activated = TRUE

	owner.apply_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH)
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/deactivate)

/obj/item/rod_of_asclepius/proc/deactivate()
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
		owner = null

	flags = NONE
	activated = FALSE
	desc = initial(desc)
	icon_state = initial(icon_state)

#undef RIGHT_HAND
#undef LEFT_HAND
