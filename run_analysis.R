#--------------------------------------------------------------------------
# Load the data from files
#--------------------------------------------------------------------------
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt", header=F)
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", header=F)
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt", header=F)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", header=F)
subj_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", header=F)
subj_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", header=F)
features <- read.table("./UCI HAR Dataset/features.txt", header=F)

names(X_train) <- features[,2]
names(X_test) <- features[,2]
names(y_train) <- "activity"
names(y_test) <- "activity"
names(subj_train) <- "subject"
names(subj_test) <- "subject"

#--------------------------------------------------------------------------
# 1. Merge the training and test sets to create one dataset
#--------------------------------------------------------------------------
X <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)
subj <- rbind(subj_train, subj_test)
data <- cbind(subj, y, X)

#--------------------------------------------------------------------------
# 2. Extract only the mean and standard deviation columns
#--------------------------------------------------------------------------
data <- data[,c(1, 2, grep("mean()|std()",names(data)))]

#--------------------------------------------------------------------------
# 3. Use descriptive activity names
#--------------------------------------------------------------------------
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header=F)
activityName <- data$activity
for (i in 1:nrow(activity_labels)) {
    activityName[data$activity == i] = as.character(activity_labels[i,2])
}
data <- cbind(activityName, data)

# Drop the original activity column
data$activity <- NULL

#--------------------------------------------------------------------------
# 4. Label the data set with descriptive variable names
#--------------------------------------------------------------------------
# Create descriptive variable names
vars <- names(data)
nvars <- c("activityName", "subject", rep("", length(vars)-2))
acci <- grep("Acc", vars)
gyroi <- grep("Gyro", vars)
nvars[acci] <- paste("from the accelometer", nvars[acci])
nvars[gyroi] <- paste("from the gyroscope", nvars[gyroi])
xi <- grep("-X", vars)
yi <- grep("-Y", vars)
zi <- grep("-Z", vars)
nvars[xi] <- paste("on the X axis", nvars[xi])
nvars[yi] <- paste("on the Y axis", nvars[yi])
nvars[zi] <- paste("on the Z axis", nvars[zi])
bi <- grep("Body", vars)
gi <- grep("Gravity", vars)
nvars[bi] <- paste("the Body", nvars[bi])
nvars[gi] <- paste("the Gravity", nvars[gi])
ji <- grep("Jerk", vars)
nvars[ji] <- paste("the Jerk of", nvars[ji])
magi <- grep("Mag", vars)
nvars[magi] <- paste("the Magnitude of", nvars[magi])
mi <- grep("mean()", vars)
si <- grep("std()", vars)
nvars[mi] <- paste("the mean of", nvars[mi])
nvars[si] <- paste("the standard deviation of", nvars[si])

# Rename variable names
names(data) <- nvars

#--------------------------------------------------------------------------
# 5. Create the second data set
#--------------------------------------------------------------------------
data2<-aggregate(data[,3:ncol(data)],
                 by=list(data$activityName, data$subject), FUN=mean)
names(data2)[1:2] = c("activityName", "subject")

# Save to the files
write.table(data, "./data.txt", row.name=FALSE)
write.table(data2, "./data2.txt", row.name=FALSE)
