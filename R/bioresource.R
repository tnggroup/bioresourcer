#install with remotes::install_github('tnggroup/bioresourcer')

bioresourcerClass <- setRefClass("bioresourcer",
                                      fields = list(
                                        #General
                                        currentUserTag = "character",
                                        folderpathBioResourceData = "character",
                                        nThreads = "numeric",

                                        #standardised subfolder paths
                                        relSubFolderpathReceiptReports = "character",
                                        #NBC
                                        folderpathBioResourceData.NBC = "character",
                                        folderpathBioResourceData.NBC.cleaned = "character",

                                        folderpathBioResourceData.NBC.raw = "character",
                                        folderpathBioResourceData.NBC.barcodeReports = "character",
                                        folderpathBioResourceData.NBC.barcodeImports = "character",

                                        config = "ANY",
                                        mysqlDAO = "ANY"
                                      ),
                                      methods = list
                                      (
                                        #this is the constructor as per convention
                                        initialize=function(filepathConfig, nFolderpathBioResourceData=getwd(),nCurrentUserTag="anon",nNThreads=3)
                                        {
                                          #Config
                                          config<<-ConfigParser$new()
                                          config$read(filepathConfig)
                                          #General
                                          currentUserTag <<- nCurrentUserTag
                                          folderpathBioResourceData <<- nFolderpathBioResourceData
                                          nThreads <<- nNThreads
                                          #standardised subfolder paths
                                          relSubFolderpathReceiptReports<<-"RR"
                                          #NBC
                                          folderpathBioResourceData.NBC<<-file.path(folderpathBioResourceData,"NBC data")
                                          folderpathBioResourceData.NBC.cleaned<<-file.path(folderpathBioResourceData.NBC,"NBC data (clean)")

                                          folderpathBioResourceData.NBC.raw<<-file.path(folderpathBioResourceData.NBC,"NBC raw reports")

                                          folderpathBioResourceData.NBC.barcodeReports<<-file.path(folderpathBioResourceData.NBC,"RR RedCap barcode reports")

                                          folderpathBioResourceData.NBC.barcodeImports<<-file.path(folderpathBioResourceData.NBC,"RR Redcap barcode imports")
                                        }
                                      )
)



bioresourcerClass$methods(
  connectMysqlDAO=function(host, dbname, user, password, port=25060, group='mhbior', folderpathSql="SQL"){
    mysqlDAO<<-mysqlDatabaseUtilityClass(host=host, dbname=dbname, user=user, port=port, folderpathSql=folderpathSql, askForPassword =F, group=group, password=password)
    return(1)
  }
)

#library(ConfigParser)
bioresourcerClass$methods(
  connectMysqlDAOfromConfig=function(folderpathSql="SQL"){

    connectMysqlDAO(
      host = config$data$mysqldb$host,
      dbname = config$data$mysqldb$database,
      user = config$data$mysqldb$user,
      port = as.integer(config$data$mysqldb$port),
      password = config$data$mysqldb$password,
      folderpathSql= folderpathSql
    )
  }
)


bioresourcerClass$methods(
  exportSpark=function(){

    connectMysqlDAOfromConfig()
    mysqlDAO$executeSharedRoutines()

    #GLAD
    cFilename<-paste0("RV5_glad_pid_",format(Sys.time(), "%d%m%Y"),".csv")
    pidGLAD<-mysqlDAO$selectStudyPID(1)
    fwrite(pidGLAD,file = file.path(config$data$sftp$localdir,cFilename), col.names = T, row.names = F) #config$data$sftp$localdir
    cFilename<-paste0("RV5_glad_sample_linkage_",format(Sys.time(), "%d%m%Y"),".csv")
    linkGLAD<-mysqlDAO$selectStudyLink(1)
    fwrite(linkGLAD,file = file.path(config$data$sftp$localdir,cFilename), col.names = T, row.names = F) #config$data$sftp$localdir

    #EDGI
    cFilename<-paste0("RV5_edgi_pid_",format(Sys.time(), "%d%m%Y"),".csv")
    pidEDGI<-mysqlDAO$selectStudyPID(2)
    fwrite(pidEDGI,file = file.path(config$data$sftp$localdir,cFilename), col.names = T, row.names = F) #config$data$sftp$localdir
    cFilename<-paste0("RV5_edgi_sample_linkage_",format(Sys.time(), "%d%m%Y"),".csv")
    linkEDGI<-mysqlDAO$selectStudyLink(2)
    fwrite(linkEDGI,file = file.path(config$data$sftp$localdir,cFilename), col.names = T, row.names = F) #config$data$sftp$localdir

    return(1)
  }
)

#br<-bioresourcerClass("/Users/jakz/Documents/work_eclipse/nihr_data_xchange/export-config.ini")

#br$exportSpark()

# For tests, load these
#library(data.table)

# we can add more methods after creating the ref class (but not more fields!)

# create file for upload to redcap
#based on NBC_data_RR.py, RR_saliva_kits_received_MHBIOR.py
bioresourcerClass$methods(
  kits.NBC_data_RR=function(filenameReceiptReport, filepathReceiptReportOverride = NULL){
    #TEST
    # brc<-bioresourcerClass(nFolderpathBioResourceData="data")
    # filenameReceiptReport<-"NIHR-NBC-RTB-MHS-Sample-Receipt-Report-20250113.csv"
    # folderpathBioResourceData.NBC.raw<-brc$folderpathBioResourceData.NBC.raw
    # folderpathBioResourceData.NBC.barcodeReports<-brc$folderpathBioResourceData.NBC.barcodeReports
    # folderpathBioResourceData.NBC.barcodeImports<-brc$folderpathBioResourceData.NBC.barcodeImports
    # relSubFolderpathReceiptReports<-brc$relSubFolderpathReceiptReports
    # nThreads<-brc$nThreads
    # filepathReceiptReportOverride<-"data/NBC data/NBC raw reports/RR/January 2025/NIHR-NBC-RTB-MHS-Sample-Receipt-Report-20250113.csv"

    settingMHBIORSalivaKitSamplesFileNamePrefix<-"BioResourceRR_MHBIOR_saliva_kits_"
    settingRedCapSalivaKitSamplesFileNamePrefix<-"BioResourceRR_saliva_kits_unreturned_"

    if(!is.null(filepathReceiptReportOverride)){
      fileToRead<-filepathReceiptReportOverride
    } else fileToRead<-file.path(folderpathBioResourceData.NBC.raw,relSubFolderpathReceiptReports,filenameReceiptReport)
    #CSV
    fileData.receiptReports <- data.table::fread(file = fileToRead, na.strings =c(".",NA,"NA",""), encoding = "UTF-8",check.names = T, fill = T, blank.lines.skip = T, data.table = T, nThread = nThreads, showProgress = F)

    #standardise filename from file timestamp - NBC_data_RR_DD_MM_YYYY.csv
    filename.split<-strsplit(filenameReceiptReport,split = "-",fixed = T)
    filename.split.datepart<-strsplit(filename.split[[1]][length(filename.split[[1]])],split = ".",fixed = T)[[1]][[1]]
    fileDT<-strptime(filename.split.datepart,format='%Y%m%d')
    newFilenamePart<-paste0("NBC_data_RR_",strftime(fileDT,format='%d_%m_%Y'))
    fileYearString<-strftime(fileDT,format='%Y')
    fileMonthTextString<-strftime(fileDT,format='%B')

    #BUSINESS RULES
    #1. Data - save to folderpathBioResourceData.NBC.barcodeReports/YEAR
    #2. No data - save to folderpathBioResourceData.NBC.cleaned/relSubFolderpathReceiptReports

    if(nrow(fileData.receiptReports)>0){
      fileToWrite<-file.path(folderpathBioResourceData.NBC.barcodeReports,fileYearString,paste0(newFilenamePart,".csv"))
    } else {
      fileToWrite<-file.path(folderpathBioResourceData.NBC.cleaned,relSubFolderpathReceiptReports,paste0(newFilenamePart,"_empty",".csv"))
    }

    data.table::fwrite(x = fileData.receiptReports,file = fileToWrite, append = F,quote = T,sep = ",",col.names = T,nThread=nThreads)
    cat("\nReceipt report written to:\n",fileToWrite,"\n")

    #continue - only when data present
    if(nrow(fileData.receiptReports)>0){
      #continue
    } else {
      return(1)
    }

    #process MHBIOR samples report (including unreturned)
    #based on Scripts/Daily uploads/RR_saliva_kits_received_MHBIOR.py, Scripts/Daily uploads/RR_saliva_kits_received.py
    fileToRead<-file.path(folderpathBioResourceData.NBC.barcodeReports,fileYearString,paste0(settingMHBIORSalivaKitSamplesFileNamePrefix,strftime(fileDT,format='%d.%m.%Y'),".csv"))
    fileData.samplesReports <- data.table::fread(file = fileToRead, na.strings =c(".",NA,"NA",""), encoding = "UTF-8",check.names = T, fill = T, blank.lines.skip = T, data.table = T, nThread = nThreads, showProgress = F)

    fileToRead<-file.path(folderpathBioResourceData.NBC.barcodeReports,fileYearString,paste0(settingRedCapSalivaKitSamplesFileNamePrefix,strftime(fileDT,format='%d.%m.%Y'),".csv"))
    fileData.samplesReportsUnreturned <- data.table::fread(file = fileToRead, na.strings =c(".",NA,"NA",""), encoding = "UTF-8",check.names = T, fill = T, blank.lines.skip = T, data.table = T, nThread = nThreads, showProgress = F)

    setDT(fileData.samplesReports)
    setDT(fileData.samplesReportsUnreturned)
    setDT(fileData.receiptReports)
    fileData.samplesReports[,c('Aliases', 'Kit.sent', 'Already.sent.kit.back')]<-NULL

    fileData.samplesReports[,c('kit_unusable','destruction_certificate'):=NA]
    fileData.samplesReports<-fileData.samplesReports[,.(participant_id=Participant.id, study_id=Study, barcode=Barcode, royal_mail_tracking_id=Tracking.id, date_kit_sent=Date.kit.sent, nhs_provided=NHS.Provided, kit_unusable, destruction_certificate, type=Sample.type, date_kit_received_na=Date.kit.received)]
    fileData.samplesReportsUnreturned[,barcode:=saliva_kit_barcode][,saliva_kit_barcode:=NULL]

    #replace variables for NHS provided
    #unique(fileData.samplesReports$nhs_provided)
    fileData.samplesReports[nhs_provided=="Yes",nhs_provided:=1]
    fileData.samplesReports[nhs_provided=="No",nhs_provided:=0]
    fileData.samplesReports[,nhs_provided:=as.numeric(nhs_provided)]

    #replace variables for study_id
    #unique(fileData.samplesReports$study_id)
    fileData.samplesReports[study_id=="GLAD",study_id:=1]
    fileData.samplesReports[study_id=="EDGI UK",study_id:=2]
    fileData.samplesReports[,study_id:=as.numeric(study_id)]

    # fill in kit_unusable as 0 if empty
    #unique(fileData.samplesReports$kit_unusable)
    fileData.samplesReports[is.na(kit_unusable),kit_unusable:=0]
    fileData.samplesReports[,kit_unusable:=as.numeric(kit_unusable)]

    #see to it that barcode is of type character
    fileData.samplesReports[,barcode:=as.character(barcode)]
    fileData.receiptReports[,barcode:=as.character(TubeBarcode)][,TubeBarcode:=NULL]

    #merge, left outer join fileData.samplesReports with fileData.receiptReports
    dim(fileData.samplesReports)
    dim(fileData.receiptReports)
    fileData.samplesReports.receiptReports <- merge(fileData.samplesReports,fileData.receiptReports,by = "barcode",all.x = T, all.y = F)
    dim(fileData.samplesReports.receiptReports)
    fileData.samplesReports.receiptReports[,c('Project', 'Condition', 'Comment', 'ParticipantID', 'Clinic', 'Gender', 'Date.Time.Taken', 'TubeType', 'Photo',	'Volume', 'VolUnit')]<-NULL #deactivate these variables to keep true to the previous rules

    fileToWrite<-file.path(folderpathBioResourceData.NBC.barcodeImports,fileYearString,paste0("RR_saliva_kits_received_MHBIOR_",strftime(fileDT,format='%d.%m.%Y'),".csv"))
    data.table::fwrite(x = fileData.samplesReports.receiptReports,file = fileToWrite, append = F,quote = T,sep = ",",col.names = T,nThread=nThreads)
    cat("\nBarcode imports file written to:\n",fileToWrite,"\n")

    #merge, left outer join fileData.samplesReportsUnreturned with fileData.receiptReports
    dim(fileData.samplesReportsUnreturned)
    dim(fileData.receiptReports)
    fileData.samplesReportsUnreturned.receiptReports <- merge(fileData.samplesReportsUnreturned,fileData.receiptReports,by = "barcode",all.x = T, all.y = F)
    dim(fileData.samplesReportsUnreturned.receiptReports)
    #this originally kept all columns from the receipt report

    fileToWrite<-file.path(folderpathBioResourceData.NBC.barcodeImports,fileYearString,paste0("RR_saliva_kits_received_",strftime(fileDT,format='%d.%m.%Y'),".csv"))
    data.table::fwrite(x = fileData.samplesReportsUnreturned.receiptReports,file = fileToWrite, append = F,quote = T,sep = ",",col.names = T,nThread=nThreads)
    cat("\nBarcode imports UNRETURNED file written to:\n",fileToWrite,"\n")

    #process REDCap file (Barcode imports, unreturned?)
    #Data is currently in fileData.samplesReportsUnreturned.receiptReports(?)




  }
)

#BioResourceRR_MHBIOR_saliva_kits_30.09.2024.csv
