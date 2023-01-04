#  --------------------------------------------------------------------------------------------------------------
#   FUNCTIONS TO FIT AND SELECT CPUE standardization MODELS
#	Originally written for American Samoa Boat-Based Survey CPUE standardization using GAMs
#	Modified to add glmer from lme4 as well as GAMMs
#		with different selection (lowest AIC only if LR test sig) / stop criteria (%dev. explained)
#	Erin Bohaboy erin.bohaboy@noaa.gov
#  These functions can be called with SOURCE command
#  --------------------------------------------------------------------------------------------------------------

# --- Load lots of libraries:
#  	rm(list=ls())
#  	Sys.setenv(TZ = "UTC")		# setting system time to UTC avoids bugs in sqldf
  	library(sqldf)
  	library(dplyr)
#  	library(tidyr)
	library(fitdistrplus)
	library(mgcv)
	library(formula.tools)
 	library(this.path)
 	library(lme4)
	library(gamm4)			# install.packages('gamm4')
#	library(assertthat)


# --- read in the functions



# FUNCTIONS --------------------------------------------------------------------------------------------------------------
# FORWARD SELECTION lowest AIC only if LR test sig / stop criteria = delta %dev. explained (delta_dev_expl_thresh)
#
#
#
#    1. binomial_linear()			
#    2. binomial_gam()				
#    3. lognormal_linear()
#    4. lognormal_gam()
#
#
#
#  ARGUMENTS 		DESCRIPTIONS
#  data_set			R object containing the data (z = 0 or 1 for binomial, positive CPUE only for positive process)
#  out_directory		give the full file path of the folder where you want to keep the outputs for the model selection
#				process. The output file will have the 
#					name like binomial_gamm_dt.txt, where dt is the system time (in UTC?)
#					as MMDDhhmmss
#  var_name			list the covariate names, matching the column names in the input data, that are being considered.
#					additive terms have to be given (e.g. s(Hour, bs='cc')). May specify k as well in each term to prevent
#					large ks. Remember to include effort as a potential covariate for the presence/absence process.
#  delta_dev_expl_thresh		
#				relative proportion change in deviance explained (as a positive number) 
#					that qualifies a variable for addition to the model. default is 0.0025 (0.25%). I use that for
#					swordfish because that was used last time.




# FUNCTION 1: --------------------------------------------------------------------------------------------------------------
# ----   PRESENCE/ABSENCE (BINOMIAL DISTRIBUTION) using GLM and GLMER


binomial_linear <- function(data_set, var_name, out_directory, delta_dev_expl_thresh = 0.0025) {
 
# ---- preliminaries
   nvars <- length(var_name)
   list_vars <- data.frame('var_i' = seq(1,nvars,1),'var_name' = var_name)		#str(list_vars)

   start_dt <- paste0(substr(Sys.time(),6,7),substr(Sys.time(),9,10),substr(Sys.time(),12,13),
				substr(Sys.time(),15,16),substr(Sys.time(),18,19))
  
   intercept_only_text <- "z ~ 1"
   year_only_text <- "z ~ Year_fac"
   null_formula_text <- "z ~ Year_fac + (1 | Permit_fac)"			#

   out_file <- paste0(out_directory,"/","binomial_",start_dt,".txt")


# ---- STEP 1: fit "null" models
    intercept_only_formula <- as.formula(intercept_only_text)
    year_only_formula <- as.formula(year_only_text)
    null_formula_formula <- as.formula(null_formula_text)
    
    intercept_only_glm <- glm(intercept_only_formula, data = data_set, family=binomial, na.action = na.omit)
    year_only_glm <- glm(year_only_formula, data = data_set, family=binomial, na.action = na.omit)
    null_glmer <- run_glmer <- glmer(null_formula_formula, data = data_set, family=binomial, na.action = na.omit)

    intercept_only_aic <- as.numeric(intercept_only_glm$aic)
    year_only_aic <- as.numeric(year_only_glm$aic)		

    intercept_only_dev <- as.numeric(intercept_only_glm$deviance)		# str(intercept_only_glm$data$z)
    year_only_dev <- as.numeric(year_only_glm$deviance)

    intercept_only_LL <- as.numeric(logLik(intercept_only_glm))
    year_only_LL <- as.numeric(logLik(year_only_glm))

    intercept_only_nparms <- 1
    year_only_nparms <- as.numeric(length(year_only_glm$coefficients))

    intercept_only_dev_expl <- 0
    year_only_dev_expl <- (intercept_only_dev-year_only_dev)/intercept_only_dev

    null_dev <- last_dev <- as.numeric(summary(run_glmer)$AICtab["deviance"])
    null_aic <- last_aic <- as.numeric(summary(run_glmer)$AICtab["AIC"])
    null_LL <- last_LL <- as.numeric(summary(run_glmer)$AICtab["logLik"])			# attributes(thing)$df <- summary(run_glmer)$logLik
    null_nparms <- last_nparms <- attributes(summary(run_glmer)$logLik)$df
    null_dev_expl <- last_dev_expl <- (intercept_only_dev-null_dev)/intercept_only_dev

  # write out info on the "null" models
   info_head <- paste("AIC", "dev", "LL", "nparm", "dev_expl", "formula", sep = " | ")
   info_intercept_only <- paste(round(intercept_only_aic,0), round(intercept_only_dev,0), round(intercept_only_LL,0), 
					intercept_only_nparms, round(intercept_only_dev_expl,4), intercept_only_text, sep = " | ")
   info_year_only <- paste(round(year_only_aic,0), round(year_only_dev,0), round(year_only_LL,0), 
					year_only_nparms, round(year_only_dev_expl,4), year_only_text, sep = " | ")
   info_null <- paste(round(null_aic,0), round(null_dev,0), round(null_LL,0), null_nparms, round(null_dev_expl,4), 
					null_formula_text, sep = " | ")

	write(info_head, file = out_file, append=TRUE)
	write(info_intercept_only, file = out_file, append=TRUE)   
	write(info_year_only, file = out_file, append=TRUE)   
	write(info_null, file = out_file, append=TRUE)   

   keep_going = TRUE
   current_formula <- null_formula_text

# --- STEP 2: try to add each variable, get AIC, compute likelihood ratio test, pick the one variable to add

 while(keep_going) {

      info_mod <- paste(round(last_aic,0), round(last_dev,0), round(last_LL,2), last_nparms, round(last_dev_expl,4), 
					current_formula, sep = " | ")
	write(info_head, file = out_file, append=TRUE)
	write(info_mod, file = out_file, append=TRUE)   

   list_vars$var_i <- seq(1,nrow(list_vars),1)			# renumber the rows

   list_vars <- mutate(list_vars, 'aic_add' = 0, 'dev_add' = 0, 'LL_add' = 0, 'nparms_add' = 0, 'dev_exp_add' = 0, 
			'LR_add' = 0, 'LR_chi2_p' = 0, 'calc_max_grad' = 999)


   for (i in 1:nrow(list_vars)) {
	add_var = list_vars[i,2]
	formula_text <- paste0(current_formula," + ",add_var)
	formula_formula <- as.formula(formula_text)
 	run_glmer <- glmer(formula_formula, data = data_set, family=binomial, na.action = na.omit)

    	mod_aic <- as.numeric(summary(run_glmer)$AICtab["AIC"])			#summary(run_glmer)
	mod_dev <- as.numeric(summary(run_glmer)$AICtab["deviance"])
	mod_LL <- as.numeric(summary(run_glmer)$AICtab["logLik"])			
    	mod_nparms <- attributes(summary(run_glmer)$logLik)$df
	mod_dev_expl <- (intercept_only_dev - mod_dev)/intercept_only_dev
	mod_LR <- 2*abs(last_LL-mod_LL)
	mod_LR_chi2_p <- 1 - pchisq(mod_LR, df = (mod_nparms - last_nparms), lower.tail = TRUE, log.p = FALSE)
	mod_calc_max_grad <- run_glmer@optinfo$derivs %>% with(. , solve(Hessian, gradient))  %>% abs() %>% max()

	list_vars[i,3] <- mod_aic
	list_vars[i,4] <- mod_dev
	list_vars[i,5] <- mod_LL
	list_vars[i,6] <- mod_nparms
	list_vars[i,7] <- mod_dev_expl
	list_vars[i,8] <- mod_LR
	list_vars[i,9] <- mod_LR_chi2_p
	list_vars[i,10] <- mod_calc_max_grad
	}											

# write out the results for each variable
	list_vars_rounded <- list_vars
	list_vars_rounded[,c(3,4,5)] <- round(list_vars[,c(3,4,5)],2)
	list_vars_rounded[,7] <- round(list_vars[,7],7)
	list_vars_rounded[,8] <- round(list_vars[,8],1)

	# output list_vars		#str(list_vars)
	write_me <- colnames(list_vars)
	write(write_me, file = out_file, sep=" | ",ncolumns=10, append=TRUE)

	for (k in 1:nrow(list_vars)) {
	write_me <- as.matrix(list_vars_rounded[k,])
	write(write_me, file = out_file, sep=" | ",ncolumns=10, append=TRUE)
	 	 }

#  --- STEP 3: look at results, choose which to leave out   # list_vars$LR_chi2_p[1] <- 0.1
	
  # can not consider models where mod_LR_chi2_p > 0.05		#
 	list_vars_sig <- subset(list_vars, LR_chi2_p <= 0.05)

  # tell us about the lowest aic cov
	# determine index, name
	index_lowest <- which.min(list_vars_sig$aic_add)
	lowest_name <- list_vars_sig[index_lowest,2]
	lowest_aic <- list_vars_sig[index_lowest,3]
	lowest_LL <- list_vars_sig[index_lowest,5]
	lowest_nparms <- list_vars_sig[index_lowest,6]
	lowest_dev_expl <- list_vars_sig[index_lowest,7]

  # calculate the change in deviance explained (i.e. should we keep going?)
	delta_dev_expl <- lowest_dev_expl - last_dev_expl 					# 

	if (nrow(list_vars_sig)>0) {
		if (delta_dev_expl < delta_dev_expl_thresh)  {
			keep_going = FALSE
		}
	    }

	if (nrow(list_vars_sig)==0) {
	  	keep_going = FALSE
	    }

   # output info
	info <- paste(lowest_name, round(lowest_aic,2), round(delta_dev_expl,5),"keep going",keep_going, sep = " | ")
	write(info, file = out_file, append=TRUE)
	
	# update last_aic
	last_aic <- lowest_aic

	# update last dev_expl
	last_dev_expl <- lowest_dev_expl

	# update last LL
	last_LL <- lowest_LL

	# update last_nparms
	last_nparms <- lowest_nparms

  # IF that last cov satisfied our threshold for inclusion, update current formula, update list_vars
	if (keep_going == TRUE) {
	current_formula <- paste0(current_formula," + ",list_vars[list_vars$var_name==lowest_name,2])
	# update list_vars
	list_vars <- list_vars[list_vars$var_name!=lowest_name,]
     }

  #	in the unlikely event that every variable we initially considered should be included, stop here too 
  #   we'll know we got every variable if the length of current formula (total elements, including z, ~, and year)
  #		is equal to nvars + 3
	current_formula_formula <- as.formula(current_formula)
 	if (length(current_formula_formula) == nvars + 2) {
	  keep_going <- FALSE
	}

  # if that last added variable didn't make the cut or it did, but it was the last one and we updated current_formula,
  #	then define best model 
	if (keep_going == FALSE) {
	best_formula <- current_formula
     }

   }

 # now we have "best_formula"
 #	refit the GAM, return the model object and the data in a list 
	best_formula_formula <- as.formula(best_formula)

	best_glmer <- glmer(best_formula_formula, data = data_set, family=binomial, na.action = na.omit)

	return(best_glmer)

} 
		
# --------------------------------------  FUNCTION 1 END










# FUNCTION 2: --------------------------------------------------------------------------------------------------------------
# ----   PRESENCE/ABSENCE (BINOMIAL DISTRIBUTION) using GAMM



binomial_gam <- function(data_set, var_name, out_directory, delta_dev_expl_thresh = 0.0025) {
 
# ---- preliminaries
   nvars <- length(var_name)
   list_vars <- data.frame('var_i' = seq(1,nvars,1),'var_name' = var_name)		#str(list_vars)

   start_dt <- paste0(substr(Sys.time(),6,7),substr(Sys.time(),9,10),substr(Sys.time(),12,13),
				substr(Sys.time(),15,16),substr(Sys.time(),18,19))
  
   intercept_only_text <- "z ~ 1"
   year_only_text <- "z ~ Year_fac"
   null_formula_text <- "z ~ Year_fac + s(Permit_fac, bs = 're')"

   out_file <- paste0(out_directory,"/","GAMM_binomial_",start_dt,".txt")


# ---- STEP 1: fit "null" models. Use glm and glmer

    intercept_only_formula <- as.formula(intercept_only_text)
    year_only_formula <- as.formula(year_only_text)
    null_formula_formula <- as.formula(null_formula_text)
    
    intercept_only_glm <- glm(intercept_only_formula, data = data_set, family=binomial, na.action = na.omit)
    year_only_glm <- glm(year_only_formula, data = data_set, family=binomial, na.action = na.omit)
    null_glmer <- run_glmer <- gamm4(null_formula_formula, data = data_set, family=binomial, na.action = na.omit)

    intercept_only_aic <- as.numeric(intercept_only_glm$aic)
    year_only_aic <- as.numeric(year_only_glm$aic)		

    intercept_only_dev <- as.numeric(intercept_only_glm$deviance)
    year_only_dev <- as.numeric(year_only_glm$deviance)

    intercept_only_LL <- as.numeric(logLik(intercept_only_glm))
    year_only_LL <- as.numeric(logLik(year_only_glm))

    intercept_only_nparms <- 1
    year_only_nparms <- as.numeric(length(year_only_glm$coefficients))

    intercept_only_dev_expl <- 0
    year_only_dev_expl <- (intercept_only_dev-year_only_dev)/intercept_only_dev

    null_LL <- last_LL <- as.numeric(logLik(run_glmer$mer))					#summary(run_glmer$mer)	
    null_nparms <- last_nparms <- attributes(summary(run_glmer$mer)$logLik)$df
    null_aic <- last_aic <- AIC(run_glmer$mer)
    null_dev <- last_dev <- deviance(run_glmer$mer)
    null_dev_expl <- last_dev_expl <- (intercept_only_dev-null_dev)/intercept_only_dev


  # write out info on the "null" models
   info_head <- paste("AIC", "dev", "LL", "nparm", "dev_expl", "formula", sep = " | ")
   info_intercept_only <- paste(round(intercept_only_aic,0), round(intercept_only_dev,0), round(intercept_only_LL,0), 
					intercept_only_nparms, round(intercept_only_dev_expl,4), intercept_only_text, sep = " | ")
   info_year_only <- paste(round(year_only_aic,0), round(year_only_dev,0), round(year_only_LL,0), 
					year_only_nparms, round(year_only_dev_expl,4), year_only_text, sep = " | ")
   info_null <- paste(round(null_aic,0), round(null_dev,0), round(null_LL,0), null_nparms, round(null_dev_expl,4), 
					null_formula_text, sep = " | ")

	write(info_head, file = out_file, append=TRUE)
	write(info_intercept_only, file = out_file, append=TRUE)   
	write(info_year_only, file = out_file, append=TRUE)   
	write(info_null, file = out_file, append=TRUE)   

   keep_going = TRUE
   current_formula <- null_formula_text


# ------------- Add one variable

 while(keep_going) {

      info_mod <- paste(round(last_aic,0), round(last_dev,0), round(last_LL,2), last_nparms, round(last_dev_expl,4), 
					current_formula, sep = " | ")
	write(info_head, file = out_file, append=TRUE)
	write(info_mod, file = out_file, append=TRUE)   

   list_vars$var_i <- seq(1,nrow(list_vars),1)			# renumber the rows


   list_vars <- mutate(list_vars, 'aic_add' = 0, 'dev_add' = 0, 'LL_add' = 0, 'nparms_add' = 0, 'dev_exp_add' = 0, 
			'LR_add' = 0, 'LR_chi2_p' = 0, 'calc_max_grad' = 999)

# --- STEP 2: try to add each variable, get AIC, compute likelihood ratio test, pick the one variable to add

   for (i in 1:nrow(list_vars)) {
	add_var = list_vars[i,2]
	formula_text <- paste0(current_formula," + ",add_var)
	formula_formula <- as.formula(formula_text)
	run_gam <- gamm4(formula_formula, data = data_set, family= 'binomial', 
		knots = list(Moon=c(0,1), Hour=c(0,24), Yday=c(0,366)), na.action = na.omit)

	# head(data_set)			#plot(run_gam$gam)

	mod_LL <- as.numeric(logLik(run_gam$mer))	
	mod_nparms <- attributes(summary(run_gam$mer)$logLik)$df
	mod_aic <- AIC(run_gam$mer)
	mod_dev <-  deviance(run_gam$mer)
	mod_dev_expl <- (intercept_only_dev - mod_dev)/intercept_only_dev
	mod_LR <- 2*abs(last_LL-mod_LL)
	mod_LR_chi2_p <- 1 - pchisq(mod_LR, df = (mod_nparms - last_nparms), lower.tail = TRUE, log.p = FALSE)
	mod_calc_max_grad <- run_gam$mer@optinfo$derivs %>% with(. , solve(Hessian, gradient))  %>% abs() %>% max()

	list_vars[i,3] <- mod_aic
	list_vars[i,4] <- mod_dev
	list_vars[i,5] <- mod_LL
	list_vars[i,6] <- mod_nparms
	list_vars[i,7] <- mod_dev_expl
	list_vars[i,8] <- mod_LR
	list_vars[i,9] <- mod_LR_chi2_p
	list_vars[i,10] <- mod_calc_max_grad
	}											

# write out the results for each variable
	list_vars_rounded <- list_vars
	list_vars_rounded[,c(3,4,5)] <- round(list_vars[,c(3,4,5)],2)
	list_vars_rounded[,7] <- round(list_vars[,7],7)
	list_vars_rounded[,8] <- round(list_vars[,8],1)
#	list_vars_rounded[,c(9,10)] <- format(round(list_vars[,c(9,10)],3), scientific = TRUE)
#	list_vars_rounded[,c(9,10)] <- format(list_vars[,c(9,10)], scientific = TRUE)

	# output list_vars		#str(list_vars)
	write_me <- colnames(list_vars)
	write(write_me, file = out_file, sep=" | ",ncolumns=10, append=TRUE)

	for (k in 1:nrow(list_vars)) {
	write_me <- as.matrix(list_vars_rounded[k,])
	write(write_me, file = out_file, sep=" | ",ncolumns=10, append=TRUE)
	 	 }

#  --- STEP 3: look at results, choose which to leave out   # list_vars$LR_chi2_p[1] <- 0.1
	
  # can not consider models where mod_LR_chi2_p > 0.05		#
 	list_vars_sig <- subset(list_vars, LR_chi2_p <= 0.05)

  # tell us about the lowest aic cov
	# determine index, name
	index_lowest <- which.min(list_vars_sig$aic_add)
	lowest_name <- list_vars_sig[index_lowest,2]
	lowest_aic <- list_vars_sig[index_lowest,3]
	lowest_LL <- list_vars_sig[index_lowest,5]
	lowest_nparms <- list_vars_sig[index_lowest,6]
	lowest_dev_expl <- list_vars_sig[index_lowest,7]

  # calculate the change in deviance explained (i.e. should we keep going?)	# last_dev_expl <- 0.488249
	delta_dev_expl <- lowest_dev_expl - last_dev_expl 					# 

	if (nrow(list_vars_sig)>0) {
		if (delta_dev_expl < delta_dev_expl_thresh)  {
			keep_going = FALSE
		}
	    }

	if (nrow(list_vars_sig)==0) {
	  	keep_going = FALSE
	    }

	# output info
	info <- paste(lowest_name, round(lowest_aic,2), round(delta_dev_expl,5),"keep going",keep_going, sep = " | ")
	write(info, file = out_file, append=TRUE)
	
	# update last_aic
	last_aic <- lowest_aic

	# update last dev_expl
	last_dev_expl <- lowest_dev_expl

	# update last LL
	last_LL <- lowest_LL

	# update last_nparms
	last_nparms <- lowest_nparms

  # IF that last cov satisfied our threshold for inclusion, update current formula, update list_vars
	if (keep_going == TRUE) {
	current_formula <- paste0(current_formula," + ",list_vars[list_vars$var_name==lowest_name,2])
	# update list_vars
	list_vars <- list_vars[list_vars$var_name!=lowest_name,]
     }

  #	in the unlikely event that every variable we initially considered should be included, stop here too 
  #   we'll know we got every variable if the length of current formula (total elements, including z, ~, and year)
  #		is equal to nvars + 3
	current_formula_formula <- as.formula(current_formula)
	nvars_current_formula <- (length(attributes(terms.formula(current_formula_formula))$variables))-2
 	if (nvars_current_formula == nvars) {
	  keep_going <- FALSE
	}

  # if that last added variable didn't make the cut or it did, but it was the last one and we updated current_formula,
  #	then define best model 
	if (keep_going == FALSE) {
	best_formula <- current_formula
     }

   }

 # now we have "best_formula"
 #	refit the GAM, return the model object and the data in a list 
	best_formula_formula <- as.formula(best_formula)

	best_gam <- gamm4(best_formula_formula, data = data_set, family= 'binomial', 
		knots = list(Moon=c(0,1), Hour=c(0,24), Yday=c(0,366)), na.action = na.omit)
	return(best_gam)


} 
		
# --------------------------------------  FUNCTION 2 END









# FUNCTION 3: --------------------------------------------------------------------------------------------------------------
# ----   LOGNORMAL DISTRIBUTION POSITIVE PROCESS, linear
#	unfortunately, with lm, as opposed to additive models, you can't make glmmer objects on gaussian distributions
#		glmer() actually calls lmer() and makes an lm object (not a glmer object).


lognormal_linear <- function(data_set, var_name, out_directory, delta_dev_expl_thresh = 0.0025) {
 
# ---- preliminaries
   nvars <- length(var_name)
   list_vars <- data.frame('var_i' = seq(1,nvars,1),'var_name' = var_name)		#str(list_vars)

   start_dt <- paste0(substr(Sys.time(),6,7),substr(Sys.time(),9,10),substr(Sys.time(),12,13),
				substr(Sys.time(),15,16),substr(Sys.time(),18,19))
  
   intercept_only_text <- "log(CPUE) ~ 1"
   year_only_text <- "log(CPUE) ~ Year_fac"
   null_formula_text <- "log(CPUE) ~ Year_fac + (1 | Permit_fac)"

   out_file <- paste0(out_directory,"/","LnN_",start_dt,".txt")


# ---- STEP 1: fit "null" models

    intercept_only_formula <- as.formula(intercept_only_text)
    year_only_formula <- as.formula(year_only_text)
    null_formula_formula <- as.formula(null_formula_text)
    
    intercept_only_glm <- glm(intercept_only_formula, data = data_set, family=gaussian, na.action = na.omit)
    year_only_glm <- glm(year_only_formula, data = data_set, family=gaussian, na.action = na.omit)
    null_glmer <- run_glmer <- lmer(null_formula_formula, data = data_set, na.action = na.omit)

    intercept_only_aic <- as.numeric(intercept_only_glm$aic)
    year_only_aic <- as.numeric(year_only_glm$aic)	
    null_aic <- last_aic <- as.numeric(AIC(null_glmer))	

    intercept_only_LL <- as.numeric(logLik(intercept_only_glm))
    year_only_LL <- as.numeric(logLik(year_only_glm))
    null_LL <- last_LL <- as.numeric(logLik(null_glmer))

    intercept_only_dev <- as.numeric(intercept_only_glm$deviance)			# devcomp(null_glmer)
    year_only_dev <- as.numeric(year_only_glm$deviance)
    null_dev <- last_dev <- sum(residuals(null_glmer, type="deviance")^2)

    intercept_only_nparms <- 1
    year_only_nparms <- as.numeric(length(year_only_glm$coefficients))
    null_nparms <- last_nparms <- attributes(summary(run_glmer)$logLik)$df

    intercept_only_dev_expl <- 0
    year_only_dev_expl <- (intercept_only_dev-year_only_dev)/intercept_only_dev
    null_dev_expl <- last_dev_expl <- (intercept_only_dev-null_dev)/intercept_only_dev

  # write out info on the "null" models
   info_head <- paste("AIC", "dev", "LL", "nparm", "dev_expl", "formula", sep = " | ")
   info_intercept_only <- paste(round(intercept_only_aic,0), round(intercept_only_dev,0), round(intercept_only_LL,0), 
					intercept_only_nparms, round(intercept_only_dev_expl,4), intercept_only_text, sep = " | ")
   info_year_only <- paste(round(year_only_aic,0), round(year_only_dev,0), round(year_only_LL,0), 
					year_only_nparms, round(year_only_dev_expl,4), year_only_text, sep = " | ")
   info_null <- paste(round(null_aic,0), round(null_dev,0), round(null_LL,0), null_nparms, round(null_dev_expl,4), 
					null_formula_text, sep = " | ")

	write(info_head, file = out_file, append=TRUE)
	write(info_intercept_only, file = out_file, append=TRUE)   
	write(info_year_only, file = out_file, append=TRUE)   
	write(info_null, file = out_file, append=TRUE)   

   keep_going = TRUE
   current_formula <- null_formula_text

# ------------- Add one variable

 while(keep_going) {

      info_mod <- paste(round(last_aic,0), round(last_dev,0), round(last_LL,2), last_nparms, round(last_dev_expl,4), 
					current_formula, sep = " | ")
	write(info_head, file = out_file, append=TRUE)
	write(info_mod, file = out_file, append=TRUE)   

   list_vars$var_i <- seq(1,nrow(list_vars),1)			# renumber the rows


   list_vars <- mutate(list_vars, 'aic_add' = 0, 'dev_add' = 0, 'LL_add' = 0, 'nparms_add' = 0, 'dev_exp_add' = 0, 
			'LR_add' = 0, 'LR_chi2_p' = 0, 'calc_max_grad' = 999)

# --- STEP 2: try to add each variable, get AIC, compute likelihood ratio test, pick the one variable to add

   for (i in 1:nrow(list_vars)) {
	add_var = list_vars[i,2]
	formula_text <- paste0(current_formula," + ",add_var)
	formula_formula <- as.formula(formula_text)
 #	run_gam <- gam(formula_formula, data = sp_data_all,  family= 'binomial', knots = list(Moon_days=c(0,30), 
 #				wdir=c(0,360), yday=c(0,366)), method='ML',na.action = na.omit)
 #	run_glmer <- glmer(formula_formula, data = data_set, family=binomial, na.action = na.omit)
 	run_glmer <- lmer(formula_formula, data = data_set, na.action = na.omit)		#str(run_glmer)

    	mod_aic <- as.numeric(AIC(run_glmer))			#summary(run_glmer)
	mod_dev <- as.numeric(sum(residuals(run_glmer, type="deviance")^2))
	mod_LL <- as.numeric(logLik(run_glmer))			
    	mod_nparms <- attributes(summary(run_glmer)$logLik)$df
	mod_dev_expl <- (intercept_only_dev - mod_dev)/intercept_only_dev
	mod_LR <- 2*abs(last_LL-mod_LL)
	mod_LR_chi2_p <- 1 - pchisq(mod_LR, df = (mod_nparms - last_nparms), lower.tail = TRUE, log.p = FALSE)
	
	mod_calc_max_grad <- run_glmer@optinfo$derivs %>% with(. , solve(Hessian, gradient))  %>% abs() %>% max()
	# run_glmer@optinfo$derivs$gradient		# I don't understand why the Hessian is 1 x 1.

	list_vars[i,3] <- mod_aic
	list_vars[i,4] <- mod_dev
	list_vars[i,5] <- mod_LL
	list_vars[i,6] <- mod_nparms
	list_vars[i,7] <- mod_dev_expl
	list_vars[i,8] <- mod_LR
	list_vars[i,9] <- mod_LR_chi2_p
	list_vars[i,10] <- mod_calc_max_grad
	}											

# write out the results for each variable
	list_vars_rounded <- list_vars
	list_vars_rounded[,c(3,4,5)] <- round(list_vars[,c(3,4,5)],2)
	list_vars_rounded[,7] <- round(list_vars[,7],7)
	list_vars_rounded[,8] <- round(list_vars[,8],1)
#	list_vars_rounded[,c(9,10)] <- format(round(list_vars[,c(9,10)],3), scientific = TRUE)
#	list_vars_rounded[,c(9,10)] <- format(list_vars[,c(9,10)], scientific = TRUE)

	# output list_vars		#str(list_vars)
	write_me <- colnames(list_vars)
	write(write_me, file = out_file, sep=" | ",ncolumns=10, append=TRUE)

	for (k in 1:nrow(list_vars)) {
	write_me <- as.matrix(list_vars_rounded[k,])
	write(write_me, file = out_file, sep=" | ",ncolumns=10, append=TRUE)
	 	 }

#  --- STEP 3: look at results, choose which to leave out   # list_vars$LR_chi2_p[1] <- 0.1
	
  # can not consider models where mod_LR_chi2_p > 0.05		#
 	list_vars_sig <- subset(list_vars, LR_chi2_p <= 0.05)

  # tell us about the lowest aic cov
	# determine index, name
	index_lowest <- which.min(list_vars_sig$aic_add)
	lowest_name <- list_vars_sig[index_lowest,2]
	lowest_aic <- list_vars_sig[index_lowest,3]
	lowest_LL <- list_vars_sig[index_lowest,5]
	lowest_nparms <- list_vars_sig[index_lowest,6]
	lowest_dev_expl <- list_vars_sig[index_lowest,7]

  # calculate the change in deviance explained (i.e. should we keep going?)
	delta_dev_expl <- lowest_dev_expl - last_dev_expl 

	if (delta_dev_expl < delta_dev_expl_thresh)  {
		keep_going = FALSE
		}

	# output info
	info <- paste(lowest_name, round(lowest_aic,2), round(delta_dev_expl,5),"keep going",keep_going, sep = " | ")
	write(info, file = out_file, append=TRUE)
	
	# update last_aic
	last_aic <- lowest_aic

	# update last dev_expl
	last_dev_expl <- lowest_dev_expl

	# update last LL
	last_LL <- lowest_LL

  # IF that last cov satisfied our threshold for inclusion, update current formula, update list_vars
	if (keep_going == TRUE) {
	current_formula <- paste0(current_formula," + ",list_vars[list_vars$var_name==lowest_name,2])
	# update list_vars
	list_vars <- list_vars[list_vars$var_name!=lowest_name,]
     }

  #	in the unlikely event that every variable we initially considered should be included, stop here too 
  #   we'll know we got every variable if the length of current formula (total elements, including z, ~, and year)
  #		is equal to nvars + 3
	current_formula_formula <- as.formula(current_formula)
 	if (length(current_formula_formula) == nvars + 2) {
	  keep_going <- FALSE
	}

  # if that last added variable didn't make the cut or it did, but it was the last one and we updated current_formula,
  #	then define best model 
	if (keep_going == FALSE) {
	best_formula <- current_formula
     }

   }

 # now we have "best_formula"
 #	refit the GAM, return the model object and the data in a list 
	best_formula_formula <- as.formula(best_formula)

 #	best_glmer <- glmer(best_formula_formula, data = data_set, family=binomial, na.action = na.omit)
 	best_glmer <- lmer(best_formula_formula, data = data_set, na.action = na.omit)		#str(run_glmer)

	return(best_glmer)

} 
		
# --------------------------------------  FUNCTION 3 END






# FUNCTION 4: --------------------------------------------------------------------------------------------------------------
# ----  Positive Process (Lognormal distribution) using GAMM


lognormal_gam <- function(data_set, var_name, out_directory, delta_dev_expl_thresh = 0.0025) {


# ---- preliminaries
   nvars <- length(var_name)
   list_vars <- data.frame('var_i' = seq(1,nvars,1),'var_name' = var_name)		#str(list_vars)

   start_dt <- paste0(substr(Sys.time(),6,7),substr(Sys.time(),9,10),substr(Sys.time(),12,13),
				substr(Sys.time(),15,16),substr(Sys.time(),18,19))
  
   intercept_only_text <- "log(CPUE) ~ 1"
   year_only_text <- "log(CPUE) ~ Year_fac"
   null_formula_text <- "log(CPUE) ~ Year_fac + s(Permit_fac, bs = 're')"

   out_file <- paste0(out_directory,"/","GAMM_LnN_",start_dt,".txt")


# ---- STEP 1: fit "null" models. Use glm and glmer

    intercept_only_formula <- as.formula(intercept_only_text)
    year_only_formula <- as.formula(year_only_text)
    null_formula_formula <- as.formula(null_formula_text)
    
    intercept_only_glm <- glm(intercept_only_formula, data = data_set, family=gaussian, na.action = na.omit)
    year_only_glm <- glm(year_only_formula, data = data_set, family=gaussian, na.action = na.omit)
    null_glmer <- run_glmer <- gamm4(null_formula_formula, data = data_set, family=gaussian, na.action = na.omit)

    intercept_only_aic <- as.numeric(intercept_only_glm$aic)
    year_only_aic <- as.numeric(year_only_glm$aic)		

    intercept_only_dev <- as.numeric(intercept_only_glm$deviance)
    year_only_dev <- as.numeric(year_only_glm$deviance)

    intercept_only_LL <- as.numeric(logLik(intercept_only_glm))
    year_only_LL <- as.numeric(logLik(year_only_glm))

    intercept_only_nparms <- 1
    year_only_nparms <- as.numeric(length(year_only_glm$coefficients))

    intercept_only_dev_expl <- 0
    year_only_dev_expl <- (intercept_only_dev-year_only_dev)/intercept_only_dev

    null_dev <- last_dev <- sum(residuals(null_glmer$gam, type="deviance")^2)			# this only works with Gaussian models
    null_aic <- last_aic <- as.numeric(AIC(null_glmer$mer))
    null_LL <- last_LL <- as.numeric(logLik(null_glmer$mer))
    null_nparms <- last_nparms <- attributes(summary(run_glmer$mer)$logLik)$df
    null_dev_expl <- last_dev_expl <- (intercept_only_dev-null_dev)/intercept_only_dev


  # write out info on the "null" models
   info_head <- paste("AIC", "dev", "LL", "nparm", "dev_expl", "formula", sep = " | ")
   info_intercept_only <- paste(round(intercept_only_aic,0), round(intercept_only_dev,0), round(intercept_only_LL,0), 
					intercept_only_nparms, round(intercept_only_dev_expl,4), intercept_only_text, sep = " | ")
   info_year_only <- paste(round(year_only_aic,0), round(year_only_dev,0), round(year_only_LL,0), 
					year_only_nparms, round(year_only_dev_expl,4), year_only_text, sep = " | ")
   info_null <- paste(round(null_aic,0), round(null_dev,0), round(null_LL,0), null_nparms, round(null_dev_expl,4), 
					null_formula_text, sep = " | ")

	write(info_head, file = out_file, append=TRUE)
	write(info_intercept_only, file = out_file, append=TRUE)   
	write(info_year_only, file = out_file, append=TRUE)   
	write(info_null, file = out_file, append=TRUE)   

   keep_going = TRUE
   current_formula <- null_formula_formula


# ------------- Add one variable

 while(keep_going) {

      info_mod <- paste(round(last_aic,0), round(last_dev,0), round(last_LL,2), last_nparms, round(last_dev_expl,4), 
					current_formula, sep = " | ")
	write(info_head, file = out_file, append=TRUE)
	write(info_mod, file = out_file, append=TRUE)   

   list_vars$var_i <- seq(1,nrow(list_vars),1)			# renumber the rows


   list_vars <- mutate(list_vars, 'aic_add' = 0, 'dev_add' = 0, 'LL_add' = 0, 'nparms_add' = 0, 'dev_exp_add' = 0, 
			'LR_add' = 0, 'LR_chi2_p' = 0, 'calc_max_grad' = 999)

# --- STEP 2: try to add each variable, get AIC, compute likelihood ratio test, pick the one variable to add

   for (i in 1:nrow(list_vars)) {
	add_var = list_vars[i,2]
	formula_text <- paste0(current_formula,' + ',add_var)
	formula_formula <- as.formula(formula_text)
	run_gam <- gamm4(formula_formula, data = data_set, family= 'gaussian', 
		knots = list(Moon=c(0,1), Hour=c(0,24), Yday=c(0,366)), na.action = na.omit)

	mod_LL <- as.numeric(logLik(run_gam$mer))	
	mod_nparms <- attributes(summary(run_gam$mer)$logLik)$df				# n
	mod_aic <- AIC(run_gam$mer)			
	mod_dev <- sum(residuals(run_gam$mer, type="deviance")^2)	
	mod_dev_expl <- (intercept_only_dev - mod_dev)/intercept_only_dev
	mod_LR <- 2*abs(last_LL-mod_LL)
	mod_LR_chi2_p <- 1 - pchisq(mod_LR, df = (mod_nparms - last_nparms), lower.tail = TRUE, log.p = FALSE)
	mod_calc_max_grad <- run_gam$mer@optinfo$derivs %>% with(. , solve(Hessian, gradient))  %>% abs() %>% max()

	list_vars[i,3] <- mod_aic
	list_vars[i,4] <- mod_dev
	list_vars[i,5] <- mod_LL
	list_vars[i,6] <- mod_nparms
	list_vars[i,7] <- mod_dev_expl
	list_vars[i,8] <- mod_LR
	list_vars[i,9] <- mod_LR_chi2_p
	list_vars[i,10] <- mod_calc_max_grad
	}											

# write out the results for each variable
	list_vars_rounded <- list_vars
	list_vars_rounded[,c(3,4,5)] <- round(list_vars[,c(3,4,5)],2)
	list_vars_rounded[,7] <- round(list_vars[,7],7)
	list_vars_rounded[,8] <- round(list_vars[,8],1)
#	list_vars_rounded[,c(9,10)] <- format(round(list_vars[,c(9,10)],3), scientific = TRUE)
#	list_vars_rounded[,c(9,10)] <- format(list_vars[,c(9,10)], scientific = TRUE)

	# output list_vars		#str(list_vars)
	write_me <- colnames(list_vars)
	write(write_me, file = out_file, sep=" | ",ncolumns=10, append=TRUE)

	for (k in 1:nrow(list_vars)) {
	write_me <- as.matrix(list_vars_rounded[k,])
	write(write_me, file = out_file, sep=" | ",ncolumns=10, append=TRUE)
	 	 }

#  --- STEP 3: look at results, choose which to leave out   # list_vars$LR_chi2_p[1] <- 0.1
	
  # can not consider models where mod_LR_chi2_p > 0.05		#
 	list_vars_sig <- subset(list_vars, LR_chi2_p <= 0.05)

  # tell us about the lowest aic cov
	# determine index, name
	index_lowest <- which.min(list_vars_sig$aic_add)
	lowest_name <- list_vars_sig[index_lowest,2]
	lowest_aic <- list_vars_sig[index_lowest,3]
	lowest_LL <- list_vars_sig[index_lowest,5]
	lowest_nparms <- list_vars_sig[index_lowest,6]
	lowest_dev_expl <- list_vars_sig[index_lowest,7]		# lowest_dev_expl <- 0.29

  # calculate the change in deviance explained (i.e. should we keep going?)
	delta_dev_expl <- lowest_dev_expl - last_dev_expl 					# 

	if (nrow(list_vars_sig)>0) {
		if (delta_dev_expl < delta_dev_expl_thresh)  {
			keep_going = FALSE
		}
	    }

	if (nrow(list_vars_sig)==0) {
	  	keep_going = FALSE
	    }

	# output info
	info <- paste(lowest_name, round(lowest_aic,2), round(delta_dev_expl,5),"keep going",keep_going, sep = " | ")
	write(info, file = out_file, append=TRUE)
	
	# update last_aic
	last_aic <- lowest_aic

	# update last dev_expl
	last_dev_expl <- lowest_dev_expl

	# update last LL
	last_LL <- lowest_LL

	# update last_nparms
	last_nparms <- lowest_nparms

  # IF that last cov satisfied our threshold for inclusion, update current formula, update list_vars
	if (keep_going == TRUE) {
	current_formula <- paste0(current_formula," + ",list_vars[list_vars$var_name==lowest_name,2])
	# update list_vars
	list_vars <- list_vars[list_vars$var_name!=lowest_name,]
     }

  #	in the unlikely event that every variable we initially considered should be included, stop here too 
  #   we'll know we got every variable if the length of current formula (total elements, including z, ~, and year)
  #		is equal to nvars + 3
	current_formula_formula <- as.formula(current_formula)
 	if (length(current_formula_formula) == nvars + 2) {
	  keep_going <- FALSE
	}

  # if that last added variable didn't make the cut or it did, but it was the last one and we updated current_formula,
  #	then define best model 
	if (keep_going == FALSE) {
	best_formula <- current_formula
     }

   }

 # now we have "best_formula"
 #	refit the GAM, return the model object
	best_formula_formula <- as.formula(best_formula)

	best_gam <- gamm4(best_formula_formula, data = data_set, family= 'gaussian', 
		knots = list(Moon=c(0,1), Hour=c(0,24), Yday=c(0,366)), na.action = na.omit)

	return(best_gam)

} 
		
# --------------------------------------  FUNCTION 4 END













































