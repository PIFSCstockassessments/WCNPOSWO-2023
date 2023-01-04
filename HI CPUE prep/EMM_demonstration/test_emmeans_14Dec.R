#  Investigate the emmeans function from package emmeans
#	and demonstrate similarities to coding the large table (ref grid) directly
#	to create a standardized CPUE index 
#	using Hawai'i deep-set longline logbook data
#
#  NOTE: The datasets in this script contain logbook permit/vessel numbers and are PII
#	PLEASE HANDLE APPROPRIATELY
#
#  Erin Bohaboy, erin.bohaboy@noaa.gov, 14Dec2022

# required libraries
  library(dplyr)  
  library(lme4)
  library(gamm4)
  library(emmeans)
  library(this.path)
  library(data.table)  
  library(mgcv)

# ggeffects is used to predict from the gamm4 models to recreate the working paper
# library(ggeffects)


# make sure this script (the one we are reading from) is in the same directory as anything we want to read in
#  identify that directory using this.path::
   root_dir <- this.path::here(.. = 0)

# load the Deep-set data, already cleaned-up and seperated into the presence/absence and positive datasets
   load(paste0(root_dir, '/SWO_Deep_Data.RData'))

  # one quick modification: for illustration, treat Month as a factor when fitting the models. 
  # For the working paper, I used day of year (e.g. a number between 1 and 366) as a spline term in the models, 
  # then predicted by month using the
  # center value for each. Note, predicting by month and then taking the marginal mean over all months is the same as
  # doing an integration estimate with 12 divisions. You could easily integrate over days (e.g. 365 or 366 divisions).

  SWODeep$Month_fac <- as.factor(SWODeep$Month)
  SWODeep_pos$Month_fac <- as.factor(SWODeep_pos$Month)

# if desireable, load the fitted gamm4:gam objects used in the 2022 CPUE standardization working paper
# WARNING: this is a huge workspace (2.8 Gb)
#   load(paste0(root_dir, '/SWO_Deep_GAMM_objects.RData'))


# fit some simplified models to see what the functions are doing

# --------------
#  Linear model

#  fit a relatively simple linear model
simple_glm <- glm(log(CPUE) ~ Year_fac + Month_fac + SST, data = SWODeep_pos, family=gaussian, na.action = na.omit)

#  have emmeans generate the prediction (reference) grid
simple_ref <- ref_grid(simple_glm)			#str(simple_ref)		# emmeans predicts on average categorical
	# note: emmeans automatically takes the average of categorical variables across all data within the dataset
	#		used in the model and uses that value in the prediction grid. I would argue that median is a more
	#		stable statistic to use for central tendency, but it shouldn't impact the relative index really,
	#		but we'll use the means to enable comparison.

#  use the estimated marginal means function, tell it we want the year margin.
simple_emmeans_glm <- emmeans(simple_glm, c("Year_fac"))	


# Code it ourselves:

  # build prediction grid
	# for categorical variables, expand out the large table
	  pred_grid <- expand.grid(Year_fac = levels(SWODeep_pos$Year_fac), 
			Month_fac = levels(SWODeep_pos$Month_fac))
	# for smooth/continuous variables add median value on to prediction grid
	# BUT for comparison to emmeans, use the average
	  pred_grid <- mutate(pred_grid, SST = mean(SWODeep_pos$SST, na.rm = TRUE))
		# double-check that the size of the grid is what we expect
		# nrow(pred_grid)		# nlevels(SWODeep_pos$Year_fac)*nlevels(SWODeep_pos$Month_fac)

	# do the prediction
 	  pred = predict.glm(simple_glm, newdata = pred_grid, type = "response", se.fit = TRUE)		

	# put the prediction values (e.g. log(CPUE) estimates) into each grid		
	  pred_df <- data.frame(raw = pred$fit, se = pred$se.fit)
	  pred_yrs <- cbind(pred_grid,pred_df)			# head(pred_yrs)
	
      # correct for lognormal error if positive process was LnN
	  MSE = summary(simple_glm)$dispersion
 	  pred_yrs$correct = exp(pred_yrs$raw+(MSE/2))
	  pred_yrs$se_correct = exp(pred_yrs$raw)*(pred_yrs$se)
		 		
	# calculate marginal means
	  mm_raw <- with(pred_yrs, tapply(raw, Year_fac, mean))
	  mm_fit <- with(pred_yrs, tapply(correct, Year_fac, mean))
	  mm_se_raw <- with(pred_yrs, tapply(se, Year_fac, mean))
	  mm_se <- with(pred_yrs, tapply(se_correct, Year_fac, mean))
	  marg_means_glm <- data.frame(year = as.numeric(names(mm_fit)), raw = mm_raw, se = mm_se_raw, 
						correct = mm_fit, se_correct = mm_se)						#str(marg_means_pos)

# compare
    plot(marg_means_glm$raw, summary(simple_emmeans_glm)$emmean)
	abline(0,1, col='red')
    plot(marg_means_glm$se, summary(simple_emmeans_glm)$SE)
	abline(0,1, col='red')

   # means are identical, SE estimates are very close, and nearly linearly related.





# --------------
#  General Linear model


# 

#  fit a relatively simple general linear model
simple_glm <- glm(z ~ Year_fac + Month_fac + SST, data = SWODeep, family='binomial', na.action = na.omit)
#  have emmeans generate the prediction (reference) grid
simple_ref <- ref_grid(simple_glm)			#summary(simple_ref)		# emmeans predicts on average categorical
	# note: emmeans automatically takes the average of categorical variables across all data within the dataset
	#		used in the model and uses that value in the prediction grid. I would argue that median is a more
	#		stable statistic to use for central tendency, but it shouldn't impact the relative index really,
	#		but we'll use the means to enable comparison.

#  use the estimated marginal means function, tell it we want the year margin.
simple_emmeans_glm <- emmeans(simple_glm, c("Year_fac"))	

# this is logit scale, back-transform
emmeans_glm_df <- as.data.frame(summary(simple_emmeans_glm))
emmeans_glm_df$transform_CPUE <- 1/(1+exp(-(emmeans_glm_df$emmean)))

# Is this still wrong? Try doing the marginal means ourselves, but use ref_grid to do predictions 
#	(as was done in 2018)

refgrid_predict <- as.data.frame(summary(simple_ref))			# str(refgrid_predict)

# back-transform, then take marginal means
refgrid_predict$transform_CPUE <- 1/(1+exp(-(refgrid_predict$prediction)))

	mm_2 <- with(refgrid_predict, tapply(transform_CPUE, Year_fac, mean))


# Code it ourselves:

  # build prediction grid
	# for categorical variables, expand out the large table
	  pred_grid <- expand.grid(Year_fac = levels(SWODeep$Year_fac), 
			Month_fac = levels(SWODeep$Month_fac))
	# for smooth/continuous variables add median value on to prediction grid
	# BUT for comparison to emmeans, use the average
	  pred_grid <- mutate(pred_grid, SST = mean(SWODeep$SST, na.rm = TRUE))
		# double-check that the size of the grid is what we expect
		# nrow(pred_grid)		# nlevels(SWODeep_pos$Year_fac)*nlevels(SWODeep_pos$Month_fac)

	# do the prediction
 	  pred = predict.glm(simple_glm, newdata = pred_grid, type = "response", se.fit = TRUE)		

	# put the prediction values (e.g. log(CPUE) estimates) into each grid		
	  pred_df <- data.frame(raw = pred$fit, se = pred$se.fit)
	  pred_yrs <- cbind(pred_grid,pred_df)			# head(pred_yrs)
		 		
	# calculate marginal means
	  mm_raw <- with(pred_yrs, tapply(raw, Year_fac, mean))
	  mm_se_raw <- with(pred_yrs, tapply(se, Year_fac, mean))
	  marg_means_glm <- data.frame(year = as.numeric(names(mm_raw)), raw = mm_raw, se = mm_se_raw)						#str(marg_means_pos)

# compare: it matters when you back-transform: before or after marginal means
    plot(marg_means_glm$raw, emmeans_glm_df$transform_CPUE)
	abline(0,1, col='red')

    plot(marg_means_glm$raw, mm_2)
	abline(0,1, col='red')

    plot(marg_means_glm$se, summary(simple_emmeans_glm)$SE, col='blue')

   # means are identical, SE estimates are very close, and nearly linearly related.



# --------------
#	A simple gam
#	here forward is less nicely commented out, but the idea is the same


# using emmeans
simple_gam <- gam(log(CPUE) ~ Year_fac + Month_fac + s(Lat), data = SWODeep_pos, family=gaussian, na.action = na.omit)
simple_gam_ref <- ref_grid(simple_gam)			#str(simple_ref)		# emmeans predicts on average categorical
simple_emmeans_gam <- emmeans(simple_gam, c("Year_fac"))	
		# used 22.116


		pos_pred_grid <- expand.grid(Year_fac = levels(SWODeep_pos$Year_fac), 
			Month_fac = levels(SWODeep_pos$Month_fac))
		# for smooth variables add median value on to prediction grid
		# BUT for comparison to emmeans, use the average
		pos_pred_grid <- mutate(pos_pred_grid, Lat = mean(SWODeep_pos$Lat, na.rm = TRUE))

	# do prediction
 		pred_pos = predict.gam(simple_gam, newdata = pos_pred_grid, type = "response", se.fit = TRUE)		

	# marginal means
		pred_pos_df <- data.frame(pos_raw = pred_pos$fit, pos_se = pred_pos$se.fit)
		pred_pos_yrs <- cbind(pos_pred_grid,pred_pos_df)			# head(pred_pos_yrs)
	
		  # correct for lognormal error if positive process was LnN
		  MSE = summary(simple_gam)$dispersion
		  pred_pos_yrs$pos_correct = exp(pred_pos_yrs$pos_raw+(MSE/2))
		  pred_pos_yrs$pos_se_correct = exp(pred_pos_yrs$pos_raw)*(pred_pos_yrs$pos_se)
		 		
		mm_pos_raw <- with(pred_pos_yrs, tapply(pos_raw, Year_fac, mean))
		mm_pos_fit <- with(pred_pos_yrs, tapply(pos_correct, Year_fac, mean))
		mm_pos_se_raw <- with(pred_pos_yrs, tapply(pos_se, Year_fac, mean))
		mm_pos_se <- with(pred_pos_yrs, tapply(pos_se_correct, Year_fac, mean))
		marg_means_gam <- data.frame(year = as.numeric(names(mm_pos_fit)), pos_raw = mm_pos_raw, pos_se = mm_pos_se_raw, 
						pos_correct = mm_pos_fit, pos_se_correct = mm_pos_se)						#str(marg_means_pos)


    plot(marg_means_gam$pos_raw, summary(simple_emmeans_gam)$emmean)
	abline(0,1, col='red')

    plot(marg_means_gam$pos_se, summary(simple_emmeans_gam)$SE)
	abline(0,1, col='red')

   # means are identical, SEs are not




# --------------
#	A gamm directly from mgcv, random=list(fac=~1)

# using emmeans		# 
simple_gamm <- gamm(log(CPUE) ~ Year_fac + Month_fac + s(Lat), data = SWODeep_pos, random = list(Permit_fac=~1),
		family=gaussian, na.action = na.omit)
simple_gamm_ref <- ref_grid(simple_gamm, data = SWODeep_pos)			#str(simple_ref)		# emmeans predicts on average categorical
simple_emmeans_gamm <- emmeans(simple_gamm, c("Year_fac"), data = SWODeep_pos)	
		# used 22.116

# The predict value for the random effect permit is hidden in this gam object. Makes it difficult to make influence plots.

		# for categorical variables, do large table
		pos_pred_grid <- expand.grid(Year_fac = levels(SWODeep_pos$Year_fac), 
			Month_fac = levels(SWODeep_pos$Month_fac))
		# for smooth variables add median value on to prediction grid
		# BUT for comparison to emmeans, use the average
		pos_pred_grid <- mutate(pos_pred_grid, Lat = mean(SWODeep_pos$Lat, na.rm = TRUE))

	# do prediction
 		pred_pos = predict.gam(simple_gamm$gam, newdata = pos_pred_grid, type = "response", se.fit = TRUE)		

	# marginal means
		pred_pos_df <- data.frame(pos_raw = pred_pos$fit, pos_se = pred_pos$se.fit)
		pred_pos_yrs <- cbind(pos_pred_grid,pred_pos_df)			# head(pred_pos_yrs)
	
		  # correct for lognormal error if positive process was LnN
		  MSE = summary(simple_gam)$dispersion
		  pred_pos_yrs$pos_correct = exp(pred_pos_yrs$pos_raw+(MSE/2))
		  pred_pos_yrs$pos_se_correct = exp(pred_pos_yrs$pos_raw)*(pred_pos_yrs$pos_se)
		 		
		mm_pos_raw <- with(pred_pos_yrs, tapply(pos_raw, Year_fac, mean))
		mm_pos_fit <- with(pred_pos_yrs, tapply(pos_correct, Year_fac, mean))
		mm_pos_se_raw <- with(pred_pos_yrs, tapply(pos_se, Year_fac, mean))
		mm_pos_se <- with(pred_pos_yrs, tapply(pos_se_correct, Year_fac, mean))
		marg_means_gamm <- data.frame(year = as.numeric(names(mm_pos_fit)), pos_raw = mm_pos_raw, pos_se = mm_pos_se_raw, 
						pos_correct = mm_pos_fit, pos_se_correct = mm_pos_se)						#str(marg_means_pos)


    plot(marg_means_gamm$pos_raw, summary(simple_emmeans_gamm)$emmean)
	abline(0,1, col='red')

    plot(marg_means_gamm$pos_se, summary(simple_emmeans_gamm)$SE)
	abline(0,1, col='red')

   # means are identical, SEs are not






#  ----------------------------------------
#  ----------------------------------------
#  ----------------------------------------

#  emmeans can't handle the gam that comes out of gamm4. It can handle gams and gamms from mgcv


# try refitting the best deepset using mgcv and see what happens.
#	BUT we will have to fit on Month as a factor, not a spline to be comparable.


mgcv_gamm <- gamm(log(CPUE) ~ Year_fac + Month_fac + s(Hour, bs = "cc") + HPF_fac + s(Lat) + 
    SST + Bait_fac, data = SWODeep_pos, random = list(Permit_fac=~1),
		knots = list(Hour=c(0,24)),
		family=gaussian, na.action = na.omit)


simple_mgcv_gamm_ref <- ref_grid(mgcv_gamm, data = SWODeep_pos)			#str(simple_ref)		# emmeans predicts on average categorical
simple_mgcv_emmeans_gamm <- emmeans(mgcv_gamm, c("Year_fac"), data = SWODeep_pos)
 		# Hour = 7.9222	# note emmeans is using complete cases only
    		# Lat = 22.088			# mean(subset(SWODeep_pos, is.na(SST)==FALSE)$Lat)
 		# SST = 25.143			# mean(subset(SWODeep_pos, is.na(SST)==FALSE)$Hour)


# WLT

	# build prediction grid
		# for categorical variables, do large table
		pos_pred_grid <- expand.grid(Year_fac = levels(SWODeep_pos$Year_fac), 
			Month_fac = levels(SWODeep_pos$Month_fac),  HPF_fac = levels(SWODeep_pos$HPF_fac),
		 	Bait_fac = levels(SWODeep_pos$Bait_fac))
		# for smooth variables add median value on to prediction grid
		# BUT for comparison to emmeans, assign values above
		pos_pred_grid <- mutate(pos_pred_grid, Lat = 22.088)
		pos_pred_grid <- mutate(pos_pred_grid, Hour = 7.9222)
		pos_pred_grid <- mutate(pos_pred_grid, SST = 25.143)


	# do prediction
 		pred_pos = predict.gam(mgcv_gamm$gam, newdata = pos_pred_grid, type = "response", se.fit = TRUE)		

	# marginal means
		pred_pos_df <- data.frame(pos_raw = pred_pos$fit, pos_se = pred_pos$se.fit)
		pred_pos_yrs <- cbind(pos_pred_grid,pred_pos_df)			# head(pred_pos_yrs)
	
		  # correct for lognormal error if positive process was LnN
		  MSE = summary(mgcv_gamm$gam)$dispersion
		  pred_pos_yrs$pos_correct = exp(pred_pos_yrs$pos_raw+(MSE/2))
		  pred_pos_yrs$pos_se_correct = exp(pred_pos_yrs$pos_raw)*(pred_pos_yrs$pos_se)
		 		
		mm_pos_raw <- with(pred_pos_yrs, tapply(pos_raw, Year_fac, mean))
		mm_pos_fit <- with(pred_pos_yrs, tapply(pos_correct, Year_fac, mean))
		mm_pos_se_raw <- with(pred_pos_yrs, tapply(pos_se, Year_fac, mean))
		mm_pos_se <- with(pred_pos_yrs, tapply(pos_se_correct, Year_fac, mean))
		marg_means_gamm_mgcv <- data.frame(year = as.numeric(names(mm_pos_fit)), pos_raw = mm_pos_raw, pos_se = mm_pos_se_raw, 
						pos_correct = mm_pos_fit, pos_se_correct = mm_pos_se)						#str(marg_means_pos)


    plot(marg_means_gamm_mgcv$pos_raw, summary(simple_mgcv_emmeans_gamm)$emmean)
	abline(0,1, col='red')

    plot(marg_means_gamm_mgcv$pos_se, summary(simple_mgcv_emmeans_gamm)$SE)
	abline(0,1, col='red')

   # means are identical, SEs are very different, by a factor of about 2 and something else going on.

    plot(marg_means_gamm_mgcv$pos_se, summary(simple_mgcv_emmeans_gamm)$SE*2)
	abline(0,1, col='red')



#  ----------------------------------------

#  this is the actual code used to predict the deep-set CPUE using the gamm4 objects:



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

# need a relational table to tell us the correct yday to use for each month.
month_yday <- data.frame(Month = as.character(seq(1,12,1)),Yday = c(15,46,74,105,135,166,196,227,258,288,319,349))


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
	#  can find using ggeffects package
    library(ggeffects)
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

	# str(pos_pred_grid)		# this is very big 27 years x 12 months x 8 bait x 9 HPF levels
						# 27*12*8*9

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

	# column delta_fit is predicted annual CPUE, delta_se is SE. Please note: for graphing purposes, it is necessary
	#	to calculate confidence intervals in logspace for the positive process. See script 3_CPUE_figures.R


























