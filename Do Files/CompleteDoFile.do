//DROP AGGREGATES
clear
cd "C:\Users\mruss\projects\classes\ec204\final_project" //Absolute File Path to my project location

use "data\MasterDataset.dta"
rename Year Time
merge 1:1 CountryCode Time using "C:\Users\mruss\Downloads\GDP PPP Panel Data.dta", gen(merge_agg)
drop if merge_agg==1

/* 
CLEAN COLUMN NAME and DROP irrelevant columns
*/

//A bunch of renaming for research
rename GDPpercapitagrowthannual gdp_pc_growth
rename GDPdeflatorbaseyearvariesb gdp_deflator
rename Domesticcreditprovidedbyfina dmstc_crdt_financial
rename Domesticcredittoprivatesecto dmstc_crdt_privt
rename Depthofcreditinformationinde depth_of_credit
rename Exportvolumeindex2000100 export_volume
rename GDPpercapitaconstant2015US gdp_constant
rename Accesstoelectricityofpopu electricity_access
rename CPIAmacroeconomicmanagementra cpi_macro_rating
rename cpi_macro_rating cpia_macro_rating
rename CPIAeconomicmanagementcluster cpi_econ_rating
rename CPIAfinancialsectorrating1 cpia_financial_rating
rename Informalpaymentstopublicoffi informal_payments
rename CountryName country_name
rename Time year
rename CountryCode country_code
rename Inflationconsumerpricesannu inflation
rename Consumerpriceindex2010100 cpi
rename Borrowersfromcommercialbanks borrowers
rename CPIAgenderequalityrating1l cpia_gender_eq_rating
rename CPIApoliciesforsocialinclusi cpia_social_inclus_rating
rename CPIApropertyrightsandruleba cpia_prpty_rights_rating
rename CPIAsocialprotectionrating1 cpia_social_protctn_rating
rename cpi_econ_rating cpia_econ_rating

//Dropping columns not used in final model
drop Adolescentfertilityratebirth Agedependencyratioofworki Agriculturevalueaddedannual Agriculturevalueaddedconsta AgriculturevalueaddedofG
drop Airtransportregisteredcarrie AutomatedtellermachinesATMs Contributingfamilyworkersfem  Contributingfamilyworkersmal  Contributingfamilyworkerstot
drop GDPconstant2015USNYGDP  GDPgrowthannual GDPgrowthannualNYGDPMK  GDPpercapitaPPPconstant20 GDPPPPconstant2021internat
drop ElectricpowerconsumptionkWh

//Generate an average rating column 
egen cpia_avg_rating = rowmean( cpia_econ_rating cpia_financial_rating  cpia_social_inclus_rating cpia_prpty_rights_rating cpia_social_protctn_rating)

//Drop rows without our main dependent variable
drop if missing(cpia_avg_rating)
save "data\renamed_rows_final.dta", replace //Save checkpoint

/* Regression and table generation do file */
clear
cd "C:\Users\mruss\projects\classes\ec204\final_project" //Absolute File Path to my project
use data\renamed_rows_final.dta

//Relabel variables for better outreg2 output
label variable cpia_macro_rating "Macro"
label variable inflation "Inflation"
label variable cpia_avg "CPIA_Avg"
label variable export_volume "Export"
label variable dmstc_crdt_financial "Credit Financial"

//Generate Helper Columns for Different Models
gen macro_rating_sq = cpia_macro_rating * cpia_macro_rating
label variable macro_rating_sq "Macro^2"
gen log_macro_rating = log(cpia_macro_rating)
label variable log_macro_rating "Log(Macro)"
gen macro_export = cpia_macro_rating * export_volume
label variable macro_export "Macro x Export"

//Start Regressions
encode country_code, gen(country)
xtset country year

//-----------------Fixed Effects Modeling---------------------

//Basic Linear
xtreg inflation cpia_macro_rating,r fe
outreg2 using "Regression Outputs\no_ovb.doc", replace adjr2

//Basic Quadratic
xtreg inflation cpia_macro_rating macro_rating_sq, r fe
outreg2 using "Regression Outputs\no_ovb.doc", adjr2

//Basic Logrithmic
xtreg inflation log_macro_rating, r fe
outreg2 using "Regression Outputs\no_ovb.doc", adjr2

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


//Controlling for OVB in outreg2
xtreg inflation cpia_macro_rating, r fe
outreg2 using "Regression Outputs\regression_results.doc", replace adjr2

xtreg inflation cpia_macro_rating cpia_avg_rating, r fe
outreg2 using "Regression Outputs\regression_results.doc", adjr2

xtreg inflation cpia_macro_rating cpia_avg_rating dmstc_crdt_financial, r fe
outreg2 using "Regression Outputs\regression_results.doc", adjr2

xtreg inflation cpia_macro_rating cpia_avg_rating dmstc_crdt_financial export_volume, r fe
outreg2 using "Regression Outputs\regression_results.doc", adjr2
//---------Joint F-Test

//---------Interaction Term Testing----------------------
xtreg inflation c.cpia_macro_rating##c.cpia_avg_rating dmstc_crdt_financial export_volume, r fe
xtreg inflation c.cpia_macro_rating##c.dmstc_crdt_financial c.cpia_avg_rating export_volume, r fe

//FINAL RESULTS: EXTREMELY INTERESTING

//Basic Linear Model
xtreg inflation cpia_macro_rating, r fe
outreg2 using "Regression Outputs\final_results.doc", replace adjr2 label

//Linear Model for Comparison (Adj R^2)
xtreg inflation cpia_macro_rating export_volume cpia_avg_rating dmstc_crdt_financial, r fe
outreg2 using "Regression Outputs\final_results.doc", adjr2 label

//Squared Model
xtreg inflation cpia_macro_rating macro_rating_sq export_volume cpia_avg_rating dmstc_crdt_financial, r fe
outreg2 using "Regression Outputs\final_results.doc", adjr2 label

//Log Model 
xtreg inflation cpia_macro_rating log_macro_rating export_volume cpia_avg_rating dmstc_crdt_financial, r fe
outreg2 using "Regression Outputs\final_results.doc", adjr2 label

//ONLY WHEN holding other variables constant
xtreg inflation cpia_macro_rating export_volume macro_export, r fe
outreg2 using "Regression Outputs\final_results.doc", adjr2 label

//Interaction Term
xtreg inflation cpia_macro_rating export_volume macro_export cpia_avg_rating dmstc_crdt_financial, r fe
outreg2 using "Regression Outputs\final_results.doc", adjr2 label


///Scatterplot codex`'

* Create a new boolean variable for outliers
gen extreme_inflation = inflation > 200

* Label the new variable for clarity
label variable extreme_inflation "Inflation > 200%"
 
 
//Create the scatter plot of the results
twoway (scatter inflation cpia_macro_rating, sort mcolor(ltblue) msize(3-pt)) if extreme_inflation == 0, ytitle("% Change in Inflation") ymtick(minmax) xtitle("CPIA Macroeconomic Management Rating (1 = Bad, 6 = Great)") title("Macroeconomic Management Quality v Inflation % by Year", span) note("World Bank Data 2005-2016", margin(esubhead))
graph export "C:\Users\mruss\projects\classes\ec204\final_project\Scatter.png", as(png) name("Graph")