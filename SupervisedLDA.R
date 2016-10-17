library(RTextTools)
library(lda)


args = commandArgs(trailingOnly=TRUE)

# if (length(args) < 0) {
#   stop("At least one argument must be supplied (input file).n", call.=FALSE)
# } else if (length(args)==1) {
#   # default output file
#   args[2] = "out.txt"
# }


representation <- 2

inputFile <- args[1]
datasetName <- args[2]
connectionsFile <- args[3]
description <- args[4]
alphaValue <- args[5]
betaValue <- args[6]


#datasetName <- "Oil-test"
#datasetName <- "reuters-1" 
#inputFile <- "D:/Documents/Dropbox/Tesis II - Seminario/DataSets/Reuters/reuters-1.csv"
#inputFile <- "D:/GIT/TextSimilarity/Data/Oil/OilTrain.csv"

#connectionsFile <- "D:/GIT/TextDataPreProcessingR/DBCredentials.R"

dataSet = read.csv(inputFile)  # read csv file 

texts <- dataSet$text
annotations <- dataSet$class

matrix <- create_matrix(dataSet$text, language="english",
                        removeNumbers=TRUE, stemWords=FALSE, removeStopwords=TRUE, 
                        stripWhitespace=TRUE, toLower=TRUE)

vocab <- matrix$dimnames$Terms

corpus <- lexicalize(dataSet$text, lower=TRUE, vocab = vocab)

annotations.levels <-levels(annotations)


num.topics <- length(annotations.levels)

## Initialize the params
params <- sample(annotations, num.topics, replace=TRUE)

annotations.numeric <- as.numeric(annotations)

variance <- var(annotations.numeric)

result <- slda.em(documents=corpus,
                  K=num.topics,
                  vocab=vocab,
                  num.e.iterations=10,
                  num.m.iterations=4,
                  alpha=alphaValue, eta=betaValue,
                  annotations.numeric,
                  params,
                  variance=variance,
                  logistic=FALSE,
                  method="sLDA")


source(connectionsFile)
mydb = dbConnect(MySQL(), user=DBUser, password=DBPassword, dbname=DBName, host=DBHost)

queryStr = paste("SELECT * FROM dataset WHERE name = '",datasetName,"';", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetId <- dat$id

queryStr = paste("Insert into datasetrepresentation(dataset,representation,description,status) values(",datasetId,",",representation,",'",description," alpha: ",alphaValue," beta: ",betaValue," ','running');",sep = "")
dbSendQuery(mydb, queryStr)

queryStr = paste("SELECT MAX(id) as id FROM datasetrepresentation", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetrepresentation <- dat$id

line <- annotations.levels[1]
for (i in 2:num.topics){
  line <- paste(line,annotations.levels[i],sep = ",")
}

queryStr = paste("Insert into document(datasetRepresentation,original,value,class) values(",datasetrepresentation,",'N/A','",line,"','N/A');",sep = "")
dbSendQuery(mydb, queryStr)

num.documents <- length(annotations)

for (i in 1:num.documents){
  line <- result$model$model$z.bar.[i,1]
  for (j in 2:num.topics){
    line <- paste(line,result$model$model$z.bar.[i,j],sep = ",")
  }
  queryStr = paste("Insert into document(datasetRepresentation,original,value,class) values(",datasetrepresentation,",'",texts[i],"','",line,"','",annotations[i],"');",sep = "")
  dbSendQuery(mydb, queryStr)
}

queryStr = paste("update datasetrepresentation set status='successful' where id=",datasetrepresentation,";",sep = "")
dbSendQuery(mydb, queryStr)



# 
# predictions <- slda.predict(poliblog.documents,
#                             result$topics, 
#                             result$model,
#                             alpha = 1.0,
#                             eta=0.1)
