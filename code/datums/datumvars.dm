// reference: /client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)

/**
  * Proc to check if a datum allows proc calls on it
  *
  * Returns TRUE if you can call a proc on the datum, FALSE if you cant
  *
  */
/datum/proc/CanProcCall(procname)
	return TRUE

/datum/proc/can_vv_get(var_name)
	return TRUE

/mob/can_vv_get(var_name)
	var/static/list/protected_vars = list(
		"lastKnownIP", "computer_id", "attack_log_old"
	)
	if(!check_rights(R_ADMIN, FALSE, usr) && (var_name in protected_vars))
		return FALSE
	return TRUE

/client/can_vv_get(var_name)
	var/static/list/protected_vars = list(
		"address", "computer_id", "connection", "jbh", "pm_tracker", "related_accounts_cid", "related_accounts_ip", "watchlisted"
	)
	if(!check_rights(R_ADMIN, FALSE, usr) && (var_name in protected_vars))
		return FALSE
	return TRUE

/datum/proc/vv_edit_var(var_name, var_value) //called whenever a var is edited
	switch(var_name)
		if("vars")
			return FALSE
		if("var_edited")
			return FALSE
	var_edited = TRUE
	vars[var_name] = var_value

	. = TRUE


/client/vv_edit_var(var_name, var_value) //called whenever a var is edited
	switch(var_name)
		// I know we will never be in a world where admins are editing client vars to let people bypass TOS
		// But guess what, if I have the ability to overengineer something, I am going to do it
		if("tos_consent")
			return FALSE
		// Dont fuck with this
		if("cui_entries")
			return FALSE
		// or this
		if("jbh")
			return FALSE
		if("vars")
			return FALSE
		if("var_edited")
			return FALSE
	var_edited = TRUE
	vars[var_name] = var_value

	. = TRUE

/datum/proc/vv_get_var(var_name)
	switch(var_name)
		if("attack_log_old", "debug_log")
			return debug_variable(var_name, vars[var_name], 0, src, sanitize = FALSE)
		if("vars")
			return debug_variable(var_name, list(), 0, src)
	return debug_variable(var_name, vars[var_name], 0, src)

/client/vv_get_var(var_name)
	switch(var_name)
		if("vars")
			return debug_variable(var_name, list(), 0, src)
	return debug_variable(var_name, vars[var_name], 0, src)

/datum/proc/can_vv_delete()
	return TRUE

//please call . = ..() first and append to the result, that way parent items are always at the top and child items are further down
//add seperaters by doing . += "---"
/datum/proc/vv_get_dropdown()
	SHOULD_CALL_PARENT(TRUE)

	. = list()

	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_PROC_CALL, "Call Proc")
	VV_DROPDOWN_OPTION(VV_HK_MARK_OBJECT, "Mark Object")
	VV_DROPDOWN_OPTION(VV_HK_JUMP_TO, "Jump to Object")
	VV_DROPDOWN_OPTION(VV_HK_DELETE, "Delete")
	VV_DROPDOWN_OPTION(VV_HK_TRAITMOD, "Modify Traits")
	VV_DROPDOWN_OPTION(VV_HK_ADDCOMPONENT, "Add Component/Element")
	VV_DROPDOWN_OPTION(VV_HK_REMOVECOMPONENT, "Remove Component/Element")
	VV_DROPDOWN_OPTION(VV_HK_MASSREMOVECOMPONENT, "Mass Remove Component/Element")
	VV_DROPDOWN_OPTION("", "---")

/**
 * This proc is only called if everything topic-wise is verified. The only verifications that should happen here is things like permission checks!
 * href_list is a reference, modifying it in these procs WILL change the rest of the proc in topic.dm of admin/view_variables!
 * This proc is for "high level" actions like admin heal/set species/etc/etc. The low level debugging things should go in admin/view_variables/topic_basic.dm in case this runtimes.
 */
/datum/proc/vv_do_topic(list/href_list)
	if(!usr || !usr.client || !usr.client.holder || !check_rights(R_VAREDIT))
		return FALSE //This is VV, not to be called by anything else.
	if(href_list[VV_HK_MODIFY_TRAITS])
		usr.client.holder.modify_traits(src)

	return TRUE

/datum/proc/vv_get_header()
	. = list()

/client/vv_get_dropdown()
	. = ..()

	VV_DROPDOWN_OPTION(VV_HK_MANIPULATE_COLOR_MATRIX, "Manipulate Color Matrix")
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_PROC_CALL, "Call Proc")
	VV_DROPDOWN_OPTION(VV_HK_MARK_OBJECT, "Mark Object")
	VV_DROPDOWN_OPTION(VV_HK_DELETE, "Delete")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_TRAITS, "Modify Traits")
	VV_DROPDOWN_OPTION("", "---")

/client/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_MANIPULATE_COLOR_MATRIX])
		if(!check_rights(R_DEBUG))
			return

		message_admins("[key_name_admin(usr)] is manipulating the colour matrix for [src]")
		var/datum/ui_module/colour_matrix_tester/CMT = new(target=src)
		CMT.ui_interact(usr)

/client/proc/debug_variables(datum/D in world)
	set name = "\[Admin\] View Variables"

	var/static/cookieoffset = rand(1, 9999) //to force cookies to reset after the round.

	if(!check_rights(R_ADMIN|R_VIEWRUNTIMES))
		to_chat(usr, "<span class='warning'>You need to be an administrator to access this.</span>")
		return

	if(!D)
		return

	var/datum/asset/asset_cache_datum = get_asset_datum(/datum/asset/simple/vv)
	asset_cache_datum.send(usr)

	var/islist = islist(D)
	var/isclient = isclient(D)
	if(!islist && !isclient && !istype(D))
		return

	var/title = ""
	var/icon/sprite
	var/hash
	var/refid

	if(!islist)
		refid = "[D.UID()]"
	else
		refid = "\ref[D]"

	var/type = /list
	if(!islist)
		type = D.type

	if(isatom(D))
		var/atom/A = D
		if(A.icon && A.icon_state)
			sprite = new /icon(A.icon, A.icon_state)
			hash = md5(A.icon)
			hash = md5(hash + A.icon_state)
			usr << browse_rsc(sprite, "vv[hash].png")


	var/sprite_text
	if(sprite)
		sprite_text = "<img src='vv[hash].png'></td><td>"

	var/list/header = islist ? list("<b>/list</b>") : D.vv_get_header()

	var/formatted_type = "[type]"
	if(length(formatted_type) > 25)
		var/middle_point = length(formatted_type) / 2
		var/splitpoint = findtext(formatted_type, "/", middle_point)
		if(splitpoint)
			formatted_type = "[copytext(formatted_type, 1, splitpoint)]<br>[copytext(formatted_type, splitpoint)]"
		else
			formatted_type = "Type too long" //No suitable splitpoint (/) found.


	var/marked
	if(holder.marked_datum && holder.marked_datum == D)
		marked = "<br><font size='1' color='red'><b>Marked Object</b></font>"


	var/varedited_line = ""
	if(isatom(D))
		var/atom/A = D
		if(A.admin_spawned)
			varedited_line += "<br><font size='1' color='red'><b>Admin Spawned</b></font>"


	if(!islist && D.var_edited)
		varedited_line += "<br><font size='1' color='red'><b>Var Edited</b></font>"


	var/list/dropdownoptions = list()
	if(islist)
		dropdownoptions = list(
			"<option>---</option>",
			"<option value='byond://?_src_=vars;listadd=[refid]'>Add Item</option>",
			"<option value='byond://?_src_=vars;listnulls=[refid]'>Remove Nulls</option>",
			"<option value='byond://?_src_=vars;listdupes=[refid]'>Remove Dupes</option>",
			"<option value='byond://?_src_=vars;listlen=[refid]'>Set len</option>",
			"<option value='byond://?_src_=vars;listshuffle=[refid]'>Shuffle</option>"
		)
	else
		dropdownoptions = D.vv_get_dropdown()

	var/list/names = list()
	if(!islist)
		for(var/V in D.vars)
			names += V


	sleep(1) // Without a sleep here, VV sometimes disconnects clients


	var/list/variable_html = list()
	if(islist)
		var/list/L = D
		for(var/i in 1 to length(L))
			var/key = L[i]
			var/value
			if(IS_NORMAL_LIST(L) && !isnum(key))
				value = L[key]
			variable_html += debug_variable(i, value, 0, D)
	else
		names = sortList(names)
		for(var/V in names)
			if(D.can_vv_get(V))
				variable_html += D.vv_get_var(V)

	var/html = {"
<html>
	<head>
		<meta charset="UTF-8">
		<title>[title]</title>
		<link rel="stylesheet" type="text/css" href="[SSassets.transport.get_asset_url("view_variables.css")]">
		[window_scaling ? "<style>body {zoom: [100 / window_scaling]%;}</style>" : ""]
	</head>
	<body onload='selectTextField(); updateSearch()' onkeydown='return checkreload()' onkeyup='updateSearch()'>
		<script type="text/javascript">
			function checkreload() {
				if(event.keyCode == 116){	//F5 (to refresh properly)
					document.getElementById("refresh_link").click();
					event.preventDefault ? event.preventDefault() : (event.returnValue = false)
					return false;
				}
				return true;
			}
			function updateSearch(){
				var filter_text = document.getElementById('filter');
				var filter = filter_text.value.toLowerCase();
				if(event.keyCode == 13){	//Enter / return
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for(var i = 0; i < lis.length; ++i)
					{
						try{
							var li = lis\[i\];
							if(li.style.backgroundColor == "#ffee88")
							{
								alist = lis\[i\].getElementsByTagName("a")
								if(alist.length > 0){
									location.href=alist\[0\].href;
								}
							}
						}catch(err) {   }
					}
					return
				}
				if(event.keyCode == 38){	//Up arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for(var i = 0; i < lis.length; ++i)
					{
						try{
							var li = lis\[i\];
							if(li.className == "var visible" && li.style.backgroundColor == "#ffee88")
							{
								for(var j = i-1; j >= 0; --j) {
									var li_new = lis\[j\];
									if(li_new.className == "var visible") {
										li.style.backgroundColor = "white";
										li_new.style.backgroundColor = "#ffee88";
										return
									}
								}
							}
						}catch(err) {  }
					}
					return
				}
				if(event.keyCode == 40){	//Down arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for(var i = 0; i < lis.length; ++i)
					{
						try{
							var li = lis\[i\];
							if(li.className == "var visible" && li.style.backgroundColor == "#ffee88")
							{
								for(var j = i+1; j < lis.length; ++j) {
									var li_new = lis\[j\];
									if(li_new.className == "var visible") {
										li.style.backgroundColor = "white";
										li_new.style.backgroundColor = "#ffee88";
										return
									}
								}
							}
						}catch(err) {  }
					}
					return
				}

				document.cookie="[refid][cookieoffset]search="+encodeURIComponent(filter);
				var vars_ol = document.getElementById('vars');
				var lis = vars_ol.getElementsByTagName("li");
				var first = true;
				for(var i = 0; i < lis.length; ++i)
				{
					try{
						var li = lis\[i\];
						li.style.backgroundColor = "white";
						if(li.innerText.toLowerCase().indexOf(filter) == -1)
						{
							li.className = "var";
						} else {
							if(first) {
								li.style.backgroundColor = "#ffee88";
								first = false;
							}
							li.className = "var visible";
						}
					}catch(err) {   }
				}
			}
			function selectTextField() {
				var filter_text = document.getElementById('filter');
				filter_text.focus();
				filter_text.select();
				var lastsearch = getCookie("[refid][cookieoffset]search");
				if(lastsearch) {
					filter_text.value = lastsearch;
					updateSearch();
				}
			}
			function loadPage(list) {
				if(list.options\[list.selectedIndex\].value == ""){
					return;
				}
				location.href=list.options\[list.selectedIndex\].value;
			}
			function getCookie(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i=0; i<ca.length; i++) {
					var c = ca\[i\];
					while(c.charAt(0)==' ') c = c.substring(1,c.length);
					if(c.indexOf(name)==0) return c.substring(name.length,c.length);
				}
				return "";
			}

		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[header.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							[marked]
							[varedited_line]
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<a id='refresh_link' href='byond://?_src_=vars;[islist ? "listrefresh=\ref[D]" : "datumrefresh=[D.UID()]"]'>Refresh</a>
							<form>
								<select name="file" size="1"
									onchange="loadPage(this.form.elements\[0\])"
									target="_parent._top"
									onmouseclick="this.focus()"
									style="background-color:#ffffff">
									<option value selected>Select option</option>
									[dropdownoptions.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
			</tr>
		</table>
		<hr>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
		<script type='text/javascript'>
			var vars_ol = document.getElementById("vars");
			var complete_list = vars_ol.innerHTML;
		</script>
	</body>
</html>
	"}

	if(istype(D, /datum))
		log_admin("[key_name(usr)] opened VV for [D] ([D.UID()])")

	var/size_string = window_scaling ? "size=[475 * window_scaling]x[650 * window_scaling]" : "size=[475]x[650]"
	usr << browse(html, "window=variables[refid];[size_string]")

#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )
/proc/debug_variable(name, value, level, datum/owner, sanitize = TRUE)
	var/header
	if(owner)
		if(islist(owner))
			var/list/debug_list = owner
			var/index = name
			if(value)
				name = debug_list[name] // name is really the index until this line
			else
				value = debug_list[name]
			header = "<li class='vars visible'>(<a href='byond://?_src_=vars;listedit=\ref[owner];index=[index]'>E</a>) (<a href='byond://?_src_=vars;listchange=\ref[owner];index=[index]'>C</a>) (<a href='byond://?_src_=vars;listremove=\ref[owner];index=[index]'>-</a>) "
		else
			header = "<li class='vars visible'>(<a href='byond://?_src_=vars;datumedit=[owner.UID()];varnameedit=[name]'>E</a>) (<a href='byond://?_src_=vars;datumchange=[owner.UID()];varnamechange=[name]'>C</a>) (<a href='byond://?_src_=vars;datummass=[owner.UID()];varnamemass=[name]'>M</a>) "
	else
		header = "<li>"

	var/name_part = VV_HTML_ENCODE(name)
	if(level > 0 || islist(owner)) //handling keys in assoc lists
		if(isdatum(name))
			var/datum/datum_key = name
			name_part = "<a href='byond://?_src_=vars;Vars=[datum_key.UID()]'>[VV_HTML_ENCODE(name)] \ref[datum_key]</a>"
		else if(isclient(name))
			var/client/client_key = name
			name_part = "<a href='byond://?_src_=vars;Vars=[client_key.UID()]'>[VV_HTML_ENCODE(client_key)] \ref[client_key]</a> ([client_key] [client_key.type])"
		else if(islist(name))
			var/list/list_value = name
			name_part = "<a href='byond://?_src_=vars;VarsList=\ref[list_value]'> /list ([length(list_value)]) \ref[name]</a>"

	var/item = _debug_variable_value(name, value, level, owner, sanitize)

	return "[header][name_part] = [item]</li>"

/proc/_debug_variable_value(name, value, level, datum/owner, sanitize)

	. = "<font color='red'>DISPLAY_ERROR:</font> ([value] \ref[value]s)"

	if(isnull(value))
		return "<span class='value'>null</span>"

	else if(is_color_text(value))
		return "<span class='value'><span class='colorbox' style='width: 1em; background-color: [value]; border: 1px solid black; display: inline-block'>&nbsp;</span> \"[value]\"</span>"

	else if(istext(value))
		return "<span class='value'>\"[VV_HTML_ENCODE(value)]\"</span>"

	else if(isicon(value))
		#ifdef VARSICON
		return "/icon (<span class='value'>[value]</span>) [bicon(value, use_class=0)]"
		#else
		return "/icon (<span class='value'>[value]</span>)"
		#endif

	else if(istype(value, /image))
		var/image/I = value
		#ifdef VARSICON
		return "<a href='byond://?_src_=vars;Vars=[I.UID()]'>[name] \ref[value]</a> /image (<span class='value'>[value]</span>) [bicon(value, use_class=0)]"
		#else
		return "<a href='byond://?_src_=vars;Vars=[I.UID()]'>[name] \ref[value]</a> /image (<span class='value'>[value]</span>)"
		#endif

	else if(isfile(value))
		return "<span class='value'>'[value]'</span>"

	else if(istype(value, /datum))
		var/datum/D = value
		return D.debug_variable_value(sanitize)

	else if(islist(value))
		var/list/L = value
		var/list/items = list()

		if(length(L) > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || length(L) > (IS_NORMAL_LIST(L) ? 250 : 300)))
			for(var/i in 1 to length(L))
				var/key = L[i]
				var/val
				if(IS_NORMAL_LIST(L) && !isnum(key))
					val = L[key]
				if(isnull(val))
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			return "<a href='byond://?_src_=vars;VarsList=\ref[L]'>/list ([length(L)])</a><ul>[items.Join()]</ul>"

		else
			return "<a href='byond://?_src_=vars;VarsList=\ref[L]'>/list ([length(L)])</a>"

	else if(name in GLOB.bitfields)
		return "<span class='value'>[VV_HTML_ENCODE(translate_bitfield(VV_BITFIELD, name, value))]</span>"
	else
		return "<span class='value'>[VV_HTML_ENCODE(value)]</span>"

/datum/proc/debug_variable_value(sanitize)
	return "<a href='byond://?_src_=vars;Vars=[UID()]'>[VV_HTML_ENCODE(src)] \ref[src]</a> ([type])"

/matrix/debug_variable_value(sanitize)
	return {"<span class='value'>
			<table class='matrixbrak'><tbody><tr><td class='lbrak'>&nbsp;</td><td>
			<table class='matrix'>
			<tbody>
				<tr><td>[a]</td><td>[d]</td><td>0</td></tr>
				<tr><td>[b]</td><td>[e]</td><td>0</td></tr>
				<tr><td>[c]</td><td>[f]</td><td>1</td></tr>
			</tbody>
			</table></td><td class='rbrak'>&nbsp;</td></tr></tbody></table></span>"} //TODO link to modify_transform wrapper for all matrices

/client/proc/view_var_Topic(href, href_list, hsrc)
	//This should all be moved over to datum/admins/Topic() or something ~Carn
	if(!check_rights(R_ADMIN|R_MOD, FALSE) \
		&& !((href_list["datumrefresh"] || href_list["Vars"] || href_list["VarsList"]) && check_rights(R_VIEWRUNTIMES, FALSE)) \
		&& !((href_list["proc_call"]) && check_rights(R_PROCCALL, FALSE)) \
	)
		return // clients with R_VIEWRUNTIMES can still refresh the window/view references/view lists. they cannot edit anything else however.

	if(view_var_Topic_list(href, href_list, hsrc))  // done because you can't use UIDs with lists and I don't want to snowflake into the below check to supress warnings
		return

	// Correct and warn about any VV topic links that aren't using UIDs
	for(var/paramname in href_list)
		if(findtext(href_list[paramname], "]_"))
			continue // Contains UID-specific formatting, skip it
		var/datum/D = locate(href_list[paramname])
		if(!D)
			continue
		var/datuminfo = "[D]"
		if(istype(D))
			datuminfo = datum_info_line(D)
			href_list[paramname] = D.UID()
		else if(isclient(D))
			var/client/C = D
			href_list[paramname] = C.UID()
		stack_trace("Found \\ref-based '[paramname]' param in VV topic for [datuminfo], should be UID: [href]")

	if(href_list["Vars"])
		debug_variables(locateUID(href_list["Vars"]))

	var/target = GET_VV_TARGET
	vv_core_topics(target, href_list, href)
	if(isdatum(target))
		var/datum/D = target
		D.vv_do_topic(href_list)

	// Refresh the VV if something asked us to
	if(href_list["datumrefresh"])
		var/datum/DAT = locateUID(href_list["datumrefresh"])
		if(!istype(DAT, /datum) && !isclient(DAT))
			return
		src.debug_variables(DAT)

/client/proc/view_var_Topic_list(href, href_list, hsrc)
	if(href_list["VarsList"])
		debug_variables(locate(href_list["VarsList"]))
		return TRUE

	if(href_list["listedit"] && href_list["index"])
		var/index = text2num(href_list["index"])
		if(!index)
			return TRUE

		var/list/L = locate(href_list["listedit"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		mod_list(L, null, "list", "contents", index, autodetect_class = TRUE)
		return TRUE

	if(href_list["listchange"] && href_list["index"])
		var/index = text2num(href_list["index"])
		if(!index)
			return TRUE

		var/list/L = locate(href_list["listchange"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		mod_list(L, null, "list", "contents", index, autodetect_class = FALSE)
		return TRUE

	if(href_list["listremove"] && href_list["index"])
		var/index = text2num(href_list["index"])
		if(!index)
			return TRUE

		var/list/L = locate(href_list["listremove"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		var/variable = L[index]
		var/prompt = alert("Do you want to remove item number [index] from list?", "Confirm", "Yes", "No")
		if(prompt != "Yes")
			return
		L.Cut(index, index+1)
		log_world("### ListVarEdit by [src]: /list's contents: REMOVED=[html_encode("[variable]")]")
		log_admin("[key_name(src)] modified list's contents: REMOVED=[variable]")
		message_admins("[key_name_admin(src)] modified list's contents: REMOVED=[variable]")
		return TRUE

	if(href_list["listadd"])
		var/list/L = locate(href_list["listadd"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return TRUE

		mod_list_add(L, null, "list", "contents")
		return TRUE

	if(href_list["listdupes"])
		var/list/L = locate(href_list["listdupes"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return TRUE

		uniqueList_inplace(L)
		log_world("### ListVarEdit by [src]: /list contents: CLEAR DUPES")
		log_admin("[key_name(src)] modified list's contents: CLEAR DUPES")
		message_admins("[key_name_admin(src)] modified list's contents: CLEAR DUPES")
		return TRUE

	if(href_list["listnulls"])
		var/list/L = locate(href_list["listnulls"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return TRUE

		listclearnulls(L)
		log_world("### ListVarEdit by [src]: /list contents: CLEAR NULLS")
		log_admin("[key_name(src)] modified list's contents: CLEAR NULLS")
		message_admins("[key_name_admin(src)] modified list's contents: CLEAR NULLS")
		return TRUE

	if(href_list["listlen"])
		var/list/L = locate(href_list["listlen"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return TRUE
		var/value = vv_get_value(VV_NUM)
		if(value["class"] != VV_NUM)
			return TRUE

		L.len = value["value"]
		log_world("### ListVarEdit by [src]: /list len: [length(L)]")
		log_admin("[key_name(src)] modified list's len: [length(L)]")
		message_admins("[key_name_admin(src)] modified list's len: [length(L)]")
		return TRUE

	if(href_list["listshuffle"])
		var/list/L = locate(href_list["listshuffle"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return TRUE

		shuffle_inplace(L)
		log_world("### ListVarEdit by [src]: /list contents: SHUFFLE")
		log_admin("[key_name(src)] modified list's contents: SHUFFLE")
		message_admins("[key_name_admin(src)] modified list's contents: SHUFFLE")
		return TRUE

	if(href_list["listrefresh"])
		debug_variables(locate(href_list["listrefresh"]))
		return TRUE

/client/proc/debug_global_variables(var_search as text)
	set category = "Debug"
	set name = "Debug Global Variables"

	if(!check_rights(R_ADMIN|R_VIEWRUNTIMES))
		to_chat(usr, "<span class='warning'>You need to be an administrator to access this.</span>")
		return

	var_search = trim(var_search)
	if(!var_search)
		return
	if(!GLOB.can_vv_get(var_search))
		return
	switch(var_search)
		if("vars")
			return FALSE
	if(!(var_search in GLOB.vars))
		to_chat(src, "<span class='debug'>GLOB.[var_search] does not exist.</span>")
		return
	log_and_message_admins("is debugging the Global Variables controller with the search term \"[var_search]\"")
	var/result = GLOB.vars[var_search]
	if(islist(result) || isclient(result) || istype(result, /datum))
		to_chat(src, "<span class='debug'>Now showing GLOB.[var_search].</span>")
		return debug_variables(result)
	to_chat(src, "<span class='debug'>GLOB.[var_search] returned [result].</span>")

#undef VV_HTML_ENCODE
