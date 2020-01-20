/**********************************************************
NANO UI FRAMEWORK

nanoui class (or whatever Byond calls classes)

nanoui is used to open and update nano browser uis
**********************************************************/

/datum/nanoui
	// the user who opened this ui
	var/mob/user
	// the object this ui "belongs" to
	var/datum/src_object
	// the title of this ui
	var/title
	// the key of this ui, this is to allow multiple (different) uis for each src_object
	var/ui_key
	// window_id is used as the window name/identifier for browse and onclose
	var/window_id
	// the browser window width
	var/width = 0
	// the browser window height
	var/height = 0
	// whether to use extra logic when window closes
	var/on_close_logic = 1
	// an extra ref to use when the window is closed, usually null
	var/atom/ref = null
	// options for modifying window behaviour
	var/window_options = "focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;" // window option is set using window_id
	// the list of stylesheets to apply to this ui
	var/list/stylesheets = list()
	// the list of javascript scripts to use for this ui
	var/list/scripts = list()
	// a list of templates which can be used with this ui
	var/templates[0]
	// the layout key for this ui (this is used on the frontend, leave it as "default" unless you know what you're doing)
	var/layout_key = "default"
	// this sets whether to re-render the ui layout with each update (default 0, turning on will break the map ui if it's in use)
	var/auto_update_layout = 0
	// this sets whether to re-render the ui content with each update (default 1)
	var/auto_update_content = 1
	// the default state to use for this ui (this is used on the frontend, leave it as "default" unless you know what you're doing)
	var/state_key = "default"
	// show the map ui, this is used by the default layout
	var/show_map = 0
	// the map z level to display
	var/map_z_level = 1
	// initial data, containing the full data structure, must be sent to the ui (the data structure cannot be extended later on)
	var/list/initial_data = null // Initialize as null for proper ! usage in initial set up
	// set to 1 to update the ui automatically every master_controller tick
	var/is_auto_updating = 0
	// the current status/visibility of the ui
	var/status = STATUS_INTERACTIVE

	// Relationship between a master interface and its children. Used in update_status
	var/datum/nanoui/master_ui
	var/list/datum/nanoui/children = list()
	var/datum/topic_state/state = null

 /**
  * Create a new nanoui instance.
  *
  * @param nuser /mob The mob who has opened/owns this ui
  * @param nsrc_object /obj|/mob The obj or mob which this ui belongs to
  * @param nui_key string A string key to use for this ui. Allows for multiple unique uis on one src_oject
  * @param ntemplate string The filename of the template file from /nano/templates (e.g. "my_template.tmpl")
  * @param ntitle string The title of this ui
  * @param nwidth int the width of the ui window
  * @param nheight int the height of the ui window
  * @param nref /atom A custom ref to use if "on_close_logic" is set to 1
  *
  * @return /nanoui new nanoui object
  */
/datum/nanoui/New(nuser, nsrc_object, nui_key, ntemplate_filename, ntitle = 0, nwidth = 0, nheight = 0, var/atom/nref = null, var/datum/nanoui/master_ui = null, var/datum/topic_state/state = default_state)
	user = nuser
	src_object = nsrc_object
	ui_key = nui_key
	window_id = "[ui_key]\ref[src_object]"

	src.master_ui = master_ui
	if(master_ui)
		master_ui.children += src
	src.state = state

	// add the passed template filename as the "main" template, this is required
	add_template("main", ntemplate_filename)

	if(ntitle)
		title = ntitle
	if(nwidth)
		width = nwidth
	if(nheight)
		height = nheight
	if(nref)
		ref = nref

	add_common_assets()

	var/datum/asset/assets = get_asset_datum(/datum/asset/nanoui)
	assets.send(user, ntemplate_filename)

 /**
  * Use this proc to add assets which are common to (and required by) all nano uis
  *
  * @return nothing
  */
/datum/nanoui/proc/add_common_assets()
	add_script("libraries.min.js") // A JS file comprising of jQuery, doT.js and jQuery Timer libraries (compressed together)
	add_script("nano.js")          // A JS file of the NanoUI JavaScript compressed into one file.
	add_stylesheet("nanoui.css")   // Concatenated CSS sheet common to all UIs, contains all of the standard NanoUI styling.

	// CodeMirror
	add_script("codemirror-compressed.js") // A custom minified JavaScript file of CodeMirror, with the following plugins: CSS Mode, NTSL Mode, CSS-hint addon, Search addon, Sublime Keymap.

 /**
  * Set the current status (also known as visibility) of this ui.
  *
  * @param state int The status to set, see the defines at the top of this file
  * @param push_update int (bool) Push an update to the ui to update it's status (an update is always sent if the status has changed to red (0))
  *
  * @return nothing
  */
/datum/nanoui/proc/set_status(state, push_update)
	if(state != status) // Only update if it is different
		if(status == STATUS_DISABLED)
			status = state
			if(push_update)
				update()
		else
			status = state
			if(push_update || status == 0)
				push_data(null, 1) // Update the UI, force the update in case the status is 0, data is null so that previous data is used

 /**
  * Update the status (visibility) of this ui based on the user's status
  *
  * @param push_update int (bool) Push an update to the ui to update it's status. This is set to 0/false if an update is going to be pushed anyway (to avoid unnessary updates)
  *
  * @return nothing
  */
/datum/nanoui/proc/update_status(var/push_update = 0)
	var/new_status = src_object.CanUseTopic(user, state)
	if(master_ui)
		new_status = min(new_status, master_ui.status)

	set_status(new_status, push_update)
	if(new_status == STATUS_CLOSE)
		close()

 /**
  * Set the ui to auto update (every master_controller tick)
  *
  * @param state int (bool) Set auto update to 1 or 0 (true/false)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_auto_update(nstate = 1)
	is_auto_updating = nstate

 /**
  * Set the initial data for the ui. This is vital as the data structure set here cannot be changed when pushing new updates.
  *
  * @param data /list The list of data for this ui
  *
  * @return nothing
  */
/datum/nanoui/proc/set_initial_data(list/data)
	initial_data = data

 /**
  * Get config data to sent to the ui.
  *
  * @return /list config data
  */
/datum/nanoui/proc/get_config_data()
	var/name = "[src_object]"
	var/list/config_data = list(
			"title" = title,
			"map" = (using_map && using_map.name) ? using_map.name : "Unknown",
			"srcObject" = list("name" = name),
			"stateKey" = state_key,
			"status" = status,
			"autoUpdateLayout" = auto_update_layout,
			"autoUpdateContent" = auto_update_content,
			"showMap" = show_map,
			"mapZLevel" = map_z_level,
			"user" = list(
				"name" = user.name,
				"fancy" = user.client.prefs.nanoui_fancy
			),
			"window" = list(
				"width" = width,
				"height" = height,
				"ref" = window_id
			)
		)
	return config_data

 /**
  * Get data to sent to the ui.
  *
  * @param data /list The list of general data for this ui (can be null to use previous data sent)
  *
  * @return /list data to send to the ui
  */
/datum/nanoui/proc/get_send_data(var/list/data)
	var/list/config_data = get_config_data()

	var/list/send_data = list("config" = config_data)

	if(!isnull(data))
		send_data["data"] = data

	return send_data

 /**
  * Set the browser window options for this ui
  *
  * @param nwindow_options string The new window options
  *
  * @return nothing
  */
/datum/nanoui/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

 /**
  * Add a CSS stylesheet to this UI
  * These must be added before the UI has been opened, adding after that will have no effect
  *
  * @param file string The name of the CSS file from /nano/css (e.g. "my_style.css")
  *
  * @return nothing
  */
/datum/nanoui/proc/add_stylesheet(file)
	stylesheets.Add(file)

 /**
  * Add a JavsScript script to this UI
  * These must be added before the UI has been opened, adding after that will have no effect
  *
  * @param file string The name of the JavaScript file from /nano/js (e.g. "my_script.js")
  *
  * @return nothing
  */
/datum/nanoui/proc/add_script(file)
	scripts.Add(file)

 /**
  * Add a template for this UI
  * Templates are combined with the data sent to the UI to create the rendered view
  * These must be added before the UI has been opened, adding after that will have no effect
  *
  * @param key string The key which is used to reference this template in the frontend
  * @param filename string The name of the template file from /nano/templates (e.g. "my_template.tmpl")
  *
  * @return nothing
  */
/datum/nanoui/proc/add_template(key, filename)
	templates[key] = filename

 /**
  * Set the layout key for use in the frontend Javascript
  * The layout key is the basic layout key for the page
  * Two files are loaded on the client based on the layout key varable:
  *     -> a template in /nano/templates with the filename "layout_<layout_key>.tmpl
  *     -> a CSS stylesheet in /nano/css with the filename "layout_<layout_key>.css
  *
  * @param nlayout string The layout key to use
  *
  * @return nothing
  */
/datum/nanoui/proc/set_layout_key(nlayout_key)
	layout_key = lowertext(nlayout_key)

 /**
  * Set the ui to update the layout (re-render it) on each update, turning this on will break the map ui (if it's being used)
  *
  * @param state int (bool) Set update to 1 or 0 (true/false) (default 0)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_auto_update_layout(nstate)
	auto_update_layout = nstate

 /**
  * Set the ui to update the main content (re-render it) on each update
  *
  * @param state int (bool) Set update to 1 or 0 (true/false) (default 1)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_auto_update_content(nstate)
	auto_update_content = nstate

 /**
  * Set the state key for use in the frontend Javascript
  *
  * @param nstate_key string The key of the state to use
  *
  * @return nothing
  */
/datum/nanoui/proc/set_state_key(nstate_key)
	state_key = nstate_key

 /**
  * Toggle showing the map ui
  *
  * @param nstate_key boolean 1 to show map, 0 to hide (default is 0)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_show_map(nstate)
	show_map = nstate

 /**
  * Toggle showing the map ui
  *
  * @param nstate_key boolean 1 to show map, 0 to hide (default is 0)
  *
  * @return nothing
  */
/datum/nanoui/proc/set_map_z_level(nz)
	map_z_level = nz

 /**
  * Set whether or not to use the "old" on close logic (mainly unset_machine())
  *
  * @param state int (bool) Set on_close_logic to 1 or 0 (true/false)
  *
  * @return nothing
  */
/datum/nanoui/proc/use_on_close_logic(state)
	on_close_logic = state

 /**
  * Return the HTML for this UI
  *
  * @return string HTML for the UI
  */
/datum/nanoui/proc/get_html()

	// before the UI opens, add the layout files based on the layout key
	add_template("layout", "layout_[layout_key].tmpl")

	var/head_content = ""

	for(var/filename in scripts)
		head_content += "<script type='text/javascript' src='[filename]'></script> "

	for(var/filename in stylesheets)
		head_content += "<link rel='stylesheet' type='text/css' href='[filename]'> "

	var/template_data_json = "{}" // An empty JSON object
	if(templates.len > 0)
		template_data_json = json_encode(templates)

	var/list/send_data = get_send_data(initial_data)
	var/initial_data_json = replacetext(replacetext(json_encode(send_data), "&#34;", "&amp;#34;"), "'", "&#39;")

	var/url_parameters_json = json_encode(list("src" = UID()))

	return {"
<!DOCTYPE html>
<html>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<script type='text/javascript'>
			function receiveUpdateData(jsonString)
			{
				// We need both jQuery and NanoStateManager to be able to recieve data
				// At the moment any data received before those libraries are loaded will be lost
				if(typeof NanoStateManager != 'undefined' && typeof jQuery != 'undefined')
				{
					NanoStateManager.receiveUpdateData(jsonString);
				}
				else
				{
					alert('browser.recieveUpdateData failed due to jQuery or NanoStateManager being unavailiable.');
				}
			}
		</script>
		[head_content]
	</head>
	<body scroll=auto data-template-data='[template_data_json]' data-url-parameters='[url_parameters_json]' data-initial-data='[initial_data_json]'>
		<div id='uiLayout'>
		</div>
		<noscript>
			<div id='uiNoScript'>
				<h1>Javascript Required</h1>
				<p>Javascript is required in order to use this NanoUI interface.</p>
				<p>Please enable Javascript in Internet Explorer, and restart your game.</p>
			</div>
		</noscript>
	</body>
</html>
	"}

 /**
  * Open this UI
  *
  * @return nothing
  */
/datum/nanoui/proc/open()
	if(!user.client)
		return

	var/window_size = ""
	if(width && height)
		window_size = "size=[width]x[height];"

	update_status(0)
	if(status == STATUS_CLOSE)
		return

	if(!initial_data)
		set_initial_data(src_object.ui_data(user, ui_key, state)) // Get the UI data.

	// Preset the can_rezie and titlebar values on uis if the user has fancy uis set
	// Prevents the ui from flickering when opened
	if(user.client.prefs.nanoui_fancy)
		set_window_options("focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=0;titlebar=0;")

	user << browse(get_html(), "window=[window_id];[window_size][window_options]")
	winset(user, "mapwindow.map", "focus=true") // return keyboard focus to map
	on_close_winset()
	//onclose(user, window_id)
	SSnanoui.ui_opened(src)

/**
 * Reinitialize the UI with
 */
/datum/nanoui/proc/reinitialize(template, list/data)
	if(template)
		add_template("main", template)
	if(data)
		set_initial_data(data)
	open()

 /**
  * Close this UI
  *
  * @return nothing
  */
/datum/nanoui/proc/close()
	is_auto_updating = 0
	SSnanoui.ui_closed(src)
	user << browse(null, "window=[window_id]")
	for(var/datum/nanoui/child in children)
		child.close()

	src_object.on_ui_close(user)

 /**
  * Set the UI window to call the nanoclose verb when the window is closed
  * This allows Nano to handle closed windows
  *
  * @return nothing
  */
/datum/nanoui/proc/on_close_winset()
	if(!user.client)
		return
	var/params = "\ref[src]"

	winset(user, window_id, "on-close=\"nanoclose [params]\"")

 /**
  * Push data to an already open UI window
  *
  * @return nothing
  */
/datum/nanoui/proc/push_data(data, force_push = 0)
	update_status(0)
	if(status == STATUS_DISABLED && !force_push)
		return // Cannot update UI, no visibility

	var/list/send_data = get_send_data(data)

//	to_chat(user, list2json_usecache(send_data))// used for debugging //NANO DEBUG HOOK

	user << output(list2params(list(json_encode(send_data))),"[window_id].browser:receiveUpdateData")

 /**
  * This Topic() proc is called whenever a user clicks on a link within a Nano UI
  * If the UI status is currently STATUS_INTERACTIVE then call the src_object Topic()
  * If the src_object Topic() returns 1 (true) then update all UIs attached to src_object
  *
  * @return nothing
  */
/datum/nanoui/Topic(href, href_list)
	update_status(0) // update the status
	if(status != STATUS_INTERACTIVE || user != usr) // If UI is not interactive or usr calling Topic is not the UI user
		return

	// This is used to toggle the nano map ui
	var/map_update = 0
	if(href_list["showMap"])
		set_show_map(text2num(href_list["showMap"]))
		map_update = 1

	if(href_list["mapZLevel"])
		set_map_z_level(text2num(href_list["mapZLevel"]))
		map_update = 1

	if((src_object && src_object.Topic(href, href_list, 0, state)) || map_update)
		SSnanoui.update_uis(src_object) // update all UIs attached to src_object

 /**
  * Process this UI, updating the entire UI or just the status (aka visibility)
  * This process proc is called by the master_controller
  *
  * @param update string For this UI to update
  *
  * @return nothing
  */
/datum/nanoui/process(update = 0)
	if(!src_object || !user)
		close()
		return

	if(status && (update || is_auto_updating))
		update() // Update the UI (update_status() is called whenever a UI is updated)
	else
		update_status(1) // Not updating UI, so lets check here if status has changed

 /**
  * Update the UI
  *
  * @return nothing
  */
/datum/nanoui/proc/update(var/force_open = 0)
	src_object.ui_interact(user, ui_key, src, force_open, master_ui, state)
