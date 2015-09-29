/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	show_laws(0)
	if(mind)	ticker.mode.remove_cultist(mind)
	if(mind)	ticker.mode.remove_revolutionary(mind)
	if(mind)	ticker.mode.remove_thrall(mind,0)
	if(mind)	ticker.mode.remove_shadowling(mind)
	return
	
/mob/living/silicon/robot/update_hotkey_mode()
	client.hotkeytype = "Cyborg"
	client.hotkeyon = 1
	winset(src, null, "mainwindow.macro=borghotkeymode hotkey_toggle.is-checked=true mapwindow.map.focus=true input.background-color=#F0F0F0")

/mob/living/silicon/robot/update_normal_mode()
	client.hotkeytype = "Cyborg"
	client.hotkeyon = 0
	winset(src, null, "mainwindow.macro=borgmacro hotkey_toggle.is-checked=false input.focus=true input.background-color=#D3B5B5")