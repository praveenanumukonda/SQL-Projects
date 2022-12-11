Use CencusProject

Select * from Data1

Select * from Data2

-- number of rows in our dataset

Select count(*) from CencusProject..Data1

Select count(*) from CencusProject..Data2

-- Dataset for Jharkand and Bihar

Select * from CencusProject..Data1 where State in ('Jharkhand', 'Bihar')

-- Total population of India

Select sum(population) Total_population from CencusProject..Data2 

-- Average Growth

select AVG(Growth)*100 avg_growth from Data1 -- For entire country


select state, round((AVG(Growth)*100), 2) avg_growth
from Data1
group by State
order by avg_growth desc


-- Avg Sex ratio

select state, round(AVG(sex_ratio),0) avg_sex_ratio
from Data1
group by state
order by avg_sex_ratio desc

--avg literacy rate

select state, round(AVG(Literacy),0) avg_literacy
from Data1
group by state
having round(AVG(Literacy),0) >90
order by avg_literacy desc

-- top 3 state showing highest growth rate


select top 3 state, round((AVG(Growth)*100), 2) avg_growth
from Data1
group by State
order by avg_growth desc

-- bottom 3 state showing lowest sex rate


select top 3 state, round(AVG(Sex_Ratio), 0) avg_sex_ratio
from Data1
group by State
order by avg_sex_ratio asc


--Top and Bottom 3 states in literacy rate

drop table if exists #top3_state;
select * 
into #top3_state
from 
(select top 3 state, round(AVG(Literacy),0) avg_literacy
from Data1
group by state
order by avg_literacy desc) top3

GO

drop table if exists #bottom3_state;

select * 
into #bottom3_state 
from 
(select top 3 state, round(AVG(Literacy),0) avg_literacy
from Data1
group by state
order by avg_literacy asc) bottom3


Select * from #top3_state
Union
Select * from #bottom3_state


-- States starting with letter 'a'
select distinct state  from CencusProject..Data1
where lower(state) like 'a%' or  LOWER(state) like 'b%'

select distinct state  from CencusProject..Data1
where lower(state) like 'a%' and  LOWER(state) like '%h'




-- ***************** Session-II *************************

select * from CencusProject..Data1

select * from CencusProject..Data2


use CencusProject
-- Calculating Total male and female count by State

select	d.state,
		sum(d.total_males) total_males,
		sum(d.total_females) total_female,
		round(avg(d.male_pct),2) male_pct,
		round(avg(d.female_pct),2) female_pct,
		sum(Population)
from 

	(select	c.district,
			c.state,
			ROUNd(c.Population/(c.sex_ratio +1),0) as total_males,
			ROUND(c.population*c.sex_ratio/(c.sex_ratio +1),0) as total_females,
			ROUNd(c.Population/(c.sex_ratio +1)/c.Population,2)*100 as male_pct,
			ROUND(c.population*c.sex_ratio/(c.sex_ratio +1)/c.Population,2)*100 as female_pct,
			c.Population
	from 
	(select a.district, a.State, a.Sex_Ratio/1000 sex_ratio, b.population
	from Data1 a
	join Data2 b
	on a.District = b.District) c) d
group by state



-- Calculating Total literate and ill-literate persons by State


select	d.State,
		sum(d.literate_person) literate_person ,
		sum(d.illeterate_person) illeterate_person ,
		sum(d.Population) total_population
from
(select	c.District,
		c.State,
		c.literacy_rate * 100 literacy_rate,
		round((c.literacy_rate * c.Population),0) as literate_person,
		round((1-c.literacy_rate) * c.population,0) as illeterate_person,
		c.population
from
(select a.district, a.State, a.Literacy/100 literacy_rate , b.population
	from Data1 a
	join Data2 b
	on a.District = b.District) c) d
group by State



--Population in previous census and overall growth%

use CencusProject


select
e.previous_census_population previous_census_population, e.current_census_population current_census_population, 
round(((e.current_census_population - e.previous_census_population)/e.previous_census_population)*100, 2) overall_growth
from
(select SUM(d.previous_census_population) previous_census_population , sum(d.current_census_population) current_census_population
from
(select c.State, SUM(c.previous_census_population) previous_census_population, sum(c.Population) current_census_population
from
(select a.district, a.State, a.Growth , b.population, round(b.Population/(1+a.Growth),0) previous_census_population
	from Data1 a
	join Data2 b
	on a.District = b.District) c
group by c.State)d)e

--Population Vs Area

select s.total_area/r.previous_census_population previous_census_area, s.total_area/r.current_census_population current_census_area
from 
(select '1' as keyy, n.* 
from 
(select
e.previous_census_population previous_census_population, e.current_census_population current_census_population, 
round(((e.current_census_population - e.previous_census_population)/e.previous_census_population)*100, 2) overall_growth
from
(select SUM(d.previous_census_population) previous_census_population , sum(d.current_census_population) current_census_population
from
(select c.State, SUM(c.previous_census_population) previous_census_population, sum(c.Population) current_census_population
from
(select a.district, a.State, a.Growth , b.population, round(b.Population/(1+a.Growth),0) previous_census_population
	from Data1 a
	join Data2 b
	on a.District = b.District) c
group by c.State)d )e )n ) r
join
(select '1' as keyy, m.* from
(select sum(area_km2) total_area from Data2) m) s
on r.keyy = s.keyy

--Window Function

select a.District, a.State,a.Literacy ,a.rank_order
from 
(select  District,
		State,
		Literacy,
		rank() over(partition by state order by literacy) as rank_order
from Data1) a
where a.rank_order in (1,2,3)
