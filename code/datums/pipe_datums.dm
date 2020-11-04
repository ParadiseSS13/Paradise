GLOBAL_LIST_EMPTY(construction_pipe_list)	//List of all pipe datums
GLOBAL_LIST_EMPTY(rpd_pipe_list)			//Some pipes we don't want to be dispensable by the RPD, so we have a separate thing

/datum/pipes
	var/pipe_name		//What the pipe is called in the interface
	var/pipe_id			//Use the pipe define for this
	var/pipe_type		//Atmos, disposals etc.
	var/pipe_category	//What category of pipe
	var/bendy = FALSE	//Is this pipe bendy?
	var/orientations	//Number of orientations (for interface purposes)
	var/pipe_icon		//icon_state of the dispensed pipe (for interface purposes)
	var/rpd_dispensable = FALSE

/datum/pipes/atmospheric
	pipe_type = PIPETYPE_ATMOS
	pipe_category = PIPETYPE_ATMOS

/datum/pipes/disposal
	pipe_type = PIPETYPE_DISPOSAL

//Normal pipes

/datum/pipes/atmospheric/simple
	pipe_name = "straight pipe"
	pipe_id = PIPE_SIMPLE_STRAIGHT
	orientations = 2
	pipe_icon = "simple"
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/bent //Why is this not atmospheric/simple/bent you ask? Because otherwise the ordering of the pipes in the UI menu gets weird
	pipe_name = "bent pipe"
	pipe_id = PIPE_SIMPLE_BENT
	orientations = 4
	bendy = TRUE
	pipe_icon = "simple"
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/manifold
	pipe_name = "t-manifold"
	pipe_id = PIPE_MANIFOLD
	orientations = 4
	pipe_icon = "manifold"
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/manifold4w
	pipe_name = "4-way manifold"
	pipe_id = PIPE_MANIFOLD4W
	orientations = 1
	pipe_icon = "manifold4w"
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/cap
	pipe_name = "pipe cap"
	pipe_id = PIPE_CAP
	orientations = 4
	pipe_icon = "cap"
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/valve
	pipe_name = "manual valve"
	pipe_id = PIPE_MVALVE
	orientations = 2
	pipe_icon = "mvalve"
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/valve/digital
	pipe_name = "digital valve"
	pipe_id = PIPE_DVALVE
	pipe_icon = "dvalve"

/datum/pipes/atmospheric/tvalve
	pipe_name = "manual t-valve"
	pipe_id = PIPE_TVALVE
	orientations = 4
	pipe_icon = "tvalve"
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/tvalve/digital
	pipe_name = "digital t-valve"
	pipe_id = PIPE_DTVALVE
	pipe_icon = "dtvalve"

//Supply pipes

/datum/pipes/atmospheric/simple/supply
	pipe_name = "straight supply pipe"
	pipe_id = PIPE_SUPPLY_STRAIGHT
	pipe_category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/bent/supply
	pipe_name = "bent supply pipe"
	pipe_id = PIPE_SUPPLY_BENT
	pipe_category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/manifold/supply
	pipe_name = "supply T-manifold"
	pipe_id = PIPE_SUPPLY_MANIFOLD
	pipe_category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/manifold4w/supply
	pipe_name = "4-way supply manifold"
	pipe_id = PIPE_SUPPLY_MANIFOLD4W
	pipe_category = RPD_SUPPLY_PIPING

/datum/pipes/atmospheric/cap/supply
	pipe_name = "supply pipe cap"
	pipe_id = PIPE_SUPPLY_CAP
	pipe_category = RPD_SUPPLY_PIPING

//Scrubbers pipes

/datum/pipes/atmospheric/simple/scrubbers
	pipe_name = "straight scrubbers pipe"
	pipe_id = PIPE_SCRUBBERS_STRAIGHT
	pipe_category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/bent/scrubbers
	pipe_name = "bent scrubbers pipe"
	pipe_id = PIPE_SCRUBBERS_BENT
	pipe_category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/manifold/scrubbers
	pipe_name = "scrubbers t-manifold"
	pipe_id = PIPE_SCRUBBERS_MANIFOLD
	pipe_category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/manifold4w/scrubbers
	pipe_name = "4-way scrubbers manifold"
	pipe_id = PIPE_SCRUBBERS_MANIFOLD4W
	pipe_category = RPD_SCRUBBERS_PIPING

/datum/pipes/atmospheric/cap/scrubbers
	pipe_name = "scrubbers pipe cap"
	pipe_id = PIPE_SCRUBBERS_CAP
	pipe_category = RPD_SCRUBBERS_PIPING

//Devices

/datum/pipes/atmospheric/upa
	pipe_name = "universal pipe adapter"
	pipe_id = PIPE_UNIVERSAL
	orientations = 2
	pipe_icon = "universal"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/connector
	pipe_name = "connector"
	pipe_id = PIPE_CONNECTOR
	orientations = 4
	pipe_icon = "connector"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/unaryvent
	pipe_name = "unary vent"
	pipe_id = PIPE_UVENT
	orientations = 4
	pipe_icon = "uvent"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/scrubber
	pipe_name = "scrubber"
	pipe_id = PIPE_SCRUBBER
	orientations = 4
	pipe_icon = "scrubber"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/pump
	pipe_name = "pump"
	pipe_id = PIPE_PUMP
	orientations = 4
	pipe_icon = "pump"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/volume_pump
	pipe_name = "volume pump"
	pipe_id = PIPE_VOLUME_PUMP
	orientations = 4
	pipe_icon = "volumepump"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/gate
	pipe_name = "passive gate"
	pipe_id = PIPE_PASSIVE_GATE
	orientations = 4
	pipe_icon = "passivegate"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/filter
	pipe_name = "gas filter"
	pipe_id = PIPE_GAS_FILTER
	orientations = 4
	pipe_icon = "filter"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/mixer
	pipe_name = "gas mixer"
	pipe_id = PIPE_GAS_MIXER
	orientations = 4
	pipe_icon = "mixer"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/sensor
	pipe_name = "gas sensor"
	pipe_id = PIPE_GAS_SENSOR
	orientations = 1
	pipe_icon = "sensor"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/meter
	pipe_name = "meter"
	pipe_id = PIPE_METER
	orientations = 1
	pipe_icon = "meter"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/passive_vent
	pipe_name = "passive vent"
	pipe_id = PIPE_PASV_VENT
	orientations = 4
	pipe_icon = "passive vent"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/dual_vent_pump
	pipe_name = "dual-port vent pump"
	pipe_id = PIPE_DP_VENT
	orientations = 2
	pipe_icon = "dual-port vent"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/injector
	pipe_name = "air injector"
	pipe_id = PIPE_INJECTOR
	orientations = 4
	pipe_icon = "injector"
	pipe_category = RPD_DEVICES
	rpd_dispensable = TRUE

//Heat exchange pipes

/datum/pipes/atmospheric/simple/he
	pipe_name = "straight h/e pipe"
	pipe_id = PIPE_HE_STRAIGHT
	pipe_icon = "he"
	pipe_category = RPD_HEAT_PIPING

/datum/pipes/atmospheric/bent/he
	pipe_name = "bent h/e pipe"
	pipe_id = PIPE_HE_BENT
	pipe_icon = "he"
	bendy = TRUE
	pipe_category = RPD_HEAT_PIPING

/datum/pipes/atmospheric/he_junction
	pipe_name = "junction"
	pipe_id = PIPE_JUNCTION
	orientations = 4
	pipe_icon = "junction"
	pipe_category = RPD_HEAT_PIPING
	rpd_dispensable = TRUE

/datum/pipes/atmospheric/heat_exchanger
	pipe_name = "heat exchanger"
	pipe_id = PIPE_HEAT_EXCHANGE
	orientations = 4
	pipe_icon = "heunary"
	pipe_category = RPD_HEAT_PIPING
	rpd_dispensable = TRUE

//DISPOSALS PIPES

/datum/pipes/disposal/straight
	pipe_name = "straight disposals pipe"
	pipe_id = PIPE_DISPOSALS_STRAIGHT
	orientations = 2
	pipe_icon = "pipe-s"
	rpd_dispensable = TRUE

/datum/pipes/disposal/bent
	pipe_name = "bent disposals pipe"
	pipe_id = PIPE_DISPOSALS_BENT
	orientations = 4
	pipe_icon = "pipe-c"
	rpd_dispensable = TRUE

/datum/pipes/disposal/junction
	pipe_name = "disposals junction"
	pipe_id = PIPE_DISPOSALS_JUNCTION_RIGHT
	orientations = 4
	pipe_icon = "pipe-j1"
	rpd_dispensable = TRUE

/datum/pipes/disposal/y_junction
	pipe_name = "disposals y-junction"
	pipe_id = PIPE_DISPOSALS_Y_JUNCTION
	orientations = 4
	pipe_icon = "pipe-y"
	rpd_dispensable = TRUE

/datum/pipes/disposal/trunk
	pipe_name = "disposals trunk"
	pipe_id = PIPE_DISPOSALS_TRUNK
	orientations = 4
	pipe_icon = "pipe-t"
	rpd_dispensable = TRUE

/datum/pipes/disposal/bin
	pipe_name = "disposals pipe bin"
	pipe_id = PIPE_DISPOSALS_BIN
	orientations = 1
	pipe_icon = "disposal"
	rpd_dispensable = TRUE

/datum/pipes/disposal/outlet
	pipe_name = "disposals outlet"
	pipe_id = PIPE_DISPOSALS_OUTLET
	orientations = 4
	pipe_icon = "outlet"
	rpd_dispensable = TRUE

/datum/pipes/disposal/chute
	pipe_name = "disposals chute"
	pipe_id = PIPE_DISPOSALS_CHUTE
	orientations = 4
	pipe_icon = "intake"
	rpd_dispensable = TRUE

/datum/pipes/disposal/sortjunction
	pipe_name = "disposals sort junction"
	pipe_id = PIPE_DISPOSALS_SORT_RIGHT
	orientations = 4
	pipe_icon = "pipe-j1s"
	rpd_dispensable = TRUE

//Pipes the RPD can't dispense. Since these don't use an interface, we don't need to bother with setting an icon. We do, however, want to name these for other purposes

/datum/pipes/atmospheric/circulator
	pipe_name = "circulator / heat exchanger"
	pipe_id = PIPE_CIRCULATOR
	pipe_icon = "circ"

/datum/pipes/atmospheric/omni_filter
	pipe_name = "omni filter"
	pipe_id = PIPE_OMNI_FILTER
	pipe_icon = "omni_filter"

/datum/pipes/atmospheric/omni_mixer
	pipe_name = "omni mixer"
	pipe_id = PIPE_OMNI_MIXER
	pipe_icon = "omni_mixer"

/datum/pipes/atmospheric/insulated
	pipe_name = "insulated pipe"
	pipe_id = PIPE_INSULATED_STRAIGHT
	pipe_icon = "insulated"

/datum/pipes/atmospheric/insulated/bent
	pipe_name = "bent insulated pipe"
	pipe_id = PIPE_INSULATED_BENT

/datum/pipes/disposal/left_sortjunction
	pipe_name = "disposals sort junction left"
	pipe_id = PIPE_DISPOSALS_SORT_LEFT
	pipe_icon = "pipe-j2s"

/datum/pipes/disposal/left_junction
	pipe_name = "disposals junction"
	pipe_id = PIPE_DISPOSALS_JUNCTION_LEFT
	pipe_icon = "pipe-j2"

/proc/get_pipe_name(var/pipe_id, var/pipe_type)
	for(var/datum/pipes/P in GLOB.construction_pipe_list)
		if(P.pipe_id == pipe_id && P.pipe_type == pipe_type)
			return P.pipe_name
	return "unknown pipe"

/proc/get_pipe_icon(var/pipe_id)
	for(var/datum/pipes/P in GLOB.construction_pipe_list)
		if(P.pipe_id == pipe_id)
			return P.pipe_icon
	return "unknown icon"
