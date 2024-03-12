/datum/outfit/job/chef/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Culinary Artist")
				head = /obj/item/clothing/head/chefhat/red
				uniform = /obj/item/clothing/under/rank/civilian/chef/red
				suit = /obj/item/clothing/suit/chef/red
				belt = /obj/item/storage/belt/chef/apron/red


/datum/job/cargo_tech/New()
	. = ..()
	alt_titles |= list("Deliverer", "Доставщик", "Переносчик")

/datum/outfit/job/cargo_tech/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Deliverer", "Доставщик", "Переносчик")
				uniform = /obj/item/clothing/under/misc/overalls
				shoes = /obj/item/clothing/shoes/workboots
				head = /obj/item/clothing/head/soft
				r_hand = /obj/item/mail_scanner
				r_pocket = /obj/item/storage/bag/mail
				l_ear = /obj/item/radio/headset/headset_service
				r_ear = /obj/item/radio/headset/headset_cargo
				id = /obj/item/card/id/courier
				backpack_contents = list(
					/obj/item/eftpos = 1,
					/obj/item/clipboard = 1,
					/obj/item/reagent_containers/spray/pepper = 1,
					/obj/item/reagent_containers/spray/pestspray = 1,
					/obj/item/reagent_containers/spray/plantbgone = 1,
				)

				backpack = /obj/item/storage/backpack/industrial
				satchel = /obj/item/storage/backpack/satchel_eng
				dufflebag = /obj/item/storage/backpack/duffel/engineering
