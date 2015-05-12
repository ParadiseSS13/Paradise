/datum/game_mode
	var/list/datum/mind/superheroes = list()
	var/list/datum/mind/supervillains = list()
	var/list/datum/mind/greyshirts = list()

/datum/superheroes
	var/name
	var/desc
	var/class
	var/list/default_genes = list(REGEN, NO_BREATH, RESIST_COLD)
	var/list/default_spells = list()

/datum/superheroes/proc/create(var/mob/living/carbon/human/H)
	assign_genes(H)
	assign_spells(H)
	equip(H)
	assign_id(H)

/datum/superheroes/proc/equip(var/mob/living/carbon/human/H)
	H.fully_replace_character_name(H.real_name, name)
	for(var/obj/item/W in H)
		if(istype(W,/obj/item/organ)) continue
		H.unEquip(W)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(H), slot_l_ear)

/datum/superheroes/proc/assign_genes(var/mob/living/carbon/human/H)
	if(default_genes.len)
		for(var/gene in default_genes)
			H.mutations |= gene
		H.update_mutations()

/datum/superheroes/proc/assign_spells(var/mob/living/carbon/human/H)
	if(default_spells.len)
		for(var/spell in default_spells)
			var/obj/effect/proc_holder/spell/wizard/S = spell
			if(!S) return
			H.AddSpell(new S)

/datum/superheroes/proc/assign_id(var/mob/living/carbon/human/H)
	var/obj/item/weapon/card/id/syndicate/W = new(H)
	W.registered_name = H.real_name
	W.access = list(access_maint_tunnels)
	if(class == "Superhero")
		W.name = "[H.real_name]'s ID Card (Superhero)"
		W.assignment = "Superhero"
		ticker.mode.superheroes += H.mind
	else if(class == "Supervillain")
		W.name = "[H.real_name]'s ID Card (Supervillain)"
		W.assignment = "Supervillain"
		ticker.mode.supervillains += H.mind

	H.equip_to_slot_or_del(W, slot_wear_id)
	H.regenerate_icons()

	H << desc

/datum/superheroes/owlman
	name = "Owlman"
	class = "Superhero"
	desc = "You are Owlman, the oldest and some say greatest superhero this station has ever known. You have faced countless \
	foes, and protected the station for years. Your tech gadgets make you a force to be reckoned with. You are the hero this \
	station deserves."

/datum/superheroes/owlman/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black/greytide(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/owl(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/owl_mask(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/bluespace/owlman(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night(H), slot_glasses)


/datum/superheroes/griffin
	name = "The Griffin"
	default_spells = list(/obj/effect/proc_holder/spell/wizard/targeted/recruit)
	class = "Supervillain"
	desc = "You are The Griffin, the ultimate supervillain. You thrive on chaos and have no respect for the supposed authority \
	of the command staff of this station. Along with your gang of dim-witted yet trusty henchmen, you will be able to execute \
	the most dastardly plans."

/datum/superheroes/griffin/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/griffin(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/griffin(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings/griffinwings(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/griffin(H), slot_head)

	var/obj/item/weapon/implant/freedom/L = new/obj/item/weapon/implant/freedom(H)
	L.imp_in = H
	L.implanted = 1
	var/obj/item/organ/external/affected = H.organs_by_name["head"]
	affected.implants += L
	L.part = affected
	return 1


/datum/superheroes/lightnian
	name = "LightnIan"
	class = "Superhero"
	desc = "You are LightnIan, the lord of lightning! A freak electrical accident while working in the station's kennel \
	has given you mastery over lightning and a peculiar desire to sniff butts. Although you are a recent addition to the \
	station's hero roster, you intend to leave your mark."
	default_spells = list(/obj/effect/proc_holder/spell/wizard/targeted/lightning/lightnian)

/datum/superheroes/lightnian/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/brown(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/corgisuit(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/corgi(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/weapon/bedsheet/orange(H), slot_back)


/datum/superheroes/electro
	name = "Electro-Negmatic"
	class = "Supervillain"
	desc = "You were a roboticist, once. Now you are Electro-Negmatic, a name this station will learn to fear. You designed \
	your costume to resemble E-N, your faithful dog that some callous RD destroyed because it was sparking up the plasma. You \
	intend to take your revenge and make them all pay thanks to your magnetic powers."
	default_spells = list(/obj/effect/proc_holder/spell/wizard/targeted/magnet)

/datum/superheroes/electro/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black/greytide(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/corgisuit/en(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/corgi/en(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/weapon/bedsheet/cult(H), slot_back)




///////////////////////////////POWERS/ABILITIES CODE/////////////////////////////////////////


//The Griffin's special recruit abilitiy
/obj/effect/proc_holder/spell/wizard/targeted/recruit
	name = "Recruit Greyshirt"
	desc = "Allows you to recruit a conscious, non-braindead, non-catatonic human to be part of the Greyshirts, your personal henchmen. This works on Civilians only and you can recruit a maximum of 3!."
	charge_max = 450
	clothes_req = 0
	range = 1 //Adjacent to user
	action_icon_state = "spell_greytide"
	var/recruiting = 0

/obj/effect/proc_holder/spell/wizard/targeted/recruit/cast(list/targets)
	for(var/mob/living/carbon/human/target in targets)
		if(ticker.mode.greyshirts.len >= 3)
			usr << "<span class='warning'>You have already recruited the maximum number of henchmen.</span>"
		if(!in_range(usr, target))
			usr << "<span class='warning'>You need to be closer to enthrall [target].</span>"
			charge_counter = charge_max
			return
		if(!target.ckey)
			usr << "<span class='warning'>The target has no mind.</span>"
			charge_counter = charge_max
			return
		if(target.stat)
			usr << "<span class='warning'>The target must be conscious.</span>"
			charge_counter = charge_max
			return
		if(!ishuman(target))
			usr << "<span class='warning'>You can only recruit humans.</span>"
			charge_counter = charge_max
			return
		if(target.mind.assigned_role != "Civilian")
			usr << "<span class='warning'>You can only recruit Civilians.</span>"
		if(recruiting)
			usr << "<span class='danger'>You are already recruiting!</span>"
			charge_counter = charge_max
			return
		recruiting = 1
		usr << "<span class='danger'>This target is valid. You begin the recruiting process.</span>"
		target << "<span class='userdanger'>[usr] focuses in concentration. Your head begins to ache.</span>"

		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					usr << "<span class='notice'>You begin by introducing yourself and explaining what you're about.</span>"
					usr.visible_message("<span class='danger'>[usr]'s introduces himself and explains his plans.</span>")
				if(2)
					usr << "<span class='notice'>You begin the recruitment of [target].</span>"
					usr.visible_message("<span class='danger'>[usr] leans over towards [target], whispering excitedly as he gives a speech.</span>")
					target << "<span class='danger'>You feel yourself agreeing with [usr], and a surge of loyalty begins building.</span>"
					target.Weaken(12)
					sleep(20)
					if(isloyal(target))
						usr << "<span class='notice'>They are enslaved by Nanotrasen. You feel their interest in your cause wane and disappear.</span>"
						usr.visible_message("<span class='danger'>[usr] stops talking for a moment, then moves back away from [target].</span>")
						target << "<span class='danger'>Your loyalty implant activates and a sharp pain reminds you of your loyalties to Nanotrasen.</span>"
						return
				if(3)
					usr << "<span class='notice'>You begin filling out the application form with [target].</span>"
					usr.visible_message("<span class='danger'>[usr] pulls out a pen and paper and begins filling an application form with [target].</span>")
					target << "<span class='danger'>You are being convinced by [usr] to fill out an application form to become a henchman.</span>" //Ow the edge
			if(!do_mob(usr, target, 100)) //around 30 seconds total for enthralling, 45 for someone with a loyalty implant
				usr << "<span class='danger'>The enrollment process has been interrupted - you have lost the attention of [target].</span>"
				target << "<span class='warning'>You move away and are no longer under the charm of [usr]. The application form is null and void.</span>"
				recruiting = 0
				return

		recruiting = 0
		usr << "<span class='notice'>You have recruited <b>[target]</b> as your henchman!</span>"
		target << "<span class='deadsay'><b>You have decided to enroll as a henchman for [usr]. You are now part of the feared 'Greyshirts'.</b></span>"
		target << "<span class='deadsay'><b>You must follow the orders of [usr], and help him succeed in his dastardly schemes.</span>"
		target << "<span class='deadsay'>You may not harm other Greyshirt or [usr]. However, you do not need to obey other Greyshirts.</span>"
		ticker.mode.greyshirts += target.mind
		target.set_species("Human")
		target.h_style = "Bald"
		target.f_style = "Shaved"
		target.s_tone = 35
		target.r_eyes = 1
		target.b_eyes = 1
		target.g_eyes = 1
		for(var/obj/item/W in target)
			if(istype(W,/obj/item/organ)) continue
			target.unEquip(W)
		target.fully_replace_character_name(target.real_name, "Generic Henchman ([rand(1, 1000)])")
		target.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey/greytide(target), slot_w_uniform)
		target.equip_to_slot_or_del(new /obj/item/clothing/shoes/black/greytide(target), slot_shoes)
		target.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/mechanical/greytide(target), slot_l_hand)
		var/obj/item/weapon/card/id/syndicate/W = new(target)
		W.registered_name = target.real_name
		W.access = list(access_maint_tunnels)
		W.name = "[target.real_name]'s ID Card (Greyshirt)"
		W.assignment = "Greyshirt"
		target.equip_to_slot_or_del(W, slot_wear_id)
		target.equip_to_slot_or_del(new /obj/item/device/radio/headset(target), slot_l_ear)
		target.regenerate_icons()

