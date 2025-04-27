/* Regression and table generation do file */
clear
cd "C:\Users\mruss\projects\classes\ec204\final_project" //Absolute File Path Sorry
use data\renamed_rows_final.dta

//Generate Helper Columns for Different Models
gen macro_rating_sq = cpia_macro_rating * cpia_macro_rating
gen log_macro_rating = log(cpia_macro_rating)
gen log_inf_perc = log(cp_inflation_perc)


//Start Regressions
encode country_code, gen(country)
xtset country year

//-----------------Fixed Effects Modeling---------------------

//Basic Linear
xtreg inflation cpia_macro_rating,r fe
outreg2 using no_ovb.doc, replace adjr2

//Basic Quadratic
xtreg inflation cpia_macro_rating macro_rating_sq, r fe
outreg2 using no_ovb.doc, adjr2

//Basic Logrithmic
xtreg inflation log_macro_rating, r fe
outreg2 using no_ovb.doc, adjr2

//-----------Controlling for OVB 
//Testing (Note extra variables added as I discovered OVBs)

//No sig change
xtreg inflation cpia_macro_rating gdp_pc_growth  , r fe
xtreg inflation cpia_macro_rating gdp_constant  , r fe
//Sig Change (But 1/3 of the number of observatiosn)
xtreg inflation cpia_macro_rating  dmstc_crdt_financial export_volume  depth_of_credit , r fe
//No sig change
xtreg inflation cpia_macro_rating  dmstc_crdt_financial export_volume  depth_of_credit electricity_access, r fe
//Not enough observations to make conclusions
xtreg inflation cpia_macro_rating  dmstc_crdt_financial export_volume  depth_of_credit informal_payments , r fe


//Final Table
xtreg inflation cpia_macro_rating, r fe
outreg2 using regression_results.doc, replace adjr2

xtreg inflation cpia_macro_rating cpia_avg_rating, r fe
outreg2 using regression_results.doc, adjr2

xtreg inflation cpia_macro_rating cpia_avg_rating dmstc_crdt_financial, r fe
outreg2 using regression_results.doc, adjr2

xtreg inflation cpia_macro_rating cpia_avg_rating dmstc_crdt_financial export_volume, r fe
outreg2 using regression_results.doc, adjr2
//---------Joint F-Test

//---------Interaction Term Testing----------------------
xtreg inflation c.cpia_macro_rating##c.cpia_avg_rating dmstc_crdt_financial export_volume, r fe
xtreg inflation c.cpia_macro_rating##c.dmstc_crdt_financial c.cpia_avg_rating export_volume, r fe

//FINAL RESULTS: EXTREMELY INTERESTING

//Interaction Term DOES matter
xtreg inflation c.cpia_macro_rating##c.export_volume cpia_avg_rating c.dmstc_crdt_financial, r fe
outreg2 using final_results.doc, replace adjr2
//ONLY WHEN holding other variables constant
xtreg inflation c.cpia_macro_rating##c.export_volume, r fe
outreg2 using final_results.doc, adjr2
