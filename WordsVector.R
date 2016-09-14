
library(RTextTools)

inputFile <- "D:/GIT/ReutersXMLToCSV/DataSamples/reut2-005.csv"
dataSize <- 526
trainSize <- 400
testSize <- 126


dataSet = read.csv(inputFile)  # read csv file 

matrix <- create_matrix(dataSet$text, language="english",
                        removeNumbers=TRUE, stemWords=TRUE, removeStopwords=TRUE, 
                          stripWhitespace=TRUE, toLower=TRUE, weighting=tm::weightTfIdf)

matrixNoTFIDF <- create_matrix(dataSet$text, language="english",
                        removeNumbers=TRUE, stemWords=TRUE, removeStopwords=TRUE, 
                        stripWhitespace=TRUE, toLower=TRUE)

container <- create_container(matrix,dataSet$class,trainSize=1:trainSize, testSize=(trainSize+1):dataSize,
                              virgin=FALSE)

write.csv(matrix, file = "test.csv")


