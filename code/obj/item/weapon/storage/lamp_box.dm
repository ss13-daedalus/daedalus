// a box of replacement lamps

/obj/item/weapon/storage/lamp_box
	name = "replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots=21
	can_hold = list("/obj/item/weapon/lamp/tube", "/obj/item/weapon/lamp/bulb")
	max_combined_w_class = 21

/obj/item/weapon/storage/lamp_box/bulbs/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/lamp/bulb(src)

/obj/item/weapon/storage/lamp_box/tubes
	name = "replacement tubes"
	icon_state = "lighttube"

/obj/item/weapon/storage/lamp_box/tubes/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/lamp/tube(src)

/obj/item/weapon/storage/lamp_box/mixed
	name = "replacement lights"
	icon_state = "lightmixed"

/obj/item/weapon/storage/lamp_box/mixed/New()
	..()
	for(var/i = 0; i < 14; i++)
		new /obj/item/weapon/lamp/tube(src)
	for(var/i = 0; i < 7; i++)
		new /obj/item/weapon/lamp/bulb(src)
