### code to run quick checks on SS models for SWO

suppressMessages(suppressWarnings(library(r4ss)))
library(ss3diags, quietly=T, warn.conflicts = F)
library(reshape2, quietly=T, warn.conflicts=F)
library(ggplot2, quietly=T, warn.conflicts=F)

base.dir<-"C://users//michelle.sculley//documents//2023 SWO ASSESS"
model.list<-c("01_Divide F9 size data",
              "02_Drop S4 and S8",
              "03_both 1 and 2",
              "04_change Lmin",
              "05_change settlement month",
              "06_increase CV Lmin",
              "07_lognormal selec", 
              "08_2 4 and 7",
              "09_3 and 7", 
              "10_3 4 7 and 6",
              "11_drop F20 decrease Amin",
              "12_mirrow F9",
              "13_mirrorF9 decrease Amin",
              "14_mirrorF9 decrease Amin Fix eqcat")

#current.dir<-paste0(base.dir,"//SA Meeting Runs//",model.list[4])

#current.dir<-paste0(base.dir, "//ModelDev//Current Best")#//F9 Cubic Spline")
#current.dir<-paste0(base.dir,"//ModelDev//NoSex//TWN block//JPN F1 block//DW Size Comp//Split F9 size")
setwd(base.dir)
### Run all
# for ( i in 1:length(model.list)){
#   current.dir<-paste0(base.dir,"//SA Meeting Runs//",model.list[i])
#   
#   base.model<-SS_output(current.dir)#, printstats = FALSE, verbose=FALSE)
# 
# 

# 
# SS_plots(base.model, html = FALSE, png = FALSE, pdf=TRUE, catchasnumbers = TRUE)
# }

#### RUn just one
current.dir<-paste0(base.dir,"//SA Meeting Runs//",model.list[14])
plotdir<-paste0(current.dir,"//plots")

base.model<-SS_output(current.dir, printstats = FALSE, verbose=FALSE)

startyear = 1975
endyear = 2021
rnames <- base.model$derived_quants$Label

#SS_plots(base.model, html = TRUE, png = TRUE, pdf=FALSE, catchasnumbers = TRUE)

                                                                          # # For cpue
# png(paste0(plotdir,"//CPUERunsTest.png"),height=8,width=8, units="in",res=200)
# sspar(mfrow=c(4,2),plot.cex = 0.8)
# SSplotRunstest(base.model,subplots="cpue",add=T,cex.main = 0.8) # use add=T to maintain plot set up
# dev.off()
# # Add Joint Residual plot and use ploting option
# SSplotJABBAres(base.model,subplots="cpue",add=T,legendcex = 0.5,ylimAdj = 2)
# 
# png(paste0(plotdir,"//LengthRunsTest.png"),height=8,width=8, units="in",res=200)
# sspar(mfrow=c(4,2),plot.cex = 0.8)
# SSplotRunstest(base.model,subplots="len",add=T,cex.main = 0.8) # use add=T to maintain plot set up
# dev.off()
# 
# 
# CPUE.mean<-aggregate(base.model$cpue$Obs, by=list(base.model$cpue$Fleet_name),mean)
# CPUE.annual<-base.model$cpue[,c("Fleet_name","Yr","Obs")]
# CPUE.annual<-dcast(CPUE.annual,Yr~Fleet_name)
# for (i in 1:8){
#   CPUE.annual[,i+1]<-CPUE.annual[,i+1]/CPUE.mean[i,2]
# }
# CPUE.annual<-melt(CPUE.annual, id.var="Yr", na.rm=TRUE)
# ggplot()+
#   geom_point(aes(x=Yr,y=value,fill=variable),data=CPUE.annual) +
#   geom_line(aes(x=Yr,y=value,color=variable),data=CPUE.annual) +
#   theme_bw() 
#   
