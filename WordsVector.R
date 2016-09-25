
library(RTextTools)
library(RMySQL)



args = commandArgs(trailingOnly=TRUE)

# if (length(args) < 0) {
#   stop("At least one argument must be supplied (input file).n", call.=FALSE)
# } else if (length(args)==1) {
#   # default output file
#   args[2] = "out.txt"
# }


representation <- 1
#datasetName <- "Oil-test"
datasetName <- "reuters-1" 


inputFile <- "D:/Documents/Dropbox/Tesis II - Seminario/DataSets/Reuters/reuters-1.csv"
#inputFile <- "D:/GIT/TextSimilarity/Data/Oil/OilTrain.csv"


dataSet = read.csv(inputFile)  # read csv file 

matrix <- create_matrix(dataSet$text, language="english",
                        removeNumbers=TRUE, stemWords=TRUE, removeStopwords=TRUE, 
                          stripWhitespace=TRUE, toLower=TRUE, weighting=tm::weightTfIdf)

matrixNoTFIDF <- create_matrix(dataSet$text, language="english",
                        removeNumbers=TRUE, stemWords=TRUE, removeStopwords=TRUE, 
                        stripWhitespace=TRUE, toLower=TRUE)


mat <- matrix(, nrow = matrix$nrow, ncol = matrix$ncol)

for (i in 1:length(matrix$i)){
  mat[matrix$i[i],matrix$j[i]] <- matrix$v[i]
}

dimnames(mat) = list( 
     matrix$dimnames$Docs,         # row names 
     matrix$dimnames$Terms) # column names 

matNoTFIDF <- matrix(, nrow = matrixNoTFIDF$nrow, ncol = matrixNoTFIDF$ncol)

for (i in 1:length(matrixNoTFIDF$i)){
  matNoTFIDF[matrixNoTFIDF$i[i],matrixNoTFIDF$j[i]] <- matrixNoTFIDF$v[i]
}

dimnames(matNoTFIDF) = list( 
  matrixNoTFIDF$dimnames$Docs,         # row names 
  matrixNoTFIDF$dimnames$Terms) # column names 

mydb = dbConnect(MySQL(), user='root', password='', dbname='TextSimilarity', host='localhost')

queryStr = paste("SELECT * FROM dataset WHERE name = '",datasetName,"';", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetId <- dat$id

queryStr = paste("Insert into datasetrepresentation(dataset,representation,description) values(",datasetId,",",representation,",'with TF-IDF');",sep = "")
dbSendQuery(mydb, queryStr)

queryStr = paste("SELECT MAX(id) as id FROM datasetrepresentation", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetrepresentation <- dat$id



for (i in 1:matrix$nrow){
    line <- matrix[i,0]
    for (j in 2:matrix$ncol){
      line <- paste(line,matrix[i,j],sep = ",")
    }
    queryStr = paste("Insert into document(datasetRepresentation,value) values(",datasetrepresentation,",'",line,"');",sep = "")
    dbSendQuery(mydb, queryStr)
}


queryStr = paste("Insert into datasetrepresentation(dataset,representation,description) values(",datasetId,",",representation,",'without TF-IDF');",sep = "")
dbSendQuery(mydb, queryStr)

queryStr = paste("SELECT MAX(id) as id FROM datasetrepresentation", sep="")
res <- dbSendQuery(mydb, queryStr)
dat <- dbFetch(res)

datasetrepresentation <- dat$id



for (i in 1:matrixNoTFIDF$nrow){
  line <- matrixNoTFIDF[i,0]
  for (j in 2:matrixNoTFIDF$ncol){
    line <- paste(line,matrixNoTFIDF[i,j],sep = ",")
  }
  queryStr = paste("Insert into document(datasetRepresentation,value) values(",datasetrepresentation,",'",line,"');",sep = "")
  dbSendQuery(mydb, queryStr)
}




