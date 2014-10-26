/*

Miscellaneous traitor devices

BATTERER


*/

/*

The Batterer, like a flashbang but 50% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/device/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon_state = "batterer"
	throwforce = 5
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"

	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 2


/obj/item/device/batterer/attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
	if(!user) 	return
	if(times_used >= max_uses)
		user << "\red The mind batterer has been burnt out!"
		return

	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [src] to knock down people in the area.</font>")

	for(var/mob/living/carbon/human/M in orange(10, user))
		spawn()
			if(prob(50))

				M.Weaken(rand(10,20))
				if(prob(25))
					M.Stun(rand(5,10))
				M << "\red <b>You feel a tremendous, paralyzing wave flood your mind.</b>"
				if(!iscarbon(user))
					M.LAssailant = null
				else
					M.LAssailant = user
			else
				M << "\red <b>You feel a sudden, electric jolt travel through your head.</b>"

	playsound(src.loc, 'sound/misc/interference.ogg', 50, 1)
	user << "\blue You trigger [src]."
	times_used += 1
	if(times_used >= max_uses)
		icon_state = "battererburnt"


/*
		The radioactive microlaser, a device disguised as a health analyzer used to irradiate people.

		The strength of the radiation is determined by the 'intensity' setting, while the delay between
	the scan and the irradiation kicking in is determined by the wavelength.

		Each scan will cause the microlaser to have a brief cooldown period. Higher intensity will increase
	the cooldown, while higher wavelength will decrease it.

		Wavelength is also slightly increased by the intensity as well.
*/

/obj/item/device/rad_laser
	name = "Health Analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject. A strange microlaser is hooked on to the scanning end."
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	discrete = 1 // Makes the item not give an attack log message for viewers.
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	origin_tech = "magnets=3;biotech=5;syndicate=3"
	var/intensity = 5 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds
	var/used = 0 // is it cooling down?

/obj/item/device/rad_laser/attack(mob/living/M as mob, mob/living/user as mob)
	if(!used)
		..()
		user.visible_message("<span class='notice'> [user] has analyzed [M]'s vitals.","<span class='notice'> You have analyzed [M]'s vitals.")
		var/cooldown = round(max(100,(((intensity*8)-(wavelength/2))+(intensity*2))*10))
		used = 1
		icon_state = "health1"
		handle_cooldown(cooldown) // splits off to handle the cooldown while handling wavelength
		spawn((wavelength+(intensity*4))*10)
			if(M)
				if(intensity >= 5)
					M.apply_effect(round(intensity/1.5), PARALYZE)
				M.apply_effect(intensity*10, IRRADIATE)
	else
		user << "<span class='danger'>The radioactive microlaser is still recharging.</span>"

/obj/item/device/rad_laser/proc/handle_cooldown(var/cooldown)
	spawn(cooldown)
		used = 0
		icon_state = "health"

/obj/item/device/rad_laser/attack_self(mob/user as mob)
	..()
	interact(user)

/obj/item/device/rad_laser/interact(mob/user as mob)
	user.set_machine(src)

	var/cooldown = round(max(10,((intensity*8)-(wavelength/2))+(intensity*2)))
	var/dat = {"
	Radiation Intensity: <A href='?src=\ref[src];radint=-5'>-</A><A href='?src=\ref[src];radint=-1'>-</A> [intensity] <A href='?src=\ref[src];radint=1'>+</A><A href='?src=\ref[src];radint=5'>+</A><BR>
	Radiation Wavelength: <A href='?src=\ref[src];radwav=-5'>-</A><A href='?src=\ref[src];radwav=-1'>-</A> [(wavelength+(intensity*4))] <A href='?src=\ref[src];radwav=1'>+</A><A href='?src=\ref[src];radwav=5'>+</A><BR>
	Laser Cooldown: [cooldown] Seconds<BR>
	"}

	var/datum/browser/popup = new(user, "radlaser", "Radioactive Microlaser Interface", 400, 240)
	popup.set_content(dat)
	popup.open()

/obj/item/device/rad_laser/Topic(href, href_list)
	if(!in_range(src, usr) || issilicon(usr) || !usr.canmove || usr.restrained())
		return 1

	usr.set_machine(src)

	if(href_list["radint"])
		var/amount = text2num(href_list["radint"])
		amount += intensity
		intensity = max(1,(min(10,amount)))

	else if(href_list["radwav"])
		var/amount = text2num(href_list["radwav"])
		amount += wavelength
		wavelength = max(1,(min(120,amount)))

	//updateUsrDialog()
	interact(usr)
	add_fingerprint(usr)
	return