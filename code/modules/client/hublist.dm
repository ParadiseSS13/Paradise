/**
  * Arguments:
  * * user - Mob calling the lookup so the UI can be opened
  * * response - [/datum/http_response] passed through from [SShttp]
  */
/datum/proc/hublist_fetch_callback(mob/user, datum/http_response/response)
	if(!user)
		return

	if(response.errored)
		to_chat(user, "<span class='warning'>Error fetching Hublist. Please inform a maintainer or server host.</span>")
		hublist_popup(user)
		return

	if(response.status_code != 200)
		to_chat(user, "<span class='warning'>Error performing Hublist fetch (Code: [response.status_code])</span>")
		hublist_popup(user)
		return

	hublist_popup(user, response.body)

/datum/proc/hublist_popup(mob/user, content)
	var/dat = {"<html><meta charset="UTF-8"><body>"}
	var/tally = length(GLOB.clients)
	if(tally > 90)
		dat += "Игроков на этом сервере уже <b>[tally]</b>. Пожалуйста, выберите другой сервер.<br>Это поможет обеспечить комфортную игру другим на текущем сервере. Но мы вас не заставляем переходить, это окно можно просто закрыть. Спасибо за понимание!<br><HR><br>"
	if(content)
		dat += content
	else
		dat += GLOB.hublist
	dat += "</body></html>"

	var/datum/browser/popup = new(user, "hublist", "<div align='center'>Сервера проекта SS220</div>", 600, 550)
	popup.set_content(dat)
	popup.open(FALSE)

/client/proc/hublistpanel(forced = FALSE)
	if(!config.hublist_url && !GLOB.hublist)
		to_chat(usr, "<span class='warning'>The Hublist isn't configured yet. Please inform a maintainer or server host.</span>")
		return

	if(holder && forced)
		return FALSE

	if(config.hublist_url)
		var/datum/callback/cb = CALLBACK(src, /datum/.proc/hublist_fetch_callback, usr)
		SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, config.hublist_url, proc_callback=cb)
	else
		hublist_popup(usr)


