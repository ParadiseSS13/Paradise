/*
 * Crayons
 */

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_BELT | SLOT_EARS
	attack_verb = list("attacked", "coloured")
	toolspeed = 1
	var/colour = "#FF0000" //RGB
	var/drawtype = "rune"
	var/list/graffiti = list("body","amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","up","down","left","right","heart","borgsrogue","voxpox","shitcurity","catbeast","hieroglyphs1","hieroglyphs2","hieroglyphs3","security","syndicate1","syndicate2","nanotrasen","lie","valid","arrowleft","arrowright","arrowup","arrowdown","chicken","hailcrab","brokenheart","peace","scribble","scribble2","scribble3","skrek","squish","tunnelsnake","yip","youaredead")
	var/list/letters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes
	var/dat
	var/list/validSurfaces = list(/turf/simulated/floor)

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is jamming the [name] up [user.p_their()] nose and into [user.p_their()] brain. It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return (BRUTELOSS|OXYLOSS)

/obj/item/toy/crayon/New()
	..()
	name = "[colourName] crayon" //Makes crayons identifiable in things like grinders
	drawtype = pick(pick(graffiti), pick(letters), "rune[rand(1,10)]")

/obj/item/toy/crayon/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/proc/update_window(mob/living/user as mob)
	dat += "<center><h2>Currently selected: [drawtype]</h2><br>"
	dat += "<a href='?src=[UID()];type=random_letter'>Random letter</a><a href='?src=[UID()];type=letter'>Pick letter</a>"
	dat += "<hr>"
	dat += "<h3>Runes:</h3><br>"
	dat += "<a href='?src=[UID()];type=random_rune'>Random rune</a>"
	for(var/i = 1; i <= 10; i++)
		dat += "<a href='?src=[UID()];type=rune[i]'>Rune[i]</a>"
		if(!((i + 1) % 3)) //3 buttons in a row
			dat += "<br>"
	dat += "<hr>"
	graffiti.Find()
	dat += "<h3>Graffiti:</h3><br>"
	dat += "<a href='?src=[UID()];type=random_graffiti'>Random graffiti</a>"
	var/c = 1
	for(var/T in graffiti)
		dat += "<a href='?src=[UID()];type=[T]'>[T]</a>"
		if(!((c + 1) % 3)) //3 buttons in a row
			dat += "<br>"
		c++
	dat += "<hr>"
	var/datum/browser/popup = new(user, "crayon", name, 300, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	dat = ""

/obj/item/toy/crayon/Topic(href, href_list, hsrc)
	var/temp = "a"
	switch(href_list["type"])
		if("random_letter")
			temp = pick(letters)
		if("letter")
			temp = input("Choose the letter.", "Scribbles") in letters
		if("random_rune")
			temp = "rune[rand(1,10)]"
		if("random_graffiti")
			temp = pick(graffiti)
		else
			temp = href_list["type"]
	if((usr.restrained() || usr.stat || !usr.is_in_active_hand(src)))
		return
	drawtype = temp
	update_window(usr)

/obj/item/toy/crayon/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	if(is_type_in_list(target,validSurfaces))
		var/temp = "rune"
		if(letters.Find(drawtype))
			temp = "letter"
		else if(graffiti.Find(drawtype))
			temp = "graffiti"
		to_chat(user, "You start drawing a [temp] on the [target.name].")
		if(instant || do_after(user, 50 * toolspeed, target = target))
			var/obj/effect/decal/cleanable/crayon/C = new /obj/effect/decal/cleanable/crayon(target,colour,drawtype,temp)
			C.add_hiddenprint(user)
			to_chat(user, "You finish drawing [temp].")
			if(uses)
				uses--
				if(!uses)
					to_chat(user, "<span class='danger'>You used up your [name]!</span>")
					qdel(src)

/obj/item/toy/crayon/attack(mob/M, mob/user)
	var/huffable = istype(src,/obj/item/toy/crayon/spraycan)
	if(M == user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(!H.check_has_mouth())
				to_chat(user, "<span class='warning'>You do not have a mouth!</span>")
				return
		playsound(loc, 'sound/items/eatfood.ogg', 50, 0)
		to_chat(user, "<span class='notice'>You take a [huffable ? "huff" : "bite"] of the [name]. Delicious!</span>")
		user.nutrition += 5
		if(uses)
			uses -= 5
			if(uses <= 0)
				to_chat(user, "<span class='warning'>There is no more of [name] left!</span>")
				qdel(src)
	else
		..()


/obj/item/toy/crayon/red
	icon_state = "crayonred"
	colour = "#DA0000"
	colourName = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	colour = "#FF9300"
	colourName = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	colour = "#FFF200"
	colourName = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	colour = "#A8E61D"
	colourName = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	colour = "#00B7EF"
	colourName = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	colour = "#DA00FF"
	colourName = "purple"

/obj/item/toy/crayon/random/New()
	icon_state = pick(list("crayonred", "crayonorange", "crayonyellow", "crayongreen", "crayonblue", "crayonpurple"))
	switch(icon_state)
		if("crayonred")
			colour = "#DA0000"
			colourName = "red"
		if("crayonorange")
			colour = "#FF9300"
			colourName = "orange"
		if("crayonyellow")
			colour = "#FFF200"
			colourName = "yellow"
		if("crayongreen")
			colour = "#A8E61D"
			colourName = "green"
		if("crayonblue")
			colour = "#00B7EF"
			colourName = "blue"
		if("crayonpurple")
			colour = "#DA00FF"
			colourName = "purple"
	..()

/obj/item/toy/crayon/white
	icon_state = "crayonwhite"
	colour = "#FFFFFF"
	colourName = "white"

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	colour = "#FFFFFF"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/mime/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='?src=[UID()];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/mime/Topic(href,href_list)
	if(!Adjacent(usr) || usr.incapacitated())
		return
	if(href_list["color"])
		if(colour != "#FFFFFF")
			colour = "#FFFFFF"
		else
			colour = "#000000"
		update_window(usr)
	else
		..()

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	colour = "#FFF000"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/rainbow/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='?src=[UID()];color=1'>Change color</a></center>"
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
	icon_state = "spraycan_cap"
	desc = "A metallic container containing tasty paint."
	var/capped = 1
	instant = 1
	validSurfaces = list(/turf/simulated/floor,/turf/simulated/wall)

/obj/item/toy/crayon/spraycan/New()
	..()
	name = "Nanotrasen-brand Rapid Paint Applicator"
	update_icon()

/obj/item/toy/crayon/spraycan/attack_self(mob/living/user as mob)
	var/choice = input(user,"Spraycan options") in list("Toggle Cap","Change Drawing","Change Color")
	switch(choice)
		if("Toggle Cap")
			to_chat(user, "<span class='notice'>You [capped ? "Remove" : "Replace"] the cap of the [src]</span>")
			capped = capped ? 0 : 1
			icon_state = "spraycan[capped ? "_cap" : ""]"
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
		return
	else
		if(iscarbon(target))
			if(uses-10 > 0)
				uses = uses - 10
				var/mob/living/carbon/human/C = target
				user.visible_message("<span class='danger'> [user] sprays [src] into the face of [target]!</span>")
				if(C.client)
					C.EyeBlurry(3)
					C.EyeBlind(1)
					if(C.check_eye_prot() <= 0) // no eye protection? ARGH IT BURNS.
						C.Confused(3)
						C.Weaken(3)
				C.lip_style = "spray_face"
				C.lip_color = colour
				C.update_body()
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
		..()

/obj/item/toy/crayon/spraycan/update_icon()
	overlays.Cut()
	var/image/I = image('icons/obj/crayons.dmi',icon_state = "[capped ? "spraycan_cap_colors" : "spraycan_colors"]")
	I.color = colour
	overlays += I
