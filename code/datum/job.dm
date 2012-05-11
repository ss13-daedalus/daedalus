/**
 * /datum/job.dm
 *
 * Sets up all job descriptions, flags, equipment, et al. for station personnel
 */

//		SECURITY
/datum/job/hos
	title = "Head of Security"
	flag = HOS
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffdddd"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/security (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_sec(H), H.slot_back)
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/hos(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/under/rank/head_of_security(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/armourrigvest(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/jackboots(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/heads/hos(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/gloves/hos(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/HoS(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses/sechud(H), H.slot_glasses)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/gun/energy/gun(H), H.slot_s_store)
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		return 1

/datum/job/warden
	title = "Warden"
	flag = WARDEN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	alt_titles = list( "Jailor" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_sec(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/security(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_sec(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/warden(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/jackboots(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/security(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/armor/vest/warden(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/warden(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/gloves/red(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses/sechud(H), H.slot_glasses)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/device/flash(H), H.slot_l_store)
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		return 1

/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	alt_titles = list("Forensic Technician", "Inspector")

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_sec(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_norm(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/det(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/det_suit(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/detective(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/head/det_hat(H), H.slot_head)
/*		var/obj/item/clothing/mask/cigarette/CIG = new /obj/item/clothing/mask/cigarette(H)
		CIG.light("")
		H.equip_if_possible(CIG, H.slot_wear_mask)	*/
		//Fuck that thing.  --SkyMarshal
		H.equip_if_possible(new /obj/item/clothing/gloves/detective(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/storage/box/evidence(H.back), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/fcardholder(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/device/detective_scanner(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/drinks/dflask(H.back), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/lighter/zippo(H), H.slot_l_store)
//		H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/candy_corn(H), H.slot_h_store)
//		No... just no. --SkyMarshal
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		return 1

/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	alt_titles = list("Constable", "Enforcer", "Peacekeeper")

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_sec(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/security(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_sec(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/security(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/jackboots(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/security(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/gearharness(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/head/secsoft(H), H.slot_head)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/clothing/gloves/red(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), H.slot_s_store)
		H.equip_if_possible(new /obj/item/device/flash(H), H.slot_l_store)
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		return 1

//		ENGINEERING
/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = CHIEF
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/ce(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_eng(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/pda/heads/ce(H), H.slot_l_store)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat/white(H), H.slot_head)
		H.equip_if_possible(new /obj/item/weapon/storage/belt/utility/full(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), H.slot_gloves)
		var/list/wire_index = list(
				"Orange" = 1,
				"Dark red" = 2,
				"White" = 3,
				"Yellow" = 4,
				"Red" = 5,
				"Blue" = 6,
				"Green" = 7,
				"Grey" = 8,
				"Black" = 9,
				"Pink" = 10,
				"Brown" = 11,
				"Maroon" = 12)
		H.mind.store_memory("<b>The door wires are as follows:</b>")
		H.mind.store_memory("<b>Power:</b> [wire_index[airlockIndexToWireColor[2]]] and [wire_index[airlockIndexToWireColor[3]]]")
		H.mind.store_memory("<b>Backup Power:</b> [wire_index[airlockIndexToWireColor[5]]] and [wire_index[airlockIndexToWireColor[6]]]")
		H.mind.store_memory("<b>Door Bolts:</b> [wire_index[airlockIndexToWireColor[4]]]")
		H << "\blue You have memorised the important wires for the vessel.  Use them wisely."
		return 1

/datum/job/engineer
	title = "Station Engineer"
	flag = ENGINEER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	alt_titles = list( "Technician", "Electrician" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_eng(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/engineer(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/orange(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/weapon/storage/belt/utility/full(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(H), H.slot_head)
		H.equip_if_possible(new /obj/item/device/t_scanner(H), H.slot_r_store)
		H.equip_if_possible(new /obj/item/device/pda/engineering(H), H.slot_l_store)
		return 1

/datum/job/atmos
	title = "Atmospheric Technician"
	flag = ATMOSTECH
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_norm(H), H.slot_back)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/atmospheric_technician(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/engineering(H), H.slot_l_store)
		H.equip_if_possible(new /obj/item/weapon/storage/belt/utility/atmostech/(H), H.slot_belt)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/box/engineer(H), H.slot_r_hand)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box/engineer(H.back), H.slot_in_backpack)
		return 1

/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief engineer and research director"
	selection_color = "#fff5cc"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_rob(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_norm(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/roboticist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/engineering(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(H), H.slot_l_hand)
		return 1

//		MEDICAL
/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/cmo(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_med(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chief_medical_officer(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/heads/cmo(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat/cmo(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/device/flashlight/pen(H), H.slot_s_store)
		H.equip_if_possible(new /obj/item/device/healthanalyzer(H), H.slot_r_store)
		return 1

/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	alt_titles = list("Virologist", "Surgeon", "Emergency Medical Technician", "Nurse", "General Practitioner", "M.D.")

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_med(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4)
			if(alt_titles == "Virologist")
				H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_vir(H), H.slot_back)
			else
				H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_med(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/medical(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/medical(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/device/flashlight/pen(H), H.slot_s_store)
		H.equip_if_possible(new /obj/item/device/healthanalyzer(H), H.slot_r_store)
		return 1

/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_gen(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/geneticist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/medical(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat/genetics(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/device/flashlight/pen(H), H.slot_s_store)
		return 1

/*
/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/virologist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/pda/medical(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/mask/surgical(H), H.slot_wear_mask)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/labcoat/virologist(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/device/flashlight/pen(H), H.slot_s_store)
		return 1
*/

/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer and the research director"
	selection_color = "#ffeeff"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_chem(H), H.slot_back)
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chemist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/toxins(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat/chemist(H), H.slot_wear_suit)
		return 1

//		SCIENCE
/datum/job/rd
	title = "Research Director"
	flag = RD
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/rd(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/under/rank/research_director(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/pda/heads/rd(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/clipboard(H), H.slot_l_store)
		return 1

/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	alt_titles = list("Phoron Researcher", "Xenobiologist", "Research Assistant", "PhD")

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_tox(H), H.slot_back)
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_sci(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/under/rank/scientist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/toxins(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat/science(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/mask/gas(H), H.slot_wear_mask)
		H.equip_if_possible(new /obj/item/weapon/tank/oxygen(H), H.slot_l_hand)
		return 1

//		CIVILIAN
//Food
/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list( "Barkeep" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_norm(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/armor/vest(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/under/rank/bartender(H), H.slot_w_uniform)

		if(H.backbag == 1)
			var/obj/item/weapon/storage/box/Barpack = new /obj/item/weapon/storage/box(H)
			H.equip_if_possible(Barpack, H.slot_r_hand)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(H), H.slot_in_backpack)

		return 1

/datum/job/chef
	title = "Chef"
	flag = CHEF
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list("Cook", "Culinary Technician", "Butcher", "Baker" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/clothing/under/rank/chef(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/chef(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/chefhat(H), H.slot_head)
		return 1

/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list( "Farmer", "Hydroponicist", "Aeroponicist" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_hyd(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/hydroponics(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/gloves/botanic_leather(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/apron(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/device/analyzer/plant_analyzer(H), H.slot_s_store)
		return 1

//Cargo
/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list("Logistics Director")

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/qm(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/under/rank/cargo(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/quartermaster(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(H), H.slot_glasses)
		H.equip_if_possible(new /obj/item/weapon/clipboard(H), H.slot_r_store)
		return 1

/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list( "Dockworker", "Warehouser", "Shipping and Receiving Technician" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_cargo(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/under/rank/cargo(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/quartermaster(H), H.slot_belt)
		return 1

/datum/job/mining
	title = "Shaft Miner"
	flag = MINER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list( "Miner", "Digger", "Resource Extraction Specialist" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_mine (H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_eng(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/miner(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/box(H), H.slot_r_hand)
			H.equip_if_possible(new /obj/item/weapon/crowbar(H), H.slot_l_hand)
			H.equip_if_possible(new /obj/item/weapon/satchel(H), H.slot_l_store)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box(H.back), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/weapon/crowbar(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/weapon/satchel(H), H.slot_in_backpack)
		return 1


/*
//Griff
/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/clown(H), H.slot_back)
		H.equip_if_possible(new /obj/item/weapon/storage/box/survival(H.back), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/clothing/under/rank/clown(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/clown_shoes(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/clown(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/mask/gas/clown_hat(H), H.slot_wear_mask)
		H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/bikehorn(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/stamp/clown(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/toy/crayon/rainbow(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/toy/crayonbox(H), H.slot_in_backpack)
		H.mutations |= CLOWN
		return 1



/datum/job/mime
	title = "Mime"
	flag = MIME
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/mime(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/mime(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/gloves/white(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/mask/gas/mime(H), H.slot_wear_mask)
		H.equip_if_possible(new /obj/item/clothing/head/beret(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/suit/suspenders(H), H.slot_wear_suit)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/box/survival(H), H.slot_r_hand)
			H.equip_if_possible(new /obj/item/toy/crayon/mime(H), H.slot_l_store)
			H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), H.slot_l_hand)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box/survival(H.back), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/toy/crayon/mime(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), H.slot_in_backpack)
		H.verbs += /client/proc/mimespeak
		H.verbs += /client/proc/mimewall
		H.mind.special_verbs += /client/proc/mimespeak
		H.mind.special_verbs += /client/proc/mimewall
		H.miming = 1
		return 1
*/

/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list( "Custodian", "Custodial Technician", "Maintanance Technician", "Lighting Specialist" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/clothing/under/rank/janitor(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/janitor(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/device/portalathe(H), H.slot_in_backpack)
		return 1

//More or less assistants
/datum/job/librarian
	title = "Librarian"
	flag = LIBRARIAN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list( "Literary Specialist", "Bibliotechnician" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/clothing/under/suit_jacket/red(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/weapon/barcodescanner(H), H.slot_l_store)
		return 1

var/global/lawyer = 0//Checks for another lawyer
/datum/job/lawyer
	title = "Lawyer"
	flag = LAWYER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list( "Attorney at Law", "Attorney", "esq.", "Public Defender", "Paralegal" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(!lawyer)
			lawyer = 1
			H.equip_if_possible(new /obj/item/clothing/under/lawyer/bluesuit(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/suit/lawyer/bluejacket(H), H.slot_wear_suit)
		else
			H.equip_if_possible(new /obj/item/clothing/under/lawyer/purpsuit(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/suit/lawyer/purpjacket(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/lawyer(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/weapon/storage/briefcase(H), H.slot_l_hand)
		return 1

/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	alt_titles = list( "Counselor", "Apostate", "Reverend", "Pastor", "Advisor" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0

		var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible(H)
		H.equip_if_possible(B, H.slot_l_hand)
		H.equip_if_possible(new /obj/item/device/pda/chaplain(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chaplain(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		spawn(0)
			var/religion_name = "Christianity"
			var/new_religion = input(H, "You are the Chaplain / Counselor / etc. For game mechanics purposes, you need to choose a religion either way. Would you like to change your religion? Default is Christianity, in SPACE.", "Name change", religion_name)

			if ((length(new_religion) == 0) || (new_religion == "Christianity"))
				new_religion = religion_name

			if (new_religion)
				if (length(new_religion) >= 26)
					new_religion = copytext(new_religion, 1, 26)
				new_religion = dd_replacetext(new_religion, ">", "'")
				switch(lowertext(new_religion))
					if("christianity")
						B.name = pick("The Holy Bible","The Dead Sea Scrolls")
					if("satanism")
						B.name = "The Unholy Bible"
					if("cthulu")
						B.name = "The Necronomicon"
					if("islam")
						B.name = "Quran"
					if("scientology")
						B.name = pick("The Biography of L. Ron Hubbard","Dianetics")
					if("chaos")
						B.name = "The Book of Lorgar"
					if("imperium")
						B.name = "Uplifting Primer"
					if("science")
						B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
					else
						B.name = "The Holy Book of [new_religion]"
//			feedback_set_details("religion_name","[new_religion]")

		spawn(1)
			var/deity_name = "Space Jesus"
			var/new_deity = input(H, "Would you like to change your deity? Default is Space Jesus.", "Name change", deity_name)

			if ((length(new_deity) == 0) || (new_deity == "Space Jesus") )
				new_deity = deity_name

			if(new_deity)
				if (length(new_deity) >= 26)
					new_deity = copytext(new_deity, 1, 26)
					new_deity = dd_replacetext(new_deity, ">", "'")
			B.deity_name = new_deity

			var/accepted = 0
			var/outoftime = 0
			spawn(200) // 20 seconds to choose
				outoftime = 1
			var/new_book_style = "Bible"

			while(!accepted)
				if(!B) break // prevents possible runtime errors
				new_book_style = input(H,"Which bible style would you like?") in list("Bible", "Koran", "Scrapbook", "Creeper", "White Bible", "Holy Light", "Athiest", "Tome", "The King in Yellow", "Ithaqua", "Scientology", "the bible melts", "Necronomicon")
				switch(new_book_style)
					if("Koran")
						B.icon_state = "koran"
						B.item_state = "koran"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 4
					if("Scrapbook")
						B.icon_state = "scrapbook"
						B.item_state = "scrapbook"
					if("Creeper")
						B.icon_state = "creeper"
						B.item_state = "syringe_kit"
					if("White Bible")
						B.icon_state = "white"
						B.item_state = "syringe_kit"
					if("Holy Light")
						B.icon_state = "holylight"
						B.item_state = "syringe_kit"
					if("Athiest")
						B.icon_state = "athiest"
						B.item_state = "syringe_kit"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 10
					if("Tome")
						B.icon_state = "tome"
						B.item_state = "syringe_kit"
					if("The King in Yellow")
						B.icon_state = "kingyellow"
						B.item_state = "kingyellow"
					if("Ithaqua")
						B.icon_state = "ithaqua"
						B.item_state = "ithaqua"
					if("Scientology")
						B.icon_state = "scientology"
						B.item_state = "scientology"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 8
					if("the bible melts")
						B.icon_state = "melted"
						B.item_state = "melted"
					if("Necronomicon")
						B.icon_state = "necronomicon"
						B.item_state = "necronomicon"
					else
						// if christian bible, revert to default
						B.icon_state = "bible"
						B.item_state = "bible"
						for(var/area/chapel/main/A in world)
							for(var/turf/T in A.contents)
								if(T.icon_state == "carpetsymbol")
									T.dir = 2

				H:update_clothing() // so that it updates the bible's item_state in his hand

				switch(input(H,"Look at your bible - is this what you want?") in list("Yes","No"))
					if("Yes")
						accepted = 1
					if("No")
						if(outoftime)
							H << "Welp, out of time, buddy. You're stuck. Next time choose faster."
							accepted = 1

			if(ticker)
				ticker.Bible_icon_state = B.icon_state
				ticker.Bible_item_state = B.item_state
				ticker.Bible_name = B.name
//			feedback_set_details("religion_deity","[new_deity]")
//			feedback_set_details("religion_book","[new_book_style]")
		return 1

//		COMMAND STAFF
/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space law"
	selection_color = "#ccccff"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_norm(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/captain(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/pda/captain(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/caphat(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(H), H.slot_glasses)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/id_kit(H), H.slot_r_hand)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/id_kit(H.back), H.slot_in_backpack)
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		world << "<b>[H.real_name] is the captain!</b>"
		return 1

/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	alt_titles = list( "Personnel Director", "Director of Human Resources" )

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/hop(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_norm(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/head_of_personnel(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/heads/hop(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/armor/vest(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/head/helmet(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/gloves/blue(H), H.slot_gloves)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/id_kit(H), H.slot_r_hand)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/id_kit(H.back), H.slot_in_backpack)
		return 1

//		NON-HUMAN
/datum/job/ai
	title = "AI"
	flag = AI
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		return 1

/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		return 1

//		ASSISTANT
/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/clothing/under/color/grey(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		return 1

//		TEMPLATE

// Apparently, a template.
/datum/job

	//The name of the job
	var/title = "NOPE"

	//Bitflags for the job
	var/flag = 0
	var/department_flag = 0

	//Players will be allowed to spawn in as jobs that are set to "Station"
	var/faction = "None"

	//How many players can be this job
	var/total_positions = 0

	//How many players can spawn in as this job
	var/spawn_positions = 0

	//How many players have this job
	var/current_positions = 0

	//Supervisors, who this person answers to directly
	var/supervisors = ""

	//Sellection screen color
	var/selection_color = "#ffffff"

	//List of alternate titles, if any
	var/list/alt_titles

/datum/job/proc/equip(var/mob/living/carbon/human/H)
	return 1
