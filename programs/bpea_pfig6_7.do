clear *

global datain "D:\Projects\BPEA\data\"

global datamorg "D:\Projects\BPEA\data\morg\clean_nber_morg_output"

global dataout  "D:\Projects\BPEA\data\TEMP"

global figures  "D:\Projects\BPEA\figures"


use "$datain\FRED_USRECM.dta", clear
keep year month USRECM
keep if year>=1979 & year<=2019
replace year=year+month/12
save  "$dataout\FRED_USRECM2.dta", replace
 
use "$datamorg\cleaned_nber_morg.dta" , clear

keep if age>=25

*drop self-employed
*rename class classx
*lab var classx "private = 1, fed = 2, state = 3, loc = 4, self = 5, 6, w/o pay = 7" //<=1993
*lab var class94 "fed = 1, state = 2, loc = 3, priv = 4, 5, self = 6, 7, w/o pay = 8" //>=1994
drop if classer>=5 & classer<=7
drop if classx>=5 & classx<=8


drop if twage==.
sort state year
merge m:1 state year using "$datain\min_wage_stateannual2019.dta"  
drop _merge

gen lwb=0.85*mw_ef
gen upb=1.15*mw_ef
gen atmw=0 
replace atmw=1 if wage>= lwb & wage <= upb

drop lwb upb statefips

**use same trimming as DFL  $>1 and <$100 in 1979 nominal dollars
** rebase wage in 2019
sum cpi if year==2019
gen cpi2019=r(mean)

gen rwage2=(wage/cpi)*cpi2019
drop cpi2019

* create race variable with 4 categories white non hispanic , black non hispanic, hispanic all races, *and other races
tab race, missing

gen race1=race
replace race1 = 3 if race > 2  //suppress oth races for comparability
*	lab var race "white = 1, Black = 2, other = 3"

gen race2=1 if race1==1 & ( hispanic==0  )
replace race2=2 if race1 == 2  & (hispanic==0  )
replace race2=3 if hispanic==1 
replace race2=4 if race1==3 & ( hispanic==0 | hispanic==. )
 

tab race1 race2, missing

tab race2, gen(r4d)

forvalues i=1(1)4 {
gen atmw4d`i'=atmw if race2==`i'
}


drop female
gen byte female=(sex==2)

save "$dataout\morg4atmw.dta" , replace
**Figure 6

use "$dataout\morg4atmw.dta" ,clear

sort year female
collapse atmw4d1 atmw4d2 atmw4d3 atmw4d4  ///
    [weight=eweight], by(year female)

append using "$dataout\FRED_USRECM2.dta"
sort year


set scheme s1color
graph set window fontface "Times New Roman"

gen recession = USRECM *0.31


twoway  (area recession year, color(gs14) ) ///
 (line atmw4d1 year if female==0, lp(longdash_dot) lc(black) lwidth(medium)) ///
(line atmw4d2 year if female==0, lp(solid) lc(midblue) lwidth(medthick)) ///
(line atmw4d3 year if female==0, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line atmw4d4 year if female==0, lp(dash) lc(dkgreen) lwidth(medium)) ///
 , ytitle("Proportion of MW Workers", size(large)) xlabel(1980(5)2020, labsize(large)) ///
  ylabel(0(.1)0.3, labsize(large) angle(0)) yline(0(0.05)0.3, lstyle(grid)) yscale(r( 0 0.31)) ///
legend(order(2 "Whites" 3 "Blacks" 4 "Hispanics" 5 "API+")  size(medium) col(2) pos(12) ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) subtitle({it:A. Men}, size(large)) ///
saving("$figures\PF_racialethnic_atmwm", replace) 


twoway (area recession year, color(gs14) ) ///
(line atmw4d1 year if female==1, lp(longdash_dot) lc(black) lwidth(medium)) ///
(line atmw4d2 year if female==1, lp(solid) lc(midblue) lwidth(medthick)) ///
(line atmw4d3 year if female==1, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line atmw4d4 year if female==1, lp(dash) lc(dkgreen) lwidth(medium)) ///
 , ytitle("Proportion of MW Workers", size(large)) xlabel(1980(5)2020, labsize(large)) ///
  ylabel(0(.1)0.3, labsize(large) angle(0)) yline(0(0.05)0.3, lstyle(grid)) yscale(r( 0 0.31)) ///
legend(order(2 "Whites" 3 "Blacks" 4 "Hispanics" 5 "API+") size(medium) col(2) pos(12) ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) subtitle({it:B. Women}, size(large)) ///
saving("$figures\PF_racialethnic_atmwf", replace) 


graph combine "$figures\PF_racialethnic_atmwm.gph" "$figures\PF_racialethnic_atmwf.gph" , iscale(1) ///
	graphregion(margin(zero ))   xsize(15) ysize(6) ///	
	note("Source: Author's Calculation, CPS-MORG 1979-2019, Employed Workers Ages 25-64, within 15% of effective minimum wage." "            Shaded areas indicate recessions." ,  size(medium)) ///
saving("$figures\PF_racialethnic_atmw.gph", replace)	

graph export $figures\PF_racialethnic_atmw.emf, replace
graph export $figures\PF_racialethnic_atmw.pdf, replace

*** Figure 7B

use "$dataout\morg4atmw.dta" ,clear

keep if atmw==1

*** noisy up wage to avoid heaping
set seed 9876
gen noise=runiform(-0.01,0.01)
gen nsywage=wage+noise

gen quartile=.
forvalues yr=1979(1) 2019 {
xtile temp = nsywage [weight=eweight] if year==`yr', nq(4)
replace quartile=temp if year==`yr'
drop temp
}

tab quartile
bysort quartile: sum wage if year>=2000

gen bottom=0
replace bottom=1 if quartile ==1

forvalues i=1(1)4 {
gen bottomd`i'=bottom if race2==`i'
}

sort year female
collapse bottomd1 bottomd2 bottomd3 bottomd4   [weight=eweight], by(year)

append using "$dataout\FRED_USRECM2.dta"
sort year

gen recession = USRECM *0.61

twoway (area recession year, color(gs14) ) ///
(line bottomd1 year , lp(longdash_dot) lc(black) lwidth(medium)) ///
(line bottomd2 year , lp(solid) lc(midblue) lwidth(medthick)) ///
(line bottomd3 year , lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line bottomd4 year , lp(dash) lc(dkgreen) lwidth(medium)) ///
 , ytitle("Proportion of MW Workers", size(large)) xlabel(1980(5)2020, labsize(large)) ///
  ylabel(0(.2)0.6, labsize(large) angle(0)) yline(0(0.1)0.6, lstyle(grid)) yline(0.25, lstyle(foreground)) yscale(r( 0 0.51)) subtitle("B. Proportion of MW Workers" "in the Bottom 25% of the MW Distribution", size(large)) /// ///
  legend(order(2 "Whites" 3 "Blacks" 4 "Hispanics" 5 "API+") size(medium) col(2) pos(1) ring(0) region(lcolor(none)))    xtitle("Year", size(large)) ///
saving("$figures\PF_racialethnic_atp25mw", replace) 


Now do Figure 7A

use "$datain\state_min_wag_1979_2019.dta", clear

merge m:m datem using "$datain\FRED_USRECM.dta"
keep if _merge==3
drop _merge

di monthly("1979m1","YM")

***for clarify use quarterly data
keep if inlist(month, 3,6 , 9, 12)

egen rmw_ef=rowmax(r_mw19 rfed_mw19)
egen rmw_efm = max(rmw_ef), by(datem)

gen nyear=year+(month/12)

gen recession = USRECM *15
replace recession=3 if recession==0
keep if year>=1979 & year<=2019

set scheme s1color
graph set window fontface "Times New Roman"
 
twoway  (area recession nyear, color(gs14) ) ///
  (line rfed_mw19 nyear, msymbol(i)  lwidth(medium) lpattern(longdash_dot) lcolor(black)  ) ///
     (line rmw_efm nyear, msymbol(i)  lwidth(medthick) lcolor(dkorange)  )  ///
   , ytitle("Minimum Wages ($2019)", size(large))  yline(3(2)15, lstyle(grid))  ///
    ylabel(3(2) 15, labsize(large) angle(0)) yscale(r(3 15)) xlabel(1980(5)2020, labsize(large)) ///
	xtitle("Year", size(large)) subtitle("A. Increasing Inequality between Federal" " and State Real Minimum Wages", size(large)) ///
	  legend(col(1) pos(11) ring(0) order(2 "Federal Minimum Wage" 3 "Highest State Minimum Wage" ) hole(1) ///
  size(medium) region(lstyle(none)) symxsize(8) keygap(1) textwidth(25) ) xsize(16) ysize(9) ///
  saving("$figures\PF_trends_mw", replace) 
 

graph combine "$figures\PF_trends_mw.gph" "$figures\PF_racialethnic_atp25mw.gph" , iscale(1) ///
	graphregion(margin(zero ))   xsize(15) ysize(6) ///	
	note("Source: Author's Calculation, CPS-MORG 1979-2019, Employed Workers Ages 25-64, within 15% of effective minimum wage." "            Shaded areas indicate recessions. MW data from FRED and Vaghula dn Zipper (2019)" ,  size(medium)) ///
saving("$figures\PF_trends_mw25.gph", replace)	

graph export $figures\PF_trends_mw25.emf, replace 
graph export $figures\PF_trends_mw25.pdf, replace
