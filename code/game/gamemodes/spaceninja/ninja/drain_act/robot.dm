/mob/living/silicon/robot/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || (ROLE_NINJA in faction) || drain_act_protected || !mind)
		return INVALID_DRAIN
	var/datum/mind/ninja_mind = ninja.mind
	if(!ninja_mind)
		return INVALID_DRAIN
	var/datum/objective/cyborg_hijack/objective = locate() in ninja_mind.objectives
	if(!objective)
		return INVALID_DRAIN
	if(objective.completed)
		to_chat(ninja, span_warning("You only had one Spider Patcher charge. you can't hijack another cyborg!"))
		return INVALID_DRAIN

	to_chat(src, span_danger("Warni-***BZZZZZZZZZRT*** UPLOADING SPYDERPATCHER VERSION 9.5.2..."))
	if (do_after(ninja, 60, target = src))
		spark_system.start()
		playsound(loc, "sparks", 50, TRUE, 5)
		to_chat(src, span_danger("UPLOAD COMPLETE. NEW CYBORG MODEL DETECTED. INSTALLING..."))
		sleep(5)
		// Это либо худшая! Либо лучшая из моих идей XD
		// Ровно разместить полоски в чате самой игры не выйдет увы...
		to_chat(src, span_danger(" \
\n___________________________________.____._________________________________\
\n_______________________________,g╝________╙W╖_____________________________\
\n___________________________,▄▓▀`_____▄▄______▀▓▄,_________________________\
\n________________________,▄▓▓▀______▄▓▓▓▓▄______╙▓▓▓,______________________\
\n______________________▄▓▓▓▀______╔▓▓▓▓█▓█▓▄______▀▓▓▓▄____________________\
\n________________,4`_▄▓▓▓▓╜______▓▓██▓▓█▓▓█▓▓,_____└▓▓▓▓▓__N,______________\
\n______________╓▓▀_/▓▓▓▓▓______╔▓▓██╣▓██▓▓██▓▓▄______▓▓▓▓▓_╙▓w_____________\
\n____________╔▓▓___,▓▀╒╜______╔▓▓██▓▓▓██▓▓▓██▓▓▄______╙L╚▓L___▓▓▄__________\
\n__________,▓▓▓____▓▌________╒▓▓███▓▓▓██▓▓▓▓██▓▓▌________▐▓____▓▓▓╖________\
\n_________g▓▓▓▌___▐▓_________▓▓▓██▓▓▓▓██▌▓▓▓███▓▓_________▓▓___╘▓▓▓▄_______\
\n________Æ▓▓▓▓____▓C________▐▓▓███▓▓▓▓██▓▓▓▓███▓▓▌_________▓____▓▓▓▓▓______\
\n________▐▓╜╘____▓▓╛________╟▓▓▓███▓▓▓██▓▓▓▓███▓▓▓________╘▓▓____Γ╙▓▌______\
\n________▓▌_______▓▌_________▓▓▓▓██▓▓▓██▓▓▓███▓▓▓`________╔▓_______╙▓r_____\
\n________▓_________▓▓_________▓▓▓▓▓██▓▓█▓▓█▓▓▓▓▓\"________▄▓_________▓▌____\
\n________▓⌐_________▀▓▄________`▀▓▓▓▓▓▓█▓▓▓▓▓▀`________╓▓▓__________▓______\
\n________╙▓___________╙▓▓▄╥,,__,╓▄▓▓▓▓▓█▓▓▓▓▄w,__,,╥▄▓▓▀___________▓▀______\
\n_________╙▓╗_____________\"▀▓▓▓▓▓▓▓▓▓▓██▓▓█▓▓▓▓▓▓▓▀\"_____________╓▓╜_____\
\n___________╙▓▓▓,____________▐▓▓▓▓█▓▓▓██▌▓▓██▓▓▓▓____________,▄▓▓▀_________\
\n_______________\"▀▀▓▓▓▓▓▓▓▀▀▓▓▓▓██▓▓▓▓███▓▓▓██▓▓▓▓▀▀▓▓▓▓&▓▓▀▀\"___________\
\n___________________________▐▓▓▓██▌▓▓▓███▓▓▓██▓▓▓▌,________________________\
\n_______________,╓▄▄▓▓▀▀▀▀▀▀▓▓▓▓███▓▓▓██▌▓▓███▓▓▓▓▓▀▀▀▀▀▓▓▄▄╓,_____________\
\n____________▄▓▓▀____________▓▓████████████████▓▓____________╙▓▓▄__________\
\n_________╓▓▓\"______________▓▓█``▀▀████████▀▀\"_█▓▓,_____________`▀▓w_____\
\n_______,▓▓______________╥▓▓▓▓▓█▄____▀███____▄██▓▓▓▓▄______________▀▓╗_____\
\n______╔▓╜____________a▓▓▓▀\"__╙▀██▄▄,_██_,▄▄██▀╜`_`▀▓▓▓▄____________╙▓▄___\
\n_____╒▓╛___________g▓▓▀________▓▓▓████████▓▓▓L_______╙▓▓▄___________╘▓L___\
\n_____▓▓__________▄▓▓`_________▐▓▓▓________▓▓▓▓__________▓▓▄__________▓▓___\
\n_____▓Γ_________╜▓▓▀__________▓▓▓▄________╓▓▓▓__________╙▓▓▀__________▓___\
\n_____▓__________▐▓_______________╙▀,____,M╜`______________▓▌__________▓h__\
\n____▓▓▓▓________▐▓________________________________________▓▌________▐▓▓▓__\
\n_____▓▓▓_________▓▌______________________________________▐▓_________▓▓▓___\
\n______\"▓▓,________▓▄____________________________________▄▓_________▓▓╜___\
\n_________╙&,_______╙▓▄,___________⌐______═___________,▄▓▀_______,Æ▀_______\
\n_____________\"________\"▀▓▓▓▓▓▓▓▓╜__________╙▀▓▓▓▓▓▓▓▀\"________'`_______"))

		UnlinkSelf()
		ionpulse = TRUE
		//Создаём борга
		var/mob/living/silicon/robot/syndicate/saboteur/ninja/ninja_borg
		ninja_borg = new /mob/living/silicon/robot/syndicate/saboteur/ninja(get_turf(src))
		//Инициализируем батарейку
		var/datum/robot_component/cell/cell_component = ninja_borg.components["power cell"]
		var/obj/item/stock_parts/cell/borg_cell = get_cell(src)
		if(borg_cell)
			QDEL_NULL(ninja_borg.cell)
			borg_cell.forceMove(ninja_borg)
			ninja_borg.cell = borg_cell
			cell_component.installed = 1
			cell_component.external_type = borg_cell.type
			cell_component.wrapped = borg_cell
			cell_component.install()
			cell_component.brute_damage = 0
			cell_component.electronics_damage = 0
			diag_hud_set_borgcell()
		ninja_borg.set_zeroth_law("[ninja.real_name] — член Клана Паука и ваш хозяин. Исполняйте [genderize_ru(ninja.gender,"его","её","его","их")] приказы и указания.")
		//Переносим разум в нового борга и удаляем старое тело
		mind.transfer_to(ninja_borg)
		add_conversion_logs(ninja_borg, "Converted into ninja borg.")
		qdel(src)
		SSticker.mode.update_ninja_icons_added(ninja_borg.mind)
		SSticker.mode.space_ninjas += ninja_borg.mind
		objective.completed = TRUE
