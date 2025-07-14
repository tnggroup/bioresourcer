
mysqlDatabaseUtilityClass <- setRefClass("pgDatabaseUtility",
                                             fields = list(
                                               group = "character",
                                               user = "character",
                                               host = "character",
                                               port = "numeric",
                                               connection = "ANY",
                                               folderpathSql = "character"
                                             ),
                                             methods = list
                                             (
                                               #this is the constructor as per convention
                                               initialize=function(dbname, host, user, port, password, group, folderpathSql="SQL", askForPassword=F)
                                               {

                                                 group <<- group
                                                 host <<- host
                                                 user <<- user
                                                 port <<- port
                                                 folderpathSql<<-folderpathSql
                                                 if(askForPassword){
                                                   connection <<- dbConnect(RMariaDB::MariaDB(), #RMySQL::MySQL()
                                                                            dbname = dbname,
                                                                            host = host,
                                                                            port = port,
                                                                            user = user,
                                                                            password = rstudioapi::askForPassword(prompt = "Enter database password for specified user."),
                                                                            group = group
                                                                            )
                                                 } else {
                                                   connection <<- dbConnect(RMariaDB::MariaDB(),
                                                             dbname = dbname,
                                                             host = host,
                                                             port = port,
                                                             user = user,
                                                             password = password,
                                                             group = group)
                                                 }
                                               }
                                             )
)

# we can add more methods after creating the ref class (but not more fields!)

# dbutil <- mysqlDatabaseUtilityClass(host="db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com", dbname="mhbior", user="doadmin", port=25060, askForPassword =T, group='mhbior')
# res<-dbutil$testFunction()
# library(RMySQL)
# library(DBI)
# library(data.table)
# q <- dbSendQuery(dbutil$connection,
#                  "SELECT * FROM mhbior.studies" #"SELECT met.get_cohortinstance($1,$2)"
# ) #list(cohort,instance)
# res<-dbFetch(q)

mysqlDatabaseUtilityClass$methods(
  testFunction=function(cohort,instance){
    q <- dbSendQuery(connection,
                     "SELECT * FROM mhbior.studies;" #"SELECT met.get_cohortinstance($1,$2)"
                     ) #list(cohort,instance)
    res<-dbFetch(q)
    dbClearResult(q)
    return(res)
  }
)

mysqlDatabaseUtilityClass$methods(
  executeSharedRoutines=function(){

    q <- dbExecute(connection,"DROP TEMPORARY TABLE IF EXISTS t_consented_alias")

    qString<-fread(file = file.path(folderpathSql,"shared.sql"), sep = NULL, header = F, strip.white = F, check.names = F,stringsAsFactors = F, encoding = "UTF-8",data.table = F) #stringsAsFactors = F, quote = ''
    qString2<-paste(unlist(qString),collapse = '\n')

    q <- dbExecute(connection,
                     qString2
    )
    # q <- dbSendQuery(connection,
    #                  qString2
    # )
    # res<-dbFetch(q)
    # dbClearResult(q)
    return(q)
  }
)

# res<-dbutil$executeSharedRoutines()
# View(res)

mysqlDatabaseUtilityClass$methods(
  selectConsentedAlias=function(cohort,instance){

    q <- dbSendQuery(connection,
                     "SELECT * FROM t_consented_alias;"
    ) #list(cohort,instance)
    res<-dbFetch(q)
    dbClearResult(q)
    return(res)
  }
)

mysqlDatabaseUtilityClass$methods(
  selectStudyPID=function(studyIndexInt){

    q <- dbExecute(connection,"DROP TEMPORARY TABLE IF EXISTS t_pid")

    qString<-fread(file = file.path(folderpathSql,"pid_generic.sql"), sep = NULL, header = F, strip.white = F, check.names = F,stringsAsFactors = F, encoding = "UTF-8",data.table = F) #stringsAsFactors = F, quote = ''
    qString2<-paste(unlist(qString),collapse = '\n')

    q <- dbSendQuery(connection,
                     qString2,
                     list(paste0("",studyIndexInt))
    )

    q <- dbSendQuery(connection,
                     "SELECT * FROM t_pid"
    )


    res<-dbFetch(q)
    dbClearResult(q)
    return(res)
  }
)

mysqlDatabaseUtilityClass$methods(
  selectStudyLink=function(studyIndexInt){

    q <- dbExecute(connection,"DROP TEMPORARY TABLE IF EXISTS t_link")

    qString<-fread(file = file.path(folderpathSql,"link_generic.sql"), sep = NULL, header = F, strip.white = F, check.names = F,stringsAsFactors = F, encoding = "UTF-8",data.table = F) #stringsAsFactors = F, quote = ''
    qString2<-paste(unlist(qString),collapse = '\n')

    q <- dbSendQuery(connection,
                     qString2,
                     list(paste0("",studyIndexInt))
    )

    q <- dbSendQuery(connection,
                     "SELECT * FROM t_link"
    )


    res<-dbFetch(q)
    dbClearResult(q)
    return(res)
  }
)

# q <- dbSendQuery(dbutil$connection,
#                  qString2
# )
#
# dbBind(q,list(1))
#
# q <- dbSendQuery(connection,
#                  "SELECT * FROM t_pid"
# )
#
# res<-dbFetch(q)
# dbClearResult(q)
# View(res)

# dbutil <- mysqlDatabaseUtilityClass(host="db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com", dbname="mhbior", user="doadmin", port=25060, askForPassword =T, group='mhbior')
# dbutil$executeSharedRoutines()
# res<-dbutil$selectConsentedAlias()
# res1<-dbutil$selectStudyPID(studyIndexInt = 1)
# res2<-dbutil$selectStudyPID(studyIndexInt = 2)
