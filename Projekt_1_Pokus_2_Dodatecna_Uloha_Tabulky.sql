      
	 /*
	PROSÍM, JAKO PRVNÍ SI PŘEČTĚTE PRŮVODNÍ LISTINU (PRUVODNI_LISTINA.PDF).
	DĚKUJI.
	*/
   

   
-- DODATEČNÉ ÚKOLY - VYTVOŘENÍ TABULEK 
 	 	
-- Tabulka 1, zadání chápu tak, že tabulka má obsahovat agregovaná data za roky, které jsou společné oběma tabulkám, tzn. 2006-2018
-- a mají to být jen relevantní data, proto volím průměrnou cenu výrobku / kategorii / průměrnou mzdu v daném roce v jednotlivých odvětvích
	 
CREATE OR REPLACE TABLE t_Jan_Dvorak_project_SQL_primary_final AS  
	SELECT 
	 	YEAR(cp.date_from) 												AS year_period, 
	 	ROUND(AVG (cp.value),2) 										AS average_price,
	 	CONCAT(cpc.name, ' ', cpc.price_value, ' ', cpc.price_unit) 	AS category_name,
	 	ROUND(AVG(cpr.value),0) 										AS average_salary_year_period,
	 	cpib.name 														AS industry_name
	FROM 
	 	czechia_price cp 
	JOIN 
		czechia_price_category cpc 
		ON cp.category_code = cpc.code 
	JOIN 
		czechia_region cr 
		ON cp.region_code = cr.code
	JOIN 
		czechia_payroll cpr
		ON cpr.payroll_year = YEAR(cp.date_from)
	JOIN
		czechia_payroll_industry_branch cpib 
		ON cpib.code = cpr.industry_branch_code 
	WHERE 
	 	cp.region_code IS NOT NULL 
	 	AND YEAR (cp.date_to) BETWEEN '2006' AND '2018' 
	 	AND cpr.value_type_code = '5958' 
 		AND cpr.value  IS NOT NULL 
 		AND cpr.calculation_code = '200'
	GROUP BY 
		cp.category_code, 
		YEAR(cp.date_from),
		cpib.name;
	
	 
-- Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, 
-- jako primární přehled pro ČR
-- t_Jan_Dvorak_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).

-- Tabulka 2, step 1 ověření propojitelnosti tabulek economies a countries a čaasových obdobích, které je potřeba filtrovat
-- Pozn. jediná země, která je v tabulce economies, ale není v tabulce countries, je KOSOVO
 
	SELECT DISTINCT 
		e.country AS Country_economies, 
		c.country AS Country_countries
	FROM 
		economies e
	LEFT JOIN 
		countries c 
		ON c.country = e.country 
	WHERE 
		c.country IS NULL
	ORDER BY 
		e.country;
		


 -- pozor !!! v tabulkách czechia_payroll (2000-2021)
 -- a czechia_price (2006-2018), na které se máme časově párovat, jsou různá časová období !!!
 	SELECT DISTINCT 
 		payroll_year 
	FROM 
		czechia_payroll cp 
	ORDER BY
		payroll_year ;

	SELECT DISTINCT 
		year(date_to)
	FROM
		czechia_price cp  
	ORDER BY
		YEAR(date_to);
	
	
-- Tabulka 2, step 2, vytvoření tabulky
	
	CREATE OR REPLACE TABLE t_Jan_Dvorak_project_SQL_secondary_final AS 
	SELECT 
		e.country,
		e.`year`, 
		e.gdp, 
		e.gini, 
		e.population
	FROM 
		economies e
	LEFT JOIN 
		countries c 
		ON c.country = e.country 
	WHERE
		(c.continent = 'Europe' OR e.country = 'kosovo') 
		AND e.`year` BETWEEN 2000 AND  2021
	GROUP BY 
		e.country,
		e.`year` 
	ORDER BY 
		e.country,
		e.`year`;	