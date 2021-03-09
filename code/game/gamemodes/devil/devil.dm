GLOBAL_LIST_INIT(whiteness, list(
	/obj/item/clothing/under/color/white = 2,
	/obj/item/clothing/under/rank/bartender = 1,
	/obj/item/clothing/under/rank/chef = 1,
	/obj/item/clothing/under/rank/chief_engineer = 1,
	/obj/item/clothing/under/rank/scientist = 1,
	/obj/item/clothing/under/rank/chemist = 1,
	/obj/item/clothing/under/rank/chief_medical_officer = 1,
	/obj/item/clothing/under/rank/geneticist = 1,
	/obj/item/clothing/under/rank/virologist = 1,
	/obj/item/clothing/under/rank/nursesuit = 1,
	/obj/item/clothing/under/rank/medical = 1,
	/obj/item/clothing/under/rank/psych = 1,
	/obj/item/clothing/under/rank/orderly = 1,
	/obj/item/clothing/under/rank/security/brigphys = 1,
	/obj/item/clothing/under/rank/internalaffairs = 1,
	/obj/item/clothing/under/rank/ntrep = 1,
	/obj/item/clothing/under/det = 1,
	/obj/item/clothing/under/wedding/bride_white = 1,
	/obj/item/clothing/under/mafia/white = 1,
	/obj/item/clothing/under/noble_clothes = 1,
	/obj/item/clothing/under/sl_suit = 1,
	/obj/item/clothing/under/burial = 1
))



/mob/living/proc/check_devil_bane_multiplier(obj/item/weapon, mob/living/attacker)
	switch(mind.devilinfo.bane)
		if(BANE_WHITECLOTHES)
			if(istype(attacker, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = attacker
				if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under))
					var/obj/item/clothing/under/U = H.w_uniform
					if(GLOB.whiteness[U.type])
						src.visible_message("<span class='warning'>[src] seems to have been harmed by the purity of [attacker]'s clothes.</span>", "<span class='notice'>Unsullied white clothing is disrupting your form.</span>")
						return GLOB.whiteness[U.type] + 1
		if(BANE_TOOLBOX)
			if(istype(weapon,/obj/item/storage/toolbox))
				src.visible_message("<span class='warning'>The [weapon] seems unusually robust this time.</span>", "<span class='notice'>The [weapon] is your unmaking!</span>")
				return 2.5 // Will take four hits with a normal toolbox.
		if(BANE_HARVEST)
			if(istype(weapon,/obj/item/reagent_containers/food/snacks/grown/) || istype(weapon,/obj/item/grown))
				src.visible_message("<span class='warning'>The spirits of the harvest aid in the exorcism.</span>", "<span class='notice'>The harvest spirits are harming you.</span>")
				src.Weaken(2)
				qdel(weapon)
				return 2
	return 1
