// A special pen for service droids. Can be toggled to switch between normal writing mode, and paper rename mode
// Allows service droids to rename paper items.

/obj/item/pen/multi/robopen
	desc = "A black ink printing attachment with a paper naming mode."
	name = "Printing Pen"
	var/mode = 1

/obj/item/pen/multi/robopen/attack_self__legacy__attackchain(mob/user as mob)
	var/choice = tgui_input_list(user, "Would you like to change colour or mode?", name, list("Colour","Mode"))
	if(!choice)
		return

	switch(choice)
		if("Colour")
			select_colour(user)
		if("Mode")
			if(mode == 1)
				mode = 2
			else
				mode = 1
			to_chat(user, "Changed printing mode to '[mode == 2 ? "Rename Paper" : "Write Paper"]'")
			playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	return

// Copied over from paper's rename verb
// see code\modules\paperwork\paper.dm line 62

/obj/item/pen/multi/robopen/proc/RenamePaper(mob/user, obj/paper)
	if(!user || !paper)
		return

	var/n_name = tgui_input_text(user, "What would you like to label the paper?", "Paper Labelling", max_length = MAX_NAME_LEN)
	if(!Adjacent(user) || !n_name)
		return

	paper.name = "paper - [n_name]"
	add_fingerprint(user)

//TODO: Add prewritten forms to dispense when you work out a good way to store the strings.
/obj/item/form_printer
	//name = "paperwork printer"
	name = "paper dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"

/obj/item/form_printer/attack__legacy__attackchain(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	return

/obj/item/form_printer/afterattack__legacy__attackchain(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)

	if(!target || !flag)
		return

	if(istype(target,/obj/structure/table))
		deploy_paper(get_turf(target))

/obj/item/form_printer/attack_self__legacy__attackchain(mob/user as mob)
	deploy_paper(get_turf(src))

/obj/item/form_printer/proc/deploy_paper(turf/T)
	T.visible_message("<span class='notice'>\The [src.loc] dispenses a sheet of crisp white paper.</span>")
	new /obj/item/paper(T)


//Personal shielding for the combat module.

/obj/item/borg/destroyer/mobility
	name = "mobility module"
	desc = "By retracting limbs and tucking in its head, a combat android can roll at high speeds."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
	powerneeded = 25
