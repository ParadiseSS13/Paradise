// Для отрисовки ХУД'ов.
GLOBAL_LIST_INIT(Jobs_SS220, list("intern", "cadet", "trainee", "student"))

/proc/get_all_medical_novice_tittles()
	return list("Intern", "Medical Assistant", "Student Medical Doctor")

/proc/get_all_security_novice_tittles()
	return list("Security Cadet", "Security Assistant", "Security Graduate")

/proc/get_all_engineering_novice_tittles()
	return list("Trainee Engineer", "Engineer Assistant", "Technical Assistant", "Engineer Student", "Technical Student", "Technical Trainee")

/proc/get_all_science_novice_tittles()
	return list("Student Scientist", "Scientist Assistant", "Scientist Pregraduate", "Scientist Graduate", "Scientist Postgraduate")

/proc/get_all_novice_tittles()
	return get_all_medical_novice_tittles() + get_all_security_novice_tittles() + get_all_engineering_novice_tittles() + get_all_science_novice_tittles()

/mob/living/carbon/human/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	holder.icon = 'icons/mob/hud/sechud.dmi'
	if(wear_id && (wear_id.get_job_name() in GLOB.Jobs_SS220))
		holder.icon = 'modular_ss220/jobs/icons/hud.dmi'
	. = ..()

/obj/item/get_job_name() //Used in secHUD icon generation
	var/assignmentName = get_ID_assignment(if_no_id = "Unknown")
	var/rankName = get_ID_rank(if_no_id = "Unknown")

	var/novmed = get_all_medical_novice_tittles()
	var/novsec = get_all_security_novice_tittles()
	var/noveng = get_all_engineering_novice_tittles()
	var/novrnd = get_all_science_novice_tittles()

	if((assignmentName in novmed) || (rankName in novmed))
		return "intern"
	if((assignmentName in novsec) || (rankName in novsec))
		return "cadet"
	if((assignmentName in noveng) || (rankName in noveng))
		return "trainee"
	if((assignmentName in novrnd) || (rankName in novrnd))
		return "student"

	. = ..()

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
