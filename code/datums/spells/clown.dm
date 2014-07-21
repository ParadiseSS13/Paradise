/obj/effect/proc_holder/spell/targeted/embiggen
	name = "Embiggen"
	desc = "Make sure everyone knows you're there!"
	charge_max = 600

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = -1
	selection_type = "range"

	icon_power_button = "genetic_view"


/obj/effect/proc_holder/spell/targeted/remoteview/cast(list/targets)
	if(!ishuman(usr))
		return

	for(var/mob/living/target in targets)
		var/matrix/M = matrix()
		M.Scale(2)
		target.transform = M

		spawn(300)
			M = matrix()
			target.transform = M