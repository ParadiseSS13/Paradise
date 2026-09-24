//Disposal delivery helpers
//Just slap em above sorting junction and they will set their sorting tag by themselves
/obj/effect/mapping_helpers/sortjunc_helper
	icon_state = "mail_sorting"
	late = TRUE
	var/sort_type = list()

/obj/effect/mapping_helpers/sortjunc_helper/Initialize(mapload)
	. = ..()
	var/obj/structure/disposalpipe/sortjunction/mail_sorter = locate(/obj/structure/disposalpipe/sortjunction) in loc
	if(mail_sorter)
		mail_sorter.sort_type = sort_type
		mail_sorter.update_appearance(UPDATE_NAME|UPDATE_DESC)
	else
		log_world("[src] failed to find a sorting junction pipe at [AREACOORD(src)]")
	qdel(src)

#define MAILSORTINGHELPERS(helper_type, sort_id, icon) \
	/obj/effect/mapping_helpers/sortjunc_helper/##helper_type { \
		sort_type = sort_id; \
		icon_state = icon; \
	}

MAILSORTINGHELPERS(disposals, list(TAGGER_LOCATION_DISPOSALS), "mail_sorting_sup")
MAILSORTINGHELPERS(cargo_bay, list(TAGGER_LOCATION_CARGO_BAY), "mail_sorting_sup")
MAILSORTINGHELPERS(qm_office, list(TAGGER_LOCATION_QM_OFFICE), "mail_sorting_com")
MAILSORTINGHELPERS(engineering, list(TAGGER_LOCATION_ENGINEERING), "mail_sorting_eng")
MAILSORTINGHELPERS(ce_office, list(TAGGER_LOCATION_CE_OFFICE), "mail_sorting_com")
MAILSORTINGHELPERS(atmospherics, list(TAGGER_LOCATION_ATMOSPHERICS), "mail_sorting_eng")
MAILSORTINGHELPERS(hos_office, list(TAGGER_LOCATION_HOS_OFFICE), "mail_sorting_com")
MAILSORTINGHELPERS(security, list(TAGGER_LOCATION_SECURITY), "mail_sorting_sec")
MAILSORTINGHELPERS(medbay, list(TAGGER_LOCATION_MEDBAY), "mail_sorting_med")
MAILSORTINGHELPERS(cmo_office, list(TAGGER_LOCATION_CMO_OFFICE), "mail_sorting_com")
MAILSORTINGHELPERS(chemistry, list(TAGGER_LOCATION_CHEMISTRY), "mail_sorting_med")
MAILSORTINGHELPERS(research, list(TAGGER_LOCATION_RESEARCH), "mail_sorting_sci")
MAILSORTINGHELPERS(rd_office, list(TAGGER_LOCATION_RD_OFFICE), "mail_sorting_com")
MAILSORTINGHELPERS(robotics, list(TAGGER_LOCATION_ROBOTICS), "mail_sorting_sci")
MAILSORTINGHELPERS(hop_office, list(TAGGER_LOCATION_HOP_OFFICE), "mail_sorting_com")
MAILSORTINGHELPERS(library, list(TAGGER_LOCATION_LIBRARY), "mail_sorting_serv")
MAILSORTINGHELPERS(chapel, list(TAGGER_LOCATION_CHAPEL), "mail_sorting_serv")
MAILSORTINGHELPERS(captains_office, list(TAGGER_LOCATION_CAPTAIN_OFFICE), "mail_sorting_com")
MAILSORTINGHELPERS(bar, list(TAGGER_LOCATION_BAR), "mail_sorting_serv")
MAILSORTINGHELPERS(kitchen, list(TAGGER_LOCATION_KITCHEN), "mail_sorting_serv")
MAILSORTINGHELPERS(hydroponics, list(TAGGER_LOCATION_HYDROPONICS), "mail_sorting_serv")
MAILSORTINGHELPERS(janitor, list(TAGGER_LOCATION_JANITOR), "mail_sorting_serv")
MAILSORTINGHELPERS(genetics, list(TAGGER_LOCATION_GENETICS), "mail_sorting_sci")
MAILSORTINGHELPERS(detective, list(TAGGER_LOCATION_DETECTIVE), "mail_sorting_sec")
MAILSORTINGHELPERS(morgue, list(TAGGER_LOCATION_MORGUE), "mail_sorting_med")

#undef MAILSORTINGHELPERS
