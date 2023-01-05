#V3.30.08.03-safe;_2017_09_29;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_11.6
#_data_and_control_files: dataV1_10.dat // controlV1_10.ctl
#V3.30.08.03-safe;_2017_09_29;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_11.6
#_user_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_user_info_available_at:https://vlab.ncep.noaa.gov/group/stock-synthesis
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
1  #_N_Growth_Patterns
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Morph_between/within_stdev_ratio (no read if N_morphs=1)
#_Cond  1 #vector_Morphdist_(-1_in_first_val_gives_normal_approx)
#
2 # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity
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
1 #_env/block/dev_adjust_method for all time-vary parms (1=warn relative to base parm bounds; 3=no bound check)
#  autogen
0 0 0 0 0 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen all time-varying parms; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
# 
#
# setup for M, growth, maturity, fecundity, recruitment distibution, movement 
#
3 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate
 #_Age_natmort_by sex x growthpattern
 0.42 0.37 0.32 0.27 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.22
 0.4 0.38 0.38 0.37 0.37 0.37 0.36 0.36 0.36 0.36 0.36 0.36 0.36 0.36 0.36 0.36
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K; 4=not implemented
1 #_Age(post-settlement)_for_L1;linear growth below this
15 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (fixed at 0.2 in 3.24; value should approx initial Z; -999 replicates 3.24)
0  #_placeholder for future growth feature
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
2 #_First_Mature_Age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
 50 200 97.7 97.7 99 0 -4 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 100 300 226.3 226.3 99 0 -2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.05 0.3 0.246 0.25 99 0 -4 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.01 0.5 0.1 0.1 99 0 -3 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.01 0.5 0.15 0.15 99 0 -3 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
 0 3 1.3e-05 1.3e-05 99 0 -3 0 0 0 0 0 0 0 # Wtlen_1_Fem
 0 4 3.07 3.07 99 0 -3 0 0 0 0 0 0 0 # Wtlen_2_Fem
 1 200 143.68 143.68 99 0 -3 0 0 0 0 0 0 0 # Mat50%_Fem
 -3 3 -0.1034 -0.1034 99 0 -3 0 0 0 0 0 0 0 # Mat_slope_Fem
 0 3 1 1 99 0 -3 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem
 0 3 0 0 99 0 -3 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem
 50 200 99 99 99 0 -4 0 0 0 0 0 0 0 # L_at_Amin_Mal_GP_1
 100 250 206.4 206.4 99 0 -2 0 0 0 0 0 0 0 # L_at_Amax_Mal_GP_1
 0.05 0.3 0.271 0.271 99 0 -4 0 0 0 0 0 0 0 # VonBert_K_Mal_GP_1
 0.01 0.5 0.1 0.1 99 0 -3 0 0 0 0 0 0 0 # CV_young_Mal_GP_1
 0.01 0.5 0.15 0.15 99 0 -3 0 0 0 0 0 0 0 # CV_old_Mal_GP_1
 0 3 1.3e-05 1.3e-05 99 0 -3 0 0 0 0 0 0 0 # Wtlen_1_Mal
 0 4 3.07 3.07 99 0 -3 0 0 0 0 0 0 0 # Wtlen_2_Mal
 0 0 0 0 0 0 -4 0 0 0 0 0 0 0 # RecrDist_GP_1
 0 0 0 0 0 0 -4 0 0 0 0 0 0 0 # RecrDist_Area_1
 0 0 0 0 0 0 -4 0 0 0 0 0 0 0 # RecrDist_month_7
 1 1 1 1 1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
#
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
#_Spawner-Recruitment
3 #_SR_function: 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepard_3Parm
1  # 0/1 to use steepness in initial equ recruitment calculation
1  #  future feature:  0/1 to make realized sigmaR a function of SR curvature
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
             3            50       6.83094           9.3            99             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           0.2             1           0.9           0.9            99             0         -4          0          0          0          0          0          0          0 # SR_BH_steep
             0             2           0.6           0.6            99             0         -3          0          0          0          0          0          0          0 # SR_sigmaR
            -5             5             0             0            99             0         -1          0          0          0          0          0          0          0 # SR_regime
             0             0             0             0            99             0         -1          0          0          0          0          0          0          0 # SR_autocorr
1 #do_recdev:  0=none; 1=devvector; 2=simple deviations
1975 # first year of main recr_devs; early devs can preceed this era
2021 # last year of main recr_devs; forecast devs start in following year
3 #_recdev phase 
1 # (0/1) to read 13 advanced options
 1960 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 5 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1963.5 #_last_early_yr_nobias_adj_in_MPD
 2002.3 #_first_yr_fullbias_adj_in_MPD
 2014.6 #_last_yr_fullbias_adj_in_MPD
 2017.3 #_first_recent_yr_nobias_adj_in_MPD
 0.9077 #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)
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
#  1960E 1961E 1962E 1963E 1964E 1965E 1966E 1967E 1968E 1969E 1970E 1971E 1972E 1973E 1974E 1975R 1976R 1977R 1978R 1979R 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017F
#  -0.0195273 -0.00662092 -0.0092369 -0.0127493 -0.0181387 -0.0261113 -0.0379196 -0.0556169 -0.0820407 -0.119799 -0.1699 -0.223246 -0.251857 -0.197295 -0.0145472 -0.0815081 -0.178114 -0.0256049 0.0246331 -0.129046 -0.152633 0.0858876 0.310561 0.474463 0.147018 0.042641 -0.000326637 0.06095 0.00629332 -0.216307 -0.177389 0.391906 -0.0206544 -0.0869772 -0.0815725 -0.204187 -0.468673 0.140032 0.372188 -0.158508 -0.0810358 -0.0100333 -0.00770104 0.37287 0.23572 0.00344993 0.0689789 0.00173073 -0.219633 -0.136761 0.0740547 -0.218258 -0.0583477 -0.012623 -0.0451489 0.00760982 -0.0499464 0
# implementation error by year in forecast:  0
#
#Fishing Mortality info 
0.5 # F ballpark
-1960 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
4 # max F or harvest rate, depends on F_Method
# no additional F input needed for Fmethod 1
# if Fmethod=2; read overall start F value; overall phase; N detailed inputs to read
# if Fmethod=3; read N iterations for tuning for Fmethod 3
5  # N iterations for tuning F in hybrid method (recommend 3 to 7)
#
#_initial_F_parms; count = 4
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0 3 0.0729936 0.1 99 0 1 # InitF_seas_1_flt_1F1_JPN_WCNPO_OSDWLL_early_Area1
 0 3 0.0723435 0.1 99 0 1 # InitF_seas_2_flt_1F1_JPN_WCNPO_OSDWLL_early_Area1
 0 3 0.0709809 0.1 99 0 1 # InitF_seas_3_flt_1F1_JPN_WCNPO_OSDWLL_early_Area1
 0 3 0.0719997 0.1 99 0 1 # InitF_seas_4_flt_1F1_JPN_WCNPO_OSDWLL_early_Area1
#2017 2226
# F rates by fleet
#_Q_setup for every fleet, even if no survey
#_1:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm)
#_2:  extra input for link, i.e. mirror fleet
#_3:  0/1 to select extra sd parameter
#_4:  0/1 for biasadj or not
#_5:  0/1 to float
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
           -15             0      -6.10362            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S1_JPN_WCNPO_OSDWLL_early_Area1(19)
           -15             0      -6.12306            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S2_JPN_WCNPO_OSDWCOLL_late_Area1(20)
           -15             0      -8.77456            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S3_JPN_WCNPO_OSDWLL_early_Area2(21)
           -15             0      -8.71628            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S4_JPN_WCNPO_OSDWLL_late_Area2(22)
           -15             0      -7.00626            -1            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S6_TWN_WCNPO_DWLL_late(24)
           -15             0      -7.98243             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S7_US_WCNPO_LL_deep(25)
           -15             0       -5.2155             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S8_US_WCNPO_LL_shallow_early(26)
           -15             0      -4.34732             0            99             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S9_US_WCNPO_LL_shallow_late(27)
#_no timevary Q parameters
#
#_size_selex_patterns
#Pattern:_0; parm=0; selex=1.0 for all sizes
#Pattern:_1; parm=2; logistic; with 95% width specification
#Pattern:_5; parm=2; mirror another size selex; PARMS pick the min-max bin to mirror
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_6; parm=2+special; non-parm len selex
#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (average over bin range)
#Pattern:_8; parm=8; New doublelogistic with smooth transitions and constant above Linf option
#Pattern:_9; parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset
#Pattern:_21; parm=2+special; non-parm len selex, read as pairs of size, then selex
#Pattern:_22; parm=4; double_normal as in CASAL
#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0
#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners
#Pattern:_25; parm=3; exponential-logistic in size
#Pattern:_27; parm=3+special; cubic spline 
#Pattern:_42; parm=2+special+3; // like 27, with 2 additional param for scaling (average over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
#_Pattern Discard Male Special
 24	0	0	0	#	1	F1_JPN_WCNPO_OSDWLL_early_Area1  # 1
24	0	0	0	#	2	F2_JPN_WCNPO_OSDWCOLL_late_Area1  # 2
24	0	0	0	#	3	F3_JPN_EPO_OSDWLL #3
15	0	0	3	#	4	F4_JPN_WCNPO_OSDF  # 4
24	0	0	0	#	5	F5_JPN_WCNPO_CODF  # 5
15	0	0	1	#	6	F6_JPN_WCNPO_Other_early  # 6
15	0	0	2	#	7	F7_JPN_WCNPO_Other_late  # 7
24	0	0	0	#	8	F8_TWN_WCNPO_DWLL_late  # 8
15	0	0	8	#	9	F9_TWN_WCNPO_DWLL_early  # 9
15	0	0	2	#	10	F10_TWN_WCNPO_Other  # 10
24	0	0	0	#	11	F11_US_WCNPO_LL_deep  # 11
24	0	0	0	#	12	F12_US_WCNPO_LL_shallow_late  # 12
24	0	0	0	#	13	F13_US_WCNPO_LL_shallow_early  # 13
15	0	0	8	#	14	F14_US_WCNPO_GN  # 14
15	0	0	8	#	15	F15_US_WCNPO_Other  # 15
15	0	0	11	#	16	F16_JPN_WCNPO_OSDWLL_early_Area2  # 16
15	0	0	11	#	17	F17_JPN_WCNPO_OSDWLL_late_Area2  # 17
15	0	0	8	#	18	F18_WCPFC # 18
24	0	0	0	#	19	F19_IATTC  # 19
15	0	0		#	20	S1_JPN_WCNPO_OSDWLL_early_Area1
15	0	0		#	21	S2_JPN_WCNPO_OSDWCOLL_late_Area1
15	0	0		#	22	S3_JPN_WCNPO_OSDWLL_early_Area2
15	0	0		#	23	S4_JPN_WCNPO_OSDWLL_late_Area2
15	0	0		#	24	S5_TWN_WCNPO_DWLL_late
15	0	0		#	25	S6_US_WCNPO_LL_deep
15	0	0		#	26	S7_US_WCNPO_LL_shallow_early
15	0	0		#	27	S8_US_WCNPO_LL_shallow_late
#
#_age_selex_types
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage
#Pattern:_11; parm=2; selex=1.0  for specified min-max age
#Pattern:_12; parm=2; age logistic
#Pattern:_13; parm=8; age double logistic
#Pattern:_14; parm=nages+1; age empirical
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_16; parm=2; Coleraine - Gaussian
#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (average over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age
#Pattern:_42; parm=2+nages+1; // cubic spline; with 2 additional param for scaling (average over bin range)
#_Pattern Discard Male Special
 10 0 0 0 # 1 F1_JPN_WCNPO_OSDWLL_early_Area1
 10 0 0 0 # 2 F2_JPN_WCNPO_OSDWCOLL_late_Area1
 10 0 0 0 # 3 F3_JPN_WCNPO_OSDWLL_early_Area2
 10 0 0 0 # 4 F4_JPN_WCNPO_OSDWLL_late_Area2
 10 0 0 0 # 5 F5_JPN_WCNPO_OSDF
 10 0 0 0 # 6 F6_JPN_WCNPO_CODF
 10 0 0 0 # 7 F7_JPN_WCNPO_Other_early
 10 0 0 0 # 8 F8_JPN_WCNPO_Other_late
 10 0 0 0 # 9 F9_TWN_WCNPO_DWLL_early
 10 0 0 0 # 10 F10_TWN_WCNPO_DWLL_late
 0 0 0 0 # 11 F11_TWN_WCNPO_Other
 0 0 0 0 # 12 F12_US_WCNPO_LL_deep
 0 0 0 0 # 13 F13_US_WCNPO_LL_shallow_early
 0 0 0 0 # 14 F14_US_WCNPO_LL_shallow_late
 0 0 0 0 # 15 F15_US_WCNPO_GN
 0 0 0 0 # 16 F16_US_WCNPO_Other
 0 0 0 0 # 17 F17_WCPFC_LL
 0 0 0 0 # 18 F18_IATTC_LL_Overlap
 0 0 0 0 # 19 S1_JPN_WCNPO_OSDWLL_early_Area1
 0 0 0 0 # 20 S2_JPN_WCNPO_OSDWCOLL_late_Area1
 0 0 0 0 # 21 S3_JPN_WCNPO_OSDWLL_early_Area2
 0 0 0 0 # 22 S4_JPN_WCNPO_OSDWLL_late_Area2
 0 0 0 0 # 23 S5_TWN_WCNPO_DWLL_early
 0 0 0 0 # 24 S6_TWN_WCNPO_DWLL_late
 0 0 0 0 # 25 S7_US_WCNPO_LL_deep
 0 0 0 0 # 26 S8_US_WCNPO_LL_shallow_early
 0 0 0 0 # 27 S9_US_WCNPO_LL_shallow_late
 0 0 0 0 # 28 S10_US_WCNPO_GN
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
            18           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  SizeSel_P1_F1_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P2_F1_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P3_F1_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -2            10       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P4_F1_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P5_F1_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P6_F1_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            18           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  SizeSel_P1_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P2_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P3_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -2            10       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P4_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P5_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P6_F2_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            18           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  SizeSel_P1_F3_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P2_F3_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P3_F3_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -2            10       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P4_F3_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P5_F3_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P6_F3_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            18           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  SizeSel_P1_F5_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P2_F5_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P3_F5_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -2            10       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P4_F5_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P5_F5_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P6_F5_JPN_WCNPO_OSDWCOLL_late_Area1(2)
           18           257       163.913            90          0.05             1          2          0          0          0          0          0          0          0  #  SizeSel_P1_F8_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -8             3      -5.76589           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P2_F8_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -4            12       7.70468             6          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P3_F8_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            -2            10       8.28387           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P4_F8_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P5_F8_JPN_WCNPO_OSDWCOLL_late_Area1(2)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P6_F8_JPN_WCNPO_OSDWCOLL_late_Area1(2)
            18           250       169.111            90          0.05             1          2          0          0          0          0          0          0          0  #  SizeSel_P1_F11_US_WCNPO_LL_shallow_late(14)
            -5             3      -3.44686           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P2_F11_US_WCNPO_LL_shallow_late(14)
            -4            12       7.96829             6          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P3_F11_US_WCNPO_LL_shallow_late(14)
            -6            10       8.67979           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P4_F11_US_WCNPO_LL_shallow_late(14)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P5_F11_US_WCNPO_LL_shallow_late(14)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P6_F11_US_WCNPO_LL_shallow_late(14)
            18           250       169.111            90          0.05             1          2          0          0          0          0          0          0          0  #  SizeSel_P1_F12_US_WCNPO_LL_shallow_late(14)
            -5             3      -3.44686           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P2_F12_US_WCNPO_LL_shallow_late(14)
            -4            12       7.96829             6          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P3_F12_US_WCNPO_LL_shallow_late(14)
            -6            10       8.67979           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P4_F12_US_WCNPO_LL_shallow_late(14)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P5_F12_US_WCNPO_LL_shallow_late(14)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P6_F12_US_WCNPO_LL_shallow_late(14)
            18           250       169.111            90          0.05             1          2          0          0          0          0          0          0          0  #  SizeSel_P1_F13_US_WCNPO_LL_shallow_late(14)
            -5             3      -3.44686           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P2_F13_US_WCNPO_LL_shallow_late(14)
            -4            12       7.96829             6          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P3_F13_US_WCNPO_LL_shallow_late(14)
            -6            10       8.67979           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P4_F13_US_WCNPO_LL_shallow_late(14)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P5_F13_US_WCNPO_LL_shallow_late(14)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P6_F13_US_WCNPO_LL_shallow_late(14)
  18           250       169.111            90          0.05             1          2          0          0          0          0          0          0          0  #  SizeSel_P1_F19_US_WCNPO_LL_shallow_late(14)
            -5             3      -3.44686           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P2_F19_US_WCNPO_LL_shallow_late(14)
            -4            12       7.96829             6          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P3_F19_US_WCNPO_LL_shallow_late(14)
            -6            10       8.67979           0.1          0.05             1          3          0          0          0          0          0          0          0  #  SizeSel_P4_F19_US_WCNPO_LL_shallow_late(14)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P5_F19_US_WCNPO_LL_shallow_late(14)
          -999           999          -999          -999            99             0         -2          0          0          0          0          0          0          0  #  SizeSel_P6_F19_US_WCNPO_LL_shallow_late(14) 
#_no timevary selex parameters
#
0   #  use 2D_AR1 selectivity(0/1):  experimental feature
#_no 2D_AR1 selex offset used
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read; 1=read if tags exist
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
# read 9 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark
#like_comp fleet  phase  value  sizefreq_method
 4 1 1 1 1
 4 2 1 1 1
 4 6 1 1 1
 4 10 1 1 1
 4 13 1 1 1
 4 14 1 1 1
 4 18 1 1 1
 1 23 1 1 1
 1 28 1 1 1
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
#  1 1 1 #_CPUE/survey:_19
#  1 1 1 #_CPUE/survey:_20
#  1 1 1 #_CPUE/survey:_21
#  1 1 1 #_CPUE/survey:_22
#  0 0 0 #_CPUE/survey:_23
#  1 1 1 #_CPUE/survey:_24
#  1 1 1 #_CPUE/survey:_25
#  1 1 1 #_CPUE/survey:_26
#  1 1 1 #_CPUE/survey:_27
#  0 0 0 #_CPUE/survey:_28
#  0 0 0 #_lencomp:_1
#  1 1 1 #_lencomp:_2
#  0 0 0 #_lencomp:_3
#  0 0 0 #_lencomp:_4
#  0 0 0 #_lencomp:_5
#  0 0 0 #_lencomp:_6
#  0 0 0 #_lencomp:_7
#  0 0 0 #_lencomp:_8
#  0 0 0 #_lencomp:_9
#  1 1 1 #_lencomp:_10
#  0 0 0 #_lencomp:_11
#  0 0 0 #_lencomp:_12
#  0 0 0 #_lencomp:_13
#  1 1 1 #_lencomp:_14
#  0 0 0 #_lencomp:_15
#  0 0 0 #_lencomp:_16
#  0 0 0 #_lencomp:_17
#  1 1 1 #_lencomp:_18
#  0 0 0 #_lencomp:_19
#  0 0 0 #_lencomp:_20
#  0 0 0 #_lencomp:_21
#  0 0 0 #_lencomp:_22
#  0 0 0 #_lencomp:_23
#  0 0 0 #_lencomp:_24
#  0 0 0 #_lencomp:_25
#  0 0 0 #_lencomp:_26
#  0 0 0 #_lencomp:_27
#  0 0 0 #_lencomp:_28
#  1 1 1 #_init_equ_catch
#  1 1 1 #_recruitments
#  1 1 1 #_parameter-priors
#  1 1 1 #_parameter-dev-vectors
#  1 1 1 #_crashPenLambda
#  0 0 0 # F_ballpark_lambda
0 # (0/1) read specs for more stddev reporting 
 # 0 1 -1 5 1 5 1 -1 5 # placeholder for selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages
 # placeholder for vector of selex bins to be reported
 # placeholder for vector of growth ages to be reported
 # placeholder for vector of NatAges ages to be reported
999

