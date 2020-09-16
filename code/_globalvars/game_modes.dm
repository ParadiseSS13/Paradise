
GLOBAL_VAR_INIT(master_mode, "extended") //"extended"
GLOBAL_VAR_INIT(secret_force_mode, "secret") // if this is anything but "secret", the secret rotation will forceably choose this mode

GLOBAL_VAR_INIT(wavesecret, 0) // meteor mode, delays wave progression, terrible name
GLOBAL_DATUM(start_state, /datum/station_state) // Used in round-end report. Dont ask why it inits as null

GLOBAL_VAR(custom_event_msg)
GLOBAL_VAR(custom_event_admin_msg)

GLOBAL_LIST_EMPTY(summon_spots)

GLOBAL_VAR(protect_target) // The one sucker that will be fought over by antags
GLOBAL_LIST_EMPTY(protect_target_assassins) // Who is going to hunt them
GLOBAL_LIST_EMPTY(protect_target_protectors) // Who is going to protect them
