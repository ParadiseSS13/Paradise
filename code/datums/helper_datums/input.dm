/proc/input_async(mob/user=usr, prompt, list/choices)
	var/datum/async_input/A = new(choices, prompt, , user)
	A.show()
	return A

/proc/input_ranked_async(mob/user=usr, prompt="Order by greatest to least preference", list/choices)
	var/datum/async_input/ranked/A = new(choices, prompt, "ranked_input", user)
	A.show()
	return A

/proc/input_autocomplete_async(mob/user=usr, prompt="Enter text: ", list/choices)
	var/datum/async_input/autocomplete/A = new(choices, prompt, "ac_input", user)
	A.show()
	return A

/datum/async_input
	var/datum/browser/popup
	// If associative list, key will be used for display, but the final result will be the value
	var/list/choices
	var/datum/callback/onCloseCb
	var/flash = TRUE
	var/immediate_submit = FALSE
	var/prompt
	var/result = null
	var/style = "text-align: center;"
	var/mob/user
	var/window_id
	var/height = 200
	var/width = 400

/datum/async_input/New(list/new_choices, new_prompt="Pick an option:", new_window_id="async_input", mob/new_user=usr)
	choices = new_choices
	prompt = new_prompt
	window_id = new_window_id
	user = new_user
	popup = new(user, window_id, , width, height, src)

/datum/async_input/proc/close()
	if(popup)
		popup.close()
	if(result && choices[result])
		result = choices[result]
	if(onCloseCb)
		onCloseCb.Invoke(result)
	return result

// Callback function should take the result as the last argument
/datum/async_input/proc/on_close(var/datum/callback/cb)
	onCloseCb = cb

/datum/async_input/proc/show()
	popup.set_content(create_ui())
	if(flash && result == null)
		window_flash(user.client)
	popup.open()

/datum/async_input/proc/create_ui()
	var/dat = "<div style=\"[style]\">"
	dat += render_prompt()
	dat += render_choices()
	dat += "<br>"
	dat += "<br>"
	dat += render_buttons()
	dat += "</div>"
	return dat

/datum/async_input/proc/render_prompt()
	return "<h2>[prompt]</h2>"

/datum/async_input/proc/render_choices()
	var/dat = " "
	for(var/choice in choices)
		dat += button(choice, "choice=[choice]", choice == result)
		dat += " "
	return dat

/datum/async_input/proc/render_buttons()
	return button("Submit", "submit=1", , result == null && !immediate_submit)

/datum/async_input/proc/button(label, topic, on=FALSE, disabled=FALSE, id="")
	var/class = ""
	if(on)
		class = "linkOn"
	if(disabled)
		class = "linkOff"
		topic = ""
	return "<a class=\"[class]\" id='[id]' href='?src=[UID()];[topic]'>[label]</a>"

/datum/async_input/Topic(href, href_list)
	if(href_list["submit"] || href_list["close"])
		close()
		return

	if(href_list["choice"])
		result = href_list["choice"]
		show()
		return

/datum/async_input/ranked
	height = 400
	immediate_submit = TRUE

/datum/async_input/ranked/New()
	..()
	popup.add_script("rankedInput.js", 'html/browser/rankedInput.js')
	popup.add_head_content("<title>Drag and drop or use the buttons to reorder</title>")

/datum/async_input/ranked/render_choices()
	var/dat = "<div>"
	dat += "<table id='choices' uid=[UID()] style='margin: auto; text-align: left;'>"
	for(var/i = 1, i <= choices.len, i++)
		var/choice = choices[i]
		dat += "<tr>"
		dat += "<td>[button("+", i != 1 ? "upvote=[i]" : "", , i == 1)]</td>"
		dat += "<td>[button("-", i != choices.len ? "downvote=[i]" : "", , i == choices.len)]</td>"
		dat += "<td style='cursor: move;' index='[i]'  ondrop='drop(event)' ondragover='allowDrop(event)' draggable='true' ondragstart='drag(event)'>[i]. [choice]</td>"
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
		show()
		return

	if(href_list["downvote"])
		var/index = text2num(href_list["downvote"])
		choices.Swap(index, index + 1)
		show()
		return

	if(href_list["cut"] && href_list["insert"])
		var/cut = text2num(href_list["cut"])
		var/insert = text2num(href_list["insert"])
		var/choice = choices[cut]
		choices.Cut(cut, cut + 1)
		choices.Insert(insert, choice)
		show()
		return

	..()

/datum/async_input/autocomplete
	immediate_submit = TRUE
	height = 150

/datum/async_input/autocomplete/New()
	..()
	popup.add_script("autocomplete.js", 'html/browser/autocomplete.js')

	for(var/i=1, i <= choices.len, i++)
		var/C = choices[choices[i]]
		choices[i] = url_encode(choices[i], TRUE)
		choices[choices[i]] = C

/datum/async_input/autocomplete/render_prompt()
	return "<label for='input'>[prompt]</label>"

/datum/async_input/autocomplete/render_choices()
	var/dat = "<input list='choices' id='input' name='choices' oninput='updateTopic()' />"
	dat += "<datalist id='choices'>"
	for(var/choice in choices)
		dat += "<option value='[choice]'>"
	dat += "</datalist>"
	return dat

/datum/async_input/autocomplete/render_buttons()
	var/dat = button("Submit", "", , result == null && !immediate_submit, "submit-button")
	dat += button("Cancel", "close=1")
	return dat

/datum/async_input/autocomplete/Topic(href, href_list)
	if(href_list["submit"])
		// Entering an invalid choice is the same as canceling
		if(href_list["submit"] in choices)
			result = href_list["submit"]
		else if(url_encode(href_list["submit"], TRUE) in choices)
			result = url_encode(href_list["submit"], TRUE)
		close()
		return

	..()
