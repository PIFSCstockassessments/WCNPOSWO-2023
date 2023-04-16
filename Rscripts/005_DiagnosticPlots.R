### Diagnostic Plots
### run 001_LoadModel.R prior to running this script

library(r4ss,quietly=T,warn.conflicts = F)
library(ss3diags, quietly = T, warn.conflicts = F)
library(ggplot2,quietly = T, warn.conflicts = F)

# ##CPUE Runs test
# 
#   png(paste0(plotdir,"//CPUERunsTest.png"),height=8,width=8, units="in",res=200)
#   sspar(mfrow=c(4,2),plot.cex = 0.8)
SSplotRunstest(base.model,subplots="cpue",add=T,cex.main = 0.8) # use add=T to maintain plot set up
#   dev.off()
# # # Add Joint Residual plot and use ploting option
# # # SSplotJABBAres(base.model,subplots="cpue",add=T,legendcex = 0.5,ylimAdj = 2)
# # # 
# # 
# # ## Size comp runs test
#   png(paste0(plotdir,"//LengthRunsTest.png"),height=8,width=8, units="in",res=200)
#   sspar(mfrow=c(4,2),plot.cex = 0.8)
   SSplotRunstest(base.model,subplots="len",add=T,cex.main = 0.8) # use add=T to maintain plot set up
#   dev.off()
#  

  
  ##Notes for Running ASPM
  ## Use Ctl.ss_new as new control file
  ## Set all rec devs to 0, turn off advanced options
  ## Fix initial F paramters (set phases to neg)
  ## fix selectivity for all fleets (set phases to neg)
  ## set lambda of size comp fleets and recruiment devs to 0
  ## set lambda of equilibrium catch/intial F to 1
 ##ASPM Model
 ASPMDir<-paste0(current.dir,"\\ASPM")
 
 ASPM<-SS_output(ASPMDir, verbose=FALSE,printstats = FALSE)
 ASPMSumBioSpawn<-ASPM$derived_quants[which(ASPM$derived_quants==paste0("SSB_",startyear)):which(ASPM$derived_quants==paste0("SSB_",endyear)),]
 ASPMSumBioSpawn$Year<-seq(startyear, endyear,1)
 #SS_plots(ASPM)
# png(file.path(current.dir,"plots","ASPMBiomass_Spawn.png"),height=8,width=18, units="in",res=300)
 ASPM_Plot<-ggplot()+
   geom_point(aes(x=Year,y=Value), data=SumBioSpawn,size=1)+
   geom_line(aes(x=Year,y=Value), data=SumBioSpawn,size=1)+
   geom_point(aes(x=Year,y=Value), data=ASPMSumBioSpawn,size=1, shape=17)+
   geom_line(aes(x=Year,y=Value), data=ASPMSumBioSpawn,size=1, linetype="dashed")+
   geom_ribbon(aes(x=Year,ymin=Value-1.96*StdDev,ymax=Value+1.96*StdDev),data=SumBioSpawn,alpha=0.2)+
   geom_ribbon(aes(x=Year,ymin=Value-1.96*StdDev,ymax=Value+1.96*StdDev),data=ASPMSumBioSpawn,alpha=0.2)+
   ylab("Spawning Biomass (mt)") +
   xlab("Year")+
   theme(axis.text.x=element_text(size=8), axis.title.x=element_text(size=12),
         axis.text.y=element_text(size=8),axis.title.y=element_text(size=12),
         panel.border = element_rect(color="black",fill=NA,size=1),
         panel.background = element_blank())+
   scale_x_continuous(breaks=seq(startyear,endyear,5))# +
 #scale_y_continuous(label = comma)
# ASPM_Plot
# dev.off()
 
 