//DROP AGGREGATES
use "C:\Users\mruss\projects\classes\ec204\final_project\data\MasterDataset.dta"
rename Year Time
merge 1:1 CountryCode Time using "C:\Users\mruss\Downloads\GDP PPP Panel Data.dta", gen(merge_agg)
drop if merge_agg==1