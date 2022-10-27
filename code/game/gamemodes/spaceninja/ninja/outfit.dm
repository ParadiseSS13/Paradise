/datum/outfit/ninja
	name = "Space Ninja"
	uniform = /obj/item/clothing/under/ninja
	suit = /obj/item/clothing/suit/space/space_ninja
	glasses = /obj/item/clothing/glasses/ninja
	mask = /obj/item/clothing/mask/gas/space_ninja
	head = /obj/item/clothing/head/helmet/space/space_ninja
	r_ear = /obj/item/radio/headset/ninja
	shoes = /obj/item/clothing/shoes/space_ninja
	gloves = /obj/item/clothing/gloves/space_ninja
	r_pocket = /obj/item/tank/internals/emergency_oxygen/ninja
	belt = /obj/item/melee/energy_katana
	back = /obj/item/storage/backpack/ninja

/datum/outfit/ninja/pre_equip(mob/living/carbon/human/ninja)
	ninja.set_species(/datum/species/human) // Это можно считать временным решением, пока у ниндзи нет спрайтов одежды для других рас
	ninja.revive()							// В прочем, все мы знаем, что временные решения обычно самые постоянные...
											// revive - тут, чтобы оставались робоконечности (вместо замены конечностей кодом set_species)

/datum/outfit/ninja/post_equip(mob/living/carbon/human/ninja)
	if(istype(ninja.wear_suit, suit))
		var/obj/item/clothing/suit/space/space_ninja/ninja_suit = ninja.wear_suit
		ninja_suit.preferred_clothes_gender = ninja.gender
		ninja_suit.n_headset = ninja.r_ear
		ninja_suit.n_backpack = ninja.back
		if(istype(ninja.belt, belt))
			ninja_suit.energyKatana = ninja.belt

