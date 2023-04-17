### plot sensitivity runs
## run 001_LoadModel.R and 003_DataSummaryFigs.R before running

library(r4ss)

Sensbase<-paste0(current.dir,"\\Sensitivities")
SensList<-c("\\1_base_case_highM",
            "\\2_base_case_lowM",
            "\\3_base_case_h070",
            "\\4_Sensitivity_h081",
            "\\5_Sensitivity_h099",
            "\\6_Sensitivity_large_Amax",
            "\\7_Sensitivity_Sun_Growth",
            "\\8_Sensitivity_high_L50",
            "\\9_Sensitivity_low_L50",
            "\\10_Sensitivity_L50_Wang2003",
            "\\11a_Sensitivity_Drop_VNCN_catch",
            "\\11b_Sensitivity_Drop_VNCN_catch_until2021",
            "\\12_Sensitivity_NP_all_Catch",
            "\\13_OrphanCatch",
            "\\14_Change_Amin_1",
            "\\15_Change_S6_lambda0",
            "\\16_TWN doubleNorm Selec",
            "\\17_Add F9 Size Data",
            "\\18a_Only S2",
            "\\18b_Only S4",
            "\\18c_Only S5",
            "\\18d_Only S7",
            "\\18e_Only S8",
            "\\18f_Only S7 and S8",
            "\\19_All CPUE")
for (i in 1:length(SensList)){SensDir[i]<-paste0(Sensbase,SensList[i])}
SensMods<-SSgetoutput(dirvec=SensDir)
SensModsSum<-SSsummarize(SensMods)



NatM_sens<-SSsummarize(list(base.model,SensMods[[1]],SensMods[[2]]))
SSplotComparisons(NatM_sens,png=TRUE, plotdir = plotdir, legendlabels=c("base case","Model 1","Model 2"),  subplots = c(1,5,7),shadealpha = 0, filenameprefix = "SensNatM_")

h_sens<-SSsummarize(list(base.model,SensMods[[3]],SensMods[[4]],SensMods[[5]]))
SSplotComparisons(h_sens,png=TRUE, plotdir = plotdir, legendlabels=c("base case","Model 3","Model 4","Model 5"),subplots = c(1,5,7), shadealpha = 0, filenameprefix = "SensSteep_")
h_sens<-SSsummarize(list(base.model,SensMods[[3]],SensMods[[4]]))
SSplotComparisons(h_sens,png=TRUE, plotdir = plotdir, legendlabels=c("base case","Model 3","Model 4"),subplots = c(1,5,7), shadealpha = 0, filenameprefix = "SensSteep2_")

Growth_sens<-SSsummarize(list(base.model,SensMods[[6]], SensMods[[7]]))
SSplotComparisons(Growth_sens,png=TRUE, plotdir = plotdir, legendlabels=c("base case","Model 6","Model 7"), subplots = c(1,5,7),  shadealpha = 0, filenameprefix="SensGrowth_")
Growth_sens<-SSsummarize(list(base.model, SensMods[[7]]))
SSplotComparisons(Growth_sens,png=TRUE, plotdir = plotdir, legendlabels=c("base case","Model 7"), subplots = c(1,5,7),  shadealpha = 0, filenameprefix="SensGrowth2_")


Mat_sens<-SSsummarize(list(base.model,SensMods[[8]],SensMods[[9]],SensMods[[10]]))
SSplotComparisons(Mat_sens,png=TRUE, plotdir = plotdir, legendlabels=c("base case","Model 8","Model 9","Model 10"), subplots = c(1,5,7), shadealpha = 0, filenameprefix = "SensMat_")


Catch_sens<-SSsummarize(list(base.model,SensMods[[11]],SensMods[[12]],SensMods[[13]],SensMods[[14]]))
SSplotComparisons(Start_sens,png=TRUE, plotdir = plotdir, legendlabels=c("base case","Model 11a","Model 11b","Model 12","Model 13"), subplots = c(1,5,7),shadealpha = 0) 

 Changes_sens<-SSsummarize(list(base.model,SensMods[[13]], SensMods[[14]]))
 SSplotComparisons(Changes_sens,png=TRUE, plotdir = paste0(dirbase,SensList[14]), legendlabels=c("base case","Model 13","Model 14"), subplots = c(1,5,7),shadealpha = 0)
 

CPUE_Sens<-SSsummarize(list(base.model,SensMods[[19]],SensMods[[20]],SensMods[[21]],SensMods[[22]],SensMods[[23]],SensMods[[24]],SensMods[[25]]))
SSplotComparisons(CPUE_Sens,png=TRUE, plotdir = plotdir, legendlabels=c("base case","Model 18a","Model 18b","Model 18c","Model 18d","Model 18e","Model 18f","Model 19"), subplots = c(1,5,7),  shadealpha = 0, filenameprefix = "SensCPUE_")

CPUE_Sens<-SSsummarize(list(base.model,SensMods[[19]],SensMods[[20]],SensMods[[21]],SensMods[[22]],SensMods[[23]],SensMods[[24]],SensMods[[25]]))
SSplotComparisons(CPUE_Sens,png=TRUE, plotdir = plotdir, legendlabels=c("base case","Model 18a","Model 18b","Model 18c","Model 18d","Model 18e","Model 18f","Model 19"), subplots = c(1,5,7),  shadealpha = 0, filenameprefix = "SensCPUE_")
