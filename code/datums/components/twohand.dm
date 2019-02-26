/obj/item/proc/is_twohandable() // Returns TRUE if an object has a two-handing component. FALSE otherwise.
	if(GetComponent(/datum/component/twohand))
		return TRUE

/obj/item/proc/is_twohanded() // Returns TRUE if an item is wielded with two hands. FALSE otherwise.
	var/datum/component/twohand/T = GetComponent(/datum/component/twohand)
	if(istype(T))
		return T.wielded


/*
 * Component for twohanding an /obj/item.
 * Default behavior is to toggle wielding with attack_self, however this can be overridden by changing the toggle_wield_signal in the Initialize call.
 */
/datum/component/twohand
	var/wielded
	var/obj/item/container
	var/force_mod
	var/require_wield
	var/wield_sound
	var/unwield_sound
	var/icon_state_suffix = "_wielded"
	var/item_state_suffix
	var/examine_hint = "looks like it could be two-handed by <b>activating it in your hand</b>"
	dupe_mode = COMPONENT_DUPE_UNIQUE // Each object should only have one twohand component.

/datum/component/twohand/Initialize(_force_mod, _require_wield, _wield_sound, _unwield_sound, icon_state_suffix_override, 
									item_state_suffix_override, examine_hint_override, toggle_wield_signal = COMSIG_ITEM_ATTACK_SELF)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	if(examine_hint_override)
		examine_hint = examine_hint_override
	container = parent
	force_mod = _force_mod
	require_wield = _require_wield
	if(require_wield)
		RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/on_pickup)
	else if(toggle_wield_signal) // Only allow us to toggle the two-handing if the two-handing isn't required.
		RegisterSignal(parent, toggle_wield_signal, .proc/toggle_wield)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/unwield)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	
	

/datum/component/twohand/proc/on_examine(datum/source, mob/user)
	if(wielded && (user.l_hand == container || user.r_hand == container))
		to_chat(user, "<span class='notice'>You have [container] gripped in two hands.</span>")
		return
	to_chat(user, "<span class='notice'>[container] [examine_hint].</span>")

/datum/component/twohanded/proc/parent_in_user_hands(mob/living/carbon/human/user)
	if(user.l_hand == container || user.r_hand == container)
		return TRUE

/datum/component/twohand/proc/toggle_wield(datum/source, mob/user)
	if(wielded)
		return unwield(source, user)
	return wield(source, user)

/datum/component/twohand/proc/wield(datum/source, mob/user)
	if(wielded)
		return
	if(!ishuman(user))
		return
	/mob/living/carbon/human/H = user
	if(!container.Adjacent(H) || !parent_in_user_hands(H))
		return
	if(H.dna.species.is_small)
		to_chat(user, "<span class='warning'>It's too heavy for you to wield fully.</span>")
		return
	if(force_mod)
		container.force += force_mod
	if(wield_sound)
		playsound(loc, wield_sound, 50, 1)
	if(icon_state_suffix)
		container.icon_state = "[container.icon_state][icon_state_suffix]"
	if(item_state_suffix)
		container.item_state = "[container.item_state][item_state_suffix]"
	update_icon()
	H.update_inv_r_hand()
	H.update_inv_l_hand()

/datum/component/twohand/proc/unwield(datum/source, mob/user)
	if(wielded)
		return
	if(!ishuman(user))
		return
	/mob/living/carbon/human/H = user
	if(!container.Adjacent(H) || !parent_in_user_hands(H))
		return
	if(force_mod)
		container.force -= force_mod
	if(unwield_sound)
		playsound(loc, unwield_sound, 50, 1)
	if(icon_state_suffix)
		container.icon_state = "[container.icon_state.initial()]"
	if(item_state_suffix)
		container.item_state = "[container.item_state.initial()]"
	update_icon()
	H.update_inv_r_hand()
	H.update_inv_l_hand()