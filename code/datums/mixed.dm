/datum/data
	var/name = "data"
	var/size = 1.0


/datum/data/function
	name = "function"
	size = 2.0


/datum/data/function/data_control
	name = "data control"


/datum/data/function/id_changer
	name = "id changer"


/datum/data/record
	name = "record"
	size = 5.0
	var/list/fields = list(  )

/datum/data/record/Destroy()
	if(src in SSrecords.medical)
		SSrecords.medical -= src
	if(src in SSrecords.security)
		SSrecords.security -= src
	if(src in SSrecords.general)
		SSrecords.general -= src
	if(src in SSrecords.locked)
		SSrecords.locked -= src
	return ..()

/datum/data/text
	name = "text"
	var/data = null

/datum/debug
	var/list/debuglist
