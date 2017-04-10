// WIRES

/obj/item/weapon/wire
	desc = "This is just a simple piece of regular insulated wire."
	name = "wire"
	icon = 'icons/obj/power.dmi'
	icon_state = "item_wire"
	var/amount = 1.0
	var/laying = 0.0
	var/old_lay = null
	materials = list(MAT_METAL=40)
	attack_verb = list("whipped", "lashed", "disciplined", "tickled")

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return (OXYLOSS)


/obj/item/weapon/wire/proc/update()
	if(src.amount > 1)
		src.icon_state = "spool_wire"
		src.desc = text("This is just spool of regular insulated wire. It consists of about [] unit\s of wire.", src.amount)
	else
		src.icon_state = "item_wire"
		src.desc = "This is just a simple piece of regular insulated wire."
	return

/obj/item/weapon/wire/attack_self(mob/user as mob)
	if(src.laying)
		src.laying = 0
		to_chat(user, "\blue You're done laying wire!")
	else
		to_chat(user, "\blue You are not using this to lay wire...")
	return


