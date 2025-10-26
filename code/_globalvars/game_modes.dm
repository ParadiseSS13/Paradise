
GLOBAL_VAR_INIT(master_mode, "extended") //"extended"
GLOBAL_VAR_INIT(secret_force_mode, "secret") // if this is anything but "secret", the secret rotation will forceably choose this mode

GLOBAL_DATUM(start_state, /datum/station_state) // Used in round-end report. Dont ask why it inits as null

GLOBAL_VAR(custom_event_msg)

/// We want anomalous_particulate_tracker to exist only once and be accessible from anywhere.
GLOBAL_DATUM_INIT(anomaly_smash_track, /datum/anomalous_particulate_tracker, new)
