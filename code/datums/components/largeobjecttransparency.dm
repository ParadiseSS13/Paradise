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
	var/list/registered_turfs
	var/amounthidden = 0

/datum/component/largetransparency/Initialize(_x_offset = 0, _y_offset = 1, _x_size = 0, _y_size = 1, _initial_alpha = null, _target_alpha = 140, _toggle_click = TRUE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	x_offset = _x_offset
	y_offset = _y_offset
	x_size = _x_size
	y_size = _y_size
	if(isnull(_initial_alpha))
		var/atom/at = parent
		initial_alpha = at.alpha
	else
		initial_alpha = _initial_alpha
	target_alpha = _target_alpha
	toggle_click = _toggle_click
	registered_turfs = list()


/datum/component/largetransparency/Destroy()
	registered_turfs.Cut()
	return ..()

/datum/component/largetransparency/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/OnMove)
	RegisterWithTurfs()

/datum/component/largetransparency/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterFromTurfs()

/datum/component/largetransparency/proc/RegisterWithTurfs()
	var/turf/current_tu = get_turf(parent)
	if(!current_tu)
		return
	var/turf/lowleft_tu = locate(clamp(current_tu.x + x_offset, 0, world.maxx), clamp(current_tu.y + y_offset, 0, world.maxy), current_tu.z)
	var/turf/upright_tu = locate(min(lowleft_tu.x + x_size, world.maxx), min(lowleft_tu.y + y_size, world.maxy), current_tu.z)
	registered_turfs = block(lowleft_tu, upright_tu) //small problems with z level edges but nothing gamebreaking.
	//register the signals
	for(var/regist_tu in registered_turfs)
		if(!regist_tu)
			continue
		RegisterSignal(regist_tu, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON), .proc/objectEnter)
		RegisterSignal(regist_tu, COMSIG_ATOM_EXITED, .proc/objectLeave)
		RegisterSignal(regist_tu, COMSIG_TURF_CHANGE, .proc/OnTurfChange)
		for(var/thing in regist_tu)
			var/atom/check_atom = thing
			if(!(check_atom.flags_2 & CRITICAL_ATOM_2))
				continue
			amounthidden++
	if(amounthidden)
		reduceAlpha()

/datum/component/largetransparency/proc/UnregisterFromTurfs()
	var/list/signal_list = list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_TURF_CHANGE, COMSIG_ATOM_INITIALIZED_ON)
	for(var/regist_tu in registered_turfs)
		UnregisterSignal(regist_tu, signal_list)
	registered_turfs.Cut()

/datum/component/largetransparency/proc/OnMove()
	amounthidden = 0
	restoreAlpha()
	UnregisterFromTurfs()
	RegisterWithTurfs()

/datum/component/largetransparency/proc/OnTurfChange()
	addtimer(CALLBACK(src, .proc/OnMove), 0, TIMER_UNIQUE|TIMER_OVERRIDE) //*pain

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
	var/atom/par_atom = parent
	par_atom.alpha = target_alpha
	if(toggle_click)
		par_atom.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/component/largetransparency/proc/restoreAlpha()
	var/atom/par_atom = parent
	par_atom.alpha = initial_alpha
	if(toggle_click)
		par_atom.mouse_opacity = MOUSE_OPACITY_OPAQUE
