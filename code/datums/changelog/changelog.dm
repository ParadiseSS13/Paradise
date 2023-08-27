GLOBAL_DATUM(changelog_tgui, /datum/ui_module/changelog)
GLOBAL_VAR_INIT(changelog_hash, "")

/datum/ui_module/changelog
	var/static/list/changelog_items = list()
	name = "Changelog"

/datum/ui_module/changelog/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "Changelog", name, 800, 600, master_ui, state)
		ui.open()

/datum/ui_module/changelog/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "get_month")
		var/datum/asset/changelog_item/changelog_item = changelog_items[params["date"]]
		if (!changelog_item)
			changelog_item = new /datum/asset/changelog_item(params["date"])
			changelog_items[params["date"]] = changelog_item
		return changelog_item.send(usr)

/datum/ui_module/changelog/ui_static_data(mob/user)
	var/list/data = list( "dates" = list() )
	var/regex/ymlRegex = regex(@"\.yml", "g")

	for(var/archive_file in sortTim(flist("html/changelogs/archive/"), cmp = /proc/cmp_text_asc))
		var/archive_date = ymlRegex.Replace(archive_file, "")
		data["dates"] = list(archive_date) + data["dates"]

	return data


/client/verb/changelog()
	set name = "Changelog"
	set category = "OOC"
	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/ui_module/changelog()

	GLOB.changelog_tgui.ui_interact(mob)
	if(GLOB.changelog_hash && prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences(src)
		winset(src, "rpane.changelog", "font-style=;")
