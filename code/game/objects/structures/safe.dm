/*
CONTAINS:
SAFES
FLOOR SAFES
*/

//SAFES
/obj/structure/safe
	name = "\improper Safe"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms - 2 tumbler safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	anchored = 1
	density = 1
	var/open = 0		//is the safe open?
	var/unlocked = 0
	var/tumbler_1_pos	//the tumbler position- from 0 to 72
	var/tumbler_1_open	//the tumbler position to open at- 0 to 72
	var/tumbler_2_pos
	var/tumbler_2_open
	var/open_pos
	var/dial = 0		//where is the dial pointing?
	var/space = 0		//the combined w_class of everything in the safe
	var/maxspace = 24	//the maximum combined w_class of stuff in the safe
	var/combo_to_open	//so admins know the code


/obj/structure/safe/New()
	tumbler_2_pos = rand(0, 99) // first value in the combination set first
	tumbler_2_open = rand(0, 99)

	tumbler_1_pos = rand(0, 99)
	do
	tumbler_1_open = rand(0, 99)
	while(tumbler_1_open > Wrap(tumbler_2_open +48, 0, 100) && tumbler_1_open < Wrap(tumbler_2_open + 53, 0, 100)) // prevents a combination that wont open
	do
		open_pos = rand(0,99)
	while(open_pos > Wrap(tumbler_1_open - 2, 0, 100) && open_pos < Wrap(tumbler_1_open + 2, 0, 100)) // prevents a combination that wont open
	var/num1 = tumbler_2_open + 54
	if(num1 > 99)
		num1 = num1 - 100
	var/num2 = tumbler_1_open + 98
	if(num2 > 99)
		num2 = num2 - 100

	combo_to_open = "Go right past [num1] twice then stop at [num1]. Go left past [num2] once then stop at [num2]. Turn right till it stops and its open."

/obj/structure/safe/Initialize()
	..()
	for(var/obj/item/I in loc)
		if(space >= maxspace)
			return
		if(I.w_class + space <= maxspace)
			space += I.w_class
			I.loc = src


/obj/structure/safe/proc/check_unlocked()
	if(tumbler_1_pos == tumbler_1_open && tumbler_2_pos == tumbler_2_open && dial == open_pos)
		unlocked = 1
		return 1
	unlocked = 0
	return 0

/obj/structure/safe/proc/make_noise(tum1_turns, tum2_turns, mob/user, canhear)
	if(user && canhear)
		var/tum1_tmp = tum1_turns
		var/tum2_tmp = tum2_turns
		while(tum1_tmp >= 1 || tum2_tmp >= 1)
			if(tum1_tmp >= 1)
				to_chat(user, "<span class='italics'>You hear a [pick("clack", "scrape", "clank")] from [src].</span>")
				tum1_tmp = tum1_tmp - rand(4, 8)
			if(tum2_tmp >= 1)
				to_chat(user, "<span class='italics'>You hear a [pick("click", "chink", "clink")] from [src].</span>")
				tum2_tmp = tum2_tmp - rand(4, 8)
			if(tumbler_1_pos == tumbler_1_open && tum1_turns == 1) // You cant hear tumblers if you spin fast!
				to_chat(user, "<span class='italics'>You hear a [pick("tonk", "krunk", "plunk")] from [src].</span>")
			if(tumbler_2_pos == tumbler_2_open && tum1_turns == 1 && tum2_turns == 1) // You cant hear tumblers if you spin fast!
				to_chat(user, "<span class='italics'>You hear a [pick("tink", "krink", "plink")] from [src].</span>")
	if(unlocked)
		if(user)
			visible_message("<i><b>[pick("Spring", "Sprang", "Sproing", "Clunk", "Krunk")]!</b></i>")

/obj/structure/safe/update_icon()
	if(open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)

/obj/structure/safe/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)
	return

/obj/structure/safe/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "safe.tmpl", name, 600, 750)
		ui.open()
		ui.set_auto_update(1)

/obj/structure/safe/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	var/list/contents_names = list()
	if(open)
		for(var/obj/O in contents)
			contents_names[++contents_names.len] = list("name" = O.name, "index" = contents.Find(O))
	else
		contents_names = list(list("name" = "you're"), list("name" = "a"), list("name" = "cheater"))

	data["dial"] = dial
	data["open"] = open
	data["unlocked"] = unlocked
	data["rotation"] = "[-dial*3.6]deg"
	data["contents"] = contents_names

	return data


/obj/structure/safe/Topic(href, href_list)
	if(..())
		return 1

	var/canhear = 0
	if(!ishuman(usr))
		to_chat(usr, "You don't have hands to operate the safe!")
		return 0

	var/mob/living/carbon/human/user = usr
	if(istype(user.l_hand, /obj/item/clothing/accessory/stethoscope) || istype(user.r_hand, /obj/item/clothing/accessory/stethoscope))
		canhear = 1

	if(href_list["open"])
		if(check_unlocked() || open)
			to_chat(user, "<span class='notice'>You [open ? "close" : "open"] [src].</span>")
			open = !open
			update_icon()
			.=1
		else
			to_chat(user, "<span class='warning'>You can't open [src], the lock is engaged!</span>")
			.=1

	if(href_list["decrement"])
		var/ticks = text2num(href_list["decrement"])
		var/tum1_turns = 0
		var/tum2_turns = 0
		if(open)
			return
		for(var/i=1 to ticks)
			if(!check_unlocked())
				dial = Wrap(dial - 1, 0 ,100)
				if(dial == tumbler_1_pos + 1 || dial == tumbler_1_pos - 99)
					tumbler_1_pos = Wrap(tumbler_1_pos - 1, 0, 100)
					tum1_turns++
					if(tumbler_1_pos == tumbler_2_pos + 51 || tumbler_1_pos == tumbler_2_pos - 49)
						tumbler_2_pos = Wrap(tumbler_2_pos - 1, 0, 100)
						tum2_turns++
			sleep(world.tick_lag)
			SSnanoui.update_uis(src)
		check_unlocked()
		make_noise(tum1_turns, tum2_turns, user, canhear)
		.=1

	if(href_list["increment"])
		var/ticks = text2num(href_list["increment"])
		var/tum1_turns = 0
		var/tum2_turns = 0
		if(open)
			return
		for(var/i=1 to ticks)
			check_unlocked()
			dial = Wrap(dial + 1, 0, 100)
			if(dial == tumbler_1_pos - 1 || dial == tumbler_1_pos + 99)
				tumbler_1_pos = Wrap(tumbler_1_pos + 1, 0, 100)
				tum1_turns++
				if(tumbler_1_pos == tumbler_2_pos - 51 || tumbler_1_pos == tumbler_2_pos + 49)
					tumbler_2_pos = Wrap(tumbler_2_pos + 1, 0, 100)
					tum2_turns++
			sleep(world.tick_lag)
			SSnanoui.update_uis(src)
		make_noise(tum1_turns, tum2_turns, user, canhear)
		.=1

	if(href_list["retrieve"])
		var/index = text2num(href_list["retrieve"])
		if(index > 0 && index <= contents.len)
			var/obj/item/P = contents[index]
			if(open)
				if(P && in_range(src, user))
					user.put_in_hands(P)
		.=1

	updateUsrDialog()
	SSnanoui.update_uis(src)
	return


/obj/structure/safe/attackby(obj/item/I, mob/user, params)
	if(open)
		if(I.w_class + space <= maxspace)
			space += I.w_class
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in the safe!</span>")
				return
			I.loc = src
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
			updateUsrDialog()
			return
		else
			to_chat(user, "<span class='notice'>[I] won't fit in [src].</span>")
			return
	else
		if(istype(I, /obj/item/clothing/accessory/stethoscope))
			to_chat(user, "<span class='warning'>Hold [I] in one of your hands while you manipulate the dial!</span>")
			return
		else
			to_chat(user, "<span class='warning'>You can't put [I] in into the safe while it is closed!</span>")
			return


obj/structure/safe/blob_act()
	return

obj/structure/safe/ex_act(severity)
	return


//FLOOR SAFES
/obj/structure/safe/floor
	name = "floor safe"
	icon_state = "floorsafe"
	density = 0
	level = 1	//underfloor
	layer = 2.5


/obj/structure/safe/floor/Initialize()
	..()
	var/turf/T = loc
	hide(T.intact)


/obj/structure/safe/floor/hide(var/intact)
	invisibility = intact ? 101 : 0