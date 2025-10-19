GLOBAL_DATUM_INIT(fire_overlay, /image, image("icon" = 'icons/goonstation/effects/fire.dmi', "icon_state" = "fire"))
GLOBAL_DATUM_INIT(welding_sparks, /mutable_appearance, mutable_appearance('icons/effects/welding_effect.dmi', "welding_sparks", GASFIRE_LAYER, ABOVE_LIGHTING_PLANE))

/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	max_integrity = 200
	can_be_hit = FALSE
	suicidal_hands = TRUE
	/// Set in the Initialise depending on the item size. Unless it's overriden by a specific item
	move_resist = null

	/**
	 * Species-specific sprites, concept stolen from Paradise//vg/.
	 *
	 * ex:
	 *
	 *	sprite_sheets = list("Tajaran" = 'icons/cat/are/bad')
	 *
	 * If index term exists, this sprite sheet will be used.
	 *
	 * This should never have a "Human" inside - use `worn_icon` instead.
	*/
	var/list/sprite_sheets
	/// Used to override inhand items. Use a single .dmi and suffix the icon states inside with _l and _r for each hand.
	var/list/sprite_sheets_inhand

	/// Icon file for mob worn overlays. Can be ignored if sprite_sheets/sprite_sheets_inhand is set
	var/icon/worn_icon
	/// Icon state for mob worn overlays, if null the `icon_state` value will be used
	var/worn_icon_state

	/// Icon state for mob inhand overlays, if null the `icon_state` value will be used
	var/inhand_icon_state
	/// Icon file for left hand inhand overlays
	var/icon/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	/// Icon file for right inhand overlays
	var/icon/righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	/// Dimension X of the lefthand_file and righthand_file var
	/// eg: 32x32 sprite, 64x64 sprite, etc.
	var/inhand_x_dimension = 32
	/// Dimension Y of the lefthand_file and righthand_file var
	/// eg: 32x32 sprite, 64x64 sprite, etc.
	var/inhand_y_dimension = 32

	/// used in item_attack.dm to make an item not show an attack message to viewers
	var/discrete = FALSE
	/// Sound played when you hit something with the item
	var/hitsound
	/// Played when the item is used, for example tools
	var/usesound
	/// Used when yate into a mob
	var/mob_throw_hit_sound
	/// Sound used when equipping the item into a valid slot
	var/equip_sound
	/// Sound uses when picking the item up (into your hands)
	var/pickup_sound
	/// Sound uses when dropping the item, or when its thrown.
	var/drop_sound
	/// Whether or not we use stealthy audio levels for this item's attack sounds
	var/stealthy_audio = FALSE
	/// Allows you to override the attack animation with an attack effect
	var/attack_effect_override
	/// Used in attackby() to say how something was attacked `"[x] has been [z.attack_verb] by [y] with [z]"`
	var/list/attack_verb
	/// Determines how big/small items are to fit in storage containers
	var/w_class = WEIGHT_CLASS_NORMAL
	/// This is used to determine on which slots an item can fit.
	var/slot_flags = 0
	/// If set, this determines which slots are considered when using quick equip
	var/prefered_slot_flags = 0
	/// Determines what it can pass over/through. IE. 'PASSTABLE' will allow it to pass over tables
	pass_flags = PASSTABLE
	pressure_resistance = 4
	should_spread_blood = TRUE
	var/obj/item/master

	/// Flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/heat_protection = 0
	/// Flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0
	/// Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/max_heat_protection_temperature
	/// Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags
	var/min_cold_protection_temperature
	/// List of /datum/action's that this item has.
	var/list/actions = list()
	/// List of paths of action datums to give to the item on New().
	var/list/actions_types = list()

	/// What materials the item yields when broken down. Some methods will not recover everything (autolathes only recover metal and glass, for example).
	var/list/materials = list()
	/// Since any item can now be a piece of clothing, this has to be put here so all items share it.
	/// This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/flags_inv
	/// The associated key to the dye registry GLOB list, used to transform/color this piece of clothing through dyeing
	var/dyeing_key
	/// If this item is put into a washing machine to be dyed, can objects of this type be dyed into a different color/icon?
	var/dyeable = FALSE
	/// What bodyflags does this item cover? See setup.dm for appropriate bit flags
	var/body_parts_covered = 0
	/// For leaking gas from turf to mask and vice-versa.
	var/gas_transfer_coefficient = 1
	/// for chemicals/diseases
	var/permeability_coefficient = 1
	/// for electrical admittance/conductance (electrocution checks and shit)
	var/siemens_coefficient = 1
	/// How much clothing is slowing you down. Negative values speeds you up.
	var/slowdown = 0
	/// Flat armour reduction, occurs after percentage armour penetration.
	var/armor_penetration_flat = 0
	/// Percentage armour reduction, happens before flat armour reduction.
	var/armor_penetration_percentage = 0
	/// For what suits can store. IE. secuirty vest holding stunbatons, disablers, cuffs.
	var/list/allowed = list()
	/// All items can have an uplink hidden inside, just remember to add the triggers.
	var/obj/item/uplink/hidden/hidden_uplink

	/// Used by security bots to determine if this item is safe for public use.
	var/needs_permit = FALSE
	/// How long it takes to remove an item off of somebody. IE. clothing
	var/strip_delay = DEFAULT_ITEM_STRIP_DELAY
	/// How long it takes to put an item onto somebody. IE. clothing
	var/put_on_delay = DEFAULT_ITEM_PUTON_DELAY
	/// For flags that define what areas an item cover
	var/flags_cover = 0

	/// Used to give a reaction chance on hit that is not a block. If less than 0, will remove the block message, allowing overides.
	var/hit_reaction_chance = 0

	/// What can/cant be worn, and where is valid to be worn by ian/E-N(and corgies), most of the time changing the name and emotes of the pet.
	// Needs to be in /obj/item because corgis can wear a lot of non-clothing items
	var/datum/dog_fashion/dog_fashion = null

	/// UID of a /mob
	var/thrownby

	/// So items can have custom embedd values because customisation is king
	var/embed_chance = EMBED_CHANCE
	/// The chances of the item falling out of the limb
	var/embedded_fall_chance = EMBEDDED_ITEM_FALLOUT
	/// The cances of the item dealing damage to the limb
	var/embedded_pain_chance = EMBEDDED_PAIN_CHANCE
	/// The coefficient of multiplication for the damage this item does while embedded (this * w_class)
	var/embedded_pain_multiplier = EMBEDDED_PAIN_MULTIPLIER
	/// The coefficient of multiplication for the damage this item does when falling out of a limb (this * w_class)
	var/embedded_fall_pain_multiplier = EMBEDDED_FALL_PAIN_MULTIPLIER
	/// The coefficient of multiplication for the damage this item does when first embedded (this * w_class)
	var/embedded_impact_pain_multiplier = EMBEDDED_IMPACT_PAIN_MULTIPLIER
	/// The coefficient of multiplication for the damage removing this without surgery causes (this * w_class)
	var/embedded_unsafe_removal_pain_multiplier = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER
	/// A time in ticks, multiplied by the w_class.
	var/embedded_unsafe_removal_time = EMBEDDED_UNSAFE_REMOVAL_TIME
	/// How fast something has to be going to embed
	var/embedded_ignore_throwspeed_threshold = FALSE

	/// What kind of tool are we?
	var/tool_behaviour = NONE
	/// If we can turn on or off, are we currently active? Mostly for welders and this will normally be TRUE
	var/tool_enabled = TRUE
	/// How loud are we when we use our tool?
	var/tool_volume = 50
	/// If this item is a tool, the speed multiplier. Smaller numbers are faster.
	var/toolspeed = 1

	//Tooltip vars

	/// Is this item equipped into an inventory slot or hand of a mob?
	var/in_inventory = FALSE

	var/tip_timer = 0

	// Smithing vars
	/// List of attached tool bits
	var/list/attached_bits = list()
	/// Maximum number of bits
	var/max_bits = 1
	/// Failure rate of using this tool. Without a bit, defaults to 0 for no failure chance
	var/bit_failure_rate = 0
	/// Efficiency modifier for tools that use energy or fuel
	var/bit_efficiency_mod = 1
	/// Productivity modifier for tools
	var/bit_productivity_mod = 1

	///////////////////////////
	// MARK: item hover FX
	///////////////////////////

	/// Is this item inside a storage object?
	var/in_storage = FALSE
	// For assigning a belt overlay icon state in belts.dmi
	var/belt_icon = null
	/// Holder var for the item outline filter, null when no outline filter on the item.
	var/outline_filter
	/// In tiles, how far this weapon can reach; 1 for adjacent, which is default
	var/reach = 1

	scatter_distance = 5

/obj/item/New()
	..()

	if(!hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"
	LAZYINITLIST(attack_verb)
	if(!move_resist)
		determine_move_resist()

/obj/item/Initialize(mapload)
	. = ..()
	for(var/path in actions_types)
		new path(src)
	if(isstorage(loc)) //marks all items in storage as being such
		in_storage = TRUE

/// This proc is used to add text for items with ABSTRACT flag after default examine text.
/obj/item/proc/customised_abstract_text(mob/living/carbon/owner)
	return

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
		var/mob/m = loc
		m.unequip(src, force = TRUE)
	QDEL_LIST_CONTENTS(actions)

	master = null
	return ..()

/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || (!isturf(target.loc) && !isturf(target) && not_inside))
		return FALSE
	else
		return TRUE

/obj/item/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)

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

	. = ..(user, "", "It is a [size] item.")

	if(user.research_scanner) //Mob has a research scanner active.
		var/msg = "*--------* <BR>"

		if(origin_tech)
			msg += "<span class='notice'>Testing potentials:</span><BR>"
			var/list/techlvls = params2list(origin_tech)
			for(var/T in techlvls) //This needs to use the better names.
				msg += "Tech: [GLOB.rnd_tech_id_to_name[T]] | Magnitude: [techlvls[T]] <br>"
		else
			msg += "<span class='danger'>No tech origins detected.</span><BR>"

		if(length(materials))
			msg += "<span class='notice'>Extractable materials:<BR>"
			for(var/mat in materials)
				msg += "[CallMaterialName(mat)]<BR>" //Capitize first word, remove the "$"
		else
			msg += "<span class='danger'>No extractable materials detected.</span><BR>"
		msg += "*--------*"
		. += msg

	if(length(attached_bits))
		. += "<span class='notice'>Has [length(attached_bits)] bits attached.</span>"
		. += "<span class='notice'>Bits can be removed with Alt-Click.</span>"

/obj/item/burn()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		new /obj/effect/decal/cleanable/ash(T)
		..()

/obj/item/acid_melt()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/obj/effect/decal/cleanable/molten_object/MO = new(T)
		MO.pixel_x = rand(-16,16)
		MO.pixel_y = rand(-16,16)
		MO.desc = "Looks like this was \an [src] some time ago."
		..()

/obj/item/attack_hand(mob/user as mob, pickupfireoverride = FALSE)
	if(!user)
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(user.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(!temp)
			to_chat(user, "<span class='warning'>You try to use your hand, but it's missing!</span>")
			return FALSE
		if(temp && !temp.is_usable())
			to_chat(user, "<span class='warning'>You try to move your [temp.name], but cannot!</span>")
			return FALSE

	if((resistance_flags & ON_FIRE) && !pickupfireoverride)
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(H.gloves && (H.gloves.max_heat_protection_temperature > 360))
				extinguish()
				to_chat(user, "<span class='notice'>You put out the fire on [src].</span>")
			else
				to_chat(user, "<span class='warning'>You burn your hand on [src]!</span>")
				var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_arm")
				if(affecting && affecting.receive_damage(0, 5))		// 5 burn damage
					H.UpdateDamageIcon()
				return
		else
			extinguish()

	if(acid_level > 20 && !ismob(loc))// so we can still remove the clothes on us that have acid.
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(!H.gloves || (!(H.gloves.resistance_flags & (UNACIDABLE|ACID_PROOF))))
				to_chat(user, "<span class='warning'>The acid on [src] burns your hand!</span>")
				var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_arm")
				if(affecting && affecting.receive_damage(0, 5))	// 5 burn damage
					H.UpdateDamageIcon()

	if(..())
		return

	if(throwing)
		throwing.finalize(FALSE)

	if(isliving(loc))
		if(loc == user)
			if(HAS_TRAIT(user, TRAIT_I_WANT_BRAINS) || !user.unequip(src))
				return FALSE
		else
			return FALSE

	if(flags & ABSTRACT)
		return FALSE

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src))
		dropped(user, TRUE)
		return FALSE

	return TRUE

/obj/item/attack_alien(mob/user)
	var/mob/living/carbon/alien/A = user

	if(!A.has_fine_manipulation && !HAS_TRAIT(src, TRAIT_XENO_INTERACTABLE))
		if(src in A.contents) // To stop Aliens having items stuck in their pockets
			A.drop_item_to_ground(src)
		to_chat(user, "<span class='warning'>Your claws aren't capable of such fine manipulation!</span>")
		return
	attack_hand(A)

/obj/item/attack_ai(mob/user as mob)
	if(istype(loc, /obj/item/robot_module))
		// If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		if(!R.low_power_mode) // Can't equip modules with an empty cell.
			R.activate_item(src)
			R.hud_used.update_robot_modules_display()

// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby__legacy__attackchain(obj/item/I, mob/living/user, params)
	if(isstorage(I))
		var/obj/item/storage/S = I
		if(S.use_to_pickup)
			if(S.pickup_all_on_tile) // Mode is set to collect all items on a tile and we clicked on a valid one.
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
						S.handle_item_insertion(IT, user, TRUE)	// The TRUE stops the "You put the [src] into [S]" insertion message from being displayed.
					if(success && !failure)
						to_chat(user, "<span class='notice'>You put everything in [S].</span>")
					else if(success)
						to_chat(user, "<span class='notice'>You put some things in [S].</span>")
					else
						to_chat(user, "<span class='notice'>You fail to pick anything up with [S].</span>")

			else if(S.can_be_inserted(src))
				S.handle_item_insertion(src, user)
	else if(istype(I, /obj/item/stack/tape_roll))
		if(isstorage(src)) // Don't tape the bag if we can put the duct tape inside it instead
			var/obj/item/storage/bag = src
			if(bag.can_be_inserted(I))
				return
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

/obj/item/proc/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/signal_result = (SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, owner, hitby, damage, attack_type)) + prob(final_block_chance)
	if(!signal_result)
		return FALSE
	if(hit_reaction_chance >= 0) // Normally used for non blocking hit reactions, but also used for displaying block message on actual blocks
		owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
	return signal_result

/// Used to add a bit through a signal
/obj/item/proc/add_bit(atom/source, obj/item/smithed_item/tool_bit/bit, mob/user)
	SIGNAL_HANDLER // COMSIG_BIT_ATTACH
	if(length(attached_bits) >= max_bits)
		to_chat(user, "<span class='notice'>Your tool already has the maximum number of bits!</span>")
		return
	if(bit.flags & NODROP || !user.transfer_item_to(bit, src))
		to_chat(user, "<span class='warning'>[bit] is stuck to your hand!</span>")
		return
	attached_bits += bit
	bit.on_attached(src)

/// Used to remove a bit through a signal
/obj/item/proc/remove_bit(atom/source, mob/user)
	SIGNAL_HANDLER // COMSIG_CLICK_ALT
	if(!Adjacent(user))
		return
	if(!length(attached_bits))
		to_chat(user, "<span class='notice'>Your [src] has no tool bits to remove.</span>")
		return

	INVOKE_ASYNC(src, PROC_REF(finish_remove_bit), user)

/obj/item/proc/finish_remove_bit(mob/user)
	if(!Adjacent(user))
		return
	var/obj/item/smithed_item/tool_bit/old_bit
	if(length(attached_bits) == 1)
		old_bit = attached_bits[1]
	else
		old_bit = tgui_input_list(user, "Select a tool bit", src, attached_bits)
	if(!istype(old_bit, /obj/item/smithed_item/tool_bit))
		return
	old_bit.on_detached()
	user.put_in_hands(old_bit)

/// Generic use proc. Depending on the item, it uses up fuel, charges, sheets, etc. Returns TRUE on success, FALSE on failure.
/obj/item/proc/use(used)
	return !used

/// Generic refill proc. Transfers something (e.g. fuel, charge) from an atom to our tool. returns TRUE if it was successful, FALSE otherwise
/obj/item/proc/refill(mob/user, atom/A, amount) // Not sure if there should be an argument that indicates what exactly is being refilled
	return FALSE

/obj/item/proc/talk_into(mob/M, text, channel=null)
	return

/// Called when a mob drops an item.
/obj/item/proc/dropped(mob/user, silent = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(user)
	if(flags & DROPDEL)
		qdel(src)
	if((flags & NODROP) && !(initial(flags) & NODROP)) // Remove NODROP if dropped. Probably from delimbing.
		flags &= ~NODROP
	in_inventory = FALSE
	mouse_opacity = initial(mouse_opacity)
	remove_outline()
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED,user)
	if(!silent)
		playsound(src, drop_sound, DROP_SOUND_VOLUME, ignore_walls = FALSE)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)
	in_inventory = TRUE

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/storage/S as obj)
	in_storage = FALSE
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/storage/S as obj)
	in_storage = TRUE
	return

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

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return

// called when the giver gives it to the receiver
/obj/item/proc/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// Initial is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it
/obj/item/proc/equipped(mob/user, slot, initial = FALSE)
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(slot, user)) //some items only give their actions buttons when in a specific slot.
			A.Grant(user)
	in_inventory = TRUE
	if(!initial)
		if(equip_sound && (slot & slot_flags))
			playsound(src, equip_sound, EQUIP_SOUND_VOLUME, TRUE, ignore_walls = FALSE)
		else if(slot & ITEM_SLOT_BOTH_HANDS)
			playsound(src, pickup_sound, PICKUP_SOUND_VOLUME, ignore_walls = FALSE)

/obj/item/proc/item_action_slot_check(slot, mob/user)
	return TRUE

/// returns TRUE if the item is equipped by a mob, 0 otherwise.
/obj/item/proc/is_equipped() // This might need some error trapping, not sure if get_equipped_items() is safe for non-human mobs.
	if(!ismob(loc))
		return FALSE

	var/mob/M = loc
	if(src in M.get_equipped_items())
		return TRUE
	else
		return FALSE

// the mob(M) is attempting to equip this item into the slot passed through as 'slot'. Return TRUE if it can do this and FALSE if it can't.
// If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
// Set disable_warning to FALSE if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = FALSE)
	if(!M)
		return FALSE

	return M.can_equip(src, slot, disable_warning)

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = null
	set name = "Pick up"

	if(!(usr)) // BS12 EDIT
		return
	if(usr.incapacitated() || !Adjacent(usr))
		return
	if(!iscarbon(usr) || isbrain(usr)) // Is humanoid, and is not a brain
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if(anchored) // Object isn't anchored
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	if(!usr.hand && usr.r_hand) // Right hand is not full
		to_chat(usr, "<span class='warning'>Your right hand is full.</span>")
		return
	if(usr.hand && usr.l_hand) // Left hand is not full
		to_chat(usr, "<span class='warning'>Your left hand is full.</span>")
		return
	if(!isturf(loc)) // Object is on a turf
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	// All checks are done, time to pick it up!
	usr.UnarmedAttack(src)


// This proc is executed when someone clicks the on-screen UI button.
// The default action is attack_self().
// Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/user, actiontype)
	if(new_attack_chain)
		activate_self(user)
	else
		attack_self__legacy__attackchain(user)

/obj/item/proc/IsReflect(def_zone) // This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
	return FALSE

/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !isturf(L))
		L = L.loc
	return loc

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(force && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
		return FALSE

	var/mob/living/carbon/human/H = M
	if(istype(H) && ( \
			(H.head && H.head.flags_cover & HEADCOVERSEYES) || \
			(H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) || \
			(H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, "<span class='danger'>You're going to need to remove that mask/helmet/glasses first!</span>")
		return

	if(isalien(M) || isslime(M)) // Aliens don't have eyes, slimes also don't have eyes!
		to_chat(user, "<span class='warning'>You cannot locate any eyes on this creature!</span>")
		return

	src.add_fingerprint(user)

	playsound(loc, src.hitsound, 30, TRUE, -1)

	user.do_attack_animation(M)

	if(H.check_shields(src, force, "the [name]", MELEE_ATTACK))
		return FALSE

	if(M != user)
		M.visible_message("<span class='danger'>[user] has stabbed [M] in the eye with [src]!</span>", \
							"<span class='userdanger'>[user] stabs you in the eye with [src]!</span>")
	else
		user.visible_message( \
			"<span class='danger'>[user] has stabbed [user.p_themselves()] in the eyes with [src]!</span>", \
			"<span class='userdanger'>You stab yourself in the eyes with [src]!</span>" \
		)

	add_attack_logs(user, M, "Eye-stabbed with [src] ([uppertext(user.a_intent)])")

	if(istype(H))
		var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
		if(!eyes) // should still get stabbed in the head
			var/obj/item/organ/external/head/head = H.bodyparts_by_name["head"]
			if(head)
				head.receive_damage(force, TRUE)
			return
		eyes.receive_damage(rand(3,4), 1)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != 2)
				if(!eyes.is_robotic()) // robot eyes bleeding might be a bit silly
					to_chat(M, "<span class='danger'>Your eyes start to bleed profusely!</span>")
			if(prob(50))
				if(M.stat != DEAD)
					to_chat(M, "<span class='danger'>You drop what you're holding and clutch at your eyes!</span>")
					M.drop_item()
				M.AdjustEyeBlurry(20 SECONDS)
				M.Paralyse(2 SECONDS)
				M.Weaken(4 SECONDS)
			if(eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, "<span class='danger'>You go blind!</span>")
		var/obj/item/organ/external/affecting = H.get_organ("head")
		if(istype(affecting) && affecting.receive_damage(force))
			H.UpdateDamageIcon()
	else
		M.take_organ_damage(force)
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
		if(isliving(hit_atom)) // Living mobs handle hit sounds differently.
			if(get_heat())
				var/mob/living/L = hit_atom
				L.IgniteMob()
			var/volume = get_volume_by_throwforce_and_or_w_class()
			if(throwforce > 0)
				if(mob_throw_hit_sound)
					SSthrowing.playsound_capped(hit_atom, mob_throw_hit_sound, volume, TRUE, -1)
				else if(hitsound)
					SSthrowing.playsound_capped(hit_atom, hitsound, volume, TRUE, -1)
				else
					SSthrowing.playsound_capped(hit_atom, 'sound/weapons/genhit.ogg', volume, TRUE, -1)
			else
				SSthrowing.playsound_capped(hit_atom, 'sound/weapons/throwtap.ogg', volume, TRUE, -1)

		else
			SSthrowing.playsound_capped(src, drop_sound, YEET_SOUND_VOLUME, ignore_walls = FALSE)
		return hit_atom.hitby(src, 0, itempush, throwingdatum = throwingdatum)

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin = 1, diagonals_first = 0, datum/callback/callback, force, dodgeable)
	thrownby = thrower?.UID()
	callback = CALLBACK(src, PROC_REF(after_throw), callback) // replace their callback with our own
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback, force, dodgeable)

/obj/item/proc/after_throw(datum/callback/callback)
	if(callback) // call the original callback
		. = callback.Invoke()
	throw_speed = initial(throw_speed) // explosions change this.
	in_inventory = FALSE

/obj/item/proc/pwr_drain()
	return FALSE // Process Kill

/obj/item/proc/remove_item_from_storage(atom/newLoc) // please use this if you're going to snowflake an item out of a obj/item/storage
	if(!newLoc)
		return FALSE
	if(isstorage(loc))
		var/obj/item/storage/S = loc
		S.remove_from_storage(src,newLoc)
		return TRUE
	return FALSE


/obj/item/proc/wash(mob/user, atom/source)
	if(flags & ABSTRACT) // Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return
	to_chat(user, "<span class='notice'>You start washing [src]...</span>")
	if(!do_after(user, 40, target = source))
		return
	clean_blood()
	acid_level = 0
	user.visible_message("<span class='notice'>[user] washes [src] using [source].</span>", \
						"<span class='notice'>You wash [src] using [source].</span>")
	return TRUE

/obj/item/proc/get_crutch_efficiency() // Does an item prop up a human mob and allow them to stand if they are missing a leg/foot?
	return FALSE

/// Return true if you don't want regular throw handling
/obj/item/proc/override_throw(mob/user, atom/target)
	return FALSE

/obj/item/proc/is_equivalent(obj/item/I)
	return I == src

/obj/item/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return SEND_SIGNAL(src, COMSIG_ATOM_HITBY, AM, skipcatch, hitpush, blocked, throwingdatum)

/obj/item/attack_hulk(mob/living/carbon/human/user)
	return FALSE

/obj/item/attack_animal(mob/living/simple_animal/M)
	if(can_be_hit)
		return ..()
	return FALSE

/obj/item/mech_melee_attack(obj/mecha/M)
	return FALSE

/obj/item/proc/openTip(location, control, params, user)
	openToolTip(user, src, params, title = name, content = "[desc]", theme = "")

/obj/item/MouseEntered(location, control, params)
	. = ..()
	if(in_inventory || in_storage)
		var/mob/user = usr
		if(!(user.client.prefs.toggles2 & PREFTOGGLE_2_HIDE_ITEM_TOOLTIPS))
			tip_timer = addtimer(CALLBACK(src, PROC_REF(openTip), location, control, params, user), 8, TIMER_STOPPABLE)
		if(QDELETED(src))
			return
		if(!(user.client.prefs.toggles2 & PREFTOGGLE_2_SEE_ITEM_OUTLINES))
			return
		var/mob/living/L = user
		if(istype(L) && HAS_TRAIT(L, TRAIT_HANDS_BLOCKED))
			apply_outline(L, COLOR_RED_GRAY) // if they're dead or handcuffed, let's show the outline as red to indicate that they can't interact with that right now
		else
			apply_outline(L) // if the player's alive and well we send the command with no color set, so it uses the theme's color

/obj/item/MouseExited()
	deltimer(tip_timer) // delete any in-progress timer if the mouse is moved off the item before it finishes
	closeToolTip(usr)
	remove_outline()
	return ..()

/obj/item/MouseDrop_T(obj/item/I, mob/user)
	if(!user || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || src == I || !isliving(user))
		return

	if(loc && I.loc == loc && isstorage(loc) && loc.Adjacent(user)) // Are we trying to swap two items in the storage?
		var/obj/item/storage/S = loc
		S.swap_items(src, I, user)
		remove_outline()
		return TRUE
	remove_outline() // get rid of the hover effect in case the mouse exit isn't called if someone drags and drops an item and somthing goes wrong

/obj/item/proc/apply_outline(mob/user, outline_color = null)
	if(!(in_inventory || in_storage) || QDELETED(src) || isobserver(user)) // cancel if the item isn't in an inventory, is being deleted, or if the person hovering is a ghost (so that people spectating you don't randomly make your items glow)
		return
	var/theme = lowertext(user.client.prefs.UI_style)
	if(!outline_color) // if we weren't provided with a color, take the theme's color
		switch(theme) // yeah it kinda has to be this way
			if("midnight")
				outline_color = COLOR_THEME_MIDNIGHT
			if("plasmafire")
				outline_color = COLOR_THEME_PLASMAFIRE
			if("retro")
				outline_color = COLOR_THEME_RETRO // just as garish as the rest of this theme
			if("slimecore")
				outline_color = COLOR_THEME_SLIMECORE
			if("operative")
				outline_color = COLOR_THEME_OPERATIVE
			if("clockwork")
				outline_color = COLOR_THEME_CLOCKWORK // if you want free gbp go fix the fact that clockwork's tooltip css is glass'
			if("glass")
				outline_color = COLOR_THEME_GLASS
			else // this should never happen, hopefully
				outline_color = COLOR_WHITE
	if(color)
		outline_color = COLOR_WHITE // if the item is recolored then the outline will be too, let's make the outline white so it becomes the same color instead of some ugly mix of the theme and the tint
	if(outline_filter)
		filters -= outline_filter
	outline_filter = filter(type = "outline", size = 1, color = outline_color)
	filters += outline_filter

/obj/item/proc/remove_outline()
	if(outline_filter)
		filters -= outline_filter
		outline_filter = null

/// Returns a numeric value for sorting items used as parts in machines, so they can be replaced by the B/RPED
/obj/item/proc/get_part_rating()
	return 0

/obj/item/proc/update_slot_icon()
	if(!ismob(loc))
		return
	var/mob/owner = loc
	var/flags = slot_flags
	if(flags & ITEM_SLOT_OUTER_SUIT)
		owner.update_inv_wear_suit()
	if(flags & ITEM_SLOT_JUMPSUIT)
		owner.update_inv_w_uniform()
	if(flags & ITEM_SLOT_GLOVES)
		owner.update_inv_gloves()
	if(flags & ITEM_SLOT_EYES)
		owner.update_inv_glasses()
	if(flags & ITEM_SLOT_BOTH_EARS)
		owner.update_inv_ears()
	if(flags & ITEM_SLOT_MASK)
		owner.update_inv_wear_mask()
	if(flags & ITEM_SLOT_NECK)
		owner.update_inv_neck()
	if(flags & ITEM_SLOT_HEAD)
		owner.update_inv_head()
	if(flags & ITEM_SLOT_SHOES)
		owner.update_inv_shoes()
	if(flags & ITEM_SLOT_ID)
		owner.update_inv_wear_id()
	if(flags & ITEM_SLOT_BELT)
		owner.update_inv_belt()
	if(flags & ITEM_SLOT_BACK)
		owner.update_inv_back()
	if(flags & ITEM_SLOT_PDA)
		owner.update_inv_wear_pda()

/// Called on cyborg items that need special charging behavior. Override as needed for specific items.
/obj/item/proc/cyborg_recharge(coeff = 1, emagged = FALSE)
	return

// Access and Job stuff

/// Used in secHUD icon generation
/obj/item/proc/get_job_name()
	var/assignmentName = get_ID_assignment(if_no_id = "Unknown")
	var/rankName = get_ID_rank(if_no_id = "Unknown")

	var/job_icons = get_all_job_icons()
	var/centcom = get_all_centcom_jobs()
	var/solgov = get_all_solgov_jobs()
	var/soviet = get_all_soviet_jobs()
	var/special = get_all_special_jobs()

	// Return with the NT logo if it is a Centcom job
	if((assignmentName in centcom) || (rankName in centcom))
		return "centcom"

	// Return with the SolGov logo if it is a SolGov job
	if((assignmentName in solgov) || (rankName in solgov))
		return "solgov"

	// Return with the U.S.S.P logo if it is a Soviet job
	if((assignmentName in soviet) || (rankName in soviet))
		return "soviet"

	// For roles that can't be assigned to any category and require custom icon
	if(assignmentName in special)
		return assignmentName

	if(rankName in special)
		return rankName

	// Check if the job has a hud icon
	if(assignmentName in job_icons)
		return assignmentName

	if(rankName in job_icons)
		return rankName

	// Return unknown hud if none of the above apply
	return "unknown"

/obj/item/proc/get_ID_assignment(if_no_id = "No id")
	var/obj/item/card/id/id = GetID()
	if(istype(id)) // Make sure its actually an ID
		return id.assignment
	return if_no_id

/obj/item/proc/get_ID_rank(if_no_id = "No id")
	var/obj/item/card/id/id = GetID()
	if(istype(id)) // Make sure its actually an ID
		return id.rank
	return if_no_id

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

/obj/item/proc/add_tape()
	return

/obj/item/proc/remove_tape()
	return

/obj/item/water_act(volume, temperature, source, method)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_OIL_SLICKED))
		slowdown = initial(slowdown)
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
		REMOVE_TRAIT(src, TRAIT_OIL_SLICKED, "potion")
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.regenerate_icons()

/obj/item/cleaning_act(mob/user, atom/cleaner, cleanspeed, text_verb, text_description, text_targetname)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_OIL_SLICKED))
		slowdown = initial(slowdown)
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
		REMOVE_TRAIT(src, TRAIT_OIL_SLICKED, "potion")
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.regenerate_icons()

/obj/item/proc/get_heat()
	return

/obj/item/proc/run_pointed_on_item(mob/pointer_mob, atom/target_atom)
	if(!HAS_TRAIT(src, TRAIT_CAN_POINT_WITH) || target_atom == src)
		return FALSE

	var/pointed_object = "\the [target_atom]"
	if(target_atom.loc in pointer_mob)
		pointed_object += " inside [target_atom.loc]"

	if(pointer_mob.a_intent == INTENT_HELP || !ismob(target_atom))
		pointer_mob.visible_message("<b>[pointer_mob]</b> points to [pointed_object] with [src].")
		return TRUE

	target_atom.visible_message("<span class='danger'>[pointer_mob] points [src] at [pointed_object]!</span>",
									"<span class='userdanger'>[pointer_mob] points [src] at you!</span>")
	SEND_SOUND(target_atom, sound('sound/weapons/targeton.ogg'))
	return TRUE

/obj/item/proc/canStrip(mob/stripper, mob/owner)
	SHOULD_BE_PURE(TRUE)
	return !(flags & NODROP) && !(flags & ABSTRACT) && !HAS_TRAIT(src, TRAIT_NO_STRIP)

/obj/item/proc/should_stack_with(obj/item/other)
	return type == other.type && name == other.name

/obj/item/proc/update_action_buttons(update_flags = ALL, force = FALSE)
	for(var/datum/action/current_action as anything in actions)
		current_action.build_all_button_icons(update_flags, force)

/**
  * Handles the bulk of cigarette lighting interactions. You must call `light()` to actually light the cigarette.
  *
  * Returns: the target's cigarette (or the cigarette itself if attacked directly) if all checks are passed.
  * If the cigarette is already lit, or is a fancy smokable being lit by anything other than a zippo or match, will return `FALSE`.
  * Otherwise it will return `null`.
  * Arguments:
  * * user - The mob trying to light the cigarette.
  * * target - The mob with the cigarette.
  * * direct_attackby_item - Used if the cigarette item is clicked on directly with a lighter instead of a mob wearing a cigarette.
  */
/obj/item/proc/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	if(!user || !target)
		return null

	var/obj/item/clothing/mask/cigarette/cig = direct_attackby_item ? direct_attackby_item : target.wear_mask
	if(!istype(cig))
		return null

	if(!direct_attackby_item && (user.zone_selected != "mouth" || user.a_intent != INTENT_HELP))
		return null

	if(cig.lit)
		to_chat(user, "<span class='warning'>[cig] is already lit!</span>")
		return FALSE

	// Only matches and cigars can light fancy smokables.
	if(length(cig.fancy_lighters) && !is_type_in_list(src, cig.fancy_lighters))
		to_chat(user, "<span class='danger'>[cig] straight out REFUSES to be lit by such uncivilized means!</span>")
		return FALSE

	return cig

/// Changes the speech verb when wearing this item if a value is returned
/obj/item/proc/change_speech_verb()
	return

/obj/item/proc/set_nodrop(set_value, user)
	switch(set_value)
		if(TRUE)
			flags |= NODROP
		if(FALSE)
			flags &= ~NODROP
		if(NODROP_TOGGLE)
			flags ^= NODROP
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.update_hands_hud()

/obj/item/proc/on_hands_swap(mob/user, in_active_hand)
	return
