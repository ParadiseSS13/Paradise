//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/shadow_mend
	id = "shadow_mend"
	duration = 30
	alert_type = /obj/screen/alert/status_effect/shadow_mend

/obj/screen/alert/status_effect/shadow_mend
	name = "Shadow Mend"
	desc = "Shadowy energies wrap around your wounds, sealing them at a price. After healing, you will slowly lose health every three seconds for thirty seconds."
	icon_state = "shadow_mend"

/datum/status_effect/shadow_mend/on_apply()
	owner.visible_message("<span class='notice'>Violet light wraps around [owner]'s body!</span>", "<span class='notice'>Violet light wraps around your body!</span>")
	playsound(owner, 'sound/magic/teleport_app.ogg', 50, 1)
	return ..()

/datum/status_effect/shadow_mend/tick()
	owner.adjustBruteLoss(-15)
	owner.adjustFireLoss(-15)

/datum/status_effect/shadow_mend/on_remove()
	owner.visible_message("<span class='warning'>The violet light around [owner] glows black!</span>", "<span class='warning'>The tendrils around you cinch tightly and reap their toll...</span>")
	playsound(owner, 'sound/magic/teleport_diss.ogg', 50, 1)
	owner.apply_status_effect(STATUS_EFFECT_VOID_PRICE)


/datum/status_effect/void_price
	id = "void_price"
	duration = 300
	tick_interval = 30
	alert_type = /obj/screen/alert/status_effect/void_price

/obj/screen/alert/status_effect/void_price
	name = "Void Price"
	desc = "Black tendrils cinch tightly against you, digging wicked barbs into your flesh."
	icon_state = "shadow_mend"

/datum/status_effect/void_price/tick()
	playsound(owner, 'sound/weapons/bite.ogg', 50, 1)
	owner.adjustBruteLoss(3)

/datum/status_effect/exercised
	id = "Exercised"
	duration = 1200
	alert_type = null

/datum/status_effect/exercised/on_creation(mob/living/new_owner, ...)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	START_PROCESSING(SSprocessing, src) //this lasts 20 minutes, so SSfastprocess isn't needed.

/datum/status_effect/exercised/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

//Blood-drunk
/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10 //1 second
	tick_interval = 0
	alert_type = /obj/screen/alert/status_effect/blooddrunk
	var/last_bruteloss
	var/last_fireloss 
	var/last_toxloss 
	var/last_oxyloss 
	var/last_cloneloss 

/obj/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply() //Different to /tg/ version, because they handle things differently. I think this is better anyway
	flash_color(owner, flash_color = "#FF0000", flash_time = 10) 
	var/status = CANSTUN | CANWEAKEN | CANPARALYSE //Completely immune to stuns, same as stimulants.
	owner.status_flags &= ~status
	if(iscarbon(owner))
		last_bruteloss = owner.getBruteLoss() //Collecting damage values for later
		last_fireloss = owner.getFireLoss()
		last_toxloss = owner.getToxLoss()
		last_oxyloss = owner.getOxyLoss()
		last_cloneloss = owner.getCloneLoss() //Lets be real, who's gonna take clone damage while on lavaland, but we have to be consistent
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1)
	return ..()

/datum/status_effect/blooddrunk/tick()
	var/healamount
	var/new_bruteloss = owner.getBruteLoss()
	var/new_fireloss = owner.getFireLoss()
	var/new_toxloss = owner.getToxLoss()
	var/new_oxyloss = owner.getOxyLoss()
	var/new_cloneloss = owner.getCloneLoss()

	if(new_bruteloss > last_bruteloss)
		healamount = (last_bruteloss-new_bruteloss)*0.9 //Takes a negative value of damage taken, takes 90% of the value
		owner.adjustBruteLoss(healamount) //Adjusts damage by the value before, healing for 90% of damage taken

	if(new_fireloss > last_fireloss)
		healamount = (last_fireloss-new_fireloss)*0.9
		owner.adjustFireLoss(healamount)

	if(new_toxloss > last_toxloss)
		healamount = (last_toxloss-new_toxloss)*0.9
		owner.adjustToxLoss(healamount)

	if(new_oxyloss > last_oxyloss)
		healamount = (last_oxyloss-new_oxyloss)*0.9
		owner.adjustOxyLoss(healamount)

	if(new_cloneloss > last_cloneloss)
		healamount = (last_cloneloss-new_cloneloss)*0.9
		owner.adjustCloneLoss(healamount)

	last_bruteloss = owner.getBruteLoss() //Resetting damage values
	last_fireloss = owner.getFireLoss()
	last_toxloss = owner.getToxLoss()
	last_oxyloss = owner.getOxyLoss()
	last_cloneloss = owner.getCloneLoss()

/datum/status_effect/blooddrunk/on_remove()
	owner.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE
