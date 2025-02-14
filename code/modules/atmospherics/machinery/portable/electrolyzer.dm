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

// Turns the electrolyzer on and off
/obj/machinery/atmospherics/portable/electrolyzer/attack_hand(mob/user as mob)
	. = ..()
	if(active)
		active = FALSE
		to_chat(user, "<span class='notice'>The electrolyzer is now off.</span>")
		icon_state = "electrolyzer_off"
	else
		active = TRUE
		to_chat(user, "<span class='notice'>The electrolyzer is now on.</span>")
		icon_state = "electrolyzer_on"

/obj/machinery/atmospherics/portable/electrolyzer/process()
    if(active)
		var/MINIMUM_WATER_FOR_ELECTROLYZER = 10
				log_admin("DEBUG: HEY LOOK, HYROGEN")
