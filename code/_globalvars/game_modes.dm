var/master_mode = "extended"//"extended"
var/secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

var/wavesecret = 0 // meteor mode, delays wave progression, terrible name
var/datum/station_state/start_state = null // Used in round-end report

var/custom_event_msg = null
var/custom_event_admin_msg = null

var/list/summon_spots = list()
