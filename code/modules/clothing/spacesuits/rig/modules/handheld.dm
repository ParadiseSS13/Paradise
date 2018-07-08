
/obj/item/rig_module/handheld
	name = "mounted device"
	desc = "Some kind of hardsuit extension."
	usable = 0
	selectable = 0
	toggleable = 1
	disruptive = 0
	activate_string = "Deploy"
	deactivate_string = "Retract"

	var/device_type
	var/obj/item

/obj/item/rig_module/handheld/activate()
	if(!..())
		return

	if(!holder.wearer.put_in_hands(device))
		to_chat(holder.wearer, "<span class='notice'>You need a free hand to hold \the [device].</span>")
		active = 0
		return

	to_chat(holder.wearer, "<span class='notice'>You deploy \the [device].</span>")


/obj/item/rig_module/handheld/deactivate()
	if(!..())
		return
	if(ismob(device.loc))			//Better check for the holder, instead of assuming the rigwearer has it.
		var/mob/M = device.loc	//Helps in case the code fails to keep the module in one place, this should still return it.
		M.unEquip(device, 1)

	device.loc = src
	to_chat(holder.wearer, "<span class='notice'>You retract \the [device].</span>")

/obj/item/rig_module/handheld/New()
	..()
	if(device_type)
		device = new device_type(src)
		device.flags |= NODROP //We don't want to drop it while it's active/inhand.
		activate_string += " [device]"
		deactivate_string += " [device]"

/obj/item/rig_module/handheld/horn
	name = "mounted bikehorn"
	desc = "For tactical honking"
	interface_name = "mounted bikehorn"
	interface_desc = "Honks"
	device_type = /obj/item/bikehorn
