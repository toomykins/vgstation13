//Methods that need to be cleaned.
/* INFORMATION
Put (mob/proc)s here that are in dire need of a code cleanup.
*/

// has_disease()/contract_disease() and the whole /datum/disease infection path
// were removed with the legacy disease system. Diseases now live in virus2
// (mob.virus2, infect_disease2 / infect_disease2_predefined).
