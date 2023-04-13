#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>
# Run Retrospective analysis example
# Cookbook paper in revision
# "A Cookbook for Using Model Diagnostics in Integrated Stock Assessments"
#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>

# Install r4ss
# devtools::install_github('r4ss/r4ss')
# Load Libray
library(r4ss)
library(gridExtra)
library(ggplot2)
#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>
# Preparations
#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>
# 1. Setup a subfolder names Reference_Run
# 2. Copy the following files of your assessment into this subfolder
# - data.ss
# - control.ss
# - start.ss
# - forecast.ss  
# - wtatage.ss (if applicable)
# 3. if data and control file have specific names e.g. tuna_data.ss change to generic data.ss
# 4. Also ajust to data.ss and control.ss in starter file
# 5. Run Model Model in Malawi_Demo folder

# Step 1. Identify restrospective period
# e.g., for end.yr.vec   <- c(2015,2014,2013,2012,2011,2010)
start.retro <- 0    #end year of model e.g., 2015
end.retro   <- 5    #number of years for retrospective e.g., 2014,2013,2012,2011,2010

# Step 2. Identify the base directory
dirname.base = file.path(current.dir,"Diagnostics","Retros")

Run = "full"

# Names of DAT and CONTROL files
DAT = "swo2023_v003.dat"
CTL =  "swo2023_v001.ctl"

# # Step 3. Identify the directory where a completed model run is located
 dirname.completed.model.run <- current.dir
# dirname.completed.model.run
# 
# # Step 4. Create a subdirectory for the Retrospectives
 dirname.Retrospective <- paste0(dirname.base,'/Retro_',Run)
# dir.create(path=dirname.Retrospective, showWarnings = TRUE, recursive = TRUE)
 setwd(dirname.Retrospective)
# 
# 
# # Step 5.
# #----------------- copy model run files ----------------------------------------
#  file.copy(paste(dirname.completed.model.run,       "starter.ss_new", sep="/"),
#            paste(dirname.Retrospective, "starter.ss", sep="/"))
#  file.copy(paste(dirname.completed.model.run,       "control.ss_new", sep="/"),
#            paste(dirname.Retrospective, CTL, sep="/"))
#  file.copy(paste(dirname.completed.model.run,       "data_echo.ss_new", sep="/"),
#            paste(dirname.Retrospective, DAT, sep="/"))	
#  file.copy(paste(dirname.completed.model.run,       "forecast.ss", sep="/"),
#            paste(dirname.Retrospective, "forecast.ss", sep="/"))
#  file.copy(paste(dirname.completed.model.run,       "SS.exe", sep="/"),
#            paste(dirname.Retrospective, "ss.exe", sep="/"))
#  file.copy(paste(dirname.completed.model.run,       "wtatage.ss", sep="/"),
#            paste(dirname.Retrospective, "wtatage.ss", sep="/"))
# 
# #------------Make Changes to the Starter.ss file (DC Example) ------------------------------- 
#  starter <- readLines(paste(dirname.Retrospective, "/starter.ss", sep=""))
# # 
# # # 1) Starter File changes to speed up model runs
# # # Run Display Detail
#  # [8] "2 # run display detail (0,1,2)" 
#  linen <- grep("# run display detail", starter)
#  starter[linen] <- paste0( 1 , " # run display detail (0,1,2)" )
#  write(starter, paste(dirname.Retrospective, "starter.ss", sep="/"))
# # 
# #------------ r4SS retrospective calculations------------------------------- 
# 
# # Step 6. Run the retrospective analyses with r4SS function "SS_doRetro"
# # Here Switched off Hessian extras "-nohess" (much faster)
# 
#  retro(dir=dirname.Retrospective, oldsubdir="", newsubdir="retrospectives", years=start.retro:-end.retro,extras = "-nohess")

# Step 7. Read "SS_doRetro" output
retroModels <- SSgetoutput(dirvec=file.path(dirname.Retrospective, "retrospectives",paste("retro",start.retro:-end.retro,sep="")))

# Step 8. save as Rdata file for ss3diags
#save(retroModels,file=file.path(dirname.Retrospective,paste0("Retro_",Run,".rdata")))


## plot your results
retroSummary <- SSsummarize(retroModels)
endyrvec <- retroSummary$endyrs + 0:-5
#SSplotComparisons(retroSummary, endyrvec=endyrvec, legendlabels=paste("Data",0:-5,"years"),png=TRUE, plotdir=plotdir, legend= FALSE, type="l", sprtarg =0)

## create biomass and SPR retrospective plots. Be sure to update years as necessary
# SummaryBio<-retroSummary$SpawnBio
# names(SummaryBio)<-c("basecase","retro-1","retro-2","retro-3","retro-4","retro-5","Label","Yr")
# SummaryBio<-melt(SummaryBio,id.vars=c("Label","Yr"))
# SummaryBio<-subset(SummaryBio,Yr>=startyear)
# RemoveVector<-c(which(SummaryBio$variable=="retro-1"&SummaryBio$Yr==endyear),which(SummaryBio$variable=="retro-2"&SummaryBio$Yr>=endyear-1),which(SummaryBio$variable=="retro-3"&SummaryBio$Yr>=endyear-2),which(SummaryBio$variable=="retro-4"&SummaryBio$Yr>=endyear-3),which(SummaryBio$variable=="retro-5"&SummaryBio$Yr>=endyear-4))
# SummaryBio<-SummaryBio[-RemoveVector,]
# 
# a<-ggplot() +
#   geom_line(aes(x=Yr,y=value,color=variable),data=SummaryBio, size=1) +
#   theme(panel.border = element_rect(color="black",fill=NA,size=1),
#         panel.background = element_blank(), strip.background = element_blank(),
#         legend.position = "none") +
#   scale_color_manual(values = c("basecase" = "black","retro-1" = "red", "retro-2"="orange","retro-3"="yellow","retro-4"="green","retro-5"="blue", "basecase"="black")) + xlab("Year") + ylab("Spawning Biomass (mt)") +
#   geom_line(aes(x=Yr,y=value),data=subset(SummaryBio,variable=="basecase"),color="black", size=1.25)
# 
# 
# 
# 
# SPR<-retroSummary$SPRratio
# names(SPR)<-c("basecase","retro-1","retro-2","retro-3","retro-4","retro-5","Label","Yr")
# SPR<-melt(SPR,id.vars=c("Label","Yr"))
# SPR<-subset(SPR,Yr>=startyear)
# RemoveVector<-c(which(SPR$variable=="retro-1"&SPR$Yr==endyear),which(SPR$variable=="retro-2"&SPR$Yr>=endyear-1),which(SPR$variable=="retro-3"&SPR$Yr>=endyear-2),which(SPR$variable=="retro-4"&SPR$Yr>=endyear-3),which(SPR$variable=="retro-5"&SPR$Yr>=endyear-4))
# SPR<-SPR[-RemoveVector,]
# 
# b<-ggplot() +
#   geom_line(aes(x=Yr,y=value,color=variable),data=SPR, size=1) +
#   theme(panel.border = element_rect(color="black",fill=NA,size=1),
#         panel.background = element_blank(), strip.background = element_blank(),
#         legend.position = "none") +
#   scale_color_manual(values = c("basecase" = "black","retro-1" = "red", "retro-2"="orange","retro-3"="yellow","retro-4"="green","retro-5"="blue", "basecase"="black")) + xlab("Year") + ylab("1-SPR") +
#   geom_line(aes(x=Yr,y=value),data=subset(SPR,variable=="basecase"),color="black", size=1.25) +
#   scale_y_continuous(limits = c(0,1))
# 
# grid.arrange(a,b,ncol=2)
# 
#*******************************************************************
#  Retrospective Analysis with Hindcasting
#*******************************************************************

# load retroModels produced with "Run_Retrospective_bum.R"
#load(file=file.path(getwd(),paste0("Retro_",Run),paste0("Retro_",Run,".rdata")),verbose=T)

# Summarize the list of retroModels
#retroSummary <- r4ss::SSsummarize(retroModels)

# # Now Check Retrospective Analysis with one-step ahead Forecasts
#  sspar(mfrow=c(2,2),plot.cex = 0.9)
#  SSplotRetro(retroSummary,forecast = F,add=T,showrho = F,subplots = c("SSB", "F")[1]) # SSB
#  SSplotRetro(retroSummary,forecast = F,add=T,showrho = F,subplots = c("SSB", "F")[2],legend = F) # F
#  SSplotRetro(retroSummary,xmin=2000,forecastrho = T,add=T,legend = F)
#  SSplotRetro(retroSummary,xmin=2000,forecastrho = T,add=T,legend = F,subplots="F")
 #dev.print(jpeg,paste0(plotdir,"/RetroForecast_",Run,".jpg"), width = 8, height = 9, res = 300, units = "in")

# Get retro stats
 #SShcbias(retroSummary)
# # 
# # # Do Hindcast with Cross-Validation of CPUE observations
#  sspar(mfrow=c(3,2))
#  SSplotHCxval(retroSummary,add=T, cex.main=0.5) # CPUE
#  dev.print(jpeg,paste0(plotdir,"/HCxvalIndex_",Run,".jpg"), width = 16, height = 10, res = 300, units = "in")
# # 
# # # Also test new feature of Hindcast with Cross-Validation for mean length
#  sspar(mfrow=c(3,2))
#  # Use new converter fuction SSretroComps() for size comps
#  hccomps = SSretroComps(retroModels)
#  # Plot
#  SSplotHCxval(hccomps,add=T,subplots = "len",legendloc="bottomright",legendcex=0.8)
#  dev.print(jpeg,paste0(plotdir,"/HCxvalLen_",Run,".jpg"), width = 8, height = 10, res = 300, units = "in")
# # 
# # # Get mase stats from hindcasting
#  SSmase(retroSummary,quants="cpue")
#  SSmase(hccomps,quants="len")
# 
