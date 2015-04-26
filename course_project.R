# Load data
tr_subject<-read.table("UCI HAR Dataset/train/subject_train.txt", header=T)
tr_set<-read.table("UCI HAR Dataset/train/X_train.txt", header=T)
tr_labels<-read.table("UCI HAR Dataset/train/y_train.txt", header=T)

test_subject<-read.table("UCI HAR Dataset/test/subject_test.txt", header=T)
test_set<-read.table("UCI HAR Dataset/test/X_test.txt", header=T)
test_labels<-read.table("UCI HAR Dataset/test/y_test.txt", header=T)

features<-read.table("UCI HAR Dataset/features.txt")

# Step 1. Merge test and training sets.
names(tr_subject)<-names(test_subject)
total_subject<-rbind(tr_subject,test_subject)
total_labels<-rbind(tr_labels, test_labels)
names(test_set)<-names(tr_set)
total_set<-rbind(tr_set, test_set) 

# Fix names in total set
colnames(total_set)<-features[,2]
head(names(total_set))

# Step 2. Extract only mean and SD for each measurement
mean_std<-grep ("mean|std",names(total_set))
total_set<-total_set[,mean_std]

#Add activities and subjects data
total<-cbind(total_subject,total_labels,total_set)
names(total)[1]<-"Subject"
names(total)[2]<-"Condition"

# Step 3. Uses descriptive activity names to name the activities in the data set

activities<-read.table("UCI HAR Dataset/activity_labels.txt")
activities[,2]
total[,2]<-as.factor(total[,2])
levels (total[,2])<-activities[,2]
levels (total[,2])

# Step 4. Appropriately labels the data set with descriptive variable names. 
nms<-names(total)

nms<-gsub("\\-mean\\(\\)","Mean", nms)
nms<-gsub("\\-std\\(\\)","StDev", nms)
nms<-gsub("\\-meanFreq\\(\\)","MeanFreq", nms)
nms<-gsub("\\-","", nms)
nms<-gsub("Acc","Acceleration", nms)
nms<-gsub("Mag","Magnitude", nms)

names(total)<-nms

# Step 5. From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject.

library(dplyr)
total_groups<-group_by(total,Condition, Subject)
tidied<-summarise_each(total_groups,funs(mean))

write.table(tidied, file="tidied_data.txt", sep=" ",row.name=F)
