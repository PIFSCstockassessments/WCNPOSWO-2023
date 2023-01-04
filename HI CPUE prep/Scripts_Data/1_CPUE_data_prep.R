##########################
#	CPUE standardization data handling for the Hawaii-based LL fleet for the 2021 terminal year swordfish WCNPO Stock Assessment
#	Erin Bohaboy erin.bohaboy@noaa.gov
#
#  21October 2022
#
#  ------ various notes
#  Erin spent a few hours trying to figure out why there were so many shallow sets shown south of the Hawaiian Islands 
#	after 2004 in the 2018 report. It was actually an error in the code used to generate those figures.
#	See CPUEStandardization_19Sep.R for all the stuff I investigated.
#	
#    So, the figures and summary statistics / descriptions in the report were incorrect, but the error did not
#	propagate into the actual CPUE standardization, so there shouldn't be much of an effect.
#	Also, once the figures are corrected, it is more obvious that the fishery is shrinking towards the north,
#	I don't know if they discussed this much last time.
#
#  NOTE: these are logbook data (not observer data as stated in the 2018 report)
#
#  creates workspace
#	1_CPUE_data.RData 


##########################

#  	rm(list=ls())

	library(ggplot2)
	library(maps)				# install.packages('maps')
  	library(sf)				# install.packages('sf')
	library(reshape2)				# install.packages('reshape2')			
	library(sp)					# install.packages('sp')
	library(plyr)
	library(dplyr)
	library(gridExtra)
      library(lme4)				# install.packages('lme4')
      library(statmod)				# install.packages('statmod')
	library(MASS)
	library(lunar)
	library(this.path)
	library(sqldf)
	library(lubridate)
	#  	Can check for colorblind-friendly at https://www.color-blindness.com/coblis-color-blindness-simulator/

    #	options(scipen=999)			# turn OFF scientific notation
    #	options(scipen=0)				# turn ON scientific notation (default)

# establish directories using this.path
  	root_dir <- this.path::here(.. = 0)

# preliminary data handling, either load workspace or perform below:
  #	load(paste0(root_dir, '/1_CPUE_data.RData')) 		# most up-to-date

# ensure root_dir wasn't changed when loading the workspace
  	root_dir <- this.path::here(.. = 0)



#  ------------------------------------------
#	PRELIMINARY DATA HANDLING
#  ------------------------------------------

# read in data, already with environmental covariates added
	SWO <- read.csv(paste0(root_dir, '/SWO_CPUE_94_21_corrected.csv'), header=TRUE)

	str(SWO)			# 425,619 records		# names(SWO)		#summary(SWO)
					# SWO$LATITUDE[100000:101000]		# head(SWO)

## well, now we are missing the actual lat/long (all are rounded to full or half deg)
##	binning is now confusing because the bins will be #.76 to #.75 
##	use the "raw" data to reattach lat/long
####	WARNING WARNING WARNING: UNIQUE_SET_ID is not a consistent set identifier. Always check it, or, merge on
####			year, month, day, beginsettime, permit
## Michelle said Lat and Long are the mid-point of begin_set and end_haul		# summary(raw$BEGIN_SET_LONGITUDE_DEGREES)

	raw <- read.csv(paste0(root_dir, '/SWO_logbk_95_22_raw.csv'), header=TRUE)
	# str(raw)		# head(raw)			#nrow(raw)	# names(raw)		#465,522

	nrow(subset(raw, is.na(raw$BEGIN_SET_LATITUDE_DEGREES)))

	string <- "SELECT DISTINCT UNIQUE_SET_ID,PERMIT_NUMBER, BEGIN_SET_LATITUDE_DEGREES, BEGIN_SET_LATITUDE_MINUTES,
				BEGIN_SET_LONGITUDE_DEGREES, BEGIN_SET_LONGITUDE_MINUTES,
				END_HAUL_LATITUDE_DEGREES, END_HAUL_LATITUDE_MINUTES,
				END_HAUL_LONGITUDE_DEGREES, END_HAUL_LONGITUDE_MINUTES, SWO_CPUE

				FROM raw
				"

  	set_lat_lon_1 <- sqldf(string, stringsAsFactors=FALSE)		# str(set_lat_lon_1)

	set_lat_lon_2 <- mutate(set_lat_lon_1, BEGIN_LAT = BEGIN_SET_LATITUDE_DEGREES + BEGIN_SET_LATITUDE_MINUTES/60,
						BEGIN_LON = BEGIN_SET_LONGITUDE_DEGREES + BEGIN_SET_LONGITUDE_MINUTES/60,
						END_LAT = END_HAUL_LATITUDE_DEGREES + END_HAUL_LATITUDE_MINUTES/60,
						END_LON = END_HAUL_LONGITUDE_DEGREES + END_HAUL_LONGITUDE_MINUTES/60)
	set_lat_lon_3 <- mutate(set_lat_lon_2, LAT_MID = (BEGIN_LAT + END_LAT)/2, LON_MID = (BEGIN_LON + END_LON)/2)

	head(set_lat_lon_3)


# confirm that unique_set_ids match by checking permit_number
# answer is yes, skip to below
  #	string <- "SELECT SWO.*,set_lat_lon_3.PERMIT_NUMBER as Permit_number_raw, set_lat_lon_3.LAT_MID, set_lat_lon_3.LON_MID,  set_lat_lon_3.SWO_CPUE as raw_cpue
  #			FROM
  #				SWO LEFT JOIN set_lat_lon_3
  #					ON SWO.UNIQUE_SET_ID = set_lat_lon_3. UNIQUE_SET_ID"
  #	SWO2 <- sqldf(string, stringsAsFactors=FALSE)		# head(SWO2)		# 425,619 	#summary(SWO2)
  #
  #	# double check that permit numbers match
  #	sum(SWO2$PERMIT_NUMBER!=SWO2$Permit_number_raw,na.rm=TRUE)
  #	# YAY!
  #
  #	# remake SWO2 without permit number
  #	rm(SWO2)

	string <- "SELECT SWO.*,set_lat_lon_3.LAT_MID, set_lat_lon_3.LON_MID,  set_lat_lon_3.SWO_CPUE as raw_cpue
			FROM
				SWO LEFT JOIN set_lat_lon_3
					ON SWO.UNIQUE_SET_ID = set_lat_lon_3. UNIQUE_SET_ID"
	SWO2 <- sqldf(string, stringsAsFactors=FALSE)		# nrow(SWO2)		# 425,619 	#summary(SWO2)

# There is a single set where CPUE was 1.14 in the dataset w/ covars (SWO2) but was zero in the raw data
#   assume CPUE value in SWO2 was correct 
  #	SWO2$raw_cpue[is.na(SWO2$raw_cpue)] <- 0
  #	summary(SWO2$SWO_CPUE - SWO2$raw_cpue)
  #	index_me <- SWO2$SWO_CPUE - SWO2$raw_cpue
  #	index_me[index_me>0.1] 

  # 	There were 4 NA'S introduced during the merge between raw and SWO2 
  #	these sets were all missing end_haul lat and lon in raw, given data were incomplete, exclude those 4 sets,
  #   (in addition to one UNIQUE_SET_ID = NA) later

	SWO2$Date<-as.Date(with(SWO2,paste(HAUL_YEAR,HAUL_MONTH,HAUL_DAY,sep="-")),"%Y-%m-%d")
	SWO2 <- mutate(SWO2, Moon_radians = lunar.phase(Date, shift = 10))
  
  #  2pi radians = a whole moon phase. divide by 2pi, new moon is 0, full is 0.5, knot at 1.		# str(SWO2)
   	SWO2 <- mutate(SWO2, Moon = round((Moon_radians/(2*pi)),digits=2))

  #  add day of year, knot at 366
	SWO2 <- mutate(SWO2, Yday = yday(Date))			# summary(SWO2$Yday)

# redefine SWO
	rm(SWO)
	SWO <- SWO2			#nrow(SWO)				# 425,619 sets

# MICHELLE'S NOTES:
# SWO_NIND is number of individuals, CPUE is fish per 1000 hooks
# Permit number is a unique identifier for each vessel - even if the vessel changes its name. 
#	When you are plotting the data you can use this to make sure there are at least three vessels per category, 
#	I also sometimes use it as a random effect to account for fishing vessel. 
# Target species code can be T= tuna, B = Billfish (i.e. swordfish), or M = Mixed (both). 
#	M only occurs prior to 2004, after which fishermen have to declare which type of set they are using, 
#		deep or shallow, prior to the trip leaving. 
#	The definition of a deep set is > 10 hooks per float until 2004, and >=14 hooks per float after 2004.
#  UPDATE!!!!!!!!!!!!!!!!!!!!!
#  21NOv, deep-sets are 15+ HPF. 14 is included with shallow after 2005


## create dataframe with all desired covariates				# SWO[400000,]
	SWOCPUE<-data.frame("Year"=SWO[,"HAUL_YEAR"],
				"Month"=SWO[,"HAUL_MONTH"],
				"Day"=SWO[,"HAUL_DAY"],
				"Permit"=SWO[,"PERMIT_NUMBER"],
				"Target" = SWO[,"TRIP_TYPE_CODE"],
				"Lat"=SWO[,"LAT_MID"],
				"Lon"=SWO[,"LON_MID"]*-1,
                    	"ID"=SWO[,"UNIQUE_SET_ID"],
				"Set"=rep("ASSIGN_ME", nrow(SWO)),
				"Bait"=SWO[,"BAIT_CODE"],
                    	"BeginSetTime"=SWO[,"BEGIN_SET_TIME"],
				"HPF"=SWO[,"HOOKS_PER_FLOAT"],
				"HPSet"=SWO[,"NUMBER_OF_HOOKS_SET"],
				"Lightsticks"=SWO[,"NUMBER_OF_LIGHT_STICKS"],
                    	"SST"=SWO[,"SSTDEGC"],
				"PDO"=SWO[,"PDO_INDEX"],
				"SOI"=SWO[,"SOI"],
				"Illum"=SWO[,"Lunar"],
                    	"Moon"=SWO[,"Moon"],
				"MLD"=SWO[,"MLD"],					# mixed layer depth
				"Yday"=SWO[,"Yday"],
				"CatNum"=SWO[,"SWO_NIND"],
				"CPUE"=SWO[,"SWO_CPUE"])
	# head(SWOCPUE)
	

 # assign set type
 #  ------------------------------------------
 # 	UPDATE  12October 2022.
 #	After fitting models and looking at deep sets, 10 < HPF < 15 can't be included pre-2005 
 #		and excluded post-2005 as deep sets without causing weird behavior in models.
 #	It's OK to have 2 different definitions of shallow set because they are two different indices
 #	but, we can only have 1 definition of deep set if we want to keep it as a single index

    	SWOCPUE$Set[SWOCPUE$HPF>=15] <- "D"	
   	SWOCPUE$Set[SWOCPUE$HPF<=10 & SWOCPUE$Year < 2004 ] <- "S"		
   	SWOCPUE$Set[SWOCPUE$HPF<15 & SWOCPUE$Year>=2004 ] <- "S"		#summary(as.factor(SWOCPUE$Set))	

# check number of records
	nrow(SWOCPUE)							#425,619
  	nrow(subset(SWOCPUE, Set == 'D'))				#380,920		380920+43808+891	
  	nrow(subset(SWOCPUE, Set == 'S'))				#43,808
  	nrow(subset(SWOCPUE, Set == 'ASSIGN_ME'))			#891		
										# but that includes "shallow" sets in years 2001, 02, 03, 04, 
										# which we don't care about
	nrow(subset(SWOCPUE, Set == 'ASSIGN_ME' & Year > 2000 & Year < 2005))		# 318		891-318	= 573

# how many sets had 11-14 hooks prior to 2001?
										# throwaway <- subset(SWOCPUE, Year < 2001 & HPF > 10 & HPF < 15)
										# str(throwaway)		#summary(as.factor(throwaway$Target))
										# nrow(subset(throwaway, CPUE == 0))	#499/573

#  Set = "ASSIGN_ME" (891 records) exclude now			# summary(as.factor(SWOCPUE$Set))
SWOCPUE <- subset(SWOCPUE, Set != "ASSIGN_ME")			# str(SWOCPUE)  (n = 424,728)			#573/424715


# check for NAs and weird stuff
  # 	summary(SWOCPUE)

# remove NA's in Bait, Lat/Lon, ID
  	SWOCPUE<-subset(SWOCPUE,!is.na(Bait)&!is.na(Lat)&!is.na(Lon)&!is.na(ID))		#nrow(SWOCPUE)	# 424,692

# replace NA with zeros for lightsticks
	SWOCPUE$Lightsticks[is.na(SWOCPUE$Lightsticks)] <- 0

# leave NAs in SST. We don't want to throw away all those sets now because we might not use SST in the standardization
	
# there are 1 records where HPSet = 0 and 1 record where HPFloat = 0.
# 	these were all zero catch sets. Assume error in data, eliminate those records.
	nrow(subset(SWOCPUE,HPF==0))				# 1 record where HPF is zero
	nrow(subset(SWOCPUE,HPSet==0))			# 1 record where HPSet is zero
	SWOCPUE<-subset(SWOCPUE,HPSet>0&HPF>0)		#nrow(SWOCPUE)	# 424,690

# assign 1 deg and 5 deg lat/lon grids					# try <- seq(0,3,0.1)		#floor(try)
	SWOCPUE$Lat1<-ceiling(SWOCPUE$Lat)-0.5
	SWOCPUE$Lon1<-ceiling(SWOCPUE$Lon)-0.5
	SWOCPUE$Lat5<-(ceiling(SWOCPUE$Lat/5)*5)-2.5
	SWOCPUE$Lon5<-(ceiling(SWOCPUE$Lon/5)*5)-2.5

# assign quarter of year
	Q1<-which(SWOCPUE$Month>=1&SWOCPUE$Month<=3)
	Q2<-which(SWOCPUE$Month>=4&SWOCPUE$Month<=6)
	Q3<-which(SWOCPUE$Month>=7&SWOCPUE$Month<=9)
	SWOCPUE$Quarter<-4
	SWOCPUE[Q1,"Quarter"]<-1
	SWOCPUE[Q2,"Quarter"]<-2
	SWOCPUE[Q3,"Quarter"]<-3
	
#  assign quarter of day
	SWOCPUE$Begin<-ifelse(SWOCPUE$BeginSetTime>=0&SWOCPUE$BeginSetTime<=600,1,
                      ifelse(SWOCPUE$BeginSetTime>600&SWOCPUE$BeginSetTime<=1200,2,
                             ifelse(SWOCPUE$BeginSetTime>1200&SWOCPUE$BeginSetTime<=1800,3,4)))

	# str(SWOCPUE)
	# summary(SWOCPUE)

#  make an hour column for GAMM		# try <- head(SWOCPUE)			#str(SWOCPUE)		#summary(SWOCPUE)
	# View(subset(SWOCPUE, is.na(SWOCPUE$Hour)))

	SWOCPUE$Hour <-  substr(as.character(SWOCPUE$BeginSetTime),1,nchar(as.character(SWOCPUE$BeginSetTime))-2)
	SWOCPUE$Hour <-  as.numeric(SWOCPUE$Hour)
	# times between midnight and 1 am (hour = 0) will come out as NA
	SWOCPUE$Hour[is.na(SWOCPUE$Hour)] <-  0


# make a copy of this dataset
#	SWOCPUE_prelim <- SWOCPUE			#  SWOCPUE_prelim -> SWOCPUE


#  add bait code groups because having 40+ levels for a fixed effect is a lot of wasted params, 
#	especially because N per level is so unbalanced.
#	even having 10 is kind of a lot.					#str(SWOCPUE)

# simplify the bait codes into fewer categories. See 
# dplyr::count(SWOShala,Bait)
# dplyr::count(SWOShalb,Bait)
# dplyr::count(SWODeep,Bait)			plyr::

  bait_codes <- read.csv(paste0(root_dir, '/bait_codes.csv'), header=TRUE)		#bait_codes

	#names(SWOCPUE)

	string <- "SELECT SWOCPUE.*,bait_codes.Bait_name , bait_codes.Bait_group
  			FROM
  				SWOCPUE LEFT JOIN bait_codes
  					ON SWOCPUE.Bait = bait_codes.Bait"
  	SWOCPUE2 <- sqldf(string, stringsAsFactors=FALSE)		# head(SWOCPUE2)		# str(SWOCPUE2)	#	
  
 rm(SWOCPUE)
 SWOCPUE <- SWOCPUE2

#  add a presence/absence column
	SWOCPUE$z <- 0
	SWOCPUE[SWOCPUE$CPUE > 0,"z"]=1			#summary(as.factor(SWOCPUE$z))


# check correlations of candidate continuous covars
# 	cor(subset(SWOCPUE, !is.na(SST) & Set=="S")[,c("CPUE","MLD","Lat","Lon","SST","PDO","SOI","Illum","Moon","Lightsticks" )])
# strongest correlations are only ~0.45: Lon:MLD, SST:MLD, and Lat:lightsticks
	
#	cor(subset(SWOCPUE, !is.na(SST) & Set=="D")[,c("CPUE","MLD","Lat","Lon","SST","PDO","SOI","Illum","Lightsticks" )])
# some correlations, note larger sample size. Lat:MLD

# SOI and PDO are generally about -0.5, so maybe only include 1. Also, consider that SOI and PDO might actually influence
#	swordfish abundance, so including here might not be entirely wise.

#  summary(SWOCPUE$Lightsticks)		#
SWOCPUE <- mutate(SWOCPUE, LPH = Lightsticks/HPSet)
# summary(SWOCPUE)
SWOCPUE$Lightsticks_YN <- SWOCPUE$Lightsticks
SWOCPUE$Lightsticks_YN[SWOCPUE$Lightsticks==0] <- 'N'
SWOCPUE$Lightsticks_YN[SWOCPUE$Lightsticks>0] <- 'Y'
SWOCPUE$Lightsticks_YN <- as.factor(SWOCPUE$Lightsticks_YN)		#summary(SWOCPUE$Lightsticks_YN)




#  ------------------------------
#	make GAMM datasets
#
#
# divide the CPUE data into 3 seperate datasets: shallow set before the closure (2000 and earlier),
#		shallow set after the closure (2004+), deepset
# the fishery was open in January 2001 and June-Dec 2004, but we exclude sets from these partial years.

SWOShala <- subset(SWOCPUE,Set=="S"&Year<2001)  #nrow(SWOShala)	#24,233	#summary(as.factor(SWOShala$z))[1]/nrow(SWOShala)	#14.7% zeros
SWOShalb <- subset(SWOCPUE,Set=="S"&Year>2004)  #nrow(SWOShalb)	#18,728	#summary(as.factor(SWOShalb$z))[1]/nrow(SWOShalb)	#1.1% zeros
SWODeep  <- subset(SWOCPUE,Set=="D")  		#nrow(SWODeep)	#380,885	#summary(as.factor(SWODeep$z))[1]/nrow(SWODeep)		#84.2% zeros

# summary(as.factor(SWOShala$Target))
# summary(as.factor(SWOShalb$Target))
# summary(as.factor(SWODeep$Target))

# how are space (Lat/Lon) and environment (SST/MLD) correlated?
	put_together <- rbind(SWOShala, SWOShalb, SWODeep)
	cor(subset(put_together, !is.na(SST))[,c("Lat","Lon","MLD","SST","PDO","SOI","Yday")])

	just_shallow <- rbind(SWOShala, SWOShalb)
	cor(subset(just_shallow, !is.na(SST))[,c("Lat","Lon","MLD","SST","PDO","SOI","Yday")])

	cor(subset(SWOShalb, !is.na(SST))[,c("Lat","Lon","MLD","SST","PDO","SOI","Yday")])

	cor(subset(SWODeep, !is.na(SST))[,c("Lat","Lon","MLD","SST","PDO","SOI","Yday")])

#	plot(SWOShalb$Yday, SWOShalb$SST)

# in the last assessment, 15 explainatory variables were considered.
# Random: Permit
# Fac: Year, Quarter, Bait, HPF, Begin
# Cont: SST, MLD, HPSet, Illum, PDO, SOI, Lat, Lon
#	*** note CPUE is N per 1000 hooks, hence including a measure of total effort (HPSet) only makes sense in the binomial
#		one could argue it would make more sense for CPUE to be fish per set, and HPSet would always be a cov.
# They also considered BeginSetTime as a categorical var.

# take a look around		#

# hist(SWOShalb$LPH, breaks = seq(0,6,0.1))	#summary(SWOShalb$LPH)	#obviously using 4.7 lightsticks per hook is an error
# deep_lph <- hist(SWODeep$LPH)	#summary(SWODeep$LPH)	#obviously using 4.7 lightsticks per hook is an error


# hist(SWOShala$HPF, breaks=seq(0,16,1))
# summary(as.factor(SWOShala$HPF))			# 9 levels
# summary(as.factor(SWOShalb$HPF))			# 10 levels
# length(summary(as.factor(SWODeep$HPF)))		# range 14 to 88, 43 levels, could easily bin it.

# summary(as.factor(SWOShala$Bait))			# 11 levels
# summary(as.factor(SWOShalb$Bait))			# 13 levels
# length(summary(as.factor(SWODeep$Bait)))		# 42 levels. do not bin.


SWOShala$HPF_fac <- as.factor(SWOShala$HPF)				# summary(as.factor(SWODeep$HPF))
SWOShalb$HPF_fac <- as.factor(SWOShalb$HPF)
SWODeep$HPF_fac <- as.factor(floor(SWODeep$HPF/5)*5)		# summary(SWODeep$HPF_fac)	#try <- seq(15,25,1)	#floor(try/5)*5
	# make a 55+ HPF bin
SWODeep$HPF_fac[SWODeep$HPF>=55] <- 55
SWODeep$HPF_fac <- droplevels(SWODeep$HPF_fac)

# standardize the effort variable within each dataset

	SWOShala <- mutate(SWOShala, HPSet_std = (HPSet - mean(SWOShala$HPSet))/sd(SWOShala$HPSet))
	SWOShalb <- mutate(SWOShalb, HPSet_std = (HPSet - mean(SWOShalb$HPSet))/sd(SWOShalb$HPSet))
	SWODeep <- mutate(SWODeep, HPSet_std = (HPSet - mean(SWODeep$HPSet))/sd(SWODeep$HPSet))

# Create factor variables and drop unused levels for each dataset
#	prob not necessary, but good to make sure

SWOShala <- mutate(SWOShala, Year_fac = as.factor(Year), Quarter_fac = as.factor(Quarter), 
		Bait_fac = as.factor(Bait_group), Begin_fac = as.factor(Begin), Permit_fac = as.factor(Permit))
SWOShala <- droplevels(SWOShala)

SWOShalb <- mutate(SWOShalb, Year_fac = as.factor(Year), Quarter_fac = as.factor(Quarter), 
		Bait_fac = as.factor(Bait_group), Begin_fac = as.factor(Begin), Permit_fac = as.factor(Permit))
SWOShalb <- droplevels(SWOShalb)

SWODeep <- mutate(SWODeep, Year_fac = as.factor(Year), Quarter_fac = as.factor(Quarter), 
		Bait_fac = as.factor(Bait_group), Begin_fac = as.factor(Begin), Permit_fac = as.factor(Permit))
SWODeep <- droplevels(SWODeep)

# make a positive catches only dataset for each
SWOShala_pos <- subset(SWOShala, z == 1)				#nrow(SWOShala_pos)
SWOShalb_pos <- subset(SWOShalb, z == 1)
SWODeep_pos <- subset(SWODeep, z == 1)


# ls()


## --------
## MAKE MAPPING DATASETS
## for creating figures which are compliant with confidentiality agreement:
## use unique to return the dataframe of unique permit numbers, 
## then count how many there are in each lat/lon combo
## then if there are squares with <3, print the lat/lons so that in the SWOCPUE 
## dataframe I can make a column where those lat/lons are 0 = include and all others
## = 1


#  display_carto_all(colorblind_friendly = TRUE)


## need plyr not dplyr for this set of code
#	(or could be done in sqldf)
#	library(plyr)

# vessel x year x 1deg grid. Note that shallow or deep is not included as a stratum in the confidentiality criteria. 
	SWOUnique_1 <- unique(SWOCPUE[,c("Year","Lat1","Lon1","Permit")])		# head(SWOUnique_1)		#nrow(SWOUnique_1)	#154,501
	UniqueCount_1 <- plyr::count(SWOUnique_1,vars=c("Year","Lat1","Lon1"))		# head(UniqueCount_1)	#nrow(UniqueCount_1)	#17,602
	names(UniqueCount_1)[length(names(UniqueCount_1))] <- "freq_1"			#View(UniqueCount_1)

	SWOUnique_5 <- unique(SWOCPUE[,c("Year","Lat5","Lon5","Permit")])			
	UniqueCount_5 <- plyr::count(SWOUnique_5,vars=c("Year","Lat5","Lon5"))	
	names(UniqueCount_5)[length(names(UniqueCount_5))] <- "freq_5"			#nrow(UniqueCount_5)		#1,496		#17602/25

	# merge this info back onto the CPUE dataset
	SWOCPUE <- merge(SWOCPUE,UniqueCount_1,by=c("Year","Lat1","Lon1"))		#str(SWOCPUE)	#str(UniqueCount_1)
	SWOCPUE$Include_1 <- ifelse(SWOCPUE$freq_1<3,0,1)

	SWOCPUE <- merge(SWOCPUE,UniqueCount_5,by=c("Year","Lat5","Lon5"))		#str(SWOCPUE)	#str(UniqueCount_5)
	SWOCPUE$Include_5 <- ifelse(SWOCPUE$freq_5<3,0,1)

# make duplicate datasets of SWOCPUE with only mappable grids for each resolution 
	SWOMapping1<-subset(SWOCPUE,Include_1==1)							#str(SWOMapping1)
	SWOMapping5<-subset(SWOCPUE,Include_5==1)

# calculate averages per grid x year x settype							#head(CPUE_avgs_1)
	CPUE_avgs_1 <- aggregate(SWOMapping1$CPUE,
		by=list(SWOMapping1$Year, SWOMapping1$Lat1 , SWOMapping1$Lon1, SWOMapping1$Set),mean)
	names(CPUE_avgs_1) <- c("Year","Lat","Lon","Set","CPUE")				
			#nrow(subset(CPUE_avgs_1, Set == 'S'))			#nrow(subset(CPUE_avgs_1, Set == 'D'))

	CPUE_avgs_5 <- aggregate(SWOMapping5$CPUE,
		by=list(SWOMapping5$Year, SWOMapping5$Lat5 , SWOMapping5$Lon5, SWOMapping5$Set),mean)		#nrow(CPUE_avgs_5)
	names(CPUE_avgs_5) <- c("Year","Lat","Lon","Set","CPUE")
			#nrow(subset(CPUE_avgs_5, Set == 'S'))	#552		#nrow(subset(CPUE_avgs_5, Set == 'D'))	#943

#  aggregate across all years by 1 and 5 deg. grids
	SWOUnique_all_1 <- unique(SWOCPUE[,c("Lat1","Lon1","Permit")])			# nrow(UniqueCount_all_1)	#1726
	UniqueCount_all_1 <- plyr::count(SWOUnique_all_1,vars=c("Lat1","Lon1"))	
	names(UniqueCount_all_1)[length(names(UniqueCount_all_1))] <- "freq_1_allyr"

	SWOUnique_all_5 <- unique(SWOCPUE[,c("Lat5","Lon5","Permit")])			# nrow(UniqueCount_all_5)	#102
	UniqueCount_all_5 <- plyr::count(SWOUnique_all_5,vars=c("Lat5","Lon5"))
	names(UniqueCount_all_5)[length(names(UniqueCount_all_5))] <- "freq_5_allyr"

	# merge this info back onto the CPUE dataset
	SWOCPUE <- merge(SWOCPUE,UniqueCount_all_1,by=c("Lat1","Lon1"))		#nrow(SWOCPUE)	#head(SWOCPUE$Include_1_allyr)	#424,690
	SWOCPUE$Include_1_allyr <- ifelse(SWOCPUE$freq_1_allyr<3,0,1)

	SWOCPUE<-merge(SWOCPUE,UniqueCount_all_5,by=c("Lat5","Lon5"))		#str(SWOCPUE)	#str(UniqueCount_1)
	SWOCPUE$Include_5_allyr<-ifelse(SWOCPUE$freq_5_allyr<3,0,1)

# make duplicate datasets of SWOCPUE with only mappable grids for each resolution 
	SWOMapping1_allyr <-subset(SWOCPUE,Include_1_allyr==1)			#nrow(SWOMapping5_allyr)	
	SWOMapping5_allyr <-subset(SWOCPUE,Include_5_allyr==1)			# head(SWOMapping5_allyr)		

# calculate averages per grid x settype
	CPUE_avgs_1_allyr <- aggregate(SWOMapping1_allyr$CPUE,
		by=list(SWOMapping1_allyr$Lat1 , SWOMapping1_allyr$Lon1, SWOMapping1_allyr$Set),mean)	# str(CPUE_avgs_1_allyr)	#1933
	names(CPUE_avgs_1_allyr) <- c("Lat","Lon","Set","CPUE")
	# str(subset(CPUE_avgs_1_allyr, Set == 'D'))	#1129		# str(subset(CPUE_avgs_1_allyr, Set == 'S'))		#804


	CPUE_avgs_5_allyr <- aggregate(SWOMapping5_allyr$CPUE,
		by=list(SWOMapping5_allyr$Lat5 , SWOMapping5_allyr$Lon5, SWOMapping5_allyr$Set),mean)
	names(CPUE_avgs_5_allyr) <- c("Lat","Lon","Set","CPUE")				#str(CPUE_avgs_5_allyr)
	# str(subset(CPUE_avgs_5_allyr, Set == 'D'))	#79		# str(subset(CPUE_avgs_5_allyr, Set == 'S'))		#73


# ---------------------------------------------
# sum total effort (hooks set) per grid

	hooks_set_5 <- aggregate(SWOMapping5$HPSet,
		by=list(SWOMapping5$Year, SWOMapping5$Lat5 , SWOMapping5$Lon5, SWOMapping5$Set),sum)
	names(hooks_set_5) <- c("Year","Lat","Lon","Set","Hooks")
	hooks_set_5 <- mutate(hooks_set_5, thou_hooks = Hooks/1000)			#nrow(hooks_set_5)	#matches nrow(CPUE_avgs_5)
			#nrow(subset(hooks_set_5, Set == 'S'))	# 552		#nrow(subset(hooks_set_5, Set == 'D'))	# 943

	hooks_set_1 <- aggregate(SWOMapping1$HPSet,
		by=list(SWOMapping1$Year, SWOMapping1$Lat1 , SWOMapping1$Lon1, SWOMapping1$Set),sum)		#head(hooks_set_1)
	names(hooks_set_1) <- c("Year","Lat","Lon","Set","Hooks")
	hooks_set_1 <- mutate(hooks_set_1, thou_hooks = Hooks/1000)
			#nrow(subset(hooks_set_1, Set == 'S'))	# 3373 	#nrow(subset(hooks_set_1, Set == 'D'))	# 10005

	hooks_set_5_allyears <- aggregate(SWOMapping5_allyr$HPSet,
		by=list(SWOMapping5_allyr$Lat5 , SWOMapping5_allyr$Lon5, SWOMapping5_allyr$Set),sum)		#str(SWOMapping5)
	names(hooks_set_5_allyears) <- c("Lat","Lon","Set","Hooks")
	hooks_set_5_allyears <- mutate(hooks_set_5_allyears, thou_hooks = Hooks/1000)			#nrow(hooks_set_5)	#matches nrow(CPUE_avgs_5)
			#nrow(subset(hooks_set_5_allyears, Set == 'S'))	# 73		#nrow(subset(hooks_set_5_allyears, Set == 'D'))	# 79

	hooks_set_1_allyears <- aggregate(SWOMapping1_allyr$HPSet,
		by=list(SWOMapping1_allyr$Lat1 , SWOMapping1_allyr$Lon1, SWOMapping1_allyr$Set),sum)		#head(hooks_set_1)
	names(hooks_set_1_allyears) <- c("Lat","Lon","Set","Hooks")
	hooks_set_1_allyears <- mutate(hooks_set_1_allyears, thou_hooks = Hooks/1000)
			#nrow(subset(hooks_set_1_allyears, Set == 'S'))	# 804 	#nrow(subset(hooks_set_1_allyears, Set == 'D'))	# 1129


# download a shape file for US land areas from 
#	https://catalog.data.gov/dataset/tiger-line-shapefile-2016-nation-u-s-current-state-and-equivalent-national

	us <- st_read(paste0(root_dir, '/tl_2016_us_state/tl_2016_us_state.shp'))
	hawaii <- st_coordinates(subset(us,NAME=="Hawaii"))	
	hawaii_df <- as.data.frame(hawaii)

#  clean-up and save workspace			#str(SWOShala)

  	all_objs <- ls()
  	save_objs <- c("CPUE_avgs_1", "CPUE_avgs_1_allyr", "CPUE_avgs_5", "CPUE_avgs_5_allyr",
				"root_dir", "SWOCPUE", "SWOMapping1", "SWOMapping1_allyr", "SWOMapping5", 
				"SWOMapping5_allyr", "hawaii_df", "hooks_set_5", "hooks_set_1", "hooks_set_5_allyears", "hooks_set_1_allyears",
				"SWODeep", "SWODeep_pos", 
				"SWOShala", "SWOShala_pos",
				"SWOShalb", "SWOShalb_pos")
  	remove_objs <- setdiff(all_objs, save_objs)

  if (1 == 2) {
  	rm(list=remove_objs)
  	rm(save_objs)
  	rm(remove_objs)
  	rm(all_objs)
	}

 # rm(root_dir)

 #  save.image("C:\\Users\\Erin.Bohaboy\\Documents\\Swordfish\\Scripts_Data\\1_CPUE_data.RData") 

























