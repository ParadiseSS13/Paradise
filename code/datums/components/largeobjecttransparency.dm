///Makes large icons partially see through if high priority atoms are behind them.
/datum/component/largetransparency
	//Can be positive or negative. Determines how far away from parent the first registered turf is.
	var/x_offset
	var/y_offset
	//Has to be positive or 0.
	var/x_size
	var/y_size
	//The alpha values this switches in between.
	var/initial_alpha
	var/target_alpha
	//if this is supposed to prevent clicks if it's transparent.
	var/toggle_click
	//The atom's mouse opacity, so it's restored to its default
	var/initial_mouse_opacity
	var/list/registered_turfs
	var/amounthidden = 0

/datum/component/largetransparency/Initialize(_x_offset = 0, _y_offset = 1, _x_size = 0, _y_size = 1, _initial_alpha = null, _target_alpha = 140, _toggle_click = TRUE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	x_offset = _x_offset
	y_offset = _y_offset
	x_size = _x_size
	y_size = _y_size
	var/atom/at = parent
	if(isnull(_initial_alpha))
		initial_alpha = at.alpha
	else
		initial_alpha = _initial_alpha
	target_alpha = _target_alpha
	toggle_click = _toggle_click
	initial_mouse_opacity = at.mouse_opacity
	registered_turfs = list()


/datum/component/largetransparency/Destroy()
	registered_turfs.Cut()
	return ..()

/datum/component/largetransparency/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(OnMove))
	RegisterWithTurfs()

/datum/component/largetransparency/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterFromTurfs()

/datum/component/largetransparency/proc/RegisterWithTurfs()
	var/turf/current_turf = get_turf(parent)
	if(!current_turf)
		return
	var/turf/lowleft_turf = locate(clamp(current_turf.x + x_offset, 0, world.maxx), clamp(current_turf.y + y_offset, 0, world.maxy), current_turf.z)
	var/turf/upright_turf = locate(min(lowleft_turf.x + x_size, world.maxx), min(lowleft_turf.y + y_size, world.maxy), current_turf.z)
	registered_turfs = block(lowleft_turf, upright_turf) //small problems with z level edges due to object size offsets, but nothing truly problematic.
	//register the signals
	for(var/registered_turf in registered_turfs)
		RegisterSignal(registered_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON), PROC_REF(objectEnter))
		RegisterSignal(registered_turf, COMSIG_ATOM_EXITED, PROC_REF(objectLeave))
		RegisterSignal(registered_turf, COMSIG_TURF_CHANGE, PROC_REF(OnTurfChange))
		for(var/thing in registered_turf)
			var/atom/check_atom = thing
			if(!(check_atom.flags_2 & CRITICAL_ATOM_2))
				continue
			amounthidden++
	if(amounthidden)
		reduceAlpha()

/datum/component/largetransparency/proc/UnregisterFromTurfs()
	var/list/signal_list = list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_TURF_CHANGE, COMSIG_ATOM_INITIALIZED_ON)
	for(var/registered_turf in registered_turfs)
		UnregisterSignal(registered_turf, signal_list)
	registered_turfs.Cut()

/datum/component/largetransparency/proc/OnMove()
	amounthidden = 0
	restoreAlpha()
	UnregisterFromTurfs()
	RegisterWithTurfs()

/datum/component/largetransparency/proc/OnTurfChange()
	addtimer(CALLBACK(src, PROC_REF(OnMove)), 0, TIMER_UNIQUE|TIMER_OVERRIDE) //*pain

/datum/component/largetransparency/proc/objectEnter(datum/source, atom/enterer)
	if(!(enterer.flags_2 & CRITICAL_ATOM_2))
		return
	if(!amounthidden)
		reduceAlpha()
	amounthidden++

/datum/component/largetransparency/proc/objectLeave(datum/source, atom/leaver)
	if(!(leaver.flags_2 & CRITICAL_ATOM_2))
		return
	amounthidden = max(0, amounthidden - 1)
	if(!amounthidden)
		restoreAlpha()

/datum/component/largetransparency/proc/reduceAlpha()
	var/atom/parent_atom = parent
	animate(parent_atom, alpha = target_alpha, 0.5 SECONDS)
	if(toggle_click)
		parent_atom.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/component/largetransparency/proc/restoreAlpha()
	var/atom/parent_atom = parent
	animate(parent_atom, alpha = initial_alpha, 0.5 SECONDS)
	if(toggle_click)
		parent_atom.mouse_opacity = initial_mouse_opacity
