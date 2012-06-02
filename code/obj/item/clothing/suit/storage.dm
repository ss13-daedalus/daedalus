/obj/item/clothing/suit/storage/gearharness
	name = "gear harness"
	desc = "A simple security harness, used for storing small objects"
	icon_state = "gearharness"
	item_state = "gearharness"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/pepper_spray,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/stun_baton,/obj/item/weapon/handcuffs,/obj/item/barricade_tape_roll/police)
	flags_inv = 0

/obj/item/clothing/suit/storage/armourrigvest
	name = "armour rig vest"
	desc = "An important looking armoured vest, outfitted with pockets."
	icon_state = "armourrigvest"
	item_state = "armourrigvest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/pepper_spray,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/stun_baton,/obj/item/weapon/handcuffs,/obj/item/barricade_tape_roll/police)
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/officer
	name = "officer jacket"
	desc = "An armored jacket used in special operations."
	icon_state = "detective"
	item_state = "det_suit"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.02
	protective_temperature = 1000
	flags = FPRINT | TABLEPASS | SUITSPACE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/stun_baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 0, rad = 0)
	flags_inv = 0

/obj/item/clothing/suit/storage/armoredundersuit
	name = "armoured undersuit"
	desc = "An layer of armor that attaches to clothing, outfitted with pockets."
	icon_state = "invisible"
	item_state = "invisible"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/pepper_spray,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/stun_baton,/obj/item/weapon/handcuffs,/obj/item/barricade_tape_roll/police)
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_inv = 0

