/datum/wires/fabricator

	holder_type = /obj/machinery/fabricator
	wire_count = 10

var/const/FABRICATOR_HACK_WIRE = 1
var/const/FABRICATOR_SHOCK_WIRE = 2
var/const/FABRICATOR_DISABLE_WIRE = 4

/datum/wires/fabricator/GetInteractWindow()
	var/obj/machinery/fabricator/A = holder
	. += ..()
	. += text("<BR>The red light is [A.disabled ? "off" : "on"].<BR>The green light is [A.shocked ? "off" : "on"].<BR>The blue light is [A.hacked ? "off" : "on"].<BR>")

/datum/wires/fabricator/CanUse()
	var/obj/machinery/fabricator/A = holder
	if(A.panel_open)
		return 1
	return 0

/datum/wires/fabricator/Interact(var/mob/living/user)
	if(CanUse(user))
		var/obj/machinery/fabricator/V = holder
		V.attack_hand(user)

/datum/wires/fabricator/UpdateCut(index, mended)
	var/obj/machinery/fabricator/A = holder
	switch(index)
		if(FABRICATOR_HACK_WIRE)
			A.adjust_hacked(!mended)
		if(FABRICATOR_SHOCK_WIRE)
			A.shocked = !mended
		if(FABRICATOR_DISABLE_WIRE)
			A.disabled = !mended

/datum/wires/fabricator/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/fabricator/A = holder
	switch(index)
		if(FABRICATOR_HACK_WIRE)
			A.adjust_hacked(!A.hacked)
			spawn(50)
				if(A && !IsIndexCut(index))
					A.adjust_hacked(0)
					Interact(usr)
		if(FABRICATOR_SHOCK_WIRE)
			A.shocked = !A.shocked
			spawn(50)
				if(A && !IsIndexCut(index))
					A.shocked = 0
					Interact(usr)
		if(FABRICATOR_DISABLE_WIRE)
			A.disabled = !A.disabled
			spawn(50)
				if(A && !IsIndexCut(index))
					A.disabled = 0
					Interact(usr)