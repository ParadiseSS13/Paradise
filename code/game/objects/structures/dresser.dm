/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = TRUE
	anchored = TRUE

/obj/structure/dresser/attack_hand(mob/user)
	change_undergarments(user)

/obj/structure/dresser/proc/change_undergarments(mob/user)
	if(!Adjacent(user))//no tele-grooming
		return
	if(!(ishuman(user) && anchored))
		return
	var/mob/living/carbon/human/H = user

	var/choice = tgui_input_list(user, "Underwear, Undershirt, or Socks?", "Changing", list("Underwear", "Undershirt", "Socks"))

	if(!Adjacent(user))
		return
	switch(choice)
		if("Underwear")
			var/list/valid_underwear = list()
			for(var/underwear in GLOB.underwear_list)
				var/datum/sprite_accessory/S = GLOB.underwear_list[underwear]
				if(!(H.dna.species.name in S.species_allowed))
					continue
				valid_underwear[underwear] = GLOB.underwear_list[underwear]
			var/new_underwear = tgui_input_list(user, "Choose your underwear:", "Changing", valid_underwear)
			if(new_underwear)
				H.underwear = new_underwear

		if("Undershirt")
			var/list/valid_undershirts = list()
			for(var/undershirt in GLOB.undershirt_list)
				var/datum/sprite_accessory/S = GLOB.undershirt_list[undershirt]
				if(!(H.dna.species.name in S.species_allowed))
					continue
				valid_undershirts[undershirt] = GLOB.undershirt_list[undershirt]
			for(var/config in GLOB.configuration.custom_sprites.fluff_undershirts)
				if(user.ckey in config["ckeys"])
					valid_undershirts[config["name"]] = GLOB.undershirt_full_list[config["name"]]
			sortTim(valid_undershirts, GLOBAL_PROC_REF(cmp_text_asc))
			var/new_undershirt = tgui_input_list(user, "Choose your undershirt:", "Changing", valid_undershirts)
			if(new_undershirt)
				H.undershirt = new_undershirt

		if("Socks")
			var/list/valid_sockstyles = list()
			for(var/sockstyle in GLOB.socks_list)
				var/datum/sprite_accessory/S = GLOB.socks_list[sockstyle]
				if(!(H.dna.species.name in S.species_allowed))
					continue
				valid_sockstyles[sockstyle] = GLOB.socks_list[sockstyle]
			var/new_socks = tgui_input_list(user, "Choose your socks:", "Changing", valid_sockstyles)
			if(new_socks)
				H.socks = new_socks

	add_fingerprint(H)
	H.update_body()

/obj/structure/dresser/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/dresser/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 20)

/obj/structure/dresser/deconstruct(disassembled = FALSE)
	var/mat_drop = 15
	if(disassembled)
		mat_drop = 30
	new /obj/item/stack/sheet/wood(drop_location(), mat_drop)
	..()

/obj/structure/dresser/wardrobe
	name = "wardrobe"
	desc = "A good place to store all your clothes."
	icon_state = "wardrobe"
	var/locked_overlay = "wardrobe_locked"
	/// List of objects which this item can store (if set, it can't store anything else)
	var/list/can_hold = list(/obj/item/clothing)
	/// List of objects which this item can't store (can make exceptions to can_hold)
	var/list/cant_hold = list(
		/obj/item/storage,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/mask/cigarette,
		/obj/item/clothing/mask/facehugger, //Why would you do this
		/obj/item/clothing/accessory/medal,
		/obj/item/clothing/suit/armor/riot,
		/obj/item/clothing/suit/armor/reactive,
		/obj/item/clothing/suit/armor/laserproof,
		/obj/item/clothing/suit/hooded/ablative,
		/obj/item/clothing/gloves/color/black/krav_maga
	)
	var/locked = FALSE

/obj/structure/dresser/wardrobe/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/dresser/wardrobe/update_overlays()
	. = ..()
	. += locked ? locked_overlay : null

/obj/structure/dresser/wardrobe/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It's currently [locked ? null : "un"]locked.")

/obj/structure/dresser/wardrobe/AltShiftClick(mob/user)
	change_undergarments(user)

/obj/structure/dresser/wardrobe/AltClick(mob/user)
	toggle_lock(user)

/obj/structure/dresser/wardrobe/attack_hand(mob/user)
	if(user.a_intent == INTENT_HARM)
		return CONTINUE_ATTACK
	if(locked)
		toggle_lock(user)
		return
	if(!length(contents))
		return ..()
	if(!Adjacent(user))
		return ..()
	var/obj/item/item_to_retrieve = tgui_input_list(user, "What would you like to take out?", src, contents)
	if(!item_to_retrieve)
		return
	if(!Adjacent(user))
		return
	item_to_retrieve.forceMove(loc)
	to_chat(user, SPAN_NOTICE("You take [item_to_retrieve] out of [src]."))
	if(issilicon(user))
		return
	user.put_in_hands(item_to_retrieve)
	var/mob/living/carbon/human/H = user
	add_fingerprint(H)

/obj/structure/dresser/wardrobe/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(locked)
		toggle_lock(user)
		return ITEM_INTERACT_COMPLETE
	if(!Adjacent(user))
		return ITEM_INTERACT_COMPLETE
	if(!is_type_in_list(used, can_hold) || is_type_in_list(used, cant_hold))
		to_chat(user, SPAN_NOTICE("You can't put [used] in [src]. It doesn't fit."))
		return ITEM_INTERACT_COMPLETE
	if(!user.drop_item())
		to_chat(user, SPAN_WARNING("[used] is stuck to you!"))
		return ITEM_INTERACT_COMPLETE
	used.forceMove(src)
	var/mob/living/carbon/human/H = user
	add_fingerprint(H)
	to_chat(user, SPAN_NOTICE("You put [used] in [src]."))
	return ITEM_INTERACT_COMPLETE

/obj/structure/dresser/wardrobe/proc/toggle_lock(mob/user)
	if(!allowed(user))
		to_chat(user, SPAN_NOTICE("Access Denied."))
		return
	locked = !locked
	visible_message(SPAN_NOTICE("[user] [locked ? null : "un"]lock[user.p_s()] [src]."))
	var/mob/living/carbon/human/H = user
	add_fingerprint(H)
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/dresser/wardrobe/captain
	name = "Captain's Wardrobe"
	desc = "All the clothes you need to lead a station."
	icon_state = "wardrobe_captain"
	locked = TRUE
	req_access = list(ACCESS_CAPTAIN)

/obj/structure/dresser/wardrobe/captain/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/head/caphat(src)
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/head/caphat/parade/white(src)
	new /obj/item/clothing/head/beret/captain(src)
	new /obj/item/clothing/head/beret/captain/white(src)
	new /obj/item/clothing/head/crown/fancy(src)
	new /obj/item/clothing/neck/cloak/captain(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/jacket(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/jacket/tunic(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/coat(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/coat/white(src)
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	new /obj/item/clothing/suit/hooded/wintercoat/captain/white(src)
	new /obj/item/clothing/neck/cloak/captain_mantle(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/rank/captain/skirt(src)
	new /obj/item/clothing/under/rank/captain/white(src)
	new /obj/item/clothing/under/rank/captain/skirt/white(src)
	new /obj/item/clothing/under/rank/captain/parade(src)
	new /obj/item/clothing/under/rank/captain/dress(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/captain(src)
	new /obj/item/clothing/under/plasmaman/captain(src)
