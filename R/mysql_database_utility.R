
mysqlDatabaseUtilityClass <- setRefClass("pgDatabaseUtility",
                                             fields = list(
                                               group = "character",
                                               user = "character",
                                               host = "character",
                                               port = "numeric",
                                               connection = "ANY"
                                             ),
                                             methods = list
                                             (
                                               #this is the constructor as per convention
                                               initialize=function(dbname, host, user, port, password, group, askForPassword=F)
                                               {

                                                 group <<- group
                                                 host <<- host
                                                 user <<- user
                                                 port <<- port
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

#dbutil <- mysqlDatabaseUtilityClass(host="db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com", dbname="mhbior", user="doadmin", port=25060, askForPassword =T, group='mhbior')
#res<-dbutil$testFunction()
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

    qString<-fread(file = file.path("MySQL","shared.sql"), sep = NULL, header = F, strip.white = F, check.names = F,stringsAsFactors = F, encoding = "UTF-8",data.table = F) #stringsAsFactors = F, quote = ''
    qString2<-paste(unlist(qString),collapse = '\n')

    q <- dbSendQuery(connection,
                     qString2
    )
    res<-dbFetch(q)
    dbClearResult(q)
    return(res)
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

    qString<-fread(file = file.path("MySQL","pid_generic.sql"), sep = NULL, header = F, strip.white = F, check.names = F,stringsAsFactors = F, encoding = "UTF-8",data.table = F) #stringsAsFactors = F, quote = ''
    qString2<-paste(unlist(qString),collapse = '\n')

    q <- dbSendQuery(connection,
                     qString2,
                     list(studyIndexInt)
    )

    q <- dbSendQuery(connection,
                     "SELECT * FROM t_pid"
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

#dbutil <- mysqlDatabaseUtilityClass(host="db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com", dbname="mhbior", user="doadmin", port=25060, askForPassword =T, group='mhbior')
#dbutil$executeSharedRoutines()
#res<-dbutil$selectConsentedAlias()
#res<-dbutil$selectStudyPID(1)
