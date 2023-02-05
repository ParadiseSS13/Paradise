PROCESSING_SUBSYSTEM_DEF(instruments)
	name = "Instruments"
	init_order = INIT_ORDER_INSTRUMENTS
	wait = 1
	flags = SS_TICKER|SS_BACKGROUND|SS_KEEP_TIMING
	offline_implications = "Instruments will no longer play. No immediate action is needed."

	/// List of all instrument data, associative id = datum
	var/list/datum/instrument/instrument_data
	/// List of all song datums.
	var/list/datum/song/songs
	/// Max lines in songs
	var/musician_maxlines = 600
	/// Max characters per line in songs
	var/musician_maxlinechars = 300
	/// Deciseconds between hearchecks. Too high and instruments seem to lag when people are moving around in terms of who can hear it. Too low and the server lags from this.
	var/musician_hearcheck_mindelay = 5
	/// Maximum instrument channels total instruments are allowed to use. This is so you don't have instruments deadlocking all sound channels.
	var/max_instrument_channels = MAX_INSTRUMENT_CHANNELS
	/// Current number of channels allocated for instruments
	var/current_instrument_channels = 0
	/// Single cached list for synthesizer instrument ids, so you don't have to have a new list with every synthesizer.
	var/list/synthesizer_instrument_ids

/datum/controller/subsystem/processing/instruments/Initialize()
	initialize_instrument_data()
	synthesizer_instrument_ids = get_allowed_instrument_ids()

/**
  * Initializes all instrument datums
  */
/datum/controller/subsystem/processing/instruments/proc/initialize_instrument_data()
	instrument_data = list()
	for(var/path in subtypesof(/datum/instrument))
		var/datum/instrument/I = path
		if(initial(I.abstract_type) == path)
			continue
		I = new path
		I.Initialize()
		if(!I.id)
			qdel(I)
			continue
		else
			instrument_data[I.id] = I
		CHECK_TICK

/**
  * Reserves a sound channel for a given instrument datum
  *
  * Arguments:
  * * I - The instrument datum
  */
/datum/controller/subsystem/processing/instruments/proc/reserve_instrument_channel(datum/instrument/I)
	if(current_instrument_channels > max_instrument_channels)
		return
	. = SSsounds.reserve_sound_channel(I)
	if(!isnull(.))
		current_instrument_channels++

/**
  * Called when a datum/song is created
  *
  * Arguments:
  * * S - The created datum/song
  */
/datum/controller/subsystem/processing/instruments/proc/on_song_new(datum/song/S)
	LAZYADD(songs, S)

/**
  * Called when a datum/song is deleted
  *
  * Arguments:
  * * S - The deleted datum/song
  */
/datum/controller/subsystem/processing/instruments/proc/on_song_del(datum/song/S)
	LAZYREMOVE(songs, S)

/**
  * Returns the instrument datum at the given ID or path
  *
  * Arguments:
  * * id_or_path - The ID or path of the instrument
  */
/datum/controller/subsystem/processing/instruments/proc/get_instrument(id_or_path)
	return instrument_data["[id_or_path]"]
