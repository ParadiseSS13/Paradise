//Indumentaria para el beekeeper//

/datum/outfit/job/hydro/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
    . = ..()
    if(H.mind && H.mind.role_alt_title)
        switch(H.mind.role_alt_title)
            if("Beekeeper")
                uniform = /obj/item/clothing/under/rank/hydroponics
                suit = /obj/item/clothing/suit/beekeeper_suit
                gloves = /obj/item/clothing/gloves/botanic_leather
                shoes = /obj/item/clothing/shoes/black
                head = /obj/item/clothing/head/beekeeper_head
                l_ear = /obj/item/radio/headset/headset_service
                suit_store = /obj/item/melee/flyswatter
                pda = /obj/item/pda/botanist

                backpack = /obj/item/storage/backpack/botany
                satchel = /obj/item/storage/backpack/satchel_hyd
                dufflebag = /obj/item/storage/backpack/duffel/hydro
