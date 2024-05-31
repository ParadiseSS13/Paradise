#define CRAYON_MESSAGE_MAX_LENGTH 16
#define CARDBORG_HEAD 1
#define CARDBORG_BODY 2

/*
 * Crayons
 */
/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_FLAG_BELT | SLOT_FLAG_EARS
	attack_verb = list("attacked", "coloured")
	toolspeed = 1
	var/colour = COLOR_RED
	var/drawtype = "rune"
	var/list/graffiti = list("body","amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","up","down","left","right","heart","borgsrogue","voxpox","shitcurity","catbeast","hieroglyphs1","hieroglyphs2","hieroglyphs3","security","syndicate1","syndicate2","nanotrasen","lie","valid","arrowleft","arrowright","arrowup","arrowdown","chicken","hailcrab","brokenheart","peace","scribble","scribble2","scribble3","skrek","squish","tunnelsnake","yip","youaredead")
	var/list/letters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes
	var/dat
	var/busy = FALSE
	var/list/validSurfaces = list(/turf/simulated/floor)
	/// How many times this crayon has been gnawed on
	var/times_eaten = 0
	/// How many times a crayon can be bitten before being depleted. You eated it
	var/max_bites = 4
	/// The stored message in the crayon.
	var/preset_message
	/// The index of the character in the message that will be drawn next.
	var/preset_message_index = 0

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is jamming the [name] up [user.p_their()] nose and into [user.p_their()] brain. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS|OXYLOSS

/obj/item/toy/crayon/New()
	..()
	drawtype = pick(pick(graffiti), pick(letters), "rune[rand(1, 8)]")

/obj/item/toy/crayon/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/proc/update_window(mob/living/user as mob)
	var/current_drawtype = drawtype
	if(preset_message_index > 0)
		current_drawtype = copytext(preset_message, 1, preset_message_index)
		current_drawtype += "<u>[preset_message[preset_message_index]]</u>"
		current_drawtype += copytext(preset_message, preset_message_index + 1)
		current_drawtype = uppertext(current_drawtype)
	dat += "<center><h2>Currently selected: [current_drawtype]</h2><br>"
	dat += "<a href='byond://?src=[UID()];type=random_letter'>Random letter</a><a href='byond://?src=[UID()];type=letter'>Pick letter</a><br />"
	dat += "<a href='byond://?src=[UID()];type=message'>Message</a>"
	dat += "<hr>"
	dat += "<h3>Runes:</h3><br>"
	dat += "<a href='byond://?src=[UID()];type=random_rune'>Random rune</a>"
	for(var/i = 1; i <= 8; i++)
		dat += "<a href='byond://?src=[UID()];type=rune[i]'>Rune [i]</a>"
		if(!((i + 1) % 3)) //3 buttons in a row
			dat += "<br>"
	dat += "<hr>"
	graffiti.Find()
	dat += "<h3>Graffiti:</h3><br>"
	dat += "<a href='byond://?src=[UID()];type=random_graffiti'>Random graffiti</a>"
	var/c = 1
	for(var/T in graffiti)
		dat += "<a href='byond://?src=[UID()];type=[T]'>[T]</a>"
		if(!((c + 1) % 3)) //3 buttons in a row
			dat += "<br>"
		c++
	dat += "<hr>"
	var/datum/browser/popup = new(user, "crayon", name, 300, 500)
	popup.set_content(dat)
	popup.open()
	dat = ""

/obj/item/toy/crayon/Topic(href, href_list, hsrc)
	var/temp = "a"
	preset_message_index = 0
	switch(href_list["type"])
		if("random_letter")
			temp = pick(letters)
		if("letter")
			temp = input("Choose the letter.", "Scribbles") in letters
		if("random_rune")
			temp = "rune[rand(1, 8)]"
		if("random_graffiti")
			temp = pick(graffiti)
		if("message")
			var/regex/graffiti_chars = regex("\[^a-zA-Z0-9+\\-!?=%&,.#\\/\]", "g")
			var/new_preset = input(usr, "Set the message. Max length [CRAYON_MESSAGE_MAX_LENGTH] characters.")
			new_preset = copytext(new_preset, 1, CRAYON_MESSAGE_MAX_LENGTH)
			preset_message = lowertext(graffiti_chars.Replace(new_preset, ""))
			if(preset_message != "")
				log_admin("[key_name(usr)] has set the message of [src] to \"[preset_message]\".")
				preset_message_index = 1
		else
			temp = href_list["type"]
	if((usr.restrained() || usr.stat || !usr.is_in_active_hand(src)))
		return
	drawtype = temp
	update_window(usr)

/obj/item/toy/crayon/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	if(busy) return
	if(is_type_in_list(target,validSurfaces))
		var/temp = "rune"
		if(preset_message_index > 0)
			temp = "letter"
			drawtype = preset_message[preset_message_index]
		else if(letters.Find(drawtype))
			temp = "letter"
		else if(graffiti.Find(drawtype))
			temp = "graffiti"
		to_chat(user, "<span class='info'>You start drawing a [temp] on the [target.name].</span>")
		busy = TRUE
		if(instant || do_after(user, 50 * toolspeed, target = target))
			var/obj/effect/decal/cleanable/crayon/C = new /obj/effect/decal/cleanable/crayon(target,colour,drawtype,temp)
			C.add_hiddenprint(user)
			to_chat(user, "<span class='info'>You finish drawing [temp].</span>")

			if(preset_message_index > 0)
				preset_message_index++
				if(preset_message_index > length(preset_message))
					preset_message_index = 1
				update_window(usr)

			if(uses)
				uses--
				if(!uses)
					to_chat(user, "<span class='danger'>You used up your [name]!</span>")
					qdel(src)
		busy = FALSE

/obj/item/toy/crayon/attack(mob/M, mob/user)
	if(M == user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(!H.check_has_mouth())
				to_chat(user, "<span class='warning'>You do not have a mouth!</span>")
				return
		times_eaten++
		playsound(loc, 'sound/items/eatfood.ogg', 50, 0)
		user.adjust_nutrition(5)
		if(times_eaten < max_bites)
			to_chat(user, "<span class='notice'>You take a bite of the [name]. Delicious!</span>")
		else
			to_chat(user, "<span class='warning'>There is no more of [name] left!</span>")
			qdel(src)
	else
		..()

/obj/item/toy/crayon/examine(mob/user)
	. = ..()
	if(!user.Adjacent(src) || !times_eaten)
		return
	if(times_eaten == 1)
		. += "<span class='notice'>[src] was bitten by someone!</span>"
	else
		. += "<span class='notice'>[src] was bitten multiple times!</span>"

/obj/item/toy/crayon/red
	name = "red crayon"
	icon_state = "crayonred"
	colour = COLOR_RED
	colourName = "red"

/obj/item/toy/crayon/orange
	name = "orange crayon"
	icon_state = "crayonorange"
	colour = COLOR_ORANGE
	colourName = "orange"

/obj/item/toy/crayon/yellow
	name = "yellow crayon"
	icon_state = "crayonyellow"
	colour = COLOR_YELLOW
	colourName = "yellow"

/obj/item/toy/crayon/green
	name = "green crayon"
	icon_state = "crayongreen"
	colour = COLOR_GREEN
	colourName = "green"

/obj/item/toy/crayon/blue
	name = "blue crayon"
	icon_state = "crayonblue"
	colour = COLOR_BLUE
	colourName = "blue"

/obj/item/toy/crayon/purple
	name = "purple crayon"
	icon_state = "crayonpurple"
	colour = COLOR_PURPLE
	colourName = "purple"

/obj/item/toy/crayon/random/New()
	icon_state = pick("crayonred", "crayonorange", "crayonyellow", "crayongreen", "crayonblue", "crayonpurple")
	switch(icon_state)
		if("crayonred")
			name = "red crayon"
			colour = COLOR_RED
			colourName = "red"
		if("crayonorange")
			name = "orange crayon"
			colour = COLOR_ORANGE
			colourName = "orange"
		if("crayonyellow")
			name = "yellow crayon"
			colour = COLOR_YELLOW
			colourName = "yellow"
		if("crayongreen")
			name = "green crayon"
			colour =COLOR_GREEN
			colourName = "green"
		if("crayonblue")
			name = "blue crayon"
			colour = COLOR_BLUE
			colourName = "blue"
		if("crayonpurple")
			name = "purple crayon"
			colour = COLOR_PURPLE
			colourName = "purple"
	..()

/obj/item/toy/crayon/black
	name = "black crayon"
	icon_state = "crayonblack"
	colour = "#000000"
	colourName = "black"

/obj/item/toy/crayon/white
	name = "white crayon"
	icon_state = "crayonwhite"
	colour = "#FFFFFF"
	colourName = "white"

/obj/item/toy/crayon/white/chalk
	name = "detective's chalk"
	desc = "A stick of white chalk for marking crime scenes."
	gender = PLURAL
	toolspeed = 0.25

/obj/item/toy/crayon/mime
	name = "mime crayon"
	desc = "A very sad-looking crayon."
	icon_state = "crayonmime"
	colour = "#FFFFFF"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/mime/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='byond://?src=[UID()];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/mime/Topic(href,href_list)
	if(!Adjacent(usr) || usr.incapacitated())
		return
	if(href_list["color"])
		if(colour != COLOR_WHITE)
			colour = COLOR_WHITE
		else
			colour = COLOR_BLACK
		update_window(usr)
	else
		..()

/obj/item/toy/crayon/rainbow
	name = "rainbow crayon"
	icon_state = "crayonrainbow"
	colour = "#FFF000"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/rainbow/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='byond://?src=[UID()];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/rainbow/Topic(href,href_list[])
	if(!Adjacent(usr) || usr.incapacitated())
		return
	if(href_list["color"])
		var/temp = input(usr, "Please select colour.", "Crayon colour") as color
		colour = temp
		update_window(usr)
	else
		..()


//Spraycan stuff

/obj/item/toy/crayon/spraycan
	name = "\improper Nanotrasen-brand Rapid Paint Applicator"
	desc = "A metallic container containing spray paint."
	icon_state = "spraycan_cap"
	slot_flags = SLOT_FLAG_BELT
	var/capped = TRUE
	instant = TRUE
	validSurfaces = list(/turf/simulated/floor,/turf/simulated/wall)

/obj/item/toy/crayon/spraycan/New()
	..()
	update_icon()

/obj/item/toy/crayon/spraycan/attack(mob/M, mob/user)
	return // To stop you from eating spraycans. It's TOO SILLY!

/obj/item/toy/crayon/spraycan/attack_self(mob/living/user)
	var/choice = tgui_input_list(user, "Do you want to...", "Spraycan Options", list("Toggle Cap","Change Drawing", "Change Color"))
	switch(choice)
		if("Toggle Cap")
			to_chat(user, "<span class='notice'>You [capped ? "remove" : "replace"] the cap of [src].</span>")
			capped = !capped
			update_icon()
		if("Change Drawing")
			..()
		if("Change Color")
			colour = input(user,"Choose Color") as color
			update_icon()

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity)
		return
	if(capped)
		to_chat(user, "<span class='warning'>You cannot spray [target] while the cap is still on!</span>")
		return
	if(istype(target, /obj/item/clothing/head/cardborg) || istype(target, /obj/item/clothing/suit/cardborg))	// Spraypainting your cardborg suit for more fashion options.
		cardborg_recolor(target, user)
		return
	if(iscarbon(target))
		if(uses - 10 > 0)
			uses = uses - 10
			var/mob/living/carbon/C = target
			user.visible_message("<span class='danger'> [user] sprays [src] into the face of [target]!</span>")
			if(C.client)
				C.EyeBlurry(6 SECONDS)
				C.EyeBlind(2 SECONDS)
				if(ishuman(target))
					var/mob/living/carbon/human/H = target
					if(H.check_eye_prot() <= 0) // no eye protection? ARGH IT BURNS.
						H.Confused(6 SECONDS)
						H.KnockDown(6 SECONDS)
					H.lip_style = "spray_face"
					H.lip_color = colour
					H.update_body()
	playsound(user, 'sound/effects/spray.ogg', 5, TRUE, 5)
	..()

/obj/item/toy/crayon/spraycan/update_icon_state()
	icon_state = "spraycan[capped ? "_cap" : ""]"

/obj/item/toy/crayon/spraycan/update_overlays()
	. = ..()
	var/image/I = image('icons/obj/crayons.dmi',icon_state = "[capped ? "spraycan_cap_colors" : "spraycan_colors"]")
	I.color = colour
	. += I

/obj/item/toy/crayon/spraycan/proc/cardborg_recolor(obj/target, mob/user)
	var/is_cardborg_head = CARDBORG_BODY
	if(istype(target, /obj/item/clothing/head/cardborg))    // Differentiating between head and body.
		is_cardborg_head = CARDBORG_HEAD
	var/selected_disguise
	var/static/list/disguise_options = list(
		"Standard" = image('icons/mob/robots.dmi', "Standard"),
		"Security" = image('icons/mob/robots.dmi', "security-radial"),
		"Engineering" = image('icons/mob/robots.dmi', "engi-radial"),
		"Mining" = image('icons/mob/robots.dmi', "mining-radial"),
		"Service" = image('icons/mob/robots.dmi', "serv-radial"),
		"Medical" = image('icons/mob/robots.dmi', "med-radial"),
		"Janitor" = image('icons/mob/robots.dmi', "jan-radial"),
		"Hunter" = image('icons/mob/robots.dmi', "xeno-radial"),
		"Death Bot" = image('icons/mob/robots.dmi', "syndie-bloodhound-preview")
		)
	selected_disguise = show_radial_menu(user, target, disguise_options, require_near = TRUE, radius = 42)

	if(!selected_disguise)
		return
	var/static/list/disguise_spraypaint_items = list(
		"Standard" = list(/obj/item/clothing/head/cardborg, /obj/item/clothing/suit/cardborg),
		"Security" = list(/obj/item/clothing/head/cardborg/security, /obj/item/clothing/suit/cardborg/security),
		"Engineering" = list(/obj/item/clothing/head/cardborg/engineering, /obj/item/clothing/suit/cardborg/engineering),
		"Mining" = list(/obj/item/clothing/head/cardborg/mining, /obj/item/clothing/suit/cardborg/mining),
		"Service" = list(/obj/item/clothing/head/cardborg/service, /obj/item/clothing/suit/cardborg/service),
		"Medical" = list(/obj/item/clothing/head/cardborg/medical, /obj/item/clothing/suit/cardborg/medical),
		"Janitor" = list(/obj/item/clothing/head/cardborg/janitor, /obj/item/clothing/suit/cardborg/janitor),
		"Hunter" = list(/obj/item/clothing/head/cardborg/xeno, /obj/item/clothing/suit/cardborg/xeno),
		"Death Bot" = list(/obj/item/clothing/head/cardborg/deathbot, /obj/item/clothing/suit/cardborg/deathbot)
	)
	selected_disguise = disguise_spraypaint_items[selected_disguise][is_cardborg_head]
	playsound(user, 'sound/effects/spray.ogg', 5, TRUE, 5)
	user.unEquip(target)
	user.put_in_hands(new selected_disguise())	// Spawn the desired cardborg item.
	qdel(target)								// Get rid of the old one.

#undef CRAYON_MESSAGE_MAX_LENGTH
#undef CARDBORG_HEAD
#undef CARDBORG_BODY
