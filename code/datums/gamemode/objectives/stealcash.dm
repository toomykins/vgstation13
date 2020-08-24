/datum/objective/stealcash
	var/cash_objective =  50000
	explanation_text = "Steal 50000 spacebucks."
	var/datum/money_account/discdanacc
	name = "Steal Cash"

/datum/objective/stealcash/PostAppend()
	cash_objective =  pick(list(50000,60000,70000))
	discdanacc = create_account("DISorganization for acCOUNTing for DANish polarbears INC.",0,FALSE,0,1,TRUE)
	explanation_text = "Deposit [cash_objective] spacebucks into account number [discdanacc.account_number]."
	return TRUE

/datum/objective/stealcash/IsFulfilled()
	if (..())
		return TRUE

	if (discdanacc && discdanacc.money && discdanacc.money >= cash_objective)
		return TRUE

	return FALSE