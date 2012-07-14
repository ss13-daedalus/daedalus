/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

	Bump(atom/A)
		A.bullet_act(src, def_zone)
		src.life -= 10
		if(life <= 0)
			del(src)
		return

/obj/item/projectile/hivebotbullet
	damage = 5
	damage_type = BRUTE

