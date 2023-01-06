#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_data_and_control_files: swo2023_v001.dat // swo2023_v001.ctl
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
1  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS3)
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
#
4 # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)
1 # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area
1 #  number of recruitment settlement assignments 
0 # unused option
#GPattern month  area  age (for each settlement assignment)
 1 7 1 0
#
#_Cond 0 # N_movement_definitions goes here if Nareas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
0 #_Nblock_Patterns
#_Cond 0 #_blocks_per_pattern 
# begin and end years of blocks
#
# controls for all timevary parameters 
1 #_time-vary parm bound check (1=warn relative to base parm bounds; 3=no bound check); Also see env (3) and dev (5) options to constrain with base bounds
#
# AUTOGEN
 0 0 0 0 0 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen time-varying parms of this category; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
#_Available timevary codes
#_Block types: 0: P_block=P_base*exp(TVP); 1: P_block=P_base+TVP; 2: P_block=TVP; 3: P_block=P_block(-1) + TVP
#_Block_trends: -1: trend bounded by base parm min-max and parms in transformed units (beware); -2: endtrend and infl_year direct values; -3: end and infl as fraction of base range
#_EnvLinks:  1: P(y)=P_base*exp(TVP*env(y));  2: P(y)=P_base+TVP*env(y);  3: P(y)=f(TVP,env_Zscore) w/ logit to stay in min-max;  4: P(y)=2.0/(1.0+exp(-TVP1*env(y) - TVP2))
#_DevLinks:  1: P(y)*=exp(dev(y)*dev_se;  2: P(y)+=dev(y)*dev_se;  3: random walk;  4: zero-reverting random walk with rho;  5: like 4 with logit transform to stay in base min-max
#_DevLinks(more):  21-25 keep last dev for rest of years
#
#_Prior_codes:  0=none; 6=normal; 1=symmetric beta; 2=CASAL's beta; 3=lognormal; 4=lognormal with biascorr; 5=gamma
#
# setup for M, growth, wt-len, maturity, fecundity, (hermaphro), recr_distr, cohort_grow, (movement), (age error), (catch_mult), sex ratio 
#_NATMORT
3 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
 #_Age_natmort_by sex x growthpattern (nest GP in sex)
 0.42 0.37 0.32 0.27 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22
 0.4 0.38 0.38 0.37 0.37 0.37 0.36 0.36 0.36 0.36 0.36 0.36 0.36 0.36 0.36 0.36
#
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
1 #_Age(post-settlement)_for_L1;linear growth below this
15 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0  #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
#
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
2 #_First_Mature_Age
1 #_fecundity_at_length option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset**; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#_** in option 1, any male parameter with value = 0.0 and phase <0 is set equal to female parameter
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
# Sex: 1  BioPattern: 1  Growth
 50 200 97.7 97.7 99 0 -4 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 100 300 226.3 226.3 99 0 -2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.05 0.3 0.246 0.25 99 0 -4 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.01 0.5 0.1 0.1 99 0 -3 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.01 0.5 0.15 0.15 99 0 -3 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 0 3 1.3e-05 1.3e-05 99 0 -3 0 0 0 0 0 0 0 # Wtlen_1_Fem_GP_1
 0 4 3.07 3.07 99 0 -3 0 0 0 0 0 0 0 # Wtlen_2_Fem_GP_1
# Sex: 1  BioPattern: 1  Maturity&Fecundity
 1 200 143.68 143.68 99 0 -3 0 0 0 0 0 0 0 # Mat50%_Fem_GP_1
 -3 3 -0.1034 -0.1034 99 0 -3 0 0 0 0 0 0 0 # Mat_slope_Fem_GP_1
 0 3 1 1 99 0 -3 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem_GP_1
 0 3 0 0 99 0 -3 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem_GP_1
# Sex: 2  BioPattern: 1  NatMort
# Sex: 2  BioPattern: 1  Growth
 50 200 99 99 99 0 -4 0 0 0 0 0 0 0 # L_at_Amin_Mal_GP_1
 100 250 206.4 206.4 99 0 -2 0 0 0 0 0 0 0 # L_at_Amax_Mal_GP_1
 0.05 0.3 0.271 0.271 99 0 -4 0 0 0 0 0 0 0 # VonBert_K_Mal_GP_1
 0.01 0.5 0.1 0.1 99 0 -3 0 0 0 0 0 0 0 # CV_young_Mal_GP_1
 0.01 0.5 0.15 0.15 99 0 -3 0 0 0 0 0 0 0 # CV_old_Mal_GP_1
# Sex: 2  BioPattern: 1  WtLen
 0 3 1.3e-05 1.3e-05 99 0 -3 0 0 0 0 0 0 0 # Wtlen_1_Mal_GP_1
 0 4 3.07 3.07 99 0 -3 0 0 0 0 0 0 0 # Wtlen_2_Mal_GP_1
# Hermaphroditism
#  Recruitment Distribution 
#  Cohort growth dev base
 0.1 10 1 1 1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
#  Age Error from parameters
#  catch multiplier
#  fraction female, by GP
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
#  M2 parameter for each predator fleet
#
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm
1  # 0/1 to use steepness in initial equ recruitment calculation
1  #  future feature:  0/1 to make realized sigmaR a function of SR curvature
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
             3            50       6.5          9.3            99             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           0.2             1           0.9           0.9            99             0         -4          0          0          0          0          0          0          0 # SR_BH_steep
             0             2           0.6           0.6            99             0         -3          0          0          0          0          0          0          0 # SR_sigmaR
            -5             5             0             0            99             0         -1          0          0          0          0          0          0          0 # SR_regime
             0             0             0             0            99             0         -1          0          0          0          0          0          0          0 # SR_autocorr
#_no timevary SR parameters
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1975 # first year of main recr_devs; early devs can preceed this era
2021 # last year of main recr_devs; forecast devs start in following year
3 #_recdev phase 
1 # (0/1) to read 13 advanced options
 1960 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 5 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1963.5 #_last_yr_nobias_adj_in_MPD; begin of ramp
 2002.3 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2014.6 #_last_yr_fullbias_adj_in_MPD
 2017.3 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.9077 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
 0 #_period of cycles in recruitment (N parms read below)
 -5 #min rec_dev
 5 #max rec_dev
 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_Yr Input_value
#
# all recruitment deviations
#  1960E 1961E 1962E 1963E 1964E 1965E 1966E 1967E 1968E 1969E 1970E 1971E 1972E 1973E 1974E 1975R 1976R 1977R 1978R 1979R 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021R 2022F
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#Fishing Mortality info 
0.5 # F ballpark value in units of annual_F
-1960 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
4 # max F (methods 2-4) or harvest fraction (method 1)
5  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 4
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0 3 0.0729936 0.1 99 0 1 # InitF_seas_1_flt_1F1_JPN_WCNPO_OSDWLL_early_Area1
 #
# F rates by fleet x season
# Yr:  1975 1975 1975 1975 1976 1976 1976 1976 1977 1977 1977 1977 1978 1978 1978 1978 1979 1979 1979 1979 1980 1980 1980 1980 1981 1981 1981 1981 1982 1982 1982 1982 1983 1983 1983 1983 1984 1984 1984 1984 1985 1985 1985 1985 1986 1986 1986 1986 1987 1987 1987 1987 1988 1988 1988 1988 1989 1989 1989 1989 1990 1990 1990 1990 1991 1991 1991 1991 1992 1992 1992 1992 1993 1993 1993 1993 1994 1994 1994 1994 1995 1995 1995 1995 1996 1996 1996 1996 1997 1997 1997 1997 1998 1998 1998 1998 1999 1999 1999 1999 2000 2000 2000 2000 2001 2001 2001 2001 2002 2002 2002 2002 2003 2003 2003 2003 2004 2004 2004 2004 2005 2005 2005 2005 2006 2006 2006 2006 2007 2007 2007 2007 2008 2008 2008 2008 2009 2009 2009 2009 2010 2010 2010 2010 2011 2011 2011 2011 2012 2012 2012 2012 2013 2013 2013 2013 2014 2014 2014 2014 2015 2015 2015 2015 2016 2016 2016 2016 2017 2017 2017 2017 2018 2018 2018 2018 2019 2019 2019 2019 2020 2020 2020 2020 2021 2021 2021 2021 2022 2022 2022 2022
# seas:  1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4
# F1_JPN_WCNPO_OSDWLL_early_Area1 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
# F2_JPN_WCNPO_OSDWCOLL_late_Area1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F3_JPN_EPO_OSDWLL 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 0 4 4 4 0 4 4 4 4 0 0 0 0 0 0 0 0 0 4 4 4 0 0 4 0 0 4 4 0 0 0 0 0 0 0 0 0 0 0 0 4 0 0 0 4 0 4 0 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
# F4_JPN_WCNPO_OSDF 0.391532 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
# F5_JPN_WCNPO_CODF 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F6_JPN_WCNPO_Other_early 0.132318 1.63344 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
# F7_JPN_WCNPO_Other_late 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F8_TWN_WCNPO_DWLL_late 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F9_TWN_WCNPO_DWLL_early 0.00424941 0.0524583 0.165058 4 4 4 4 4 4 4 4 4 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
# F10_TWN_WCNPO_Other 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F11_US_WCNPO_LL_deep 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F12_US_WCNPO_LL_shallow_late 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 0 4 4 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 4 4 4 0 4 4 4 0 4 4 4 4 4 4 4 0 4 4 4 4 4 4 4 0 4 4 4 0 0 4 0 0 0 4 0 0 4 4 4 0 4 0.0851064 0.0851064 0 0.0851064
# F13_US_WCNPO_LL_shallow_early 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
# F14_US_WCNPO_GN 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F15_US_WCNPO_Other 0.0835228 1.03108 3.24424 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F16_JPN_WCNPO_OSDWLL_early_Area2 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
# F17_JPN_WCNPO_OSDWLL_late_Area2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F18_WCPFC 0.0208074 0.238776 1.60732 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
# F19_IATTC 2.24523 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0.0851064 0.0851064 0.0851064 0.0851064
#
#_Q_setup for fleets with cpue or survey data
#_1:  fleet number
#_2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
        20         1         0         0         0         1  #  S1_JPN_WCNPO_OSDWLL_early_Area1
        21         1         0         0         0         1  #  S2_JPN_WCNPO_OSDWCOLL_late_Area1
        22         1         0         0         0         1  #  S3_JPN_WCNPO_OSDWLL_early_Area2
        23         1         0         0         0         1  #  S4_JPN_WCNPO_OSDWLL_late_Area2
        24         1         0         0         0         1  #  S5_TWN_WCNPO_DWLL_late
        25         1         0         0         0         1  #  S6_US_WCNPO_LL_deep
        26         1         0         0         0         1  #  S7_US_WCNPO_LL_shallow_early
        27         1         0         0         0         1  #  S8_US_WCNPO_LL_shallow_late
-9999 0 0 0 0 0
#
#_Q_parms(if_any);Qunits_are_ln(q)
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
           -15             0       -7.07092            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S1_JPN_WCNPO_OSDWLL_early_Area1(20)
           -15             0       -7.88413            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S2_JPN_WCNPO_OSDWCOLL_late_Area1(21)
           -15             0       -6.25045            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S3_JPN_WCNPO_OSDWLL_early_Area2(22)
           -15             0       -6.85719            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S4_JPN_WCNPO_OSDWLL_late_Area2(23)
           -15             0       -6.9952            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S5_TWN_WCNPO_DWLL_late(24)
           -15             0       -1.45512             -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S6_US_WCNPO_LL_deep(25)
           -15             0        -10.139             -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S7_US_WCNPO_LL_shallow_early(26)
           -15             0       -10.5332             -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S8_US_WCNPO_LL_shallow_late(27)
#_no timevary Q parameters
#
#_size_selex_patterns
#Pattern:_0;  parm=0; selex=1.0 for all sizes
#Pattern:_1;  parm=2; logistic; with 95% width specification
#Pattern:_5;  parm=2; mirror another size selex; PARMS pick the min-max bin to mirror
#Pattern:_11; parm=2; selex=1.0  for specified min-max population length bin range
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_6;  parm=2+special; non-parm len selex
#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (average over bin range)
#Pattern:_8;  parm=8; double_logistic with smooth transitions and constant above Linf option
#Pattern:_9;  parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset
#Pattern:_21; parm=2+special; non-parm len selex, read as pairs of size, then selex
#Pattern:_22; parm=4; double_normal as in CASAL
#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0
#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners
#Pattern:_2;  parm=6; double_normal with sel(minL) and sel(maxL), using joiners, back compatibile version of 24 with 3.30.18 and older
#Pattern:_25; parm=3; exponential-logistic in length
#Pattern:_27; parm=special+3; cubic spline in length; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=special+3+2; cubic spline; like 27, with 2 additional param for scaling (average over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
#_Pattern Discard Male Special
 24 0 0 0 # 1 F1_JPN_WCNPO_OSDWLL_early_Area1
 24 0 0 0 # 2 F2_JPN_WCNPO_OSDWCOLL_late_Area1
 24 0 0 0 # 3 F3_JPN_EPO_OSDWLL
 15 0 0 3 # 4 F4_JPN_WCNPO_OSDF
 24 0 0 0 # 5 F5_JPN_WCNPO_CODF
 15 0 0 1 # 6 F6_JPN_WCNPO_Other_early
 15 0 0 2 # 7 F7_JPN_WCNPO_Other_late
 24 0 0 0 # 8 F8_TWN_WCNPO_DWLL_late
 15 0 0 8 # 9 F9_TWN_WCNPO_DWLL_early
 15 0 0 2 # 10 F10_TWN_WCNPO_Other
 24 0 0 0 # 11 F11_US_WCNPO_LL_deep
 24 0 0 0 # 12 F12_US_WCNPO_LL_shallow_late
 24 0 0 0 # 13 F13_US_WCNPO_LL_shallow_early
 15 0 0 8 # 14 F14_US_WCNPO_GN
 15 0 0 8 # 15 F15_US_WCNPO_Other
 15 0 0 11 # 16 F16_JPN_WCNPO_OSDWLL_early_Area2
 15 0 0 11 # 17 F17_JPN_WCNPO_OSDWLL_late_Area2
 15 0 0 8 # 18 F18_WCPFC
 24 0 0 0 # 19 F19_IATTC
 15 0 0 1 # 20 S1_JPN_WCNPO_OSDWLL_early_Area1
 15 0 0 2 # 21 S2_JPN_WCNPO_OSDWCOLL_late_Area1
 15 0 0 11 # 22 S3_JPN_WCNPO_OSDWLL_early_Area2
 15 0 0 11 # 23 S4_JPN_WCNPO_OSDWLL_late_Area2
 15 0 0 8 # 24 S5_TWN_WCNPO_DWLL_late
 15 0 0 11 # 25 S6_US_WCNPO_LL_deep
 15 0 0 13 # 26 S7_US_WCNPO_LL_shallow_early
 15 0 0 12 # 27 S8_US_WCNPO_LL_shallow_late
#
#_age_selex_patterns
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage
#Pattern:_11; parm=2; selex=1.0  for specified min-max age
#Pattern:_12; parm=2; age logistic
#Pattern:_13; parm=8; age double logistic. Recommend using pattern 18 instead.
#Pattern:_14; parm=nages+1; age empirical
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_16; parm=2; Coleraine - Gaussian
#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (average over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (average over bin range)
#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder
#_Pattern Discard Male Special
 10 0 0 0 # 1 F1_JPN_WCNPO_OSDWLL_early_Area1
 10 0 0 0 # 2 F2_JPN_WCNPO_OSDWCOLL_late_Area1
 10 0 0 0 # 3 F3_JPN_EPO_OSDWLL
 10 0 0 0 # 4 F4_JPN_WCNPO_OSDF
 10 0 0 0 # 5 F5_JPN_WCNPO_CODF
 10 0 0 0 # 6 F6_JPN_WCNPO_Other_early
 10 0 0 0 # 7 F7_JPN_WCNPO_Other_late
 10 0 0 0 # 8 F8_TWN_WCNPO_DWLL_late
 10 0 0 0 # 9 F9_TWN_WCNPO_DWLL_early
 10 0 0 0 # 10 F10_TWN_WCNPO_Other
 10 0 0 0 # 11 F11_US_WCNPO_LL_deep
 10 0 0 0 # 12 F12_US_WCNPO_LL_shallow_late
 10 0 0 0 # 13 F13_US_WCNPO_LL_shallow_early
 10 0 0 0 # 14 F14_US_WCNPO_GN
 10 0 0 0 # 15 F15_US_WCNPO_Other
 10 0 0 0 # 16 F16_JPN_WCNPO_OSDWLL_early_Area2
 10 0 0 0 # 17 F17_JPN_WCNPO_OSDWLL_late_Area2
 10 0 0 0 # 18 F18_WCPFC
 10 0 0 0 # 19 F19_IATTC
 10 0 0 0 # 20 S1_JPN_WCNPO_OSDWLL_early_Area1
 10 0 0 0 # 21 S2_JPN_WCNPO_OSDWCOLL_late_Area1
 10 0 0 0 # 22 S3_JPN_WCNPO_OSDWLL_early_Area2
 10 0 0 0 # 23 S4_JPN_WCNPO_OSDWLL_late_Area2
 10 0 0 0 # 24 S5_TWN_WCNPO_DWLL_late
 10 0 0 0 # 25 S6_US_WCNPO_LL_deep
 10 0 0 0 # 26 S7_US_WCNPO_LL_shallow_early
 10 0 0 0 # 27 S8_US_WCNPO_LL_shallow_late
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   F1_JPN_WCNPO_OSDWLL_early_Area1 LenSelex
            53           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  Size_DblN_peak_F1_JPN_WCNPO_OSDWLL_early_Area1(1)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_F1_JPN_WCNPO_OSDWLL_early_Area1(1)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_F1_JPN_WCNPO_OSDWLL_early_Area1(1)
            -2            10       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_F1_JPN_WCNPO_OSDWLL_early_Area1(1)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_F1_JPN_WCNPO_OSDWLL_early_Area1(1)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_F1_JPN_WCNPO_OSDWLL_early_Area1(1)
# 2   F2_JPN_WCNPO_OSDWCOLL_late_Area1 LenSelex
            53           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  Size_DblN_peak_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -2            10       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
# 3   F3_JPN_EPO_OSDWLL LenSelex
            53           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  Size_DblN_peak_F3_JPN_EPO_OSDWLL(3)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_F3_JPN_EPO_OSDWLL(3)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_F3_JPN_EPO_OSDWLL(3)
            -2            10       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_F3_JPN_EPO_OSDWLL(3)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_F3_JPN_EPO_OSDWLL(3)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_F3_JPN_EPO_OSDWLL(3)
# 4   F4_JPN_WCNPO_OSDF LenSelex
# 5   F5_JPN_WCNPO_CODF LenSelex
            50           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  Size_DblN_peak_F5_JPN_WCNPO_CODF(5)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_F5_JPN_WCNPO_CODF(5)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_F5_JPN_WCNPO_CODF(5)
            -2            15       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_F5_JPN_WCNPO_CODF(5)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_F5_JPN_WCNPO_CODF(5)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_F5_JPN_WCNPO_CODF(5)
# 6   F6_JPN_WCNPO_Other_early LenSelex
# 7   F7_JPN_WCNPO_Other_late LenSelex
# 8   F8_TWN_WCNPO_DWLL_late LenSelex
            53           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  Size_DblN_peak_F8_TWN_WCNPO_DWLL_late(8)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_F8_TWN_WCNPO_DWLL_late(8)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_F8_TWN_WCNPO_DWLL_late(8)
            -2            10       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_F8_TWN_WCNPO_DWLL_late(8)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_F8_TWN_WCNPO_DWLL_late(8)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_F8_TWN_WCNPO_DWLL_late(8)
# 9   F9_TWN_WCNPO_DWLL_early LenSelex
# 10   F10_TWN_WCNPO_Other LenSelex
# 11   F11_US_WCNPO_LL_deep LenSelex
            30           250       169.111            90          0.05             1          2          0          0          0          0          0          0          0  #  Size_DblN_peak_F11_US_WCNPO_LL_deep(11)
            -5             3      -3.44686           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_F11_US_WCNPO_LL_deep(11)
            -4            12       7.96829             6          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_F11_US_WCNPO_LL_deep(11)
            -6            15       8.67979           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_F11_US_WCNPO_LL_deep(11)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_F11_US_WCNPO_LL_deep(11)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_F11_US_WCNPO_LL_deep(11)
# 12   F12_US_WCNPO_LL_shallow_late LenSelex
            53           250       169.111            90          0.05             1          2          0          0          0          0          0          0          0  #  Size_DblN_peak_F12_US_WCNPO_LL_shallow_late(12)
            -5             3      -3.44686           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_F12_US_WCNPO_LL_shallow_late(12)
            -4            12       7.96829             6          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_F12_US_WCNPO_LL_shallow_late(12)
            -6            10       8.67979           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_F12_US_WCNPO_LL_shallow_late(12)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_F12_US_WCNPO_LL_shallow_late(12)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_F12_US_WCNPO_LL_shallow_late(12)
# 13   F13_US_WCNPO_LL_shallow_early LenSelex
            53           250       169.111            90          0.05             1          2          0          0          0          0          0          0          0  #  Size_DblN_peak_F13_US_WCNPO_LL_shallow_early(13)
            -5             3      -3.44686           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_F13_US_WCNPO_LL_shallow_early(13)
            -4            12       7.96829             6          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_F13_US_WCNPO_LL_shallow_early(13)
            -6            10       8.67979           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_F13_US_WCNPO_LL_shallow_early(13)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_F13_US_WCNPO_LL_shallow_early(13)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_F13_US_WCNPO_LL_shallow_early(13)
# 14   F14_US_WCNPO_GN LenSelex
# 15   F15_US_WCNPO_Other LenSelex
# 16   F16_JPN_WCNPO_OSDWLL_early_Area2 LenSelex
# 17   F17_JPN_WCNPO_OSDWLL_late_Area2 LenSelex
# 18   F18_WCPFC LenSelex
# 19   F19_IATTC LenSelex
            53           250       169.111            90          0.05             1          2          0          0          0          0          0          0          0  #  Size_DblN_peak_F19_IATTC(19)
            -5             3      -3.44686           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_F19_IATTC(19)
            -4            12       7.96829             6          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_F19_IATTC(19)
            -6            10       8.67979           0.1          0.05             1          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_F19_IATTC(19)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_F19_IATTC(19)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_F19_IATTC(19)
# 20   S1_JPN_WCNPO_OSDWLL_early_Area1 LenSelex
# 21   S2_JPN_WCNPO_OSDWCOLL_late_Area1 LenSelex
# 22   S3_JPN_WCNPO_OSDWLL_early_Area2 LenSelex
# 23   S4_JPN_WCNPO_OSDWLL_late_Area2 LenSelex
# 24   S5_TWN_WCNPO_DWLL_late LenSelex
# 25   S6_US_WCNPO_LL_deep LenSelex
# 26   S7_US_WCNPO_LL_shallow_early LenSelex
# 27   S8_US_WCNPO_LL_shallow_late LenSelex
# 1   F1_JPN_WCNPO_OSDWLL_early_Area1 AgeSelex
# 2   F2_JPN_WCNPO_OSDWCOLL_late_Area1 AgeSelex
# 3   F3_JPN_EPO_OSDWLL AgeSelex
# 4   F4_JPN_WCNPO_OSDF AgeSelex
# 5   F5_JPN_WCNPO_CODF AgeSelex
# 6   F6_JPN_WCNPO_Other_early AgeSelex
# 7   F7_JPN_WCNPO_Other_late AgeSelex
# 8   F8_TWN_WCNPO_DWLL_late AgeSelex
# 9   F9_TWN_WCNPO_DWLL_early AgeSelex
# 10   F10_TWN_WCNPO_Other AgeSelex
# 11   F11_US_WCNPO_LL_deep AgeSelex
# 12   F12_US_WCNPO_LL_shallow_late AgeSelex
# 13   F13_US_WCNPO_LL_shallow_early AgeSelex
# 14   F14_US_WCNPO_GN AgeSelex
# 15   F15_US_WCNPO_Other AgeSelex
# 16   F16_JPN_WCNPO_OSDWLL_early_Area2 AgeSelex
# 17   F17_JPN_WCNPO_OSDWLL_late_Area2 AgeSelex
# 18   F18_WCPFC AgeSelex
# 19   F19_IATTC AgeSelex
# 20   S1_JPN_WCNPO_OSDWLL_early_Area1 AgeSelex
# 21   S2_JPN_WCNPO_OSDWCOLL_late_Area1 AgeSelex
# 22   S3_JPN_WCNPO_OSDWLL_early_Area2 AgeSelex
# 23   S4_JPN_WCNPO_OSDWLL_late_Area2 AgeSelex
# 24   S5_TWN_WCNPO_DWLL_late AgeSelex
# 25   S6_US_WCNPO_LL_deep AgeSelex
# 26   S7_US_WCNPO_LL_shallow_early AgeSelex
# 27   S8_US_WCNPO_LL_shallow_late AgeSelex
#_No_Dirichlet parameters
#_no timevary selex parameters
#
0   #  use 2D_AR1 selectivity(0/1)
#_no 2D_AR1 selex offset used
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read and autogen if tag data exist; 1=read
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# no timevary parameters
#
#
# Input variance adjustments factors: 
 #_1=add_to_survey_CV
 #_2=add_to_discard_stddev
 #_3=add_to_bodywt_CV
 #_4=mult_by_lencomp_N
 #_5=mult_by_agecomp_N
 #_6=mult_by_size-at-age_N
 #_7=mult_by_generalized_sizecomp
#_Factor  Fleet  Value
 -9999   1    0  # terminator
#
3 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 11 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
 9 1 1 0 0
 10 1 1 1 1
-9999  1  1  1  1  #  terminator
#
# lambdas (for info only; columns are phases)
#  0 0 0 #_CPUE/survey:_1
#  0 0 0 #_CPUE/survey:_2
#  0 0 0 #_CPUE/survey:_3
#  0 0 0 #_CPUE/survey:_4
#  0 0 0 #_CPUE/survey:_5
#  0 0 0 #_CPUE/survey:_6
#  0 0 0 #_CPUE/survey:_7
#  0 0 0 #_CPUE/survey:_8
#  0 0 0 #_CPUE/survey:_9
#  0 0 0 #_CPUE/survey:_10
#  0 0 0 #_CPUE/survey:_11
#  0 0 0 #_CPUE/survey:_12
#  0 0 0 #_CPUE/survey:_13
#  0 0 0 #_CPUE/survey:_14
#  0 0 0 #_CPUE/survey:_15
#  0 0 0 #_CPUE/survey:_16
#  0 0 0 #_CPUE/survey:_17
#  0 0 0 #_CPUE/survey:_18
#  0 0 0 #_CPUE/survey:_19
#  1 1 1 #_CPUE/survey:_20
#  1 1 1 #_CPUE/survey:_21
#  1 1 1 #_CPUE/survey:_22
#  1 1 1 #_CPUE/survey:_23
#  1 1 1 #_CPUE/survey:_24
#  1 1 1 #_CPUE/survey:_25
#  1 1 1 #_CPUE/survey:_26
#  1 1 1 #_CPUE/survey:_27
#  1 1 1 #_lencomp:_1
#  1 1 1 #_lencomp:_2
#  0 0 0 #_lencomp:_3
#  0 0 0 #_lencomp:_4
#  1 1 1 #_lencomp:_5
#  0 0 0 #_lencomp:_6
#  0 0 0 #_lencomp:_7
#  1 1 1 #_lencomp:_8
#  0 0 0 #_lencomp:_9
#  0 0 0 #_lencomp:_10
#  1 1 1 #_lencomp:_11
#  1 1 1 #_lencomp:_12
#  1 1 1 #_lencomp:_13
#  0 0 0 #_lencomp:_14
#  0 0 0 #_lencomp:_15
#  0 0 0 #_lencomp:_16
#  0 0 0 #_lencomp:_17
#  0 0 0 #_lencomp:_18
#  1 1 1 #_lencomp:_19
#  0 0 0 #_lencomp:_20
#  0 0 0 #_lencomp:_21
#  0 0 0 #_lencomp:_22
#  0 0 0 #_lencomp:_23
#  0 0 0 #_lencomp:_24
#  0 0 0 #_lencomp:_25
#  0 0 0 #_lencomp:_26
#  0 0 0 #_lencomp:_27
#  0 0 0 #_init_equ_catch1
#  1 1 1 #_init_equ_catch2
#  1 1 1 #_init_equ_catch3
#  1 1 1 #_init_equ_catch4
#  1 1 1 #_init_equ_catch5
#  1 1 1 #_init_equ_catch6
#  1 1 1 #_init_equ_catch7
#  1 1 1 #_init_equ_catch8
#  1 1 1 #_init_equ_catch9
#  1 1 1 #_init_equ_catch10
#  1 1 1 #_init_equ_catch11
#  1 1 1 #_init_equ_catch12
#  1 1 1 #_init_equ_catch13
#  1 1 1 #_init_equ_catch14
#  1 1 1 #_init_equ_catch15
#  1 1 1 #_init_equ_catch16
#  1 1 1 #_init_equ_catch17
#  1 1 1 #_init_equ_catch18
#  1 1 1 #_init_equ_catch19
#  1 1 1 #_init_equ_catch20
#  1 1 1 #_init_equ_catch21
#  1 1 1 #_init_equ_catch22
#  1 1 1 #_init_equ_catch23
#  1 1 1 #_init_equ_catch24
#  1 1 1 #_init_equ_catch25
#  1 1 1 #_init_equ_catch26
#  1 1 1 #_init_equ_catch27
#  1 1 1 #_recruitments
#  1 1 1 #_parameter-priors
#  1 1 1 #_parameter-dev-vectors
#  1 1 1 #_crashPenLambda
#  0 0 0 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

