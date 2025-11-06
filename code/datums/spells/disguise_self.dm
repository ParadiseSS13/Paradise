/datum/spell/disguise_self
	name = "Disguise Self"
	desc = "Disguise yourself as a crewmember, based on your current location. Also changes your voice. Takes two seconds to cast, must stand still. \
		The illusion isn't strong enough for more thorough examinations, but will fool people at a glance. \
		You will lose control over the illusion if you're attacked, shoved, or a object is thrown at you, no matter how soft."

	base_cooldown = 3 SECONDS
	clothes_req = FALSE
	level_max = 0 //cannot be improved
	action_icon_state = "disguise_self"
	sound = null

/datum/spell/disguise_self/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/disguise_self/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user

	H.emote("spin")
	to_chat(H, "<span class='notice'>You start spinning in place and casting [src]...</span>")
	if(do_after(H, 2 SECONDS, FALSE, H))
		finish_disguise(H)
		return TRUE
	else
		H.slip("your own foot", 1 SECONDS, 0, 0, 1, "trip")
		to_chat(H, "<span class='danger'>You must stand still to cast [src]!</span>")
		return FALSE

/datum/spell/disguise_self/proc/finish_disguise(mob/living/carbon/human/H)
	H.apply_status_effect(STATUS_EFFECT_MAGIC_DISGUISE)
	var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread
	smoke.set_up(4, FALSE, H.loc)
	smoke.start()
