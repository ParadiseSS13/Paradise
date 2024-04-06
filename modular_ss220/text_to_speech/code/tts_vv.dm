/client/view_var_Topic(href, href_list, hsrc)
	. = ..()
	if(href_list["changetts"])
		if(!check_rights(R_VAREDIT))
			return
		var/atom/A = locateUID(href_list["changetts"])
		A.change_tts_seed(src.mob, TRUE, TRUE)

/atom/vv_get_dropdown()
	. = ..()
	.["Change TTS"] = "?_src_=vars;changetts=[UID()]"
