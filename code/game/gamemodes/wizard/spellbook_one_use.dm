//Single Use Spellbooks
/obj/item/spellbook/oneuse
	var/spell = /obj/effect/proc_holder/spell/projectile/magic_missile //just a placeholder to avoid runtimes if someone spawned the generic
	var/spellname = "sandbox"
	var/used = FALSE
	name = "spellbook of "
	uses = 1
	desc = "This template spellbook was never meant for the eyes of man..."

/obj/item/spellbook/oneuse/New()
	..()
	name += spellname

/obj/item/spellbook/oneuse/initialize() //No need to init
	return

/obj/item/spellbook/oneuse/attack_self(mob/user)
	var/obj/effect/proc_holder/spell/S = new spell
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == S.type)
			if(user.mind)
				if(user.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE || user.mind.special_role == SPECIAL_ROLE_WIZARD)
					to_chat(user, "<span class='notice'>You're already far more versed in this spell than this flimsy how-to book can provide.</span>")
				else
					to_chat(user, "<span class='notice'>You've already read this one.</span>")
			return
	if(used)
		recoil(user)
	else
		user.mind.AddSpell(S)
		to_chat(user, "<span class='notice'>you rapidly read through the arcane book. Suddenly you realize you understand [spellname]!</span>")
		user.create_log(MISC_LOG, "learned the spell [spellname] ([S])")
		user.create_attack_log("<font color='orange'>[key_name(user)] learned the spell [spellname] ([S]).</font>")
		onlearned(user)

/obj/item/spellbook/oneuse/proc/recoil(mob/user)
	user.visible_message("<span class='warning'>[src] glows in a black light!</span>")

/obj/item/spellbook/oneuse/proc/onlearned(mob/user)
	used = TRUE
	user.visible_message("<span class='caution'>[src] glows dark for a second!</span>")

/obj/item/spellbook/oneuse/attackby()
	return

/obj/item/spellbook/oneuse/fireball
	spell = /obj/effect/proc_holder/spell/fireball
	spellname = "fireball"
	icon_state = "bookfireball"
	desc = "This book feels warm to the touch."

/obj/item/spellbook/oneuse/fireball/recoil(mob/user as mob)
	..()
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
	qdel(src)

/obj/item/spellbook/oneuse/smoke
	spell = /obj/effect/proc_holder/spell/smoke
	spellname = "smoke"
	icon_state = "booksmoke"
	desc = "This book is overflowing with the dank arts."

/obj/item/spellbook/oneuse/smoke/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='caution'>Your stomach rumbles...</span>")
	user.adjust_nutrition(-200)

/obj/item/spellbook/oneuse/blind
	spell = /obj/effect/proc_holder/spell/trigger/blind
	spellname = "blind"
	icon_state = "bookblind"
	desc = "This book looks blurry, no matter how you look at it."

/obj/item/spellbook/oneuse/blind/recoil(mob/user)
	..()
	if(isliving(user))
		var/mob/living/L = user
		to_chat(user, "<span class='warning'>You go blind!</span>")
		L.EyeBlind(20 SECONDS)

/obj/item/spellbook/oneuse/mindswap
	spell = /obj/effect/proc_holder/spell/mind_transfer
	spellname = "mindswap"
	icon_state = "bookmindswap"
	desc = "This book's cover is pristine, though its pages look ragged and torn."
	var/mob/stored_swap = null //Used in used book recoils to store an identity for mindswaps

/obj/item/spellbook/oneuse/mindswap/onlearned()
	spellname = pick("fireball","smoke","blind","forcewall","knock","horses","charge")
	icon_state = "book[spellname]"
	name = "spellbook of [spellname]" //Note, desc doesn't change by design
	..()

/obj/item/spellbook/oneuse/mindswap/recoil(mob/user)
	..()
	if(stored_swap in GLOB.dead_mob_list)
		stored_swap = null
	if(!stored_swap)
		stored_swap = user
		to_chat(user, "<span class='warning'>For a moment you feel like you don't even know who you are anymore.</span>")
		return
	if(stored_swap == user)
		to_chat(user, "<span class='notice'>You stare at the book some more, but there doesn't seem to be anything else to learn...</span>")
		return

	var/obj/effect/proc_holder/spell/mind_transfer/swapper = new
	swapper.cast(user, stored_swap)

	to_chat(stored_swap, "<span class='warning'>You're suddenly somewhere else... and someone else?!</span>")
	to_chat(user, "<span class='warning'>Suddenly you're staring at [src] again... where are you, who are you?!</span>")
	stored_swap = null

/obj/item/spellbook/oneuse/forcewall
	spell = /obj/effect/proc_holder/spell/forcewall
	spellname = "forcewall"
	icon_state = "bookforcewall"
	desc = "This book has a dedication to mimes everywhere inside the front cover."

/obj/item/spellbook/oneuse/forcewall/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You suddenly feel very solid!</span>")
	var/obj/structure/closet/statue/S = new /obj/structure/closet/statue(user.loc, user)
	S.timer = 30
	user.drop_item()

/obj/item/spellbook/oneuse/knock
	spell = /obj/effect/proc_holder/spell/aoe/knock
	spellname = "knock"
	icon_state = "bookknock"
	desc = "This book is hard to hold closed properly."

/obj/item/spellbook/oneuse/knock/recoil(mob/living/user)
	..()
	to_chat(user, "<span class='warning'>You're knocked down!</span>")
	user.Weaken(40 SECONDS)

/obj/item/spellbook/oneuse/horsemask
	spell = /obj/effect/proc_holder/spell/horsemask
	spellname = "horses"
	icon_state = "bookhorses"
	desc = "This book is more horse than your mind has room for."

/obj/item/spellbook/oneuse/horsemask/recoil(mob/living/carbon/user as mob)
	if(ishuman(user))
		to_chat(user, "<font size='15' color='red'><b>HOR-SIE HAS RISEN</b></font>")
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.flags |= NODROP | DROPDEL	//curses!
		magichead.flags_inv = null	//so you can still see their face
		magichead.voicechange = TRUE	//NEEEEIIGHH
		if(!user.unEquip(user.wear_mask))
			qdel(user.wear_mask)
		user.equip_to_slot_if_possible(magichead, SLOT_HUD_WEAR_MASK, TRUE, TRUE)
		qdel(src)
	else
		to_chat(user, "<span class='notice'>I say thee neigh</span>")

/obj/item/spellbook/oneuse/charge
	spell = /obj/effect/proc_holder/spell/charge
	spellname = "charging"
	icon_state = "bookcharge"
	desc = "This book is made of 100% post-consumer wizard."

/obj/item/spellbook/oneuse/charge/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>[src] suddenly feels very warm!</span>")
	empulse(src, 1, 1)

/obj/item/spellbook/oneuse/summonitem
	spell = /obj/effect/proc_holder/spell/summonitem
	spellname = "instant summons"
	icon_state = "booksummons"
	desc = "This book is bright and garish, very hard to miss."

/obj/item/spellbook/oneuse/summonitem/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>[src] suddenly vanishes!</span>")
	qdel(src)

/obj/item/spellbook/oneuse/fake_gib
	spell = /obj/effect/proc_holder/spell/touch/fake_disintegrate
	spellname = "disintegrate"
	icon_state = "bookfireball"
	desc = "This book feels like it will rip stuff apart."

/obj/item/spellbook/oneuse/sacredflame
	spell = /obj/effect/proc_holder/spell/sacred_flame
	spellname = "sacred flame"
	icon_state = "booksacredflame"
	desc = "Become one with the flames that burn within... and invite others to do so as well."

/obj/item/spellbook/oneuse/random
	icon_state = "random_book"

/obj/item/spellbook/oneuse/random/initialize()
	. = ..()
	var/static/banned_spells = list(/obj/item/spellbook/oneuse/mime, /obj/item/spellbook/oneuse/mime/fingergun, /obj/item/spellbook/oneuse/mime/fingergun/fake, /obj/item/spellbook/oneuse/mime/greaterwall)
	var/real_type = pick(subtypesof(/obj/item/spellbook/oneuse) - banned_spells)
	new real_type(loc)
	qdel(src)
