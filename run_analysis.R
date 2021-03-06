
## set proper workding directory
setwd("~/Desktop/Coursera/GettingAndCleaningData/Project")

## Load the packages "reshape2"
library(reshape2)

## set the download, URL, and unzip file name
downloadFile <- "data/getdata_dataset.zip"
downloadURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

## set variables for URL, file and download locations
trainXFile <- "./UCI HAR Dataset/train/X_train.txt"
trainLabels <- "./UCI HAR Dataset/train/y_train.txt"
trainSubjectFile <- "./UCI HAR Dataset/train/subject_train.txt"
testXFile <- "./UCI HAR Dataset/test/X_test.txt"
testLabels <- "./UCI HAR Dataset/test/y_test.txt"
testSubjectFile <- "./UCI HAR Dataset/test/subject_test.txt"

## create folder if not already exists
if(!file.exists("./data")) { dir.create("./data")}
if (!file.exists(downloadFile)) {
  download.file(downloadURL, downloadFile, method = "curl");
  unzip(downloadFile, overwrite = T, exdir = ".")
}

## Load activity labels - Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("./UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

## Load the data sets
train <- read.table("./UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)
test <- read.table("./UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

## merge train and test data sets and add thier labels
combinedData <- rbind(train, test)
colnames(combinedData) <- c("subject", "activity", featuresWanted.names)

## turn activities & subjects into factors
combinedData$activity <- factor(combinedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
combinedData$subject <- as.factor(combinedData$subject)
combinedData.melted <- melt(combinedData, id = c("subject", "activity"))
combinedData.mean <- dcast(combinedData.melted, subject + activity ~ variable, mean)

## Write out the tidy data set
write.table(combinedData.mean, "tidy.txt", row.names=FALSE, quote=FALSE)