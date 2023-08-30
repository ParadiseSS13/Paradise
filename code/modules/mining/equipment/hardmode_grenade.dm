/obj/item/grenade/megafauna_hardmode
	desc = "An advanced grenade that releases nanomachines, which enter nearby megafauna. This will enrage them greatly, but allows nanotrasen to fully research their abilities."
	name = "\improper HRD-MDE Scanning Grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "enrager"
	item_state = "grenade"

/obj/item/grenade/megafauna_hardmode/prime()
	update_mob()
	playsound(loc, 'sound/effects/empulse.ogg', 50, 1)
	for(var/mob/living/simple_animal/hostile/megafauna/M in range(7, src))
		M.enrage()
		visible_message("<span class='userdanger'>[M] begins to wake up as the nanomachines enter them, it looks pissed!</span>")
	qdel(src)

/obj/item/paper/hardmode
	name = "HRD-MDE Scanner Guide"
	icon_state = "paper"
	info = {"<b>Welcome to the NT HRD-MDE Project</b><br>
	<br>
	This guide will cover the basics on the Hi-tech Research and Development, Mining Department Experiment project.<br>
	<br>
	These grenades when used, will disperse a cloud of nanomachines into nearbye fauna, allowing a detailed examination of their body structure when alive. We will use this data to develope new products to sell, and we need your help!<br>
	<br>
	We need to see these fauna working at their full potential with the nanomachines in them, so you will have to fight them. As a warning, these nanomachines have been known to irratate and annoy animals in testing, as well injecting a cocktail of drugs into them to get their organs outputting at maximum potential.<br>
	<br>
	We operate on a limited budget, but we do provide payment for participating in this project: 0.1% of profits from any products made from this research, and medals showing off your pride for NT and promoting their research.
	<br><hr>
	<font size =\"1\"><i>By participating in this experiment you waive all rights for compensation of death on the job.</font></i>
"}
