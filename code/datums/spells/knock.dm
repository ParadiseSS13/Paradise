/obj/effect/proc_holder/spell/aoe_turf/wizard/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."

	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"
	range = 3
	cooldown_min = 20 //20 deciseconds reduction per rank

	icon_power_button = "spell_knock"

/obj/effect/proc_holder/spell/aoe_turf/knock/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			spawn(1)
				if(istype(door,/obj/machinery/door/airlock/hatch/gamma))
					return
				if(istype(door,/obj/machinery/door/airlock))
					door:unlock(1)	//forced because it's magic!
				door.open()
	return