/obj/item/twohanded/required/ram
	name = "ram"
	desc = "A heavy ram used to take down those pesky doors. "
	icon = 'icons/hispania/obj/ram.dmi'
	icon_state = "ram"
	item_state = "ram"

/obj/item/twohanded/required/ram/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /turf/simulated/wall))