/proc/input_async(mob/user=usr, prompt, list/choices)
	var/datum/async_input/A = new(choices, prompt)
	A.show(user)
	return A

/proc/input_ranked_async(mob/user=usr, prompt="Order by greatest to least preference", list/choices)
	var/datum/async_input/ranked/A = new(choices, prompt)
	A.show(user)
	return A

/datum/async_input
	var/datum/browser/popup
	var/list/choices
	var/flash = TRUE
	var/immediate_submit = FALSE
	var/prompt
	var/result = null
	var/style = "text-align: center;"
	var/window_id
	var/height = 200
	var/width = 400

/datum/async_input/New(list/new_choices, new_prompt="Pick an option:", new_window_id="async_input")
	choices = new_choices
	prompt = new_prompt
	window_id = new_window_id

/datum/async_input/proc/close()
	if(popup)
		popup.close()
	return result

/datum/async_input/proc/show(mob/user)
	var/dat = create_ui(user)
	popup = new(user, window_id, , width, height, src)
	popup.set_content(dat)
	if(flash && result == null)
		window_flash(user.client)
	popup.open()

/datum/async_input/proc/create_ui(mob/user)
	var/dat = "<div style=\"[style]\">"
	dat += render_prompt(user)
	dat += render_choices(user)
	dat += "<br>"
	dat += "<br>"
	dat += button("Submit", "submit=1", , result == null && !immediate_submit)
	dat += "</div>"
	return dat

/datum/async_input/proc/render_prompt(mob/user)
	return "<h2>[prompt]</h2>"

/datum/async_input/proc/render_choices(mob/user)
	var/dat = " "
	for(var/choice in choices)
		dat += button(choice, "choice=[choice]", choice == result)
		dat += " "
	return dat

/datum/async_input/proc/button(label, topic, on=FALSE, disabled=FALSE)
	var/class = ""
	if(on)
		class = "linkOn"
	if(disabled)
		class = "linkOff"
		topic = ""
	return "<a class=\"[class]\" href='?src=[UID()];[topic]'>[label]</a>"

/datum/async_input/Topic(href, href_list)
	if(href_list["submit"] || href_list["close"])
		close()
		return

	if(href_list["choice"])
		result = href_list["choice"]
		show(usr)
		return

/datum/async_input/ranked
	height = 400
	immediate_submit = TRUE

/datum/async_input/ranked/render_choices(mob/user)
	var/dat = "<div>"
	dat += "<table style='margin: auto; text-align: left;'>"
	for(var/i = 1, i <= choices.len, i++)
		var/choice = choices[i]
		dat += "<tr>"
		dat += "<td>[button("+", i != 1 ? "upvote=[i]" : "", , i == 1)]</td>"
		dat += "<td>[button("-", i != choices.len ? "downvote=[i]" : "", , i == choices.len)]</td>"
		dat += "<td>[i]. [choice]</td>"
		dat += "</tr>"
	dat += "</table>"
	dat += "</div>"
	return dat

/datum/async_input/ranked/Topic(href, href_list)
	if(!href_list["close"])
		// Mark that user interacted with interface
		result = choices

	if(href_list["upvote"])
		var/index = text2num(href_list["upvote"])
		choices.Swap(index, index - 1)
		show(usr)
		return

	if(href_list["downvote"])
		var/index = text2num(href_list["downvote"])
		choices.Swap(index, index + 1)
		show(usr)
		return

	..()
