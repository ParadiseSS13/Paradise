/obj/structure/bar
	name = "Horizontal Bar"
	desc = "You want to crow when you look at it."
	icon = 'icons/obj/bar.dmi'
	icon_state = "bar"
	density = 0
	anchored = 1
	layer = WALL_OBJ_LAYER

/obj/structure/bar/attack_hand(mob/user as mob)
	if(in_use)
		user.visible_message("Its already in use - wait a bit.")
		return
	else
		in_use = 1
		user.setDir(SOUTH)
		user.Stun(4)
		user.loc = src.loc
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		var/reps = 0
		user.pixel_y = 5
		while (reps++ < 6)
			if (user.loc != src.loc)
				break

			for (var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
				sleep(3)
				animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)

		sleep(3)
		animate(user, pixel_y = 2, time = 3)
		sleep(3)
		in_use = 0
		animate(user, pixel_y = 0, time = 3)
		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		user.Stun(0)
		user.visible_message("<B>[finishmessage]</B>")
