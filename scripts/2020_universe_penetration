drop table if exists catalist_periodic_install.universe_totals_bymode;
drop table if exists catalist_periodic_install.universe_totals;
create table catalist_periodic_install.universe_totals as 
select dwid.statecode,
		case
         when um.gotv is true and um.inoculation is false and um.persuasion is false then 'GOTV Only'
         when um.gotv is false and um.inoculation is true and um.persuasion is false then 'Inoculation Only'
         when um.gotv is false and um.inoculation is false and um.persuasion is true then 'Persuasion Only'
         when um.gotv is true and um.inoculation is true and um.persuasion is false then 'GOTV and Incoculation'
         when um.gotv is true and um.inoculation is false and um.persuasion is true then 'GOTV and Persuasion'
         when um.gotv is false and um.inoculation is true and um.persuasion is true then 'Inoculation and Persuasion'
         when um.gotv is true and um.inoculation is true and um.persuasion is true then 'All'
         end as univ_bucket,
        cast(count(dwid.dwid_state)as decimal(18,2)) as "univ_total"
from catalist_periodic_install.universe_makeup um
left join (
  select concat(dwid, statecode) as "dwid_state", statecode, vanid from vansync.ppfa_voterfiledwidlookup
) dwid using (dwid_state)
group by 1,2
;


create temporary table attempts as
  select 
  			 um.dwid_state,
  			 um.state,
  			 committeeid,
  
  	   case
           when um.gotv is true and um.inoculation is false and um.persuasion is false then 'GOTV Only'
           when um.gotv is false and um.inoculation is true and um.persuasion is false then 'Inoculation Only'
           when um.gotv is false and um.inoculation is false and um.persuasion is true then 'Persuasion Only'
           when um.gotv is true and um.inoculation is true and um.persuasion is false then 'GOTV and Incoculation'
           when um.gotv is true and um.inoculation is false and um.persuasion is true then 'GOTV and Persuasion'
           when um.gotv is false and um.inoculation is true and um.persuasion is true then 'Inoculation and Persuasion'
           when um.gotv is true and um.inoculation is true and um.persuasion is true then 'All'
           end as univ_bucket,
           case
       		 when cc.texts=0 and cc.calls!=0 then 'called only'
           when cc.texts!=0 and cc.calls=0 then 'texted only'
           when cc.texts!=0 and cc.calls!=0 then 'called and texted'
           else 'not contacted' end as "mode",   
           cc.contact                                                        
  from 
 			(select dwid_state, state, gotv, inoculation, persuasion from catalist_periodic_install.universe_makeup) um
  left join (
    select concat(dwid, statecode) as dwid_state,statecode, vanid from vansync.ppfa_voterfiledwidlookup) dwid 

    on dwid.dwid_state=um.dwid_state
    and dwid.statecode=um.state
  left join
  (
 select vanid,
          statecode,
    			committeeid,
                count(*) as "contact",
       count(case when contacttypeid in (37,132) then 1 else null end) as texts,
       count(case when contacttypeid in (1,19,133,81,4,81) then 1 else null end) as calls
    from vansync.ppv_wj_contactscontacts_vf 
    where datecanvassed::date>='06-01-2020'
    and contacttypeid in (1,19,133,81,4,81,37,132)
    group by 1,2,3
  ) cc
 on cc.vanid=dwid.vanid
 and cc.statecode=dwid.statecode


;

drop table if exists catalist_periodic_install.universe_penetration;
create table catalist_periodic_install.universe_penetration as
select attempts.state, 
			 attempts.committeeid,
			 attempts.univ_bucket, 
       attempts.mode,
       cast(sum(case when contact is null then 1 else 0 end) as decimal(18,2)) as pct_zero,
        cast(sum(case when contact = 1 then 1 else null end) as decimal(18,2)) as pct_one,
        cast(sum(case when contact = 2 then 1 else null end) as decimal(18,2)) as pct_two,
        cast(sum(case when contact = 3 then 1 else null end) as decimal(18,2)) as pct_three,
        cast(sum(case when contact = 4 then 1 else null end) as decimal(18,2)) as pct_four,
        cast(sum(case when contact = 5 then 1 else null end) as decimal(18,2)) as pct_five,
        cast(sum(case when contact>5 then 1 else null end) as decimal(18,2)) as pct_six_more        
from attempts
group by 1,2,3,4
order by 1