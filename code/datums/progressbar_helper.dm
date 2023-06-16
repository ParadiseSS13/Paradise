#define PBHELPER_INITIAL 0
#define PBHELPER_RUNNING 1
#define PBHELPER_CANCELED 2
#define PBHELPER_FAILED 3
#define PBHELPER_FINISHED 4

/// Basically just do_after but uses timers and callbacks.
/// Every callback is optional, if they're all null you just get a progressbar that ends after `delay` deciseconds.
/datum/progressbar_helper
	var/datum/progressbar/progbar
	var/progbar_timer_id = TIMER_ID_NULL
	var/state = PBHELPER_INITIAL

	var/start = 0

	var/nomove = FALSE
	var/atom/targ
	var/atom/tloc
	var/atom/uloc

	// the callback arguments don't get reset if they're not stored, for some reason
	var/datum/callback/check_cb
	var/datum/callback/finish_cb
	var/datum/callback/fail_cb
	var/datum/callback/always_cb

/// Returns FALSE if this instance is already performing an action, otherwise TRUE.
/datum/progressbar_helper/proc/start(mob/source, atom/target, delay, staystill = TRUE, datum/callback/check = null, datum/callback/onfinish = null, datum/callback/onfail = null, datum/callback/always = null)
	if(state == PBHELPER_RUNNING || !istype(source) || !istype(target))
		return FALSE

	nomove = staystill
	targ = target
	tloc = target.loc
	uloc = source.loc

	check_cb = check
	finish_cb = onfinish
	fail_cb = onfail
	always_cb = always

	progbar = new(source, delay, target)
	progbar.update(0)
	state = PBHELPER_RUNNING
	start = world.time
	// delay / 20 because progressbar.update rounds to 5%
	progbar_timer_id = addtimer(CALLBACK(src, PROC_REF(update_callback)), delay / 20, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_LOOP)
	return TRUE

/datum/progressbar_helper/proc/cleanup()
	if(state != PBHELPER_RUNNING)
		return FALSE
	deltimer(progbar_timer_id)
	progbar_timer_id = TIMER_ID_NULL
	QDEL_NULL(progbar)
	QDEL_NULL(check_cb)
	return TRUE

/datum/progressbar_helper/proc/end()
	if(state == PBHELPER_RUNNING && always_cb)
		always_cb.Invoke()
		QDEL_NULL(always_cb)

/datum/progressbar_helper/proc/cancel()
	if(state == PBHELPER_RUNNING && cleanup())
		end()
		state = PBHELPER_CANCELED

/datum/progressbar_helper/proc/has_moved()
	return (targ.loc != tloc) || (progbar.user.loc != uloc)

/datum/progressbar_helper/proc/update_callback()
	if(state != PBHELPER_RUNNING)
		return

	if(((nomove && !has_moved()) || !nomove) && ((check_cb && check_cb.Invoke()) || !check_cb))
		progbar.update(world.time - start)
		if(world.time - start >= progbar.goal)
			if(cleanup())
				if(finish_cb)
					finish_cb.Invoke()
					QDEL_NULL(finish_cb)
				end()
				state = PBHELPER_FINISHED
	else
		if(cleanup())
			if(fail_cb)
				fail_cb.Invoke()
				QDEL_NULL(fail_cb)
			end()
			state = PBHELPER_FAILED
