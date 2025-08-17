#define PHOTOCOPIER_DELAY 5 SECONDS

/obj/machinery/photocopier
	toner = 30
	/// Selected form's category
	var/category = ""
	/// Selected form's id
	var/form_id = ""
	/// List of available forms
	var/list/forms
	/// Selected form's datum
	var/datum/bureaucratic_form/form
	/// Printing sound
	var/print_sound = 'modular_ss220/bureaucracy/sound/print.ogg'

/obj/machinery/photocopier/Initialize(mapload)
	. = ..()
	forms = new

/obj/machinery/photocopier/attack_ai(mob/user)
	add_hiddenprint(user)
	parse_forms(user)
	ui_interact(user)

/obj/machinery/photocopier/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/attack_hand(mob/user)
	. = ..()
	parse_forms(user)

/obj/machinery/photocopier/ui_act(action, list/params)
	. = ..()
	if(isnull(.))
		return

	switch(action)
		if("print_form")
			for(var/i in 1 to copies)
				if(toner <= 0)
					break
				print_form(form)
			. = TRUE
		if("choose_form")
			form = GLOB.bureaucratic_forms[params["path"]]
			form_id = params["id"]
			. = TRUE
		if("choose_category")
			category = params["category"]
			. = TRUE
		if("copies")
			copies = clamp(text2num(params["new"]), 0, maxcopies)

/obj/machinery/photocopier/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/photocopier/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Photocopier220", "Ксерокс")
		ui.open()

/obj/machinery/photocopier/ui_data(mob/user)
	if(!length(forms))
		parse_forms(user)

	var/list/data = list()
	data["isAI"] = issilicon(user)
	data["copies"] = copies
	data["maxcopies"] = maxcopies
	data["toner"] = toner
	data["copyitem"] = (copyitem ? copyitem.name : null)
	data["folder"] = (folder ? folder.name : null)
	data["mob"] = (copymob ? copymob.name : null)
	data["form"] = form
	data["category"] = category
	data["form_id"] = form_id
	data["forms"] = forms
	return data

/obj/machinery/photocopier/proc/parse_forms(mob/user)
	var/list/access = user.get_access()
	forms.Cut()
	for(var/path in GLOB.bureaucratic_forms)
		var/datum/bureaucratic_form/paper_form = GLOB.bureaucratic_forms[path]
		var/req_access = paper_form.req_access
		if(req_access && !(req_access in access))
			continue
		var/form[0]
		form["path"] = paper_form.type
		form["id"] = paper_form.id
		form["altername"] = paper_form.altername
		form["category"] = paper_form.category
		forms.Add(list(form))

/obj/machinery/photocopier/proc/print_form(datum/bureaucratic_form/form)
	if(copying)
		visible_message(span_notice("[src] работает, проявите терпение."))
		return FALSE

	toner--
	copying = TRUE
	playsound(loc, print_sound, 50)
	use_power(active_power_consumption)
	sleep(PHOTOCOPIER_DELAY)
	var/obj/item/paper/paper = new(loc)
	paper.pixel_x = rand(-10, 10)
	paper.pixel_y = rand(-10, 10)
	form.apply_to_paper(paper, usr)
	copying = FALSE

#undef PHOTOCOPIER_DELAY
