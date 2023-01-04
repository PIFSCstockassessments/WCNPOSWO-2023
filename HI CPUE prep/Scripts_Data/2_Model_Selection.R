#  --------------------------------------------------------------------------------------------------------------
#  perform model selection using functions
#	Erin Bohaboy erin.bohaboy@noaa.gov
#  --------------------------------------------------------------------------------------------------------------

# --- Load lots of libraries:
#  	rm(list=ls())
#  	Sys.setenv(TZ = "UTC")		# setting system time to UTC avoids bugs in sqldf
  	library(sqldf)
  	library(dplyr)
#  	library(tidyr)
	library(fitdistrplus)
#	library(mgcv)
	library(formula.tools)
 	library(this.path)
#	library(assertthat)
	library(ggplot2)
	library(emmeans)	
	library(lme4)

# establish directories using this.path
  	root_dir <- this.path::here(.. = 0)

# load(paste0(root_dir, '/1_CPUE_data.RData'))
# load(paste0(root_dir, '/2_Best_Models.RData')) 


# use source() to get the functions
 source(paste0(root_dir, '/2_Model_Selection_Functions.R'))

# contains 4 functions:
# binomial_linear(data_set, var_name, out_directory, delta_dev_expl_thresh = 0.0025)
# binomial_gam(data_set, var_name, out_directory, delta_dev_expl_thresh = 0.0025)
# lognormal_linear(data_set, var_name, out_directory, delta_dev_expl_thresh = 0.0025)
# lognormal_gam(data_set, var_name, out_directory, delta_dev_expl_thresh = 0.0025)


# NOTE
#	I put all the code here but I actually ran this on multiple machines and then combined the model objects back together to make the
#	2_Best_Models.RData workspace



# Shallow A --------------------------------------------------------------------------------------------------

# binom			#str(SWOShala)

	out_directory <- paste(root_dir, "/model_output", sep="")

	var_name = c( 'HPSet_std', "s(Lat)", 'Bait_fac', 'HPF_fac', 'SST', 'MLD', 'SOI', 'PDO', 'Lightsticks_YN',
			 "s(Lon, k=6)", "s(Moon, bs='cc')", "s(Yday, bs='cc')", "s(Hour, bs='cc')")

	delta_dev_expl_thresh <- 0.0025

	data_set <- SWOShala


#	Shallow_A_Binom_18Oct <- binomial_gam(data_set, var_name, out_directory, delta_dev_expl_thresh)
	Shallow_A_Binom_28Nov <- binomial_gam(data_set, var_name, out_directory, delta_dev_expl_thresh)


#  LnN
	out_directory <- paste(root_dir, "/model_output", sep="")

	var_name = c( "s(Lat)", 'Bait_fac', 'HPF_fac', 'SST', 'MLD', 'SOI', 'PDO', 'Lightsticks_YN', 
			 "s(Lon, k=6)", "s(Moon, bs='cc')", "s(Yday, bs='cc')", "s(Hour, bs='cc')")

	delta_dev_expl_thresh <- 0.0025

	data_set <- SWOShala_pos
	# summary(data_set)

	Shallow_A_LnN_29Nov <- lognormal_gam(data_set, var_name, out_directory, delta_dev_expl_thresh)
	# plot(Shallow_A_LnN_update$gam)



# Shallow B --------------------------------------------------------------------------------------------------



#  LnN	run on PICV003 28Nov
	out_directory <- paste(root_dir, "/model_output", sep="")

	var_name = c( "s(Lat)", 'Bait_fac', 'HPF_fac', 'SST', 'MLD', 'SOI', 'PDO', 'Lightsticks_YN','LPH', 
			 "s(Lon)", "s(Moon, bs='cc')", "s(Yday, bs='cc')", "s(Hour, bs='cc')")

	delta_dev_expl_thresh <- 0.0025

	data_set <- SWOShalb_pos
	# summary(data_set)

	shallow_b_lnN_update <- lognormal_gam(data_set, var_name, out_directory, delta_dev_expl_thresh)		
	# summary(shallow_b_lnN_update$gam)



# Deep --------------------------------------------------------------------------------------------------


# binom

# must fit using a subset of data

	out_directory <- paste(root_dir, "/model_output", sep="")

	var_name = c( "s(Lat)", 'HPSet_std', 'Bait_fac', 'HPF_fac', 'SST', 'MLD', 'SOI', 'PDO', 
			 "s(Lon)", "s(Moon, bs='cc')", "s(Yday, bs='cc')", "s(Hour, bs='cc')")

	delta_dev_expl_thresh <- 0.0025

	data_set <- SWODeep[sample(nrow(SWODeep), size = 20000, replace = FALSE),]
	# summary(data_set)

	Deep_binom_20K <- binomial_gam(data_set, var_name, out_directory, delta_dev_expl_thresh)
	 #  then fit the selected model using full dataset


# LnN

      out_directory <- paste(root_dir, "/model_output", sep="")

	var_name = c( "s(Lat)", 'Bait_fac', 'HPF_fac', 'SST', 'MLD', 'SOI', 'PDO', 
			 "s(Lon)", "s(Moon, bs='cc')", "s(Yday, bs='cc')", "s(Hour, bs='cc')")

	delta_dev_expl_thresh <- 0.0025

	data_set <- SWODeep_pos
	# summary(data_set)

      deep_lnN_update <- lognormal_gam(data_set, var_name, out_directory, delta_dev_expl_thresh)






#  clean-up and save workspace  --------------------------------------------------------------------------------------------------

  	all_objs <- ls()
  	save_objs <- c("Shallow_A_LnN_29Nov","root_dir")					# list objects we want to save here
  	remove_objs <- setdiff(all_objs, save_objs)

  if (1 == 2) {
  	rm(list=remove_objs)
  	rm(save_objs)
  	rm(remove_objs)
  	rm(all_objs)
	}

 #  save.image("C:\\Users\\Erin.Bohaboy\\Documents\\Swordfish\\2_Best_Models.RData") 
 # rm(root_dir)












#



