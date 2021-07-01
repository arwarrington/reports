--members
create temporary table membs as (
SELECT distinct c.vanid, gm.membership
FROM vansync.ppfa_contacts_mym c
JOIN ppfa_golden.current_customer_graph ccg
    	on c.vanid=ccg.source_primary_key
JOIN ppfa_golden.golden_membership gm
    	on ccg.resolved_id=gm.ppid
WHERE gm.active='Y'
and gm.start_date>='01-01-2018'
  );

--all c4 supporters that are not members 
create temporary table everybody as (
  SELECT distinct vanid, 'c4 supporter' as "membership" from vansync.condef where conid='42' and vanid not in (select vanid from membs)
  UNION 
  (select * from membs));

--table of events ranked by most recent   
  create temporary table events as (
  select vanid, eventid, rank () over (partition by vanid order by datetimeoffsetbegin desc)
  from everybody 
  join vansync.ppfa_eventsignups_mym es using (vanid)
  join (select eventsignupid from vansync.ppfa_eventsignupsstatuses_mym where eventstatusname in ('Completed','Scheduled','Walk In')) ess using(eventsignupid) 
    );
  
  

drop table if exists awarrington.membership_events; 
create table awarrington.membership_events as (
select membership, e.eventcalendarname, count(distinct ev.vanid)
from everybody ev
left join (select * from events where rank=1) es using(vanid)
left join vansync.ppfa_events_mym e using(eventid)
group by 1,2
  );