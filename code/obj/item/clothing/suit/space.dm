/obj/item/clothing/suit/space/rig
	name = "engineer HERP suit"
	desc = "A Hazardous Environment Ruggedized Protection suit. Has radiation shielding and is made for use in a vaccuum or other hazardous conditions."
	icon_state = "rig-engineering"
	item_state = "rig_suit"
	protective_temperature = 5000 //For not dieing near a fire, but still not being great in a full inferno
	slowdown = 2
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/satchel,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining DERP suit"
	desc = "A Durable EVA Radiation Protection suit.  Made for use in hazardous conditions."

/obj/item/clothing/suit/space/rig/elite
	icon_state = "rig-white"
	name = "advanced DERP suit"
	desc = "A white Durable EVA Radiation Protection suit.  Made for use in hazardous conditions."
	protective_temperature = 10000

/obj/item/clothing/suit/space/rig/engspace_suit
	name = "engineering space suit"
	icon_state = "engspace_suit"
	item_state = "engspace_suit"

/obj/item/clothing/suit/space/rig/cespace_suit
	name = "chief engineer's space suit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation and fire shielding, and Chief Engineer colours."
	icon_state = "cespace_suit"
	item_state = "cespace_suit"
	protective_temperature = 10000

/obj/item/clothing/suit/space/rig/security
	name = "security DERP suit"
	desc = "A Durable EVA Radiation Protection suit.  Made for use in hazardous conditions, and specially reinforced against structural damage."
	icon_state = "rig-security"
	item_state = "rig-security"
	protective_temperature = 3000
	slowdown = 1
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun/energy/laser, /obj/item/weapon/gun/energy/pulse_rifle, /obj/item/device/flashlight, /obj/item/weapon/tank/emergency_oxygen, /obj/item/weapon/gun/energy/taser, /obj/item/weapon/melee/baton)
