/datum/outfit/job/chef/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Culinary Artist")
				head = /obj/item/clothing/head/chefhat/red
				uniform = /obj/item/clothing/under/rank/civilian/chef/red
				suit = /obj/item/clothing/suit/chef/red
				belt = /obj/item/storage/belt/chef/apron/red
