/obj/item/mecha_modkit
	name = "mecha modification kit"
	desc = "A kit to modify your mech. This one doesn't do anything."
	icon = 'icons/obj/module.dmi'
	icon_state = "harddisk_mini"
	var/install_time = 15

/obj/item/mecha_modkit/proc/install(var/obj/mecha/mech, var/mob/user)
	if(user)
		to_chat(user, "<span class='notice'>You install [src] into [mech].</span>")
	return TRUE

/obj/item/mecha_modkit/voice
	name = "mecha voice modification kit : Standard"
	desc = "This modification kit updates a mech's onboard voice to Standard."
	var/nominalsound = 'sound/mecha/nominal.ogg'
	var/zoomsound = 'sound/mecha/imag_enh.ogg'
	var/critdestrsound = 'sound/mecha/critdestr.ogg'
	var/weapdestrsound = 'sound/mecha/weapdestr.ogg'
	var/lowpowersound = 'sound/mecha/lowpower.ogg'
	var/longactivationsound = 'sound/mecha/nominal.ogg'

/obj/item/mecha_modkit/voice/install(var/obj/mecha/mech, var/mob/living/carbon/user)
	if(istype(mech, /obj/mecha/combat/reticence) && user)
		to_chat(user, "<span class='warning'>You attempt to install [src] into [mech], but an invisible barrier prevents you from doing so!</span>")
		return FALSE
	if(istype(mech, /obj/mecha/combat/honker) && user)
		to_chat(user, "<span class='warning'>You attempt to install [src] into [mech], but you somehow trip before you get it in!</span>")
		user.slip("your own foot", 8, 5, 0, 0, 1, "trip")
		return FALSE
	mech.nominalsound = nominalsound
	mech.zoomsound = zoomsound
	mech.critdestrsound = critdestrsound
	mech.weapdestrsound = weapdestrsound
	mech.lowpowersound = lowpowersound
	mech.longactivationsound = longactivationsound
	..()

/obj/item/mecha_modkit/voice/nanotrasen
	name = "mecha voice modification kit : Nanotrasen"
	desc = "This modification kit updates a mech's onboard voice to Nanotrasen."
	nominalsound = 'sound/mecha/nominalnano.ogg'
	zoomsound = 'sound/mecha/imag_enhnano.ogg'
	critdestrsound = 'sound/mecha/critdestrnano.ogg'
	weapdestrsound = 'sound/mecha/weapdestrnano.ogg'
	lowpowersound = 'sound/mecha/lowpowernano.ogg'
	longactivationsound = 'sound/mecha/LongNanoActivation.ogg'

/obj/item/mecha_modkit/voice/syndicate
	name = "mecha voice modification kit : Syndicate"
	desc = "This suspicious modification kit updates a mech's onboard voice to Syndicate."
	origin_tech = "syndicate=1"
	nominalsound = 'sound/mecha/nominalsyndi.ogg'
	zoomsound = 'sound/mecha/imag_enhsyndi.ogg'
	critdestrsound = 'sound/mecha/critdestrsyndi.ogg'
	weapdestrsound = 'sound/mecha/weapdestrsyndi.ogg'
	lowpowersound = 'sound/mecha/lowpowersyndi.ogg'
	longactivationsound = 'sound/mecha/LongSyndiActivation.ogg'

/obj/item/mecha_modkit/voice/honk
	name = "mecha voice modification kit : Honk"
	desc = "This modification kit updates a mech's onboard voice to Honk. Why?"
	nominalsound = 'sound/items/bikehorn.ogg'
	zoomsound = 'sound/items/bikehorn.ogg'
	critdestrsound = 'sound/items/Airhorn2.ogg'
	weapdestrsound = 'sound/items/Airhorn2.ogg'
	lowpowersound = 'sound/items/Airhorn2.ogg'
	longactivationsound = 'sound/items/bikehorn.ogg'

/obj/item/mecha_modkit/voice/silent
	name = "mecha voice modification kit : Silent"
	desc = "This modification kit silences a mech's onboard voice."
	nominalsound = null
	zoomsound = null
	critdestrsound = null
	weapdestrsound = null
	lowpowersound = null
	longactivationsound = null
