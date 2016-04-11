/obj/machinery/computer/decryption
	name="Data-Decryption Console"
	desc="This console is used to analyse and decrypt data found from various sources"
	icon = 'icons/obj/computer.dmi'
	icon_screen = "dna"
	icon_keyboard = "med_key"
	density = 1
	req_access = list(access_research)
	var/obj/item/weapon/book/databook/databook// Currently loaded databook.
	var/init = 1

	var/A
	var/unsolvedA

	var/B
	var/unsolvedB

	var/C
	var/unsolvedC

	var/D
	var/unsolvedD

	var/E
	var/unsolvedE


/obj/machinery/computer/decryption/New()
	..()


/obj/machinery/computer/decryption/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/decryption/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/book/databook))
		if(databook)
			user << "There already is a book inside."
			return
		else
			user.drop_item(W)
			W.loc = src
			databook = W
			user << "You load [W] into [src]."
			return

/obj/machinery/computer/decryption/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/decryption/interact(mob/user)
	ui_interact(user)

// only open when book is inside, need fixin
/obj/machinery/computer/decryption/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	var/data[0]


	data["bookTitle"]=databook.name


	data["keyA"]=databook.keyfragA
	data["keyB"]=databook.keyfragB
	data["keyC"]=databook.keyfragC
	data["keyD"]=databook.keyfragD
	data["keyE"]=databook.keyfragE

	data["init"]= 1
	if(init == 0)
		data["init"]=0

	data["unsolvedA"]=unsolvedA
	data["unsolvedB"]=unsolvedB
	data["unsolvedC"]=unsolvedC
	data["unsolvedD"]=unsolvedD
	data["unsolvedE"]=unsolvedE

	if (data["init"]== 1)
		data["selectedkeyA"]="None."
	if(A)
		data["selectedkeyA"]=A


	if (data["init"]== 1)
		data["selectedkeyB"]="None."
	if(B)
		data["selectedkeyB"]=B


	if (data["init"]== 1)
		data["selectedkeyC"]="None."
	if(C)
		data["selectedkeyC"]=C


	if (data["init"]== 1)
		data["selectedkeyD"]="None."
	if(D)
		data["selectedkeyD"]=D


	if (data["init"]== 1)
		data["selectedkeyE"]="None."
	if(E)
		data["selectedkeyE"]=E

    // update the ui with data if it exists, returns null if no ui is passed/found or if force_open is 1/true
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "Decryption.tmpl", "Decryption", 550, 655)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)



/obj/machinery/computer/decryption/Topic(href, href_list)
	if(..())
		return 1


	if(href_list["eject_book"])
		if(!databook) return
		databook.loc = get_turf(src)
		visible_message("\icon[src] [src] open ups and slowly ejects out [databook].")
		databook = null


	if(href_list["change_alpha"])
		unsolvedA = input("Select cypher key fragment Alpha","Key fragment Alpha",A) in databook.keyfraglist

	if(href_list["change_beta"])
		unsolvedB = input("Select cypher key fragment Beta","Key fragment Beta",B) in databook.keyfraglist

	if(href_list["change_gamma"])
		unsolvedC = input("Select cypher key fragment Gamma","Key fragment Gamma",C) in databook.keyfraglist

	if(href_list["change_delta"])
		unsolvedD = input("Select cypher key fragment Delta","Key fragment Delta",D) in databook.keyfraglist

	if(href_list["change_epsilon"])
		unsolvedE = input("Select cypher key fragment Epsilon","Key fragment Epsilon",E) in databook.keyfraglist

	if(href_list["solve"])
		if(unsolvedA== null||unsolvedB== null||unsolvedC== null||unsolvedD== null||unsolvedE == null)
			init = 1
		else
			init = 0
			A = unsolvedA
			B = unsolvedB
			C = unsolvedC
			D = unsolvedD
			E = unsolvedE

	usr.set_machine(src)
	src.add_fingerprint(usr)
