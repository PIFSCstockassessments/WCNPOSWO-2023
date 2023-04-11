### code to run quick checks on SS models for SWO

suppressMessages(suppressWarnings(library(r4ss)))
library(ss3diags, quietly=T, warn.conflicts = F)
library(reshape2, quietly=T, warn.conflicts=F)
library(ggplot2, quietly=T, warn.conflicts=F)

base.dir<-"C://users//michelle.sculley//documents//2023 SWO ASSESS"
current.dir<-paste0(base.dir, "//ModelDev//Current Best")#//F9 Cubic Spline")
current.dir<-paste0(base.dir,"//ModelDev//NoSex//TWN block//JPN F1 block//DW Size Comp")
setwd(base.dir)
plotdir<-paste0(current.dir,"//plots")


base.model<-SS_output(current.dir, printstats = FALSE, verbose=FALSE)

startyear = 1975
endyear = 2021
rnames <- base.model$derived_quants$Label

SS_plots(base.model, html = TRUE, png = TRUE, pdf=FALSE, catchasnumbers = TRUE)


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
