      
	 /*
	PROSÍM, JAKO PRVNÍ SI PŘEČTĚTE PRŮVODNÍ LISTINU (PRUVODNI_LISTINA.PDF).
	DĚKUJI.
	*/
   
 	 
 -- Úkol 2, ZADÁNÍ : Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
 -- Úkol 2, step 1, zjištění průměrné ceny mléka a chleba za daná období
 
 
 	SELECT 
 		YEAR(date_from) 		AS year_period, 
 		ROUND(AVG(value),2) 	AS average_price,
 		cpc.name 				AS category_name
 	FROM 
 		czechia_price cp 
	JOIN 
		czechia_price_category cpc 
		ON cp.category_code = cpc.code 
	JOIN 
		czechia_region cr 
		ON cp.region_code = cr.code 
 	WHERE 
 		cp.category_code IN ('114201', '111301') 
 		AND region_code IS NOT NULL 
 		AND YEAR(date_to) IN ('2006', '2018') 
 	GROUP BY 
 		cp.category_code,
 		YEAR(date_to);
  
 -- Úkol 2, step 2, je potřeba zjistit průměrné mzdy v letech 2016 a 2018
 
    SELECT 
  		ROUND(AVG(value),0) AS average_salary, 
  		payroll_year, 
  		unit_code 
 	FROM 
 		czechia_payroll cp 
 	WHERE 
 		value_type_code = '5958' 
 		AND value  IS NOT NULL 
 		AND payroll_year IN ('2006', '2018')
 		AND calculation_code = '200'
 	GROUP BY 
 		payroll_year;
 

 -- úkol 2, step 3, ke stepu 1 připojím step 2, propojím tabulky na úrovni roku, zkusím využít funkci with
 -- + rovnou dopočítám počty kusů/litrů na průměrnou mzdu v daném roce
 -- ODPOVĚĎ : 1308 ks chleba v roce 2006, 1363 ks chleba v roce 2018, 1460 litrů mléka v roce 2006, 1667 litrů mléka v roce 2018
 
 	WITH avg_price_table AS
 	(
 		SELECT 
	 		YEAR(date_from) 		AS year_period, 
	 		ROUND(AVG (value),2) 	AS average_price,
	 		cpc.name 				AS category_name
	 	FROM 
	 		czechia_price cp 
		JOIN 
			czechia_price_category cpc 
			ON cp.category_code = cpc.code 
		JOIN 
			czechia_region cr 
			ON cp.region_code = cr.code 
	 	WHERE 
	 		cp.category_code IN ('114201', '111301') 
	 		AND region_code IS NOT NULL 
	 		AND YEAR(date_to) IN ('2006', '2018') 
	 	GROUP BY 
	 		cp.category_code,
	 		YEAR(date_from)
	 	)
 	SELECT 
 		apt.year_period,
 		apt.average_price,
 		apt.category_name,
 		ROUND(AVG(cp2.value),0) 					AS average_salary,
 		ROUND(AVG(cp2.value)/apt.average_price,0) 	AS quantity_to_buy
 	FROM 
 		avg_price_table apt
	JOIN 
		czechia_payroll cp2 
		ON cp2.payroll_year = apt.year_period
	WHERE 
		cp2.value_type_code = '5958' 
 		AND cp2.value  IS NOT NULL 
 		AND cp2.payroll_year IN ('2006', '2018')
 		AND cp2.calculation_code = '200'
	GROUP BY 
		apt.category_name,
		apt.year_period;