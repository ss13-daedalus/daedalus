/obj/item/weapon/storage/box/stealth/
	name = "Infiltration Gear"
	desc = "An old box full of old equipment.  It doesn't look like it was ever opened."


/obj/item/weapon/storage/box/stealth/New()
	..()

	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/mask/gas/voice(src)
	new /obj/item/weapon/card/id/syndicate(src)
	new /obj/item/clothing/shoes/syndigaloshes(src)
	return


