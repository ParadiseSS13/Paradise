/datum/action/innate/clockwork/clock_magic //Clockwork magic casting.
	name = "Prepare Clockwork Magic"
	button_icon_state = "carve"
	desc = "Prepare clockwork magic powering yourself from Ratvar's pool of power. The magic you will cast depends on what's in your hand."
	var/datum/action/innate/clockwork/hand_spell/construction/midas_spell = null
	var/channeling = FALSE

/datum/action/innate/clockwork/clock_magic/Remove()
	QDEL_NULL(midas_spell)
	. = ..()

// Datum for enchanting item. The name, amount of power, time needed, spell action itself from item.
/datum/spell_enchant
	var/name = "Spell Item Enchanter"
	var/enchantment = NO_SPELL
	var/req_amount = 0 //this var is scraped (for now)
	var/time = 3
	var/spell_action = FALSE // If we item needs an action button

/datum/spell_enchant/New(name, enchantment, req_amount = 0, time = 3, spell_action = FALSE)
	src.name = name
	src.enchantment = enchantment
	src.req_amount = req_amount
	src.time = time
	src.spell_action = spell_action

// The list clockwork_items you can find in defines/clockwork

/// Main proc on enchanting items/ making spell on hands
/datum/action/innate/clockwork/clock_magic/Activate()
	. = ..()
	var/obj/item/item = owner.get_active_hand()
	if(istype(item, /obj/item/gripper)) // cogs gripper
		var/obj/item/gripper/G = item
		item = G.gripped_item
	// If we having something in hand. Check if it can be enchanted. Else skip.
	if(!item) // Maybe we want to enchant our armor
		var/list/items = list()
		var/list/duplicates = list()
		var/list/possible_items = list()
		var/list/possible_icons = list()
		for(var/obj/item/I in owner.contents)
			if(istype(I, /obj/item/gripper)) // cogs gripper
				var/obj/item/gripper/G = I
				I = G.gripped_item
			if(!I.enchants)
				continue
			if(I.name in items) // in case there are doubles clockslabs
				duplicates[I.name]++
				possible_items["[I.name] ([duplicates[I.name]])"] = I
				var/image/item_image = image(icon = I.icon, icon_state = I.icon_state)
				if(I.enchant_type > NO_SPELL) //cause casting spell is -1
					item_image.add_overlay("[initial(I.icon_state)]_overlay_[I.enchant_type]")
				possible_icons += list("[I.name] ([duplicates[I.name]])" = item_image)
			else
				items.Add(I.name)
				duplicates[I.name] = 1
				possible_items[I.name] = I
				var/image/item_image = image(icon = I.icon, icon_state = I.icon_state)
				if(I.enchant_type > NO_SPELL) //cause casting spell is -1
					item_image.add_overlay("[initial(I.icon_state)]_overlay_[I.enchant_type]")
				possible_icons += list(I.name = item_image)
		if(ishuman(owner))
			possible_items += "Spell hand"
			possible_icons += list("Spell hand" = image(icon = 'icons/mob/actions/actions_clockwork.dmi', icon_state = "hand"))
		var/item_to_enchant
		if(possible_items.len >= 2)
			item_to_enchant = show_radial_menu(owner, owner, possible_icons, require_near = TRUE)
		else if(possible_items.len == 1)
			item_to_enchant = possible_items[1]
		else
			item_to_enchant = null
		if(!item_to_enchant)
			if(possible_items.len) // we had a choice but declined
				return
			item_to_enchant = null
		if(item_to_enchant == "Spell hand")
			item_to_enchant = null
		else
			item = possible_items[item_to_enchant]
			if(!(item in owner.contents))
				var/obj/item/gripper/G = locate() in owner
				if(item != G?.gripped_item)
					return
		if(QDELETED(src) || owner.incapacitated())
			return
	if(item?.enchants?.len) // it just works
		if(item.enchant_type == CASTING_SPELL)
			to_chat(owner, "<span class='warning'> You can't enchant [item] right now while spell is working!</span>")
			return
		if(item.enchant_type)
			to_chat(owner, "<span class='clockitalic'>There is already prepared spell in [item]! If you choose another spell it will overwrite old one!</span>")
		var/entered_spell_name
		var/list/possible_enchants = list()
		var/list/possible_enchant_icons = list()
		for(var/datum/spell_enchant/S in item.enchants)
			if(S.enchantment == item.enchant_type)
				continue
			possible_enchants[S.name] = S
			var/image/I = image(icon = item.icon, icon_state = initial(item.icon_state))
			I.add_overlay("[initial(item.icon_state)]_overlay_[S.enchantment]")
			possible_enchant_icons += list(S.name = I)
		entered_spell_name = show_radial_menu(owner, owner, possible_enchant_icons, require_near = TRUE)
		var/datum/spell_enchant/spell_enchant = possible_enchants[entered_spell_name]
		if(QDELETED(src) || owner.incapacitated() || !spell_enchant)
			return
		if(!(item in owner.contents))
			var/obj/item/gripper/G = locate() in owner
			if(item != G?.gripped_item)
				return
			return

		if(!channeling)
			channeling = TRUE
			to_chat(owner, "<span class='clockitalic'>You start to concentrate on your power to seal the magic in [item].</span>")
		else
			to_chat(owner, "<span class='warning'>You are already invoking clock magic!</span>")
			return

		var/clock_structure_in_range = locate(/obj/structure/clockwork/functional) in range(1, usr)
		var/time_cast = spell_enchant.time SECONDS
		if(clock_structure_in_range)
			time_cast /= 2

		if(do_after(owner, time_cast, target = owner))
			item.deplete_spell() // to clear up actions if have
			item.enchant_type = spell_enchant.enchantment
			if(spell_enchant.spell_action)
				var/datum/action/item_action/activate/enchant/E = new (item)
				E.owner = owner
				owner.actions += E
				owner.update_action_buttons(TRUE)
			item.update_icon()
			to_chat(owner, "<span class='clock'>You sealed the power in [item], you have prepared a [spell_enchant.name] invocation!</span>")

		channeling = FALSE
	// If it's empty or not an item we can enchant. Making a spell on hand.
	else
		if(!iscarbon(owner)) //This is to throw away non carbon who doesn't have hands, but silicon modules.
			to_chat(owner, "<span class='clockitalic'>You need an item that you can enchant!</span>")
			return
		if(midas_spell)
			to_chat(owner, "<span class='clockitalic'>You already prepared midas touch!</b></span>")
			return
		if(QDELETED(src) || owner.incapacitated())
			return

		if(!channeling)
			channeling = TRUE
			to_chat(owner, "<span class='clockitalic'>You start to concentrate on your power to seal the magic in your hand.</span>")
		else
			to_chat(owner, "<span class='warning'>You are already invoking clock magic!</span>")
			return

		if(do_after(owner, 50, target = owner))
			midas_spell = new /datum/action/innate/clockwork/hand_spell/construction(owner)
			midas_spell.Grant(owner, src)
			to_chat(owner, "<span class='clock'>You feel the power flows in your hand, you have prepared a [midas_spell.name] invocation!</span>")
		channeling = FALSE

/datum/action/innate/clockwork/hand_spell //The next generation of talismans, handles storage/creation of blood magic
	name = "Clockwork Magic"
	button_icon_state = "telerune"
	desc = "Let the Gears Power."
	var/magic_path = null
	var/obj/item/melee/clock_magic/hand_magic
	var/datum/action/innate/clockwork/clock_magic/source_magic
	var/used = FALSE

/datum/action/innate/clockwork/hand_spell/Grant(mob/living/owner, datum/action/innate/clockwork/hand_spell/SM)
	source_magic = SM
	return ..()

/datum/action/innate/clockwork/hand_spell/Remove()
	if(source_magic)
		source_magic.midas_spell = null
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	return ..()

/datum/action/innate/clockwork/hand_spell/IsAvailable()
	if(!isclocker(owner) || owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/clockwork/hand_spell/Activate()
	if(!magic_path) // If this spell flows from the hand
		return
	if(!hand_magic) // If you don't already have the spell active
		hand_magic = new magic_path(owner, src)
		if(!owner.put_in_hands(hand_magic))
			QDEL_NULL(hand_magic)
			to_chat(owner, "<span class='warning'>You have no empty hand for invoking clockwork magic!</span>")
			return
		to_chat(owner, "<span class='cultitalic'>Your wounds glow as you invoke the [name].</span>")
	else // If the spell is active, and you clicked on the button for it
		QDEL_NULL(hand_magic)

/datum/action/innate/clockwork/hand_spell/construction
	name = "Midas Touch"
	desc = "Empowers your hand to cover metalic objects into brass.<br><u>Converts:</u><br>Plasteel and metal into brass metal<br>Brass metal into integration cog or clockwork slab<br>Cyborgs or AI into Ratvar's servants after a short delay"
	button_icon_state = "midas_touch"
	magic_path = /obj/item/melee/clock_magic/construction

// The "magic hand" items
/obj/item/melee/clock_magic
	name = "\improper magical aura"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/clockwork.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "clocked_hand"
	item_state = "clocked_hand"
	flags = ABSTRACT | DROPDEL

	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0

	var/datum/action/innate/clockwork/hand_spell/source

/obj/item/melee/clock_magic/New(loc, spell)
	source = spell
	..()

/obj/item/melee/clock_magic/Destroy()
	if(!QDELETED(source))
		source.hand_magic = null
		if(source.used)
			qdel(source)
			source = null
		else
	return ..()

/obj/item/melee/clock_magic/construction
	name = "Midas Aura"
	desc = "A dripping brass from hand charged to twist metal."
	color = "#FFDF00"
	var/channeling = FALSE

/obj/item/melee/clock_magic/construction/examine(mob/user)
	. = ..()
	. += {"<u>A sinister spell used to convert:</u>\n
	Plasteel into brass metal\n
	[CLOCK_METAL_TO_BRASS] metal into a brass\n
	Robots into cult"}

/obj/item/melee/clock_magic/construction/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(channeling)
		to_chat(user, "<span class='clockitalic'>You are already invoking midas touch!</span>")
		return
	var/turf/turf_target = get_turf(target)

	//Metal to brass metal
	if(istype(target, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/candidate = target
		if(candidate.amount < CLOCK_METAL_TO_BRASS)
			to_chat(user, "<span class='warning'>You need [CLOCK_METAL_TO_BRASS] metal to produce a single brass!</span>")
			return
		var/quantity = (candidate.amount - (candidate.amount % CLOCK_METAL_TO_BRASS)) / CLOCK_METAL_TO_BRASS
		if(candidate.use(quantity * CLOCK_METAL_TO_BRASS))
			var/obj/item/stack/sheet/brass/B = new(turf_target, quantity)
			user.put_in_hands(B)
			to_chat(user, "<span class='warning'>Your hand starts to shine very bright onto the metal, transforming it into brass!</span>")
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)
		else
			to_chat(user, "<span class='warning'>You need [CLOCK_METAL_TO_BRASS] metal to produce a single brass!</span>")
			return

	//Plasteel to brass metal
	else if(istype(target, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/candidate = target
		var/quantity = candidate.amount
		if(candidate.use(quantity))
			var/obj/item/stack/sheet/brass/B = new(turf_target, quantity)
			user.put_in_hands(B)
			to_chat(user, "<span class='warning'>Your hand starts to shine very bright onto the plasteel, transforming it into brass!</span>")
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)

	else if(istype(target, /obj/item/stack/sheet/brass))
		var/obj/item/stack/sheet/brass/candidate = target
		var/list/choosable_items = list("Clock Slab" = /obj/item/clockwork/clockslab, "Integration Cog" = /obj/item/clockwork/integration_cog)
		var/choice = show_radial_menu(user, src, choosable_items, require_near = TRUE)
		var/picked_type = choosable_items[choice]
		if(QDELETED(src) || !picked_type || !target.Adjacent(user) || user.incapacitated())
			return
		var/obj/O = new picked_type
		if(!user.put_in_hands(O))
			O.forceMove(get_turf(src))
		candidate.use(1)
		to_chat(user, "<span class='warning'>With you magic hand you re-materialize brass into [O.name]!</span>")
		playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)

	else if(istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/candidate = target
		if(candidate.stat != DEAD || !isclocker(candidate))
			channeling = TRUE
			user.visible_message("<span class='warning'>A [user]'s hand touches [candidate] and rapidly turns all his metal into cogs and brass gears!</span>")
			playsound(get_turf(src), 'sound/machines/airlockforced.ogg', 80, TRUE)
			do_sparks(5, TRUE, target)
			if(do_after(user, 90, target = candidate))
				candidate.emp_act(EMP_HEAVY)
				candidate.ratvar_act(weak = TRUE)
				channeling = FALSE
			else
				channeling = FALSE
				return
	else if(istype(target, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/candidate = target
		if(candidate.stat != DEAD || !isclocker(candidate))
			channeling = TRUE
			user.visible_message("<span class='warning'>A [user]'s hand touches [candidate] as he starts to manipulate every piece of technology inside!</span>")
			playsound(get_turf(src), 'sound/machines/airlockforced.ogg', 80, TRUE)
			do_sparks(5, TRUE, target)
			if(do_after(user, 90, target = candidate))
				candidate.ratvar_act()
				channeling = FALSE
			else
				channeling = FALSE
				return
		else
			to_chat(user, "<span class='warning'>Your hand finalizes [candidate] - twisting it into a marauder!</span>")
			new /obj/item/clockwork/marauder(get_turf(src))
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)
			qdel(candidate)
	else
		to_chat(user, "<span class='warning'>The spell will not work on [target]!</span>")
		return
	user.whisper("Rqu-en qy'qby!")
	source.used = TRUE
	qdel(src)
