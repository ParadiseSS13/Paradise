/datum/superheroes
	var/name
	var/desc
	var/class
	var/list/default_spells = list()

/datum/superheroes/proc/create(mob/living/carbon/human/H)
	assign_mutations(H)
	assign_spells(H)
	equip(H)
	fixflags(H)
	assign_id(H)
	H.mind.special_role = SPECIAL_ROLE_SUPER

/datum/superheroes/proc/equip(mob/living/carbon/human/H)
	H.rename_character(H.real_name, name)
	for(var/obj/item/W in H.get_all_slots())
		H.drop_item_to_ground(W)
	H.equip_to_slot_or_del(new /obj/item/radio/headset(H), ITEM_SLOT_LEFT_EAR)

/datum/superheroes/proc/fixflags(mob/living/carbon/human/H)
	for(var/obj/item/W in H.get_all_slots())
		W.set_nodrop(TRUE, H)

/datum/superheroes/proc/assign_mutations(mob/living/carbon/human/H)
	var/list/default_mutations = list(GLOB.regenerateblock, GLOB.breathlessblock, GLOB.coldblock)
	for(var/mutation in default_mutations)
		H.dna.SetSEState(mutation, 1)
		singlemutcheck(H, mutation, MUTCHK_FORCED)

/datum/superheroes/proc/assign_spells(mob/living/carbon/human/H)
	if(length(default_spells))
		for(var/spell in default_spells)
			var/datum/spell/S = spell
			if(!S)
				return
			H.mind.AddSpell(new S(null))

/datum/superheroes/proc/assign_id(mob/living/carbon/human/H)
	var/obj/item/card/id/syndicate/W = new(H)
	W.registered_name = H.real_name
	W.access = list(ACCESS_MAINT_TUNNELS)
	if(class == "Superhero")
		W.assignment = "Superhero"
		W.rank = "Superhero"
		SSticker.mode.superheroes += H.mind
	else if(class == "Supervillain")
		W.assignment = "Supervillain"
		W.rank = "Supervillain"
		SSticker.mode.supervillains += H.mind
	W.icon_state = "lifetimeid"
	W.SetOwnerInfo(H)
	W.UpdateName()
	W.set_nodrop(TRUE, H)
	H.equip_to_slot_or_del(W, ITEM_SLOT_ID)
	H.regenerate_icons()

	to_chat(H, desc)

/datum/superheroes/owlman
	name = "Owlman"
	class = "Superhero"
	desc = "You are Owlman, the oldest and some say greatest superhero this station has ever known. You have faced countless \
	foes, and protected the station for years. Your tech gadgets make you a force to be reckoned with. You are the hero this \
	station deserves."

/datum/superheroes/owlman/equip(mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black/greytide(H), ITEM_SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/costume/owl(H), ITEM_SLOT_JUMPSUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings(H), ITEM_SLOT_OUTER_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/owl_mask/super_hero(H), ITEM_SLOT_MASK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/bluespace/owlman(H), ITEM_SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night(H), ITEM_SLOT_EYES)


/datum/superheroes/griffin
	name = "The Griffin"
	default_spells = list(/datum/spell/recruit)
	class = "Supervillain"
	desc = "You are The Griffin, the ultimate supervillain. You thrive on chaos and have no respect for the supposed authority \
	of the command staff of this station. Along with your gang of dim-witted yet trusty henchmen, you will be able to execute \
	the most dastardly plans."

/datum/superheroes/griffin/equip(mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/griffin(H), ITEM_SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/costume/griffin(H), ITEM_SLOT_JUMPSUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings/griffinwings(H), ITEM_SLOT_OUTER_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/griffin/(H), ITEM_SLOT_HEAD)

	var/obj/item/bio_chip/freedom/L = new/obj/item/bio_chip/freedom(H)
	L.implant(H)


/datum/superheroes/lightnian
	name = "LightnIan"
	class = "Superhero"
	desc = "You are LightnIan, the lord of lightning! A freak electrical accident while working in the station's kennel \
	has given you mastery over lightning and a peculiar desire to sniff butts. Although you are a recent addition to the \
	station's hero roster, you intend to leave your mark."
	default_spells = list(/datum/spell/charge_up/bounce/lightning/lightnian)

/datum/superheroes/lightnian/equip(mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), ITEM_SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/brown(H), ITEM_SLOT_JUMPSUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/corgisuit/super_hero(H), ITEM_SLOT_OUTER_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/corgi/super_hero(H), ITEM_SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(H), ITEM_SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/bedsheet/orange(H), ITEM_SLOT_BACK)


/datum/superheroes/electro
	name = "Electro-Negmatic"
	class = "Supervillain"
	desc = "You were a roboticist, once. Now you are Electro-Negmatic, a name this station will learn to fear. You designed \
	your costume to resemble E-N, your faithful dog that some callous RD destroyed because it was sparking up the plasma. You \
	intend to take your revenge and make them all pay thanks to your magnetic powers."
	default_spells = list(/datum/spell/charge_up/bounce/magnet)

/datum/superheroes/electro/equip(mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black/greytide(H), ITEM_SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), ITEM_SLOT_JUMPSUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/corgisuit/super_hero/en(H), ITEM_SLOT_OUTER_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/corgi/super_hero/en(H), ITEM_SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/bedsheet/cult(H), ITEM_SLOT_BACK)




///////////////////////////////POWERS/ABILITIES CODE/////////////////////////////////////////


//The Griffin's special recruit abilitiy
/datum/spell/recruit
	name = "Recruit Greyshirt"
	desc = "Allows you to recruit a conscious, non-braindead, non-catatonic human to be part of the Greyshirts, your personal henchmen. This works on Assistants only and you can recruit a maximum of 3!."
	base_cooldown = 450
	clothes_req = FALSE
	antimagic_flags = NONE
	action_icon_state = "spell_greytide"
	var/recruiting = 0

	selection_activated_message		= "<span class='notice'>You start preparing a mindblowing monologue. <b>Left-click to cast at a target!</b></span>"
	selection_deactivated_message	= "<span class='notice'>You decide to save your brilliance for another day.</span>"

/datum/spell/recruit/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = -1
	T.range = 1
	return T

/datum/spell/recruit/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(length(SSticker.mode.greyshirts) >= 3)
		if(show_message)
			to_chat(user, "<span class='warning'>You have already recruited the maximum number of henchmen.</span>")
		return FALSE
	if(recruiting)
		if(show_message)
			to_chat(user, "<span class='danger'>You are already recruiting!</span>")
		return FALSE
	return ..()

/datum/spell/recruit/valid_target(mob/living/carbon/human/target, user)
	return target.ckey && !target.stat

/datum/spell/recruit/cast(list/targets,mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	if(target.mind.assigned_role != "Assistant")
		to_chat(user, "<span class='warning'>You can only recruit Assistants.</span>")
		revert_cast(user)
		return
	recruiting = TRUE
	to_chat(user, "<span class='danger'>This target is valid. You begin the recruiting process.</span>")
	to_chat(target, "<span class='userdanger'>[user] focuses in concentration. Your head begins to ache.</span>")

	for(var/progress = 0, progress <= 3, progress++)
		switch(progress)
			if(1)
				to_chat(user, "<span class='notice'>You begin by introducing yourself and explaining what you're about.</span>")
				user.visible_message("<span class='danger'>[user] introduces [user.p_themselves()] and explains [user.p_their()] plans.</span>")
			if(2)
				to_chat(user, "<span class='notice'>You begin the recruitment of [target].</span>")
				user.visible_message("<span class='danger'>[user] leans over towards [target], whispering excitedly as [user.p_they()] give[user.p_s()] a speech.</span>")
				to_chat(target, "<span class='danger'>You feel yourself agreeing with [user], and a surge of loyalty begins building.</span>")
				target.Weaken(24 SECONDS)
				sleep(20)
				if(ismindshielded(target))
					to_chat(user, "<span class='notice'>[target.p_they(TRUE)] are enslaved by Nanotrasen. You feel [target.p_their()] interest in your cause wane and disappear.</span>")
					user.visible_message("<span class='danger'>[user] stops talking for a moment, then moves back away from [target].</span>")
					to_chat(target, "<span class='danger'>Your mindshield bio-chip activates, protecting you from conversion.</span>")
					return
			if(3)
				to_chat(user, "<span class='notice'>You begin filling out the application form with [target].</span>")
				user.visible_message("<span class='danger'>[user] pulls out a pen and paper and begins filling an application form with [target].</span>")
				to_chat(target, "<span class='danger'>You are being convinced by [user] to fill out an application form to become a henchman.</span>")//Ow the edge

		if(!do_mob(user, target, 100)) //around 30 seconds total for enthralling, 45 for someone with a mindshield bio-chip
			to_chat(user, "<span class='danger'>The enrollment process has been interrupted - you have lost the attention of [target].</span>")
			to_chat(target, "<span class='warning'>You move away and are no longer under the charm of [user]. The application form is null and void.</span>")
			recruiting = FALSE
			return

	recruiting = FALSE
	to_chat(user, "<span class='notice'>You have recruited <b>[target]</b> as your henchman!</span>")
	to_chat(target, "<span class='deadsay'><b>You have decided to enroll as a henchman for [user]. You are now part of the feared 'Greyshirts'.</b></span>")
	to_chat(target, "<span class='deadsay'><b>You must follow the orders of [user], and help [user.p_them()] succeed in [user.p_their()] dastardly schemes.</b></span>")
	to_chat(target, "<span class='deadsay'>You may not harm other Greyshirt or [user]. However, you do not need to obey other Greyshirts.</span>")
	SSticker.mode.greyshirts += target.mind
	target.set_species(/datum/species/human)
	var/obj/item/organ/external/head/head_organ = target.get_organ("head")
	if(istype(head_organ))
		head_organ.h_style = "Bald"
		head_organ.f_style = "Shaved"
	target.change_skin_tone(1)
	// No `update_dna=0` here because the character is being over-written
	target.change_eye_color(1,1,1)
	for(var/obj/item/W in target.get_all_slots())
		target.drop_item_to_ground(W)
	target.rename_character(target.real_name, "Generic Henchman ([rand(1, 1000)])")
	target.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey/greytide(target), ITEM_SLOT_JUMPSUIT)
	target.equip_to_slot_or_del(new /obj/item/clothing/shoes/black/greytide(target), ITEM_SLOT_SHOES)
	target.equip_to_slot_or_del(new /obj/item/storage/toolbox/mechanical/greytide(target), ITEM_SLOT_LEFT_HAND)
	target.equip_to_slot_or_del(new /obj/item/radio/headset(target), ITEM_SLOT_LEFT_EAR)
	var/obj/item/card/id/syndicate/W = new(target)
	W.icon_state = "lifetimeid"
	W.access = list(ACCESS_MAINT_TUNNELS)
	W.assignment = "Greyshirt"
	W.rank = "Greyshirt"
	W.set_nodrop(TRUE, W.loc)
	W.SetOwnerInfo(target)
	W.UpdateName()
	target.equip_to_slot_or_del(W, ITEM_SLOT_ID)
	target.regenerate_icons()
