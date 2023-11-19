/obj/machinery/washing_machine
	name = "washing machine"
	desc = "Gets rid of those pesky bloodstains, or your money back!"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = TRUE
	anchored = TRUE
	var/state = 1
	//1 = empty, open door
	//2 = empty, closed door
	//3 = full, open door
	//4 = full, closed door
	//5 = running
	//6 = blood, open door
	//7 = blood, closed door
	//8 = blood, running
	var/panel = FALSE
	//FALSE = closed
	//TRUE = open
	var/hacked = TRUE //Bleh, screw hacking, let's have it hacked by default.
	var/gibs_ready = 0
	var/obj/crayon

/obj/machinery/washing_machine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can <b>Alt-Click</b> [src] to start its washing cycle."

/obj/machinery/washing_machine/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	start(user)

/obj/machinery/washing_machine/proc/start(mob/user)
	if(state != 4)
		to_chat(user, "<span class='notice'>The washing machine cannot run in this state.</span>")
		return

	if(locate(/mob,contents))
		state = 8
	else
		state = 5
	update_icon(UPDATE_ICON_STATE)
	sleep(200)
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
			var/new_sheet_item_state = ""
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
					new_sheet_item_state = B.item_state
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
					B.item_state = new_sheet_item_state
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


	if(locate(/mob,contents))
		state = 7
		gibs_ready = 1
	else
		state = 4
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/washing_machine/update_icon_state()
	icon_state = "wm_[state][panel]"

/obj/machinery/washing_machine/attackby(obj/item/W as obj, mob/user as mob, params)
	if(default_unfasten_wrench(user, W))
		return
	if(istype(W,/obj/item/toy/crayon) ||istype(W,/obj/item/stamp))
		if(state in list(	1, 3, 6))
			if(!crayon)
				user.drop_item()
				crayon = W
				crayon.loc = src
				update_icon(UPDATE_ICON_STATE)
			else
				return ..()
		else
			return ..()
	else if(istype(W,/obj/item/grab))
		if((state == 1) && hacked)
			var/obj/item/grab/G = W
			if(ishuman(G.assailant) && iscorgi(G.affecting))
				G.affecting.loc = src
				qdel(G)
				state = 3
			update_icon(UPDATE_ICON_STATE)
		else
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
		if(istype(W,/obj/item/clothing/under/plasmaman))
			to_chat(user, "This item does not fit.")
			return
		if(istype(W,/obj/item/clothing/suit/space))
			to_chat(user, "This item does not fit.")
			return
		if(istype(W,/obj/item/clothing/suit/syndicatefake))
			to_chat(user, "This item does not fit.")
			return
//		if(istype(W,/obj/item/clothing/suit/powered))
//			to_chat(user, "This item does not fit.")
//			return
		if(istype(W,/obj/item/clothing/suit/cyborg_suit))
			to_chat(user, "This item does not fit.")
			return
		if(istype(W,/obj/item/clothing/suit/bomb_suit))
			to_chat(user, "This item does not fit.")
			return
		if(istype(W,/obj/item/clothing/suit/armor))
			to_chat(user, "This item does not fit.")
			return
		if(istype(W,/obj/item/clothing/mask/gas))
			to_chat(user, "This item does not fit.")
			return
		if(istype(W,/obj/item/clothing/mask/cigarette))
			to_chat(user, "This item does not fit.")
			return
		if(istype(W,/obj/item/clothing/head/syndicatefake))
			to_chat(user, "This item does not fit.")
			return
//		if(istype(W,/obj/item/clothing/head/powered))
//			to_chat(user, "This item does not fit.")
//			return
		if(istype(W,/obj/item/clothing/head/helmet))
			to_chat(user, "This item does not fit.")
			return
		if(istype(W,/obj/item/clothing/gloves/furgloves))
			to_chat(user, "This item does not fit.")
			return
		if(istype(W, /obj/item/clothing/gloves/color/black/krav_maga/sec))
			to_chat(user, "<span class='warning'>Washing these gloves would fry the electronics!</span>")
			return
		if(W.flags & NODROP) //if "can't drop" item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in the washing machine!</span>")
			return

		if(contents.len < 5)
			if(state in list(1, 3))
				user.drop_item()
				W.loc = src
				state = 3
			else
				to_chat(user, "<span class='notice'>You can't put the item in right now.</span>")
		else
			to_chat(user, "<span class='notice'>The washing machine is full.</span>")
		update_icon(UPDATE_ICON_STATE)
	else
		return ..()

/obj/machinery/washing_machine/attack_hand(mob/user as mob)
	switch(state)
		if(1)
			state = 2
		if(2)
			state = 1
			for(var/atom/movable/O in contents)
				O.loc = src.loc
		if(3)
			state = 4
		if(4)
			state = 3
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1
		if(5)
			to_chat(user, "<span class='warning'>[src] is busy.</span>")
		if(6)
			state = 7
		if(7)
			if(gibs_ready)
				gibs_ready = 0
				if(locate(/mob,contents))
					var/mob/M = locate(/mob,contents)
					M.gib()
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1


	update_icon(UPDATE_ICON_STATE)

/obj/machinery/washing_machine/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location(), 2)
	qdel(src)
