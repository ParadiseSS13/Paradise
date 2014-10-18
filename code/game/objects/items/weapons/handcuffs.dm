/obj/item/weapon/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	m_amt = 500
	origin_tech = "materials=1"
	var/dispenser = 0
	var/breakouttime = 1200 //Deciseconds = 120s = 2 minutes

/obj/item/weapon/handcuffs/attack(mob/living/carbon/C, mob/user)
	if(M_CLUMSY in user.mutations && prob(50))
		user << "<span class='warning'>Uh... how do those things work?!</span>"
		if(!C.handcuffed)
			user.drop_item()
			loc = C
			C.handcuffed = src
			C.update_inv_handcuffed()
			return

	var/cable = 0
	if(istype(src, /obj/item/weapon/handcuffs/cable))
		cable = 1

	if(!C.handcuffed)
		C.visible_message("<span class='danger'>[user] is trying to put handcuffs on [C]!</span>", \
							"<span class='danger'>[user] is trying to put handcuffs on [C]!</span>")

		if(cable)
			playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		else
			playsound(loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)

		if(do_mob(user, C, 30))
			if(C.handcuffed)
				return
			user.drop_item()
			loc = C
			C.handcuffed = src
			C.update_inv_handcuffed()
			if(cable)
				feedback_add_details("handcuffs","C")
			else
				feedback_add_details("handcuffs","H")

			add_logs(user, C, "handcuffed")

var/last_chew = 0
/mob/living/carbon/human/RestrainedClickOn(var/atom/A)
	if (A != src) return ..()
	if (last_chew + 26 > world.time) return

	var/mob/living/carbon/human/H = A
	if (!H.handcuffed) return
	if (H.a_intent != "harm") return
	if (H.zone_sel.selecting != "mouth") return
	if (H.wear_mask) return
	if (istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket)) return

	var/datum/organ/external/O = H.organs_by_name[H.hand?"l_hand":"r_hand"]
	if (!O) return

	var/s = "\red [H.name] chews on \his [O.display_name]!"
	H.visible_message(s, "\red You chew on your [O.display_name]!")
	H.attack_log += text("\[[time_stamp()]\] <font color='red'>[s] ([H.ckey])</font>")
	log_attack("[s] ([H.ckey])")

	if(O.take_damage(3,0,1,1,"teeth marks"))
		H:UpdateDamageIcon()
		if(prob(10))
			O.droplimb()

	last_chew = world.time

/obj/item/weapon/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_red"
	breakouttime = 300 //Deciseconds = 30s

/obj/item/weapon/handcuffs/cable/red
	icon_state = "cuff_red"

/obj/item/weapon/handcuffs/cable/yellow
	icon_state = "cuff_yellow"

/obj/item/weapon/handcuffs/cable/blue
	icon_state = "cuff_blue"

/obj/item/weapon/handcuffs/cable/green
	icon_state = "cuff_green"

/obj/item/weapon/handcuffs/cable/pink
	icon_state = "cuff_pink"

/obj/item/weapon/handcuffs/cable/orange
	icon_state = "cuff_orange"

/obj/item/weapon/handcuffs/cable/cyan
	icon_state = "cuff_cyan"

/obj/item/weapon/handcuffs/cable/white
	icon_state = "cuff_white"


/obj/item/weapon/handcuffs/cyborg
	dispenser = 1

/obj/item/weapon/handcuffs/pinkcuffs
	name = "fluffy pink handcuffs"
	desc = "Use this to keep prisoners in line. Or you know, your significant other."
	icon_state = "pinkcuffs"

/obj/item/weapon/handcuffs/cable/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		var/obj/item/weapon/wirerod/W = new /obj/item/weapon/wirerod
		R.use(1)
		user.put_in_hands(W)
		user << "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>"
		del(src)

