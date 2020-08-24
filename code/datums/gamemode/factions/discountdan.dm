/datum/faction/discountdan
	name = "Discount Dan"
	desc = "Best-quality food and drinks!"
	ID = DISCOUNTDAN
	required_pref = DDANREP
	initial_role = DDANREP
	late_role = DDANOP
	initroletype = /datum/role/ddanrep
	roletype = /datum/role/ddanop
	logo_state = "discount-logo"
	hud_icons = list("discount-logo")

///datum/faction/discountdan/ddanop/OnPostSetup()



/datum/faction/discountdan/OnPostSetup()

/datum/map_element/dungeon/discountshuttle
	file_path = "maps/misc/discountshuttle.dmm"
	unique = TRUE

/datum/faction/discountdan/New()
	..()
	load_dungeon(/datum/map_element/dungeon/discountshuttle)
	discount_shuttle.initialize()
