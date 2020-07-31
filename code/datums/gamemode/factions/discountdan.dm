/datum/faction/discountdan
	name = "Discount Dan"
	desc = "Best-quality food and drinks!"
	ID = DDANOP
	required_pref = DDANOP
	initial_role = MALF
	late_role = MALFBOT
	initroletype = /datum/role/malfAI //First addition should be the AI
	roletype = /datum/role/malfbot //Then anyone else should be bots
	logo_state = "discount-logo"
	var/apcs = 0
	var/AI_win_timeleft = 1800
	playlist = "malfdelta"
	// for statistics
	stat_datum_type = /datum/stat/faction/malf