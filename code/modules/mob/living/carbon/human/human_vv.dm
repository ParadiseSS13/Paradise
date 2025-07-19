/mob/living/carbon/human/vv_get_dropdown()
	. = ..()

	VV_DROPDOWN_OPTION(VV_HK_MAKE_SKELETON, "Make 2spooky")
	VV_DROPDOWN_OPTION(VV_HK_HALLUCINATE, "Hallucinate")

/mob/living/carbon/human/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_MAKE_SKELETON])
		if(!check_rights(R_SERVER|R_EVENT))
			return

		if(tgui_alert(usr, "Are you sure you want to turn this mob into a skeleton?", "Confirm Skeleton Transformation", list("Yes", "No")) != "Yes")
			return

		makeSkeleton()
		message_admins("[key_name(usr)] has turned [key_name(src)] into a skeleton")
		log_admin("[key_name_admin(usr)] has turned [key_name_admin(src)] into a skeleton")
		href_list["datumrefresh"] = UID()

	if(href_list[VV_HK_HALLUCINATE])
		if(!check_rights(R_SERVER | R_EVENT))
			return

		var/haltype = tgui_input_list(usr, "Select Hallucination Type", "Hallucinate", (subtypesof(/obj/effect/hallucination) + subtypesof(/datum/hallucination_manager)))
		if(!haltype)
			return
		invoke_hallucination(haltype)
		message_admins("[key_name(usr)] has given [key_name(src)] the [haltype] hallucination")
		log_admin("[key_name_admin(usr)] has given [key_name_admin(src)] the [haltype] hallucination")
		href_list["datumrefresh"] = UID()
