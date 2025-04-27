clear

//Load the data
cd "C:\Users\mruss\projects\classes\ec204\final_project"

use "data\renamed_rows_final.dta"

rename cp_inflation inflation

* Create a new boolean variable for outliers
gen extreme_inflation = inflation > 200

* Label the new variable for clarity
label variable extreme_inflation "Inflation > 200%"
 
 
//Create the scatter plot of the results
twoway (scatter inflation cpia_macro_rating, sort mcolor(ltblue) msize(3-pt)) if extreme_inflation == 0, ytitle("% Change in Inflation") ymtick(minmax) xtitle("CPIA Macroeconomic Management Rating (1 = Bad, 6 = Great)") title("Macroeconomic Management Quality v Inflation % by Year", span) note("World Bank Data 2005-2016", margin(esubhead))
graph export "C:\Users\mruss\projects\classes\ec204\final_project\Scatter.png", as(png) name("Graph")