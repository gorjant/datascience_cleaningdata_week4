library(reshape2)

# Ste my local work dir
setwd("/Users/gorjan/temp")

# IF file does not exist - download it and unzip it
if (!file.exists("getdata_dataset.zip")){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(url,"getdata_dataset.zip" , method="curl")
}  
if (!file.exists("UCI HAR Dataset")) 
{
  unzip(filename) 
}

# read files 
actl <- read.table("UCI HAR Dataset/activity_labels.txt")
actl[,2] <- as.character(actl[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# take data for mean and standard deviation
cleanfeat <- grep(".*std.*|.*mean.*", features[,2])
cleanfeat.names <- features[cleanfeat,2]
cleanfeat.names <- gsub('-std', 'Std', cleanfeat.names)
cleanfeat.names <- gsub('-mean', 'Mean', cleanfeat.names)
cleanfeat.names <- gsub('[-()]', '', cleanfeat.names)

# read datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[cleanfeat]
activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, activities, train)

# Concat the columns
tests<-read.table("UCI HAR Dataset/test/Y_test.txt")
test<-read.table("UCI HAR Dataset/test/X_test.txt")[cleanfeat]
tsubj<-read.table("UCI HAR Dataset/test/subject_test.txt")
test<-cbind(tsubj,tests,test)

# Connect Labels to datasets 
complete_data<-rbind(train, test)
colnames(complete_data) <- c("subjectid", "activity", cleanfeat.names)

# Make factors 
complete_data$activity <- factor(complete_data$activity, levels = actl[,1], labels = actl[,2])
complete_data$subject <- as.factor(complete_data$subject)
complete_data.melted <- melt(complete_data, id = c("subject", "activity"))
complete_data.mean <- dcast(complete_data.melted, subject + activity ~ variable, mean)
write.table(complete_data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
