/obj/item/organ/internal/liver/grey
	alcohol_intensity = 1.6

/obj/item/organ/internal/brain/grey
	icon_state = "brain-x"
	mmi_icon_state = "mmi_alien"

/obj/item/organ/internal/brain/grey/insert(var/mob/living/carbon/M, var/special = 0)
	..()
	M.add_language("Psionic Communication")

/obj/item/organ/internal/brain/grey/remove(var/mob/living/carbon/M, var/special = 0)
	. = ..()
	M.remove_language("Psionic Communication")

/obj/item/organ/internal/eyes/grey
	name = "grey eyeballs"
	dark_view = 5