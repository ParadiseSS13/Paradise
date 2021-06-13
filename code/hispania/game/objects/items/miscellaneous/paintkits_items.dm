//Oh god they have my sister thats why i made this.
/obj/item/fluff/mongosflash
	name = "red flash paintkit"
	desc = "An assorted set of exchangable parts for a flash."
	icon = 'icons/obj/paintkit.dmi'
	icon_state = "paintkit"

/obj/item/fluff/mongosflash/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !ishuman(user) || user.incapacitated())
		return

	if(istype(target, /obj/item/flash))
		to_chat(user, "<span class='notice'>You modify the appearance of [target].</span>")
		var/obj/item/flash/amongous = target
		amongous.icon = 'icons/hispania/obj/miscellaneous.dmi'
		amongous.icon_state = "flash"
		amongous.name = "custom red flash"
		amongous.desc = "A weird little flash, looks kinda sus."
		playsound(loc,'sound/hispania/effects/mongos.ogg',50,1)
		qdel(src)
		return
