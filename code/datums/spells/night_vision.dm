/obj/effect/proc_holder/spell/targeted/night_vision
	name = "Toggle Nightvision"
	desc = "Toggle your nightvision mode."

	charge_max = 10
	clothes_req = 0

	message = "<span class='notice'>You toggle your night vision!</span>"
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/night_vision/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		switch(target.lighting_alpha)
			if (LIGHTING_PLANE_ALPHA_VISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
				name = "Toggle Nightvision \[More]"
			if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
				name = "Toggle Nightvision \[Full]"
			if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
				name = "Toggle Nightvision \[OFF]"
			else
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
				name = "Toggle Nightvision \[ON]"
		target.update_sight()
