 * filter by year 2010 2013 2015 2018 and age <44 and colly is correct (i.e. no unknown) 
	keep if inlist(year,2010,2013,2015,2018) & age>44 & inlist(colly,1,2,3)

*create singular comorbidity value
	*making a plus 1 score for each thingy
	generate htn=cond(hypertenev==2,1,0)
	generate chd=cond(cheartdiev==2,1,0)
	generate stroke=cond(strokev==2,1,0)
	generate copd=cond((cronbronyr==2 | emphysemev==2),1,0)
	generate asthma=cond(asthmaev==2,1,0)
	generate diabetes=cond(diabeticev==2,1,0)
	generate arthritis=cond(arthritev==2,1,0)
	generate hepatitis=cond(hepatev==2,1,0)
	generate kidney=cond(kidneywkyr==2,1,0)
	generate cancer=cond(cancerev==2,1,0)
	*adding them all together
	generate comorbiditytotal=htn+chd+stroke+copd+asthma+diabetes+hepatitis+kidney+arthritis+cancer
    *assigning a general score
	generate comorbidity=0 if comorbiditytotal==0 
    replace comorbidity=1 if comorbiditytotal==1
	replace comorbidity=2 if comorbiditytotal>1
	
*create two age groups
	*young adults are group 0 old are group 1
	generate agegroup=cond(age<50,0,1)
 
*create binary insurance
	*a 0 represents has insurance, a 1 represents a lack of insurance         
	generate insurance=cond(hinotcov==1,0,1)
         
*create binary ethnicity leave out not enough people (get rid of hispanic p is too high)
	*not hispanic or unknown is a 0, otherwise everything else is a hispanic 1
	generate hispanic=cond(inlist(hispeth,10,90,91,92,93),0,1)

*condense race values
	*Other (put this one first becuase has the widest range of possible values)
	generate race=4 
	*white
	replace race=1 if racea==100
	*black
	replace race=2 if racea==200
	*Asian & pacisfic islander
	replace race=3 if inlist(racea,410,411,412,413,414,415,416,420,421,422,423,430,431,432,434)

*condense income values
	*unknown
	generate income=5
	*0-34999
	replace income=1 if incfam97on2==10
	*35-74999
	replace income=2 if incfam97on2==20
	*75-99999
	replace income=3 if incfam97on2==31
	*100+
	replace income=4 if incfam97on2==32
	*get rid of unknown
	drop if income==5

*condense education
	*high school or less
	generate education=1 if inlist(educrec2,10,20,30,31,32,40,41,42)
		*high school only
		*replace education=2 if educrec2==42
	*some college
	replace education=3 if inlist(educrec2,50,51,52,53)
	*4 year or more degree
	replace education=4 if inlist(educrec2,54,60)
	*unknown get rid of it
	replace education=5 if inlist(educrec2,96,97,98,99)
	drop if education==5

*condense married
	*1 is for married
	generate married=cond(inlist(marstat,10,11,12,13),1,0)

*condense smoker
	*0 is non smoker, 1 is current or former smoker
	generate smoker=cond(inlist(smokestatus2,11,12,40,20),1,0)

*condense usual place for medical care
	*0 is do not have place for usual care, 1 is have a usual place
	generate usualplace=cond(inlist(usualpl,2,3),1,0)

*create binary colly variable
	*1 is got colonoscopy as part of a routine procedure
	generate colreason=cond(colly==1,1,0)
	
*create new split year variable, we can just look at this with a graph and not include in log istic regression becuase it doenst really make sense 
	generate year2 = year
	replace year2=2019 if (year==2018 & inlist(quarter,3,4))

*flip reference on sex
	generate sex2 = cond(sex==2,0,1)
	
	
*sample weight
	svyset [pweight=sampweight], strata (year) 
	
	
*logistic regression for young people, leave out hispanic, usual place, smoking
generate ageyoung=cond(agegroup==0,1,0)
	*svy,subpop(ageyoung): logistic colreason i.comorbidity i.insurance  i.race i.income i.education i.married i.sex i.hispanic i.usualplace i.smoker
	*svy,subpop(ageyoung): logistic colreason i.race i.income i.sex i.smoker
	
*logistic regression for old people
	*svy,subpop(agegroup): logistic colreason i.comorbidity i.insurance i.race i.income i.education i.married i.smoker i.usualplace i.sex i.hispanic
	*Hispanic is removed
	*svy,subpop(agegroup): logistic colreason i.sex i.race i.income i.married i.education i.insurance i.smoker i.usualplace i.comorbidity

*Useful group for looking at differences in young people col reason in just 2018	
	generate year2young = cond( (inlist(year2,2018,201) & ageyoung) , 1,0)
	
*Colpay analysis
	*drop if missing(colpay)
	*generate colpay2 = 0 if regexm(colpay,"none")
	*replace colpay2 = "part or full" if regexm(colpay,"part")
	*replace colpay2 = "part or full" if regexm(colpay,"all")
	*drop if missing(colpay2)
	
	


