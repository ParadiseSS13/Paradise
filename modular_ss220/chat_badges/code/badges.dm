#define CHAT_BADGES_DMI 'modular_ss220/chat_badges/icons/chatbadges.dmi'

GLOBAL_LIST(badge_icons_cache)

/client/proc/get_ooc_badged_name()
	var/icon/donator_badge_icon = get_badge_icon(get_donator_badge())
	var/icon/worker_badge_icon = get_badge_icon(get_worker_badge())

	var/badge_part = "[donator_badge_icon ? bicon(donator_badge_icon) : ""][worker_badge_icon ? bicon(worker_badge_icon) : ""]"
	var/list/parts = list()
	if(badge_part)
		parts += badge_part
	parts += key
	return jointext(parts, " ")

/client/proc/get_donator_badge()
	if(donator_level && (prefs.toggles & PREFTOGGLE_DONATOR_PUBLIC))
		return donator_level > 3 ? "Paradise" : "Trusted"

	if(prefs.unlock_content && (prefs.toggles & PREFTOGGLE_MEMBER_PUBLIC))
		return "Trusted"

/client/proc/get_worker_badge()
	var/static/list/rank_badge_map = list(
		"Максон" = "Wycc",
		"Банда" = "Streamer",
		"Братюня" = "Streamer",
		"Сестрюня" = "Streamer",
		"Хост" = "Host",
		"Ведущий Разработчик" = "HeadDeveloper",
		"Старший Разработчик" = "Developer",
		"Разработчик" = "Developer",
		"Начальный Разработчик" = "MiniDeveloper",
		"Бригадир Мапперов" = "HeadMapper",
		"Маппер" = "Mapper",
		"Спрайтер" = "Spriceter",
		"Маленький Работяга" = "WikiLore",
		"Старший Администратор" = "HeadAdmin",
		"Администратор" = "GameAdmin",
		"Триал Администратор" = "TrialAdmin",
		"Ментор" = "Mentor"
	)
	return rank_badge_map[holder?.rank]

/client/proc/get_badge_icon(badge)
	if(isnull(badge))
		return null
		
	var/icon/badge_icon = LAZYACCESS(GLOB.badge_icons_cache, badge)
	if(isnull(badge_icon))
		badge_icon = icon(CHAT_BADGES_DMI, badge)
		LAZYSET(GLOB.badge_icons_cache, badge, badge_icon)
		
	return badge_icon

#undef CHAT_BADGES_DMI
