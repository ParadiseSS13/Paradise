/datum/browser
	var/mob/user
	var/title
	/// window_id is used as the window name for browse and onclose calls
	var/window_id
	var/width = 0
	var/height = 0
	/// UID of the host atom
	var/atom_uid = null
	/// Various options to control elements such as titlebar buttons for the window
	var/list/window_options = list("focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;") // window option is set using window_id
	/// Assoc list of stylesheets for use by the datum
	var/stylesheets[0]
	/// Assoc list of script files for use by the datum
	var/scripts[0]
	/// Should default stylesheets be loaded
	var/include_default_stylesheet = TRUE
	/// Header HTML content of the browser datum
	var/list/head_content = list()
	/// HTML content of the browser datum
	var/list/content = list()


/datum/browser/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, atom/atom = null)
	if(ismob(nuser))
		user = nuser
	else if(isclient(nuser))
		var/client/user_client = nuser
		user = user_client.mob

	if(!ismob(user))
		user = null

	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(user_deleted))
	window_id = nwindow_id
	if(ntitle)
		title = format_text(ntitle)
	if(nwidth)
		width = nwidth
	if(nheight)
		height = nheight
	if(atom)
		atom_uid = atom.UID()

/datum/browser/proc/user_deleted(datum/source)
	SIGNAL_HANDLER
	user = null

/datum/browser/proc/set_title(ntitle)
	title = islist(ntitle) ? ntitle : list(ntitle)

/datum/browser/proc/add_head_content(nhead_content)
	head_content = islist(nhead_content) ? nhead_content : list(nhead_content)

/datum/browser/proc/set_window_options(nwindow_options)
	window_options = islist(nwindow_options) ? nwindow_options : list(nwindow_options)

/datum/browser/proc/add_stylesheet(name, file)
	if(istype(name, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/sheet = name
		stylesheets["spritesheet_[sheet.name].css"] = "data/spritesheets/[sheet.name]"
	else
		var/asset_name = "[name].css"

		stylesheets[asset_name] = file

		if(!SSassets.cache[asset_name])
			SSassets.transport.register_asset(asset_name, file)

/datum/browser/proc/add_scss_stylesheet(name, file)
	var/asset_name = "[name].scss"
	stylesheets[asset_name] = file

	if(!SSassets.cache[asset_name])
		SSassets.transport.register_asset(asset_name, file)

/datum/browser/proc/add_script(name, file)
	scripts["[ckey(name)].js"] = file
	SSassets.transport.register_asset("[ckey(name)].js", file)

/datum/browser/proc/set_content(ncontent)
	content = islist(ncontent) ? ncontent : list(ncontent)

/datum/browser/proc/add_content(ncontent)
	content += ncontent

/datum/browser/proc/get_header()
	if(include_default_stylesheet)
		head_content += "<link rel='stylesheet' type='text/css' href='[SSassets.transport.get_asset_url("common.css")]'>"

	for(var/file in stylesheets)
		head_content += "<link rel='stylesheet' type='text/css' href='[SSassets.transport.get_asset_url(file)]'>"

	for(var/file in scripts)
		head_content += "<script type='text/javascript' src='[SSassets.transport.get_asset_url(file)]'></script>"

	if(user.client.window_scaling && user.client.window_scaling != 1)
		head_content += {"
			<style>
				body {
					zoom: [100 / user.client.window_scaling]%;
				}
			</style>
			"}

	return {"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
		<meta http-equiv='X-UA-Compatible' content='IE=edge'>
		[head_content.Join("")]
	</head>
	<body scroll=auto>
		<div class='uiWrapper'>
			[title ? "<div class='uiTitleWrapper'><div class='uiTitle'><tt>[title]</tt></div></div>" : ""]
			<div class='uiContent'>
	"}

/datum/browser/proc/get_footer()
	return {"
			</div>
		</div>
	</body>
</html>"}

/datum/browser/proc/get_content()
	return {"
	[get_header()]
	[content.Join("")]
	[get_footer()]
	"}

/datum/browser/proc/open(use_onclose = TRUE)
	if(isnull(window_id)) //null check because this can potentially nuke goonchat
		WARNING("Browser [title] tried to open with a null ID")
		to_chat(user, "<span class='userdanger'>The [title] browser you tried to open failed a sanity check! Please report this on github!</span>")
		return

	var/window_size = ""
	if(width && height)
		window_size = "size=[width]x[height];"
		if(user?.client?.window_scaling)
			window_size = "size=[width * user.client.window_scaling]x[height * user.client.window_scaling];"
		else
			window_size = "size=[width]x[height];"
	if(include_default_stylesheet)
		var/datum/asset/simple/common/common_asset = get_asset_datum(/datum/asset/simple/common)
		common_asset.send(user)
	if(length(stylesheets))
		SSassets.transport.send_assets(user, stylesheets)
	if(length(scripts))
		SSassets.transport.send_assets(user, scripts)
	user << browse(get_content(), "window=[window_id];[window_size][window_options.Join("")]")
	if(use_onclose)
		onclose(user, window_id, atom_uid)

/datum/browser/proc/close()
	if(!isnull(window_id))//null check because this can potentially nuke goonchat
		user << browse(null, "window=[window_id]")
	else
		WARNING("Browser [title] tried to close with a null ID")

/proc/onclose(mob/user, windowid, atom_uid)
	if(!user?.client)
		return

	winset(user, windowid, "on-close=\".windowclose [atom_uid || "null"]\"")

// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid atom uid is supplied, call the atom's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.
//
/client/verb/windowclose(atom_uid as text)
	set hidden = TRUE // hide this verb from the user's panel
	set name = ".windowclose" // no autocomplete on cmd line

	if(atom_uid != "null") // if passed a real atom_uid
		var/hsrc = locateUID(atom_uid) // find the reffed atom
		if(hsrc)
			var/href = "close=1"
			usr = src.mob
			src.Topic(href, params2list(href), hsrc) // this will direct to the atom's
			return // Topic() proc via client.Topic()

	// no atom_uid specified (or not found)
	// so just reset the user mob's machine var
	if(src?.mob)
		src.mob.unset_machine()
