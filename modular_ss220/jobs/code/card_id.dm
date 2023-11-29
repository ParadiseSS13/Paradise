/mob/living/carbon/human/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	holder.icon = 'icons/mob/hud/sechud.dmi'
	if(wear_id && (wear_id.get_job_name() in GLOB.jobs_positions_ss220))
		holder.icon = 'modular_ss220/jobs/icons/hud.dmi'
	. = ..()

/obj/item/get_job_name() //Used in secHUD icon generation
	var/assignmentName = get_ID_assignment(if_no_id = "Unknown")
	var/rankName = get_ID_rank(if_no_id = "Unknown")

	var/list/titles = GLOB.jobs_positions_ss220

	if(assignmentName in titles) //Check if the job has a hud icon
		return assignmentName
	if(rankName in titles)
		return rankName

	. = ..()

GLOBAL_LIST_INIT(card_skins_ss220, list(
	"intern", "student", "trainee", "cadet",
))

/obj/item/card/id/medical/intern
	name = "Intern ID"
	registered_name = "Intern"
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "intern"
	item_state = "intern-id"
	rank = "Intern"

/obj/item/card/id/research/student
	name = "Student ID"
	registered_name = "Student"
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "student"
	item_state = "student-id"

/obj/item/card/id/engineering/trainee
	name = "Trainee ID"
	registered_name = "Trainee"
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "trainee"
	item_state = "trainee-id"

/obj/item/card/id/security/cadet
	name = "Cadet ID"
	registered_name = "Cadet"
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "cadet"
	item_state = "cadet-id"

/obj/item/card/id/syndicate/Initialize()
	. = ..()
	appearances |= GLOB.card_skins_ss220
