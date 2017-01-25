#define MIMECHUCKS_COMBO "DH"
#define MIMESMOKE_COMBO "DD"
#define MIMEPALM_COMBO "GD"

/datum/martial_art/mimejutsu
	name = "Mimejutsu"
	help_verb = /mob/living/carbon/human/proc/mimejutsu_help

/datum/martial_art/mimejutsu/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(findtext(streak,MIMECHUCKS_COMBO))
		streak = ""
		mimeChuck(A,D)
		return 1
	if(findtext(streak,MIMESMOKE_COMBO))
		streak = ""
		mimeSmoke(A,D)
		return 1
	if(findtext(streak,MIMEPALM_COMBO))
		streak = ""
		mimePalm(A,D)
		return 1
	return 0

/datum/martial_art/mimejutsu/proc/mimeChuck(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(!D.stat && !D.stunned && !D.weakened)
		var/damage = rand(5, 8) + A.species.punchdamagelow
		if(!damage)
			playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			D.visible_message("<span class='warning'>[A] swings invisible nunchcuks at [D]..and misses?</span>")
			return 0


		var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_sel.selecting))
		var/armor_block = D.run_armor_check(affecting, "melee")

		D.visible_message("<span class='danger'>[A] has hit [D] with invisible nuncucks!</span>", \
								"<span class='userdanger'>[A] has hit [D] with a with invisible nuncuck!</span>")
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		D.apply_damage(damage, STAMINA, affecting, armor_block)
		add_logs(A, D, "mimechucked")

		return 1
	return basic_hit(A,D)

/datum/martial_art/mimejutsu/proc/mimeSmoke(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)

	D.visible_message("<span class='danger'>[A] throws an invisible smoke bomb!!</span>")

	var/datum/effect/system/bad_smoke_spread/smoke = new /datum/effect/system/bad_smoke_spread()
	smoke.set_up(5, 0, D.loc)
	smoke.start()

	return basic_hit(A,D)

/datum/martial_art/mimejutsu/proc/mimePalm(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(!D.stat && !D.stunned && !D.weakened)
		D.visible_message("<span class='danger'>[A] has barely touched [D] with their palm!</span>", \
						"<span class='userdanger'>[A] hovers their palm over your face!</span>")

		var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
		D.throw_at(throw_target, 200, 4,A)
	return basic_hit(A,D)


/datum/martial_art/mimejutsu/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1

	return ..()

/datum/martial_art/mimejutsu/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1

	return 1

/datum/martial_art/mimejutsu/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1

	A.do_attack_animation(D)

	return 1

/obj/item/weapon/mimejutsu_scroll
	name = "Mimejutsu 'scroll'"
	desc =	"Its a beret with a note stapled to it..."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "beret"
	var/used = 0

/obj/item/weapon/mimejutsu_scroll/attack_self(mob/user as mob)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/mimejutsu/F = new/datum/martial_art/mimejutsu(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounce'>You have learned the ancient martial art of mimes.</span>")
		used = 1
		desc = "It used to have something stapled to it..the staple is still there."
		name = "beret with staple"
		icon_state = "beret"

/mob/living/carbon/human/proc/mimejutsu_help()
	set name = "Recall Ancient Mimeing"
	set desc = "Remember the martial techniques of Mimejutsu."
	set category = "Mimejutsu"

	to_chat(usr, "<b><i>You make a invisible box around yourself and recall the teachings of Mimejutsu...</i></b>")

	to_chat(usr, "<span class='notice'>Mimechucks</span>: Disarm Harm. Hits the opponent with invisible nunchucks.")
	to_chat(usr, "<span class='notice'>Smokebomb</span>: Disarm Disarm. Drops a mime smokebomb.")
	to_chat(usr, "<span class='notice'>Silent Palm</span>: Grab Disarm. Using mime energy throw someone back.")
