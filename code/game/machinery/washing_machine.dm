/obj/machinery/washing_machine
	name = "\improper washing machine"
	desc = "An advanced washing machine, a washer and dryer all rolled up into one.\nGets rid of those pesky bloodstains, or your money back!"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = 1
	anchored = 1
	var/state = 1
	//1 = empty, open door
	//2 = empty, closed door
	//3 = full, open door
	//4 = full, closed door
	//5 = running
	//6 = blood, open door
	//7 = blood, closed door
	//8 = blood, running
	var/open = TRUE
	var/full = FALSE
	var/running = FALSE
	var/bloody = FALSE
	var/mobblooddna
	var/panel = 0
	//0 = closed
	//1 = open
	var/obj/crayon

	var/washing_damage = 20 // how much damage a single cycle should do // 20 is just enough damage to kill Ian
	var/washing_time = 15 SECONDS // how long a single cycle should take
	var/damage_time = 1 SECONDS // how often to damage the occupant
	var/hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg') // sounds made when occupant is damaged
	var/resist_time

// todo: use alt click to start the washing machine [X]
// Make washing machines more intuitive
// Mouse drag to put simplemobs in them [X]
// Clean up that damn color code lol [MAIN REASON FOR THIS]
// Make it so you can resist out of washing machines []
// convert states to vars []
// You can now drag small animals/people into washing machines [X]
// you can now kill people with washing machines [X]
// make washing machines require power []
// message for trying to put people/things/animals into the washing machine when the door is closed [X]
// If the washing machine is bloody, make shit inside of it covered in blood of whoever bled in there []
// Make washing machines release their contents when destroyed []
// Make any person/clothes inside the washing machine very bloody if used []

// Make showers not clean your clothes? []

/obj/machinery/washing_machine/AltClick(mob/living/user)
	if(!istype(usr, /mob/living))
		return
	if(running)
		to_chat(usr, "<span class='notice'>\The [src] is already running.</span>")
		return
	if(open && bloody)
		to_chat(usr, "<span class='notice'>You start \the [src] to clean it out.</span>")
	else
		if(!full)
			to_chat(usr, "<span class='notice'>\The [src] is empty, there is nothing to clean.</span>")
			return

	playsound(src, 'sound/machines/click.ogg', 25)
	running = TRUE
	open = FALSE
	if(locate(/mob,contents))
		var/mob/living/M = locate(/mob,contents)
		if(user == M)
			to_chat(M, "<span class='warning'>You activate \the [src] and quickly close the door on yourself!</span>")
		bloody = TRUE
		update_icon()
		add_attack_logs(user, M, "activated a washing machine with them inside")
		M.emote("scream")
		to_chat(M, "<span class='userdanger'>\The [src] slams your body into the walls repeatedly as the washing machine spins!</span>")
		for(var/I in 1 to (washing_time/damage_time))
			M.adjustBruteLoss(washing_damage/(washing_time/damage_time))
			playsound(src, pick(hit_sound), 10)
			sleep(damage_time)
			I++
		M.AdjustConfused(3 SECONDS)
	else
		update_icon()
		for(var/I in 1 to (washing_time/damage_time))
			playsound(src, 'sound/weapons/jug_filled_impact.ogg', 10)
			sleep(damage_time)
			I++

	if(bloody)
		for(var/atom/A in contents)
			A.clean_blood()

	//Tanning!
	for(var/obj/item/stack/sheet/hairlesshide/HH in contents)
		var/obj/item/stack/sheet/wetleather/WL = new(src)
		WL.amount = HH.amount
		qdel(HH)

	if(crayon)
		var/wash_color
		if(istype(crayon,/obj/item/toy/crayon))
			var/obj/item/toy/crayon/CR = crayon
			wash_color = CR.colourName
		else if(istype(crayon,/obj/item/stamp))
			var/obj/item/stamp/ST = crayon
			wash_color = ST.item_color

		if(wash_color)
			var/new_jumpsuit_icon_state = ""
			var/new_jumpsuit_item_state = ""
			var/new_jumpsuit_name = ""
			var/new_glove_icon_state = ""
			var/new_glove_item_state = ""
			var/new_glove_name = ""
			var/new_bandana_icon_state = ""
			var/new_bandana_item_state = ""
			var/new_bandana_name = ""
			var/new_shoe_icon_state = ""
			var/new_shoe_name = ""
			var/new_sheet_icon_state = ""
			var/new_sheet_name = ""
			var/new_softcap_icon_state = ""
			var/new_softcap_name = ""
			var/new_desc = "The colors are a bit dodgy."
			for(var/T in typesof(/obj/item/clothing/under))
				var/obj/item/clothing/under/J = new T
				if(wash_color == J.item_color)
					new_jumpsuit_icon_state = J.icon_state
					new_jumpsuit_item_state = J.item_state
					new_jumpsuit_name = J.name
					qdel(J)
					break
				qdel(J)
			for(var/T in typesof(/obj/item/clothing/gloves/color))
				var/obj/item/clothing/gloves/color/G = new T
				if(wash_color == G.item_color)
					new_glove_icon_state = G.icon_state
					new_glove_item_state = G.item_state
					new_glove_name = G.name
					qdel(G)
					break
				qdel(G)
			for(var/T in typesof(/obj/item/clothing/shoes))
				var/obj/item/clothing/shoes/S = new T
				if(wash_color == S.item_color)
					new_shoe_icon_state = S.icon_state
					new_shoe_name = S.name
					qdel(S)
					break
				qdel(S)
			for(var/T in typesof(/obj/item/clothing/mask/bandana))
				var/obj/item/clothing/mask/bandana/M = new T
				if(wash_color == M.item_color)
					new_bandana_icon_state = M.icon_state
					new_bandana_item_state = M.item_state
					new_bandana_name = M.name
					qdel(M)
					break
				qdel(M)
			for(var/T in typesof(/obj/item/bedsheet))
				var/obj/item/bedsheet/B = new T
				if(wash_color == B.item_color)
					new_sheet_icon_state = B.icon_state
					new_sheet_name = B.name
					qdel(B)
					break
				qdel(B)
			for(var/T in typesof(/obj/item/clothing/head/soft))
				var/obj/item/clothing/head/soft/H = new T
				if(wash_color == H.item_color)
					new_softcap_icon_state = H.icon_state
					new_softcap_name = H.name
					qdel(H)
					break
				qdel(H)
			if(new_jumpsuit_icon_state && new_jumpsuit_item_state && new_jumpsuit_name)
				for(var/obj/item/clothing/under/J in contents)
					if(!J.dyeable)
						continue
					J.item_state = new_jumpsuit_item_state
					J.icon_state = new_jumpsuit_icon_state
					J.item_color = wash_color
					J.name = new_jumpsuit_name
					J.desc = new_desc
			if(new_glove_icon_state && new_glove_item_state && new_glove_name)
				for(var/obj/item/clothing/gloves/color/G in contents)
					if(!G.dyeable)
						continue
					G.item_state = new_glove_item_state
					G.icon_state = new_glove_icon_state
					G.item_color = wash_color
					G.name = new_glove_name
					if(!istype(G, /obj/item/clothing/gloves/color/black/thief))
						G.desc = new_desc
			if(new_shoe_icon_state && new_shoe_name)
				for(var/obj/item/clothing/shoes/S in contents)
					if(!S.dyeable)
						continue
					if(S.chained == 1)
						S.chained = 0
						S.slowdown = SHOES_SLOWDOWN
						new /obj/item/restraints/handcuffs( src )
					S.icon_state = new_shoe_icon_state
					S.item_color = wash_color
					S.name = new_shoe_name
					S.desc = new_desc
			if(new_bandana_icon_state && new_bandana_name)
				for(var/obj/item/clothing/mask/bandana/M in contents)
					if(!M.dyeable)
						continue
					M.item_state = new_bandana_item_state
					M.icon_state = new_bandana_icon_state
					M.item_color = wash_color
					M.name = new_bandana_name
					M.desc = new_desc
			if(new_sheet_icon_state && new_sheet_name)
				for(var/obj/item/bedsheet/B in contents)
					B.icon_state = new_sheet_icon_state
					B.item_color = wash_color
					B.name = new_sheet_name
					B.desc = new_desc
			if(new_softcap_icon_state && new_softcap_name)
				for(var/obj/item/clothing/head/soft/H in contents)
					if(!H.dyeable)
						continue
					H.icon_state = new_softcap_icon_state
					H.item_color = wash_color
					H.name = new_softcap_name
					H.desc = new_desc
		QDEL_NULL(crayon)

	running = FALSE
	if(!full)
		bloody = FALSE
	else
		playsound(src, 'sound/weapons/jug_filled_impact.ogg', 25)
	update_icon()
	sleep (5)
	playsound(src, 'sound/machines/defib_success.ogg', 25)


/* /obj/machinery/washing_machine/verb/climb_out() // THIS DOESNT EVEN WORK
	set name = "Climb out"
	set category = "Object"
	set src in usr.loc

	sleep(20)
	if(state in list(1,3,6) )
		usr.loc = src.loc */

/obj/machinery/washing_machine/proc/resist_open(mob/user)

/obj/machinery/washing_machine/update_icon()
	if(bloody)
		if(running)
			state = 8
		else
			if(open)
				state = 6
			else
				state = 7
	else
		if(running)
			state = 5
		else
			if(full)
				if(open)
					state = 3
				else
					state = 4
			else
				if(open)
					state = 1
				else
					state = 2
	icon_state = "wm_[state][panel]"

/obj/machinery/washing_machine/attackby(obj/item/W, mob/user, params)
	/*if(istype(W,/obj/item/screwdriver))
		panel = !panel
		to_chat(user, "<span class='notice'>you [panel ? </span>"open" : "close"] the [src]'s maintenance panel")*/
	if(istype(W, /obj/item/reagent_containers/spray/cleaner) || istype(W, /obj/item/soap))
		user.visible_message("<span class='notice'>[user] starts to clean [src].</span>", "<span class='notice'>You start to clean [src].</span>")
		if(do_after(user, 10 * W.toolspeed, target = src))
			user.visible_message("<span class='notice'>[user] has cleaned [src].</span>", "<span class='notice'>You have cleaned [src].</span>")
	if(bloody && open)
		to_chat(user, "<span class='warning'>\The [src] is filled with blood! It won't clean anything until the blood is cleaned out.</span>")
	if(default_unfasten_wrench(user, W))
		power_change()
		return
	if(istype(W,/obj/item/toy/crayon) || istype(W,/obj/item/stamp))
		if(open && !bloody)
			if(!crayon)
				user.drop_item()
				crayon = W
				crayon.loc = src
				update_icon()
			else
				return ..()
		else
			return ..()
	else if(istype(W,/obj/item/grab))
		if(open && !full)
			var/obj/item/grab/G = W
			if((ishuman(G.assailant) && isanimal(G.affecting) && !ishostile(G.affecting) && !isbot(G.affecting)) || (ishuman(G.assailant) && ishuman(G.affecting) && HAS_TRAIT(G.affecting, TRAIT_DWARF)))
				if(ishuman(G.assailant) && ishuman(G.affecting) && HAS_TRAIT(G.affecting, TRAIT_DWARF) && (G.state < GRAB_AGGRESSIVE))
					to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
				else
					visible_message("[user] starts putting [G.affecting.name] into \the [src].")
					if(do_after(user, 20, target = G.affecting))
						visible_message("[user] puts [G.affecting.name] into \the [src].")
						add_fingerprint(user)
						G.affecting.loc = src
						qdel(G)
						full = TRUE
			update_icon()
		else
			if(!open)
				to_chat(user, "<span class='notice'>\The [src]'s door is closed.</span>")
			else
				to_chat(user, "<span class='notice'>You can't fit [W] in \the [src].</span>")
			return ..()
	else if(istype(W,/obj/item/stack/sheet/hairlesshide) || \
		istype(W,/obj/item/clothing/under) || \
		istype(W,/obj/item/clothing/mask) || \
		istype(W,/obj/item/clothing/head) || \
		istype(W,/obj/item/clothing/gloves) || \
		istype(W,/obj/item/clothing/shoes) || \
		istype(W,/obj/item/clothing/suit) || \
		istype(W,/obj/item/bedsheet))

		//YES, it's hardcoded... saves a var/can_be_washed for every single clothing item.
		//var/list/prohibited = list(/obj/item/clothing/under/plasmaman, /obj/item/clothing/suit/space, /obj/item/clothing/suit/syndicatefake, /obj/item/clothing/suit/bomb_suit, /obj/item/clothing/suit/armor, /obj/item/clothing/mask/gas, /obj/item/clothing/head/syndicatefake, /obj/item/clothing/head/helmet, /obj/item/clothing/gloves/furgloves)
		//var/list/prohibited2 = list(/obj/item/clothing/mask/cigarette, /obj/item/clothing/suit/cyborg_suit) // make the cig into a cig butt, make the cyborg suit into 4 cardboard
/*		for(W in prohibited)
			to_chat(user, "This item does not fit.")
			return
		for(W in prohibited2)
			to_chat(user, "Washing this would be a bad idea...")
			return */
		if(istype(W, /obj/item/clothing/gloves/color/black/krav_maga/sec))
			to_chat(user, "<span class='warning'>Washing these gloves would fry the electronics!</span>")
			return
		if(W.flags & NODROP) //if "can't drop" item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in the washing machine!</span>")
			return

		if(contents.len < 10)
			if(!locate(/mob,contents)) // This should block adding any extra items
				if(open && !bloody)
					user.drop_item()
					W.loc = src
					full = TRUE
				else
					to_chat(user, "<span class='notice'>You can't put the item in right now.</span>")
			else
				var/mobinside = locate(/mob,contents)
				to_chat(user, "<span class='notice'>The washing machine is is occupied by [mobinside], there's no extra space.</span>")
		else
			to_chat(user, "<span class='notice'>The washing machine is full.</span>")
		update_icon()
	else
		return ..()

/obj/machinery/washing_machine/attack_hand(mob/user as mob)
	if(running) // States 5 and 8
		to_chat(usr, "<span class='warning'>\The [src] is busy.</span>")
	else
		if(bloody)
			if(open) // 6
				to_chat(usr, "<span class='notice'>\The [src] only contains blood, there is nothing to remove from it.</span>")
			else // 7
				if(!ishuman(locate(/mob,contents)))
					if(locate(/mob,contents))
						var/mob/M = locate(/mob,contents)
						M.gib()
					to_chat(usr, "<span class='narsie'>You monster.</span>")
				for(var/atom/movable/O in contents) // it empties here because gibs would explode when opening the door
					O.loc = src.loc
				crayon = null
				full = FALSE
				open = TRUE
				playsound(src, 'sound/machines/click.ogg', 25)
		else
			if(full)
				if(open) // 3
					to_chat(usr, "<span class='notice'>You empty \the [src].</span>")
					for(var/atom/movable/O in contents)
						O.loc = src.loc
					crayon = null
					full = FALSE
				else // 4
					to_chat(usr, "<span class='notice'>You open the door on \the [src].</span>")
					open = TRUE
					playsound(src, 'sound/machines/click.ogg', 25)
			else
				if(open) // 1
					to_chat(usr, "<span class='notice'>\The [src] is empty, there is nothing to remove from it.</span>")
					for(var/atom/movable/O in contents) // We'll try anyways, just in case
						O.loc = src.loc
					crayon = null
				else // 2
					to_chat(usr, "<span class='notice'>You open the door on \the [src].</span>")
					open = TRUE
					playsound(src, 'sound/machines/click.ogg', 25)

	update_icon()

/obj/machinery/washing_machine/examine(mob/user)
	. = ..()
	var/contentsjoined = contents.Join(", ")
	if(length(contents))
		. += "<span class='notice'>\The [src] contains [contentsjoined].</span>"
	else
		. += "<span class='notice'>\The [src] is empty.</span>"
	if(bloody)
		. += "<span class='warning'>\The [src] filled with blood!</span>"

/obj/machinery/washing_machine/deconstruct(disassembled = TRUE) // TODO: make washing machines orderable from cargo and not do this by being metalizied, also make the contents not get deleted
	new /obj/item/stack/sheet/metal(drop_location(), 2)
	qdel(src)

/obj/machinery/washing_machine/MouseDrop_T(atom/movable/O, mob/user)
	var/mob/living/L = O
	if(running)
		to_chat(usr, "<span class='warning'>\The [src] is busy.</span>")
		return
	if(ishuman(user) && ishuman(L) && HAS_TRAIT(L, TRAIT_DWARF) && (user != L))
		to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
		return
	if(full)
		to_chat(user, "<span class='warning'>\The [src] needs to be empty to fit [L] inside.</span>")
		return
	if(open && !bloody && !full)
		if((ishuman(user) && isanimal(L) && !ishostile(L) && !isbot(L)) || ishuman(L))
			if(L == user)
				visible_message("[user] starts climbing into \the [src].")
			else
				visible_message("[user] starts putting [L.name] into \the [src].")
			if(do_after(user, 20, target = L))
				if(!L)
					return
				L.forceMove(src)
				add_fingerprint(user)
				if(user.pulling == L)
					user.stop_pulling()
				full = TRUE
				update_icon()
