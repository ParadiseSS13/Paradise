/obj/machinery/atmospherics/portable/electrolyzer
	name = "gas electrolyzer"
	anchored = FALSE
	icon = 'icons/obj/atmos.dmi'
	icon_state = "electrolyzer_off"
	density = TRUE

	var/board_path = /obj/item/circuitboard/electrolyzer
	var/active = FALSE


/obj/machinery/atmospherics/portable/electrolyzer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A nifty little machine that is able to produce hydrogen when supplied with water vapor, \
			allowing for on the go hydorgen production! Nanotrasen is not responsbile for any accidents that may occur \
			from sudden hydogen combustion or explosions. </span>"

/obj/machinery/atmospherics/portable/electrolyzer/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 4 SECONDS)

/obj/machinery/atmospherics/portable/electrolyzer/AltClick(mob/user)
	if(anchored)
		to_chat(user, "<span class='warning'>[src] is anchored to the floor!</span>")
		return
	pixel_x = 0
	pixel_y = 0

// Turns the electrolyzer on and off
/obj/machinery/atmospherics/portable/electrolyzer/attack_hand(mob/user as mob)
    if(stat & BROKEN)
        return
    if(!anchored)
        to_chat(user, "<span class='warning'>[src] must be anchored first!</span>")
        return

    . = ..()
    if(active)
        active = FALSE
        to_chat(user, "<span class='notice'>The electrolyzer switches off.</span>")
        icon_state = "electrolyzer_off"
    else
        active = TRUE
        to_chat(user, "<span class='notice'>The electrolyzer begins to hum quietly.</span>")
        icon_state = "electrolyzer_on"

