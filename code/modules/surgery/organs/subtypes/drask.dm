//DRASK ORGAN
/obj/item/organ/internal/drask
	name = "drask organ"
	icon = 'icons/obj/surgery_drask.dmi'
	icon_state = "innards"
	desc = "A greenish, slightly translucent organ. It is extremely cold."

/obj/item/organ/internal/heart/drask
	name = "drask heart"
	icon = 'icons/obj/surgery_drask.dmi'
	icon_state = "heart-on"
	dead_icon = "heart-off"
	organ_tag = "heart"
	parent_organ = "head"
	slot = "heart"

/obj/item/organ/internal/lungs/drask
	name = "lungs"
	icon = 'icons/obj/surgery_drask.dmi'
	icon_state = "lungs"
	gender = PLURAL
	organ_tag = "lungs"
	parent_organ = "chest"
	slot = "lungs"

/obj/item/organ/internal/liver/drask
	name = "metabolic strainer"
	icon = 'icons/obj/surgery_drask.dmi'
	icon_state = "kidneys"
	gender = PLURAL
	organ_tag = "kidneys"
	parent_organ = "groin"
	slot = "kidneys"
	alcohol_intensity = 0.8

/obj/item/organ/internal/brain/drask
	name = "brain"
	icon = 'icons/obj/surgery_drask.dmi'
	icon_state = "brain2"
	organ_tag = "brain"
	slot = "brain"
	mmi_icon = 'icons/obj/surgery_drask.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/eyes/drask
	name = "eyes"
	icon = 'icons/obj/surgery_drask.dmi'
	icon_state = "eyes"
	gender = PLURAL
	organ_tag = "eyes"
	parent_organ = "head"
	slot = "eyes"
	desc = "Drask eyes. They look even stranger disembodied"
