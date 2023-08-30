/obj/structure/katana_grave
	name = "katana mound"
	desc = "A desolate and shallow grave for those who have fallen. This one seems to be punctuated by a katana."
	icon = 'icons/obj/lavaland/misc.dmi'
	icon_state = "grave_katana"
	anchored = TRUE
	var/obj/item/dropping_item = /obj/item/katana/cursed

/obj/structure/katana_grave/attack_hand(mob/user)
	. = ..()
	activate()

/obj/structure/katana_grave/proc/activate()
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	new dropping_item(get_turf(src))
	for(var/obj/structure/fluff/grave/other_grave in orange(9,src))
		if(prob(60)) //9 is too many, go for a much more reasonable number...
			new /mob/living/simple_animal/hostile/asteroid/hivelord/legion(get_turf(other_grave))
		else
			new /mob/living/simple_animal/hostile/skeleton(get_turf(other_grave))
		playsound(other_grave, 'sound/effects/break_stone.ogg', 50, 1)
	new /obj/structure/fluff/grave/empty(get_turf(src))
	qdel(src)

/obj/structure/katana_grave/basalt
	dropping_item = /obj/item/katana/basalt
	icon_state = "grave_katana_basalt"
