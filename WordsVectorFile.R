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


inputFile <- args[1]
datasetName <- args[2]
outputFolder <- args[3]
trainSize.original <- args[4]

trainSize <- as.double(trainSize.original)/100

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

line <- matrix$dimnames$Terms[1]
for (i in 2:matrix$ncol){
  line <- paste(line,matrix$dimnames$Terms[i],sep = ",")
}

dir.create(outputFolder)

train.file.path <- paste(outputFolder, datasetName,"-",trainSize.original, "-train.txt", sep = "")
file.create(train.file.path)
train.file<-file(train.file.path)

writeLines(c(line), train.file)

for (i in 1:matrix$nrow){
  line <- matrix[i,1]
  for (j in 2:matrix$ncol){
    line <- paste(line,matrix[i,j],sep = ",")
  }
  writeLines(c(line), train.file)
}

close(train.file)


line <- matrixTest$dimnames$Terms[1]
for (i in 2:matrixTest$ncol){
  line <- paste(line,matrixTest$dimnames$Terms[i],sep = ",")
}

test.file.path <- paste(outputFolder, datasetName, "-", trainSize.original, "-test.txt", sep = "")
file.create(test.file.path)
test.file<-file(test.file.path)

writeLines(c(line), test.file)

for (i in 1:matrixTest$nrow){
  line <- matrixTest[i,1]
  for (j in 2:matrixTest$ncol){
    line <- paste(line,matrixTest[i,j],sep = ",")
  }
  writeLines(c(line), test.file)
}

close(test.file)


sink()
