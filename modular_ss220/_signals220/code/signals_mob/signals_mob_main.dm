// Signals for /mob
// Вызов сигнала при экипировке любой вещи
/mob/equip_to_slot(obj/item/W, slot, initial = FALSE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_MOB_ON_EQUIP, W, slot, initial)

// Вызов сигнала при повоторе через ctrl+wasd
/mob/facedir(ndir)
	. = ..()
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, ndir)

// Вызов сигнала при повороте через ЛКМы
/mob/ClickOn(atom/A, params)
	. = ..()
	SEND_SIGNAL(src, COMSIG_MOB_ON_CLICK, A, params)

// Расширение для пристегивания моба
/mob/MouseDrop(mob/M as mob, src_location, over_location, src_control, over_control, params)
	if((M != usr) || !istype(M))
		..()
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(IsFrozen(src) && !is_admin(usr))
		to_chat(usr, span_boldannounce("Interacting with admin-frozen players is not permitted."))
		return
	if((SEND_SIGNAL(usr, COMSIG_GADOM_CAN_GRAB) & GADOM_CAN_GRAB))
		SEND_SIGNAL(usr, COMSIG_GADOM_LOAD, usr, src)
		return
	. = ..()
