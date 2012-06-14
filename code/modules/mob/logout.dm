/mob/Logout()
	log_access("Logout: [key_name(src)]")
	if (admins[src.ckey])
		message_admins("Admin logout: [key_name(src)]")
	src.logged_in = 0
	text2file( "[src.key]: has logged out of the server.", config.fifo_access )

	..()

	return 1
