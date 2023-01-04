#  --------------------------------------------------------------------------------------------------------------
#   Swordfish do CPUE predictions using Walter's Large Table, aka marginal means
#	Erin Bohaboy erin.bohaboy@noaa.gov

#  --------------------------------------------------------------------------------------------------------------

# ----- PRELIMINARIES
#  rm(list=ls())

 # load libraries.
  library(sqldf)
  library(dplyr)
  library(this.path)
 # library(ggfortify)		#  install.packages('ggfortify')
  library(data.table)		#  install.packages('data.table')
 # library(nFactors)		#  install.packages('nFactors')
 # library(fitdistrplus)
  library(mgcv)
 # library(formula.tools)	
  library(ggplot2)
  library(magrittr)
  library(gridExtra)
  library(grid)
  library(cowplot)
  library(lattice)
  library(ggplotify)
  library(lme4)
  library(gamm4)
  library(emmeans)
  library(statmod)
  library(ggeffects)
  # library(devtools)
  # library(usethis)		# install.packages('usethis')	

   # establish directories using this.path::
   root_dir <- this.path::here(.. = 0)

   # load data
   load(paste0(root_dir, '/1_CPUE_data.RData'))

   # load best models 
   load(paste0(root_dir, '/2_Best_Models.RData')) 

   # creates the workspace
   # save.image("C:\\Users\\Erin.Bohaboy\\Documents\\Swordfish\\3_CPUE_predicted.RData")


###  !!!!!
###	don't forget, fishery closes early some years, so have to account for uneven seasonal coverage.
###	Nicho says: it would be easiest to just use season or month in the actual model.
###	or, he says: use a GAM, then predict at the daily time step or do monthly/seasonal and the "day" 
###		variable being the median for that month/season.
###	If your smooth is very wiggly at the day level then you may want to make predictions daily to 
###	capture that if you feel like it will be missed at month/seasonal scale
###  If sticking with the gamm4 package I would encourage you to consider an interaction between lat/lon
###	additionally, if you like the gam type interface you could just use sdmTMB and move into a full spatiotemporal model
###	sdmTMB can also allow you to put in some temporal structure on the random effects (e.g. AR1) which could help 
###		carry-over predictions from one quarter to the next.
###  ok so for your walters table I would predict at year * quarter * spatial cell
###	where spatial cell is all viable (in terms of the modeled population) cells within your sampling domain
###	then you would average across cells * quarter within year to get your index
###	if you do it this way then you don't have to worry about weighting your strata since all will get equal weight
###	spatial cell could be 5x5 if you wanted


# make a month to yday (for non-leap) relational table

month_yday <- data.frame(Month = as.character(seq(1,12,1)),Yday = c(15,46,74,105,135,166,196,227,258,288,319,349))


#  -------------------------------------------------------------------------------------------------------------
#	SHALLOW, EARLY

####  Additive, mixed effects	

pa_model <- Shallow_A_Binom				#  summary(pa_model$gam)
								#  Year_fac + s(Permit_fac, bs = "re") + s(Hour, bs = "cc") + 
    								#	s(Yday, bs = "cc") + s(Lat) + Lightsticks_YN + s(Moon, bs = "cc")

pos_model <- Shallow_A_LnN				#  summary(pos_model$gam)
								#  log(CPUE) ~ Year_fac + s(Permit_fac, bs = "re") + s(Lat) + 
   								#	s(Yday, bs = "cc") + s(Moon, bs = "cc") + Lightsticks_YN + 
    								#	s(Lon, k = 6) + HPF_fac + s(Hour, bs = "cc")

sp_data_all <- SWOShala
sp_data_pos <- SWOShala_pos

first_year <- min(sp_data_all$Year)			#summary(sp_data_all)
last_year <- max(sp_data_all$Year)
pos_error <- 'gaussian'
pa_years <- unique(sp_data_all$Year_fac)
pos_years <- unique(sp_data_pos$Year_fac) 


# -- build the prediction datasets

  # presence/absence
	# for categorical variables, do large table. Predict per month.
	# pa_pred_grid <- expand.grid(pa_model$gam$xlevels)			#head(pa_pred_grid)		#str(pa_pred_grid)
	pa_pred_grid <- expand.grid(Year_fac = levels(sp_data_all$Year_fac), 
		Lightsticks_YN = levels(sp_data_all$Lightsticks_YN), Month = levels(as.factor(sp_data_all$Month)))
	pa_pred_grid <- merge(pa_pred_grid, month_yday, all.x = TRUE)
	pa_pred_grid$Month <- as.numeric(pa_pred_grid$Month)
	add_leap <- data.frame(is_leap = (pa_pred_grid$Year_fac == 1996 & pa_pred_grid$Month > 2) | 
			(pa_pred_grid$Year_fac == 2000 & pa_pred_grid$Month > 2))
	pa_pred_grid <- cbind(pa_pred_grid, add_leap)		# head(pa_pred_grid)
	pa_pred_grid$new_yday <- pa_pred_grid$is_leap + pa_pred_grid$Yday
	# head(pa_pred_grid)
	pa_pred_grid <- pa_pred_grid[,c(1,2,3,6)]
	# pa_pred_grid <- pa_pred_grid[,c(1,2,3,6)]
	pa_pred_grid$Month <- as.character(pa_pred_grid$Month)
	names(pa_pred_grid)[4] <- "Yday"

	# for smooth variables use a single median for all predictions
	pa_pred_grid <- mutate(pa_pred_grid, Lat = median(sp_data_all[,names(sp_data_all)=='Lat']))
	pa_pred_grid <- mutate(pa_pred_grid, Hour = median(sp_data_all[,names(sp_data_all)=='Hour']))
	pa_pred_grid <- mutate(pa_pred_grid, Moon = median(sp_data_all[,names(sp_data_all)=='Moon']))

	# what is the "average" vessel?
	try_effects <- ggpredict(pa_model$gam, "Permit_fac", back.transform = FALSE)
	# View(try_effects)
	try_effects <- try_effects[order(try_effects$predicted),]
	avg_vessel <- as.character(try_effects$x[round(nrow(try_effects)/2,0)])
	pa_pred_grid <- mutate(pa_pred_grid, Permit_fac = avg_vessel)
	
	# View(pa_pred_grid)			# str(pa_pred_grid)		

  # positive process 
	# for categorical variables, do large table
	pos_pred_grid <- expand.grid(Year_fac = levels(sp_data_all$Year_fac), 
		HPF_fac = levels(sp_data_all$HPF_fac), Lightsticks_YN = levels(sp_data_all$Lightsticks_YN), 
		Month = levels(as.factor(sp_data_all$Month)))
 	pos_pred_grid <- merge(pos_pred_grid, month_yday, all.x = TRUE)
	pos_pred_grid$Month <- as.numeric(pos_pred_grid$Month)
	add_leap <- data.frame(is_leap = (pos_pred_grid$Year_fac == 1996 & pos_pred_grid$Month > 2) | 
			(pos_pred_grid$Year_fac == 2000 & pos_pred_grid$Month > 2))
	pos_pred_grid <- cbind(pos_pred_grid, add_leap)
	pos_pred_grid$new_yday <- pos_pred_grid$is_leap + pos_pred_grid$Yday		#head(pos_pred_grid)
	pos_pred_grid <- pos_pred_grid[,c(1,2,3,4,7)]
	pos_pred_grid$Month <- as.character(pos_pred_grid$Month)
	names(pos_pred_grid)[5] <- "Yday"

	# for smooth variables add mode (or median) value on to prediction grid
	pos_pred_grid <- mutate(pos_pred_grid, Lat = median(sp_data_all[,names(sp_data_all)=='Lat']))
	pos_pred_grid <- mutate(pos_pred_grid, Hour = median(sp_data_all[,names(sp_data_all)=='Hour']))	
	pos_pred_grid <- mutate(pos_pred_grid, Lon = median(sp_data_all[,names(sp_data_all)=='Lon']))	
	pos_pred_grid <- mutate(pos_pred_grid, Moon = median(sp_data_all[,names(sp_data_all)=='Moon']))	

	# what is the "average" vessel?
	try_effects <- ggpredict(pos_model$gam, "Permit_fac", back.transform = FALSE)
	# View(try_effects)
	try_effects <- try_effects[order(try_effects$predicted),]
	avg_vessel <- as.character(try_effects$x[round(nrow(try_effects)/2,0)])
	pos_pred_grid <- mutate(pos_pred_grid, Permit_fac = avg_vessel)

	# View(pos_pred_grid)

 # -- do the predictions    
	#head(pa_pred_grid)		#formula(pa_model$gam)
   	pred_pa = predict.gam(pa_model$gam, newdata = pa_pred_grid, type = "response", se.fit = TRUE)			

   	pred_pos = predict.gam(pos_model$gam, newdata = pos_pred_grid, type = "response", se.fit = TRUE)

 # -- put predictions back onto the prediction grids and take marginal means
 
    # BY YEAR ONLY

		# presence/absence
		pred_pa_df <- data.frame(pa_raw = pred_pa$fit, pa_se = pred_pa$se.fit)
   		pred_pa_yrs <- cbind(pa_pred_grid,pred_pa_df)				# head(pred_pa_yrs)	#str(pred_pa_yrs)
		mm_pa_fit <- with(pred_pa_yrs, tapply(pa_raw, Year_fac, mean))
		mm_pa_se <- with(pred_pa_yrs, tapply(pa_se, Year_fac, mean))
		marg_means_pa <- data.frame(year = as.numeric(names(mm_pa_fit)), pa_raw = mm_pa_fit, pa_se = mm_pa_se)

		# positive process
		pred_pos_df <- data.frame(pos_raw = pred_pos$fit, pos_se = pred_pos$se.fit)
		pred_pos_yrs <- cbind(pos_pred_grid,pred_pos_df)			# head(pred_pos_yrs)
	
		  # correct for lognormal error if positive process was LnN
		  MSE = summary(pos_model$gam)$dispersion
		  pred_pos_yrs$pos_correct = exp(pred_pos_yrs$pos_raw+(MSE/2))
		  pred_pos_yrs$pos_se_correct = exp(pred_pos_yrs$pos_raw)*(pred_pos_yrs$pos_se)
		 		
		mm_pos_raw <- with(pred_pos_yrs, tapply(pos_raw, Year_fac, mean))
		mm_pos_fit <- with(pred_pos_yrs, tapply(pos_correct, Year_fac, mean))
		mm_pos_se_raw <- with(pred_pos_yrs, tapply(pos_se, Year_fac, mean))
		mm_pos_se <- with(pred_pos_yrs, tapply(pos_se_correct, Year_fac, mean))
		marg_means_pos <- data.frame(year = as.numeric(names(mm_pos_fit)), pos_raw = mm_pos_raw, pos_se = mm_pos_se_raw, 
						pos_correct = mm_pos_fit, pos_se_correct = mm_pos_se)						#str(marg_means_pos)

	# put together the processes
  	marg_means_pos <- marg_means_pos[order(marg_means_pos$year),]			#str(pred_pa_yrs)
   	marg_means_pa <- marg_means_pa[order(marg_means_pa$year),]			#str(pred_pos_yrs)
   	pred_delta <- merge(x = marg_means_pa, y = marg_means_pos, by='year', all.x = TRUE)

	# calculate delta predictions and se
	pred_delta$delta_fit = pred_delta$pos_correct*pred_delta$pa_raw
		
	# Goodman 1960 golden rule:
	#	for 2 independent random variables X and Y:
	#	var(XY) = var(X)var(Y) + var(X)E(Y)^2 + Var(Y)E(X)^2		# rob uses E = average of all fitted values
		
	pred_delta$delta_var = pred_delta$pa_se^2*pred_delta$pos_se_correct^2 +
			pred_delta$pa_se^2*pred_delta$pos_correct^2 +
			pred_delta$pos_se_correct^2*pred_delta$pa_raw^2

	# sd = sqrt(var) = se
	pred_delta$delta_se <- (pred_delta$delta_var)^(1/2)
	pred_delta$type <- 'delta_WLT'


	# save, clean-up
	Shallow_A_Delta_Year <- pred_delta

######## # SEE END for old code predicting CPUE by month and year.




#  -------------------------------------------------------------------------------------------------------------
#	SHALLOW, LATE				# 
####  Additive, mixed effects

# there was no binom process because zeros were rare. Last assessment, we just ignore zeros and only predict on LnN
#	so essentially assuming that the probability of positive catches is constant (and equal to 1) over the timeseries.

# positive process, LnN, best model				# summary(pos_model$gam)
# log(CPUE) ~ Year_fac + s(Permit_fac, bs = "re") + s(Moon, bs = "cc") + s(Yday, bs = "cc") + SST + s(Lon) +  s(Lat)

pos_model <- Shallow_B_LnN

sp_data_all <- SWOShalb
sp_data_pos <- SWOShalb_pos

first_year <- min(sp_data_all$Year)			#summary(sp_data_all)
last_year <- max(sp_data_all$Year)
pos_error <- 'gaussian'
pos_years <- unique(sp_data_pos$Year_fac) 		# length(pos_years)		# 17*12


# -- build the prediction datasets

  # positive process 		#formula(pos_model$gam)
	# for categorical variables, do large table
	pos_pred_grid <- expand.grid(Year_fac = levels(sp_data_all$Year_fac), 
		Month = levels(as.factor(sp_data_all$Month)))
 	pos_pred_grid <- merge(pos_pred_grid, month_yday, all.x = TRUE)
	pos_pred_grid$Month <- as.numeric(pos_pred_grid$Month)
	add_leap <- data.frame(is_leap = (pos_pred_grid$Year_fac == 2008 & pos_pred_grid$Month > 2) | 
			(pos_pred_grid$Year_fac == 2012 & pos_pred_grid$Month > 2) |
			(pos_pred_grid$Year_fac == 2016 & pos_pred_grid$Month > 2) |
			(pos_pred_grid$Year_fac == 2020 & pos_pred_grid$Month > 2) )
	pos_pred_grid <- cbind(pos_pred_grid, add_leap)
	pos_pred_grid$new_yday <- pos_pred_grid$is_leap + pos_pred_grid$Yday
	pos_pred_grid <- pos_pred_grid[,c(1,2,5)]
	pos_pred_grid$Month <- as.character(pos_pred_grid$Month)
	names(pos_pred_grid)[3] <- "Yday"				# View(pos_pred_grid)

	# for smooth variables add mode (or median) value on to prediction grid
	pos_pred_grid <- mutate(pos_pred_grid, Lat = median(sp_data_pos[,names(sp_data_pos)=='Lat']))
	pos_pred_grid <- mutate(pos_pred_grid, Lon = median(sp_data_pos[,names(sp_data_pos)=='Lon']))	
	pos_pred_grid <- mutate(pos_pred_grid, SST = median(sp_data_pos[,names(sp_data_pos)=='SST'], na.rm = TRUE))	
	pos_pred_grid <- mutate(pos_pred_grid, Moon = median(sp_data_pos[,names(sp_data_pos)=='Moon']))
	pos_pred_grid <- mutate(pos_pred_grid, LPH = median(sp_data_pos[,names(sp_data_pos)=='LPH']))	
	
	# View(pos_pred_grid)

	# what is the "average" vessel?
	try_effects <- ggpredict(pos_model$gam, "Permit_fac", back.transform = FALSE)
	# View(try_effects)
	try_effects <- try_effects[order(try_effects$predicted),]
	avg_vessel <- as.character(try_effects$x[round(nrow(try_effects)/2,0)])
	pos_pred_grid <- mutate(pos_pred_grid, Permit_fac = avg_vessel)			#View(try_effects)

	# View(pos_pred_grid)


 # -- do the predictions    
 
   	pred_pos = predict.gam(pos_model$gam, newdata = pos_pred_grid, type = "response", se.fit = TRUE)

  	# put predictions back onto the prediction grids and take marginal means over year

		# positive process
		pred_pos_df <- data.frame(pos_raw = pred_pos$fit, pos_se = pred_pos$se.fit)
		pred_pos_yrs <- cbind(pos_pred_grid,pred_pos_df)			# head(pred_pos_yrs)
	
		  # correct for lognormal error if positive process was LnN
		  MSE = summary(pos_model$gam)$dispersion
		  pred_pos_yrs$pos_correct = exp(pred_pos_yrs$pos_raw+(MSE/2))
		  pred_pos_yrs$pos_se_correct = exp(pred_pos_yrs$pos_raw)*(pred_pos_yrs$pos_se)
		 		
		mm_pos_raw <- with(pred_pos_yrs, tapply(pos_raw, Year_fac, mean))
		mm_pos_fit <- with(pred_pos_yrs, tapply(pos_correct, Year_fac, mean))
		mm_pos_se_raw <- with(pred_pos_yrs, tapply(pos_se, Year_fac, mean))
		mm_pos_se <- with(pred_pos_yrs, tapply(pos_se_correct, Year_fac, mean))
		marg_means_pos <- data.frame(year = as.numeric(names(mm_pos_fit)), pos_raw = mm_pos_raw, pos_se = mm_pos_se_raw, 
						pos_correct = mm_pos_fit, pos_se_correct = mm_pos_se)						#str(marg_means_pos)

	# put together the processes (not applicable here)
  	marg_means_pos <- marg_means_pos[order(marg_means_pos$year),]			#str(pred_pa_yrs)

	# save
	Shallow_B_Predict_Year <- marg_means_pos						#head(Shallow_B_Predict_LnN_year)



#  -------------------------------------------------------------------------------------------------------------
#	DEEP SET 1995-2021				#
####  Additive, mixed effects				#



pa_model <- Deep_Binom				#summary(pa_model$gam)
pos_model <- Deep_LnN				#summary(pos_model$gam)

sp_data_all <- SWODeep
sp_data_pos <- SWODeep_pos

first_year <- min(sp_data_all$Year)			#summary(sp_data_all)
last_year <- max(sp_data_all$Year)
pos_error <- 'gaussian'
pa_years <- unique(sp_data_all$Year_fac)
pos_years <- unique(sp_data_pos$Year_fac) 


# -- build the prediction datasets

  # presence/absence		#formula(pa_model$gam)
	# for categorical variables, do large table.
	pa_pred_grid <- expand.grid(Year_fac = levels(sp_data_all$Year_fac), 
			Month = levels(as.factor(sp_data_all$Month)))
	pa_pred_grid <- merge(pa_pred_grid, month_yday, all.x = TRUE)
	pa_pred_grid$Month <- as.numeric(pa_pred_grid$Month)
	add_leap <- data.frame(is_leap = (pa_pred_grid$Year_fac == 1996 & pa_pred_grid$Month > 2) | 
			(pa_pred_grid$Year_fac == 2000 & pa_pred_grid$Month > 2) |
			(pa_pred_grid$Year_fac == 2004 & pa_pred_grid$Month > 2) |
			(pa_pred_grid$Year_fac == 2008 & pa_pred_grid$Month > 2) | 
			(pa_pred_grid$Year_fac == 2012 & pa_pred_grid$Month > 2) |
			(pa_pred_grid$Year_fac == 2016 & pa_pred_grid$Month > 2) |
			(pa_pred_grid$Year_fac == 2020 & pa_pred_grid$Month > 2) )

	pa_pred_grid <- cbind(pa_pred_grid, add_leap)		# head(pa_pred_grid)
	pa_pred_grid$new_yday <- pa_pred_grid$is_leap + pa_pred_grid$Yday
	# head(pa_pred_grid)
	pa_pred_grid <- pa_pred_grid[,c(1,2,5)]
	pa_pred_grid$Month <- as.character(pa_pred_grid$Month)
	names(pa_pred_grid)[3] <- "Yday"

	# for smooth and linear continuous variables use a single median for all predictions
	pa_pred_grid <- mutate(pa_pred_grid, Lat = median(sp_data_all[,names(sp_data_all)=='Lat']))
	pa_pred_grid <- mutate(pa_pred_grid, SST = median(sp_data_all[,names(sp_data_all)=='SST'], na.rm=TRUE))
	pa_pred_grid <- mutate(pa_pred_grid, Moon = median(sp_data_all[,names(sp_data_all)=='Moon']))


	# "average" vessel
	try_effects <- ggpredict(pa_model$gam, "Permit_fac", back.transform = FALSE)
	# View(try_effects)
	try_effects <- try_effects[order(try_effects$predicted),]
	avg_vessel <- as.character(try_effects$x[round(nrow(try_effects)/2,0)])
	pa_pred_grid <- mutate(pa_pred_grid, Permit_fac = avg_vessel)
	
	# View(pa_pred_grid)			# str(pa_pred_grid)	


  # positive process  formula(pos_model$gam)
	# for categorical variables, do large table
	pos_pred_grid <- expand.grid(Year_fac = levels(sp_data_all$Year_fac), Bait_fac = levels(sp_data_all$Bait_fac),
		HPF_fac = levels(sp_data_all$HPF_fac), Month = levels(as.factor(sp_data_all$Month)))
 	pos_pred_grid <- merge(pos_pred_grid, month_yday, all.x = TRUE)
	pos_pred_grid$Month <- as.numeric(pos_pred_grid$Month)
	add_leap <- data.frame(is_leap = (pos_pred_grid$Year_fac == 1996 & pos_pred_grid$Month > 2) | 
			(pos_pred_grid$Year_fac == 2000 & pos_pred_grid$Month > 2) |
			(pos_pred_grid$Year_fac == 2004 & pos_pred_grid$Month > 2) |
			(pos_pred_grid$Year_fac == 2008 & pos_pred_grid$Month > 2) | 
			(pos_pred_grid$Year_fac == 2012 & pos_pred_grid$Month > 2) |
			(pos_pred_grid$Year_fac == 2016 & pos_pred_grid$Month > 2) |
			(pos_pred_grid$Year_fac == 2020 & pos_pred_grid$Month > 2) )
	pos_pred_grid <- cbind(pos_pred_grid, add_leap)
	pos_pred_grid$new_yday <- pos_pred_grid$is_leap + pos_pred_grid$Yday			# str(pos_pred_grid)
	pos_pred_grid <- pos_pred_grid[,c(1,2,3,4,7)]
	pos_pred_grid$Month <- as.character(pos_pred_grid$Month)
	names(pos_pred_grid)[5] <- "Yday"

	# for smooth variables add mode (or median) value on to prediction grid
	pos_pred_grid <- mutate(pos_pred_grid, Lat = median(sp_data_all[,names(sp_data_all)=='Lat']))
	pos_pred_grid <- mutate(pos_pred_grid, Hour = median(sp_data_all[,names(sp_data_all)=='Hour']))	
	pos_pred_grid <- mutate(pos_pred_grid, SST = median(sp_data_all[,names(sp_data_all)=='SST'], na.rm=TRUE))

	# "average" vessel
	try_effects <- ggpredict(pos_model$gam, "Permit_fac", back.transform = FALSE)
	# View(try_effects)
	try_effects <- try_effects[order(try_effects$predicted),]
	avg_vessel <- as.character(try_effects$x[round(nrow(try_effects)/2,0)])
	pos_pred_grid <- mutate(pos_pred_grid, Permit_fac = avg_vessel)

	# View(pos_pred_grid)

 # -- do the predictions    
   	pred_pa = predict.gam(pa_model$gam, newdata = pa_pred_grid, type = "response", se.fit = TRUE)

   	pred_pos = predict.gam(pos_model$gam, newdata = pos_pred_grid, type = "response", se.fit = TRUE)

 # -- put predictions back onto the prediction grids and take marginal means
 
		# presence/absence
		pred_pa_df <- data.frame(pa_raw = pred_pa$fit, pa_se = pred_pa$se.fit)
   		pred_pa_yrs <- cbind(pa_pred_grid,pred_pa_df)				# head(pred_pa_yrs)	#str(pred_pa_yrs)
		mm_pa_fit <- with(pred_pa_yrs, tapply(pa_raw, Year_fac, mean))
		mm_pa_se <- with(pred_pa_yrs, tapply(pa_se, Year_fac, mean))
		marg_means_pa <- data.frame(year = as.numeric(names(mm_pa_fit)), pa_raw = mm_pa_fit, pa_se = mm_pa_se)

		# positive process
		pred_pos_df <- data.frame(pos_raw = pred_pos$fit, pos_se = pred_pos$se.fit)
		pred_pos_yrs <- cbind(pos_pred_grid,pred_pos_df)			# head(pred_pos_yrs)
	
		  # correct for lognormal error if positive process was LnN
		  MSE = summary(pos_model$gam)$dispersion
		  pred_pos_yrs$pos_correct = exp(pred_pos_yrs$pos_raw+(MSE/2))
		  pred_pos_yrs$pos_se_correct = exp(pred_pos_yrs$pos_raw)*(pred_pos_yrs$pos_se)
		 		
		mm_pos_raw <- with(pred_pos_yrs, tapply(pos_raw, Year_fac, mean))
		mm_pos_fit <- with(pred_pos_yrs, tapply(pos_correct, Year_fac, mean))
		mm_pos_se_raw <- with(pred_pos_yrs, tapply(pos_se, Year_fac, mean))
		mm_pos_se <- with(pred_pos_yrs, tapply(pos_se_correct, Year_fac, mean))
		marg_means_pos <- data.frame(year = as.numeric(names(mm_pos_fit)), pos_raw = mm_pos_raw, pos_se = mm_pos_se_raw, 
						pos_correct = mm_pos_fit, pos_se_correct = mm_pos_se)						#str(marg_means_pos)

	# put together the processes
  	marg_means_pos <- marg_means_pos[order(marg_means_pos$year),]			#str(pred_pa_yrs)
   	marg_means_pa <- marg_means_pa[order(marg_means_pa$year),]			#str(pred_pos_yrs)
   	pred_delta <- merge(x = marg_means_pa, y = marg_means_pos, by='year', all.x = TRUE)

	# calculate delta predictions and se
	pred_delta$delta_fit = pred_delta$pos_correct*pred_delta$pa_raw
		
	# Goodman 1960 golden rule:
	#	for 2 independent random variables X and Y:
	#	var(XY) = var(X)var(Y) + var(X)E(Y)^2 + Var(Y)E(X)^2		# rob uses E = average of all fitted values
		
	pred_delta$delta_var = pred_delta$pa_se^2*pred_delta$pos_se_correct^2 +
			pred_delta$pa_se^2*pred_delta$pos_correct^2 +
			pred_delta$pos_se_correct^2*pred_delta$pa_raw^2

	# sd = sqrt(var) = se
	pred_delta$delta_se <- (pred_delta$delta_var)^(1/2)
	pred_delta$type <- 'delta_WLT'


	# save, clean-up
	Deep_Delta_Year <- pred_delta




# write final CPUE indices out to .csvs for compilation into Excel

if (1 ==2) {

write.csv(Shallow_A_Delta_Year, paste0(root_dir,"/Shallow_A_Delta_Year_05Dec.csv"),row.names=FALSE)
write.csv(Shallow_B_Predict_Year, paste0(root_dir,"/Shallow_B_Predict_LnN_year_05Dec.csv"),row.names=FALSE)
write.csv(Deep_Delta_Year, paste0(root_dir,"/Deep_Delta_Year_05Dec.csv"),row.names=FALSE)

 }




#  clean-up and save workspace			#str(SWOShala)

  	all_objs <- ls()
  	save_objs <- c("Shallow_A_Delta_Year",
				"Shallow_B_Predict_Year", 
				"Deep_Delta_Year")
  	remove_objs <- setdiff(all_objs, save_objs)

  if (1 == 2) {
  	rm(list=remove_objs)
  	rm(save_objs)
  	rm(remove_objs)
  	rm(all_objs)
	}































# maintain YEAR AND MONTH

		# presence/absence
		pred_pa_df <- data.frame(pa_raw = pred_pa$fit, pa_se = pred_pa$se.fit)
   		pred_pa_yrs <- cbind(pa_pred_grid,pred_pa_df)				# head(pred_pa_yrs)	#str(pred_pa_yrs)

		mm_pa_fit <- aggregate(pred_pa_yrs$pa_raw, list(pred_pa_yrs$Year_fac, pred_pa_yrs$Month), FUN = mean)
		names(mm_pa_fit)[] <- c("year","Month","pa_raw")

		mm_pa_se <- aggregate(pred_pa_yrs$pa_se, list(pred_pa_yrs$Year_fac, pred_pa_yrs$Month), FUN = mean)
		names(mm_pa_se)[] <- c("year","Month","pa_se")

		marg_means_pa <- merge(mm_pa_fit, mm_pa_se, by=c("year","Month"))


		# positive process		#omg just use sql
		pred_pos_df <- data.frame(pos_raw = pred_pos$fit, pos_se = pred_pos$se.fit)
		pred_pos_yrs <- cbind(pos_pred_grid,pred_pos_df)			# head(pred_pos_yrs)
	
		  # correct for lognormal error if positive process was LnN
		  MSE = summary(pos_model$gam)$dispersion
		  pred_pos_yrs$pos_correct = exp(pred_pos_yrs$pos_raw+(MSE/2))
		  pred_pos_yrs$pos_se_correct = exp(pred_pos_yrs$pos_raw)*(pred_pos_yrs$pos_se)

		string <- "SELECT Year_fac as year, Month, Yday, avg(pos_raw) as pos_raw, avg(pos_se) as pos_se,
					avg(pos_correct) as pos_correct, avg(pos_se_correct) as pos_se_correct
				FROM pred_pos_yrs
				GROUP BY Year_fac, Month
				"
  		marg_means_pos <- sqldf(string, stringsAsFactors=FALSE)	


		 		
		mm_pos_raw <- with(pred_pos_yrs, tapply(pos_raw, Year_fac, mean))
		mm_pos_raw <- aggregate(pred_pa_yrs$pa_raw, list(pred_pa_yrs$Year_fac, pred_pa_yrs$Month), FUN = mean)
		names(mm_pa_fit)[] <- c("year","Month","pa_raw")

	# put together the processes
 	pred_delta <- merge(x = marg_means_pa, y = marg_means_pos, by=c('year','Month'), all.x = TRUE)	

	# calculate delta predictions and se
	pred_delta$delta_fit = pred_delta$pos_correct*pred_delta$pa_raw
		
	# Goodman 1960 golden rule:
	#	for 2 independent random variables X and Y:
	#	var(XY) = var(X)var(Y) + var(X)E(Y)^2 + Var(Y)E(X)^2
		
	pred_delta$delta_var = pred_delta$pa_se^2*pred_delta$pos_se_correct^2 +
			pred_delta$pa_se^2*pred_delta$pos_correct^2 +
			pred_delta$pos_se_correct^2*pred_delta$pa_raw^2
 
	# se = sqrt(var)
	pred_delta$delta_se <- (pred_delta$delta_var)^(1/2)

	# save, clean-up
	Shallow_A_Delta_Year_Month <- pred_delta


	# maintain YEAR AND MONTH

		# positive process		#omg just use sql
		pred_pos_df <- data.frame(pos_raw = pred_pos$fit, pos_se = pred_pos$se.fit)
		pred_pos_yrs <- cbind(pos_pred_grid,pred_pos_df)			# head(pred_pos_yrs)
	
		  # correct for lognormal error if positive process was LnN
		  MSE = summary(pos_model$gam)$dispersion
		  pred_pos_yrs$pos_correct = exp(pred_pos_yrs$pos_raw+(MSE/2))
		  pred_pos_yrs$pos_se_correct = exp(pred_pos_yrs$pos_raw)*(pred_pos_yrs$pos_se)

		string <- "SELECT Year_fac as year, Month, Yday, avg(pos_raw) as pos_raw, avg(pos_se) as pos_se,
					avg(pos_correct) as pos_correct, avg(pos_se_correct) as pos_se_correct
				FROM pred_pos_yrs
				GROUP BY Year_fac, Month
				"
  		marg_means_pos <- sqldf(string, stringsAsFactors=FALSE)	


	# save
	Shallow_B_Predict_LnN_Year_Month <- marg_means_pos




# maintain YEAR AND MONTH

		# presence/absence
		pred_pa_df <- data.frame(pa_raw = pred_pa$fit, pa_se = pred_pa$se.fit)
   		pred_pa_yrs <- cbind(pa_pred_grid,pred_pa_df)				# head(pred_pa_yrs)	#str(pred_pa_yrs)

		mm_pa_fit <- aggregate(pred_pa_yrs$pa_raw, list(pred_pa_yrs$Year_fac, pred_pa_yrs$Month), FUN = mean)
		names(mm_pa_fit)[] <- c("year","Month","pa_raw")

		mm_pa_se <- aggregate(pred_pa_yrs$pa_se, list(pred_pa_yrs$Year_fac, pred_pa_yrs$Month), FUN = mean)
		names(mm_pa_se)[] <- c("year","Month","pa_se")

		marg_means_pa <- merge(mm_pa_fit, mm_pa_se, by=c("year","Month"))


		# positive process		#omg just use sql
		pred_pos_df <- data.frame(pos_raw = pred_pos$fit, pos_se = pred_pos$se.fit)
		pred_pos_yrs <- cbind(pos_pred_grid,pred_pos_df)			# head(pred_pos_yrs)
	
		  # correct for lognormal error if positive process was LnN
		  MSE = summary(pos_model$gam)$dispersion
		  pred_pos_yrs$pos_correct = exp(pred_pos_yrs$pos_raw+(MSE/2))
		  pred_pos_yrs$pos_se_correct = exp(pred_pos_yrs$pos_raw)*(pred_pos_yrs$pos_se)

		string <- "SELECT Year_fac as year, Month, Yday, avg(pos_raw) as pos_raw, avg(pos_se) as pos_se,
					avg(pos_correct) as pos_correct, avg(pos_se_correct) as pos_se_correct
				FROM pred_pos_yrs
				GROUP BY Year_fac, Month
				"
  		marg_means_pos <- sqldf(string, stringsAsFactors=FALSE)	


		 		
		mm_pos_raw <- with(pred_pos_yrs, tapply(pos_raw, Year_fac, mean))
		mm_pos_raw <- aggregate(pred_pa_yrs$pa_raw, list(pred_pa_yrs$Year_fac, pred_pa_yrs$Month), FUN = mean)
		names(mm_pa_fit)[] <- c("year","Month","pa_raw")

	# put together the processes
 	pred_delta <- merge(x = marg_means_pa, y = marg_means_pos, by=c('year','Month'), all.x = TRUE)	

	# calculate delta predictions and se
	pred_delta$delta_fit = pred_delta$pos_correct*pred_delta$pa_raw
		
	# Goodman 1960 golden rule:
	#	for 2 independent random variables X and Y:
	#	var(XY) = var(X)var(Y) + var(X)E(Y)^2 + Var(Y)E(X)^2
		
	pred_delta$delta_var = pred_delta$pa_se^2*pred_delta$pos_se_correct^2 +
			pred_delta$pa_se^2*pred_delta$pos_correct^2 +
			pred_delta$pos_se_correct^2*pred_delta$pa_raw^2
 
	# se = sqrt(var)
	pred_delta$delta_se <- (pred_delta$delta_var)^(1/2)

	# save, clean-up
	Deep_Delta_Year_Month <- pred_delta





