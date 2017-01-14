//These are called by the on-screen buttons, adjusting what the victim can and cannot do.
/client/proc/add_gun_icons()
	if(!usr)
		return 1 // This can runtime if someone manages to throw a gun out of their hand before the proc is called.
	screen |= usr.gun_item
	screen |= usr.gun_move
	screen |= usr.gun_radio

/client/proc/remove_gun_icons()
	if(!usr)
		return 1 // Runtime prevention on N00k agents spawning with SMG
	screen -= usr.gun_item
	screen -= usr.gun_move
	screen -= usr.gun_radio