/datum/wires/suitstorage
	holder_type = /obj/machinery/suit_storage_unit
	wire_count = 8

#define SSU_WIRE_ID 1
#define SSU_WIRE_SHOCK 2
#define SSU_WIRE_SAFETY 4
#define SSU_WIRE_UV 8


/datum/wires/suitstorage/GetWireName(index)
	switch(index)
		if(SSU_WIRE_ID)
			return "ID lock"
		if(SSU_WIRE_SHOCK)
			return "Shock wire"
		if(SSU_WIRE_SAFETY)
			return "Safety wire"
		if(SSU_WIRE_UV)
			return "UV wire"


/datum/wires/suitstorage/get_status()
	. = ..()
	var/obj/machinery/suit_storage_unit/A = holder
	. += "The blue light is [A.secure ? "on" : "off"]."
	. += "The red light is [A.safeties ? "off" : "blinking"]."
	. += "The green light is [A.shocked ? "on" : "off"]."
	. += "The UV display shows [A.uv_super ? "15 nm" : "185 nm"]."

datum/wires/suitstorage/CanUse()
	var/obj/machinery/suit_storage_unit/A = holder
	if(A.panel_open)
		return 1
	return 0

/datum/wires/suitstorage/UpdateCut(index, mended)
	var/obj/machinery/suit_storage_unit/A = holder
	switch(index)
		if(SSU_WIRE_ID)
			A.secure = mended
		if(SSU_WIRE_SAFETY)
			A.safeties = mended
		if(SSU_WIRE_SHOCK)
			A.shocked = !mended
			A.shock(usr, 50)
		if(SSU_WIRE_UV)
			A.uv_super = !mended
	..()

datum/wires/suitstorage/UpdatePulsed(index)
	var/obj/machinery/suit_storage_unit/A = holder
	if(IsIndexCut(index))
		return
	switch(index)
		if(SSU_WIRE_ID)
			A.secure = !A.secure
		if(SSU_WIRE_SAFETY)
			A.safeties = !A.safeties
		if(SSU_WIRE_SHOCK)
			A.shocked = !A.shocked
			if(A.shocked)
				A.shock(usr, 100)
				spawn(50)
					if(A && !IsIndexCut(index))
						A.shocked = FALSE
		if(SSU_WIRE_UV)
			A.uv_super = !A.uv_super
	..()
