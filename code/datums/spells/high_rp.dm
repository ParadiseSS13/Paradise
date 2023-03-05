/obj/item/organ/internal/high_rp_tumor
	actions_types = list(/datum/action/item_action/organ_action/manual_breath)
	var/last_pump = 0
	var/pump_delay = 300
	var/oxy_loss = 45
	var/pump_window = 10
	var/warned = 0
	unremovable = TRUE

/obj/item/organ/internal/high_rp_tumor/insert(mob/living/target, special = 0)
	..(target, special = special)
	if(target)
		to_chat(target, "<span class='userdanger'>Я должен дышать, иначе просто задохнусь!</span>")

/mob/living/carbon/human/proc/curse_high_rp(delay = 300, oxyloss = 45)
	var/mob/living/carbon/human/H = src
	var/obj/item/organ/internal/high_rp_tumor/hrp_tumor = new
	hrp_tumor.last_pump = world.time
	hrp_tumor.pump_delay = delay
	hrp_tumor.oxy_loss = oxyloss
	hrp_tumor.pump_window = delay/5
	hrp_tumor.insert(H)

/obj/item/organ/internal/high_rp_tumor/on_life()
	if(world.time > (last_pump + (pump_delay - pump_window)))
		to_chat(owner, "Мне начинает не хватать воздуха.")
		warned = 1

	if(world.time > (last_pump + pump_delay))
		var/mob/living/carbon/human/H = owner
		H.setOxyLoss(H.oxyloss + oxy_loss)
		H.custom_emote(1, "задыхается!")
		to_chat(H, "<span class='userdanger'>Я должен дышать, иначе просто задохнусь!</span>")
		last_pump = world.time
		warned = 0

/datum/action/item_action/organ_action/manual_breath
	name = "Дышать"
	use_itemicon = FALSE
	icon_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "lungs"
	check_flags = null

/datum/action/item_action/organ_action/manual_breath/Trigger()
	. = ..()
	if(. && istype(target, /obj/item/organ/internal/high_rp_tumor))
		var/obj/item/organ/internal/high_rp_tumor/hrp_tumor = target

		if(world.time < (hrp_tumor.last_pump + (hrp_tumor.pump_delay - hrp_tumor.pump_window))) //no spam
			to_chat(owner, "<span class='userdanger'>Слишком рано!</span>")
			hrp_tumor.owner.setOxyLoss(hrp_tumor.owner.oxyloss + hrp_tumor.oxy_loss/5)
			return

		hrp_tumor.last_pump = world.time
		to_chat(owner, "<span class = 'notice'>Вы дышите.</span>")
		owner.custom_emote(1, "дышит")
