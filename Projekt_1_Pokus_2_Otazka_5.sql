      
	 /*
	PROSÍM, JAKO PRVNÍ SI PŘEČTĚTE PRŮVODNÍ LISTINU (PRUVODNI_LISTINA.PDF).
	DĚKUJI.
	*/
   
 	
 	
-- Úkol 5, ZADÁNÍ : Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
-- Úkol 5, step 1 - tabulka vývoj HDP
 
 	SELECT
	 	e2.`year` 							AS previous_year,
	 	e2.gdp 								AS gdp_py,
	 	e.`year` 							AS following_year,
	 	e.gdp 								AS gdp_fy,
	 	ROUND(((e.GDP/e2.GDP-1)*100),2) 	AS percentage_change_GDP
 	FROM 
 		economies e 
 	JOIN 
 		economies e2 
 		ON e2.`year` + 1 = e.`year` 
 		AND	e2.country = e.country 
 	WHERE 
 		e.country = 'Czech republic' 
 		AND e.gdp IS NOT NULL 
 		AND e2.gdp IS NOT NULL 
 	ORDER BY 
 		e.`year`;
 

-- Úkol 5, step 2, sloučím tabulky s vývojem HDP a vývojem mezd a cen, rovnou přidám case výraz, 
-- který mi pomůže odhadnout korelaci mezi výší změny HDP a vývoje mezd a cen
-- když vyjde case 1, znamená to, že plat ve stejném roce rostl rychleji než HDP

 
WITH salary_change AS
	(
  SELECT 
  	cp2.payroll_year 						AS previous_year,
  	ROUND(AVG(cp2.value),0) 				AS average_salary_previous_year,
  	cp.payroll_year							AS following_year,
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
	),
	gdp_change AS 
	(
	SELECT
	 	e2.`year` 							AS previous_year,
	 	e2.gdp 								AS gdp_py,
	 	e.`year` 							AS following_year,
	 	e.gdp 								AS gdp_fy,
	 	ROUND (((e.GDP/e2.GDP-1)*100),2) 	AS percentage_change_GDP_previous_year
 	FROM 
 		economies e 
 	JOIN 
 		economies e2 
 		ON e2.`year` + 1 = e.`year` 
 		AND e2.country = e.country 
 	WHERE 
 		e.country = 'Czech republic' 
 		AND e.gdp IS NOT NULL 
 		AND e2.gdp IS NOT NULL 
 	ORDER BY 
 		e.`year`
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
 	FROM 
 		salary_change
 	JOIN
 		groceries_change 
 		ON groceries_change.following_year=salary_change.following_year
 	JOIN 
 		gdp_change 
 		ON gdp_change.following_year=groceries_change.following_year;

 	
 	
 -- V rámci následujícího dotazu posouvám řádky (roky) u mezd a platů tak, abych srovnával růst HDP v daném roce s růstem mezd a platů v roce NÁSLEDUJÍCÍM (!)
  
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
		ROUND (((vcat.average_price/vcat2.average_price-1)*100),2) 	AS percentage_change_groceries
	FROM 
		v_cat AS vcat
	JOIN 
		v_cat AS vcat2 
		ON vcat.calculation_year = vcat2.calculation_year+1
	),
	gdp_change AS 
	(
	SELECT
	 	e2.`year` 							AS previous_year,
	 	e2.gdp 								AS gdp_py,
	 	e.`year` 							AS following_year,
	 	e.gdp 								AS gdp_fy,
	 	ROUND(((e.GDP/e2.GDP-1)*100),2) 	AS percentage_change_GDP
 	FROM 
 		economies e 
 	JOIN 
 		economies e2 
 		ON e2.`year` + 1 = e.`year`
 		AND	e2.country = e.country 
 	WHERE 
 		e.country = 'Czech republic' 
 		AND e.gdp IS NOT NULL 
 		AND e2.gdp IS NOT NULL 
 	ORDER BY 
 		e.`year`
 	)
  	SELECT 
	 	groceries_change.following_year,
	 	groceries_change.percentage_change_groceries,
	 	salary_change.percentage_change_salary,
	 	gdp_change.percentage_change_GDP,
 		-- když vyjde case 1, znamená to, že plat v následujícím roce rostl rychleji než HDP
 		CASE
       		 WHEN salary_change.percentage_change_salary > gdp_change.percentage_change_GDP THEN 1 
       		 ELSE 0
   		END AS salary_faster_than_GDP, 
   		CASE
      		  WHEN groceries_change.percentage_change_groceries>gdp_change.percentage_change_GDP THEN 1 
       		 ELSE 0
   		 END AS groceries_faster_than_GDP
 	FROM 
 		salary_change
 	JOIN 
 		groceries_change 
 		ON 	groceries_change.following_year=salary_change.following_year
 	JOIN 
 		gdp_change ON
 	-- TOTO JE JEDINÁ ZMĚNA V DOTAZU, POSUN ŘÁDKŮ, ABYCH MĚL VEDLE SEBE 
 	-- PŘ. RŮST CEN POTRAVIN A MEZD 2009 VS 2008, ALE VE STEJNÉM ŘÁDKU RŮST HDP ZA 2008 VS 2007
 		gdp_change.following_year+1 = groceries_change.following_year;
 

 /*
 
 ODPOVĚĎ NA ÚLOHU 5
 
 1.	Část – zda růst HDP v jednom roce se projeví výraznějším růstem mezd nebo potravin ve stejném roce

•	Existuje velmi silná korelace mezi růstem HDP a růstem mezd – v 11-ti ze 12-ti období rostly mzdy více než HDP
•	Existuje velmi slabá korelace mezi růstem HDP a růstem cen potravin -– pouze v 6-ti ze 12ti období rostly ceny potravin více než HDP

2.	Část – zda růst HDP v jednom roce se projeví výraznějším růstem mezd nebo potravin v následujícím roce

•	Existuje silná korelace mezi růstem HDP a růstem mezd – v 9-ti ze 12-ti období rostly mzdy více než HDP
•	Existuje velmi slabá korelace mezi růstem HDP a růstem cen potravin -– pouze v 7-ti ze 12ti období rostly ceny potravin více než HDP

*/
