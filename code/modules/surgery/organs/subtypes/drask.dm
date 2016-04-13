//DRASK ORGAN
/obj/item/organ/internal/drask
	name = "drask organ"
	icon = 'icons/obj/surgery_drask.dmi'
	icon_state = "innards"
	desc = "A greenish, slightly translucent organ. /red It is extremely cold."

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

///obj/item/organ/internal/liver/drask/process() //If we ever want to do the "implant them to keep a livable body temp thing." For now, I'd rather not
//	if(owner.bodytemperature >= 283)
//		src.damage += 0.2

/obj/item/organ/internal/brain/drask
	name = "brain"
	icon = 'icons/obj/surgery_drask.dmi'
	icon_state = "brain2"
	organ_tag = "brain"
	slot = "brain"

/obj/item/organ/internal/eyes/drask
	name = "eyes"
	icon = 'icons/obj/surgery_drask.dmi'
	icon_state = "eyes"
	gender = PLURAL
	organ_tag = "eyes"
	parent_organ = "head"
	slot = "eyes"
	desc = "Drask eyes. They look even stranger disembodied"

/obj/item/organ/internal/cyberimp/drask_comfort
	name = "cryonic homeostasis implant"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "rocket_chem"
	parent_organ = "chest"
	desc = "This cybernetic implant will attempt to maintain the user's body heat at a freezing temperature. Probably very dangerous unless the user is a Drask."

/obj/item/organ/internal/cyberimp/drask_comfort/process() //Not used for now, seems like a lot of hassle for not much point.
	if(owner.bodytemperature >= 273)
		owner.bodytemperature = (273)