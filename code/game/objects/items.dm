GLOBAL_DATUM_INIT(fire_overlay, /mutable_appearance, mutable_appearance('icons/goonstation/effects/fire.dmi', "fire"))
/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'

	move_resist = null // Set in the Initialise depending on the item size. Unless it's overriden by a specific item
	var/discrete = 0 // used in item_attack.dm to make an item not show an attack message to viewers
	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/blood_overlay_color = null
	var/item_state = null
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	var/belt_icon = null

	//Dimensions of the lefthand_file and righthand_file vars
	//eg: 32x32 sprite, 64x64 sprite, etc.
	var/inhand_x_dimension = 32
	var/inhand_y_dimension = 32

	max_integrity = 200

	can_be_hit = FALSE
	suicidal_hands = TRUE

	var/list/attack_verb //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/hitsound = null
	var/usesound = null
	var/throwhitsound
	var/stealthy_audio = FALSE //Whether or not we use stealthy audio levels for this item's attack sounds
	var/w_class = WEIGHT_CLASS_NORMAL
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	pass_flags = PASSTABLE
	pressure_resistance = 4
//	causeerrorheresoifixthis
	var/obj/item/master = null

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/list/actions = list() //list of /datum/action's that this item has.
	var/list/actions_types = list() //list of paths of action datums to give to the item on New().
	var/list/action_icon = list() //list of icons-sheets for a given action to override the icon.
	var/list/action_icon_state = list() //list of icon states for a given action to override the icon_state.

	var/list/materials = list()
	var/materials_coeff = 1
	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/item_color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/is_speedslimepotioned = FALSE
	var/cant_be_faster = FALSE
	var/armour_penetration = 0 //percentage of armour effectiveness to remove
	/// Allows you to override the attack animation with an attack effect
	var/attack_effect_override
	var/list/allowed = null //suit storage stuff.
	var/obj/item/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.

	var/needs_permit = 0			//Used by security bots to determine if this item is safe for public use.

	var/strip_delay = DEFAULT_ITEM_STRIP_DELAY
	var/put_on_delay = DEFAULT_ITEM_PUTON_DELAY
	var/breakouttime = 0
	var/flags_cover = 0 //for flags such as GLASSESCOVERSEYES

	var/block_chance = 0
	var/hit_reaction_chance = 0 //If you want to have something unrelated to blocking/armour piercing etc. Maybe not needed, but trying to think ahead/allow more freedom

	// Needs to be in /obj/item because corgis can wear a lot of
	// non-clothing items
	var/datum/dog_fashion/dog_fashion = null
	var/datum/muhtar_fashion/muhtar_fashion = null
	var/datum/snake_fashion/snake_fashion = null

	var/mob/thrownby = null

	//So items can have custom embedd values
	//Because customisation is king
	var/embed_chance = EMBED_CHANCE
	var/embedded_fall_chance = EMBEDDED_ITEM_FALLOUT
	var/embedded_pain_chance = EMBEDDED_PAIN_CHANCE
	var/embedded_pain_multiplier = EMBEDDED_PAIN_MULTIPLIER  //The coefficient of multiplication for the damage this item does while embedded (this*w_class)
	var/embedded_fall_pain_multiplier = EMBEDDED_FALL_PAIN_MULTIPLIER //The coefficient of multiplication for the damage this item does when falling out of a limb (this*w_class)
	var/embedded_impact_pain_multiplier = EMBEDDED_IMPACT_PAIN_MULTIPLIER //The coefficient of multiplication for the damage this item does when first embedded (this*w_class)
	var/embedded_unsafe_removal_pain_multiplier = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER //The coefficient of multiplication for the damage removing this without surgery causes (this*w_class)
	var/embedded_unsafe_removal_time = EMBEDDED_UNSAFE_REMOVAL_TIME //A time in ticks, multiplied by the w_class.
	var/embedded_ignore_throwspeed_threshold = FALSE

	var/tool_behaviour = NONE //What kind of tool are we?
	var/tool_enabled = TRUE //If we can turn on or off, are we currently active? Mostly for welders and this will normally be TRUE
	var/tool_volume = 50 //How loud are we when we use our tool?
	var/toolspeed = 1 // If this item is a tool, the speed multiplier

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		"Tajaran" = 'icons/cat/are/bad'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/
	var/list/sprite_sheets = null
	var/list/sprite_sheets_inhand = null //Used to override inhand items. Use a single .dmi and suffix the icon states inside with _l and _r for each hand.
	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.
	var/sprite_sheets_obj = null //Used to override hardcoded clothing inventory object dmis in human clothing proc.

	//Tooltip vars
	var/in_inventory = FALSE //is this item equipped into an inventory slot or hand of a mob?
	var/tip_timer = 0

	// item hover FX
	/// Is this item inside a storage object?
	var/in_storage = FALSE
	/// Holder var for the item outline filter, null when no outline filter on the item.
	var/outline_filter

	//Clockwork enchantment
	var/enchant_type = NO_SPELL // What's the type on enchantment on it? 0
	var/list/enchants = null // List(datum)

	//eat_items.dm
	var/material_type = MATERIAL_CLASS_NONE
	var/max_bites = 1 			//The maximum amount of bites before item is depleted
	var/current_bites = 0	//How many bites did
	var/integrity_bite = 10		// Integrity used
	var/nutritional_value = 20 	// How much nutrition add
	var/is_only_grab_intent = FALSE	//Grab if help_intent was used

	///In deciseconds, how long an item takes to equip/unequip; counts only for normal clothing slots, not pockets, hands etc.
	var/equip_delay_self = 0 SECONDS


/obj/item/New()
	..()
	for(var/path in actions_types)
		new path(src, action_icon[path], action_icon_state[path])

	if(!hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"
	if(!move_resist)
		determine_move_resist()


/obj/item/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/storage)) //marks all items in storage as being such
		in_storage = TRUE


/obj/item/proc/determine_move_resist()
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			move_resist = MOVE_FORCE_EXTREMELY_WEAK
		if(WEIGHT_CLASS_SMALL)
			move_resist = MOVE_FORCE_VERY_WEAK
		if(WEIGHT_CLASS_NORMAL)
			move_resist = MOVE_FORCE_WEAK
		if(WEIGHT_CLASS_BULKY)
			move_resist = MOVE_FORCE_NORMAL
		if(WEIGHT_CLASS_HUGE)
			move_resist = MOVE_FORCE_NORMAL
		if(WEIGHT_CLASS_GIGANTIC)
			move_resist = MOVE_FORCE_NORMAL


/obj/item/Destroy()
	flags &= ~DROPDEL	//prevent reqdels
	QDEL_NULL(hidden_uplink)

	if(ismob(loc))
		var/mob/M = loc
		M.drop_item_ground(src, TRUE)
	QDEL_LIST(actions)

	return ..()


/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || (!isturf(target.loc) && !isturf(target) && not_inside))
		return FALSE
	else
		return TRUE

/obj/item/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = null
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T


/obj/item/examine(mob/user)
	var/size
	switch(src.w_class)
		if(WEIGHT_CLASS_TINY)
			size = "tiny"
		if(WEIGHT_CLASS_SMALL)
			size = "small"
		if(WEIGHT_CLASS_NORMAL)
			size = "normal-sized"
		if(WEIGHT_CLASS_BULKY)
			size = "bulky"
		if(WEIGHT_CLASS_HUGE)
			size = "huge"
		if(WEIGHT_CLASS_GIGANTIC)
			size = "gigantic"

	var/material_string = item_string_material(user)

	. = ..(user, "", "It is a [size] item. [material_string]")

	if(user.research_scanner) //Mob has a research scanner active.
		var/msg = "*--------* <BR>"

		if(origin_tech)
			msg += "<span class='notice'>Testing potentials:</span><BR>"
			var/list/techlvls = params2list(origin_tech)
			for(var/T in techlvls) //This needs to use the better names.
				msg += "Tech: [CallTechName(T)] | Magnitude: [techlvls[T]] <BR>"
		else
			msg += "<span class='danger'>No tech origins detected.</span><BR>"


		if(materials.len)
			msg += "<span class='notice'>Extractable materials:<BR>"
			for(var/mat in materials)
				msg += "[CallMaterialName(mat)]<BR>" //Capitize first word, remove the "$"
		else
			msg += "<span class='danger'>No extractable materials detected.</span><BR>"
		msg += "*--------*"
		. += msg

	if(isclocker(user) && enchant_type)
		if(enchant_type == CASTING_SPELL)
			. += "<span class='notice'>The last spell hasn't expired yet!</span><BR>"
		for(var/datum/spell_enchant/S in enchants)
			if(S.enchantment == enchant_type)
				. += "<span class='notice'>It has a sealed spell \"[S.name]\" inside.</span><BR>"
				break


/obj/item/burn()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/obj/effect/decal/cleanable/ash/A = new(T)
		A.desc += "\nLooks like this used to be \an [name] some time ago."
		..()


/obj/item/acid_melt()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/obj/effect/decal/cleanable/molten_object/MO = new(T)
		MO.pixel_x = rand(-16,16)
		MO.pixel_y = rand(-16,16)
		MO.desc = "Looks like this was \an [src] some time ago."
		..()


/obj/item/afterattack(atom/target, mob/user, proximity, params)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity, params)
	..()

	if(!proximity)
		return
	try_item_eat(target, user)


/obj/item/attack_hand(mob/user, pickupfireoverride = FALSE)
	. = ..()
	if(.)
		return TRUE

	. = FALSE

	if(!user)
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(user.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(!temp)
			to_chat(user, SPAN_WARNING("You try to use your hand, but it's missing!"))
			return
		if(temp && !temp.is_usable())
			to_chat(user, SPAN_WARNING("You try to move your [temp.name], but cannot!"))
			return

	if((resistance_flags & ON_FIRE) && !pickupfireoverride)
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(H.gloves && (H.gloves.max_heat_protection_temperature > 360))
				extinguish()
				to_chat(user, SPAN_NOTICE("You put out the fire on [src]."))
			else
				to_chat(user, SPAN_WARNING("You burn your hand on [src]!"))
				var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_arm")
				if(affecting && affecting.receive_damage(0, 5))		// 5 burn damage
					H.UpdateDamageIcon()
				return
		else
			extinguish()

	if(acid_level > 20 && !ismob(loc))	// so we can still remove the clothes on us that have acid.
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(!H.gloves || (!(H.gloves.resistance_flags & (UNACIDABLE|ACID_PROOF))))
				to_chat(user, SPAN_WARNING("The acid on [src] burns your hand!"))
				var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_arm")
				if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
					H.UpdateDamageIcon()

	if(throwing)
		throwing.finalize(FALSE)

	if(loc == user)
		if(!allow_attack_hand_drop(user))
			return

		// inventory unequip delay
		if(equip_delay_self && !user.is_general_slot(user.get_slot_by_item(src)))
			user.visible_message(span_notice("[user] начинает снимать [name]..."), \
							span_notice("Вы начинаете снимать [name]..."))
			if(!do_after_once(user, equip_delay_self, target = user, attempt_cancel_message = "Снятие [name] было прервано!"))
				return

			if(user.get_active_hand())
				return

		if(!user.temporarily_remove_item_from_inventory(src))
			return

	else if(isliving(loc))
		return

	. = TRUE
	pickup(user)
	add_fingerprint(user)

	if(!user.put_in_active_hand(src, ignore_anim = FALSE))
		user.drop_item_ground(src)
		return FALSE


/**
 * If we want to stop manual unequipping of item by hands, but only for user himself (almost NODROP)
 */
/obj/item/proc/allow_attack_hand_drop(mob/user)
	return TRUE


/**
 * If xenos can manipulate with this item.
 */
/obj/item/proc/allowed_for_alien()
	return FALSE


/obj/item/attack_alien(mob/user)
	var/mob/living/carbon/alien/A = user

	if(!A.has_fine_manipulation)
		to_chat(user, SPAN_WARNING("Your claws aren't capable of such fine manipulation!"))
		return

	if(!allowed_for_alien())
		to_chat(user, SPAN_WARNING("Looks like [src] has no use for me!"))
		return

	attack_hand(A)


/obj/item/attack_ai(mob/user as mob)
	if(istype(src.loc, /obj/item/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		if(!R.low_power_mode) //can't equip modules with an empty cell.
			R.activate_module(src)
			R.hud_used.update_robot_modules_display()


// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage))
		var/obj/item/storage/S = I
		if(S.use_to_pickup)
			if(S.pickup_all_on_tile) //Mode is set to collect all items on a tile and we clicked on a valid one.
				if(isturf(loc))
					var/list/rejections = list()
					var/success = 0
					var/failure = 0

					for(var/obj/item/IT in loc)
						if(IT.type in rejections) // To limit bag spamming: any given type only complains once
							continue
						if(!S.can_be_inserted(IT))	// Note can_be_inserted still makes noise when the answer is no
							rejections += IT.type	// therefore full bags are still a little spammy
							failure = 1
							continue
						success = 1
						IT.do_pickup_animation(user)
						S.handle_item_insertion(IT, 1)	//The 1 stops the "You put the [src] into [S]" insertion message from being displayed.
					if(success && !failure)
						to_chat(user, "<span class='notice'>You put everything in [S].</span>")
					else if(success)
						to_chat(user, "<span class='notice'>You put some things in [S].</span>")
					else
						to_chat(user, "<span class='notice'>You fail to pick anything up with [S].</span>")

			else if(S.can_be_inserted(src))
				I.do_pickup_animation(user)
				S.handle_item_insertion(src)
	else if(istype(I, /obj/item/stack/tape_roll))
		if(istype(src, /obj/item/storage)) //Don't tape the bag if we can put the duct tape inside it instead
			var/obj/item/storage/bag = src
			if(bag.can_be_inserted(I))
				return ..()
		var/obj/item/stack/tape_roll/TR = I
		var/list/clickparams = params2list(params)
		var/x_offset = text2num(clickparams["icon-x"])
		var/y_offset = text2num(clickparams["icon-y"])
		if(GetComponent(/datum/component/ducttape))
			to_chat(user, "<span class='notice'>[src] already has some tape attached!</span>")
			return
		if(TR.use(1))
			to_chat(user, "<span class='notice'>You apply some tape to [src].</span>")
			AddComponent(/datum/component/ducttape, src, user, x_offset, y_offset)
			anchored = TRUE
			user.transfer_fingerprints_to(src)
		else
			to_chat(user, "<span class='notice'>You don't have enough tape to do that!</span>")
	else
		return ..()


/obj/item/proc/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, args)
	if(prob(final_block_chance))
		owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
		return 1
	return 0


// Generic use proc. Depending on the item, it uses up fuel, charges, sheets, etc.
// Returns TRUE on success, FALSE on failure.
/obj/item/proc/use(used)
	return !used


//Generic refill proc. Transfers something (e.g. fuel, charge) from an atom to our tool. returns TRUE if it was successful, FALSE otherwise
//Not sure if there should be an argument that indicates what exactly is being refilled
/obj/item/proc/refill(mob/user, atom/A, amount)
	return FALSE


/obj/item/proc/talk_into(mob/M, var/text, var/channel=null)
	return


/**
 * Used only to check for obscuration on do_unEqip.
 * Works faster than combination `get_slot_by_item(I) in check_obscured_slots()`, but CAN NOT be used to check items on equip.
 */
/obj/item/proc/is_obscured_for_unEquip(mob/living/carbon/human/user)
	if(!user || !istype(user))
		return FALSE

	if(user.wear_suit)
		if(src == user.w_uniform && (user.wear_suit.flags_inv & HIDEJUMPSUIT))
			return TRUE
		if(src == user.gloves && (user.wear_suit.flags_inv & HIDEGLOVES))
			return TRUE
		if(src == user.shoes && (user.wear_suit.flags_inv & HIDESHOES))
			return TRUE

	if(user.head)
		if(src == user.wear_mask && (user.head.flags_inv & HIDEMASK))
			return TRUE
		if(src == user.glasses && (user.head.flags_inv & HIDEGLASSES))
			return TRUE
		if((src == user.l_ear || src == user.r_ear) && (user.head.flags_inv & HIDEHEADSETS))
			return TRUE

	return FALSE


/**
 * When item is officially left user
 */
/obj/item/proc/dropped(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	// Remove any item actions we temporary gave out
	for(var/datum/action/action_item_has as anything in actions)
		action_item_has.Remove(user)

	if(flags & DROPDEL && !QDELETED(src))
		qdel(src)

	if((flags & NODROP) && !(initial(flags) & NODROP)) // Remove NODROP flag if it was not initial
		flags &= ~NODROP

	in_inventory = FALSE
	mouse_opacity = initial(mouse_opacity)
	remove_outline()

	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED,user)
	return TRUE


/**
 * Called just as an item is picked up (loc is not yet changed)
 */
/obj/item/proc/pickup(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)

	in_inventory = TRUE

	return TRUE


/**
 * Called when this item is removed from a storage item, which is passed on as S.
 * The loc variable is already set to the new destination before this is called.
 */
/obj/item/proc/on_exit_storage(obj/item/storage/S as obj)
	in_storage = FALSE

	do_drop_animation(S)


/**
 * Called when this item is added into a storage item, which is passed on as S.
 * The loc variable is already set to the storage item.
 */
/obj/item/proc/on_enter_storage(obj/item/storage/S as obj)
	in_storage = TRUE


/**
  * Called to check if this item can be put into a storage item.
  *
  * Return `FALSE` if `src` can't be inserted, and `TRUE` if it can.
  * Arguments:
  * * S - The [/obj/item/storage] that `src` is being inserted into.
  * * user - The mob trying to insert the item.
  */
/obj/item/proc/can_enter_storage(obj/item/storage/S, mob/user)
	return TRUE


/**
 * Called when "found" in pockets and storage items. Returns 1 if the search should end.
 */
/obj/item/proc/on_found(mob/finder as mob)
	return


/**
 * Called when the giver gives it to the receiver.
 */
/obj/item/proc/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	return


/**
 * Called after an item is placed in an equipment slot.
 * Note that hands count as slots.
 *
 * Arguments:
 * * 'user' is mob that equipped it
 * * 'slot' uses the slot_X defines found in setup.dm for items that can be placed in multiple slots
 * * 'initial' is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it
 */
/obj/item/proc/equipped(mob/user, slot, initial = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	for(var/datum/action/action_item_has as anything in actions)
		if(item_action_slot_check(slot, user))
			action_item_has.Grant(user)

	mouse_opacity = MOUSE_OPACITY_OPAQUE
	in_inventory = TRUE

	if(!initial)
		// Playsound etc. nothing for now
		equip_delay_self = equip_delay_self

	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	return TRUE


/**
 * Some items only give their actions buttons when in a specific slot.
 */
/obj/item/proc/item_action_slot_check(slot, mob/user)
	return TRUE


/**
 * Returns `TRUE` if the item is equipped by a mob, `FALSE` otherwise.
 * This might need some error trapping, not sure if get_equipped_items() is safe for non-human mobs.
 */
/obj/item/proc/is_equipped(include_pockets = FALSE, include_hands = FALSE)
	if(!ismob(loc))
		return FALSE

	var/mob/M = loc
	if(src in M.get_equipped_items(include_pockets, include_hands))
		return TRUE
	else
		return FALSE


/**
 * This proc is called whenever mob's client presses 'drop_held_object' hotkey
 * Not for robots since they have their own key in [keybindinds/robot.dm]
 * You can easily overriride it for different behavior on other items.
 */
/obj/item/proc/run_drop_held_item(mob/user)
	user.drop_from_active_hand()


/**
* Puts item into best inventory slot.
* If all slots are filled, item attempts to move in storage: container in offhand, belt, backpack.
* Proc is a real action after mob's client quick_equip hotkey is pressed. You can override it for diferent behavior.
*
* Arguments:
* * 'force' - set to `TRUE` if you want to ignore equip delay and clothing obscuration.
* * 'drop_on_fail' - set to `TRUE` if item should be dropped on equip fail.
* * 'qdel_on_fail' - set to `TRUE` if item should be deleted on equip fail.
* * 'silent' - set to `TRUE` if you want no warning messages on fail.
*/
/obj/item/proc/equip_to_best_slot(mob/user, force = FALSE, drop_on_fail = FALSE, qdel_on_fail = FALSE, silent = FALSE)

	if(user.equip_to_appropriate_slot(src, force, silent = TRUE))
		return TRUE

	if(equip_delay_self)
		if(!silent)
			to_chat(user, SPAN_WARNING("Вы должны экипировать [src] вручную!"))
		return FALSE

	//If storage is active - insert there
	if(user.s_active && user.s_active.can_be_inserted(src, TRUE))
		user.s_active.handle_item_insertion(src)
		return TRUE

	//Checking for storage item in offhand, then belt, then backpack
	var/list/possible = list( \
		user.get_inactive_hand(), \
		user.get_item_by_slot(slot_belt), \
		user.get_item_by_slot(slot_back) \
	)

	for(var/obj/item/storage/container in possible)
		if(!container)
			continue
		if(container.can_be_inserted(src, TRUE))
			return container.handle_item_insertion(src)

	if(drop_on_fail)
		if(src in user.get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			user.drop_item_ground(src)
		else
			forceMove(drop_location())
		return FALSE

	if(qdel_on_fail)
		if(src in user.get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
		qdel(src)

	if(!silent)
		to_chat(user, SPAN_WARNING("Вы не можете надеть [src]!"))

	return FALSE


/**
 * Mob 'M' is attempting to equip this item into the slot passed through as 'slot'. Return `TRUE` if it can do this and `FALSE` if it can't.
 * IF this is being done by a mob other than M, it will include the mob equipper, who is trying to equip the item to mob M. equipper will be null otherwise.
 * If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
 *
 * Arguments:
 * * 'disable_warning' set to `TRUE` if you wish no text outputs
 * * 'slot' is the slot we are trying to equip to
 * * 'bypass_equip_delay_self' for whether we want to bypass the equip delay
 * * 'bypass_obscured' for whether we want to ignore clothing obscuration
 */
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE)
	return M.can_equip(src, slot, disable_warning, bypass_equip_delay_self, bypass_obscured)


/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = null
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if(usr.incapacitated() || !Adjacent(usr))
		return
	if(!iscarbon(usr) || isbrain(usr)) //Is humanoid, and is not a brain
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if(anchored) //Object isn't anchored
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		to_chat(usr, "<span class='warning'>Your right hand is full.</span>")
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		to_chat(usr, "<span class='warning'>Your left hand is full.</span>")
		return
	if(!isturf(loc)) //Object is on a turf
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)


/**
 * This proc is executed when someone clicks the on-screen UI button.
 * The default action is attack_self().
 * Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
 */
/obj/item/proc/ui_action_click(mob/user, actiontype)
	attack_self(user)


/**
 * This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
 */
/obj/item/proc/IsReflect(def_zone)
	return FALSE


/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !istype(L, /turf/))
		L = L.loc
	return loc


/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	var/mob/living/carbon/human/H = M
	if(istype(H) && ( \
			(H.head && H.head.flags_cover & HEADCOVERSEYES) || \
			(H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) || \
			(H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, "<span class='danger'>You're going to need to remove that mask/helmet/glasses first!</span>")
		return

	if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/simple_animal/slime))//Aliens don't have eyes./N     slimes also don't have eyes!
		to_chat(user, "<span class='warning'>You cannot locate any eyes on this creature!</span>")
		return

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	src.add_fingerprint(user)

	playsound(loc, src.hitsound, 30, 1, -1)

	user.do_attack_animation(M)

	if(M != user)
		M.visible_message("<span class='danger'>[user] has stabbed [M] in the eye with [src]!</span>", \
							"<span class='userdanger'>[user] stabs you in the eye with [src]!</span>")
	else
		user.visible_message( \
			"<span class='danger'>[user] has stabbed [user.p_them()]self in the eyes with [src]!</span>", \
			"<span class='userdanger'>You stab yourself in the eyes with [src]!</span>" \
		)

	add_attack_logs(user, M, "Eye-stabbed with [src] ([uppertext(user.a_intent)])")

	if(istype(H))
		var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
		if(!eyes) // should still get stabbed in the head
			var/obj/item/organ/external/head/head = H.bodyparts_by_name["head"]
			head.receive_damage(rand(10,14), 1)
			return
		eyes.receive_damage(rand(3,4), 1)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != 2)
				if(!eyes.is_robotic())  //robot eyes bleeding might be a bit silly
					to_chat(M, "<span class='danger'>Your eyes start to bleed profusely!</span>")
			if(prob(50))
				if(M.stat != DEAD)
					to_chat(M, "<span class='danger'>You drop what you're holding and clutch at your eyes!</span>")
					M.drop_from_active_hand()
				M.AdjustEyeBlurry(20 SECONDS)
				M.Paralyse(2 SECONDS)
				M.Weaken(4 SECONDS)
			if(eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, "<span class='danger'>You go blind!</span>")
		var/obj/item/organ/external/affecting = H.get_organ("head")
		if(affecting.receive_damage(7))
			H.UpdateDamageIcon()
	else
		M.take_organ_damage(7)
	M.AdjustEyeBlurry(rand(6 SECONDS, 8 SECONDS))
	return


/obj/item/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FOUR)
		throw_at(S, 14, 3, spin = 0)
	else
		return


/obj/item/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(hit_atom && !QDELETED(hit_atom))
		SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
		var/itempush = TRUE
		if(w_class < WEIGHT_CLASS_BULKY)
			itempush = FALSE // too light to push anything
		return hit_atom.hitby(src, FALSE, itempush, throwingdatum = throwingdatum)


/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force)
	thrownby = thrower
	callback = CALLBACK(src, PROC_REF(after_throw), callback) //replace their callback with our own
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback, force)


/obj/item/proc/after_throw(datum/callback/callback)
	if(callback) //call the original callback
		. = callback.Invoke()
	throw_speed = initial(throw_speed) //explosions change this.
	in_inventory = FALSE


/obj/item/proc/pwr_drain()
	return FALSE // Process Kill


/obj/item/proc/remove_item_from_storage(atom/newLoc) //please use this if you're going to snowflake an item out of a obj/item/storage
	if(!newLoc)
		return FALSE
	if(istype(loc,/obj/item/storage))
		var/obj/item/storage/S = loc
		S.remove_from_storage(src,newLoc)
		return TRUE
	return FALSE


/obj/item/proc/wash(mob/user, atom/source)
	if(flags & ABSTRACT) //Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return
	to_chat(user, "<span class='notice'>You start washing [src]...</span>")
	if(!do_after(user, 40, target = source))
		return
	clean_blood()
	acid_level = 0
	user.visible_message("<span class='notice'>[user] washes [src] using [source].</span>", \
						"<span class='notice'>You wash [src] using [source].</span>")
	return TRUE


/obj/item/proc/is_crutch() //Does an item prop up a human mob and allow them to stand if they are missing a leg/foot?
	return 0


// Return true if you don't want regular throw handling
/obj/item/proc/override_throw(mob/user, atom/target)
	return FALSE


/obj/item/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return


/obj/item/attack_animal(mob/living/simple_animal/M)
	if(can_be_hit)
		return ..()
	return FALSE


/obj/item/mech_melee_attack(obj/mecha/M)
	return FALSE


/obj/item/proc/openTip(location, control, params, user)
	openToolTip(user, src, params, title = name, content = "[desc]", theme = "")


/obj/item/MouseEntered(location, control, params)
	if(in_inventory || in_storage)
		var/timedelay = 8
		var/mob/user = usr
		tip_timer = addtimer(CALLBACK(src, PROC_REF(openTip), location, control, params, user), timedelay, TIMER_STOPPABLE)
		if(QDELETED(src))
			return
		var/mob/living/L = user
		if(!(user.client.prefs.toggles2 & PREFTOGGLE_2_SEE_ITEM_OUTLINES))
			return
		if(istype(L) && L.incapacitated(ignore_lying = TRUE))
			apply_outline(L, COLOR_RED_GRAY) //if they're dead or handcuffed, let's show the outline as red to indicate that they can't interact with that right now
		else
			apply_outline(L) //if the player's alive and well we send the command with no color set, so it uses the theme's color


/obj/item/MouseExited()
	deltimer(tip_timer) //delete any in-progress timer if the mouse is moved off the item before it finishes
	closeToolTip(usr)
	remove_outline()


/obj/item/MouseDrop_T(atom/dropping, mob/user)
	if(!user || user.incapacitated(ignore_lying = TRUE) || src == dropping)
		return FALSE

	if(loc && dropping.loc == loc && istype(loc, /obj/item/storage) && loc.Adjacent(user)) // Are we trying to swap two items in the storage?
		var/obj/item/storage/S = loc
		S.swap_items(src, dropping, user)
	remove_outline() //get rid of the hover effect in case the mouse exit isn't called if someone drags and drops an item and somthing goes wrong
	return TRUE


/obj/item/proc/apply_outline(mob/user, outline_color = null)
	if(!(in_inventory || in_storage) || QDELETED(src) || isobserver(user)) //cancel if the item isn't in an inventory, is being deleted, or if the person hovering is a ghost (so that people spectating you don't randomly make your items glow)
		return
	var/theme = lowertext(user.client.prefs.UI_style)
	if(!outline_color) //if we weren't provided with a color, take the theme's color
		switch(theme) //yeah it kinda has to be this way
			if("midnight")
				outline_color = COLOR_THEME_MIDNIGHT
			if("plasmafire")
				outline_color = COLOR_THEME_PLASMAFIRE
			if("retro")
				outline_color = COLOR_THEME_RETRO //just as garish as the rest of this theme
			if("slimecore")
				outline_color = COLOR_THEME_SLIMECORE
			if("operative")
				outline_color = COLOR_THEME_OPERATIVE
			if("clockwork")
				outline_color = COLOR_THEME_CLOCKWORK //if you want free gbp go fix the fact that clockwork's tooltip css is glass'
			if("glass")
				outline_color = COLOR_THEME_GLASS
			else //this should never happen, hopefully
				outline_color = COLOR_WHITE
	if(color)
		outline_color = COLOR_WHITE //if the item is recolored then the outline will be too, let's make the outline white so it becomes the same color instead of some ugly mix of the theme and the tint
	if(outline_filter)
		filters -= outline_filter
	outline_filter = filter(type = "outline", size = 1, color = outline_color)
	filters += outline_filter


/obj/item/proc/remove_outline()
	if(outline_filter)
		filters -= outline_filter
		outline_filter = null


// Returns a numeric value for sorting items used as parts in machines, so they can be replaced by the rped
/obj/item/proc/get_part_rating()
	return 0


/obj/item/proc/update_equipped_item()
	if(QDELETED(src) || QDELETED(loc) || !ishuman(loc))
		return

	var/mob/living/carbon/human/owner = loc
	var/slot = owner.get_slot_by_item(src)

	switch(slot)
		if(slot_wear_suit)
			owner.wear_suit_update(src)

		if(slot_w_uniform)
			owner.update_inv_w_uniform()

		if(slot_gloves)
			owner.update_inv_gloves()

		if(slot_neck)
			owner.update_inv_neck()

		if(slot_glasses)
			owner.wear_glasses_update(src)

		if(slot_head)
			owner.update_head(src)

		if(slot_l_ear, slot_r_ear)
			owner.update_inv_ears()

		if(slot_shoes)
			owner.update_inv_shoes()

		if(slot_belt)
			owner.update_inv_belt()

		if(slot_wear_mask)
			owner.wear_mask_update(src)

		if(slot_wear_id)
			owner.sec_hud_set_ID()
			owner.update_inv_wear_id()

		if(slot_wear_pda)
			owner.update_inv_wear_pda()

		if(slot_l_store, slot_r_store)
			owner.update_inv_pockets()

		if(slot_s_store)
			owner.update_inv_s_store()

		if(slot_back)
			owner.update_inv_back()

		if(slot_l_hand)
			owner.update_inv_l_hand()

		if(slot_r_hand)
			owner.update_inv_r_hand()


/obj/item/proc/update_slot_icon()
	if(!ismob(loc))
		return
	var/mob/owner = loc
	var/flags = slot_flags
	if(flags & SLOT_OCLOTHING)
		owner.update_inv_wear_suit()
	if(flags & SLOT_ICLOTHING)
		owner.update_inv_w_uniform()
	if(flags & SLOT_GLOVES)
		owner.update_inv_gloves()
	if(flags & SLOT_EYES)
		owner.update_inv_glasses()
	if(flags & SLOT_EARS)
		owner.update_inv_ears()
	if(flags & SLOT_MASK)
		owner.update_inv_wear_mask()
	if(flags & SLOT_NECK)
		owner.update_inv_neck()
	if(flags & SLOT_HEAD)
		owner.update_inv_head()
	if(flags & SLOT_FEET)
		owner.update_inv_shoes()
	if(flags & SLOT_ID)
		owner.update_inv_wear_id()
	if(flags & SLOT_BELT)
		owner.update_inv_belt()
	if(flags & SLOT_BACK)
		owner.update_inv_back()
	if(flags & SLOT_PDA)
		owner.update_inv_wear_pda()
	if(owner.r_hand == src)
		owner.update_inv_r_hand()
	else if(owner.l_hand == src)
		owner.update_inv_l_hand()


/obj/item/proc/update_materials_coeff(new_coeff)
	if(new_coeff <= 1)
		materials_coeff = new_coeff
	else
		materials_coeff = 1 / new_coeff
	for(var/material in materials)
		materials[material] *= materials_coeff


/obj/item/proc/deplete_spell()
	enchant_type = NO_SPELL
	var/enchant_action = locate(/datum/action/item_action/activate/enchant) in actions
	if(enchant_action)
		qdel(enchant_action)
	update_icon()


/obj/item/update_atom_colour()
	. = ..()
	if(!is_equipped())
		return
	update_slot_icon()
	for(var/action in actions)
		var/datum/action/myaction = action
		myaction.UpdateButtonIcon()


/**
 * Simple helper we need to call before putting any item in hands, to allow fancy animation.
 * Item will be forceMoved() to turf below its holder.
 */
/obj/item/proc/forceMove_turf()
	var/turf/newloc = get(src, /turf)
	if(!newloc)
		CRASH("Item holder is not in turf contents.")
	forceMove(newloc)


/**
 * Proc that checks if item is on user
 */
/obj/item/proc/is_on_user(mob/living/user)
	return user = get(src, /mob/living)


/obj/item/proc/do_pickup_animation(atom/target)

	if(!config.item_animations_enabled)
		return

	if(!isturf(loc) || !target)
		return

	if(get_turf(src) == get_turf(target))	// No need for pickup animation if item is on user or on the same turf
		return

	var/image/transfer_animation = image(icon = src, loc = src.loc, layer = MOB_LAYER + 0.1)
	transfer_animation.transform.Scale(0.75)
	transfer_animation.plane = GAME_PLANE
	transfer_animation.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	var/target_x = target.pixel_x
	var/target_y = target.pixel_y
	var/direction = get_dir(get_turf(src), target)

	if(direction & NORTH)
		target_y += 32
	else if(direction & SOUTH)
		target_y -= 32
	if(direction & EAST)
		target_x += 32
	else if(direction & WEST)
		target_x -= 32
	if(!direction)
		target_y += 10
		transfer_animation.pixel_x += 6 * (prob(50) ? 1 : -1)

	flick_overlay_view(transfer_animation, 4)
	var/matrix/animation_matrix = new(transfer_animation.transform)
	animation_matrix.Turn(pick(-30, 30))
	animation_matrix.Scale(0.65)

	animate(transfer_animation, alpha = 175, pixel_x = target_x, pixel_y = target_y, time = 3, transform = animation_matrix, easing = CUBIC_EASING)
	animate(alpha = 0, transform = matrix().Scale(0.7), time = 1)


/obj/item/proc/do_drop_animation(atom/moving_from)

	if(!config.item_animations_enabled)
		return

	if(!isturf(loc) || !istype(moving_from))
		return

	var/from_x = moving_from.pixel_x
	var/from_y = moving_from.pixel_y
	var/direction = get_dir(moving_from, get_turf(src))

	if(direction & NORTH)
		from_y -= 32
	else if(direction & SOUTH)
		from_y += 32
	if(direction & EAST)
		from_x -= 32
	else if(direction & WEST)
		from_x += 32
	if(!direction)
		from_y += 10
		from_x += 6 * (prob(50) ? 1 : -1) //6 to the right or left, helps break up the straight upward move

	//We're moving from these chords to our current ones
	var/old_x = pixel_x
	var/old_y = pixel_y
	var/old_alpha = alpha
	var/matrix/old_transform = transform
	var/matrix/animation_matrix = new(old_transform)
	animation_matrix.Turn(pick(-30, 30))
	animation_matrix.Scale(0.7) // Shrink to start, end up normal sized

	pixel_x = from_x
	pixel_y = from_y
	alpha = 0
	transform = animation_matrix

	// This is instant on byond's end, but to our clients this looks like a quick drop
	animate(src, alpha = old_alpha, pixel_x = old_x, pixel_y = old_y, transform = old_transform, time = 3, easing = CUBIC_EASING)
