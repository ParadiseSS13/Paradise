//Contains: Engineering department jumpsuits
/obj/item/clothing/under/rank/chief_engineer
	desc = "It's a high visibility jumpsuit given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	name = "chief engineer's jumpsuit"
	icon_state = "chiefengineer"
	item_state = "chief"
	item_color = "chief"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 10, "fire" = 80, "acid" = 40)
	resistance_flags = NONE

/obj/item/clothing/under/rank/chief_engineer/skirt
	desc = "It's a high visibility jumpskirt given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	name = "chief engineer's jumpskirt"
	icon_state = "chieff"
	item_color = "chieff"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/atmospheric_technician
	desc = "It's a jumpsuit worn by atmospheric technicians."
	name = "atmospheric technician's jumpsuit"
	icon_state = "atmos"
	item_state = "atmos_suit"
	item_color = "atmos"
	resistance_flags = NONE

/obj/item/clothing/under/rank/atmospheric_technician/skirt
	desc = "It's a jumpskirt worn by atmospheric technicians."
	name = "atmospheric technician's jumpskirt"
	icon_state = "atmosf"
	item_color = "atmosf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineer
	desc = "It's an orange high visibility jumpsuit worn by engineers. It has minor radiation shielding."
	name = "engineer's jumpsuit"
	icon_state = "engine"
	item_state = "engi_suit"
	item_color = "engine"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 10, "fire" = 60, "acid" = 20)
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineer/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/engineer/trainee
	name = "engineer trainee jumpsuit"
	icon_state = "trainee_s"
	item_color = "trainee"

/obj/item/clothing/under/rank/engineer/trainee/skirt
	name = "engineer trainee jumpskirt"
	icon_state = "traineef_s"
	item_color = "traineef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineer/trainee/assistant
	name = "engineer assistant jumpsuit"
	icon_state = "eng_ass_s"
	item_color = "eng_ass"

/obj/item/clothing/under/rank/engineer/trainee/assistant/skirt
	name = "engineer assistant jumpskirt"
	icon_state = "eng_ass_f_s"
	item_color = "eng_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineer/skirt
	desc = "It's an orange high visibility jumpskirt worn by engineers. It has minor radiation shielding."
	name = "engineer's jumpskirt"
	icon_state = "enginef"
	item_color = "enginef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/roboticist
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	name = "roboticist's jumpsuit"
	icon_state = "robotics"
	item_state = "robotics"
	item_color = "robotics"
	resistance_flags = NONE

/obj/item/clothing/under/rank/roboticist/student
	name = "student robotist jumpsuit"	//What a good time to add a cute sprite here.

/obj/item/clothing/under/rank/roboticist/skirt
	desc = "It's a slimming black jumpskirt with reinforced seams; great for industrial work."
	name = "roboticist's jumpskirt"
	icon_state = "roboticsf"
	item_color = "roboticsf"

/obj/item/clothing/under/rank/roboticist/skirt/student
	name = "student robotist jumpskirt"	//And here too.

/obj/item/clothing/under/rank/mechanic
	desc = "It's a pair of overalls worn by mechanics."
	name = "mechanic's overalls"
	icon_state = "mechanic"
	item_state = "mechanic"
	item_color = "mechanic"
