/obj/item/dissector
	name = "Dissection Tool"
	desc = "An advanced handheld device that assists with the preparation and removal of non-standard alien organs."
	icon_state = "scalpel_manager_on"

/obj/item/organ/internal/heart/xenobiology
	name = "Unidentified Mass"
	desc = "A nausea-inducing hunk of twisting flesh and metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gland"
	dead_icon = null
	origin_tech = "biotech=5"
	organ_datums = list(/datum/organ/heart)
	tough = TRUE

/obj/item/organ/internal/heart/xenobiology/remove(mob/living/carbon/M, special = 0)
	processing = FALSE
	. = ..()

/obj/item/organ/internal/heart/xenobiology/on_life()


/obj/item/organ/internal/heart/xenobiology/toxic
	name = "Toxic Glands"

/obj/item/organ/internal/heart/xenobiology/toxic/trigger()
	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return
	to_chat(owner, "<span class='notice'>You feel nausious as your insides feel like they're ripping themself apart!</span>")
	owner.adjustToxLoss(5)
