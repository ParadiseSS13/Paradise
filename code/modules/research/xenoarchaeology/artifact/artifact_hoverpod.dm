/obj/mecha/working/hoverpod
	name = "hover pod"
	icon_state = "engineering_pod"
	desc = "Stubby and round, it has a human sized access hatch on the top."
	wreckage = /obj/effect/decal/mecha_wreckage/hoverpod

/obj/mecha/working/hoverpod/Process_Spacemove(var/movement_dir = 0)
	return 1 // puts the hover in hoverpod

//these three procs overriden to play different sounds
/obj/mecha/working/hoverpod/mechturn(direction)
	dir = direction
	//playsound(src,'sound/machines/hiss.ogg',40,1)
	return 1

/obj/mecha/working/hoverpod/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result


/obj/mecha/working/hoverpod/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result

/obj/effect/decal/mecha_wreckage/hoverpod
	name = "Hover pod wreckage"
	icon_state = "engineering_pod-broken"

	/*New()
		..()
		var/list/parts = list(

		for(var/i=0;i<2;i++)
			if(!isemptylist(parts) && prob(40))
				var/part = pick(parts)
				welder_salvage += part
				parts -= part
		return*/
