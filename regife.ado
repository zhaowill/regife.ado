/***************************************************************************************************

***************************************************************************************************/
program define regife, sortpreserve
	version 12
	syntax [varlist(min=1 numeric fv ts)] [if] [in] [aweight fweight pweight iweight] , Factors(string) Dimension(int)    [reps(int 0) CLuster(string) *]


	/* syntax factors */
	while (regexm("`factors'", "[ ][ ]+")) {
		local factors : subinstr local factors "  " " ", all
	}
	local factors : subinstr local factors " =" "=", all
	local factors : subinstr local factors "= " "=", all

	cap assert `: word count `factors'' == 2
	if _rc{
		di as error "There must be exactly two variables in the option factors"
		exit 
	}

	forv i = 1/2{	 
		local f : word `i' of `factors'
		if regexm("`f'", "(.+)=(.+)"){
			local id`i'gen `=regexs(1)'
			local id`i' = regexs(2)
			forval d = 1/`dimension'{
				cap confirm new variable `id`i'gen'_`d'
				if _rc{
					if _rc == 198{
						di as error "variable `id`i'gen'_`d' is not a valid name"
					}
					else if _rc == 110{
						di as error "variable `id`i'gen'_`d' already defined"
					}
					exit 198
				}
			}
		}
		else{
			local id`i' `f'
		}
		confirm var `id`i''
	}

	if ("`weight'"!=""){
		local wtype `weight'
		local wvar  `=subinstr("`exp'","=","", .)'
	}



	/* touse */
	marksample touse
	markout `touse' `id1' `id2' `wvar', strok



	/*syntax varlist  */
	fvrevar `varlist' if `touse'
	local varlist = r(varlist)
	foreach v in `varlist'{
		local tvar : char `v'[tsrevar]
		local fvar : char `v'[fvrevar]
		if "`tvar'`fvar'" ~=""{
			local namelist `namelist'  `tvar'`fvar'
		}
		else{
			local namelist `namelist' `v'
		}
	}
	tokenize `varlist'
	local y `1'
	macro shift 
	local x `*'
	tokenize `namelist'
	local yname `1'
	macro shift 
	local xname `*'



	if `reps' == 0 {
		di as text "Use the option reps() to compute correct Standard Errors"
	innerregife `anything', dimension(`dimension') id1(`id1') id2(`id2') id1gen(`id1gen') id2gen(`id2gen') y(`y') x(`x') yname(`yname') xname(`xname') touse(`touse') wtype(`wtype') wvar(`wvar') `options'

	}
	else{
		if "`id1gen'`id2gen'" ~= ""{
				qui innerregife `anything', dimension(`dimension') id1(`id1') id2(`id2') id1gen(`id1gen') id2gen(`id2gen') y(`y') x(`x') yname(`yname') xname(`xname') touse(`touse') wtype(`wtype') wvar(`wvar') `options'
		}
		if "`cluster'" == ""{
			bootstrap, reps(`reps') : ///
			innerregife `anything', dimension(`dimension') id1(`id1') id2(`id2') y(`y') x(`x') yname(`yname') xname(`xname') touse(`touse') wtype(`wtype') wvar(`wvar')  `options'
		}
		else{
			tempvar clusterid
			tsset, clear
			bootstrap, reps(`reps') cluster(`cluster') idcluster(`clusterid'): ///
			innerregife `anything', dimension(`dimension') id1(`id1') id2(`id2') y(`y') x(`x') yname(`yname') xname(`xname') touse(`touse') wtype(`wtype') wvar(`wvar') `options'
		}
	}
end


