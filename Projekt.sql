      
	 /*
	    * ZADÁNÍ ÚKOLŮ
	    * 
	 1.	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
	2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
	3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
	4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
	5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
	projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
	
	  */
   
     
   /*
    * ZVOLENÝ POSTUP
    * 
    * A.)	Prověřím si strukturu databáze, jednotlivých tabulek, jejich ER diagramy, vztahy mezi tabulkami, nulové hodnoty.
    * 		Poznatky z této části dokumentuji v příloženém souboru "Struktura databáze.pdf"
    * B.) 	Vypracovávám úkoly 1.-5. U každého z úkolů postupuju krok za krok, aby bylo zřejmé, 
    * 		jaké kódy jsem zkoušel psát - záměrně jsem si zkusil i vytvořit pohled nebo pracovat s common table expressions
    * C.) 	Vytvořím dodatečné tabulky dle zadání. 
    */
   

   /*
    * KOMENTÁŘ K AKTIVNÍMU (NE)VYUŽÍVÁNÍ GITHUBU
    * 
    * Mojí motivací k účasti na tomto kurzu je naučit se lépe porozumět práci datových analytiků proto, 
    * abych je uměl kvalitněji (fundovaněji) briefovat, lépe uměl odhadnout časovou náročnost pro vypracování zadaných úkolů resp. vůbec realizovatelnost, 
    * potažmo si jednodušší zadání zvládl vypracovat sám. 
    * To je i důvod, proč se nezabývám prací s GitHubem, a odesílám výstup přes „upload“, 
    * protože ve své současné v praxi v roli zadavatele toto nepotřebuji, 
    * a především v současné firmě ani Github nebo podobný nástroj nepoužíváme.
    *  Děkuji tímto za pochopení.
      */
   


   -- Úkol 1, step 1, tabulka, kde budou mzdy, odvětví, roky
    
     SELECT 
  		ROUND (avg(value),0) AS average_salary, 
  		payroll_year, 
  		industry_branch_code
 	FROM czechia_payroll cp 
 	WHERE 
 		value_type_code = '5958' 
 		AND industry_branch_code IS NOT NULL 
 		AND VALUE IS NOT NULL 
 		AND calculation_code = '200'
 	 	GROUP BY industry_branch_code, payroll_year;
 	
 	 
 	 -- Úkol 1, step 2, připojím tabulku industry_codes pro lepší čitelnost
 	 
 	SELECT 
  		ROUND (avg(value),0) AS average_salary, 
  		payroll_year, 
  		cpib.name 
 	FROM czechia_payroll cp 
 	JOIN
 		czechia_payroll_industry_branch cpib ON cpib.code = cp.industry_branch_code 
 	WHERE 
 		value_type_code = '5958' 
 		AND industry_branch_code IS NOT NULL 
 		AND VALUE IS NOT NULL 
 		AND calculation_code = '200'
 	 	GROUP BY industry_branch_code, payroll_year;
 	
 	 
 -- úkol 1, step 3, teď vypíšu meziroční růst mezd, tam kde jsou záporné hodnoty je jasné, že docházelo k poklesu
	SELECT 
  		cpib.name,
  		round ((avg(cp.value)-avg(cp2.value))/avg(cp2.value)*100, 1) AS salary_growth,
  		ROUND (avg(cp.value),0) AS average_salary_current_year, 
  		ROUND (avg(cp2.value),0) AS average_salary_previous_year, 
  		cp.payroll_year AS current_year,
  		cp2.payroll_year AS previous_year
  	FROM czechia_payroll cp 
 	JOIN
 		czechia_payroll_industry_branch cpib ON cpib.code = cp.industry_branch_code 
 	JOIN 
 		czechia_payroll cp2 ON cp.industry_branch_code = cp2.industry_branch_code AND cp.payroll_year = cp2.payroll_year+1 
 	WHERE 
 		cp.value_type_code = '5958' 
 		AND cp.industry_branch_code IS NOT NULL 
 		AND cp.value IS NOT NULL
 		AND cp.calculation_code = '200'
 		GROUP BY cp.industry_branch_code, cp.payroll_year;
 	  

-- úkol 1, step 4, tento dotaz už vypíše jen ty obory, kde došlo někdy v historii k meziročnímu poklesu mezd,
-- ODPOVĚĎ : Ano, jsou obory, u kterých docházelo k poklesu průměrné mzdy.
 SELECT sector_name
 FROM (
 SELECT 
  		cpib.name AS sector_name,
  		round ((avg(cp.value)-avg(cp2.value))/avg(cp2.value)*100, 1) AS salary_growth,
  		ROUND (avg(cp.value),0) AS average_salary_current_year, 
  		ROUND (avg(cp2.value),0) AS average_salary_previous_year, 
  		cp.payroll_year AS current_year,
  		cp2.payroll_year AS previous_year
  	FROM czechia_payroll cp 
 	JOIN
 		czechia_payroll_industry_branch cpib ON cpib.code = cp.industry_branch_code 
 	JOIN 
 		czechia_payroll cp2 ON cp.industry_branch_code = cp2.industry_branch_code AND cp.payroll_year = cp2.payroll_year+1 
 	WHERE 
 		cp.value_type_code = '5958' 
 		AND cp.industry_branch_code IS NOT NULL 
 		AND cp.value IS NOT NULL
 		AND cp.calculation_code = '200'
 		GROUP BY cp.industry_branch_code, cp.payroll_year
 	 ) podminka 
 	WHERE salary_growth<0
 	GROUP BY sector_name;
 	
 	

 -- 2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
  -- úkol 2, step 1, zjištění průměrné ceny mléka a chleba za daná období
 
 
 SELECT 
 	YEAR (date_from) AS year_period, 
 	round (AVG (value),2) AS average_price,
 	cpc.name AS category_name
 	FROM czechia_price cp 
	 	JOIN czechia_price_category cpc 
	 		 ON cp.category_code = cpc.code 
	 	JOIN czechia_region cr 
	 		ON cp.region_code = cr.code 
 	WHERE cp.category_code IN ('114201', '111301') AND region_code IS NOT NULL AND YEAR (date_to) IN ('2006', '2018') 
 	GROUP BY cp.category_code, YEAR (date_to);
  
 -- úkol 2, step 2, je potřeba zjistit průměrné mzdy v letech 2016 a 2018
 
    SELECT 
  		ROUND (avg(value),0) AS average_salary, 
  		payroll_year, unit_code 
 	FROM czechia_payroll cp 
 	WHERE 
 		value_type_code = '5958' 
 		AND value  IS NOT NULL 
 		AND payroll_year IN ('2006', '2018')
 		AND calculation_code = '200'
 	GROUP BY payroll_year;
 

 -- úkol 2, step 3, ke stepu 1 připojím step 2, propojím tabulky na úrovni roku, zkusím využít funkci with
 -- + rovnou dopočítám počty kusů/litrů na průměrnou mzdu v daném roce
 -- ODPOVĚĎ : 1308 ks chleba v roce 2006, 1363 ks chleba v roce 2018, 1460 litrů mléka v roce 2006, 1667 litrů mléka v roce 2018
 
 WITH avg_price_table AS
 	(
 		SELECT 
	 	YEAR (date_from) AS year_period, 
	 	round (AVG (value),2) AS average_price,
	 	cpc.name AS category_name
	 	FROM czechia_price cp 
		 	JOIN czechia_price_category cpc 
		 		 ON cp.category_code = cpc.code 
		 	JOIN czechia_region cr 
		 		ON cp.region_code = cr.code 
	 	WHERE cp.category_code IN ('114201', '111301') AND region_code IS NOT NULL AND YEAR (date_to) IN ('2006', '2018') 
	 	GROUP BY cp.category_code, YEAR (date_from)
	 	)
 SELECT apt.year_period,
 		apt.average_price,
 		apt.category_name,
 		ROUND (avg(cp2.value),0) AS average_salary,
 		ROUND (avg(cp2.value)/apt.average_price,0) AS quantity_to_buy
 		FROM avg_price_table apt
		JOIN czechia_payroll cp2 
		ON cp2.payroll_year = apt.year_period
WHERE 	cp2.value_type_code = '5958' 
 		AND cp2.value  IS NOT NULL 
 		AND cp2.payroll_year IN ('2006', '2018')
 		AND cp2.calculation_code = '200'
	GROUP BY apt.category_name, apt.year_period	;


-- 3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- úkol 3, step 0 - slepá cesta - nepodařilo se mi spojit tabulky přes JOIN, zřejmě proto, že v JOIN se nedá použít počítané pole? tak jsem na to šel přes view... 
-- nebo to jde a mám v kódu níže chybu? 

	SELECT 
		 	cpc.name AS category_name,
		 	YEAR (cp.date_from) AS previous_year,
		 	YEAR (cp2.date_from) AS next_year,
		 	round (AVG (cp.value),2) AS average_price
		 	FROM czechia_price cp 
	JOIN czechia_price_category cpc 
			ON cp.category_code = cpc.code
	JOIN czechia_price cp2
			ON YEAR (cp.date_from)=YEAR(cp2.date_from) + 1 AND cp.category_code =cp2.category_code 
		 	GROUP BY category_name, previous_year
		 	ORDER BY category_name, previous_year DESC;
		 
-- úkol 3, step 1 -  přes pohledy transformuju hodnoty v datumu na rok, odpověď je cukr krystal
-- ODPOVĚĎ : cukr krystal zlevňuje
		 
CREATE OR REPLACE VIEW v_category AS 
SELECT 
		 	cpc.name AS category_name,
		 	YEAR (cp.date_from) AS calculation_year,
		 	round (AVG (cp.value),2) AS average_price
		 	FROM czechia_price cp 
	JOIN czechia_price_category cpc 
			ON cp.category_code = cpc.code
		 	GROUP BY category_name, calculation_year
		 	ORDER BY category_name, calculation_year;


WITH ht AS 
	(
	SELECT
		vc.category_name AS category_name,
		vc.calculation_year AS previous_year,
		vc.average_price AS average_price_py,
		vc2.calculation_year AS following_year, 
		vc2.average_price AS average_price_fy,
		ROUND((vc2.average_price /vc.average_price-1)*100,1) AS percentage_change
		FROM v_category vc
		JOIN v_category vc2 ON vc2.calculation_year = vc.calculation_year+1 AND vc2.category_name = vc.category_name 
	ORDER BY vc.category_name, previous_year
	)
SELECT 
	category_name, 
	ROUND(AVG(ht.percentage_change),2) AS average_yearly_percentage_change
	FROM ht
	GROUP BY ht.category_name
	ORDER BY average_yearly_percentage_change;



-- úkol 4, Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- úkol 4, step 1, tabulka meziročního růstu mezd 

    SELECT 
  		cp2.payroll_year AS previous_year,
  		ROUND (avg(cp2.value),0) AS average_salary_previous_year,
  		cp.payroll_year AS following_year,
  		ROUND (avg(cp.value),0) AS average_salary_following_year,
  		ROUND (((cp.value/cp2.value-1)*100),2) AS percentage_change_salary
 	FROM czechia_payroll cp 
 	JOIN czechia_payroll cp2 
 		ON cp2.payroll_year+1 = cp.payroll_year
 		AND cp2.value_type_code =cp.value_type_code 
 		AND cp2.calculation_code = cp.calculation_code 
 		AND cp2.industry_branch_code = cp.industry_branch_code 
 	WHERE 
 		cp.value_type_code = '5958' 
 		AND cp.value  IS NOT NULL 
 		AND cp.calculation_code = '200'
 	GROUP BY cp.payroll_year, cp2.payroll_year 
 	ORDER BY following_year;

-- úkol 4, step 2, tabulka meziročního růstu cen potravin
 
 CREATE OR REPLACE VIEW v_cat AS 
	SELECT 
		 	YEAR (cp.date_from) AS calculation_year,
		 	round (AVG (cp.value),2) AS average_price
		 	FROM czechia_price cp
		 	GROUP BY calculation_year
		 	ORDER BY calculation_year;

SELECT 
	vcat2.calculation_year AS previous_year,
	vcat2.average_price AS average_price_previous_year,
	vcat.calculation_year AS following_year,
	vcat.average_price AS average_price_following_year,
	ROUND (((vcat.average_price/vcat2.average_price-1)*100),2) AS percentage_change_groceries
	FROM v_cat AS vcat
JOIN v_cat AS vcat2 
	ON vcat.calculation_year = vcat2.calculation_year+1;


-- Úkol 4, step 3, růst platů spojen přes dočasnou tabulku s růstem cen potravin
-- ODPOVĚĎ : vyjádřeno v % bodech, neexistuje rok, kdy by % nárůst potravin byl vyšší než % nárůst mezd o více než 10%pt,
-- maximální diference byla 4,71%pt v roce 2013, kdy ceny potravin rostly o 5,55%, zatímco mzdy o 0,84%
WITH salary_change AS
	(
  SELECT 
  		cp2.payroll_year AS previous_year,
  		ROUND (avg(cp2.value),0) AS average_salary_previous_year,
  		cp.payroll_year AS following_year,
  		ROUND (avg(cp.value),0) AS average_salary_following_year,
  		ROUND (((cp.value/cp2.value-1)*100),2) AS percentage_change_salary
 	FROM czechia_payroll cp 
 	JOIN czechia_payroll cp2 
 		ON cp2.payroll_year+1 = cp.payroll_year
 		AND cp2.value_type_code =cp.value_type_code 
 		AND cp2.calculation_code = cp.calculation_code 
 		AND cp2.industry_branch_code = cp.industry_branch_code 
 	WHERE 
 		cp.value_type_code = '5958' 
 		AND cp.value  IS NOT NULL 
 		AND cp.calculation_code = '200'
 	GROUP BY cp.payroll_year, cp2.payroll_year 
 	ORDER BY following_year
 	),
 	groceries_change AS (
  	SELECT 
	vcat2.calculation_year AS previous_year,
	vcat2.average_price AS average_price_previous_year,
	vcat.calculation_year AS following_year,
	vcat.average_price AS average_price_following_year,
	ROUND (((vcat.average_price/vcat2.average_price-1)*100),2) AS percentage_change_groceries
	FROM v_cat AS vcat
JOIN v_cat AS vcat2 
	ON vcat.calculation_year = vcat2.calculation_year+1
	)
 	SELECT 
 	groceries_change.following_year,
 	groceries_change.percentage_change_groceries,
 	salary_change.percentage_change_salary,
 	groceries_change.percentage_change_groceries-salary_change.percentage_change_salary AS change_groceries_vs_salary
 	FROM salary_change
 	JOIN groceries_change ON
 	groceries_change.following_year=salary_change.following_year;

 	
-- 5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
-- Úkol 5, step 1 - tabulka vývoj HDP
 
 	SELECT
 	 e2.`year` AS previous_year,
 	e2.gdp AS gdp_py,
 	e.`year` AS following_year,
 	e.gdp AS gdp_fy,
 	ROUND (((e.GDP/e2.GDP-1)*100),2) AS percentage_change_GDP
 	FROM economies e 
 	JOIN economies e2 ON
 		e2.`year` + 1 = e.`year` AND 
 		e2.country = e.country 
 	WHERE e.country = 'Czech republic' 
 	AND e.gdp IS NOT NULL 
 	AND e2.gdp IS NOT NULL 
 	ORDER BY e.`year`;
 

 -- Úkol 5, step 2, sloučím tabulky s vývojem HDP a vývojem mezd a cen, rovnou přidám case výraz, 
 -- který mi pomůže odhadnout korelaci mezi výší změny HDP a vývoje mezd a cen

 
WITH salary_change AS
	(
  SELECT 
  		cp2.payroll_year AS previous_year,
  		ROUND (avg(cp2.value),0) AS average_salary_previous_year,
  		cp.payroll_year AS following_year,
  		ROUND (avg(cp.value),0) AS average_salary_following_year,
  		ROUND (((cp.value/cp2.value-1)*100),2) AS percentage_change_salary
 	FROM czechia_payroll cp 
 	JOIN czechia_payroll cp2 
 		ON cp2.payroll_year+1 = cp.payroll_year
 		AND cp2.value_type_code =cp.value_type_code 
 		AND cp2.calculation_code = cp.calculation_code 
 		AND cp2.industry_branch_code = cp.industry_branch_code 
 	WHERE 
 		cp.value_type_code = '5958' 
 		AND cp.value  IS NOT NULL 
 		AND cp.calculation_code = '200'
 	GROUP BY cp.payroll_year, cp2.payroll_year 
 	ORDER BY following_year
 	),
 	groceries_change AS 
 	(
  	SELECT 
	vcat2.calculation_year AS previous_year,
	vcat2.average_price AS average_price_previous_year,
	vcat.calculation_year AS following_year,
	vcat.average_price AS average_price_following_year,
	ROUND (((vcat.average_price/vcat2.average_price-1)*100),2) AS percentage_change_groceries
	FROM v_cat AS vcat
JOIN v_cat AS vcat2 
	ON vcat.calculation_year = vcat2.calculation_year+1
	),
	gdp_change AS 
	(
	SELECT
 	 e2.`year` AS previous_year,
 	e2.gdp AS gdp_py,
 	e.`year` AS following_year,
 	e.gdp AS gdp_fy,
 	ROUND (((e.GDP/e2.GDP-1)*100),2) AS percentage_change_GDP_previous_year
 	FROM economies e 
 	JOIN economies e2 ON
 		e2.`year` + 1 = e.`year` AND 
 		e2.country = e.country 
 	WHERE e.country = 'Czech republic' 
 	AND e.gdp IS NOT NULL 
 	AND e2.gdp IS NOT NULL 
 	ORDER BY e.`year`
 	)
  	SELECT 
 	groceries_change.following_year,
 	groceries_change.percentage_change_groceries,
 	salary_change.percentage_change_salary,
 	gdp_change.percentage_change_GDP_previous_year,
 		-- když vyjde case 1, znamená to, že plat ve stejném roce rostl rychleji než HDP
 		CASE
       		 WHEN salary_change.percentage_change_salary>gdp_change.percentage_change_GDP_previous_year THEN 1 
       		 ELSE 0
   		END AS salary_faster_than_GDP, 
   		CASE
      		  WHEN groceries_change.percentage_change_groceries>gdp_change.percentage_change_GDP_previous_year THEN 1 
       		 ELSE 0
   		 END AS groceries_faster_than_GDP
 	FROM salary_change
 	JOIN groceries_change ON
 	groceries_change.following_year=salary_change.following_year
 	JOIN gdp_change ON
 	gdp_change.following_year=groceries_change.following_year;
 
 -- ODPOVĚĎ : existuje silná korelace mezi růstém HDP a růstem mezd, korelace mezi růstem HDP a růstem cen potravin neprokázákana

 -- V rámci následujícího dotazu posouvám řádky (roky) u mezd a platů tak, abych srovnával růst HDP v daném roce s růstem mezd a platů v roce NÁSLEDUJÍCÍM (!)
  
 WITH salary_change AS
	(
  SELECT 
  		cp2.payroll_year AS previous_year,
  		ROUND (avg(cp2.value),0) AS average_salary_previous_year,
  		cp.payroll_year AS following_year,
  		ROUND (avg(cp.value),0) AS average_salary_following_year,
  		ROUND (((cp.value/cp2.value-1)*100),2) AS percentage_change_salary
 	FROM czechia_payroll cp 
 	JOIN czechia_payroll cp2 
 		ON cp2.payroll_year+1 = cp.payroll_year
 		AND cp2.value_type_code =cp.value_type_code 
 		AND cp2.calculation_code = cp.calculation_code 
 		AND cp2.industry_branch_code = cp.industry_branch_code 
 	WHERE 
 		cp.value_type_code = '5958' 
 		AND cp.value  IS NOT NULL 
 		AND cp.calculation_code = '200'
 	GROUP BY cp.payroll_year, cp2.payroll_year 
 	ORDER BY following_year
 	),
 	groceries_change AS 
 	(
  	SELECT 
	vcat2.calculation_year AS previous_year,
	vcat2.average_price AS average_price_previous_year,
	vcat.calculation_year AS following_year,
	vcat.average_price AS average_price_following_year,
	ROUND (((vcat.average_price/vcat2.average_price-1)*100),2) AS percentage_change_groceries
	FROM v_cat AS vcat
JOIN v_cat AS vcat2 
	ON vcat.calculation_year = vcat2.calculation_year+1
	),
	gdp_change AS 
	(
	SELECT
 	 e2.`year` AS previous_year,
 	e2.gdp AS gdp_py,
 	e.`year` AS following_year,
 	e.gdp AS gdp_fy,
 	ROUND (((e.GDP/e2.GDP-1)*100),2) AS percentage_change_GDP
 	FROM economies e 
 	JOIN economies e2 ON
 		e2.`year` + 1 = e.`year` AND 
 		e2.country = e.country 
 	WHERE e.country = 'Czech republic' 
 	AND e.gdp IS NOT NULL 
 	AND e2.gdp IS NOT NULL 
 	ORDER BY e.`year`
 	)
  	SELECT 
 	groceries_change.following_year,
 	groceries_change.percentage_change_groceries,
 	salary_change.percentage_change_salary,
 	gdp_change.percentage_change_GDP,
 		-- když vyjde case 1, znamená to, že plat v následujícím roce rostl rychleji než HDP
 		CASE
       		 WHEN salary_change.percentage_change_salary>gdp_change.percentage_change_GDP THEN 1 
       		 ELSE 0
   		END AS salary_faster_than_GDP, 
   		CASE
      		  WHEN groceries_change.percentage_change_groceries>gdp_change.percentage_change_GDP THEN 1 
       		 ELSE 0
   		 END AS groceries_faster_than_GDP
 	FROM salary_change
 	JOIN groceries_change ON
 	groceries_change.following_year=salary_change.following_year
 	JOIN gdp_change ON
 	-- TOTO JE JEDINÁ ZMĚNA V DOTAZU, POSUN ŘÁDKŮ, ABYCH MĚL VEDLE SEBE 
 	-- PŘ. RŮST CEN POTRAVIN A MEZD 2009 VS 2008, ALE VE STEJNÉM ŘÁDKU RŮST HDP ZA 2008 VS 2007
 	gdp_change.following_year+1=groceries_change.following_year;
 


   
 -- DODATEČNÉ ÚKOLY - VYTVOŘENÍ TABULEK 
-- Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, 
-- jako primární přehled pro ČR
-- t_Jan_Dvorak_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).

-- Tabulka 2, step 1 ověření propojitelnosti tabulek economies a countries a čaasových obdobích, které je potřeba filtrovat
		-- jediná země, která je v tabulce economies, ale není v tabulce countries, je KOSOVO
 
		SELECT DISTINCT 
			e.country AS Country_economies, 
			c.country AS Country_countries
		FROM economies e
		LEFT JOIN countries c 
			ON c.country = e.country 
		WHERE c.country IS NULL
		ORDER BY e.country;
		
	
-- dotazy na tabulky Economies a Countries
	SELECT *	FROM economies e WHERE country = 'Kosovo';
	SELECT *	FROM countries c;

-- v countries jsou země, které nemají přiřazený continent, ale jsou to země mimo Evropu, takže OK
	SELECT *	FROM countries c WHERE c.continent IS null;


 -- pozor !!! v tabulkách czechia_payroll (2000-2021)
 -- a czechia_price (2006-2018), na které se máme časově párovat, jsou různá časová období !!!
 SELECT DISTINCT payroll_year 
FROM czechia_payroll cp 
ORDER BY payroll_year ;

 SELECT DISTINCT year(date_to)
FROM czechia_price cp  
ORDER BY YEAR(date_to);
	
--  pomocný dotaz, časově omezím na 2000-2021, i když je vidět, že v economies je nejnovější údaj na rok 2020
-- zároveň vyberu jen evropské země a navíc Kosovo
	
	SELECT 
		e.country,
		e.`year`, 
		e.gdp, 
		e.gini, 
		e.population
	FROM economies e
	LEFT JOIN countries c 
			ON c.country = e.country 
		WHERE (c.continent = 'Europe' OR e.country = 'kosovo') 
			AND e.`year` BETWEEN 2000 AND  2021
		GROUP BY e.country, e.`year` 
		ORDER BY e.country, e.`year` ;
	
-- Tabulka 2, step 2, vytvoření tabulky
	
	CREATE OR REPLACE TABLE t_Jan_Dvorak_project_SQL_secondary_final AS 
			SELECT 
		e.country,
		e.`year`, 
		e.gdp, 
		e.gini, 
		e.population
	FROM economies e
	LEFT JOIN countries c 
			ON c.country = e.country 
		WHERE (c.continent = 'Europe' OR e.country = 'kosovo') 
			AND e.`year` BETWEEN 2000 AND  2021
		GROUP BY e.country, e.`year` 
		ORDER BY e.country, e.`year` ;
	
-- Tabulka 2, step 3, test funkčnosti

	SELECT * FROM 	t_Jan_Dvorak_project_SQL_secondary_final;


	
-- Tabulka 1, zadání chápu tak, že tabulka má obsahovat agregovaná data za roky, které jsou společné oběma tabulkám, tzn. 2006-2018
-- a mají to být jen relevantní data, proto volím průměrnou cenu výrobku / kategorii / průměrnou mzdu v daném roce v jednotlivých odvětvích
	 
CREATE OR REPLACE TABLE t_Jan_Dvorak_project_SQL_primary_final AS  
		 SELECT 
		 	YEAR (cp.date_from) AS year_period, 
		 	round (AVG (cp.value),2) AS average_price,
		 	CONCAT (cpc.name, ' ', cpc.price_value, ' ', cpc.price_unit) AS category_name,
		 	ROUND (avg(cpr.value),0) AS average_salary_year_period,
		 	cpib.name AS industry_name
		 FROM czechia_price cp 
		 	JOIN czechia_price_category cpc 
		 		 ON cp.category_code = cpc.code 
		 	JOIN czechia_region cr 
		 		ON cp.region_code = cr.code
		 	JOIN czechia_payroll cpr
		 		ON cpr.payroll_year = YEAR(cp.date_from)
		 	JOIN czechia_payroll_industry_branch cpib 
		 		ON cpib.code = cpr.industry_branch_code 
	 	WHERE 	cp.region_code IS NOT NULL 
	 			AND YEAR (cp.date_to) BETWEEN '2006' AND '2018' 
	 			AND cpr.value_type_code = '5958' 
 				AND cpr.value  IS NOT NULL 
 				AND cpr.calculation_code = '200'
	 	GROUP BY cp.category_code, YEAR (cp.date_from), cpib.name;
	 

 
-- Tabulka 1, step 2, test funkčnosti

SELECT * FROM 	t_Jan_Dvorak_project_SQL_primary_final;




	