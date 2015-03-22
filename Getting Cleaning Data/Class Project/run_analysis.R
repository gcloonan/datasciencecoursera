##Setup work: file download, path creation, package load, etc.
library(dplyr)
library(knitr)
library(markdown)
setwd("C:/Users/gregory.j.cloonan/Documents/Data Science Class/Getting Cleaning Data/Class Project")
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "wearabledata.zip")
unzip("wearabledata.zip")
fp <- file.path("./UCI HAR Dataset")

##Reading in germane data frames
df.subject.train <- read.table(file.path(fp, "train", "subject_train.txt"), header = F)
df.subject.test <- read.table(file.path(fp, "test", "subject_test.txt"), header = F)
df.activity.train <- read.table(file.path(fp, "train", "Y_train.txt"), header = F)
df.activity.test <- read.table(file.path(fp, "test", "Y_test.txt"), header = F)
df.features.train <- read.table(file.path(fp, "train", "X_train.txt"), header = F)
df.features.test <- read.table(file.path(fp, "test", "X_test.txt"), header = F)
feature.names <- read.table(file.path(fp, "features.txt"), header = F)
activity.names <- read.table(file.path(fp, "activity_labels.txt"), header = F)

##Merging training & testing data sets
df.subject <- rbind(df.subject.train, df.subject.test)
df.activity <- rbind(df.activity.train, df.activity.test)
df.features <- rbind(df.features.train, df.features.test)

##Renaming variables
df.subject <- rename(df.subject, subject = V1)
df.activity <- rename(df.activity, activity = V1)
names(df.features) <- feature.names$V2

##Merging all into one data set
df.combined <- cbind(df.features, df.subject, df.activity)

##Subsetting our combined data set by mean and std variables only
sub.feature.names <- as.character(feature.names$V2[grep("mean\\(\\)|std\\(\\)", feature.names$V2)])
sub.variables <- c(sub.feature.names, "subject", "activity")
sub.df.combined <- subset(df.combined, select = sub.variables)

##Replacing activity observations with more descriptive labels
names(activity.names) <- c("activity", "activity.desc")
sub.df.2 <- merge(sub.df.combined, activity.names, by = "activity", all.x = T)
sub.df.3 <- sub.df.2[2:69] %>% rename(activity = activity.desc)

##Using gsub to gives features more descriptive names
names(sub.df.3) <- gsub("Acc", "Accelerometer", names(sub.df.3))
names(sub.df.3) <- gsub("Gyro", "Gyroscope", names(sub.df.3))
names(sub.df.3) <- gsub("Mag", "Magnitude", names(sub.df.3))
names(sub.df.3) <- gsub("^t", "time", names(sub.df.3))
names(sub.df.3) <- gsub("^f", "frequency", names(sub.df.3))

##Creating tidy data set with subject & activity variable averages
tidy.df <- aggregate(. ~subject + activity, sub.df.3, mean)
tidy.df <- arrange(tidy.df, subject, activity)

##Finishing steps: publishing tidy data table & codebook
write.table(tidy.df, file = "tidydf.txt", row.name = F)
knit("run_analysis.R", output = "CodeBook.md", encoding = "ISO8859-1", quiet = T)
markdownToHTML("CodeBook.md", "CodeBook.html")