var/global/image/fire_overlay = image("icon" = 'icons/goonstation/effects/fire.dmi', "icon_state" = "fire")

/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/discrete = 0 // used in item_attack.dm to make an item not show an attack message to viewers
	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/blood_overlay_color = null
	var/item_state = null
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	//Dimensions of the lefthand_file and righthand_file vars
	//eg: 32x32 sprite, 64x64 sprite, etc.
	var/inhand_x_dimension = 32
	var/inhand_y_dimension = 32

	max_integrity = 200

	can_be_hit = FALSE
	suicidal_hands = TRUE

	var/hitsound = null
	var/usesound = null
	var/throwhitsound
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
	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/item_color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/armour_penetration = 0 //percentage of armour effectiveness to remove
	var/list/allowed = null //suit storage stuff.
	var/obj/item/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.

	var/needs_permit = 0			//Used by security bots to determine if this item is safe for public use.

	var/strip_delay = DEFAULT_ITEM_STRIP_DELAY
	var/put_on_delay = DEFAULT_ITEM_PUTON_DELAY
	var/breakouttime = 0
	var/flags_cover = 0 //for flags such as GLASSESCOVERSEYES
	var/flags_size = 0 //flag, primarily used for clothing to determine if a fatty can wear something or not.

	var/block_chance = 0
	var/hit_reaction_chance = 0 //If you want to have something unrelated to blocking/armour piercing etc. Maybe not needed, but trying to think ahead/allow more freedom

	// Needs to be in /obj/item because corgis can wear a lot of
	// non-clothing items
	var/datum/dog_fashion/dog_fashion = null

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

	var/trip_verb = TV_TRIP
	var/trip_chance = 0

	var/trip_stun = 0
	var/trip_weaken = 0
	var/trip_any = FALSE
	var/trip_walksafe = TRUE
	var/trip_tiles = 0

	//Tooltip vars
	var/in_inventory = FALSE //is this item equipped into an inventory slot or hand of a mob?
	var/tip_timer = 0

/obj/item/New()
	..()
	for(var/path in actions_types)
		new path(src, action_icon[path], action_icon_state[path])

	if(!hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"

/obj/item/Destroy()
	flags &= ~DROPDEL	//prevent reqdels
	QDEL_NULL(hidden_uplink)
	if(ismob(loc))
		var/mob/m = loc
		m.unEquip(src, 1)
	QDEL_LIST(actions)
	master = null
	return ..()

/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || ((!istype(target.loc, /turf)) && (!istype(target, /turf)) && (not_inside)))
		return 0
	else
		return 1

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

	. = ..(user, "", "It is a [size] item.")

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

/obj/item/attack_hand(mob/user as mob, pickupfireoverride = FALSE)
	if(!user) return 0
	if(hasorgans(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(user.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(!temp)
			to_chat(user, "<span class='warning'>You try to use your hand, but it's missing!</span>")
			return 0
		if(temp && !temp.is_usable())
			to_chat(user, "<span class='warning'>You try to move your [temp.name], but cannot!</span>")
			return 0

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
				if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
					H.UpdateDamageIcon()

	if(istype(src.loc, /obj/item/storage))
		//If the item is in a storage item, take it out
		var/obj/item/storage/S = src.loc
		S.remove_from_storage(src)

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!user.unEquip(src))
			return 0

	else
		if(isliving(loc))
			return 0
	add_fingerprint(user)
	if(pickup(user)) // Pickup succeeded
		user.put_in_active_hand(src)

	return 1

/obj/item/attack_alien(mob/user)
	var/mob/living/carbon/alien/A = user

	if(!A.has_fine_manipulation)
		if(src in A.contents) // To stop Aliens having items stuck in their pockets
			A.unEquip(src)
		to_chat(user, "<span class='warning'>Your claws aren't capable of such fine manipulation!</span>")
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
			if(S.collection_mode) //Mode is set to collect all items on a tile and we clicked on a valid one.
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
						S.handle_item_insertion(IT, 1)	//The 1 stops the "You put the [src] into [S]" insertion message from being displayed.
					if(success && !failure)
						to_chat(user, "<span class='notice'>You put everything in [S].</span>")
					else if(success)
						to_chat(user, "<span class='notice'>You put some things in [S].</span>")
					else
						to_chat(user, "<span class='notice'>You fail to pick anything up with [S].</span>")

			else if(S.can_be_inserted(src))
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

/obj/item/proc/dropped(mob/user)
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(user)
	if(flags & DROPDEL)
		qdel(src)
	if((flags & NODROP) && !(initial(flags) & NODROP)) //Remove NODROP is dropped
		flags &= ~NODROP
	in_inventory = FALSE
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED,user)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)
	in_inventory = TRUE
	return TRUE

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/storage/S as obj)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/storage/S as obj)
	return

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
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(slot, user)) //some items only give their actions buttons when in a specific slot.
			A.Grant(user)
	in_inventory = TRUE

/obj/item/proc/item_action_slot_check(slot, mob/user)
	return 1

//returns 1 if the item is equipped by a mob, 0 otherwise.
//This might need some error trapping, not sure if get_equipped_items() is safe for non-human mobs.
/obj/item/proc/is_equipped()
	if(!ismob(loc))
		return 0

	var/mob/M = loc
	if(src in M.get_equipped_items())
		return 1
	else
		return 0

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = 0)
	if(!M)
		return 0

	return M.can_equip(src, slot, disable_warning)

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


//This proc is executed when someone clicks the on-screen UI button.
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/user, actiontype)
	attack_self(user)

/obj/item/proc/IsReflect(var/def_zone) //This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
	return 0

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

	add_attack_logs(user, M, "Eye-stabbed with [src] (INTENT: [uppertext(user.a_intent)])")

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
					M.drop_item()
				M.AdjustEyeBlurry(10)
				M.Paralyse(1)
				M.Weaken(2)
			if(eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, "<span class='danger'>You go blind!</span>")
		var/obj/item/organ/external/affecting = H.get_organ("head")
		if(affecting.receive_damage(7))
			H.UpdateDamageIcon()
	else
		M.take_organ_damage(7)
	M.AdjustEyeBlurry(rand(3,4))
	return

/obj/item/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FOUR)
		throw_at(S, 14, 3, spin = 0)
	else
		return

/obj/item/throw_impact(atom/A)
	if(A && !QDELETED(A))
		SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, A)
		var/itempush = 1
		if(w_class < WEIGHT_CLASS_BULKY)
			itempush = 0 // too light to push anything
		return A.hitby(src, 0, itempush)

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force)
	thrownby = thrower
	callback = CALLBACK(src, .proc/after_throw, callback) //replace their callback with our own
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback, force)

/obj/item/proc/after_throw(datum/callback/callback)
	if(callback) //call the original callback
		. = callback.Invoke()
	throw_speed = initial(throw_speed) //explosions change this.
	in_inventory = FALSE

/obj/item/proc/pwr_drain()
	return 0 // Process Kill

/obj/item/proc/remove_item_from_storage(atom/newLoc) //please use this if you're going to snowflake an item out of a obj/item/storage
	if(!newLoc)
		return 0
	if(istype(loc,/obj/item/storage))
		var/obj/item/storage/S = loc
		S.remove_from_storage(src,newLoc)
		return 1
	return 0


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
	return 1

/obj/item/proc/is_crutch() //Does an item prop up a human mob and allow them to stand if they are missing a leg/foot?
	return 0

// Return true if you don't want regular throw handling
/obj/item/proc/override_throw(mob/user, atom/target)
	return FALSE

/obj/item/proc/is_equivalent(obj/item/I)
	return I == src

/obj/item/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(prob(trip_chance) && ishuman(AM))
		var/mob/living/carbon/human/H = AM
		on_trip(H)

/obj/item/proc/on_trip(mob/living/carbon/human/H)
	if(H.slip(src, trip_stun, trip_weaken, trip_tiles, trip_walksafe, trip_any, trip_verb))
		return TRUE

/obj/item/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return

/obj/item/attack_hulk(mob/living/carbon/human/user)
	return FALSE

/obj/item/attack_animal(mob/living/simple_animal/M)
	if(can_be_hit)
		return ..()
	return FALSE

/obj/item/mech_melee_attack(obj/mecha/M)
	return 0

/obj/item/proc/openTip(location, control, params, user)
	openToolTip(user, src, params, title = name, content = "[desc]", theme = "")

/obj/item/MouseEntered(location, control, params)
	if(in_inventory)
		var/timedelay = 8
		var/user = usr
		tip_timer = addtimer(CALLBACK(src, .proc/openTip, location, control, params, user), timedelay, TIMER_STOPPABLE)

/obj/item/MouseExited()
	deltimer(tip_timer) //delete any in-progress timer if the mouse is moved off the item before it finishes
	closeToolTip(usr)

// Returns a numeric value for sorting items used as parts in machines, so they can be replaced by the rped
/obj/item/proc/get_part_rating()
	return 0

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

