#define OPEN_EMPTY		1
#define CLOSED_EMPTY	2
#define OPEN_FULL		3
#define CLOSED_FULL		4
#define RUNNING			5
//#define OPEN_BLOODY	6 is tied to an unused icon state
#define CLOSED_BLOODY	7
#define RUNNING_BLOODY	8

/obj/machinery/washing_machine
	name = "washing machine"
	desc = "Gets rid of those pesky bloodstains, or your money back!"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = TRUE
	anchored = TRUE
	/// Integer ID corresponding to whether the machine can accept more items, is running, will produce gibs, etc.
	var/state = OPEN_EMPTY
	var/panel = FALSE
	var/gibs_ready = FALSE
	var/obj/crayon
	/// Typecache of washable items
	var/list/can_be_washed = list(
		/obj/item/stack/sheet/hairlesshide,
		/obj/item/clothing/under,
		/obj/item/clothing/mask,
		/obj/item/clothing/head,
		/obj/item/clothing/gloves,
		/obj/item/clothing/shoes,
		/obj/item/clothing/suit,
		/obj/item/bedsheet
	)
	/// Typecache of items that do not fit, overrides the whitelist
	var/list/does_not_fit = list(
		/obj/item/clothing/under/plasmaman,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/syndicatefake,
		/obj/item/clothing/suit/cyborg_suit,
		/obj/item/clothing/suit/bomb_suit,
		/obj/item/clothing/suit/armor,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/mask/cigarette,
		/obj/item/clothing/head/syndicatefake,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/gloves/furgloves
	)

/obj/machinery/washing_machine/Initialize(mapload)
	. = ..()

	can_be_washed = typecacheof(can_be_washed)
	does_not_fit = typecacheof(does_not_fit)

/obj/machinery/washing_machine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can <b>Alt-Click</b> [src] to start its washing cycle."

/obj/machinery/washing_machine/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	start(user)

/obj/machinery/washing_machine/proc/start(mob/user)
	if(state != CLOSED_FULL)
		to_chat(user, "<span class='notice'>The washing machine cannot run in this state.</span>")
		return

	if(locate(/mob) in src)
		state = RUNNING_BLOODY
	else
		state = RUNNING
	update_icon(UPDATE_ICON_STATE)
	sleep(200)
	for(var/atom/A in src)
		A.clean_blood()

	//Tanning!
	for(var/obj/item/stack/sheet/hairlesshide/HH in src)
		new /obj/item/stack/sheet/wetleather(src, HH.amount)
		qdel(HH)


	if(crayon)
		var/wash_color
		if(istype(crayon, /obj/item/toy/crayon))
			var/obj/item/toy/crayon/CR = crayon
			wash_color = CR.colourName
		else if(istype(crayon, /obj/item/stamp))
			var/obj/item/stamp/ST = crayon
			wash_color = ST.item_color

		if(wash_color)
			var/new_jumpsuit_icon_state
			var/new_jumpsuit_item_state
			var/new_jumpsuit_name
			var/new_glove_icon_state
			var/new_glove_item_state
			var/new_glove_name
			var/new_bandana_icon_state
			var/new_bandana_item_state
			var/new_bandana_name
			var/new_shoe_icon_state
			var/new_shoe_name
			var/new_sheet_icon_state
			var/new_sheet_name
			var/new_sheet_item_state
			var/new_softcap_icon_state
			var/new_softcap_name
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
				for(var/obj/item/clothing/under/J in src)
					if(!J.dyeable)
						continue
					J.item_state = new_jumpsuit_item_state
					J.icon_state = new_jumpsuit_icon_state
					J.item_color = wash_color
					J.name = new_jumpsuit_name
					J.desc = new_desc
			if(new_glove_icon_state && new_glove_item_state && new_glove_name)
				for(var/obj/item/clothing/gloves/color/G in src)
					if(!G.dyeable)
						continue
					G.item_state = new_glove_item_state
					G.icon_state = new_glove_icon_state
					G.item_color = wash_color
					G.name = new_glove_name
					if(!istype(G, /obj/item/clothing/gloves/color/black/thief))
						G.desc = new_desc
			if(new_shoe_icon_state && new_shoe_name)
				for(var/obj/item/clothing/shoes/S in src)
					if(!S.dyeable)
						continue
					if(S.chained)
						S.chained = FALSE
						S.slowdown = SHOES_SLOWDOWN
						new /obj/item/restraints/handcuffs(src)
					S.icon_state = new_shoe_icon_state
					S.item_color = wash_color
					S.name = new_shoe_name
					S.desc = new_desc
			if(new_bandana_icon_state && new_bandana_name)
				for(var/obj/item/clothing/mask/bandana/M in src)
					if(!M.dyeable)
						continue
					M.item_state = new_bandana_item_state
					M.icon_state = new_bandana_icon_state
					M.item_color = wash_color
					M.name = new_bandana_name
					M.desc = new_desc
			if(new_sheet_icon_state && new_sheet_name)
				for(var/obj/item/bedsheet/B in src)
					B.icon_state = new_sheet_icon_state
					B.item_color = wash_color
					B.item_state = new_sheet_item_state
					B.name = new_sheet_name
					B.desc = new_desc
			if(new_softcap_icon_state && new_softcap_name)
				for(var/obj/item/clothing/head/soft/H in src)
					if(!H.dyeable)
						continue
					H.icon_state = new_softcap_icon_state
					H.item_color = wash_color
					H.name = new_softcap_name
					H.desc = new_desc
		QDEL_NULL(crayon)


	if(locate(/mob) in src)
		state = CLOSED_BLOODY
		gibs_ready = TRUE
	else
		state = CLOSED_FULL
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/washing_machine/update_icon_state()
	icon_state = "wm_[state][panel]"

/obj/machinery/washing_machine/attackby(obj/item/W, mob/user, params)
	if(default_unfasten_wrench(user, W))
		return
	if(istype(W, /obj/item/toy/crayon) || istype(W, /obj/item/stamp))
		if(state in list(OPEN_EMPTY, OPEN_FULL))
			if(!crayon)
				user.drop_item()
				crayon = W
				crayon.forceMove(src)
				update_icon(UPDATE_ICON_STATE)
			else
				return ..()
		else
			return ..()
	else if(istype(W, /obj/item/grab))
		if(state == OPEN_EMPTY)
			var/obj/item/grab/G = W
			if(ishuman(G.assailant) && iscorgi(G.affecting))
				G.affecting.forceMove(src)
				qdel(G)
				state = OPEN_FULL
			update_icon(UPDATE_ICON_STATE)
		else
			return ..()
	else if(is_type_in_typecache(W, can_be_washed))
		if(is_type_in_typecache(W, does_not_fit))
			to_chat(user, "<span class='warning'>This item does not fit.</span>")
			return
		if(istype(W, /obj/item/clothing/gloves/color/black/krav_maga/sec))
			to_chat(user, "<span class='warning'>Washing these gloves would fry the electronics!</span>")
			return
		if(W.flags & NODROP)
			to_chat(user, "<span class='warning'>[W] is stuck to your hand!</span>")
			return

		if(length(contents) < 5)
			if(state in list(OPEN_EMPTY, OPEN_FULL))
				user.drop_item()
				W.forceMove(src)
				state = OPEN_FULL
			else
				to_chat(user, "<span class='warning'>The door is closed!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is full!</span>")
		update_icon(UPDATE_ICON_STATE)
	else
		return ..()

/obj/machinery/washing_machine/attack_hand(mob/user)
	switch(state)
		if(OPEN_EMPTY)
			state = CLOSED_EMPTY
		if(CLOSED_EMPTY)
			for(var/atom/movable/O in src)
				O.forceMove(loc)
			crayon = null
			state = OPEN_EMPTY
		if(OPEN_FULL)
			state = CLOSED_FULL
		if(CLOSED_FULL)
			for(var/atom/movable/O in src)
				O.forceMove(loc)
			crayon = null
			state = OPEN_EMPTY
		if(RUNNING)
			to_chat(user, "<span class='warning'>[src] is busy.</span>")
		if(CLOSED_BLOODY)
			if(gibs_ready)
				gibs_ready = FALSE
				if(locate(/mob) in src)
					var/mob/M = locate() in src
					M.gib()
			for(var/atom/movable/O in src)
				O.forceMove(loc)
			crayon = null
			state = OPEN_EMPTY

	update_icon(UPDATE_ICON_STATE)

/obj/machinery/washing_machine/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location(), 2)
	qdel(src)

#undef OPEN_EMPTY
#undef CLOSED_EMPTY
#undef OPEN_FULL
#undef CLOSED_FULL
#undef RUNNING
#undef CLOSED_BLOODY
#undef RUNNING_BLOODY
