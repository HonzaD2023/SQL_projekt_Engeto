      
	 /*
	PROSÍM, JAKO PRVNÍ SI PŘEČTĚTE PRŮVODNÍ LISTINU (PRUVODNI_LISTINA.PDF).
	DĚKUJI.
	*/
   
 	
 	 
 -- Úkol 1, ZADÁNÍ : Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 -- Úkol 1, step 1, vypíšu meziroční růst mezd, tam kde jsou záporné hodnoty je jasné, že docházelo k poklesu

	SELECT 
  		cpib.name,
  		ROUND((AVG(cp.value)-AVG(cp2.value))/AVG(cp2.value)*100,1) 	AS salary_growth,
  		ROUND(AVG(cp.value),0) 										AS average_salary_current_year, 
  		ROUND(AVG(cp2.value),0) 									AS average_salary_previous_year, 
  		cp.payroll_year 											AS current_year,
  		cp2.payroll_year 											AS previous_year
  	FROM 
  		czechia_payroll cp 
 	JOIN
 		czechia_payroll_industry_branch cpib 
 		ON cpib.code = cp.industry_branch_code 
 	JOIN 
 		czechia_payroll cp2 
 		ON cp.industry_branch_code = cp2.industry_branch_code 
 		AND cp.payroll_year = cp2.payroll_year+1 
 	WHERE 
 		cp.value_type_code = '5958' 
 		AND cp.industry_branch_code IS NOT NULL 
 		AND cp.value IS NOT NULL
 		AND cp.calculation_code = '200'
 	GROUP BY 
 		cp.industry_branch_code, 
 		cp.payroll_year;
 	  

-- Úkol 1, step 2, tento dotaz už vypíše jen ty obory, kde došlo někdy v historii k meziročnímu poklesu mezd,
-- ODPOVĚĎ : Ano, jsou obory, u kterých docházelo k poklesu průměrné mzdy.
 	
 	SELECT 
 		sector_name
	FROM 
	(
 	SELECT 
  		cpib.name 													AS sector_name,
  		ROUND((AVG(cp.value)-AVG(cp2.value))/AVG(cp2.value)*100,1) 	AS salary_growth,
  		ROUND(AVG(cp.value),0) 										AS average_salary_current_year, 
  		ROUND(AVG(cp2.value),0) 									AS average_salary_previous_year, 
  		cp.payroll_year 											AS current_year,
  		cp2.payroll_year 											AS previous_year
  	FROM 
  		czechia_payroll cp 
 	JOIN
 		czechia_payroll_industry_branch cpib 
 		ON cpib.code = cp.industry_branch_code 
 	JOIN 
 		czechia_payroll cp2 
 		ON cp.industry_branch_code = cp2.industry_branch_code 
 		AND cp.payroll_year = cp2.payroll_year+1 
 	WHERE 
 		cp.value_type_code = '5958' 
 		AND cp.industry_branch_code IS NOT NULL 
 		AND cp.value IS NOT NULL
 		AND cp.calculation_code = '200'
 	GROUP BY 
 		cp.industry_branch_code,
 		cp.payroll_year
 	 ) 
 	 	podminka 
 	WHERE 
 		salary_growth<0
 	GROUP BY 
 		sector_name;