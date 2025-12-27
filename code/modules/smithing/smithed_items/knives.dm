/obj/item/kitchen/knife/smithed
	name = "debug smithed knife"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/obj/smithing.dmi'
	icon_state = "debug"
	slot_flags = ITEM_SLOT_BELT
	embedded_ignore_throwspeed_threshold = TRUE

	new_attack_chain = TRUE
	/// The quality of the item
	var/datum/smith_quality/quality
	/// The material of the item
	var/datum/smith_material/material
	/// Base Speed modifier
	var/base_speed_mod = 0
	/// Speed modifier
	var/speed_mod = 1.0
	/// Base productivity modifier
	var/base_productivity_mod = 0
	/// Productivity mod
	var/productivity_mod = 1.0
	/// damage increase
	var/force_increase = 0
	/// throw damage increase
	var/throw_force_increase = 0
	/// throw embed chance increase
	var/embed_chance_increase = 0
	/// Handle wrappings
	var/datum/handle_wrapping/wrap_type

/obj/item/kitchen/knife/smithed/Initialize(mapload)
	. = ..()
	set_name()

/obj/item/kitchen/knife/smithed/proc/set_name()
	if(!quality)
		return
	if(!material)
		name = "[quality.name] " + name
		return
	name = "[quality.name] [material.name] [initial(name)]"

/obj/item/kitchen/knife/smithed/proc/set_stats()
	speed_mod = 1 + (base_speed_mod * quality.stat_mult * material.tool_speed_mult)
	productivity_mod = 1 + (base_productivity_mod * quality.stat_mult * material.tool_productivity_mult)
	force_increase = initial(force_increase) * quality.stat_mult * material.force_mult
	throw_force_increase = initial(throw_force_increase) * quality.stat_mult * material.throw_force_mult
	embed_chance_increase = initial(embed_chance_increase) * quality.stat_mult * material.embed_chance_mult
	// Now we adjust the item's actual stats
	force = initial(force) + force_increase
	throwforce = initial(throwforce) + throw_force_increase
	embed_chance = initial(embed_chance) + embed_chance_increase
	// We adjust bit productivity and similar stats here because they are one and the same
	bit_productivity_mod = initial(bit_productivity_mod) * productivity_mod
	toolspeed = initial(toolspeed) * speed_mod

	// Color
	color = material.color_tint
	// Radioactive baby
	if((material == /datum/smith_material/uranium || istype(material, /datum/smith_material/uranium)) && quality)
		var/datum/component/inherent_radioactivity/radioactivity = AddComponent(/datum/component/inherent_radioactivity, 100 * quality.stat_mult, 0, 0, 1.5)
		START_PROCESSING(SSradiation, radioactivity)

/obj/item/kitchen/knife/smithed/update_overlays()
	. = ..()
	overlays.Cut()
	if(!wrap_type)
		. += "basic_wrap"
		return
	. += wrap_type.wrap_overlay

/obj/item/kitchen/knife/smithed/update_name()
	. = ..()
	set_name()

/obj/item/kitchen/knife/smithed/proc/attach_wrapping(datum/handle_wrapping/wrap)
	force += wrap.force_increase
	throwforce += wrap.throw_force_increase
	toolspeed += wrap.speed_mod
	bit_productivity_mod += wrap.productivity_mod
	embed_chance += wrap.embed_chance_increase
	wrap_type = wrap
	update_icon(UPDATE_OVERLAYS)

/obj/item/kitchen/knife/smithed/proc/remove_wrapping()
	force -= wrap_type.force_increase
	throwforce -= wrap_type.throw_force_increase
	toolspeed -= wrap_type.speed_mod
	bit_productivity_mod -= wrap_type.productivity_mod
	embed_chance -= wrap_type.embed_chance_increase
	wrap_type = null
	update_icon(UPDATE_OVERLAYS)

/obj/item/kitchen/knife/smithed/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!isstack(used))
		return ..()
	var/obj/item/stack/stacked_item = used
	if(wrap_type)
		to_chat(user, SPAN_WARNING("There is already a wrap on [src]!"))
		return ITEM_INTERACT_COMPLETE
	var/wrap_to_attach
	if(istype(stacked_item, /obj/item/stack/cable_coil))
		wrap_to_attach = /datum/handle_wrapping/cable
	if(istype(stacked_item, /obj/item/stack/sheet/cloth))
		wrap_to_attach = /datum/handle_wrapping/cloth
	if(istype(stacked_item, /obj/item/stack/sheet/durathread))
		wrap_to_attach = /datum/handle_wrapping/durathread
	if(istype(stacked_item, /obj/item/stack/sheet/leather))
		wrap_to_attach = /datum/handle_wrapping/leather
	if(istype(stacked_item, /obj/item/stack/sheet/animalhide/goliath_hide))
		wrap_to_attach = /datum/handle_wrapping/goliath_hide
	if(istype(stacked_item, /obj/item/stack/sheet/mothsilk))
		wrap_to_attach = /datum/handle_wrapping/mothsilk
	if(!wrap_to_attach)
		to_chat(user, SPAN_WARNING("You cannot wrap [stacked_item] around [src]!"))
		return ..()
	if(do_after_once(user, 5 SECONDS, target = src))
		if(stacked_item.use(5))
			attach_wrapping(wrap_to_attach)
			return ITEM_INTERACT_COMPLETE

/obj/item/kitchen/knife/smithed/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(wrap_type)
		to_chat(user, SPAN_NOTICE("You cut off the wrap on [src]."))
		remove_wrapping()

/obj/item/kitchen/knife/smithed/utility
	name = "utility knife"
	desc = "A custom-made knife designed for general purpose use."
	icon_state = "utility_knife"
	base_speed_mod = 0.25
	base_productivity_mod = 0.25

/obj/item/kitchen/knife/smithed/thrown
	name = "throwing knife"
	desc = "A lightweight, balanced throwing knife. The sharp blade enhances the chance to embed."
	icon_state = "throwing_knife"
	throw_speed = 4
	base_speed_mod = -0.25
	base_productivity_mod = -0.25
	throw_force_increase = 6 // 16 throw force at standard, 22 throw force at masterwork
	embed_chance_increase = 25 // +25% chance to embed at standard, +50% at masterwork

/obj/item/kitchen/knife/smithed/combat
	name = "combat knife"
	desc = "A heavyweight, toothed-edge combat knife. The thick blade is designed to rip and tear, and it has an integrated bayonet mount."
	icon_state = "combat_knife"
	base_productivity_mod = -0.25
	force_increase = 6 // 16 force at standard, 22 force at masterwork
	embed_chance_increase = 5
	bayonet = TRUE
