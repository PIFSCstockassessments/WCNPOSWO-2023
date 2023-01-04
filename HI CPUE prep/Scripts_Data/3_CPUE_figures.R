##########################
#	FIGURES for Hawai'i Longline Swordfish data, covariables, and CPUE
#
#
#
##########################

#  	rm(list=ls())

	library(mgcv)
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
	library(ggridges)
	library(magrittr)
	library(grid)			#install.packages('grid')
	library(cowplot)			#install.packages('cowplot')
	library(lattice)			#install.packages('lattice')
	library(ggplotify)
	library(ggeffects)				#install.packages('ggeffects')	
 	library(data.table)		# careful there is a lot of overlap between data.table and lubridate

    #	options(scipen=999)			# turn OFF scientific notation
    #	options(scipen=0)				# turn ON scientific notation (default)

# establish directories using this.path
  	root_dir <- this.path::here(.. = 0)

# preliminary data handling, load workspace:
  load(paste0(root_dir, '/1_CPUE_data.RData'))

# load fitted model objects and CPUE predictions
   load(paste0(root_dir, '/2_Best_Models.RData'))
   
   load(paste0(root_dir, '/3_CPUE_predicted.RData'))
  
   source(paste0(root_dir, '/LOAD_theme.R'))

# load in the slightly modified gam.check function that includes a qqline, horizontal, and 1:1 lines for the diagnostics
   source(paste0(root_dir, '/modified_gam_check.R'))


#  preliminaries:
# make a df to use for the x-axis when plotting yday
yday_axis <- data.frame('month'=c(seq(1,12,1),12), 'day' = c(rep(1,12),31), 'year' = rep(2021, 13),
		'label' = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', ''))
yday_axis$date <- as.Date(with(yday_axis,paste(year,month,day,sep="-")),"%Y-%m-%d")
yday_axis <- mutate(yday_axis, Yday = yday(date))





#  ------------------------------------------------------
#	EXPLORATORY FIGURES used in report
#  ------------------------------------------------------
#  ------------------------------------------------------

# WARNING: coord_fixed() is tricky, makes it difficult to manipulate margins
#	so when specifying dimensions of .png, just specify width then trim off top and bottom w/ crop

# --------------
# Fig. 4. Nom. CPUE, Shallow set, 1 deg. grid, aggregate over all years
shallow_avgs_1_allyr <- subset(CPUE_avgs_1_allyr, Set=='S')			#head(shallow_avgs_5_allyr)

 p <-  ggplot() +
	geom_raster(data = shallow_avgs_1_allyr, aes(x = Lon, y = Lat, fill = CPUE))+
	scale_fill_gradient2(low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=15)+ 
	# scale_fill_gradient2(low='darkgreen',high='red',mid='yellow', midpoint=10)+ 
	# geom_contour(data=shallow_avgs_1_allyr, aes(Lon,Lat,z=CPUE), colour="black", show.legend=FALSE) +
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-120), minor_breaks=seq(-180,-120,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude", caption="")
 ggsave(paste0(root_dir,"/Figures/1_Shallow_1deg_NoContour.png"),p, width=6.5, units="in")


# --------------
# Fig. 12. Nom. CPUE, Deep set, 1 deg. grid, aggregate over all years	
deep_avgs_1_allyr <- subset(CPUE_avgs_1_allyr, Set=='D')			#summary(deep_avgs_1_allyr)

plot_me <- deep_avgs_1_allyr
# summary(plot_me)		# look_here <- hist(plot_me$CPUE, breaks=150)

# try a very quick mod here. create a "plus group" for deep CPUE.		#head(plot_me)
plot_me$CPUE[plot_me$CPUE > 1] <- 1

 p <-  ggplot() +
	geom_raster(data = plot_me, aes(x = Lon, y = Lat, fill = CPUE))+
	scale_fill_gradient2(limits=c(0,1),breaks=seq(0,1,0.25), labels=c('0','0.25','0.5','0.75','>1'), low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=0.5)+ 
	# geom_contour(data=deep_avgs_1_allyr, aes(Lon,Lat,z=CPUE), colour="black", show.legend=FALSE) +
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-120), minor_breaks=seq(-180,-120,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude", caption="")
 ggsave(paste0(root_dir,"/Figures/NomCPUE_Deep_all_years_4Nov.png"),p, width=6.5, units="in")
	

# --------------
# Figs. 5 and 6. Nom. CPUE, shallow set, 5 deg. grid, by year	

# for shallow, do not plot 2001, 2002, 2003, 2004
plot_me <- subset(CPUE_avgs_5, Set=="S")
plot_me <- subset(plot_me, Year > 2004 | Year < 2001)
summary(plot_me)

plot_me_A <- subset(plot_me, Year <= 2010)
plot_me_B <- subset(plot_me, Year > 2010)

p <-  ggplot() +
	geom_tile(data = plot_me_A, aes(x = Lon, y = Lat, fill = CPUE))+
	scale_fill_gradient2(limits=c(0,27), low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=10)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-125), minor_breaks=seq(-180,-125,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude", caption="") +
  	facet_wrap(~Year, ncol=3)
 ggsave(paste0(root_dir,"/Figures/2_Shallow_5deg_by_year_1995_2010.png"),p, width=6.5, units="in")

p <-  ggplot() +
	geom_tile(data = plot_me_B, aes(x = Lon, y = Lat, fill = CPUE))+
	scale_fill_gradient2(limits=c(0,27),low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=10)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-125), minor_breaks=seq(-180,-125,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude", caption="") +
  	facet_wrap(~Year, ncol=3)
 ggsave(paste0(root_dir,"/Figures/2_Shallow_5deg_by_year_2011_2021.png"),p, width=6.5, units="in")



# --------------
# Figs. 13 and 14. Nom. CPUE, deep set, 5 deg. grid, by year	

plot_me <- subset(CPUE_avgs_5, Set=="D")
# summary(plot_me)		# look_here <- hist(plot_me$CPUE, breaks=150)

# View(subset(plot_me, CPUE > 1))

# try a very quick mod here. create a "plus group" for deep CPUE.		#head(plot_me)
plot_me$CPUE[plot_me$CPUE > 1] <- 1

plot_me_A <- subset(plot_me, Year <= 2009)
plot_me_B <- subset(plot_me, Year > 2009)

p <-  ggplot() +
	geom_tile(data = plot_me_A, aes(x = Lon, y = Lat, fill = CPUE))+
	scale_fill_gradient2(limits=c(0,1),breaks=seq(0,1,0.25), labels=c('0','0.25','0.5','0.75','>1'), low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=0.5)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-120), minor_breaks=seq(-180,-120,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude", caption="") +
  	facet_wrap(~Year, ncol=3)
 ggsave(paste0(root_dir,"/Figures/2_Deep_5deg_by_year_1995_2009_4Nov.png"),p, width=6.5, units="in")

p <-  ggplot() +
	geom_raster(data = plot_me_B, aes(x = Lon, y = Lat, fill = CPUE))+
	scale_fill_gradient2(limits=c(0,1),breaks=seq(0,1,0.25), labels=c('0','0.25','0.5','0.75','>1'),low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=0.5)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-120), minor_breaks=seq(-180,-120,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude", caption="") +
  	facet_wrap(~Year, ncol=3)
 ggsave(paste0(root_dir,"/Figures/2_Deep_5deg_by_year_2010_2021_4Nov.png"),p, width=6.5, units="in")


# --------------
# Figs. 2 and 3 Hooks set, shallow set, 5 deg. grid, by year

# for shallow, do not plot 2001, 2002, 2003, 2004
plot_me <- subset(hooks_set_5, Set=="S")
plot_me <- subset(plot_me, Year > 2004 | Year < 2001)
summary(plot_me)

plot_me_A <- subset(plot_me, Year <= 2010)
plot_me_B <- subset(plot_me, Year > 2010)

p <-  ggplot() +
	geom_tile(data = plot_me_A, aes(x = Lon, y = Lat, fill = thou_hooks))+
	scale_fill_gradient2(limits=c(0.5,650), low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=300)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-125), minor_breaks=seq(-180,-125,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude", fill="Thousand\nHooks", caption="") +
  	facet_wrap(~Year, ncol=3)
 ggsave(paste0(root_dir,"/Figures/3_Hooks_Shallow_5deg_by_year_1995_2010.png"),p, width=6.5, units="in")

p <-  ggplot() +
	geom_tile(data = plot_me_B, aes(x = Lon, y = Lat, fill = thou_hooks))+
	scale_fill_gradient2(limits=c(0.5,650),low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=300)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-125), minor_breaks=seq(-180,-125,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude",fill="Thousand\nHooks", caption="") +
  	facet_wrap(~Year, ncol=3)
 ggsave(paste0(root_dir,"/Figures/3_Hooks_5deg_by_year_2011_2021.png"),p, width=6.5, units="in")



# --------------
# Fig. 1 Hooks set, shallow set, 1 deg. grid, all years
plot_me <- subset(hooks_set_1_allyears, Set=="S")			#summary(plot_me)


 p <-  ggplot() +
	geom_raster(data = plot_me, aes(x = Lon, y = Lat, fill = thou_hooks))+
	scale_fill_gradient2(low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=200)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-120), minor_breaks=seq(-180,-120,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +
	labs(title="", subtitle="", y="Latitude", x="Longitude",fill="Thousand\nHooks", caption="")
 ggsave(paste0(root_dir,"/Figures/Fig1_update_28Nov_Hooks_shallow_1deg_allyears.png"),p, width=6.5, units="in")
	


# --------------
# Fig. 9 Hooks set, deep set, 1 deg. grid, all years

plot_me <- subset(hooks_set_1_allyears, Set=="D")			#summary(plot_me)


 p <-  ggplot() +
	geom_raster(data = plot_me, aes(x = Lon, y = Lat, fill = thou_hooks))+
	scale_fill_gradient2(low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=4500)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-120), minor_breaks=seq(-180,-120,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +
	labs(title="", subtitle="", y="Latitude", x="Longitude",fill="Thousand\nHooks", caption="")
 ggsave(paste0(root_dir,"/Figures/Fig9_update_28Nov_Hooks_deep_1deg_allyears.png"),p, width=6.5, units="in")
	


# --------------
# Figs. 10 and 11 Hooks set, deep set, 5 deg. grid, by year

plot_me <- subset(hooks_set_5, Set=="D")
summary(plot_me)

plot_me_A <- subset(plot_me, Year <= 2009)
plot_me_B <- subset(plot_me, Year > 2009)

p <-  ggplot() +
	geom_tile(data = plot_me_A, aes(x = Lon, y = Lat, fill = thou_hooks))+
	scale_fill_gradient2(limits=c(0.5,7000), low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=3000)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-125), minor_breaks=seq(-180,-125,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude", fill="Thousand\nHooks", caption="") +
  	facet_wrap(~Year, ncol=3)
 ggsave(paste0(root_dir,"/Figures/NHooks_Deep_by_year_1995_2009.png"),p, width=6.5, units="in")

p <-  ggplot() +
	geom_tile(data = plot_me_B, aes(x = Lon, y = Lat, fill = thou_hooks))+
	scale_fill_gradient2(limits=c(0.5,7000),low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=3000)+ 
 	geom_polygon(data=hawaii_df, aes(x = X, y = Y, group = L2), fill = "black", col= "black") +
  	scale_x_continuous(limits=c(-180,-125), minor_breaks=seq(-180,-125,5)) +
  	scale_y_continuous(limits = c(0,45), minor_breaks=seq(0,45,5)) +	
  	coord_fixed(1) +			
  	labs(title="", subtitle="", y="Latitude", x="Longitude",fill="Thousand\nHooks", caption="") +
  	facet_wrap(~Year, ncol=3)
 ggsave(paste0(root_dir,"/Figures/NHooks_Deep_by_year_2010_2021.png"),p, width=6.5, units="in")



#  ----------------------------------------------------------------------
#	sets and nominal CPUE per year x Yday, Moon, Hour, 
# 

# make a df to use for the x-axis when plotting yday
yday_axis <- data.frame('month'=c(seq(1,12,1),12), 'day' = c(rep(1,12),31), 'year' = rep(2021, 13),
		'label' = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', ''))
yday_axis$date <- as.Date(with(yday_axis,paste(year,month,day,sep="-")),"%Y-%m-%d")
yday_axis <- mutate(yday_axis, Yday = yday(date))


SWOShal_all <- rbind(SWOShala, SWOShalb)
summary(SWOShal_all$Year_fac)
SWOShal_all$Year_fac <- factor(SWOShal_all$Year_fac, levels = rev(levels(SWOShal_all$Year_fac)))


# ----  Shallow, N sets year vs. day of year
p <- ggplot(SWOShal_all, aes(x = Yday, y = Year_fac, height = stat(density))) + 
  theme_datareport_bar() +
  geom_density_ridges(stat = "binline", bins=90, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=yday_axis$Yday, labels = yday_axis$label) +
  labs(title="N Shallow Sets", subtitle="", y="", x="", caption="")
 
  ggsave(paste0(root_dir,"/Figures/NSets_Shallow_year_day.png"),p, width=6.5, units="in")

# ----  Shallow, N sets year vs. Hour
p <- ggplot(SWOShal_all, aes(x = Hour, y = Year_fac, height = stat(density))) + 
  theme_datareport_bar() +  
  geom_density_ridges(stat = "binline", bins=24, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=c(-0.5,5.75, 12, 18.25, 24.5), labels=c("midnight","0600","noon","1800","midnight") ) +
  labs(title="N Shallow Sets", subtitle="", y="", x="", caption="")

  ggsave(paste0(root_dir,"/Figures/NSets_Shallow_year_hour.png"),p, width=6.5, units="in")

# ----  Shallow, N sets year vs. Moon phase
p <- ggplot(SWOShal_all, aes(x = Moon, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=c(-0.025,0.2375, 0.5, 0.7625, 1.025), labels=c("new","first quarter","full","last quarter","new") ) +
  labs(title="N Shallow Sets", subtitle="", y="", x="", caption="")

  ggsave(paste0(root_dir,"/Figures/NSets_Shallow_year_moon.png"),p, width=6.5, units="in")


# ----  Shallow, N sets year vs. Lat		# summary(SWOShal_all$Lat)
p <- ggplot(SWOShal_all, aes(x = Lat, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=seq(0,50,10) ) +
  labs(title="N Shallow Sets", subtitle="", y="", x="Latitude (deg N)", caption="")

  ggsave(paste0(root_dir,"/Figures/NSets_Shallow_Lat.png"),p, width=6.5, units="in")


# ----  Shallow, N sets year vs. Lon		# summary(SWOShal_all$Lon)
p <- ggplot(SWOShal_all, aes(x = Lon, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=seq(-180,-120,10) ) +
  labs(title="N Shallow Sets", subtitle="", y="", x="Longitude (deg E)", caption="")

  ggsave(paste0(root_dir,"/Figures/NSets_Shallow_Lon.png"),p, width=6.5, units="in")



# ----  Shallow, N sets year vs. HPF		# summary(SWOShal_all$HPF_fac)
p <- ggplot(subset(SWOShal_all, HPF < 13), aes(x = HPF, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=11, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=seq(1,12,1) ) +
  labs(title="N Shallow Sets", subtitle="", y="", x="HPF", caption="")

  ggsave(paste0(root_dir,"/Figures/NSets_Shallow_HPF.png"),p, width=6.5, units="in")



# ----  Shallow, N sets year vs. Lightsticks_YN		# summary(SWOShal_all$LPH)		#head(SWOShal_all)		#nrow(SWOShal_all)

	string <- "SELECT Year_fac, Lightsticks_YN, count(Permit) as Nsets 
				FROM SWOShal_all
				GROUP BY Year_fac, Lightsticks_YN
				"
  	Lightsticks_year_shallow <- sqldf(string, stringsAsFactors=FALSE)			#summary(SWOShal_all_new_2)


	string <- "SELECT Year_fac, count(Permit) as Total_sets 
				FROM SWOShal_all
				GROUP BY Year_fac
				
				"
  	count_sets <- sqldf(string, stringsAsFactors=FALSE)			#summary(SWOShal_all_new_2)


	LS_2 <- merge(Lightsticks_year_shallow, count_sets, all.x = TRUE)

	LS_2 <- mutate(LS_2, prop_YN = Nsets/Total_sets)		
	names(LS_2)[2] <- 'Lightsticks'

p <- ggplot(LS_2, aes(x = Year_fac, y = prop_YN, fill=Lightsticks)) + 
  geom_bar(position="stack",stat="identity",color="black") +
  theme_datareport_bar() + 
  coord_flip() +
  scale_fill_manual(values=c('gray','white')) +
  labs(title="Proportion Shallow Sets", subtitle="", x="", y="", caption="") +
  theme(legend.position = "bottom")

  ggsave(paste0(root_dir,"/Figures/8C_propSets_Shallow_Lightsticks.png"),p, width=6, units="in")



# ----  Shallow, N sets year vs. LPH		# summary(SWOShal_all$LPH)
p <- ggplot(subset(SWOShal_all, LPH < 2), aes(x = LPH, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=seq(0,2,0.25) ) +
  labs(title="N Shallow Sets", subtitle="", y="", x="LPH", caption="")

  ggsave(paste0(root_dir,"/Figures/8D_NSets_Shallow_LPH.png"),p, width=6.5, units="in")






# ----  Shallow, N sets year vs. Permit		length(unique(SWOShal_all$Permit))			#head(SWOShal_all)
# assign number to each vessel

	string <- "SELECT Permit, min(Year) as first_year
				FROM (
				SELECT DISTINCT Permit, Year
					FROM SWOShal_all)
			GROUP BY Permit
				"

  	permits_shall <- sqldf(string, stringsAsFactors=FALSE)	

	# put in order
	permits_shall <- permits_shall[order(permits_shall$first_year),]
	permits_shall <- mutate(permits_shall, permit_num = seq(1,114,1))

  SWOShal_all_new <- merge(SWOShal_all, permits_shall, all.x = TRUE)	#head(SWOShal_all_new)

	string <- "SELECT DISTINCT permit_num, Year_fac, count(permit_num) as Nsets 
				FROM SWOShal_all_new
				GROUP BY Year_fac, permit_num
				
				"
  	SWOShal_all_new_2 <- sqldf(string, stringsAsFactors=FALSE)			#summary(SWOShal_all_new_2)


p <- ggplot(SWOShal_all_new_2, aes(permit_num, Year_fac)) + 
			 theme_datareport_bar() + 
			geom_tile(aes(fill = Nsets), colour = "black", size=0.3) + 
			scale_fill_gradient2(low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=75) +
 			theme(axis.text.x = element_blank()) +
  			theme(legend.position = "right") +
  			labs(title="N Shallow Sets", subtitle="", y="", x="Vessels", caption="")


  png(paste0(root_dir,"/Figures/NSets_Shallow_year_vessel.png"),width=6.5, height = 8, units = "in", res=600)
	p
  dev.off()







# ---- DEEP Sets

SWODeep$Year_fac <- factor(SWODeep$Year_fac, levels = rev(levels(SWODeep$Year_fac)))


# ----  Deep, N sets year vs. day of year
p <- ggplot(SWODeep, aes(x = Yday, y = Year_fac, height = stat(density))) + 
  theme_datareport_bar() +
  geom_density_ridges(stat = "binline", bins=90, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=yday_axis$Yday, labels = yday_axis$label) +
  labs(title="N Deep Sets", subtitle="", y="", x="Time of Year", caption="")
 
  ggsave(paste0(root_dir,"/Figures/Fig20_NSets_Deep_year_day.png"),p, width=6.5, height =7.5, units="in")

  ggsave(paste0(root_dir,"/Figures/Fig20_small_NSets_Deep_year_day.png"),p, width=3.15, height =7.5, units="in")

# ----  Deep positive only, N sets year vs. day of year
p <- ggplot(subset(SWODeep, z==1), aes(x = Yday, y = Year_fac, height = stat(density))) + 
  theme_datareport_bar() +
  geom_density_ridges(stat = "binline", bins=90, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=yday_axis$Yday, labels = yday_axis$label) +
  labs(title="N Deep Sets Catching Swordfish", subtitle="", y="", x="", caption="")
 
  ggsave(paste0(root_dir,"/Figures/NSets_Deep_POS_ONLY_year_day_Oct12.png"),p, width=6.5, height =7.5, units="in")


# ----  Deep, N sets year vs. Hour
p <- ggplot(SWODeep, aes(x = Hour, y = Year_fac, height = stat(density))) + 
  theme_datareport_bar() +  
  geom_density_ridges(stat = "binline", bins=24, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=c(-0.5,5.75, 12, 18.25, 24.5), labels=c("midnight","0600","noon","1800","midnight") ) +
  labs(title="N Deep Sets", subtitle="", y="", x="Time of Day", caption="")

  ggsave(paste0(root_dir,"/Figures/Fig21_NSets_Deep_year_hour.png"),p, width=6.5, height =7.5, units="in")


# ----  Deep, N sets year vs. Hour POSITIVE ONLY
p <- ggplot(subset(SWODeep, z==1), aes(x = Hour, y = Year_fac, height = stat(density))) + 
  theme_datareport_bar() +  
  geom_density_ridges(stat = "binline", bins=24, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=c(-0.5,5.75, 12, 18.25, 24.5), labels=c("midnight","0600","noon","1800","midnight") ) +
  labs(title="N Deep Sets Catching Swordfish", subtitle="", y="", x="", caption="")

  ggsave(paste0(root_dir,"/Figures/NSets_Deep_POS_ONLY_year_hour_Oct12.png"),p, width=6.5, height =7.5, units="in")


# ----  Deep, N sets year vs. Moon phase
p <- ggplot(SWODeep, aes(x = Moon, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=c(-0.025,0.2375, 0.5, 0.7625, 1.025), labels=c("new","first quarter","full","last quarter","new") ) +
  labs(title="N Deep Sets", subtitle="", y="", x="Moon Phase", caption="")

  ggsave(paste0(root_dir,"/Figures/NSets_Deep_year_moon_Oct20.png"),p, width=6.5, height =7.5, units="in")

# ----  Deep, N sets POSITIVE ONLY year vs. Moon phase
p <- ggplot(subset(SWODeep, z==1), aes(x = Moon, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=c(-0.025,0.2375, 0.5, 0.7625, 1.025), labels=c("new","first quarter","full","last quarter","new") ) +
  labs(title="N Deep Sets Catching Swordfish", subtitle="", y="", x="", caption="")

  ggsave(paste0(root_dir,"/Figures/NSets_Deep_POS_ONLY_year_moon_Oct12.png"),p, width=6.5, height =7.5, units="in")


# ----  Deep, N sets year vs. HPF
# summary(SWODeep$HPF)			#77/5  # summary(as.factor(SWODeep$HPF))	
# names(SWODeep)
p <- ggplot(SWODeep, aes(x = HPF, y = Year_fac, height = stat(density))) + 
  theme_datareport_bar() +  
  geom_density_ridges(stat = "binline", bins = 16, scale = 1, draw_baseline = FALSE) +
 scale_x_continuous(breaks=seq(9,90,5), labels = c('10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90')) +
  labs(title="N Deep Sets", subtitle="", y="", x="Hooks per Float", caption="")

  ggsave(paste0(root_dir,"/Figures/Fig25_NSets_Deep_year_HPF_update.png"),p, width=6.5, height =7.5, units="in")


p <- ggplot(subset(SWODeep, HPF < 21), aes(x = HPF, y = Year_fac, height = stat(density))) + 
  theme_datareport_bar() +  
  geom_density_ridges(stat = "binline", bins = 10, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=seq(0,21,1) ) +
  labs(title="N Deep Sets (HPF < 21)", subtitle="", y="", x="", caption="")

  ggsave(paste0(root_dir,"/Figures/NSets_Deep_year_HPF_10_20_Oct12.png"),p, width=6.5, height =7.5, units="in")

# how many deep sets are there pre-2005 that were 10-13 hooks per float?
nrow(subset(SWODeep, HPF < 14 & Year < 2005))		# 0


# ----  Deep, N sets year vs. Lat		# summary(SWODeep$Lat)
p <- ggplot(SWODeep, aes(x = Lat, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=seq(0,45,5) ) +
  labs(title="N Deep Sets", subtitle="", y="", x="Latitude (deg N)", caption="")

  ggsave(paste0(root_dir,"/Figures/Fig22_NSets_Deep_Lat.png"),p, width=6.5, units="in")



# ----  Deep, N sets year vs. SST		# summary(SWODeep$SST)
p <- ggplot(SWODeep, aes(x = SST, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=seq(20,30,2) ) +
  labs(title="N Deep Sets", subtitle="", y="", x="SST (deg C)", caption="")

  ggsave(paste0(root_dir,"/Figures/Fig23_NSets_Deep_SST.png"),p, width=6.5, units="in")



# ----  Deep, N sets year vs. Bait		# summary(SWODeep$Bait_fac)

      string <- "SELECT DISTINCT Bait_fac, Year_fac, count(Bait_fac) as Nsets 
				FROM SWODeep
				GROUP BY Year_fac, Bait_fac
				
				"
  	SWODeep_new <- sqldf(string, stringsAsFactors=FALSE)			#summary(SWODeep_new$Nsets)


  p <- ggplot(SWODeep_new, aes(Bait_fac, Year_fac)) + 
			 theme_datareport_bar() + 
			geom_tile(aes(fill = Nsets), colour = "black", size=0.3) + 
			scale_fill_gradient2(low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=15000) +
 			theme(axis.text.x = element_text(angle=60,hjust=1,vjust=0.9)) +
  			theme(legend.position = "right") +
  			labs(title="N Deep Sets", subtitle="", y="", x="Bait", caption="")


  png(paste0(root_dir,"/Figures/Fig23_NSets_Deep_year_bait.png"),width=6.5, height = 8, units = "in", res=600)
	p
  dev.off()


# ----  Deep, N sets year vs. LPH		# summary(SWODeep$LPH)


p <- ggplot(SWODeep, aes(x = LPH, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
  theme_datareport_bar() + 
  scale_x_continuous(breaks=seq(0,1,0.05) ) +
  labs(title="N Shallow Sets", subtitle="", y="", x="LPH", caption="")

  ggsave(paste0(root_dir,"/Figures/8D_NSets_Shallow_LPH.png"),p, width=6.5, units="in")







# ----  Deep, N sets year vs. Permit		length(unique(SWOShal_all$Permit))			#head(SWOShal_all)
# assign number to each vessel

	string <- "SELECT Permit, min(Year) as first_year
				FROM (
				SELECT DISTINCT Permit, Year
					FROM SWODeep)
			GROUP BY Permit
				"

  	permits_deep <- sqldf(string, stringsAsFactors=FALSE)	

	# put in order
	permits_deep <- permits_deep[order(permits_deep$first_year),]			#str(permits_deep)
	permits_deep <- mutate(permits_deep , permit_num = seq(1,224,1))

  SWODeep_all_new <- merge(SWODeep, permits_deep, all.x = TRUE)	#head(SWODeep_all_new)

	string <- "SELECT DISTINCT permit_num, Year_fac, count(permit_num) as Nsets 
				FROM SWODeep_all_new
				GROUP BY Year_fac, permit_num
				
				"
  	SWODeep_all_new_2 <- sqldf(string, stringsAsFactors=FALSE)			#summary(SWODeep_all_new_2)

SWODeep_all_new_2$Year_fac <- factor(SWODeep_all_new_2$Year_fac, levels = rev(levels(SWODeep_all_new_2$Year_fac)))


p <- ggplot(SWODeep_all_new_2, aes(permit_num, Year_fac)) + 
			 theme_datareport_bar() + 
			geom_tile(aes(fill = Nsets), colour = "black", size=0) + 
			scale_fill_gradient2(low='#bddee0',high='#00474d', mid='#00b0bd', midpoint=100) +
 			theme(axis.text.x = element_blank()) +
  			theme(legend.position = c(0.9,0.9)) +
  			labs(title="N Deep Sets", subtitle="", y="", x="Vessels", caption="")


  png(paste0(root_dir,"/Figures/NSets_Deep_year_vessel.png"),width=6.5, height = 8, units = "in", res=600)
	p
  dev.off()









# -------------------------------------
# -------------------------------------
# -------------------------------------
##  line plots of NOMINAL and STANDARDIZED by year, with +/- 1.96 SE
##	see end for code that does multipane year by month


	yday_key <- yday_axis[c(1:12),c(1,6)]
	names(yday_key)[1] <- "Month"	


## prepare datasets
  # shallow, nominal vs. modeled CPUE, by year
  # EARLY STANDARDIZED   head(Shallow_A_Delta_Year)
	stan_early <- data.frame(Year = as.numeric(as.character(Shallow_A_Delta_Year$year)),
			CPUE = Shallow_A_Delta_Year$delta_fit,
			SE = Shallow_A_Delta_Year$delta_se,
			Type = "standardized")

  # LATE	STANDARDIZED
	stan_late <- data.frame(Year = as.numeric(as.character(Shallow_B_Predict_Year$year)),
			CPUE = Shallow_B_Predict_Year$pos_correct,
			SE = Shallow_B_Predict_Year$pos_se_correct,
			Type = "standardized")


	# if we want to show CIs, we need to transform CPUE and SE back to the log scales first
	MSE_early <- summary(Shallow_A_LnN$gam)$dispersion
	MSE_late <- summary(Shallow_B_LnN$gam)$dispersion

	stan_early <- mutate(stan_early, CPUE_raw = log(CPUE)-(MSE_early/2))
	stan_early <- mutate(stan_early, SE_raw = SE/exp(CPUE_raw))
	stan_early <- mutate(stan_early, UCI_raw = CPUE_raw + 1.96*SE_raw, LCI_raw = CPUE_raw - 1.96*SE_raw)
	stan_early <- mutate(stan_early, UCI_correct = exp(UCI_raw+MSE_early/2), LCI_correct = exp(LCI_raw+MSE_early/2))

	stan_late <- mutate(stan_late, CPUE_raw = log(CPUE)-(MSE_late/2))
	stan_late <- mutate(stan_late, SE_raw = SE/exp(CPUE_raw))
	stan_late <- mutate(stan_late, UCI_raw = CPUE_raw + 1.96*SE_raw, LCI_raw = CPUE_raw - 1.96*SE_raw)
	stan_late <- mutate(stan_late, UCI_correct = exp(UCI_raw+MSE_late/2), LCI_correct = exp(LCI_raw+MSE_late/2))

      stan <- rbind(stan_early, stan_late)

  # NOMINAL
	shallow_all <- rbind(SWOShala, SWOShalb)
	nominal_avg <- aggregate(shallow_all$CPUE,by=list(shallow_all$Year), mean)
	names(nominal_avg) <- c("Year","CPUE")
	nominal_sd <- aggregate(shallow_all$CPUE,by=list(shallow_all$Year), sd)		# str(SWOShalb)
	names(nominal_sd) <- c("Year","SD")
	nominal_nobs <- dplyr::count(shallow_all,Year)

	temp1 <- merge(nominal_avg, nominal_sd, by = c("Year"))
	temp2 <- merge(temp1, nominal_nobs, by = c("Year"))
	temp3 <- mutate(temp2, SE = SD/sqrt(n))
	temp4 <- temp3[,c(1,2,5)]
	exp_nom <- expand.grid(Year = c(seq(1995,2000,1), seq(2005,2021,1)))	
	temp5 <- merge(exp_nom, temp4, by = c("Year"), all.x = TRUE)
	temp5[is.na(temp5)] <- 0
	temp5$Type <- "nominal"

	nom <- mutate(temp5, CPUE_raw = CPUE, SE_raw = SE, 
					UCI_raw = CPUE + 1.96*SE,
					LCI_raw = CPUE - 1.96*SE, 
					UCI_correct = CPUE + 1.96*SE,
					LCI_correct = CPUE - 1.96*SE)

	shallow <- rbind(stan, nom)

	# if we want to easily graph the shallow without connecting them, fill in the missing years with NAs

	shallow_missing <- expand.grid(Year = seq(2001, 2004, 1))		# str(shallow_missing)
	shallow_missing <- mutate(shallow_missing,
		CPUE = as.numeric(NA), SE = as.numeric(NA), Type = "standardized",  
		CPUE_raw = as.numeric(NA), SE_raw = as.numeric(NA), UCI_raw = as.numeric(NA), 
		LCI_raw = as.numeric(NA), UCI_correct = as.numeric(NA), LCI_correct = as.numeric(NA))
#	attributes(shallow_missing) <- NULL

	shallow_missing_2 <- shallow_missing
	shallow_missing_2$Type = "nominal"
	shallow_missing <- rbind(shallow_missing, shallow_missing_2)

  shallow <- rbind(shallow, shallow_missing)

## FIGURES				# str(shallow)


p <- ggplot(data = shallow, aes(x = Year, y = CPUE, group = Type, color = Type, shape = Type)) +
  geom_line() +
  theme_datareport_bar() +
  scale_fill_manual(values=c("red","blue")) +
  scale_color_manual(values=c("red","blue")) +
  geom_point(size=2) +
  geom_ribbon(aes(ymin = LCI_correct, ymax = UCI_correct, fill = Type), linetype = 0, alpha = 0.2) +
  theme(legend.position = c(.85, .9)) +
  theme(legend.title=element_blank()) +
  labs(title="Shallow Set", subtitle="", y="CPUE (catch per thousand hooks)", x="Year", caption="")

  ggsave(paste0(root_dir,"/Figures/Shallow_CPUE_year_19Oct.png"),p, width=6.5, units="in")

  # ignore warning, it's the missing years



#  a cleaner looking figure with just points for nominal
p <- ggplot() +
  # geom_line(data = subset(shallow, Type == 'nominal'), aes(x = Year, y = CPUE), linetype = "longdash", color = "black") +
  geom_point(data = subset(shallow, Type == 'nominal'), aes(x = Year, y = CPUE), color = "black", shape = 1, size = 2) +
  geom_line(data = subset(shallow, Type == 'standardized'), aes(x = Year, y = CPUE), linetype = "solid", color = "blue") +
  geom_point(data = subset(shallow, Type == 'standardized'), aes(x = Year, y = CPUE), color = "blue", shape = 17, size = 2.5) +
  geom_ribbon(data = subset(shallow, Type == 'standardized'), aes(x = Year, y = CPUE, ymin = LCI_correct, ymax = UCI_correct), fill="blue", linetype = 0, alpha = 0.2) +
  theme_datareport_bar() +
  scale_y_continuous(limits=c(5,20)) +
  labs(title="Shallow-Set", subtitle="", y="CPUE (catch per thousand hooks)", x="Year", caption="")

  ggsave(paste0(root_dir,"/Figures/Fig27_Shallow_CPUE_year_simpler_05Dec.png"),p, width=6.5, units="in")




  # Deep, nominal vs. modeled CPUE, by year
  # Deep_Delta_Year
	stan <- data.frame(Year = as.numeric(as.character(Deep_Delta_Year$year)),
			CPUE = Deep_Delta_Year$delta_fit,
			SE = Deep_Delta_Year$delta_se,
			Type = "standardized")

	# if we want to show CIs, we need to transform CPUE and SE back to the log scales first
	MSE <- summary(Deep_LnN$gam)$dispersion

	stan <- mutate(stan, CPUE_raw = log(CPUE)-(MSE/2))
	stan <- mutate(stan, SE_raw = SE/exp(CPUE_raw))
	stan <- mutate(stan, UCI_raw = CPUE_raw + 1.96*SE_raw, LCI_raw = CPUE_raw - 1.96*SE_raw)
	stan <- mutate(stan, UCI_correct = exp(UCI_raw+MSE/2), LCI_correct = exp(LCI_raw+MSE/2))


  # NOMINAL
	nominal_avg <- aggregate(SWODeep$CPUE,by=list(SWODeep$Year), mean)
	names(nominal_avg) <- c("Year","CPUE")
	nominal_sd <- aggregate(SWODeep$CPUE,by=list(SWODeep$Year), sd)		# str(SWOShalb)
	names(nominal_sd) <- c("Year","SD")
	nominal_nobs <- dplyr::count(SWODeep,Year)

	temp1 <- merge(nominal_avg, nominal_sd, by = c("Year"))
	temp2 <- merge(temp1, nominal_nobs, by = c("Year"))
	temp3 <- mutate(temp2, SE = SD/sqrt(n))
	temp4 <- temp3[,c(1,2,5)]
	exp_nom <- expand.grid(Year = seq(1995,2021,1))	
	temp5 <- merge(exp_nom, temp4, by = c("Year"), all.x = TRUE)
	temp5[is.na(temp5)] <- 0
	temp5$Type <- "nominal"

	nom <- mutate(temp5, CPUE_raw = CPUE, SE_raw = SE, 
					UCI_raw = CPUE + 1.96*SE,
					LCI_raw = CPUE - 1.96*SE, 
					UCI_correct = CPUE + 1.96*SE,
					LCI_correct = CPUE - 1.96*SE)

	deep <- rbind(stan, nom)


p <- ggplot(data = deep, aes(x = Year, y = CPUE, group = Type, color = Type, shape = Type)) +
  geom_line() +
  theme_datareport_bar() +
  scale_fill_manual(values=c("red","blue")) +
  scale_color_manual(values=c("red","blue")) +
  geom_point(size=2) +
  geom_ribbon(aes(ymin = LCI_correct, ymax = UCI_correct, fill = Type), linetype = 0, alpha = 0.2) +
  theme(legend.position = c(.85, .9)) +
  theme(legend.title=element_blank()) +
  labs(title="Deep Set", subtitle="", y="CPUE (catch per thousand hooks)", x="Year", caption="")

  ggsave(paste0(root_dir,"/Figures/Deep_CPUE_year_19Oct.png"),p, width=6.5, units="in")




#  a cleaner looking figure with just points for nominal
p <- ggplot() +
  # geom_line(data = subset(deep, Type == 'nominal'), aes(x = Year, y = CPUE), linetype = "longdash", color = "black") +
  geom_point(data = subset(deep, Type == 'nominal'), aes(x = Year, y = CPUE), color = "black", shape = 1, size = 2) +
  geom_line(data = subset(deep, Type == 'standardized'), aes(x = Year, y = CPUE), linetype = "solid", color = "blue") +
   geom_point(data = subset(deep, Type == 'standardized'), aes(x = Year, y = CPUE), color = "blue", shape = 17, size = 2.5) +
  geom_ribbon(data = subset(deep, Type == 'standardized'), aes(x = Year, y = CPUE, ymin = LCI_correct, ymax = UCI_correct), fill="blue", linetype = 0, alpha = 0.2) +
  theme_datareport_bar() +
  labs(title="Deep Set", subtitle="", y="CPUE (catch per thousand hooks)", x="Year", caption="")

  ggsave(paste0(root_dir,"/Figures/Fig28_Deep_CPUE_year_simpler_05Dec.png"),p, width=6.5, units="in")


# -------------------------------------
# -------------------------------------
# -------------------------------------
#   figures to show 2018 CPUE vs. this update
# -------------------------------------


old <- read.csv(paste0(root_dir, '/CPUE_2018.csv'), header = TRUE)
str(old)
old$dataset <- as.character(old$dataset)

zeroed_a <- old$CPUE[1:6]-mean(old$CPUE[1:6])
zeroed_b <- old$CPUE[11:22]-mean(old$CPUE[11:22])
zeroed_na <- rep(NA, 4)
zeroed_deep <- old$CPUE[23:44]-mean(old$CPUE[23:44])

CPUE_0_old <- c(zeroed_a, zeroed_na, zeroed_b, zeroed_deep)
old$CPUE_0 <- CPUE_0_old


new_a <- data.frame(Year = Shallow_A_Delta_Year$year, CPUE = Shallow_A_Delta_Year$pos_correct, 
			Sector = 'shallow', dataset = 'new', 
			CPUE_0 = Shallow_A_Delta_Year$pos_correct - mean(Shallow_A_Delta_Year$pos_correct))		#str(new_a)

mean_zero_late <- mean(subset(Shallow_B_Predict_Year, year < 2017)$pos_correct)

new_b <- data.frame(Year = Shallow_B_Predict_Year$year, CPUE = Shallow_B_Predict_Year$pos_correct, 
			Sector = 'shallow', dataset = 'new',
			CPUE_0 = Shallow_B_Predict_Year$pos_correct - mean_zero_late)		#

new_na <- data.frame(Year = seq(2001,2004,1), CPUE = NA, 
			Sector = 'shallow', dataset = 'new', CPUE_0 = NA)


mean_zero_deep <- mean(subset(Deep_Delta_Year, year < 2017)$delta_fit)

new_deep <- data.frame(Year = Deep_Delta_Year$year, CPUE = Deep_Delta_Year$delta_fit, 
			Sector = 'deep', dataset = 'new', 
			CPUE_0 = Deep_Delta_Year$delta_fit - mean_zero_deep)		#str(new_a)


new <- rbind(new_a, new_b, new_na)
new <- new[order(new$Year),]

new <- rbind(new, new_deep)
str(new)

compare <- rbind(old, new)
str(compare)

compare$dataset <- factor(compare$dataset, levels =
		c("new","2018"))   


p <- ggplot(data = subset(compare, Sector == "shallow"), aes(x = Year, y = CPUE, group = dataset, color = dataset, shape = dataset)) +
  geom_line(aes(linetype=dataset)) +
  theme_datareport_bar() +
  scale_fill_manual(values=c("blue", "black")) +
  scale_color_manual(values=c("blue", "black")) +
  scale_linetype_manual(values=c("solid", "dashed"))+
  scale_shape_manual(values=c(17,16)) +
  geom_point(size=2) +
  theme(legend.position = c(.85, .9)) +
  theme(legend.title=element_blank()) +
  labs(title="Shallow-Set", subtitle="", y="CPUE (catch per thousand hooks)", x="Year", caption="")

  ggsave(paste0(root_dir,"/Figures/Compare_shallow_raw_06Dec.png"),p, width=6.5, height = 3, units="in")


p <- ggplot(data = subset(compare, Sector == "shallow"), aes(x = Year, y = CPUE_0, group = dataset, color = dataset, shape = dataset)) +
  geom_line(aes(linetype=dataset)) +
  theme_datareport_bar() +
  scale_fill_manual(values=c("blue", "black")) +
  scale_color_manual(values=c("blue", "black")) +
  scale_linetype_manual(values=c("solid", "dashed"))+
  scale_shape_manual(values=c(17,16)) +
  geom_point(size=2) +
  theme(legend.position = c(.85, .9)) +
  theme(legend.title=element_blank()) +
  labs(title="Shallow-Set", subtitle="", y="Zero-Centered Index", x="Year", caption="")

  ggsave(paste0(root_dir,"/Figures/Compare_shallow_zeroed_06Dec.png"),p, width=6.5, height = 3, units="in")


p <- ggplot(data = subset(compare, Sector == "deep"), aes(x = Year, y = CPUE, group = dataset, color = dataset, shape = dataset)) +
  geom_line(aes(linetype=dataset)) +
  theme_datareport_bar() +
  scale_fill_manual(values=c("blue", "black")) +
  scale_color_manual(values=c("blue", "black")) +
  scale_linetype_manual(values=c("solid", "dashed"))+
  scale_shape_manual(values=c(17,16)) +
  geom_point(size=2) +
  theme(legend.position = c(.85, .9)) +
  theme(legend.title=element_blank()) +
  labs(title="Deep-Set", subtitle="", y="CPUE (catch per thousand hooks)", x="Year", caption="")

  ggsave(paste0(root_dir,"/Figures/Compare_deep_raw_06Dec.png"),p, width=6.5, height = 3, units="in")

p <- ggplot(data = subset(compare, Sector == "deep"), aes(x = Year, y = CPUE_0, group = dataset, color = dataset, shape = dataset)) +
  geom_line(aes(linetype=dataset)) +
  theme_datareport_bar() +
  scale_fill_manual(values=c("blue", "black")) +
  scale_color_manual(values=c("blue", "black")) +
  scale_linetype_manual(values=c("solid", "dashed"))+
  scale_shape_manual(values=c(17,16)) +
  geom_point(size=2) +
  theme(legend.position = c(.85, .9)) +
  theme(legend.title=element_blank()) +
  labs(title="Deep-Set", subtitle="", y="Zero-Centered Index", x="Year", caption="")

  ggsave(paste0(root_dir,"/Figures/Compare_deep_zeroed_06Dec.png"),p, width=6.5, height = 3, units="in")






# -------------------------------------
# -------------------------------------
# -------------------------------------
#  Describe the Models
# -------------------------------------


# -------------------------------------
# Shallow B GAMM LnN					# summary(model_object$mer)			# summary(model_object$gam)
# model_object <- Shallow_B_LnN					# formula(model_object$gam)	

# log(CPUE) ~ Year_fac + s(Permit_fac, bs = "re") + s(Moon, 
#    bs = "cc") + s(Yday, bs = "cc") + SST + s(Lon) + 
#    s(Lat) + LPH

# diagnostics of the fit
# use the modified gam.check function which includes blue lines upon Jon's request

png(file=paste0(root_dir,"/Figures/ShallowB_LnN_Diagnostics_02Dec.png"),width=6.5, height=6.5, units = "in", pointsize = 8, res=300)
	gam.check.addlines(model_object$gam)
  dev.off()


#  marginal effects from smooth terms, with rug
# plot(model_object$gam,pages=1, rug = TRUE)
# plot(model_object$gam, rug = FALSE)


# --- Marginal effects using ggeffects package ---

  model_object_gam <- model_object$gam

  # make sure we have the yday vs. month (for leap year)
  yday_axis_leap <- data.frame('Yday' = c(1,32,61,92,122,153,183,214,245,284,306,336,366),
					'label' = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''))

  yday_axis_sparse <- data.frame('Yday' = c(1,61,122,183,245,306,366),
						'label' = c('Jan','Mar','May','Jul','Sep','Nov',''))


# --- SST
  try_effects <- ggpredict(model_object_gam, "SST", back.transform = TRUE)
 # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
  p_SST <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="SST (deg C)", caption="")


# --- Moon Phase
   try_effects <- ggpredict(model_object_gam, "Moon", back.transform = TRUE)
   # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

   # ggplot w/ ribbon
   p_Moon <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
	scale_x_continuous(breaks=seq(0,1,0.25), labels=c("new","first quarter","full","last quarter","new") ) +
  	labs(title="", subtitle="", y="CPUE", x="Moon Phase", caption="")


# --- YDay
   try_effects <- ggpredict(model_object_gam, "Yday", back.transform = TRUE)
   # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

   # ggplot w/ ribbon
   p_yday <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
  	scale_x_continuous(breaks=yday_axis_sparse$Yday, labels = yday_axis_sparse$label) +
  	labs(title="", subtitle="", y="CPUE", x="Time of Year", caption="")


# --- Lat
    try_effects <- ggpredict(model_object_gam, terms = "Lat", back.transform = TRUE)

	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
    p_lat <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Latitude (deg N)", caption="")

# --- Lon
    try_effects <- ggpredict(model_object_gam, "Lon", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
    p_lon <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Longitude (deg E)", caption="")


# --- Year_fac
    try_effects <- ggpredict(model_object_gam, "Year_fac", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

    # points with CIs for factor vars
    p_year <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
	scale_x_discrete(breaks=seq(1995,2020,5)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Year", caption="")


# --- permit
    try_effects <- ggpredict(model_object_gam, "Permit_fac", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
    # str(try_effects)		# str(try_effects_year)

	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, 
			y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)					# str(marg_df)

	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- mean(marg_df$y)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)
	# in this instance, we expect permit to be Normal-ish, so easiest to visualize by sorting
	marg_df <- marg_df[order(marg_df$y_centered),]
	marg_df <- mutate(marg_df, new_x = seq(1,nrow(marg_df),1))

  p_vessel <- ggplot() +
  	geom_point(data = marg_df, aes(x = new_x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = new_x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
	scale_x_continuous(breaks=seq(0,nrow(marg_df),10), labels=NULL) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Permit", caption="")


# --- LPH
  try_effects <- ggpredict(model_object_gam, "LPH", back.transform = TRUE)		#hist(SWOShalb_pos$LPH)
 # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves			#plot(marg_df$x, marg_df$y)
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- subset(marg_df, x <= 1)

	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon		# head(marg_df)		#hist(SWOShalb_pos$LPH, breaks=seq(0,5,0.1))
  p_LPH <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
#	scale_x_continuous(breaks=seq(0,2,0.5)) +
  	labs(title="", subtitle="", y="CPUE", x="LPH", caption="")





#  output figure

  png(file=paste0(root_dir,"/Figures/ShallowB_LnN_Marginal_Effects_06Dec.png"),width=6.5, height=8, units = "in", pointsize = 8, res=300)
	grid.arrange(p_year,p_vessel, p_Moon, p_yday,p_SST,  p_lon, p_lat,p_LPH ,
		ncol=2)
  dev.off()




# -------------------------------------
#	INFLUENCE PLOTS		
# formula(model_object_gam)	
# Year_fac + s(Permit_fac, bs = "re") + s(Moon, bs = "cc") + s(Yday, bs = "cc") + SST + s(Lon) + s(Lat) + LPH

model_object <- Shallow_B_LnN
model_object_gam <- model_object$gam

# put together the predictions for each term and the observed data
#	type = terms calculates the value of each term in each predicted
pred_gam <- data.frame(pred_gam_terms = predict(model_object_gam, type="terms"), 	
		pred_gam_response = predict(model_object_gam, type="response"))

# summary(pred_gam)
pred_gam <- pred_gam[,-1]			#head(pred_gam)

# simplify, make names sql friendly
names(pred_gam)[] <- c("SST_effect", "LPH_effect", "Permit_effect","Moon_effect", "Yday_effect",
				"Lon_effect","Lat_effect", "pred_gam_response")

obs_in <- data.frame(Year_fac = model_object_gam$model[,2])			#	head(model_object_gam$model[,2])
obs_pred <- cbind(obs_in, pred_gam)							#head(obs_pred)		#str(obs_pred)

# I previously used sql code and 
#	only used unique values for each level of categorical variable per year, which seemed weird
#	for lightsticks_YN because there were only 2 levels, and each level appeared in every year
#	  but, but using the weighted averages within years, the influence reflects the abundance of each level,
#	  not just the presence/absence of each level, which is probably what we want.

obs_pred_2A <- aggregate(obs_pred[,2:ncol(obs_pred)], by= list(obs_pred$Year_fac), FUN = mean)
names(obs_pred_2A)[1] <- 'Year_fac'							#str(obs_pred_2A)

obs_pred_colmeans <- apply(obs_pred[,2:ncol(obs_pred)], 2, mean)

prelim_influence_wide <- cbind(obs_pred_2A[,1],sweep(obs_pred_2A[-1],2,obs_pred_colmeans, FUN = "-"))
names(prelim_influence_wide)[1] <- 'Year_fac'
Shallow_B_LnN_influence <- influence_wide <- prelim_influence_wide[,-(ncol(prelim_influence_wide))] 

  # make figures using facet_grid to save time
	influence_long <- as.data.frame(melt(setDT(influence_wide),id.vars="Year_fac", variable.name = "covar"))

  # put factors in the order we want them to appear
	influence_long$covar <- as.factor(influence_long$covar)
	levels(influence_long$covar)

	influence_long$covar <- factor(influence_long$covar, levels =
		c("Permit_effect",
			"Moon_effect",
			"Yday_effect",
			"SST_effect",
			"Lon_effect", 
			"Lat_effect",
			"LPH_effect"))   
	influence_long$Year <-  as.numeric(as.character(influence_long$Year_fac))
	str(influence_long)

 
  p <- ggplot() +
  	geom_point(data = influence_long, aes(x = Year, y = value))  +
	geom_line(data = influence_long, aes(x = Year, y = value))  +
    	theme_datareport_bar() +
	geom_hline(yintercept = 0, color='blue') +
  	facet_wrap(~covar, nrow=4,scales="free_y") +
  	 labs(title="Shallow Set B, log(CPUE) for Positive Catches", subtitle="", y="Influence", x="Year", caption="")


  png(file=paste0(root_dir,"/Figures/ShallowB_LnN_Influence_02Dec.png"),width=6.5, height=8, units = "in", pointsize = 8, res=300)
	p
  dev.off()



# -------------------------------------
# Shallow A GAMM LnN					# summary(model_object$mer)			# summary(model_object$gam)
# model_object <- Shallow_A_LnN					# formula(model_object$gam)	
# log(CPUE) ~ Year_fac + s(Permit_fac, bs = "re") + s(Lat) + s(Yday, bs = "cc") + s(Moon, bs = "cc") + Lightsticks_YN + 
#    s(Lon, k = 6) + HPF_fac + s(Hour, bs = "cc")


# diagnostics of the fit
  png(file=paste0(root_dir,"/Figures/ShallowA_LnN_Diagnostics_02Dec.png"),width=6.5, height=6.5, units = "in", pointsize = 8, res=300)
	gam.check.addlines(model_object$gam)
  dev.off()

#  marginal effects from smooth terms, with rug
# plot(model_object$gam,pages=1, rug = TRUE)
# plot(model_object$gam, rug = FALSE)




# --- Marginal effects using ggeffects package ---

  model_object_gam <- model_object$gam

  # make sure we have the yday vs. month (for leap year)
  yday_axis_leap <- data.frame('Yday' = c(1,32,61,92,122,153,183,214,245,284,306,336,366),
					'label' = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''))

  yday_axis_sparse <- data.frame('Yday' = c(1,61,122,183,245,306,366),
						'label' = c('Jan','Mar','May','Jul','Sep','Nov',''))


# --- Hour
  try_effects <- ggpredict(model_object_gam, "Hour", back.transform = TRUE)
 # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
  p_Hour <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
	scale_x_continuous(breaks=seq(0,24,6), labels=c("midnight","0600","noon","1800","2400") ) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Hour", caption="")


# --- Moon Phase
   try_effects <- ggpredict(model_object_gam, "Moon", back.transform = TRUE)
   # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

   # ggplot w/ ribbon
   p_Moon <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
	scale_x_continuous(breaks=seq(0,1,0.25), labels=c("new","first quarter","full","last quarter","new") ) +
  	labs(title="", subtitle="", y="CPUE", x="Moon Phase", caption="")


# --- YDay
   try_effects <- ggpredict(model_object_gam, "Yday", back.transform = TRUE)
   # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

   # ggplot w/ ribbon
   p_yday <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
  	scale_x_continuous(breaks=yday_axis_sparse$Yday, labels = yday_axis_sparse$label) +
  	labs(title="", subtitle="", y="CPUE", x="Time of Year", caption="")


# --- Lat
    try_effects <- ggpredict(model_object_gam, "Lat", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
    p_lat <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Latitude (deg N)", caption="")

# --- Lon
    try_effects <- ggpredict(model_object_gam, "Lon", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
    p_lon <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
  	# labs(title="", subtitle="", y="CPUE", x="Longitude (deg E)", caption="")
  	 labs(title="", subtitle="", y="CPUE", x="Longitude (deg E)", caption="")


# --- Year_fac
    try_effects <- ggpredict(model_object_gam, "Year_fac", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

    # points with CIs for factor vars
    p_year <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
	scale_x_discrete(breaks=seq(1995,2000,1)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Year", caption="")

# --- HPF_fac
    try_effects <- ggpredict(model_object_gam, "HPF_fac", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

    # points with CIs for factor vars
    p_HPF <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Hooks per Float", caption="")


# --- permit
    try_effects <- ggpredict(model_object_gam, "Permit_fac", back.transform = TRUE)

	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, 
			y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)					# str(marg_df)

	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- mean(marg_df$y)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)
	# in this instance, we expect permit to be Normal-ish, so easiest to visualize by sorting
	marg_df <- marg_df[order(marg_df$y_centered),]
	marg_df <- mutate(marg_df, new_x = seq(1,nrow(marg_df),1))

  p_vessel <- ggplot() +
  	geom_point(data = marg_df, aes(x = new_x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = new_x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
	scale_x_continuous(breaks=seq(0,nrow(marg_df),10), labels=NULL) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Permit", caption="")


# --- Lightsticks
    try_effects <- ggpredict(model_object_gam, "Lightsticks_YN", back.transform = FALSE)
    # plot(try_effects)		# by default, back.transform = TRUE.

	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)



    # points with CIs for factor vars
    p_Lightsticks <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
  	# scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Lightsticks (Y/N)", caption="")




#  output figure
#	now is 2 figures because there are too many covariates for 1 figure

  png(file=paste0(root_dir,"/Figures/ShallowA_LnN_Marginal_Effects_06Dec_A.png"),width=6.5, height=7.5, units = "in", pointsize = 8, res=300)
	grid.arrange(p_year,  p_vessel,p_lat, p_yday, p_Moon,p_Lightsticks,
		ncol=2)
  dev.off()

  png(file=paste0(root_dir,"/Figures/ShallowA_LnN_Marginal_Effects_06Dec_B.png"),width=6.5, height=6, units = "in", pointsize = 8, res=300)
	grid.arrange(p_lon,  p_HPF, p_Hour,
		ncol=2)
  dev.off()


 
# -------------------------------------
#	INFLUENCE PLOTS		
#
#  log(CPUE) ~ Year_fac + s(Permit_fac, bs = "re") + s(Lat) + s(Yday, bs = "cc") + s(Moon, bs = "cc") + Lightsticks_YN + 
#    s(Lon, k = 6) + HPF_fac + s(Hour, bs = "cc")

model_object <- Shallow_A_LnN
model_object_gam <- model_object$gam

# put together the predictions for each term and the observed data
#	type = terms calculates the value of each term in each predicted
pred_gam <- data.frame(pred_gam_terms = predict(model_object_gam, type="terms"), 	
		pred_gam_response = predict(model_object_gam, type="response"))

# summary(pred_gam)
pred_gam <- pred_gam[,-1]			#head(pred_gam)

# simplify, make names sql friendly
names(pred_gam)[] <- c("Lightsticks_effect", "HPF_effect","Permit_effect","Lat_effect",
		"Yday_effect", "Moon_effect", "Lon_effect", "Hour_effect", "pred_gam_response")

obs_in <- data.frame(Year_fac = model_object_gam$model[,2])			#	head(model_object_gam$model[,2])
obs_pred <- cbind(obs_in, pred_gam)							#head(obs_pred)		#str(obs_pred)

# I previously used sql code and 
#	only used unique values for each level of categorical variable per year, which seemed weird
#	for lightsticks_YN because there were only 2 levels, and each level appeared in every year
#	  but, but using the weighted averages within years, the influence reflects the abundance of each level,
#	  not just the presence/absence of each level, which is probably what we want.

obs_pred_2A <- aggregate(obs_pred[,2:ncol(obs_pred)], by= list(obs_pred$Year_fac), FUN = mean)
names(obs_pred_2A)[1] <- 'Year_fac'							#str(obs_pred_2A)

obs_pred_colmeans <- apply(obs_pred[,2:ncol(obs_pred)], 2, mean)

prelim_influence_wide <- cbind(obs_pred_2A[,1],sweep(obs_pred_2A[-1],2,obs_pred_colmeans, FUN = "-"))
names(prelim_influence_wide)[1] <- 'Year_fac'
Shallow_A_LnN_influence <- influence_wide <- prelim_influence_wide[,-(ncol(prelim_influence_wide))] 

  # make figures using facet_grid to save time

	influence_long <- as.data.frame(melt(setDT(influence_wide),id.vars="Year_fac", variable.name = "covar"))
  # put factors in the order we want them to appear
	influence_long$covar <- as.factor(influence_long$covar)
	levels(influence_long$covar)

#  log(CPUE) ~ Year_fac + s(Permit_fac, bs = "re") + s(Lat) + s(Yday, bs = "cc") + s(Moon, bs = "cc") + Lightsticks_YN + 
#    s(Lon, k = 6) + HPF_fac + s(Hour, bs = "cc")

	influence_long$covar <- factor(influence_long$covar, levels =
		c( "Permit_effect",
			"Lat_effect",      
			"Yday_effect",      
			"Moon_effect", 
			"Lightsticks_effect",      
			"Lon_effect",      
			"HPF_effect",
			"Hour_effect")  ) 
	influence_long$Year <-  as.numeric(as.character(influence_long$Year_fac))
	str(influence_long)

 
  p <- ggplot() +
  	geom_point(data = influence_long, aes(x = Year, y = value))  +
	geom_line(data = influence_long, aes(x = Year, y = value))  +
    	theme_datareport_bar() +
	geom_hline(yintercept = 0, color='blue') +
  	facet_wrap(~covar, nrow=4,scales="free_y") +
  	 labs(title="Shallow Set A, log(CPUE) for Positive Catches", subtitle="", y="Influence", x="Year", caption="")


  png(file=paste0(root_dir,"/Figures/ShallowA_LnN_Influence_02Dec.png"),width=6.5, height=8, units = "in", pointsize = 8, res=300)
	p
  dev.off()



# -------------------------------------
# Shallow A GAMM binomial					# summary(model_object$mer)			# summary(model_object$gam)
# model_object <- Shallow_A_Binom				# formula(model_object$gam)	
# OLD  z ~ Year_fac + s(Permit_fac, bs = "re") + s(Hour, bs = "cc") + s(Yday, bs = "cc") + s(Lat) + HPF_fac
# NEW   z ~ Year_fac + s(Permit_fac, bs = "re") + s(Hour, bs = "cc") + s(Yday, bs = "cc") + s(Lat) + Lightsticks_YN + s(Moon, bs = "cc")


model_object_gam <- model_object$gam

fitted_values <- fitted.values(model_object_gam)

   png(file=paste0(root_dir,"/Figures/ShallowA_Binom_Diag_02Dec.png"),width=6.5, height=4, units = "in", pointsize = 8, res=300)

	par(mfrow=c(1,2))
	par(omi=c(0.2,0.2,0.1,0.1)) #set outer margins
	par(mai=c(0.7,0.7, 0.3, 0.1)) #set inner margins

	plot(fitted_values, qresiduals(model_object_gam), xlab="Predicted Values", ylab= "Randomized Quantile Residuals")
	abline(h=0, col="blue")

	hist(qresiduals(model_object_gam), freq=FALSE, ylim=c(0,0.4), ylab="Proportional Frequency", 
		xlab="Randomized Quantile Residuals", main = "")

   dev.off()


# --- Marginal effects using ggeffects package ---

  # make sure we have the yday vs. month (for leap year)
  yday_axis_leap <- data.frame('Yday' = c(1,32,61,92,122,153,183,214,245,284,306,336,366),
					'label' = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''))

  yday_axis_sparse <- data.frame('Yday' = c(1,61,122,183,245,306,366),
						'label' = c('Jan','Mar','May','Jul','Sep','Nov',''))


# --- Hour
  try_effects <- ggpredict(model_object_gam, "Hour", back.transform = FALSE)			# 	str(try_effects)
 # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
  p_Hour <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
	scale_x_continuous(breaks=seq(0,24,6), labels=c("midnight","0600","noon","1800","2400") ) +
  	scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="p(present)", x="Hour", caption="")


# --- YDay
   try_effects <- ggpredict(model_object_gam, "Yday", back.transform = TRUE)
   # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.55
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

	# summary(marg_df)

   # ggplot w/ ribbon
   p_yday <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
   	scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +
 	theme_datareport_bar() +
  	scale_x_continuous(breaks=yday_axis_sparse$Yday, labels = yday_axis_sparse$label) +
  	labs(title="", subtitle="", y="p(present)", x="Time of Year", caption="")


# --- Lat
    try_effects <- ggpredict(model_object_gam, "Lat", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.55
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered_raw = lower_CI - make_zero)
	marg_df <- mutate(marg_df, lower_CI_centered = pmax(0,lower_CI_centered_raw ))



# ggplot w/ ribbon
    p_lat <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +  
	theme_datareport_bar() +
  	labs(title="", subtitle="", y="p(present)", x="Latitude (deg N)", caption="")


# --- Year_fac
    try_effects <- ggpredict(model_object_gam, "Year_fac", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)



    # points with CIs for factor vars
    p_year <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
	scale_x_discrete(breaks=seq(1995,2000,1)) +
  	scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +  
	theme_datareport_bar() +
  	labs(title="", subtitle="", y="p(present)", x="Year", caption="")

# --- Lightsticks
    try_effects <- ggpredict(model_object_gam, "Lightsticks_YN", back.transform = FALSE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)


    # points with CIs for factor vars
    p_Lightsticks <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
  	scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="p(present)", x="Lightsticks (Y/N)", caption="")


# --- Moon Phase
   try_effects <- ggpredict(model_object_gam, "Moon", back.transform = TRUE)
   # plot(try_effects)		# by default, back.transform = TRUE.
	

# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)


   # ggplot w/ ribbon
   p_Moon <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
	scale_x_continuous(breaks=seq(0,1,0.25), labels=c("new","first quarter","full","last quarter","new") ) +
  	labs(title="", subtitle="", y="p(present)", x="Moon Phase", caption="")



# --- permit
    try_effects <- ggpredict(model_object_gam, "Permit_fac", back.transform = FALSE)

	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)
	# in this instance, we expect permit to be Normal-ish, so easiest to visualize by sorting
	marg_df <- marg_df[order(marg_df$y_centered),]
	marg_df <- mutate(marg_df, new_x = seq(1,nrow(marg_df),1))

  p_vessel <- ggplot() +
  	geom_point(data = marg_df, aes(x = new_x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = new_x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
	scale_x_continuous(breaks=seq(0,nrow(marg_df),10), labels=NULL) +
  	scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="p(present)", x="Permit", caption="")



#  output figure

  png(file=paste0(root_dir,"/Figures/ShallowA_Binom_Marginal_Effects_02Dec.png"),width=6.5, height=8, units = "in", pointsize = 8, res=300)
	grid.arrange(p_year,p_vessel, p_Hour,p_yday, p_lat, p_Lightsticks, p_Moon,
		ncol=2)
  dev.off()



# -------------------------------------
#	INFLUENCE PLOTS	
#	erin is rethinking the "use unique levels only" of factors. 	
#
#  z ~ Year_fac + s(Permit_fac, bs = "re") + s(Hour, bs = "cc") + s(Yday, bs = "cc") + s(Lat) + Lightsticks_YN + s(Moon, bs = "cc")


model_object <- Shallow_A_Binom
model_object_gam <- model_object$gam

# put together the predictions for each term and the observed data
#	type = terms calculates the value of each term in each predicted
pred_gam <- data.frame(pred_gam_terms = predict(model_object_gam, type="terms"), 	
		pred_gam_response = predict(model_object_gam, type="response"))

# summary(pred_gam)
pred_gam <- pred_gam[,-1]			#head(pred_gam)

# simplify, make names sql friendly
names(pred_gam)[] <- c("Lightsticks_effect","Permit_effect","Hour_effect","Yday_effect","Lat_effect",
			"Moon_effect","pred_gam_response")
obs_in <- data.frame(Year_fac = model_object_gam$model[,2])			#	head(model_object_gam$model[,2])
obs_pred <- cbind(obs_in, pred_gam)							#head(obs_pred)		#str(obs_pred)

# I previously used sql code and 
#	only used unique values for each level of categorical variable per year, which seemed weird
#	for lightsticks_YN because there were only 2 levels, and each level appeared in every year
#	  but, but using the weighted averages within years, the influence reflects the abundance of each level,
#	  not just the presence/absence of each level, which is probably what we want.

obs_pred_2A <- aggregate(obs_pred[,2:ncol(obs_pred)], by= list(obs_pred$Year_fac), FUN = mean)
names(obs_pred_2A)[1] <- 'Year_fac'							#str(obs_pred_2A)

obs_pred_colmeans <- apply(obs_pred[,2:ncol(obs_pred)], 2, mean)

prelim_influence_wide <- cbind(obs_pred_2A[,1],sweep(obs_pred_2A[-1],2,obs_pred_colmeans, FUN = "-"))
names(prelim_influence_wide)[1] <- 'Year_fac'
Shallow_A_Binom_influence <- influence_wide <- prelim_influence_wide[,-(ncol(prelim_influence_wide))] 

  # make figures using facet_grid to save time

	influence_long <- as.data.frame(melt(setDT(influence_wide),id.vars="Year_fac", variable.name = "covar"))

  # put factors in the order we want them to appear
	influence_long$covar <- as.factor(influence_long$covar)
	levels(influence_long$covar)

	influence_long$covar <- factor(influence_long$covar, levels =
		c("Permit_effect",
			"Hour_effect",
			"Yday_effect", 
			"Lat_effect",        		
			"Lightsticks_effect",
			"Moon_effect"))   
	influence_long$Year <-  as.numeric(as.character(influence_long$Year_fac))
	str(influence_long)

 
  p <- ggplot() +
  	geom_point(data = influence_long, aes(x = Year, y = value))  +
	geom_line(data = influence_long, aes(x = Year, y = value))  +
    	theme_datareport_bar() +
	geom_hline(yintercept = 0, color='blue') +
  	facet_wrap(~covar, nrow=3,scales="free_y") +
  	 labs(title="Shallow Set A, Probability of Positive Catch", subtitle="", y="Influence", x="Year", caption="")


  png(file=paste0(root_dir,"/Figures/ShallowA_Binom_Influence_02Dec.png"),width=6.5, height=8, units = "in", pointsize = 8, res=300)
	p
  dev.off()



# -------------------------------------
# Deep GAMM binomial					# summary(model_object$mer)			# summary(model_object$gam)
# model_object <- Deep_Binom					# formula(model_object$gam)	
#   z ~ Year_fac + s(Permit_fac, bs = "re") + s(Yday, bs = "cc") + SST + s(Lat) + s(Moon, bs = "cc")

#  because model selection was done on 20K data, do some quick calcs to tell us about dev explained by model of full dataset
	#model	aic		dev		LL
	#z ~ 1	332967.1	332965.1	-166482.6
	intercept_only_dev <- 332965.1
	final_dev <-  deviance(Deep_Binom$mer)
	final_dev_expl <- (intercept_only_dev - final_dev)/intercept_only_dev

	model_object_gam <- model_object$gam

	fitted_values <- fitted.values(model_object_gam)

   png(file=paste0(root_dir,"/Figures/Deep_Binom_Diag_05Dec.png"),width=6.5, height=4, units = "in", pointsize = 8, res=300)

	par(mfrow=c(1,2))
	par(omi=c(0.2,0.2,0.1,0.1)) #set outer margins
	par(mai=c(0.7,0.7, 0.3, 0.1)) #set inner margins

	plot(fitted_values, qresiduals(model_object_gam), xlab="Predicted Values", ylab= "Randomized Quantile Residuals")
	abline(h=0, col="blue")

	hist(qresiduals(model_object_gam), freq=FALSE, ylim=c(0,0.4), ylab="Proportional Frequency", 
		xlab="Randomized Quantile Residuals", main = "")

   dev.off()


# --- Marginal effects using ggeffects package ---

  # make sure we have the yday vs. month (for leap year)
  yday_axis_leap <- data.frame('Yday' = c(1,32,61,92,122,153,183,214,245,284,306,336,366),
					'label' = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''))

  yday_axis_sparse <- data.frame('Yday' = c(1,61,122,183,245,306,366),
						'label' = c('Jan','Mar','May','Jul','Sep','Nov',''))


# --- YDay
   try_effects <- ggpredict(model_object_gam, "Yday", back.transform = FALSE)
   # plot(try_effects)		# by default, back.transform = TRUE, it doesn't matter with binom
	
	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

	# summary(marg_df)

   # ggplot w/ ribbon
   p_yday <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
#	scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +
    	scale_y_continuous(limits=c(0.3,0.7), breaks=seq(0.3,0.7,0.1)) +  
 	theme_datareport_bar() +
  	scale_x_continuous(breaks=yday_axis_sparse$Yday, labels = yday_axis_sparse$label) +
  	labs(title="", subtitle="", y="p(present)", x="Time of Year", caption="")

# --- Lat
    try_effects <- ggpredict(model_object_gam, "Lat", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
    p_lat <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +  
	theme_datareport_bar() +
  	labs(title="", subtitle="", y="p(present)", x="Latitude (deg N)", caption="")


# --- Year_fac
    try_effects <- ggpredict(model_object_gam, "Year_fac", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

    # points with CIs for factor vars
    p_year <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
#	scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.25)) +
	scale_x_discrete(breaks=seq(1995,2021,5)) +
  	scale_y_continuous(limits=c(0.3,0.7), breaks=seq(0.3,0.7,0.1)) +  
	theme_datareport_bar() +
  	labs(title="", subtitle="", y="p(present)", x="Year", caption="")


# --- SST
    try_effects <- ggpredict(model_object_gam, "SST", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
    p_SST <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	scale_y_continuous(limits=c(0.4,0.6), breaks=seq(0.4,0.6,0.05)) +   
	theme_datareport_bar() +
  	labs(title="", subtitle="", y="p(present)", x="SST (deg C)", caption="")



# --- Moon Phase
   try_effects <- ggpredict(model_object_gam, "Moon", back.transform = TRUE)
   # plot(try_effects)		# by default, back.transform = TRUE.
	

# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)


   # ggplot w/ ribbon
   p_Moon <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
	scale_x_continuous(breaks=seq(0,1,0.25), labels=c("new","first quarter","full","last quarter","new") ) +
  	labs(title="", subtitle="", y="p(present)", x="Moon Phase", caption="")





# --- permit
    try_effects <- ggpredict(model_object_gam, "Permit_fac", back.transform = FALSE)

	# extract values to plot ourselves
      marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, upper_CI = try_effects$conf.high, lower_CI = try_effects$conf.low)
	make_zero <- (min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2))-0.5
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)
	# in this instance, we expect permit to be Normal-ish, so easiest to visualize by sorting
	marg_df <- marg_df[order(marg_df$y_centered),]
	marg_df <- mutate(marg_df, new_x = seq(1,nrow(marg_df),1))

  p_vessel <- ggplot() +
  	geom_point(data = marg_df, aes(x = new_x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = new_x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
	scale_x_continuous(breaks=seq(0,nrow(marg_df),10), labels=NULL) +
  	scale_y_continuous(limits=c(0.2,0.8), breaks=seq(0.2,0.8,0.2)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="p(present)", x="Permit", caption="")


#  output figure

  png(file=paste0(root_dir,"/Figures/Deep_Binom_Marginal_Effects_05Dec.png"),width=6.5, height=8, units = "in", pointsize = 8, res=300)
	grid.arrange(p_year,p_vessel, p_yday,p_SST, p_lat, p_Moon,
		ncol=2)
  dev.off()



# -------------------------------------
#	INFLUENCE PLOTS		
#
#  z ~ Year_fac + s(Permit_fac, bs = "re") + s(Yday, bs = "cc") + SST + s(Lat, k = 6)


# put together the predictions for each term and the observed data
pred_gam <- data.frame(pred_gam_terms = predict(model_object_gam, type="terms"), 	
		pred_gam_response = predict(model_object_gam, type="response"))

# summary(pred_gam)
pred_gam <- pred_gam[,-1]			#head(pred_gam)

# simplify, make names sql friendly
names(pred_gam)[] <- c("SST_effect","Permit_effect","Yday_effect","Lat_effect","Moon_effect", "pred_gam_response")
obs_in <- data.frame(Year_fac = model_object_gam$model[,2])			#	head(model_object_gam$model[,2])
obs_pred <- cbind(obs_in, pred_gam)							#head(obs_pred)		#str(obs_pred)

obs_pred_2A <- aggregate(obs_pred[,2:ncol(obs_pred)], by= list(obs_pred$Year_fac), FUN = mean)
names(obs_pred_2A)[1] <- 'Year_fac'							#str(obs_pred_2A)

obs_pred_colmeans <- apply(obs_pred[,2:ncol(obs_pred)], 2, mean)

prelim_influence_wide <- cbind(obs_pred_2A[,1],sweep(obs_pred_2A[-1],2,obs_pred_colmeans, FUN = "-"))
names(prelim_influence_wide)[1] <- 'Year_fac'
Deep_Binom_influence <- influence_wide <- prelim_influence_wide[,-(ncol(prelim_influence_wide))] 

  # make figures using facet_grid to save time

	influence_long <- as.data.frame(melt(setDT(influence_wide),id.vars="Year_fac", variable.name = "covar"))

  # put factors in the order we want them to appear
	influence_long$covar <- as.factor(influence_long$covar)
	levels(influence_long$covar)

	influence_long$covar <- factor(influence_long$covar, levels =
		c("Permit_effect",
			"Yday_effect", 
			"SST_effect",
			"Lat_effect",        		
			"Moon_effect"))   
	influence_long$Year <-  as.numeric(as.character(influence_long$Year_fac))
	str(influence_long)

 
  p <- ggplot() +
  	geom_point(data = influence_long, aes(x = Year, y = value))  +
	geom_line(data = influence_long, aes(x = Year, y = value))  +
    	theme_datareport_bar() +
	geom_hline(yintercept = 0, color='blue') +
  	facet_wrap(~covar, nrow=3,scales="free_y") +
  	 labs(title="Deep Set, Probability of Positive Catch", subtitle="", y="Influence", x="Year", caption="")


  png(file=paste0(root_dir,"/Figures/Deep_Binom_Influence_05Dec.png"),width=6.5, height=8, units = "in", pointsize = 8, res=300)
	p
  dev.off()


# -------------------------------------
# Deep GAMM LnN					# summary(model_object$mer)			# summary(model_object$gam)
# model_object <- Deep_LnN					# formula(model_object$gam)	
#	log(CPUE) ~ Year_fac + s(Permit_fac, bs = "re") + s(Hour, 
#    bs = "cc") + s(Yday, bs = "cc") + HPF_fac + s(Lat) + 
#    SST + Bait_fac


# diagnostics of the fit
  png(file=paste0(root_dir,"/Figures/Deep_LnN_Diagnostics_02Dec.png"),width=6.5, height=6.5, units = "in", pointsize = 8, res=300)
	gam.check.addlines(model_object$gam)
  dev.off()

gam.check.addlines(model_object$gam)



#  marginal effects from smooth terms, with rug
# plot(model_object$gam,pages=1, rug = TRUE)
# plot(model_object$gam, rug = FALSE)


# --- Marginal effects using ggeffects package ---

  model_object_gam <- model_object$gam

  # make sure we have the yday vs. month (for leap year)
  yday_axis_leap <- data.frame('Yday' = c(1,32,61,92,122,153,183,214,245,284,306,336,366),
					'label' = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''))

  yday_axis_sparse <- data.frame('Yday' = c(1,61,122,183,245,306,366),
						'label' = c('Jan','Mar','May','Jul','Sep','Nov',''))


# --- Hour
  try_effects <- ggpredict(model_object_gam, "Hour", back.transform = TRUE)
 # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
  p_Hour <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
	scale_x_continuous(breaks=seq(0,24,6), labels=c("midnight","0600","noon","1800","2400") ) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Hour", caption="")


# --- YDay
   try_effects <- ggpredict(model_object_gam, "Yday", back.transform = TRUE)
   # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

   # ggplot w/ ribbon
   p_yday <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
  	scale_x_continuous(breaks=yday_axis_sparse$Yday, labels = yday_axis_sparse$label) +
  	labs(title="", subtitle="", y="CPUE", x="Time of Year", caption="")


# --- Lat
    try_effects <- ggpredict(model_object_gam, "Lat", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon
    p_lat <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Latitude (deg N)", caption="")


# --- Year_fac
    try_effects <- ggpredict(model_object_gam, "Year_fac", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

    # points with CIs for factor vars
    p_year <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
	scale_x_discrete(breaks=seq(1995,2021,5)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Year", caption="")

# --- HPF_fac
    try_effects <- ggpredict(model_object_gam, "HPF_fac", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

    # points with CIs for factor vars
    p_HPF <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Hooks per Float", caption="")


# --- Bait_fac
    try_effects <- ggpredict(model_object_gam, "Bait_fac", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

    marg_df$x <- as.numeric(marg_df$x)
    
    # points with CIs for factor vars	
    p_Bait <- ggplot() +
  	geom_point(data = marg_df, aes(x = x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
  	theme_datareport_bar() +
  	scale_x_continuous(breaks=seq(1,8,1)) + 
#	theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  	labs(title="", subtitle="", y="CPUE", x="Bait", caption="")



# --- SST
    try_effects <- ggpredict(model_object_gam, "SST", back.transform = TRUE)
    # plot(try_effects)		# by default, back.transform = TRUE.
	
	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)
	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- min(marg_df$y)+((max(marg_df$y)-min(marg_df$y))/2)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)

# ggplot w/ ribbon				# summary(SWODeep_pos$SST)
    p_SST <- ggplot() +
  	geom_line(data = marg_df, aes(x = x, y = y_centered))  +
  	geom_ribbon(data = marg_df, aes(x = x, ymin = lower_CI_centered, ymax = upper_CI_centered), 
		fill = "black", linetype = 0, alpha=0.2) +
  	scale_y_continuous(limits=c(-0.5,0.5), breaks=seq(-0.5,0.5,0.1)) +
  	scale_x_continuous(limits=c(22,28), breaks=seq(22,28,1)) +    	
	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="SST (deg C)", caption="")


# --- permit
    try_effects <- ggpredict(model_object_gam, "Permit_fac", back.transform = TRUE)

	# extract values to plot ourselves
	marg_df <- data.frame(x = try_effects$x, y = try_effects$predicted, 
			y_response = log(try_effects$predicted), 
				se_response = try_effects$std.error)					# str(marg_df)

	marg_df <- mutate(marg_df, upper_CI = exp(y_response + 1.96*se_response),
					lower_CI = exp(y_response - 1.96*se_response))
	make_zero <- mean(marg_df$y)
	marg_df <- mutate(marg_df, y_centered = y - make_zero, upper_CI_centered = upper_CI - make_zero,
 				lower_CI_centered = lower_CI - make_zero)
	# in this instance, we expect permit to be Normal-ish, so easiest to visualize by sorting
	marg_df <- marg_df[order(marg_df$y_centered),]
	marg_df <- mutate(marg_df, new_x = seq(1,nrow(marg_df),1))

  p_vessel <- ggplot() +
  	geom_point(data = marg_df, aes(x = new_x, y = y_centered))  +
	geom_errorbar(data = marg_df, aes(x = new_x, ymin = lower_CI_centered, ymax = upper_CI_centered),
			width = .2, position=position_dodge(.9)) +
	scale_x_continuous(breaks=seq(0,nrow(marg_df),10), labels=NULL) +
  	theme_datareport_bar() +
  	labs(title="", subtitle="", y="CPUE", x="Permit", caption="")


 # 623977 is the outlier


#  output figure

  png(file=paste0(root_dir,"/Figures/Deep_LnN_Marginal_Effects_05Dec.png"),width=6.5, height=9, units = "in", pointsize = 8, res=300)
	grid.arrange(p_year, p_vessel, p_Hour, p_yday, p_Bait,  p_lat, p_SST, p_HPF,
		ncol=2)
  dev.off()


# -------------------------------------
#	INFLUENCE PLOTS		
#
#  log(CPUE) ~ Year_fac + s(Permit_fac, bs = "re") + s(Hour, 
#    bs = "cc") + s(Yday, bs = "cc") + HPF_fac + s(Lat) + 
#    SST + Bait_fac

model_object <- Deep_LnN			# formula(model_object_gam)
model_object_gam <- model_object$gam

# put together the predictions for each term and the observed data
#	type = terms calculates the value of each term in each predicted
pred_gam <- data.frame(pred_gam_terms = predict(model_object_gam, type="terms"), 	
		pred_gam_response = predict(model_object_gam, type="response"))

# summary(pred_gam)
pred_gam <- pred_gam[,-1]			#head(pred_gam)

# simplify, make names sql friendly
names(pred_gam)[] <- c("HPF_effect","SST_effect","Bait_effect","Permit_effect","Hour_effect",
		"Yday_effect","Lat_effect", "pred_gam_response")

obs_in <- data.frame(Year_fac = model_object_gam$model[,2])			#	head(model_object_gam$model[,2])
obs_pred <- cbind(obs_in, pred_gam)							#head(obs_pred)		#str(obs_pred)

# I previously used sql code and 
#	only used unique values for each level of categorical variable per year, which seemed weird
#	for lightsticks_YN because there were only 2 levels, and each level appeared in every year
#	  but, but using the weighted averages within years, the influence reflects the abundance of each level,
#	  not just the presence/absence of each level, which is probably what we want.

obs_pred_2A <- aggregate(obs_pred[,2:ncol(obs_pred)], by= list(obs_pred$Year_fac), FUN = mean)
names(obs_pred_2A)[1] <- 'Year_fac'							#str(obs_pred_2A)

obs_pred_colmeans <- apply(obs_pred[,2:ncol(obs_pred)], 2, mean)

prelim_influence_wide <- cbind(obs_pred_2A[,1],sweep(obs_pred_2A[-1],2,obs_pred_colmeans, FUN = "-"))
names(prelim_influence_wide)[1] <- 'Year_fac'
Deep_LnN_influence <- influence_wide <- prelim_influence_wide[,-(ncol(prelim_influence_wide))] 

  # make figures using facet_grid to save time

	influence_long <- as.data.frame(melt(setDT(influence_wide),id.vars="Year_fac", variable.name = "covar"))
  # put factors in the order we want them to appear
	influence_long$covar <- as.factor(influence_long$covar)
	levels(influence_long$covar)

	influence_long$covar <- factor(influence_long$covar, levels =
		c( "Permit_effect",
			"Hour_effect" ,
			"Yday_effect",     
			"HPF_effect" ,     
			"Lat_effect", 
			"SST_effect",            
			"Bait_effect"
			)  ) 
	influence_long$Year <-  as.numeric(as.character(influence_long$Year_fac))
	str(influence_long)

 
  p <- ggplot() +
  	geom_point(data = influence_long, aes(x = Year, y = value))  +
	geom_line(data = influence_long, aes(x = Year, y = value))  +
    	theme_datareport_bar() +
	geom_hline(yintercept = 0, color='blue') +
  	facet_wrap(~covar, nrow=4,scales="free_y") +
  	 labs(title="Deep Set, log(CPUE) for Positive Catches", subtitle="", y="Influence", x="Year", caption="")


  png(file=paste0(root_dir,"/Figures/Deep_Ln_Influence_05Dec.png"),width=6.5, height=8, units = "in", pointsize = 8, res=300)
	p
  dev.off()






























































# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  by year and month



## prepare datasets
  # shallow, nominal vs. modeled CPUE, by year and month		#summary(Shallow_A_LnN$gam)
  # EARLY STANDARDIZED   head(Shallow_A_Delta_Year_Month)
	stan_early_A <- data.frame(Year = as.numeric(as.character(Shallow_A_Delta_Year_Month$year)), 
			Month = as.numeric(Shallow_A_Delta_Year_Month$Month),
			CPUE = Shallow_A_Delta_Year_Month$delta_fit,
			SE = Shallow_A_Delta_Year_Month$delta_se,
			Type = "standardized")

	stan_early <- merge(stan_early_A, yday_key, by = "Month")


  # LATE	STANDARDIZED	# head(Shallow_B_pred_year_month)		str(Shallow_B_pred_year_month)
	stan_late_A <- data.frame(Year = as.numeric(as.character(Shallow_B_pred_year_month$Year_fac)), 
			Month = as.numeric(Shallow_B_pred_year_month$Month),
			CPUE = Shallow_B_pred_year_month$pos_correct,
			SE = Shallow_B_pred_year_month$pos_se_correct,
			Type = "standardized")

	stan_late <- merge(stan_late_A, yday_key, by = "Month")


	# if we want to show CIs, we need to transform CPUE and SE back to the log scales first
	MSE_early <- summary(Shallow_A_LnN$gam)$dispersion
	MSE_late <- summary(Shallow_B_LnN$gam)$dispersion

	stan_early <- mutate(stan_early, CPUE_raw = log(CPUE)-(MSE_early/2))
	stan_early <- mutate(stan_early, SE_raw = SE/exp(CPUE_raw))
	stan_early <- mutate(stan_early, UCI_raw = CPUE_raw + 1.96*SE_raw, LCI_raw = CPUE_raw - 1.96*SE_raw)
	stan_early <- mutate(stan_early, UCI_correct = exp(UCI_raw+MSE_early/2), LCI_correct = exp(LCI_raw+MSE_early/2))

	stan_late <- mutate(stan_late, CPUE_raw = log(CPUE)-(MSE_late/2))
	stan_late <- mutate(stan_late, SE_raw = SE/exp(CPUE_raw))
	stan_late <- mutate(stan_late, UCI_raw = CPUE_raw + 1.96*SE_raw, LCI_raw = CPUE_raw - 1.96*SE_raw)
	stan_late <- mutate(stan_late, UCI_correct = exp(UCI_raw+MSE_late/2), LCI_correct = exp(LCI_raw+MSE_late/2))

      stan <- rbind(stan_early, stan_late)

  # NOMINAL
	shallow_all <- rbind(SWOShala, SWOShalb)
	nominal_avg <- aggregate(shallow_all$CPUE,by=list(shallow_all$Year, shallow_all$Month), mean)
	names(nominal_avg) <- c("Year","Month","CPUE")
	nominal_sd <- aggregate(shallow_all$CPUE,by=list(shallow_all$Year, shallow_all$Month), sd)		# str(SWOShalb)
	names(nominal_sd) <- c("Year","Month","SD")
	nominal_nobs <- dplyr::count(shallow_all,Year, Month)

	temp1 <- merge(nominal_avg, nominal_sd, by = c("Year","Month"))
	temp2 <- merge(temp1, nominal_nobs, by = c("Year","Month"))
	temp3 <- mutate(temp2, SE = SD/sqrt(n))
	temp4 <- temp3[,c(1,2,3,6)]
	exp_nom <- expand.grid(Year = c(seq(1995,2000,1), seq(2005,2021,1)), Month = seq(1,12,1))	
	temp5 <- merge(exp_nom, temp4, by = c("Year","Month"), all.x = TRUE)
	temp5[is.na(temp5)] <- 0
	temp5$Type <- "nominal"

	nom <- merge(temp5, yday_key, by = "Month")			# str(stan)		# str(nom)		#str(shallow_late)

	nom <- mutate(nom, CPUE_raw = CPUE, SE_raw = SE, 
					UCI_raw = CPUE + 1.96*SE,
					LCI_raw = CPUE - 1.96*SE, 
					UCI_correct = CPUE + 1.96*SE,
					LCI_correct = CPUE - 1.96*SE)

	shallow <- rbind(stan, nom)
#	shallow$Type <- as.factor(shallow$Type)

	# if we want to easily graph the shallow without connecting them, fill in the missing years with NAs

	shallow_missing <- expand.grid(Year = seq(2001, 2004, 1), Month = seq(1,12,1))		# str(shallow_missing)
	shallow_missing <- mutate(shallow_missing,
		CPUE = as.numeric(NA), SE = as.numeric(NA), Type = "standardized", Yday = as.numeric(NA),  
		CPUE_raw = as.numeric(NA), SE_raw = as.numeric(NA), UCI_raw = as.numeric(NA), 
		LCI_raw = as.numeric(NA), UCI_correct = as.numeric(NA), LCI_correct = as.numeric(NA))
#	attributes(shallow_missing) <- NULL

	shallow_missing_2 <- shallow_missing
	shallow_missing_2$Type = "nominal"
	shallow_missing <- rbind(shallow_missing, shallow_missing_2)

  shallow <- rbind(shallow, shallow_missing)

## FIGURES				# str(shallow)

	shallow <- mutate(shallow, plot_year = Year + Month/12)

p <- ggplot() +
  geom_line(data = subset(shallow, Type=="standardized"), aes(x = plot_year, y = CPUE), color = "blue")  +
  geom_ribbon(data = subset(shallow, Type=="standardized"), aes(x = plot_year, ymin = LCI_correct, ymax = UCI_correct), 
	fill = "blue", linetype = 0, alpha=0.2) +
  geom_line(data = subset(shallow, Type=="nominal"), aes(x = plot_year, y = CPUE), color = "red")  +
  geom_ribbon(data = subset(shallow, Type=="nominal"), aes(x = plot_year, ymin = LCI_correct, ymax = UCI_correct), 
	fill = "red", linetype = 0, alpha=0.2) +
  theme_datareport_bar() +
  labs(title="Shallow Set", subtitle="", y="CPUE (catch per thousand hooks)", x="Year", caption="")

  ggsave(paste0(root_dir,"/Figures/Shallow_CPUE_month_year.png"),p, width=6.5, units="in")



# or a different way
	# set up ticks
	ticks <- yday_axis$Yday
	ymax <- max(shallow_late$Upper_CI)		# summary(Shallow_B_pred_year_month)
	tick_height <- ymax/40
	
	grob_xlab <- textGrob("Month", gp=gpar(fontsize=10), y = unit(0.5, "npc"),)
	grob_ylab <- textGrob("CPUE (N per 1000 hooks)", gp=gpar(fontsize=10), 
		x = unit(0.6, "npc"), y = unit(0.5, "npc"),
		just = "centre", hjust = NULL, vjust = NULL, rot = 90)

  for (i in 2005:2021) {
	plot_me <- subset(shallow_late, Year == i)			#str(plot_me)
	
	assign(paste("sp_",i,sep=""),

	  ggplot(data=plot_me, aes(color=Type, x=Yday,y=CPUE)) +
		geom_point(stat="identity") +
		geom_line(stat="identity") +
		scale_color_manual(values=c("gray", "black")) +
		theme_datareport_bar() + 
		# add year ticks manually if we want them
		 geom_segment(y=0,yend=-tick_height,x=ticks[1],xend=ticks[1]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[2],xend=ticks[2]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[3],xend=ticks[3]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[4],xend=ticks[4]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[5],xend=ticks[5]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[6],xend=ticks[6]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[7],xend=ticks[7]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[8],xend=ticks[8]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[9],xend=ticks[9]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[10],xend=ticks[10]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[11],xend=ticks[11]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[12],xend=ticks[12]) +
		 geom_segment(y=0,yend=-tick_height,x=ticks[13],xend=ticks[13]) +
#		facet_wrap(~SCIENTIFIC_NAME, labeller = labeller(SCIENTIFIC_NAME = sp_names), ncol=3) +
#		theme(strip.text.x = element_text(face = "italic")) +
		scale_x_continuous(breaks = ticks, labels =c("Jan","","","Apr","","","Jul","","","Oct","","","")) +
		scale_y_continuous(limits=c(0,30)) +

	theme(axis.title.x = element_text(angle = 0, margin = margin(t=5, r=0, b=-15, l=0), vjust = 0)) +
	theme(axis.title.y = element_text(angle = 90, margin = margin(-20,0,-25,-15), vjust = 0)) +
		labs(y="", x="", caption="", title = as.character(i))
	     )
	   }

	tiff(file="2_6_prop_pos_by_area_8Oct.tiff",width=6.5, height=6, units = "in", pointsize = 8, res=300)
	grid.arrange(sp_2005, sp_2006 , sp_2007 , sp_2008, sp_2009, sp_2010, sp_2011,  sp_2012,  sp_2013,
		ncol=3, left = grob_ylab, bottom = grob_xlab)
	dev.off()


# ----  Deep, N positive sets year vs. day of year
SWODeep$Year_fac <- factor(SWODeep$Year_fac, levels = rev(levels(SWODeep$Year_fac)))
SWODeep_pos$Year_fac <- factor(SWODeep_pos$Year_fac, levels = rev(levels(SWODeep_pos$Year_fac)))

# make a df to use for the x axis
yday_axis <- data.frame('month'=c(seq(1,12,1),12), 'day' = c(rep(1,12),31), 'year' = rep(2021, 13),
		'label' = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', ''))
yday_axis$date <- as.Date(with(yday_axis,paste(year,month,day,sep="-")),"%Y-%m-%d")
yday_axis <- mutate(yday_axis, Yday = yday(date))

p <- ggplot(SWODeep, aes(x = Yday, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=90, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=yday_axis$Yday, labels = yday_axis$label) +
  labs(title="", subtitle="", y="", x="", caption="")

p <- ggplot(SWODeep_pos, aes(x = Yday, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=90, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=yday_axis$Yday, labels = yday_axis$label) +
  labs(title="", subtitle="", y="", x="", caption="")



# ----  year vs. Hour
p <- ggplot(SWODeep_pos, aes(x = Hour, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=24, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=c(-0.5,5.75, 12, 18.25, 24.5), labels=c("midnight","0600","noon","1800","midnight") ) +
  labs(title="", subtitle="", y="", x="", caption="")

p <- ggplot(SWODeep, aes(x = Hour, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=24, scale = 1, draw_baseline = FALSE) +
  scale_x_continuous(breaks=c(-0.5,5.75, 12, 18.25, 24.5), labels=c("midnight","0600","noon","1800","midnight") ) +
  labs(title="", subtitle="", y="", x="", caption="")


# ----   year vs. Moon phase
p <- ggplot(SWODeep_pos, aes(x = Moon, y = Year_fac, height = stat(density))) + 
  geom_density_ridges(stat = "binline", bins=20, scale = 1, draw_baseline = FALSE) +
#  scale_x_continuous(breaks=seq(0,1,0.25), labels=c("new","first quarter","full","last quarter","new") ) +
  scale_x_continuous(breaks=c(-0.025,0.2375, 0.5, 0.7625, 1.025), labels=c("new","first quarter","full","last quarter","new") ) +
  labs(title="", subtitle="", y="", x="", caption="")


# jitter obs, not so good
# ggplot(SWOShal_all, aes(x = Yday, y = Year_fac)) + 
#  geom_density_ridges(rel_min_height = 0.01, jittered_points = TRUE)



















#  ----------------------------------------------------------------------


