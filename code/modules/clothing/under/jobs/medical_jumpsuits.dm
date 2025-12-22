/obj/item/clothing/under/rank/medical
	icon = 'icons/obj/clothing/under/medical.dmi'
	worn_icon = 'icons/mob/clothing/under/medical.dmi'
	inhand_icon_state = "nursesuit"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/medical.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/medical.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/medical.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/medical.dmi'
	)

/obj/item/clothing/under/rank/medical/cmo
	name = "chief medical officer's uniform"
	desc = "It's a blue dress shirt and black slacks worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/medical/cmo/skirt
	name = "chief medical officer's skirt"
	desc = "It's a blue dress shirt and black skirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/cmo/turtleneck
	name = "chief medical officer's turtleneck"
	desc = "A fancy turtleneck designed to keep the wearer cozy in a cold medical bay. Due to budget cuts, the material does not offer any external protection."
	icon_state = "cmo_turtle"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/doctor
	name = "medical doctor's jumpsuit"
	desc = "It's made of a special fiber that provides protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "medical"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/medical/doctor/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/medical/doctor/skirt
	name = "medical doctor's jumpskirt"
	icon_state = "medicalf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/virologist
	name = "virologist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	icon_state = "virology"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/medical/virologist/skirt
	name = "virologist's jumpskirt"
	icon_state = "virologyf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/nursesuit
	name = "nurse's suit"
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	icon_state = "nursesuit"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/medical/nurse
	name = "nurse's dress"
	desc = "A dress commonly worn by the nursing staff in the medical department."
	icon_state = "nurse"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/medical/orderly
	name = "orderly's uniform"
	desc = "A white suit to be worn by orderly people who love orderly things."
	icon_state = "orderly"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/medical/scrubs
	name = "blue medical scrubs"
	desc = "It's made of a special fiber that provides protection against biohazards. This one is in baby blue."
	icon_state = "scrubsblue"
	permeability_coefficient = 0.1

/obj/item/clothing/under/rank/medical/scrubs/green
	name = "green medical scrubs"
	desc = "It's made of a special fiber that provides protection against biohazards. This one is in dark green."
	icon_state = "scrubsgreen"

/obj/item/clothing/under/rank/medical/scrubs/purple
	name = "purple medical scrubs"
	desc = "It's made of a special fiber that provides protection against biohazards. This one is in deep purple."
	icon_state = "scrubspurple"

/obj/item/clothing/under/rank/medical/scrubs/coroner
	name = "coroner's scrubs"
	desc = "It's made of a special fiber that provides protection against biohazards. This one is as dark as an emo's poetry."
	icon_state = "scrubsblack"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/rank/medical/chemist
	name = "chemist's jumpsuit"
	desc = "It's made of a special fiber that gives minor protection against biohazards. It has a chemist rank stripe on it."
	icon_state = "chemistry"
	permeability_coefficient = 0.3
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 95)

/obj/item/clothing/under/rank/medical/chemist/skirt
	name = "chemist's jumpskirt"
	icon_state = "chemistryf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/paramedic
	name = "paramedic's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards and radiation. It has a cross on the back denoting that the wearer is trained medical personnel."
	icon_state = "paramedic"
	permeability_coefficient = 0.3
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/paramedic/skirt
	name = "paramedic's jumpskirt"
	icon_state = "paramedic_skirt"

/obj/item/clothing/under/rank/medical/psych
	name = "psychiatrist's jumpsuit"
	desc = "A basic white jumpsuit. It has turqouise markings that denote the wearer as a psychiatrist."
	icon_state = "psych"

/obj/item/clothing/under/rank/medical/psych/turtleneck
	name = "psychologist's turtleneck"
	desc = "A turqouise turtleneck and a pair of dark blue slacks, belonging to a psychologist."
	icon_state = "psychturtle"

/// Seems like it should be here for organisational purposes
/obj/item/clothing/under/rank/medical/gown
	name = "medical gown"
	desc = "a flimsy examination gown, the back ties never close."
	icon_state = "medicalgown"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
