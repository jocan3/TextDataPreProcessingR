library(RTextTools)
library(lda)
library(RMySQL)
library(caret)

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
trainSize <- as.double(args[4])
alphaValue <- args[5]
betaValue <- args[6]
batch <- args[7]

description <- paste("LDA",datasetName, ". alpha:",toString(alphaValue),". beta:",toString(betaValue),". Train:",toString(trainSize*100),"%",sep=" ")
# 
# # trainSize <- 0.6
# # datasetName <- "Oil-test"
# # #datasetName <- "reuters-1"
# # #inputFile <- "D:/Documents/Dropbox/Tesis II - Seminario/DataSets/Reuters/reuters-1.csv"
# # alphaValue <- 0.2
# # betaValue <- 0.8
# # inputFile <- "D:/GIT/TextSimilarity/Data/Oil/OilTrain.csv"
# # # 
# # # connectionsFile <- "D:/GIT/TextDataPreProcessingR/DBCredentials.R"
# # # 


OriginaldataSet = read.csv(inputFile)  # read csv file 

 
 set.seed(as.numeric(Sys.time()))
 inTrain <- createDataPartition(OriginaldataSet$class, p = trainSize, 
                                list = FALSE)


dataSet <- OriginaldataSet[inTrain,]
dataset.test <- OriginaldataSet[-inTrain,]

texts <- dataSet$text
annotations <- dataSet$class

############################################## DB ACTIONS #########################################################

source(connectionsFile)
mydb = dbConnect(MySQL(), user=DBUser, password=DBPassword, dbname=DBName, host=DBHost)

queryStr = paste("SELECT * FROM dataset WHERE name = '",datasetName,"';", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetId <- dat$id

queryStr = paste("Insert into datasetrepresentation(dataset,representation,description,status) values(",datasetId,",",representation,",'",description,"','running');",sep = "")
dbSendQuery(mydb, queryStr)

queryStr = paste("SELECT MAX(id) as id FROM datasetrepresentation", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetrepresentation <- dat$id

###################################################################################################################


matrix <- create_matrix(dataSet$text, language="english",
                        removeNumbers=TRUE, stemWords=FALSE, removeStopwords=TRUE, 
                        stripWhitespace=TRUE, toLower=TRUE)

vocab <- matrix$dimnames$Terms

corpus <- lexicalize(dataSet$text, lower=TRUE, vocab = vocab)

annotations.levels <-levels(annotations)

num.topics <- length(annotations.levels)

## Initialize the params (initial coeficientes to be used by the EM step)
params <- sample(annotations, num.topics, replace=TRUE)

annotations.numeric <- as.numeric(annotations)

variance <- var(annotations.numeric)

result <- NULL
attempt <- 1
while( is.null(result) && attempt <= 3 ) {
  attempt <- attempt + 1
  try(
    result <- slda.em(documents=corpus,
                      K=num.topics,
                      vocab=vocab,
                      num.e.iterations=100,
                      num.m.iterations=50,
                      alpha=alphaValue, eta=betaValue,
                      annotations.numeric,
                      params,
                      variance=variance,
                      logistic=FALSE,
                      method="sLDA")
  )
} 

line <- annotations.levels[1]
for (i in 2:num.topics){
  line <- paste(line,annotations.levels[i],sep = ",")
}

############################################## DB ACTIONS #########################################################

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

queryStr = "SELECT * FROM algorithm WHERE name = 'LDA';"
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)
algorithm <- dat$id

queryStr = "SELECT * FROM metric WHERE name = 'N/A';"
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)
metric <- dat$id


descriptionExperiment = paste(description, ". Algorithm: LDA (No ensemble). Metric: N/A. K=N/A. Train=", toString(trainSize * 100), "% Test=", toString((1-trainSize)*100), "%.", sep="")

queryStr = paste("INSERT INTO experiment(datasetRepresentation, algorithm, metric, description, status, batch) VALUES (",datasetrepresentation,",",algorithm,",",metric,",'",descriptionExperiment,"','","running","',",batch,");",sep = "")
dbSendQuery(mydb, queryStr)

queryStr = paste("SELECT MAX(id) as id FROM experiment", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

experiment <- dat$id

###################################################################################################################


texts.test <- dataset.test$text
annotations.test <- dataset.test$class

matrix.test <- create_matrix(texts.test, language="english",
                             removeNumbers=TRUE, stemWords=FALSE, removeStopwords=TRUE, 
                             stripWhitespace=TRUE, toLower=TRUE)

vocab.test <- matrix.test$dimnames$Terms

corpus.test <- lexicalize(dataset.test$text, lower=TRUE, vocab = vocab.test)

annotations.levels.test <-levels(annotations.test)

annotations.numeric.test <- as.numeric(annotations.test)

num.topics.test <- length(annotations.levels.test)

predictions <- NULL
attempt <- 1
while( is.null(predictions) && attempt <= 3 ) {
  attempt <- attempt + 1
  try(
    predictions <- slda.predict(corpus.test,
                                result$topics,
                                result$model,
                                alpha = alphaValue,
                                eta= betaValue)
  )
} 


coefs = coef(result$model)
result.topics = result$topics
doc_sums_count <- slda.predict.docsums(corpus.test, result$topics, alphaValue, betaValue, 100, 50, 0L)
props <- t(doc_sums_count)/colSums(doc_sums_count)



############################################## DB ACTIONS #########################################################

num.documents.test <- length(annotations.test)

for (i in 1:num.documents.test){
  line <- props[i,1]
  for (j in 2:num.topics.test){
    line <- paste(line,props[i,j],sep = ",")
  }
  
  queryStr = paste("Insert into document(datasetRepresentation,original,value,class) values(",datasetrepresentation,",'",texts.test[i],"','",line,"','","TEST:",annotations.test[i],"');",sep = "")
  dbSendQuery(mydb, queryStr)
  
  queryStr = paste("SELECT MAX(id) as id FROM document", sep="")
  res <- dbSendQuery(mydb, queryStr)
  dat <- dbFetch(res)
  document.id <- dat$id
  
  queryStr = paste("Insert into imputation(document, experiment, expectedClass, imputedClass) values(",document.id,",",experiment,",'",annotations.test[i],"','",annotations.levels[round(predictions[i])],"');",sep = "")
  dbSendQuery(mydb, queryStr)
  
  queryStr = paste("Insert into imputationlda(document, experiment, expectedClass, imputedClass) values(",document.id,",",experiment,",",annotations.numeric.test[i],",",predictions[i],");",sep = "")
  dbSendQuery(mydb, queryStr)
}

queryStr = paste("update datasetrepresentation set status='successful' where id=",datasetrepresentation,";",sep = "")
dbSendQuery(mydb, queryStr)

queryStr = paste("update experiment set status='successful' where id=",experiment,";",sep = "")
dbSendQuery(mydb, queryStr)

# Header for topic model

line <- ""
topic.model.header <- colnames(result.topics)
for (j in 1:length(topic.model.header)){
  line <- paste(line,",",topic.model.header[j])
}
queryStr = paste("Insert into ldadata(datasetRepresentation,experiment,topic,model,coefficient) values(",datasetrepresentation,",",experiment,",'N/A','",line,"',0.0);",sep = "")
dbSendQuery(mydb, queryStr)


for (i in 1:length(coefs)){
  line <- ""
  current.result.topic <- result.topics[i,]
  for (j in 1:length(current.result.topic)){
    line <- paste(line,",",current.result.topic[j])
  }
  queryStr = paste("Insert into ldadata(datasetRepresentation,experiment,topic,model,coefficient) values(",datasetrepresentation,",",experiment,",'",annotations.levels[i],"','",line,"',",coefs[i],");",sep = "")
  dbSendQuery(mydb, queryStr)
}


###################################################################################################################


