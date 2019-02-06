/obj/item/organ/internal/liver/grey
	name = "grey liver"
	desc = "A small, odd looking liver"
	icon = 'icons/obj/species_organs/grey.dmi'
	alcohol_intensity = 1.6

/obj/item/organ/internal/brain/grey
	desc = "A large brain"
	icon = 'icons/obj/species_organs/grey.dmi'
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/grey.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/brain/grey/insert(var/mob/living/carbon/M, var/special = 0)
	..()
	M.add_language("Psionic Communication")

/obj/item/organ/internal/brain/grey/remove(var/mob/living/carbon/M, var/special = 0)
	. = ..()
	M.remove_language("Psionic Communication")

/obj/item/organ/internal/eyes/grey
	name = "grey eyeballs"
	desc = "They still look creepy and emotionless"
	icon = 'icons/obj/species_organs/grey.dmi'
	dark_view = 5

/obj/item/organ/internal/heart/grey
	name = "grey heart"
	icon = 'icons/obj/species_organs/grey.dmi'

/obj/item/organ/internal/lungs/grey
	name = "grey lungs"
	icon = 'icons/obj/species_organs/grey.dmi'

/obj/item/organ/internal/kidneys/grey
	name = "grey kidneys"
	icon = 'icons/obj/species_organs/grey.dmi'