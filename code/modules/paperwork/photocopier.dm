#define EMAG_DELAY 50
#define MODE_COPY 	"mode_copy"
#define MODE_PRINT 	"mode_print"
#define MODE_AIPIC 	"mode_aipic"

/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	var/insert_anim = "bigscanner1"
	anchored = 1
	density = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	max_integrity = 300
	integrity_failure = 100
	var/emag_cooldown
	atom_say_verb = "bleeps"
	var/mode = MODE_COPY
	var/category = "" // selected form's category
	var/form_id = "" // selected form's id
	var/list/forms = new/list() // forms list
	var/obj/item/paper/form/form = null // selected form for print
	var/obj/item/copyitem = null	//what's in the copier!
	var/copies = 1	//how many copies to print!
	var/toner = 60 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!
	var/mob/living/ass = null
	var/syndicate = FALSE
	var/info_box = "Если у вас есть пожелания или \
					идеи для улучшения стандартных \
					форм, обратитесь в Департамент \
					Стандартизации Nanotrasen."
	var/info_box_color = "blue"
	var/ui_theme = "nanotrasen"// Если темы нету, будет взята стандартная НТ тема для интерфейса

/obj/machinery/photocopier/syndie
	name = "Syndicate photocopier"
	desc = "They don't even try to hide it's theirs..."
	syndicate = TRUE
	icon_state = "syndiebigscanner"
	insert_anim = "syndiebigscanner1"
	info_box = "При использовании любой из данных форм,\
				обратите внимание на все пункты снизу. \
				Синдикат напоминает, что в ваших же интересах \
				соблюдать данные указания."
	ui_theme = "syndicate"

/obj/machinery/photocopier/attack_ai(mob/user)
	src.add_hiddenprint(user)
	parse_forms(user)
	ui_interact(user)

/obj/machinery/photocopier/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/attack_hand(mob/user)
	if(..(user))
		return 1

	user.set_machine(src)
	parse_forms(user)
	ui_interact(user)
	return

/obj/machinery/photocopier/ui_act(action, params)
	if(..())
		return
	if(stat & (BROKEN|NOPOWER))
		return

	. = TRUE
	switch(action)
		if("copy")
			if(emag_cooldown > world.time)
				to_chat(usr, "<span class='warning'>[src] is busy, try again in a few seconds.</span>")
				return

			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
			for(var/i = 0, i < copies, i++)
				if(toner <= 0)
					break

				if(GLOB.copier_items_printed >= GLOB.copier_max_items) //global vars defined in misc.dm
					if(prob(10))
						visible_message("<span class='warning'>The printer screen reads \"PC LOAD LETTER\".</span>")
					else
						visible_message("<span class='warning'>The printer screen reads \"PHOTOCOPIER NETWORK OFFLINE, PLEASE CONTACT SYSTEM ADMINISTRATOR\".</span>")
					if(!GLOB.copier_items_printed_logged)
						message_admins("Photocopier cap of [GLOB.copier_max_items] papers reached, all photocopiers are now disabled. This may be the cause of any lag.")
						GLOB.copier_items_printed_logged = TRUE
					break

				if(emag_cooldown > world.time)
					return

				if(istype(copyitem, /obj/item/paper))
					copy(copyitem)
					sleep(15)
				else if(istype(copyitem, /obj/item/photo))
					photocopy(copyitem)
					sleep(15)
				else if(istype(copyitem, /obj/item/paper_bundle))
					var/obj/item/paper_bundle/C = copyitem
					if(toner < (C.amount + 1))
						visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner for the operation.</span>") // It is better to prevent partial bundle than to produce broken paper bundle
						return
					var/obj/item/paper_bundle/B = bundlecopy(copyitem)
					if(!B)
						return
					sleep(15*B.amount)
				else if(ass && ass.loc == loc)
					copyass()
					sleep(15)
				else
					to_chat(usr, "<span class='warning'>\The [copyitem] can't be copied by \the [src].</span>")
					break
				GLOB.copier_items_printed++
				use_power(active_power_usage)
		if("print_form")
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
			for(var/i = 0, i < copies, i++)
				if(toner <= 0)
					break

				if(GLOB.copier_items_printed >= GLOB.copier_max_items) //global vars defined in misc.dm
					if(prob(10))
						visible_message("<span class='warning'>The printer screen reads \"PC LOAD LETTER\".</span>")
					else
						visible_message("<span class='warning'>The printer screen reads \"PHOTOCOPIER NETWORK OFFLINE, PLEASE CONTACT SYSTEM ADMINISTRATOR\".</span>")
					if(!GLOB.copier_items_printed_logged)
						message_admins("Photocopier cap of [GLOB.copier_max_items] papers reached, all photocopiers are now disabled. This may be the cause of any lag.")
						GLOB.copier_items_printed_logged = TRUE
					break

				if(emag_cooldown > world.time)
					return

				print_form(form)
				sleep(15)

				GLOB.copier_items_printed++
				use_power(active_power_usage)
		if("choose_form")
			form = params["path"]
			form_id = params["id"]
		if("choose_category")
			category = params["category"]
		if("remove")
			if(copyitem)
				copyitem.forceMove(get_turf(src))
				if(ishuman(usr))
					if(!usr.get_active_hand())
						usr.put_in_hands(copyitem)
				to_chat(usr, "<span class='notice'>You take \the [copyitem] out of \the [src].</span>")
				copyitem = null
			else if(check_ass())
				to_chat(ass, "<span class='notice'>You feel a slight pressure on your ass.</span>")
		if("min")
			if(copies > 1)
				copies--
		if("add")
			if(copies < maxcopies)
				copies++
		if("aipic")
			if(!istype(usr,/mob/living/silicon))
				return

			if(toner >= 5)
				var/mob/living/silicon/tempAI = usr
				var/obj/item/camera/siliconcam/camera = tempAI.aiCamera

				if(!camera)
					return
				var/datum/picture/selection = camera.selectpicture()
				if(!selection)
					return

				playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
				var/obj/item/photo/p = new /obj/item/photo (src.loc)
				p.construct(selection)
				if(p.desc == "")
					p.desc += "Copied by [tempAI.name]"
				else
					p.desc += " - Copied by [tempAI.name]"
				toner -= 5
				sleep(15)
		if("mode_copy")
			mode = MODE_COPY
		if("mode_print")
			mode = MODE_PRINT
		if("mode_aipic")
			mode = MODE_AIPIC
		else
			return FALSE
	add_fingerprint(usr)


/obj/machinery/photocopier/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Photocopier", name, 650, 500, master_ui, state)
		ui.open()

/obj/machinery/photocopier/ui_data(mob/user)
	if(forms.len == 0)
		parse_forms(user)

	var/list/data = list()

	data["isAI"] = issilicon(user)
	data["copyitem"] = copyitem
	data["ass"] = ass && ass.loc == loc ? TRUE : FALSE
	data["copies"] = copies
	data["toner"] = toner
	data["mode"] = mode
	data["form"] = form
	data["category"] = category
	data["form_id"] = form_id
	data["forms"] = forms
	data["info_box"] = info_box
	data["info_box_color"] = info_box_color
	data["ui_theme"] = ui_theme

	return data

/obj/machinery/photocopier/proc/parse_forms(mob/user)
	var/list/access = user.get_access()
	forms = new/list()
	for(var/F in subtypesof(/obj/item/paper/form))
		var/obj/item/paper/form/ff = F
		var/req_access = initial(ff.access)
		if(req_access && !(req_access in access))
			continue
		if(syndicate && !(ff in subtypesof(/obj/item/paper/form/syndieform))) //Если у нас синдипритер, нам не нужны другие формы
			continue
		if(!syndicate && !emagged && (ff in subtypesof(/obj/item/paper/form/syndieform)))
			continue
		var/form[0]
		form["path"] = F
		form["id"] = initial(ff.id)
		form["altername"] = initial(ff.altername)
		form["category"] = initial(ff.category)
		forms[++forms.len] = form

/obj/machinery/photocopier/attackby(obj/item/O as obj, mob/user as mob, params)
	add_fingerprint(user)
	if(istype(O, /obj/item/paper) || istype(O, /obj/item/photo) || istype(O, /obj/item/paper_bundle))
		if(!copyitem)
			user.drop_item()
			copyitem = O
			O.forceMove(src)
			to_chat(user, "<span class='notice'>You insert \the [O] into \the [src].</span>")
			flick(insert_anim, src)
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
	else if(istype(O, /obj/item/toner))
		if(toner <= 10) //allow replacing when low toner is affecting the print darkness
			user.drop_item()
			to_chat(user, "<span class='notice'>You insert the toner cartridge into \the [src].</span>")
			var/obj/item/toner/T = O
			toner += T.toner_amount
			qdel(O)
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
	else if(istype(O, /obj/item/grab)) //For ass-copying.
		var/obj/item/grab/G = O
		if(ismob(G.affecting) && G.affecting != ass)
			var/mob/GM = G.affecting
			visible_message("<span class='warning'>[usr] drags [GM.name] onto the photocopier!</span>")
			GM.forceMove(get_turf(src))
			ass = GM
			if(copyitem)
				copyitem.forceMove(get_turf(src))
				copyitem = null
	else
		return ..()

/obj/machinery/photocopier/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/photocopier/proc/print_form(var/obj/item/paper/form/form)
	var/obj/item/paper/form/paper = new form (loc)
	toner--
	if(toner == 0)
		visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
	return paper

/obj/machinery/photocopier/proc/copy(var/obj/item/paper/copy)
	var/obj/item/paper/c = new /obj/item/paper (loc)
	c.header = copy.header
	c.info = copy.info
	c.footer = copy.footer
	c.name = copy.name // -- Doohl
	c.fields = copy.fields
	c.stamps = copy.stamps
	c.stamped = copy.stamped
	c.ico = copy.ico
	c.offset_x = copy.offset_x
	c.offset_y = copy.offset_y
	var/list/temp_overlays = copy.overlays       //Iterates through stamps
	var/image/img                                //and puts a matching
	for(var/j = 1, j <= temp_overlays.len, j++) //gray overlay onto the copy
		if(copy.ico.len)
			if(findtext(copy.ico[j], "cap") || findtext(copy.ico[j], "cent") || findtext(copy.ico[j], "rep"))
				img = image('icons/obj/bureaucracy.dmi', "paper_stamp-circle")
			else if(findtext(copy.ico[j], "deny"))
				img = image('icons/obj/bureaucracy.dmi', "paper_stamp-x")
			else
				img = image('icons/obj/bureaucracy.dmi', "paper_stamp-dots")
			img.pixel_x = copy.offset_x[j]
			img.pixel_y = copy.offset_y[j]
			c.overlays += img
	c.updateinfolinks()
	toner--
	if(toner == 0)
		visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
	return c


/obj/machinery/photocopier/proc/photocopy(var/obj/item/photo/photocopy)
	var/obj/item/photo/p = new /obj/item/photo (loc)
	p.name = photocopy.name
	p.icon = photocopy.icon
	p.tiny = photocopy.tiny
	p.img = photocopy.img
	p.desc = photocopy.desc
	p.pixel_x = photocopy.pixel_x
	p.pixel_y = photocopy.pixel_y
	if(photocopy.scribble)
		p.scribble = photocopy.scribble
	toner -= 5
	if(toner < 0)
		toner = 0
		visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
	return p


/obj/machinery/photocopier/proc/copyass()
	var/icon/temp_img
	if(!check_ass()) //You have to be sitting on the copier and either be a xeno or a human without clothes on.
		return
	if(emagged)
		if(ishuman(ass))
			var/mob/living/carbon/human/H = ass
			to_chat(H, "<span class='notice'>Something smells toasty...</span>")
			var/obj/item/organ/external/G = H.get_organ("groin")
			G.receive_damage(0, 30)
			spawn(20)
				H.emote("scream")
			emag_cooldown = world.time + EMAG_DELAY
		else
			to_chat(ass, "<span class='notice'>Something smells toasty...</span>")
			ass.apply_damage(30, BURN)
			emag_cooldown = world.time + EMAG_DELAY
	if(ishuman(ass)) //Suit checks are in check_ass
		var/mob/living/carbon/human/H = ass
		temp_img = icon('icons/obj/butts.dmi', H.dna.species.butt_sprite)
	else if(isdrone(ass))
		temp_img = icon('icons/obj/butts.dmi', "drone")
	else if(istype(ass,/mob/living/simple_animal/diona))
		temp_img = icon('icons/obj/butts.dmi', "nymph")
	else if(isalien(ass) || istype(ass,/mob/living/simple_animal/hostile/alien)) //Xenos have their own asses, thanks to Pybro.
		temp_img = icon('icons/obj/butts.dmi', "xeno")
	else
		return
	var/obj/item/photo/p = new /obj/item/photo (loc)
	p.desc = "You see [ass]'s ass on the photo."
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	p.img = temp_img
	var/icon/small_img = icon(temp_img) //Icon() is needed or else temp_img will be rescaled too >.>
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	p.icon = ic
	toner -= 5
	if(toner < 0)
		toner = 0
		visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
	return p

//If need_toner is 0, the copies will still be lightened when low on toner, however it will not be prevented from printing. TODO: Implement print queues for fax machines and get rid of need_toner
/obj/machinery/photocopier/proc/bundlecopy(var/obj/item/paper_bundle/bundle, var/need_toner=1)
	var/obj/item/paper_bundle/P = new /obj/item/paper_bundle (src, default_papers = FALSE)
	for(var/obj/item/W in bundle)
		if(toner <= 0 && need_toner)
			toner = 0
			visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
			break

		if(istype(W, /obj/item/paper))
			W = copy(W)
		else if(istype(W, /obj/item/photo))
			W = photocopy(W)
		W.forceMove(P)
		P.amount++
	if(!P.amount)
		qdel(P)
		return null
	P.amount--
	P.forceMove(get_turf(src))
	P.update_icon()
	P.icon_state = "paper_words"
	P.name = bundle.name
	P.pixel_y = rand(-8, 8)
	P.pixel_x = rand(-9, 9)
	return P

/obj/machinery/photocopier/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		if(toner > 0)
			new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
			toner = 0

/obj/machinery/photocopier/MouseDrop_T(mob/target, mob/user)
	check_ass() //Just to make sure that you can re-drag somebody onto it after they moved off.
	if(!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || istype(user, /mob/living/silicon/ai) || target == ass)
		return
	add_fingerprint(user)
	if(target == user && !user.incapacitated())
		visible_message("<span class='warning'>[usr] jumps onto [src]!</span>")
	else if(target != user && !user.restrained() && !user.stat && !user.IsWeakened() && !user.stunned && !user.paralysis)
		if(target.anchored) return
		if(!ishuman(user)) return
		visible_message("<span class='warning'>[usr] drags [target.name] onto [src]!</span>")
	target.forceMove(get_turf(src))
	ass = target
	if(copyitem)
		copyitem.forceMove(get_turf(src))
		visible_message("<span class='notice'>[copyitem] is shoved out of the way by [ass]!</span>")
		copyitem = null

/obj/machinery/photocopier/proc/check_ass() //I'm not sure wether I made this proc because it's good form or because of the name.
	if(!ass)
		return 0
	if(ass.loc != src.loc)
		ass = null
		return 0
	else
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		atom_say("Внимание: обнаружена задница на печатном полотне!")
		return 1

/obj/machinery/photocopier/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		to_chat(user, "<span class='notice'>You overload [src]'s laser printing mechanism.</span>")
	else
		to_chat(user, "<span class='notice'>[src]'s laser printing mechanism is already overloaded!</span>")

/obj/item/toner
	name = "toner cartridge"
	icon = 'icons/obj/device.dmi'
	icon_state = "tonercartridge"
	var/toner_amount = 30

#undef EMAG_DELAY
#undef MODE_COPY
#undef MODE_PRINT
#undef MODE_AIPIC
