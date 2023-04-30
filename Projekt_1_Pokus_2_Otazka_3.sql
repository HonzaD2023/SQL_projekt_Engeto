      
	 /*
	PROSÍM, JAKO PRVNÍ SI PŘEČTĚTE PRŮVODNÍ LISTINU (PRUVODNI_LISTINA.PDF).
	DĚKUJI.
	*/
   
 	
-- Úkol 3, ZADÁNÍ : Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- úkol 3, step 1 -  přes pohledy transformuju hodnoty v datumu na rok, odpověď je cukr krystal
-- ODPOVĚĎ : cukr krystal zlevňuje
		 
	CREATE OR REPLACE VIEW v_category AS 
	SELECT 
		cpc.name 					AS category_name,
		YEAR(cp.date_from) 			AS calculation_year,
		ROUND (AVG(cp.value),2) 	AS average_price
	FROM 
		czechia_price cp 
	JOIN 
		czechia_price_category cpc 
		ON cp.category_code = cpc.code
	GROUP BY 
		category_name,
		calculation_year
	ORDER BY
		category_name,
		calculation_year;


	WITH ht AS 
	(
	SELECT
		vc.category_name 										AS category_name,
		vc.calculation_year 									AS previous_year,
		vc.average_price 										AS average_price_py,
		vc2.calculation_year 									AS following_year, 
		vc2.average_price 										AS average_price_fy,
		ROUND((vc2.average_price /vc.average_price-1)*100,1) 	AS percentage_change
	FROM 
		v_category vc
	JOIN 
		v_category vc2 
		ON vc2.calculation_year = vc.calculation_year+1 
		AND vc2.category_name = vc.category_name 
	ORDER BY 
		vc.category_name,
		previous_year
	)
	SELECT 
		category_name, 
		ROUND(AVG(ht.percentage_change),2) AS average_yearly_percentage_change
	FROM 
		ht
	GROUP BY 
		ht.category_name
	ORDER BY 
		average_yearly_percentage_change;