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
		if("Максон")
			rank = "Wycc"

		if("Банда", "Братюня", "Сестрюня")
			rank = "Streamer"

		if("Хост")
			rank = "Host"

		if("Ведущий Разработчик")
			rank = "HeadDeveloper"

		if("Старший Разработчик", "Разработчик")
			rank = "Developer"

		if("Начальный Разработчик")
			rank = "MiniDeveloper"

		if("Бригадир Мапперов")
			rank = "HeadMapper"

		if("Маппер")
			rank = "Mapper"

		if("Спрайтер")
			rank = "Spriceter"

		if("Маленький Работяга")
			rank = "WikiLore"

		if("Старший Администратор")
			rank = "HeadAdmin"

		if("Администратор")
			rank = "GameAdmin"

		if("Триал Администратор")
			rank = "TrialAdmin"

		if("Ментор")
			rank = "Mentor"

	var/icon/rank_badge = icon(CHAT_BADGES_DMI, rank)
	. = "[bicon(rank_badge)][.]"

#undef CHAT_BADGES_DMI
