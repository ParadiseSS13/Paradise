#define CHAT_BADGES_DMI 'modular_ss220/chat_badges/icons/chatbadges.dmi'

/client/proc/get_ooc_badged_name()
	. = key
	if(donator_level && (prefs.toggles & PREFTOGGLE_DONATOR_PUBLIC))
		var/icon/donator = icon(CHAT_BADGES_DMI, donator_level > 3 ? "Trusted" : "Paradise")
		. = "[bicon(donator)][.]"

	if(prefs.unlock_content)
		if(prefs.toggles & PREFTOGGLE_MEMBER_PUBLIC)
			var/icon/palm = icon(CHAT_BADGES_DMI, "Trusted")
			. = "[bicon(palm)][.]"

	if(!holder)
		return

	// Config disallows using Russian so this is the way
	var/rank
	switch(holder.rank)
		if("Хост")
			rank = "Host"
		if("Ведущий Разработчик")
			rank = "HeadDeveloper"
		if("Старший Администратор")
			rank = "HeadAdmin"
		if("Банда")
			rank = "Streamer"
		if("Админ")
			rank = "GameAdmin"
		if("Триал Админ")
			rank = "TrialAdmin"
		if("Ментор")
			rank = "Mentor"
		if("Разработчик")
			rank = "Developer"
		if("Маппер")
			rank = "Mapper"
		if("Спрайтер")
			rank = "Spriceter"

	var/icon/rank_badge = icon(CHAT_BADGES_DMI, rank)
	. = "[bicon(rank_badge)][.]"

#undef CHAT_BADGES_DMI
