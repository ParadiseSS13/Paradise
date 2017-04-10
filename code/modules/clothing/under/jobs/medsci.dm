/*
 * Science
 */
/obj/item/clothing/under/rank/research_director
	desc = "It's a jumpsuit worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	name = "research director's jumpsuit"
	icon_state = "director"
	item_state = "g_suit"
	item_color = "director"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 10, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/scientist
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has markings that denote the wearer as a scientist."
	name = "scientist's jumpsuit"
	icon_state = "toxins"
	item_state = "w_suit"
	item_color = "toxinswhite"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 10, bio = 0, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/scientist/skirt
	name = "scientist's jumpskirt"
	icon_state = "sciencewhitef"
	item_color = "sciencewhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags_size = null

/obj/item/clothing/under/rank/chemist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	name = "chemist's jumpsuit"
	icon_state = "chemistry"
	item_state = "w_suit"
	item_color = "chemistrywhite"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/chemist/skirt
	name = "chemist's jumpskirt"
	icon_state = "chemistrywhitef"
	item_color = "chemistrywhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags_size = null

/*
 * Medical
 */
/obj/item/clothing/under/rank/chief_medical_officer
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	name = "chief medical officer's jumpsuit"
	icon_state = "cmo"
	item_state = "w_suit"
	item_color = "cmo"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/chief_medical_officer/skirt
	desc = "It's a jumpskirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	name = "chief medical officer's jumpskirt"
	icon_state = "cmof"
	item_color = "cmof"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags_size = null

/obj/item/clothing/under/rank/geneticist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	name = "geneticist's jumpsuit"
	icon_state = "genetics"
	item_state = "w_suit"
	item_color = "geneticswhite"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/geneticist/skirt
	name = "geneticist's jumpskirt"
	icon_state = "geneticswhitef"
	item_color = "geneticswhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags_size = null

/obj/item/clothing/under/rank/virologist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	name = "virologist's jumpsuit"
	icon_state = "virology"
	item_state = "w_suit"
	item_color = "virologywhite"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/virologist/skirt
	name = "virologist's jumpskirt"
	icon_state = "virologywhitef"
	item_color = "virologywhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags_size = null

/obj/item/clothing/under/rank/nursesuit
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	name = "nurse's suit"
	icon_state = "nursesuit"
	item_state = "nursesuit"
	item_color = "nursesuit"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/nurse
	desc = "A dress commonly worn by the nursing staff in the medical department."
	name = "nurse's dress"
	icon_state = "nurse"
	item_state = "nurse"
	item_color = "nurse"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/orderly
	desc = "A white suit to be worn by orderly people who love orderly things."
	name = "orderly's uniform"
	icon_state = "orderly"
	item_state = "orderly"
	item_color = "orderly"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/medical
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	name = "medical doctor's jumpsuit"
	icon_state = "medical"
	item_state = "w_suit"
	item_color = "medical"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/medical/skirt
	name = "medical doctor's jumpskirt"
	icon_state = "medicalf"
	item_color = "medicalf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags_size = null

/obj/item/clothing/under/rank/medical/blue
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in baby blue."
	icon_state = "scrubsblue"
	item_color = "scrubsblue"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/medical/green
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in dark green."
	icon_state = "scrubsgreen"
	item_color = "scrubsgreen"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/medical/purple
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in deep purple."
	icon_state = "scrubspurple"
	item_color = "scrubspurple"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/medical/mortician
	name = "coroner's scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is as dark as an emo's poetry."
	icon_state = "scrubsblack"
	item_color = "scrubsblack"
	flags_size = ONESIZEFITSALL

//paramedic
/obj/item/clothing/under/rank/medical/paramedic
	desc = "It's made of a special fiber that provides minor protection against biohazards and radiation. It has a cross on the chest denoting that the wearer is trained medical personnel."
	name = "paramedic's jumpsuit"
	icon_state = "paramedic"
	item_state = "paramedic"
	item_color = "paramedic"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 10)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/psych
	desc = "A basic white jumpsuit. It has turqouise markings that denote the wearer as a psychiatrist."
	name = "psychiatrist's jumpsuit"
	icon_state = "psych"
	item_state = "w_suit"
	item_color = "psych"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/psych/turtleneck
	desc = "A turqouise turtleneck and a pair of dark blue slacks, belonging to a psychologist."
	name = "psychologist's turtleneck"
	icon_state = "psychturtle"
	item_state = "b_suit"
	item_color = "psychturtle"
	flags_size = ONESIZEFITSALL


/*
 * Medsci, unused (i think) stuff
 */
/obj/item/clothing/under/rank/geneticist_new
	desc = "It's made of a special fiber which provides minor protection against biohazards."
	name = "geneticist's jumpsuit"
	icon_state = "genetics_new"
	item_state = "w_suit"
	item_color = "genetics_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/chemist_new
	desc = "It's made of a special fiber which provides minor protection against biohazards."
	name = "chemist's jumpsuit"
	icon_state = "chemist_new"
	item_state = "w_suit"
	item_color = "chemist_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/scientist_new
	desc = "Made of a special fiber that gives special protection against biohazards and small explosions."
	name = "scientist's jumpsuit"
	icon_state = "scientist_new"
	item_state = "w_suit"
	item_color = "scientist_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 10, bio = 0, rad = 0)
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/rank/virologist_new
	desc = "Made of a special fiber that gives increased protection against biohazards."
	name = "virologist's jumpsuit"
	icon_state = "virologist_new"
	item_state = "w_suit"
	item_color = "virologist_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	flags_size = ONESIZEFITSALL
