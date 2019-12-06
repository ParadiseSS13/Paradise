/obj/item/circuitboard/doppler_array
	name = "Circuit Board (Tachyon-Doppler Array)"
	board_type = "machine"
	build_path = /obj/machinery/doppler_array
	origin_tech = "programming=3;bluespace=2,plasmatech=4"
	frame_desc = "Requires 1 Nano Manipulator and 2 Advanced Scanning Module."
	req_components = list(
						/obj/item/stock_parts/scanning_module/adv = 2,
						/obj/item/stock_parts/manipulator/nano = 1)

/obj/item/circuitboard/doppler_array/range
	name = "Circuit Board (Long Range Tachyon-Doppler Array)"
	build_path = /obj/machinery/doppler_array/range
	origin_tech = "programming=4;bluespace=4,plasmatech=5"
	frame_desc = "Requires 1 Pico Manipulator and 2 Phasic Scanning Module."
	req_components = list(
						/obj/item/stock_parts/scanning_module/phasic = 2,
						/obj/item/stock_parts/manipulator/pico = 1)

