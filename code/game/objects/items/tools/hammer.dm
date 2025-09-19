/obj/item/hammer
	name = "hammer"
	desc = "A useful tool to many throughout history. Slightly better than a weighted rock."
	icon = 'icons/obj/tools.dmi'
	icon_state = "hammer"
	belt_icon = "hammer"
	usesound = 'sound/magic/fellowship_armory.ogg'
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	materials = list(MAT_METAL = 300)
	origin_tech = "engineering=1;combat=1"
	attack_verb = list("attacked", "hammered", "smashed", "bludgeoned", "whacked")

	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_HAMMER

/obj/item/hammer/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/obj/item/hammer/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is bashing [user.p_their()] head with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")

	if(!use_tool(user, user, 3 SECONDS, volume = tool_volume))
		return SHAME
	playsound(loc, usesound, 50, FALSE)
	return BRUTELOSS
