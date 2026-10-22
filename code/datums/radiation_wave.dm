/// A burst of radiation spreading a ring further each time SSradiation fires.
/// Where it's got to is kept on the Rust side, see SSradiation.spread_waves().
/datum/radiation_wave
	/// The thing that spawned this radiation wave
	var/source
	/// The strength at the origin. Multiplied by the weight of a tile to determine the strength of radiation there.
	var/intensity
	/// The type of particle emitted
	var/emission_type = ALPHA_RAD

/datum/radiation_wave/New(atom/_source, _intensity = 0, _emission_type = ALPHA_RAD)
	source = _source
	intensity = _intensity
	emission_type = _emission_type

/datum/radiation_wave/Destroy()
	. = QDEL_HINT_IWILLGC
	source = null
	..()
