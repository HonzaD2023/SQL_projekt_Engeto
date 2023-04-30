      
	 /*
	PROSÍM, JAKO PRVNÍ SI PŘEČTĚTE PRŮVODNÍ LISTINU (PRUVODNI_LISTINA.PDF).
	DĚKUJI.
	*/
   
 
-- Úkol 4, ZADÁNÍ :  Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- úkol 4, step 1, tabulka meziročního růstu mezd 

    SELECT 
  		cp2.payroll_year 						AS previous_year,
  		ROUND (AVG(cp2.value),0) 				AS average_salary_previous_year,
  		cp.payroll_year 						AS following_year,
  		ROUND (AVG(cp.value),0) 				AS average_salary_following_year,
  		ROUND (((cp.value/cp2.value-1)*100),2) 	AS percentage_change_salary
 	FROM 
 		czechia_payroll cp 
 	JOIN 
 		czechia_payroll cp2 
 		ON cp2.payroll_year+1 = cp.payroll_year
 		AND cp2.value_type_code = cp.value_type_code 
 		AND cp2.calculation_code = cp.calculation_code 
 		AND cp2.industry_branch_code = cp.industry_branch_code 
 	WHERE 
 		cp.value_type_code = '5958' 
 		AND cp.value  IS NOT NULL 
 		AND cp.calculation_code = '200'
 	GROUP BY 
 		cp.payroll_year,
 		cp2.payroll_year 
 	ORDER BY
 		following_year;

-- úkol 4, step 2, pohled meziročního růstu cen potravin
 
 CREATE OR REPLACE VIEW v_cat AS 
	SELECT 
		YEAR(cp.date_from) 		AS calculation_year,
		ROUND(AVG(cp.value),2) AS average_price
	FROM 
		czechia_price cp
	GROUP BY 
		calculation_year
	ORDER BY 
		calculation_year;

	SELECT 
		vcat2.calculation_year 										AS previous_year,
		vcat2.average_price 										AS average_price_previous_year,
		vcat.calculation_year 										AS following_year,
		vcat.average_price 											AS average_price_following_year,
		ROUND(((vcat.average_price/vcat2.average_price-1)*100),2) 	AS percentage_change_groceries
	FROM 
		v_cat AS vcat
	JOIN 
		v_cat AS vcat2 
		ON vcat.calculation_year = vcat2.calculation_year+1;


-- Úkol 4, step 3, růst platů spojen přes dočasnou tabulku s růstem cen potravin
-- ODPOVĚĎ : vyjádřeno v % bodech, neexistuje rok, kdy by % nárůst potravin byl vyšší než % nárůst mezd o více než 10%pt,
-- maximální diference byla 4,71%pt v roce 2013, kdy ceny potravin rostly o 5,55%, zatímco mzdy o 0,84%
WITH salary_change AS
	(
	SELECT 
	  	cp2.payroll_year 						AS previous_year,
	  	ROUND(AVG(cp2.value),0) 				AS average_salary_previous_year,
	  	cp.payroll_year 						AS following_year,
	  	ROUND(AVG(cp.value),0) 					AS average_salary_following_year,
	  	ROUND(((cp.value/cp2.value-1)*100),2) 	AS percentage_change_salary
	 FROM 
	 	czechia_payroll cp 
	 JOIN 
	 	czechia_payroll cp2 
	 	ON cp2.payroll_year+1 = cp.payroll_year
	 	AND cp2.value_type_code =cp.value_type_code 
	 	AND cp2.calculation_code = cp.calculation_code 
	 	AND cp2.industry_branch_code = cp.industry_branch_code 
	 WHERE 
	 	cp.value_type_code = '5958' 
	 	AND cp.value  IS NOT NULL 
	 	AND cp.calculation_code = '200'
	 GROUP BY 
	 	cp.payroll_year, 
	 	cp2.payroll_year 
	 ORDER BY 
	 	following_year
 	),
 	groceries_change AS 
 	(
  	SELECT 
		vcat2.calculation_year 										AS previous_year,
		vcat2.average_price 										AS average_price_previous_year,
		vcat.calculation_year 										AS following_year,
		vcat.average_price 											AS average_price_following_year,
		ROUND(((vcat.average_price/vcat2.average_price-1)*100),2) 	AS percentage_change_groceries
	FROM 
		v_cat AS vcat
	JOIN 
		v_cat AS vcat2 
		ON vcat.calculation_year = vcat2.calculation_year+1
	)
 	SELECT 
 		groceries_change.following_year,
 		groceries_change.percentage_change_groceries,
 		salary_change.percentage_change_salary,
 		groceries_change.percentage_change_groceries-salary_change.percentage_change_salary AS change_groceries_vs_salary
 	FROM 
 		salary_change
 	JOIN
 		groceries_change ON
 		groceries_change.following_year=salary_change.following_year;