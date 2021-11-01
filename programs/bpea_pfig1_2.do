clear *

global datamorg "D:\Projects\BPEA\data\morg\clean_nber_morg_output"

global dataout  "D:\Projects\BPEA\data\TEMP"

global figures  "D:\Projects\BPEA\figures"

use "$datamorg\cleaned_nber_morg.dta" 

keep if age>=25
**rebase rwage to 2019

* drop self-employed
*rename class classx
*lab var classx "private = 1, fed = 2, state = 3, loc = 4, self = 5, 6, w/o pay = 7" //<=1993
*lab var class94 "fed = 1, state = 2, loc = 3, priv = 4, 5, self = 6, 7, w/o pay = 8" //>=1994
drop if classer>=5 & classer<=7
drop if classx>=5 & classx<=8


**use same trimming as DFL  $>1 and <$100 in 1979 nominal dollars
drop if twage==.
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

gen foreignb=0
replace foreignb=1 if citizen==4 |  citizen==5

** separate US-born and Foreign born

gen race3=1 if race2==1 & foreignb==0
replace race3=2 if race2==1 & foreignb==1
replace race3=3 if race2==2 & foreignb==0
replace race3=4 if race2==2 & foreignb==1
replace race3=5 if race2==3 & foreignb==0
replace race3=6 if race2==3 & foreignb==1
replace race3=7 if race2==4 & foreignb==0
replace race3=8 if race2==4 & foreignb==1

tab race1 race3, missing

tab race2, gen(r4d)
tab race3, gen(r8d)

forvalues i=1(1)4 {
gen wage4d`i'=rwage2 if race2==`i'
}

forvalues i=1(1)8 {
gen wage8d`i'=rwage2 if race3==`i'
}

save "$dataout\morg8bpea.dta" , replace

sort year
collapse r4d1 r4d2 r4d3 r4d4  r8d1 r8d2 r8d3  r8d4 r8d5 r8d6 r8d7 r8d8 wage4d1 wage4d2 wage4d3 wage4d4 wage8d1 wage8d2 wage8d3 wage8d4 wage8d5 wage8d6 wage8d7 wage8d8 [weight=eweight], by(year)

save "$dataout\morg8mean.dta" , replace

use "$dataout\morg8mean.dta" , clear

set scheme s1color
*graph set window fontface "Arial"
graph set window fontface "Times New Roman"

** Paper Figures

*** Figure 1
	 
twoway (line r4d1 year,  lp(longdash_dot) lc(black) lwidth(medium)) ///
 (line r4d2 year, lp(solid) lc(midblue) lwidth(medthick))  ///
(line r4d3 year, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line r4d4 year, lp(dash) lc(dkgreen) lwidth(medium)) ///
, ytitle("Proportion", size(large)) xlabel(1980(5)2020, labsize(large)) ///
  ylabel(0(.2)1, labsize(medlarge) angle(0)) yline(0(.1)1, lstyle(grid))  ///
legend(order(1 "Whites" 2 "Blacks" 3 "Hispanics" 4 "API+") size(medium) r(4) pos(9) ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) title("A. Racial/Ethnic Groups in the U.S. Labor Force", size(large)) ///
saving("$figures\PF_racialethnic_time", replace) 
 
	 
twoway (line wage4d1 year, lp(longdash_dot) lc(black) lwidth(medium)) ///
(line wage4d2 year, lp(solid) lc(midblue) lwidth(medthick)) ///
(line wage4d3 year, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line wage4d4 year, lp(dash) lc(dkgreen) lwidth(medium)), ytitle("Real Wages ($2019)", size(large)) xlabel(1980(5)2020, labsize(large)) ///
 ylabel(10(5)35, labsize(medlarge) angle(0)) yline(10(2.5)35, lstyle(grid))  ///
legend(order(1 "Whites" 2 "Blacks" 3 "Hispanics" 4 "API+") size(medium) r(4) pos(11) ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) title("B. Average Hourly Earnings by Groups", size(large)) ///
saving("$figures\PF_racialethnic_wages", replace)


graph combine "$figures\PF_racialethnic_time.gph" "$figures\PF_racialethnic_wages.gph" , iscale(1) ///
	graphregion(margin(zero ))   xsize(15) ysize(6) ///	
	note("Source: Author's Calculation, CPS-MORG 1979-2019, Employed Workers Ages 25-64.",  size(medium)) ///
saving("$figures\PF_trends_racialethnic.gph", replace)	 
	 
graph export "$figures\PF_trends_racialethnic.emf", replace
graph export "$figures\PF_trends_racialethnic.pdf", replace

forvalues i=1(1)8{
gen ratio8d`i'=wage8d`i'/wage8d1
}
gen ratio4d3=wage8d3/wage4d1

gen time=year-1978
regress ratio8d3 time if year>=1994
predict pratio8d3
regress ratio4d3 time if year>=1994

regress ratio8d4 time
regress ratio8d2 time
regress ratio8d5 time

*** Figure 2
*** country of birth available only from 1994

twoway (line r4d2 year if year>=1994, lp(solid) lc(midblue) lwidth(medthick)) ///
(line r8d4 year if year>=1994, lp(longdash_shortdash) lc(eltblue*1.2) lwidth(medthick)) ///
(line r4d3 year if year>=1994, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line r8d6 year if year>=1994, lp(dash_dot) lc(sienna) lwidth(medthick)) ///
(line r4d4 year if year>=1994, lp(dash) lc(dkgreen) lwidth(medium)) ///
(line r8d8 year if year>=1994, lp(shortdash) lc(green) lwidth(medium)) ///
, ytitle("Proportion", size(large))  xlabel(1995(5)2020, labsize(large)) ///
  ylabel(0(0.05)0.2, labsize(large) angle(0)) yline(0(0.05)0.2, lstyle(grid))  ///
legend(order(1 "B-All" 2 "B-FB" 3 "H-All" 4 "H-FB" 5 "API-All" 6 "API-FB") size(medium)  col(1) r(4) pos(11) ///
ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) title("A. Racial/Ethnic Groups by Birth Country", size(large)) ///
saving("$figures\PF_racialethnic_time8c", replace)

twoway (line ratio8d2 year if year>=1994, lp(longdash) lc(gs6) lwidth(medthick)) ///
(line ratio8d3 year if year>=1994, lp(solid) lc(midblue*1.2) lwidth(medthick)) ///
(line ratio8d4 year if year>=1994, lp(longdash_shortdash) lc(eltblue*1.2) lwidth(medthick)) ///
(line ratio8d5 year if year>=1994, lp(longdash) lc(cranberry) lwidth(medthick)) ///
(line ratio8d6 year if year>=1994, lp(dash_dot) lc(sienna) lwidth(medthick)) ///
(line ratio8d7 year if year>=1994, lp(dash) lc(dkgreen) lwidth(medium)) ///
(line ratio8d8 year if year>=1994, lp(shortdash) lc(midgreen) lwidth(medium)) ///
(line pratio8d3 year if year>=1994, lp(dash) lc(black) lwidth(thin)) ///
, ytitle("Ratio of Group to W-USB", size(large)) xlabel(1995(5)2020, labsize(large))  ///
 ylabel(0.4(0.2)1.1, labsize(large) angle(0)) yline(0.4(0.1)1.1, lstyle(grid)) yline(1.0, lstyle(foreground)) /// 
  legend(order(2 "B-USB" 3 "B-FB" 8 "B-USBTrend"  4 "H-USB" 5 "H-FB" 6 "API-USB" 7 "API-FB" 1 "W-FB" ) ///
 size(medium) pos(6) col(3)  ring(0) region(lcolor(none))) ///
xtitle("Year", size(large)) title("B. Ratio of Group AHE to Whites US-Born", size(large)) ///
saving("$figures\PF_racialethnic_ratio8", replace)


graph combine "$figures\PF_racialethnic_time8c.gph" "$figures\PF_racialethnic_ratio8.gph" , iscale(1) ///
	graphregion(margin(zero ))   xsize(15) ysize(6) ///	
	note("Source: Author's Calculation, CPS-MORG 1979-2019, Employed Workers Ages 25-64. W is for whites, B is for Blacks, H for Hispanics," "           FB for Foreign-Born, and USB for US-Born. Birth country available from 1994.",  size(medium)) ///
saving("$figures\PF_racialethnic_USFB.gph", replace)	 
	 
graph export $figures\PF_racialethnic_USFB.emf, replace
graph export $figures\PF_racialethnic_USFB.pdf, replace