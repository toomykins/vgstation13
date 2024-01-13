/datum/migration/mysql/ss13/_016
	id = 16
	name = "Change jobs to params for more kinds of bans"

/datum/migration/mysql/ss13/_016/up()
	if(!hasColumn("erro_ban","param"))
		var/sql1 = execute("ALTER TABLE erro_ban CHANGE job param varchar(32);");
		return (sql1)
	else
		warning("param column exists. Skipping modification.")

	return TRUE

/datum/migration/mysql/ss13/_016/down()
	if(hasColumn("erro_ban","param"))
		return execute("ALTER TABLE erro_ban CHANGE param job varchar(32);");
	else
		warning("param column does not exist. Skipping revert to job.")

	return TRUE

