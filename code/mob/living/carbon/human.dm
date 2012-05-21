/// EXPERIMENTAL STUFF

/mob/living/carbon/human/var/const
	slot_back = 1
	slot_wear_mask = 2
	slot_handcuffed = 3
	slot_l_hand = 4
	slot_r_hand = 5
	slot_belt = 6
	slot_wear_id = 7
	slot_ears = 8
	slot_glasses = 9
	slot_gloves = 10
	slot_head = 11
	slot_shoes = 12
	slot_wear_suit = 13
	slot_w_uniform = 14
	slot_l_store = 15
	slot_r_store = 16
	slot_s_store = 17
	slot_in_backpack = 18
	slot_h_store = 19

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		del(W)
	return null

/mob/living/carbon/human/proc/equip_if_possible(obj/item/W, slot, del_on_fail = 1) // since byond doesn't seem to have pointers, this seems like the best way to do this :/
	//warning: icky code
	var/equipped = 0
	if((slot == l_store || slot == r_store || slot == belt || slot == wear_id) && !src.w_uniform)
		del(W)
		return
	if(slot == s_store && !src.wear_suit)
		del(W)
		return
	if(slot == h_store && !src.head)
		del(W)
		return
	switch(slot)
		if(slot_back)
			if(!src.back)
				src.back = W
				equipped = 1
		if(slot_wear_mask)
			if(!src.wear_mask)
				src.wear_mask = W
				equipped = 1
		if(slot_handcuffed)
			if(!src.handcuffed)
				src.handcuffed = W
				equipped = 1
		if(slot_l_hand)
			if(!src.l_hand)
				src.l_hand = W
				equipped = 1
		if(slot_r_hand)
			if(!src.r_hand)
				src.r_hand = W
				equipped = 1
		if(slot_belt)
			if(!src.belt)
				src.belt = W
				equipped = 1
		if(slot_wear_id)
			if(!src.wear_id)
				src.wear_id = W
				equipped = 1
		if(slot_ears)
			if(!src.l_ear)
				src.l_ear = W
				equipped = 1
			else if(!src.r_ear)
				src.r_ear = W
				equipped = 1
		if(slot_glasses)
			if(!src.glasses)
				src.glasses = W
				equipped = 1
		if(slot_gloves)
			if(!src.gloves)
				src.gloves = W
				equipped = 1
		if(slot_head)
			if(!src.head)
				src.head = W
				equipped = 1
		if(slot_shoes)
			if(!src.shoes)
				src.shoes = W
				equipped = 1
		if(slot_wear_suit)
			if(!src.wear_suit)
				src.wear_suit = W
				equipped = 1
		if(slot_w_uniform)
			if(!src.w_uniform)
				src.w_uniform = W
				equipped = 1
		if(slot_l_store)
			if(!src.l_store)
				src.l_store = W
				equipped = 1
		if(slot_r_store)
			if(!src.r_store)
				src.r_store = W
				equipped = 1
		if(slot_s_store)
			if(!src.s_store)
				src.s_store = W
				equipped = 1
		if(slot_in_backpack)
			if (src.back && istype(src.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = src.back
				if(B.contents.len < B.storage_slots && W.w_class <= B.max_w_class)
					W.loc = B
					equipped = 1
		if(slot_h_store)
			if(!src.h_store)
				src.h_store = W
				equipped = 1

	if(equipped)
		W.layer = 20
	else
		if (del_on_fail)
			del(W)
	return equipped
/mob/living/carbon/human/proc/create_mind_space_ninja()
	if(mind)
		mind.assigned_role = "MODE"
		mind.special_role = "Space Ninja"
	else
		mind = new
		mind.current = src
		mind.original = src
		mind.assigned_role = "MODE"
		mind.special_role = "Space Ninja"
	if(!(mind in ticker.minds))
		ticker.minds += mind//Adds them to regular mind list.
	if(!(mind in ticker.mode.traitors))//If they weren't already an extra traitor.
		ticker.mode.traitors += mind//Adds them to current traitor list. Which is really the extra antagonist list.
	return 1

/mob/living/carbon/human/proc/equip_space_ninja(safety=0)//Safety in case you need to unequip stuff for existing characters.
	if(safety)
		del(w_uniform)
		del(wear_suit)
		del(wear_mask)
		del(head)
		del(shoes)
		del(gloves)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(src)
	equip_if_possible(R, slot_ears)
	if(gender==FEMALE)
		equip_if_possible(new /obj/item/clothing/under/color/blackf(src), slot_w_uniform)
	else
		equip_if_possible(new /obj/item/clothing/under/color/black(src), slot_w_uniform)
	equip_if_possible(new /obj/item/clothing/shoes/space_ninja(src), slot_shoes)
	equip_if_possible(new /obj/item/clothing/suit/space/space_ninja(src), slot_wear_suit)
	equip_if_possible(new /obj/item/clothing/gloves/space_ninja(src), slot_gloves)
	equip_if_possible(new /obj/item/clothing/head/helmet/space/space_ninja(src), slot_head)
	equip_if_possible(new /obj/item/clothing/mask/gas/voice/space_ninja(src), slot_wear_mask)
	equip_if_possible(new /obj/item/device/flashlight(src), slot_belt)
	equip_if_possible(new /obj/item/weapon/plastique(src), slot_r_store)
	equip_if_possible(new /obj/item/weapon/plastique(src), slot_l_store)
	equip_if_possible(new /obj/item/weapon/tank/emergency_oxygen(src), slot_s_store)
	resistances += "alien_embryo"
	return 1

//=======//HELPER PROCS//=======//

