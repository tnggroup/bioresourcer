#runs the exportSpark routine
library('bioresourcer')
br<-bioresourcerClass("export-config.ini")
br$exportSpark()
