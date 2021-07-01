--average PPFA supporters in 2020
create temporary table guys as 
select distinct extract(month from cac.datecreated), count(distinct c.vanid) as "guys"
from vansync.ppfa_contacts_mym c
where cac.datecreated::date>='01-01-2020'
group by 1
;

select avg(guys)
from guys
;

--average PPAF supporters in 2020
create temporary table guys as 
select distinct extract(month from cac.datecreated), count(distinct c.vanid) as "guys"
from vansync.ppfa_contacts_mym c
left join vansync.ppfa_contactsactivistcodes_mym cac using(vanid)
where cac.datecreated::date>='01-01-2020'
and activistcodeid='4132411'
group by 1
;

select avg(guys)
from guys
;

--PPAF supporters that are BIPOC by percentage 
select distinct cat.race, count(distinct c.vanid) as "guys"
from vansync.ppfa_contacts_mym c
left join vansync.catalist_appends_mym cat 
on c.vanid=cat.vanid
left join vansync.ppfa_contactsactivistcodes_mym cac 
on c.vanid=cac.vanid 
where cac.datecreated::date>='01-01-2020'
and activistcodeid='4132411'
group by 1

--volunteer leaders 

create temporary table guys as 
SELECT distinct extract(month from date_time::date),
   COUNT (DISTINCT tar.vanid) as "guys"
   FROM targets_final.change_tracker tar
   left join vansync.ppfa_contactsactivistcodes_mym cac using(vanid)
   WHERE tar.new_target='4 - Vol Leaders'
   AND date_time::date >='01-01-2020'
	and activistcodeid='4132411'
    group by 1
;
select avg(guys)
from guys

create temporary table guys as 
SELECT distinct extract(month from date_time::date),
   cat.race,
   COUNT (DISTINCT tar.vanid) as "guys"
   FROM targets_final.change_tracker tar
   left join vansync.catalist_appends_mym cat 
on tar.vanid=cat.vanid
   WHERE tar.new_target='4 - Vol Leaders'
   AND date_time::date >='01-01-2020'
    group by 1,2
;
select race, avg(guys)
from guys
group by 1