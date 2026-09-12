/datum/action/cooldown/mob_cooldown/bot/sword
	name = "Energy Sword"
	desc = "Turn your sword off/on!"
	button_icon = 'icons/obj/weapons/energy_melee.dmi'
	button_icon_state = "e_sword_on"
	cooldown_time = 0 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/bot/sword/Activate(mob/living/firer, atom/target)
	var/obj/item/melee/energy/sword/saber/my_sword = locate() in owner
	INVOKE_ASYNC(my_sword, TYPE_PROC_REF(/obj/item/melee/energy/sword/saber, attack_self__legacy__attackchain), owner)
	var/mob/living/basic/bot/secbot/griefsky/super_beeps = owner
	var/active = HAS_TRAIT(my_sword, TRAIT_ITEM_ACTIVE)
	super_beeps.on_weapon_transform(src, super_beeps, active)
	return TRUE
