/*
CONTAINS:
RLF
*/

/obj/item/rlf
	name = "Rapid Lollipop Fabricator"
	desc = "A device used to rapidly deploy lollipop."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rlf"
	opacity = 0
	density = 0
	anchored = 0.0
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/rlf/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if(!isrobot(user))
		return
	if(!iscarbon(A))
		return
	var/mob/living/carbon/receiver = A
	if(receiver.stat != CONSCIOUS)
		to_chat(user, "<span class='warning'>[receiver] can't accept any items because they're not conscious!</span>")
		return
	if(!user.Adjacent(receiver))
		to_chat(user, "<span class='warning'>You need to be closer to [receiver] to offer them lollipop.</span>")
		return
	if(!receiver.client)
		to_chat(user, "<span class='warning'>You offer lollipop to [receiver], but they don't seem to respond...</span>")
		return
	var/obj/item/I = new /obj/item/reagent_containers/food/snacks/candy/sucker/lollipop
	receiver.throw_alert("take item [I.UID()]", /obj/screen/alert/take_item/RLF, alert_args = list(user, receiver, I))
	to_chat(user, "<span class='info'>You offer lollipop to [receiver].</span>")

/obj/screen/alert/take_item/RLF

/obj/screen/alert/take_item/RLF/Click(location, control, params)
	var/mob/living/receiver = locateUID(receiver_UID)
	if(receiver.stat != CONSCIOUS)
		return
	var/obj/item/reagent_containers/food/snacks/candy/sucker/I = locateUID(item_UID)
	if(receiver.r_hand && receiver.l_hand)
		to_chat(receiver, "<span class='warning'>You need to have your hands free to accept [I]!</span>")
		return
	var/mob/living/giver = locateUID(giver_UID)
	if(!isrobot(giver))
		return
	if(!giver.Adjacent(receiver))
		to_chat(receiver, "<span class='warning'>You need to stay in reaching distance of [giver] to take [I]!</span>")
		return
	UnregisterSignal(I, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	var/mob/living/silicon/robot/borg = giver
	borg.cell.charge -= 500
	receiver.put_in_hands(I)
	I.add_fingerprint(receiver)
	I.on_give(giver, receiver)
	receiver.visible_message("<span class='notice'>[giver] handed [I] to [receiver].</span>")
	receiver.clear_alert("take item [item_UID]")
