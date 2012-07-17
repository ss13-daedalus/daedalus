/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	throwforce = 1
	w_class = 1.0
	var
		caliber = ""							//Which kind of guns it can be loaded into
		projectile_type = ""//The bullet type to create when New() is called
		obj/item/projectile/BB = null 			//The loaded bullet


	New()
		..()
		if(projectile_type)
			BB = new projectile_type(src)
		pixel_x = rand(-10.0, 10)
		pixel_y = rand(-10.0, 10)
		dir = pick(cardinal)

/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet"

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	caliber = ".50"
	projectile_type = "/obj/item/projectile/bullet"

/obj/item/ammo_casing/a418
	desc = "A .418 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet/suffocationbullet"


/obj/item/ammo_casing/a75
	desc = "A .75 bullet casing."
	caliber = "75"
	projectile_type = "/obj/item/projectile/bullet/gyro"


/obj/item/ammo_casing/a666
	desc = "A .666 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet/cyanideround"


/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet/weakbullet"


/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = "/obj/item/projectile/bullet/weakbullet"


/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = "/obj/item/projectile/bullet/midbullet"


/obj/item/ammo_casing/a12mm
	desc = "A 12mm bullet casing."
	caliber = "12mm"
	projectile_type = "/obj/item/projectile/bullet/midbullet"

