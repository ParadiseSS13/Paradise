// reference: /client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)

/client/proc/debug_variables(datum/D in world)
	set category = "Debug"
	set name = "View Variables"
	//set src in world


	if(!usr.client || !usr.client.holder)
		to_chat(usr, "<span class='warning'>You need to be an administrator to access this.</span>")
		return


	var/title = ""
	var/list/body = list()

	if(!D)	return
	if(istype(D, /atom))
		var/atom/A = D
		title = "[A.name] (\ref[A]) = [A.type]"

		#ifdef VARSICON
		if(A.icon)
			body += debug_variable("icon", new/icon(A.icon, A.icon_state, A.dir), 0)
		#endif

	var/sprite

	if(istype(D,/atom))
		var/atom/AT = D
		if(AT.icon && AT.icon_state)
			sprite = 1

	title = "[D] (\ref[D]) = [D.type]"

	body += {"<script type="text/javascript">

				function updateSearch(){
					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(event.keyCode == 13){	//Enter / return
						var vars_ol = document.getElementById('vars');
						var lis = vars_ol.getElementsByTagName("li");
						for( var i = 0; i < lis.length; ++i )
						{
							try{
								var li = lis\[i\];
								if( li.style.backgroundColor == "#ffee88" )
								{
									alist = lis\[i\].getElementsByTagName("a")
									if(alist.length > 0){
										location.href=alist\[0\].href;
									}
								}
							}catch(err) {	 }
						}
						return
					}

					if(event.keyCode == 38){	//Up arrow
						var vars_ol = document.getElementById('vars');
						var lis = vars_ol.getElementsByTagName("li");
						for( var i = 0; i < lis.length; ++i )
						{
							try{
								var li = lis\[i\];
								if( li.style.backgroundColor == "#ffee88" )
								{
									if( (i-1) >= 0){
										var li_new = lis\[i-1\];
										li.style.backgroundColor = "white";
										li_new.style.backgroundColor = "#ffee88";
										return
									}
								}
							}catch(err) {	}
						}
						return
					}

					if(event.keyCode == 40){	//Down arrow
						var vars_ol = document.getElementById('vars');
						var lis = vars_ol.getElementsByTagName("li");
						for( var i = 0; i < lis.length; ++i )
						{
							try{
								var li = lis\[i\];
								if( li.style.backgroundColor == "#ffee88" )
								{
									if( (i+1) < lis.length){
										var li_new = lis\[i+1\];
										li.style.backgroundColor = "white";
										li_new.style.backgroundColor = "#ffee88";
										return
									}
								}
							}catch(err) {	}
						}
						return
					}

					//This part here resets everything to how it was at the start so the filter is applied to the complete list. Screw efficiency, it's client-side anyway and it only looks through 200 or so variables at maximum anyway (mobs).
					if(complete_list != null && complete_list != ""){
						var vars_ol1 = document.getElementById("vars");
						vars_ol1.innerHTML = complete_list
					}

					if(filter.value == ""){
						return;
					}else{
						var vars_ol = document.getElementById('vars');
						var lis = vars_ol.getElementsByTagName("li");

						for( var i = 0; i < lis.length; ++i )
						{
							try{
								var li = lis\[i\];
								if( li.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									vars_ol.removeChild(li);
									i--;
								}
							}catch(err) {	 }
						}
					}
					var lis_new = vars_ol.getElementsByTagName("li");
					for( var j = 0; j < lis_new.length; ++j )
					{
						var li1 = lis\[j\];
						if(j == 0){
							li1.style.backgroundColor = "#ffee88";
						}else{
							li1.style.backgroundColor = "white";
						}
					}
				}



				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();

				}

				function loadPage(list) {

					if(list.options\[list.selectedIndex\].value == ""){
						return;
					}

					location.href=list.options\[list.selectedIndex\].value;

				}
			</script> "}

	body += "<body onload='selectTextField(); updateSearch()' onkeyup='updateSearch()'>"

	body += "<div align='center'><table width='100%'><tr><td width='50%'>"

	if(sprite)
		body += "<table align='center' width='100%'><tr><td>[bicon(D, use_class=0)]</td><td>"
	else
		body += "<table align='center' width='100%'><tr><td>"

	body += "<div align='center'>"

	if(istype(D,/atom))
		var/atom/A = D
		if(isliving(A))
			body += "<a href='?_src_=vars;rename=[D.UID()]'><b>[D]</b></a>"
			if(A.dir)
				body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=[D.UID()];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=[D.UID()];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=[D.UID()];rotatedir=right'>>></a></font>"
			var/mob/living/M = A
			body += "<br><font size='1'><a href='?_src_=vars;datumedit=[D.UID()];varnameedit=ckey'>[M.ckey ? M.ckey : "No ckey"]</a> / <a href='?_src_=vars;datumedit=[D.UID()];varnameedit=real_name'>[M.real_name ? M.real_name : "No real name"]</a></font>"
			body += {"
			<br><font size='1'>
			BRUTE:<font size='1'><a href='?_src_=vars;mobToDamage=[D.UID()];adjustDamage=brute'>[M.getBruteLoss()]</a>
			FIRE:<font size='1'><a href='?_src_=vars;mobToDamage=[D.UID()];adjustDamage=fire'>[M.getFireLoss()]</a>
			TOXIN:<font size='1'><a href='?_src_=vars;mobToDamage=[D.UID()];adjustDamage=toxin'>[M.getToxLoss()]</a>
			OXY:<font size='1'><a href='?_src_=vars;mobToDamage=[D.UID()];adjustDamage=oxygen'>[M.getOxyLoss()]</a>
			CLONE:<font size='1'><a href='?_src_=vars;mobToDamage=[D.UID()];adjustDamage=clone'>[M.getCloneLoss()]</a>
			BRAIN:<font size='1'><a href='?_src_=vars;mobToDamage=[D.UID()];adjustDamage=brain'>[M.getBrainLoss()]</a>
			</font>


			"}
		else
			body += "<a href='?_src_=vars;datumedit=[D.UID()];varnameedit=name'><b>[D]</b></a>"
			if(A.dir)
				body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=[D.UID()];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=[D.UID()];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=[D.UID()];rotatedir=right'>>></a></font>"
	else
		body += "<b>[D]</b>"

	body += "</div>"

	body += "</tr></td></table>"

	var/formatted_type = text("[D.type]")
	if(length(formatted_type) > 25)
		var/middle_point = length(formatted_type) / 2
		var/splitpoint = findtext(formatted_type,"/",middle_point)
		if(splitpoint)
			formatted_type = "[copytext(formatted_type,1,splitpoint)]<br>[copytext(formatted_type,splitpoint)]"
		else
			formatted_type = "Type too long" //No suitable splitpoint (/) found.

	body += "<div align='center'><b><font size='1'>[formatted_type]</font></b>"

	if(src.holder && src.holder.marked_datum && src.holder.marked_datum == D)
		body += "<br><font size='1' color='red'><b>Marked Object</b></font>"

	body += "</div>"

	body += "</div></td>"

	body += "<td width='50%'><div align='center'><a href='?_src_=vars;datumrefresh=[D.UID()]'>Refresh</a>"

	body += {"	<form>
				<select name="file" size="1"
				onchange="loadPage(this.form.elements\[0\])"
				target="_parent._top"
				onmouseclick="this.focus()"
				style="background-color:#ffffff">
			"}

	body += {"	<option value>Select option</option>
				<option value> </option>
			"}


	body += "<option value='?_src_=vars;mark_object=[D.UID()]'>Mark Object</option>"
	body += "<option value='?_src_=vars;proc_call=[D.UID()]'>Call Proc</option>"
	body += "<option value='?_src_=vars;jump_to=[D.UID()]'>Jump to Object</option>"
	if(ismob(D))
		body += "<option value='?_src_=vars;mob_player_panel=[D.UID()]'>Show player panel</option>"

	body += "<option value>---</option>"

	if(ismob(D))
		body += "<option value='?_src_=vars;give_spell=[D.UID()]'>Give Spell</option>"
		body += "<option value='?_src_=vars;give_disease=[D.UID()]'>Give Disease</option>"
		body += "<option value='?_src_=vars;godmode=[D.UID()]'>Toggle Godmode</option>"
		body += "<option value='?_src_=vars;build_mode=[D.UID()]'>Toggle Build Mode</option>"

		body += "<option value='?_src_=vars;make_skeleton=[D.UID()]'>Make 2spooky</option>"

		body += "<option value='?_src_=vars;direct_control=[D.UID()]'>Assume Direct Control</option>"
		body += "<option value='?_src_=vars;offer_control=[D.UID()]'>Offer Control to Ghosts</option>"
		body += "<option value='?_src_=vars;drop_everything=[D.UID()]'>Drop Everything</option>"

		body += "<option value='?_src_=vars;regenerateicons=[D.UID()]'>Regenerate Icons</option>"
		body += "<option value='?_src_=vars;addlanguage=[D.UID()]'>Add Language</option>"
		body += "<option value='?_src_=vars;remlanguage=[D.UID()]'>Remove Language</option>"
		body += "<option value='?_src_=vars;addorgan=[D.UID()]'>Add Organ</option>"
		body += "<option value='?_src_=vars;remorgan=[D.UID()]'>Remove Organ</option>"

		body += "<option value='?_src_=vars;fix_nano=[D.UID()]'>Fix NanoUI</option>"

		body += "<option value='?_src_=vars;addverb=[D.UID()]'>Add Verb</option>"
		body += "<option value='?_src_=vars;remverb=[D.UID()]'>Remove Verb</option>"
		if(ishuman(D))
			body += "<option value>---</option>"
			body += "<option value='?_src_=vars;setspecies=[D.UID()]'>Set Species</option>"
			body += "<option value='?_src_=vars;makeai=[D.UID()]'>Make AI</option>"
			body += "<option value='?_src_=vars;makemask=[D.UID()]'>Make Mask of Nar'sie</option>"
			body += "<option value='?_src_=vars;makerobot=[D.UID()]'>Make cyborg</option>"
			body += "<option value='?_src_=vars;makemonkey=[D.UID()]'>Make monkey</option>"
			body += "<option value='?_src_=vars;makealien=[D.UID()]'>Make alien</option>"
			body += "<option value='?_src_=vars;makeslime=[D.UID()]'>Make slime</option>"
			body += "<option value='?_src_=vars;makesuper=[D.UID()]'>Make superhero</option>"
		body += "<option value>---</option>"
		body += "<option value='?_src_=vars;gib=[D.UID()]'>Gib</option>"
	if(isobj(D))
		body += "<option value='?_src_=vars;delall=[D.UID()]'>Delete all of type</option>"
	if(isobj(D) || ismob(D) || isturf(D))
		body += "<option value='?_src_=vars;addreagent=[D.UID()]'>Add reagent</option>"
		body += "<option value='?_src_=vars;explode=[D.UID()]'>Trigger explosion</option>"
		body += "<option value='?_src_=vars;emp=[D.UID()]'>Trigger EM pulse</option>"

	body += "</select></form>"

	body += "</div></td></tr></table></div><hr>"

	body += "<font size='1'><b>E</b> - Edit, tries to determine the variable type by itself.<br>"
	body += "<b>C</b> - Change, asks you for the var type first.<br>"
	body += "<b>M</b> - Mass modify: changes this variable for all objects of this type.</font><br>"

	body += "<hr><table width='100%'><tr><td width='20%'><div align='center'><b>Search:</b></div></td><td width='80%'><input type='text' id='filter' name='filter_text' value='' style='width:100%;'></td></tr></table><hr>"

	body += "<ol id='vars'>"

	var/list/names = list()
	for(var/V in D.vars)
		names += V

	names = sortList(names)

	for(var/V in names)
		body += debug_variable(V, D.vars[V], 0, D)

	body += "</ol>"

	var/html = "<html><head>"
	if(title)
		html += "<title>[title]</title>"
	html += {"<style>
body
{
	font-family: Verdana, sans-serif;
	font-size: 9pt;
}
.value
{
	font-family: "Courier New", monospace;
	font-size: 8pt;
}
</style>"}
	html += "</head><body>"
	html += body.Join("")

	html += {"
		<script type='text/javascript'>
			var vars_ol = document.getElementById("vars");
			var complete_list = vars_ol.innerHTML;
		</script>
	"}

	html += "</body></html>"

	usr << browse(html, "window=variables[D.UID()];size=475x650")

	return

/client/proc/debug_variable(name, value, level, var/datum/DA = null)
	var/list/html = list()

	if(DA)
		html += "<li style='backgroundColor:white'>(<a href='?_src_=vars;datumedit=[DA.UID()];varnameedit=[name]'>E</a>) (<a href='?_src_=vars;datumchange=[DA.UID()];varnamechange=[name]'>C</a>) (<a href='?_src_=vars;datummass=[DA.UID()];varnamemass=[name]'>M</a>) "
	else
		html += "<li>"

	if(isnull(value))
		html += "[name] = <span class='value'>null</span>"

	else if(istext(value))
		html += "[name] = <span class='value'>\"[value]\"</span>"

	else if(isicon(value))
		#ifdef VARSICON
		html += "[name] = /icon (<span class='value'>[value]</span>) [bicon(value, use_class=0)]"
		#else
		html += "[name] = /icon (<span class='value'>[value]</span>)"
		#endif

	else if(istype(value, /image))
		var/image/I = value
		#ifdef VARSICON
		html += "<a href='?_src_=vars;Vars=[I.UID()]'>[name] \ref[value]</a> = /image (<span class='value'>[value]</span>) [bicon(value, use_class=0)]"
		#else
		html += "<a href='?_src_=vars;Vars=[I.UID()]'>[name] \ref[value]</a> = /image (<span class='value'>[value]</span>)"
		#endif

	else if(isfile(value))
		html += "[name] = <span class='value'>'[value]'</span>"

	else if(istype(value, /datum))
		var/datum/D = value
		html += "<a href='?_src_=vars;Vars=[D.UID()]'>[name] \ref[value]</a> = [D.type]"

	else if(istype(value, /client))
		var/client/C = value
		html += "<a href='?_src_=vars;Vars=[C.UID()]'>[name] \ref[value]</a> = [C] [C.type]"
//
	else if(istype(value, /list))
		var/list/L = value
		html += "[name] = /list ([L.len])"

		if(L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > 500))
			// not sure if this is completely right...
			if(0)	 //(L.vars.len > 0)
				html += "<ol>"
				html += "</ol>"
			else
				html += "<ul>"
				var/index = 1
				for(var/entry in L)
					if(istext(entry))
						html += debug_variable(entry, L[entry], level + 1)
					else
						html += debug_variable(index, L[index], level + 1)
					index++
				html += "</ul>"

	else
		html += "[name] = <span class='value'>[value]</span>"
		/*
		// Bitfield stuff
		if(round(value)==value) // Require integers.
			var/idx=0
			var/bit=0
			var/bv=0
			html += "<div class='value binary'>"
			for(var/block=0;block<8;block++)
				html += " <span class='block'>"
				for(var/i=0;i<4;i++)
					idx=(block*4)+i
					to_chat(bit=1, idx)
					bv=value & bit
					html += "<a href='?_src_=vars;togbit=[idx];var=[name];subject=[DA.UID()]' title='bit [idx] ([bit])'>[bv?1:0]</a>"
				html += "</span>"
			html += "</div>"
		*/
	html += "</li>"

	return html.Join("")

/client/proc/view_var_Topic(href, href_list, hsrc)
	//This should all be moved over to datum/admins/Topic() or something ~Carn
	if(!check_rights(R_ADMIN|R_MOD))
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
		log_runtime(EXCEPTION("Found \\ref-based '[paramname]' param in VV topic for [datuminfo], should be UID: [href]"))

	if(href_list["Vars"])
		debug_variables(locateUID(href_list["Vars"]))

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
	else if(href_list["rename"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["rename"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/new_name = sanitize(copytext(input(usr,"What would you like to name this mob?","Input a name",M.real_name) as text|null,1,MAX_NAME_LEN))
		if( !new_name || !M )	return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
		M.rename_character(M.real_name, new_name)
		href_list["datumrefresh"] = href_list["rename"]

	else if(href_list["varnameedit"] && href_list["datumedit"])
		if(!check_rights(R_VAREDIT))	return

		var/D = locateUID(href_list["datumedit"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnameedit"], 1)

	else if(href_list["togbit"])
		if(!check_rights(R_VAREDIT))	return

		var/atom/D = locateUID(href_list["subject"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return
		if(!(href_list["var"] in D.vars))
			to_chat(usr, "Unable to find variable specified.")
			return
		var/value = D.vars[href_list["var"]]
		value ^= 1 << text2num(href_list["togbit"])

		D.vars[href_list["var"]] = value

	else if(href_list["varnamechange"] && href_list["datumchange"])
		if(!check_rights(R_VAREDIT))	return

		var/D = locateUID(href_list["datumchange"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnamechange"], 0)

	else if(href_list["varnamemass"] && href_list["datummass"])
		if(!check_rights(R_VAREDIT))	return

		var/atom/A = locateUID(href_list["datummass"])
		if(!istype(A))
			to_chat(usr, "This can only be used on instances of type /atom")
			return

		cmd_mass_modify_object_variables(A, href_list["varnamemass"])

	else if(href_list["mob_player_panel"])
		if(!check_rights(R_ADMIN|R_MOD))	return

		var/mob/M = locateUID(href_list["mob_player_panel"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.holder.show_player_panel(M)
		href_list["datumrefresh"] = href_list["mob_player_panel"]

	else if(href_list["give_spell"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/mob/M = locateUID(href_list["give_spell"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_spell(M)
		href_list["datumrefresh"] = href_list["give_spell"]


	else if(href_list["give_disease"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/mob/M = locateUID(href_list["give_disease"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_disease(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["godmode"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/M = locateUID(href_list["godmode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_godmode(M)
		href_list["datumrefresh"] = href_list["godmode"]

	else if(href_list["gib"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/M = locateUID(href_list["gib"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_gib(M)

	else if(href_list["build_mode"])
		if(!check_rights(R_BUILDMODE))	return

		var/mob/M = locateUID(href_list["build_mode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		togglebuildmode(M)
		href_list["datumrefresh"] = href_list["build_mode"]

	else if(href_list["drop_everything"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/mob/M = locateUID(href_list["drop_everything"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_admin_drop_everything(M)

	else if(href_list["direct_control"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/mob/M = locateUID(href_list["direct_control"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_assume_direct_control(M)

	else if(href_list["make_skeleton"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/mob/living/carbon/human/H = locateUID(href_list["make_skeleton"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/confirm = alert("Are you sure you want to turn this mob into a skeleton?","Confirm Skeleton Transformation","Yes","No")
		if(confirm != "Yes")
			return

		H.makeSkeleton()
		message_admins("[key_name(usr)] has turned [key_name(H)] into a skeleton")
		log_admin("[key_name_admin(usr)] has turned [key_name_admin(H)] into a skeleton")
		href_list["datumrefresh"] = href_list["make_skeleton"]

	else if(href_list["offer_control"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["offer_control"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		to_chat(M, "Control of your mob has been offered to dead players.")
		log_admin("[key_name(usr)] has offered control of ([key_name(M)]) to ghosts.")
		message_admins("[key_name_admin(usr)] has offered control of ([key_name_admin(M)]) to ghosts")
		var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [M.real_name]?", poll_time = 100)
		var/mob/dead/observer/theghost = null

		if(candidates.len)
			theghost = pick(candidates)
			to_chat(M, "Your mob has been taken over by a ghost!")
			message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(M)])")
			M.ghostize()
			M.key = theghost.key
		else
			to_chat(M, "There were no ghosts willing to take control.")
			message_admins("No ghosts were willing to take control of [key_name_admin(M)])")

	else if(href_list["delall"])
		if(!check_rights(R_DEBUG|R_SERVER))	return

		var/obj/O = locateUID(href_list["delall"])
		if(!isobj(O))
			to_chat(usr, "This can only be used on instances of type /obj")
			return

		var/action_type = alert("Strict type ([O.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
		if(action_type == "Cancel" || !action_type)
			return

		if(alert("Are you really sure you want to delete all objects of type [O.type]?",,"Yes","No") != "Yes")
			return

		if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
			return

		var/O_type = O.type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted)")
				message_admins("[key_name_admin(usr)] deleted all objects of type [O_type] ([i] objects deleted)")
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted)")
				message_admins("[key_name_admin(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted)")

	else if(href_list["addreagent"]) /* Made on /TG/, credit to them. */
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/atom/A = locateUID(href_list["addreagent"])

		if(!A.reagents)
			var/amount = input(usr, "Specify the reagent size of [A]", "Set Reagent Size", 50) as num
			if(amount)
				A.create_reagents(amount)

		if(A.reagents)
			var/list/reagent_options = list()
			for(var/r_id in chemical_reagents_list)
				var/datum/reagent/R = chemical_reagents_list[r_id]
				reagent_options[R.name] = r_id

			if(reagent_options.len)
				reagent_options = sortAssoc(reagent_options)
				reagent_options.Insert(1, "CANCEL")

				var/chosen = input(usr, "Choose a reagent to add.", "Choose a reagent.") in reagent_options
				var/chosen_id = reagent_options[chosen]

				if(chosen_id)
					var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", A.reagents.maximum_volume) as num
					if(amount)
						A.reagents.add_reagent(chosen_id, amount)
						log_admin("[key_name(usr)] has added [amount] units of [chosen] to \the [A]")
						message_admins("[key_name_admin(usr)] has added [amount] units of [chosen] to \the [A]")

	else if(href_list["explode"])
		if(!check_rights(R_DEBUG|R_EVENT))	return

		var/atom/A = locateUID(href_list["explode"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_explosion(A)
		href_list["datumrefresh"] = href_list["explode"]

	else if(href_list["emp"])
		if(!check_rights(R_DEBUG|R_EVENT))	return

		var/atom/A = locateUID(href_list["emp"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_emp(A)
		href_list["datumrefresh"] = href_list["emp"]

	else if(href_list["mark_object"])
		if(!check_rights(0))	return

		var/datum/D = locateUID(href_list["mark_object"])
		if(!istype(D))
			to_chat(usr, "This can only be done to instances of type /datum")
			return

		src.holder.marked_datum = D
		href_list["datumrefresh"] = href_list["mark_object"]

	else if(href_list["proc_call"])
		if(!check_rights(R_PROCCALL))
			return

		var/T = locateUID(href_list["proc_call"])

		if(T)
			callproc_datum(T)

	else if(href_list["jump_to"])
		if(!check_rights(R_ADMIN))
			return

		var/atom/A = locateUID(href_list["jump_to"])
		var/turf/T = get_turf(A)
		if(T)
			usr.client.jumptoturf(T)
		href_list["datumrefresh"] = href_list["jump_to"]


	else if(href_list["rotatedatum"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/atom/A = locateUID(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom")
			return

		switch(href_list["rotatedir"])
			if("right")	A.dir = turn(A.dir, -45)
			if("left")	A.dir = turn(A.dir, 45)

		message_admins("[key_name_admin(usr)] has rotated \the [A]")
		log_admin("[key_name(usr)] has rotated \the [A]")
		href_list["datumrefresh"] = href_list["rotatedatum"]

	else if(href_list["makemonkey"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makemonkey"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makerobot"=href_list["makerobot"]))

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makealien"=href_list["makealien"]))

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makeslime"=href_list["makeslime"]))

	else if(href_list["makesuper"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makesuper"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makesuper"=href_list["makesuper"]))

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makeai"=href_list["makeai"]))

	else if(href_list["makemask"])
		if(!check_rights(R_SPAWN)) return
		var/mob/currentMob = locateUID(href_list["makemask"])
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!currentMob)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makemask"=href_list["makemask"]))


	else if(href_list["setspecies"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["setspecies"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_species = input("Please choose a new species.","Species",null) as null|anything in all_species

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.set_species(new_species))
			to_chat(usr, "Set species of [H] to [H.species].")
			H.regenerate_icons()
			message_admins("[key_name_admin(usr)] has changed the species of [key_name_admin(H)] to [new_species]")
			log_admin("[key_name(usr)] has changed the species of [key_name(H)] to [new_species]")
		else
			to_chat(usr, "Failed! Something went wrong.")

	else if(href_list["addlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locateUID(href_list["addlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		var/new_language = input("Please choose a language to add.","Language",null) as null|anything in all_languages

		if(!new_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.add_language(new_language))
			to_chat(usr, "Added [new_language] to [H].")
			message_admins("[key_name_admin(usr)] has given [key_name_admin(H)] the language [new_language]")
			log_admin("[key_name(usr)] has given [key_name(H)] the language [new_language]")
		else
			to_chat(usr, "Mob already knows that language.")

	else if(href_list["remlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locateUID(href_list["remlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		if(!H.languages.len)
			to_chat(usr, "This mob knows no languages.")
			return

		var/datum/language/rem_language = input("Please choose a language to remove.","Language",null) as null|anything in H.languages

		if(!rem_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.remove_language(rem_language.name))
			to_chat(usr, "Removed [rem_language] from [H].")
			message_admins("[key_name_admin(usr)] has removed language [rem_language] from [key_name_admin(H)]")
			log_admin("[key_name(usr)] has removed language [rem_language] from [key_name(H)]")
		else
			to_chat(usr, "Mob doesn't know that language.")

	else if(href_list["addverb"])
		if(!check_rights(R_DEBUG))			return

		var/mob/living/H = locateUID(href_list["addverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living")
			return
		var/list/possibleverbs = list()
		possibleverbs += "Cancel" 								// One for the top...
		possibleverbs += typesof(/mob/proc,/mob/verb,/mob/living/proc,/mob/living/verb)
		switch(H.type)
			if(/mob/living/carbon/human)
				possibleverbs += typesof(/mob/living/carbon/proc,/mob/living/carbon/verb,/mob/living/carbon/human/verb,/mob/living/carbon/human/proc)
			if(/mob/living/silicon/robot)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/robot/proc,/mob/living/silicon/robot/verb)
			if(/mob/living/silicon/ai)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/ai/proc,/mob/living/silicon/ai/verb)
		possibleverbs -= H.verbs
		possibleverbs += "Cancel" 								// ...And one for the bottom

		var/verb = input("Select a verb!", "Verbs",null) as anything in possibleverbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb || verb == "Cancel")
			return
		else
			H.verbs += verb
			message_admins("[key_name_admin(usr)] has given [key_name_admin(H)] the verb [verb]")
			log_admin("[key_name(usr)] has given [key_name(H)] the verb [verb]")

	else if(href_list["remverb"])
		if(!check_rights(R_DEBUG))			return

		var/mob/H = locateUID(href_list["remverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		var/verb = input("Please choose a verb to remove.","Verbs",null) as null|anything in H.verbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb)
			return
		else
			H.verbs -= verb
			message_admins("[key_name_admin(usr)] has removed verb [verb] from [key_name_admin(H)]")
			log_admin("[key_name(usr)] has removed verb [verb] from [key_name(H)]")

	else if(href_list["addorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locateUID(href_list["addorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
			return

		var/new_organ = input("Please choose an organ to add.","Organ",null) as null|anything in subtypesof(/obj/item/organ)-/obj/item/organ
		if(!new_organ) return

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(locateUID(new_organ) in M.internal_organs)
			to_chat(usr, "Mob already has that organ.")
			return
		var/obj/item/organ/internal/organ = new new_organ
		organ.insert(M)
		message_admins("[key_name_admin(usr)] has given [key_name_admin(M)] the organ [new_organ]")
		log_admin("[key_name(usr)] has given [key_name(M)] the organ [new_organ]")

	else if(href_list["remorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locateUID(href_list["remorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
			return

		var/obj/item/organ/internal/rem_organ = input("Please choose an organ to remove.","Organ",null) as null|anything in M.internal_organs

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(!(locateUID(rem_organ) in M.internal_organs))
			to_chat(usr, "Mob does not have that organ.")
			return

		to_chat(usr, "Removed [rem_organ] from [M].")
		rem_organ.remove(M)
		message_admins("[key_name_admin(usr)] has removed the organ [rem_organ] from [key_name_admin(M)]")
		log_admin("[key_name(usr)] has removed the organ [rem_organ] from [key_name(M)]")
		qdel(rem_organ)

	else if(href_list["fix_nano"])
		if(!check_rights(R_DEBUG)) return

		var/mob/H = locateUID(href_list["fix_nano"])

		if(!istype(H) || !H.client)
			to_chat(usr, "This can only be done on mobs with clients")
			return

		H.client.reload_nanoui_resources()

		to_chat(usr, "Resource files sent")
		to_chat(H, "Your NanoUI Resource files have been refreshed")

		log_admin("[key_name(usr)] resent the NanoUI resource files to [key_name(H)]")

	else if(href_list["regenerateicons"])
		if(!check_rights(0))	return

		var/mob/M = locateUID(href_list["regenerateicons"])
		if(!ismob(M))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		M.regenerate_icons()

	else if(href_list["adjustDamage"] && href_list["mobToDamage"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_EVENT))	return

		var/mob/living/L = locateUID(href_list["mobToDamage"])
		if(!istype(L)) return

		var/Text = href_list["adjustDamage"]

		var/amount =	input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

		if(!L)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		switch(Text)
			if("brute")	L.adjustBruteLoss(amount)
			if("fire")	L.adjustFireLoss(amount)
			if("toxin")	L.adjustToxLoss(amount)
			if("oxygen")L.adjustOxyLoss(amount)
			if("brain")	L.adjustBrainLoss(amount)
			if("clone")	L.adjustCloneLoss(amount)
			else
				to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
				return

		if(amount != 0)
			log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [L]")
			message_admins("[key_name_admin(usr)] dealt [amount] amount of [Text] damage to [L]")
			href_list["datumrefresh"] = href_list["mobToDamage"]

	if(href_list["datumrefresh"])
		var/datum/DAT = locateUID(href_list["datumrefresh"])
		if(!istype(DAT, /datum))
			return
		src.debug_variables(DAT)

	return
