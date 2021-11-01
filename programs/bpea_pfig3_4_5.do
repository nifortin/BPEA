clear *

global datamorg "D:\Projects\BPEA\data\morg\clean_nber_morg_output"

global dataout  "D:\Projects\BPEA\data\TEMP"

global figures  "D:\Projects\BPEA\figures"

use "$dataout\morg8bpea.dta" , replace

forvalues i=1(1)4 {
gen wagec4u`i'=rwage2 if race2==`i' & covered==1
gen wagec4nu`i'=rwage2 if race2==`i' & covered==0
gen educ4d`i'=educ if race2==`i'
gen ucov4d`i'=covered if race2==`i'
}

drop female
gen byte female=(sex==2)

sort year female
collapse  educ4d1 educ4d2 educ4d3 educ4d4  ucov4d1 ucov4d2 ucov4d3 ucov4d4 [weight=eweight], by(year female)

set scheme s1color
graph set window fontface "Times New Roman"

**** Figure 3

twoway (line educ4d1 year if female==0, lp(longdash_dot) lc(black) lwidth(medium)) ///
(line educ4d2 year if female==0, lp(solid) lc(midblue) lwidth(medthick)) ///
(line educ4d3 year if female==0, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line educ4d4 year if female==0, lp(dash) lc(dkgreen) lwidth(medium)), ytitle("Average Years of Schooling", size(large)) xlabel(1980(5)2020, labsize(large)) ///
 ylabel(8(2)16, labsize(medlarge) angle(0)) yline(8(1)16, lstyle(grid))  ///
legend(order(1 "Whites" 2 "Blacks" 3 "Hispanics" 4 "API+") size(medium) r(4) pos(5) ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) subtitle({it:A. Men}, size(large)) ///
saving("$figures\PF_racialethnic_educm", replace) 


twoway (line educ4d1 year if female==1, lp(longdash_dot) lc(black) lwidth(medium)) ///
(line educ4d2 year if female==1, lp(solid) lc(midblue) lwidth(medthick)) ///
(line educ4d3 year if female==1, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line educ4d4 year if female==1, lp(dash) lc(dkgreen) lwidth(medium)), ytitle("Average Years of Schooling", size(large)) xlabel(1980(5)2020, labsize(large)) ///
 ylabel(8(2)16, labsize(medlarge) angle(0)) yline(8(1)16, lstyle(grid))  ///
legend(order(1 "Whites" 2 "Blacks" 3 "Hispanics" 4 "API+") size(medium) r(4) pos(5) ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) subtitle({it:B. Women}, size(large))  ///
saving("$figures\PF_racialethnic_educf", replace) 


graph combine "$figures\PF_racialethnic_educm" "$figures\PF_racialethnic_educf" , iscale(1) ///
	graphregion(margin(zero ))   xsize(15) ysize(6) ///	
	note("Source: Author's Calculation, CPS-MORG 1979-2019, Employed Workers Ages 25-64.",  size(medium)) ///
saving("$figures\PF_racialethnic_educ", replace)	 


graph export "$figures\PF_racialethnic_educ.emf", replace
graph export "$figures\PF_racialethnic_educ.pdf", replace


forvalues i=1(1)4 {
regress educ4d`i' year if female==0
regress educ4d`i' year if female==1
}


bysort female: sum educ4d*
bysort female: list educ4d2 if year==1979
bysort female: list educ4d2 if year==1995
bysort female: list educ4d2 if year==2019

regress educ4d1 year if female==0 & year<1996
regress educ4d1 year if female==0 & year>=1996
*Blacks
regress educ4d2 year if female==0 & year<1996
regress educ4d2 year if female==0 & year>=1996
regress educ4d2 year if female==1 & year<1996
regress educ4d2 year if female==1 & year>=1996

*Hispanics
regress educ4d3 year if female==0 & year<1996
regress educ4d3 year if female==0 & year>=1996
regress educ4d3 year if female==1 & year<1996
regress educ4d3 year if female==1 & year>=1996

***Figure 4

sort year
twoway (line ucov4d1 year if female==0, lp(longdash_dot) lc(black) lwidth(medium)) ///
(line ucov4d2 year if female==0, lp(solid) lc(midblue) lwidth(medthick)) ///
(line ucov4d3 year if female==0, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line ucov4d4 year if female==0, lp(dash) lc(dkgreen) lwidth(medium)), ytitle("Proportion Covered", size(large)) xlabel(1980(5)2020, labsize(large)) ///
 ylabel(0(.1)0.45, labsize(medlarge) angle(0)) yline(0(0.05)0.45, lstyle(grid))  ///
legend(order(1 "Whites" 2 "Blacks" 3 "Hispanics" 4 "API+") size(medium) r(4) pos(1) ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) subtitle({it:A. Men}, size(large))  ///
saving("$figures\PF_racialethnic_ucovm", replace)


twoway (line ucov4d1 year if female==1, lp(longdash_dot) lc(black) lwidth(medium)) ///
(line ucov4d2 year if female==1, lp(solid) lc(midblue) lwidth(medthick)) ///
(line ucov4d3 year if female==1, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line ucov4d4 year if female==1, lp(dash) lc(dkgreen) lwidth(medium)), ytitle("Proportion Covered", size(large)) xlabel(1980(5)2020, labsize(large)) ///
 ylabel(0(.1)0.45, labsize(medlarge) angle(0)) yline(0(0.05)0.45, lstyle(grid))  ///
legend(order(1 "Whites" 2 "Blacks" 3 "Hispanics" 4 "API+") size(medium) r(4) pos(1) ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) subtitle({it:B. Women}, size(large))  ///
saving("$figures\PF_racialethnic_ucovf", replace)


graph combine "$figures\PF_racialethnic_ucovm" "$figures\PF_racialethnic_ucovf.gph" , iscale(1) ///
	graphregion(margin(zero ))   xsize(15) ysize(6) ///	
	note("Source: Author's Calculation, CPS-MORG 1979-2019, Employed Workers Ages 25-64.",  size(medium)) ///
saving("$figures\PF_racialethnic_ucov", replace)	 
	 
graph export $figures\PF_racialethnic_ucov.emf, replace
graph export $figures\PF_racialethnic_ucov.pdf, replace

***Figure 5


use "$dataout\morg8bpea.dta" , clear

forvalues i=1(1)4 {
gen wage4u`i'=rwage2 if race2==`i' & covered==1
gen wage4nu`i'=rwage2 if race2==`i' & covered==0
gen educ4d`i'=educ if race2==`i'
gen ucov4d`i'=covered if race2==`i'
}

sort year
collapse educ4d1 educ4d2 educ4d3 educ4d4 ucov4d1 ucov4d2 ucov4d3 ucov4d4 ///
 wage4nu1 wage4nu2 wage4nu3 wage4nu4 wage4u1 wage4u2 wage4u3 wage4u4 [weight=eweight], by(year)
 
 
twoway (line wage4nu1 year if year>=1984, lp(longdash_dot) lc(black) lwidth(medium)) ///
(line wage4u1 year if year>=1984, lp(dash) lc(gs6) lwidth(medthick)) ///
(line wage4nu2 year if year>=1984, lp(solid) lc(midblue) lwidth(medthick)) ///
(line wage4u2 year if year>=1984, lp(longdash) lc(eltblue*1.2) lwidth(medthick)) ///
(line wage4nu3 year if year>=1984, lp(shortdash) lc(cranberry) lwidth(medthick)) ///
(line wage4u3 year if year>=1984, lp(shortdash_dot) lc(sienna) lwidth(medthick)) ///
, ytitle("Real Wages ($2019)", size(large)) xlabel(1985(5)2020, labsize(large)) ///
 ylabel(10(5)35, labsize(large) angle(0)) yline(10(2.5)35, lstyle(grid)) yscale(r(8 35)) ///
 legend(order(1 "W-Non-Union" 2 "W-Union" 3 "B-Non-Union" 4 "B-Union"  5 "H-Non-Union" 6 "H-Union") size(medium) pos(6) col(2)  ///
 ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) subtitle("A. AHE by Union Status and Racial/Ethnic Groups", size(large)) ///
saving("$figures\PF_racialethnic_wagesunion1", replace)


forvalues i=1(1)4{
gen ratio4u`i'=wage4u`i'/wage4u1
gen ratio4nu`i'=wage4nu`i'/wage4nu1
gen unionpre`i'=(wage4u`i'/wage4nu`i') -1
}

gen time=year-1978
regress unionpre2 time
predict prunionpre2

twoway  (line unionpre1 year if year>=1984, lp(longdash_dot) lc(black) lwidth(medium)) ///
(line unionpre2 year if year>=1984, lp(solid) lc(midblue) lwidth(medthick)) ///
(line unionpre3 year if year>=1984, lp(shortdash) lc(cranberry) lwidth(medthick)) ///
(line prunionpre2 year if year>=1984, lp(dash) lc(gs4) lwidth(thin)) ///
, ytitle("Union/Non-Union Gap", size(large)) xlabel(1985(5)2020, labsize(large)) ///
 ylabel(0(0.1)0.4, labsize(large) angle(0) ) yline(0.0(0.05)0.45, lstyle(grid)) yscale(r(0 0.45)) /// 
 legend(order(1 "Whites" 2 "Blacks" 3 "Hispanics") hole(4) size(medium) r(1) pos(12) ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) subtitle("B. Union/Non-Union Premium by Racial/Ethnic Group", size(large)) ///
saving("$figures\PF_racialethnic_unionpre", replace)


graph combine "$figures\PF_racialethnic_wagesunion1.gph" "$figures\PF_racialethnic_unionpre.gph" , iscale(1) ///
	graphregion(margin(zero ))   xsize(15) ysize(6) ///	
	note("Source: Author's Calculation, CPS-MORG 1979-2019, Employed Workers Ages 25-64. W is for whites, B is for Blacks, H for Hispanics. Union Premium"   "        is computed as the ratio of AHE for union to non-union workers minus 1." ,  size(medium)) ///
saving("$figures\PF_racialethnic_USFB.gph", replace)	 
	  
	
graph export $figures\PF_racialethnic_USFB.emf, replace
graph export $figures\PF_racialethnic_USFB.pdf, replace
