#define VV_HK_CHANGETTS "changetts"

/atom/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_CHANGETTS, "Change TTS")

/client/view_var_Topic(href, href_list, hsrc)
	. = ..()
	if(href_list[VV_HK_CHANGETTS])
		if(!check_rights(R_VAREDIT))
			return
		var/atom/A = GET_VV_TARGET
		A.change_tts_seed(src.mob, TRUE, TRUE)

#undef VV_HK_CHANGETTS
