dir.create("log")
logFile <- paste("log/log-",as.numeric(Sys.time()),".txt", sep = "")
file.create(logFile)
sink(logFile,append=FALSE, split=FALSE)

library(RTextTools)
library(RMySQL)
library(caret)

args = commandArgs(trailingOnly=TRUE)

# if (length(args) < 0) {
#   stop("At least one argument must be supplied (input file).n", call.=FALSE)
# } else if (length(args)==1) {
#   # default output file
#   args[2] = "out.txt"
# }


representation <- 1

inputFile <- args[1]
datasetName <- args[2]
connectionsFile <- args[3]
description <- args[4]
trainSize <- as.double(args[5])

#trainSize <- 0.5

#datasetName <- "Oil-test"
#datasetName <- "reuters-1" 


#inputFile <- "D:/Documents/Dropbox/Tesis II - Seminario/DataSets/Reuters/reuters-1.csv"
#inputFile <- "D:/GIT/TextSimilarity/Data/Oil/OilTrain.csv"

#connectionsFile <- "D:/GIT/TextDataPreProcessingR/DBCredentials.R"


OriginaldataSet = read.csv(inputFile)  # read csv file 


set.seed(as.numeric(Sys.time()))
inTrain <- createDataPartition(OriginaldataSet$class, p = trainSize, 
                               list = FALSE)


dataSet <- OriginaldataSet[inTrain,]

dataset.test <- OriginaldataSet[-inTrain,]

matrix.original <- create_matrix(OriginaldataSet$text, language="english",
                        removeNumbers=TRUE, stemWords=TRUE, removeStopwords=TRUE, 
                        stripWhitespace=TRUE, toLower=TRUE)

matrix <- matrix.original[inTrain,]
matrixTest <- matrix.original[-inTrain,]

classes <- dataSet$class
texts <- dataSet$text

classes.test <- dataset.test$class
texts.test <- dataset.test$text


source(connectionsFile)

mydb = dbConnect(MySQL(), user=DBUser, password=DBPassword, dbname=DBName, host=DBHost)

queryStr = paste("SELECT * FROM dataset WHERE name = '",datasetName,"';", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetId <- dat$id

queryStr = paste("Insert into datasetrepresentation(dataset,representation,description,status) values(",datasetId,",",representation,",'",description," Train','running');",sep = "")
dbSendQuery(mydb, queryStr)

queryStr = paste("SELECT MAX(id) as id FROM datasetrepresentation", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetrepresentation <- dat$id


line <- matrix$dimnames$Terms[1]
for (i in 2:matrix$ncol){
  line <- paste(line,matrix$dimnames$Terms[i],sep = ",")
}

queryStr = paste("Insert into document(datasetRepresentation,original,value,class) values(",datasetrepresentation,",'N/A','",line,"','N/A');",sep = "")
dbSendQuery(mydb, queryStr)


for (i in 1:matrix$nrow){
  line <- matrix[i,1]
  for (j in 2:matrix$ncol){
    line <- paste(line,matrix[i,j],sep = ",")
  }
  queryStr = paste("Insert into document(datasetRepresentation,original,value,class) values(",datasetrepresentation,",'",texts[i],"','",line,"','",classes[i],"');",sep = "")
  dbSendQuery(mydb, queryStr)
}



queryStr = paste("update datasetrepresentation set status='successful' where id=",datasetrepresentation,";",sep = "")
dbSendQuery(mydb, queryStr)


queryStr = paste("Insert into datasetrepresentation(dataset,representation,description,status) values(",datasetId,",",representation,",'",description," Test','running');",sep = "")
dbSendQuery(mydb, queryStr)

queryStr = paste("SELECT MAX(id) as id FROM datasetrepresentation", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetrepresentation <- dat$id


line <- matrixTest$dimnames$Terms[1]
for (i in 2:matrixTest$ncol){
  line <- paste(line,matrixTest$dimnames$Terms[i],sep = ",")
}


queryStr = paste("Insert into document(datasetRepresentation,original,value,class) values(",datasetrepresentation,",'N/A','",line,"','N/A');",sep = "")
dbSendQuery(mydb, queryStr)

for (i in 1:matrixTest$nrow){
  line <- matrixTest[i,1]
  for (j in 2:matrixTest$ncol){
    line <- paste(line,matrixTest[i,j],sep = ",")
  }
  queryStr = paste("Insert into document(datasetRepresentation,original,value,class) values(",datasetrepresentation,",'",texts.test[i],"','",line,"','",classes.test[i],"');",sep = "")
  dbSendQuery(mydb, queryStr)
}

queryStr = paste("update datasetrepresentation set status='successful' where id=",datasetrepresentation,";",sep = "")
dbSendQuery(mydb, queryStr)

sink()
