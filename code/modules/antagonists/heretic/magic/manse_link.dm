/datum/spell/pointed/manse_link
	name = "Manse Link"
	desc = "This spell allows you to pierce through reality and connect minds to one another \
		via your Mansus Link. All minds connected to your Mansus Link will be able to communicate discreetly across great distances."

	overlay_icon_state = "bg_heretic_border"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	is_a_heretic_spell = TRUE
	base_cooldown = 20 SECONDS

	invocation = "PI'RC' TH' M'ND."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	cast_range = 7

	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS

/datum/spell/pointed/manse_link/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/spell/pointed/manse_link/valid_target(target, user)
	. = ..()
	if(!.)
		return FALSE

	return isliving(cast_on)

/datum/spell/pointed/manse_link/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	// If we fail to link, cancel the spell.
	if(!do_linking(cast_on))
		return . | SPELL_CANCEL_CAST

/**
 * The actual process of linking [linkee] to our network.
 */
/datum/spell/pointed/manse_link/proc/do_linking(mob/living/linkee)
	var/datum/component/mind_linker/linker = target
	if(linkee.stat == DEAD)
		to_chat(owner, "<span class='warning'>They're dead!</span>")
		return FALSE

	to_chat(owner, "<span class='notice'>You begin linking [linkee]'s mind to yours...</span>")
	to_chat(linkee, "<span class='warning'>You feel your mind being pulled somewhere... connected... intertwined with the very fabric of reality...</span>")

	if(!do_after(owner, link_time, linkee, hidden = TRUE))
		to_chat(owner, "<span class='warning'>You fail to link to [linkee]'s mind.</span>")
		to_chat(linkee, "<span class='warning'>The foreign presence leaves your mind.</span>")
		return FALSE

	if(QDELETED(src) || QDELETED(owner) || QDELETED(linkee))
		return FALSE

	if(!linker.link_mob(linkee))
		to_chat(owner, "<span class='warning'>You can't seem to link to [linkee]'s mind.</span>")
		to_chat(linkee, "<span class='warning'>The foreign presence leaves your mind.</span>")
		return FALSE

	return TRUE
