drop table if exists awarrington.good_governance_penetration;
drop table if exists awarrington.good_governance_totals;
create table awarrington.good_governance_totals as 
select dwid.statecode,
		  'gg_1' as univ_bucket,
      cast(count(dwid.dwid_state)as decimal(18,2)) as "univ_total"
from (select concat(dwid,state) as "dwid_state" from catalist_periodic_install.goodgovernance20210927) um
join (
  select concat(dwid, statecode) as "dwid_state", statecode, vanid from vansync.ppfa_voterfiledwidlookup
) dwid using(dwid_state)
group by 1,2
;

--texts and calls
create temporary table tc as 
select concat(vanid,statecode) as "vanid_state", 
	   statecode, 
       contactscontactid,
       contacttypeid 
       from vansync.ppfa_contactscontacts_vf 
       where contacttypeid in (1,19,133,81,4,81,37,132) and campaignid='29576'
;
--digital
create temporary table d as 
select concat(voter_file_vanid,mstate) as "vanid_state",
      		  mstate as "statecode",
              1 as "contactscontactid",
			      3000 as "contacttypeid"
            from awarrington.digitotal 
;            


create temporary table attempts as
  select 
  			 um.dwid_state,
  			 um.state,
  			 committeeid,
         'gg_1' as univ_bucket,
           case
       		 when cc.texts=0 and cc.digital=0 and cc.calls!=0 then 'called only'
           when cc.texts=0 and cc.digital!=0 and cc.calls=0 then 'digital only'
           when cc.texts!=0 and cc.digital=0 and cc.calls=0 then 'texted only'
           else 'multiple modes' end as "mode",   
           cc.contact                                                        
  from 
 			(select concat(dwid, state) as dwid_state, state from catalist_periodic_install.goodgovernance20210927) um
  left join (
    select concat(dwid, statecode) as dwid_state,statecode, vanid from vansync.ppfa_voterfiledwidlookup) dwid 
    on dwid.dwid_state=um.dwid_state
    and dwid.statecode=um.state
  left join
  (
 select vanid_state,
       statecode,
	   count(*) as "contact",
       count(case when contacttypeid in (37,132) then 1 else null end) as texts,
       count(case when contacttypeid in (1,19,133,81,4,81) then 1 else null end) as calls,
       count(case when contacttypeid=3000 then 1 else null end) as digital 
    from tc
    full outer join d using(vanid_state,statecode,contactscontactid,contacttypeid) 
    group by 1,2
  ) cc
 on cc.vanid=dwid.vanid
 and cc.statecode=dwid.statecode
;


;

drop table if exists awarrington.good_governance_penetration_test;
create table awarrington.good_governance_penetration_test as
select state, 
			 univ_bucket, 
       mode,
       cast(sum(case when contact is null then 1 else 0 end) as decimal(18,2)) as pct_zero,
        cast(sum(case when contact = 1 then 1 else null end) as decimal(18,2)) as pct_one,
        cast(sum(case when contact = 2 then 1 else null end) as decimal(18,2)) as pct_two,
        cast(sum(case when contact = 3 then 1 else null end) as decimal(18,2)) as pct_three,
        cast(sum(case when contact = 4 then 1 else null end) as decimal(18,2)) as pct_four,
        cast(sum(case when contact = 5 then 1 else null end) as decimal(18,2)) as pct_five,
        cast(sum(case when contact>5 then 1 else null end) as decimal(18,2)) as pct_six_more        
from all_attempts
group by 1,2,3,4
order by 1