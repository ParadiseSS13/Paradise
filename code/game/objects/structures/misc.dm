//MISC structures- if it is less than 100 lines and doesn't fit in a category, toss it in here!

/*CURRENT CONTENTS:
	NT recruitment signpost
	Ninja Teleportation Console
*/

/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob, params)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		to_chat(user, "Civilians: NT is recruiting! Please head SOUTH to the NT Recruitment office to join the station's crew!")

/obj/structure/ninjatele

	name = "Long-Distance Teleportation Console"
	desc = "A console used to send a Spider Clan operative long distances rapidly."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "teleconsole"
	anchored = 1
	density = 0

	attackby(obj/item/weapon/W as obj, mob/user as mob, params)

		return attack_hand(user)


	attack_hand(mob/user as mob)


		if(user.mind.special_role=="Ninja")
			switch(alert("Phase Jaunt relay primed, target locked as [station_name()], initiate VOID-shift translocation? (Warning! Internals required!)",,"Yes","No"))

				if("Yes")
					if(user.z != src.z)        return

					user.loc.loc.Exited(user)
					user.loc = pick(carplist) // In the future, possibly make specific NinjaTele landmarks, and give him an option to teleport to North/South/East/West of SS13 instead of just hijacking a carpspawn.


					playsound(user.loc, 'sound/effects/phasein.ogg', 25, 1)
					playsound(user.loc, 'sound/effects/sparks2.ogg', 50, 1)
					anim(user.loc,user,'icons/mob/mob.dmi',,"phasein",,user.dir)

					to_chat(user, "<span class='boldnotice'>VOID-Shift</span> translocation successful")

				if("No")

					to_chat(user, "<span class='danger'>Process aborted!</span>")

					return
		else
			to_chat(user, "<span class='danger'>FĆAL �Rr�R</span>: ŧer nt recgnized, c-cntr-r䣧-ç äcked.")
