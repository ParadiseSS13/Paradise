/**
 * A technical component which allows datums to register to other datums their QDELETION.
 * Created so that, for instance, a human can listen to the same object twice to handle different things.
 * Since you can only subscribe to a target once given a specific signal.
 */

/datum/component/qdeleting
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Who are we listening to?
	var/datum/target
	/// What do we call when the target gets destroyed?
	var/datum/callback/callback
	/// What signal causes us to qdel?
	var/delete_signal

/datum/component/qdeleting/Initialize(datum/target, datum/callback/callback, delete_signal)
	if(!istype(target) || !istype(callback))
		return COMPONENT_INCOMPATIBLE
	src.callback = callback
	src.target = target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/do_callback)
	if(delete_signal)
		RegisterSignal(parent, delete_signal, .proc/delete_comp)
		src.delete_signal = delete_signal

/datum/component/qdeleting/Destroy(force, silent)
	target = null
	callback = null
	return ..()

/datum/component/qdeleting/proc/delete_comp()
	qdel(src)

/datum/component/qdeleting/proc/do_callback()
	callback.InvokeAsync(target)
	qdel(src)

/datum/component/qdeleting/UnregisterFromParent()
	UnregisterSignal(parent, delete_signal)
	if(delete_signal)
		UnregisterSignal(parent, delete_signal)
