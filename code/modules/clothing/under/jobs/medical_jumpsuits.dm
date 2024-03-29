/obj/item/clothing/under/rank/medical
	icon = 'icons/obj/clothing/under/medical.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/medical.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/medical.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/medical.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/medical.dmi'
		)

/obj/item/clothing/under/rank/medical/chief_medical_officer
	name = "chief medical officer's jumpsuit"
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo"
	item_state = "cmo"
	item_color = "cmo"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt
	name = "chief medical officer's jumpskirt"
	desc = "It's a jumpskirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmof"
	item_color = "cmof"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/doctor
	name = "medical doctor's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "medical"
	item_state = "medical"
	item_color = "medical"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/doctor/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/medical/doctor/skirt
	name = "medical doctor's jumpskirt"
	icon_state = "medicalf"
	item_color = "medicalf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS


/obj/item/clothing/under/rank/medical/virologist
	name = "virologist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	icon_state = "virology"
	item_state = "virology"
	item_color = "virology"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/virologist/skirt
	name = "virologist's jumpskirt"
	icon_state = "virologyf"
	item_color = "virologyf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/nursesuit
	name = "nurse's suit"
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	icon_state = "nursesuit"
	item_state = "nursesuit"
	item_color = "nursesuit"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/nurse
	name = "nurse's dress"
	desc = "A dress commonly worn by the nursing staff in the medical department."
	icon_state = "nurse"
	item_state = "nurse"
	item_color = "nurse"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/orderly
	name = "orderly's uniform"
	desc = "A white suit to be worn by orderly people who love orderly things."
	icon_state = "orderly"
	item_state = "orderly"
	item_color = "orderly"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/scrubs
	name = "blue medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in baby blue."
	icon_state = "scrubsblue"
	item_color = "scrubsblue"

/obj/item/clothing/under/rank/medical/scrubs/green
	name = "green medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in dark green."
	icon_state = "scrubsgreen"
	item_color = "scrubsgreen"

/obj/item/clothing/under/rank/medical/scrubs/purple
	name = "purple medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in deep purple."
	icon_state = "scrubspurple"
	item_color = "scrubspurple"

/obj/item/clothing/under/rank/medical/scrubs/coroner
	name = "coroner's scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is as dark as an emo's poetry."
	icon_state = "scrubsblack"
	item_color = "scrubsblack"

/obj/item/clothing/under/rank/medical/chemist
	name = "chemist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	icon_state = "chemistry"
	item_state = "chemistry"
	item_color = "chemistry"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 95)

/obj/item/clothing/under/rank/medical/chemist/skirt
	name = "chemist's jumpskirt"
	icon_state = "chemistryf"
	item_color = "chemistryf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/paramedic
	name = "paramedic's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards and radiation. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "paramedic"
	item_state = "paramedic"
	item_color = "paramedic"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/psych
	name = "psychiatrist's jumpsuit"
	desc = "A basic white jumpsuit. It has turqouise markings that denote the wearer as a psychiatrist."
	icon_state = "psych"
	item_state = "psych"
	item_color = "psych"

/obj/item/clothing/under/rank/medical/psych/turtleneck
	name = "psychologist's turtleneck"
	desc = "A turqouise turtleneck and a pair of dark blue slacks, belonging to a psychologist."
	icon_state = "psychturtle"
	item_state = "psychturtle"
	item_color = "psychturtle"

/// Seems like it should be here for organisational purposes
/obj/item/clothing/under/rank/medical/gown
	name = "medical gown"
	desc = "a flimsy examination gown, the back ties never close."
	icon_state = "medicalgown"
	item_state = "medicalgown"
	item_color = "medicalgown"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
