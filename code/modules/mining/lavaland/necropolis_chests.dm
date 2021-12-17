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
	var/loot = rand(1, 26)
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
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/berserker(src)
		if(13)
			new /obj/item/nullrod/scythe/talking(src)
		if(14)
			new /obj/item/nullrod/armblade/mining(src)
		if(15)
			new /obj/item/guardiancreator(src)
		if(16)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disk/mob_and_turf_aoe(src)
			else
				new /obj/item/disk/design_disk/modkit_disk/bounty(src)
		if(17)
			new /obj/item/warp_cube/red(src)
		if(18)
			new /obj/item/wisp_lantern(src)
		if(19)
			new /obj/item/immortality_talisman(src)
		if(20)
			new /obj/item/gun/magic/hook(src)
		if(21)
			new /obj/item/voodoo(src)
		if(22)
			new /obj/item/grenade/clusterbuster/inferno(src)
		if(23)
			new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor(src)
		if(24)
			new /obj/item/spellbook/oneuse/summonitem(src)
		if(25)
			new /obj/item/book_of_babel(src)
		if(26)
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
