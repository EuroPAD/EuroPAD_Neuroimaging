library(R.matlab)
library(dplyr)

rm(list = ls(all = T))

atlasnames <- read.csv("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/atlases/Schaefer2018/Centroid_coordinates/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm.Centroid_RAS.csv")
atlasnames <- atlasnames[,2]

filelist = read.delim("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fastECM/list_fastECMstats.txt", header = F)
colnames(filelist) = "filename"

metrics = rownames(as.data.frame(data[[1]]))

df_list = list()
# for each metric
for (metric in seq(1,8)) {
  name = metrics[metric]
  # make a dataframe for that metric
  df_list[[name]] = data.frame(matrix(NA, length(filelist$filename), nrow(as.data.frame(data[[1]][metric]))))
  rownames(df_list[[name]]) = filelist$filename
  
  for (file in filelist$filename) {
    data = readMat(file)
    
    for (val in seq(1,nrow(as.data.frame(data[[1]][metric])))) {
      df_list[[name]][file,paste0("X",val)] = data[[1]][[metric]][[val]]
    }
  }
  
  if (nrow(as.data.frame(data[[1]][metric])) == 100) {
    colnames(df_list[[name]]) = atlasnames
  }
  
  for (row in rownames(df_list[[name]])) {
    str = row %>% strsplit(., "/")
    sub = str[[1]][[13]]
    ses = str[[1]][[14]]
    df_list[[name]][row,"sub"] = sub
    df_list[[name]][row,"ses"] = ses
  }
  
  df_list[[name]] = df_list[[name]] %>%
    select(sub, ses, everything())
  rownames(df_list[[name]]) = NULL
  
  write.csv(df_list[[name]], 
            file = paste0("/home/radv/lpieperhoff/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fastECM/fastECMstats_",name,".csv"), 
            row.names = F)
}


# OLD
fastECM = data.frame(matrix(NA, length(filelist$filename), 100))

rownames(fastECM) = filelist$filename

for (file in filelist$filename) {
  data = readMat(file)
  
  for (val in seq(1,100)) {
    fastECM[file,paste0("X",val)] = data[[1]][[1]][[val]]
  }
}

atlasnames <- read.csv("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/atlases/Schaefer2018/Centroid_coordinates/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm.Centroid_RAS.csv")
atlasnames <- atlasnames[,2]
colnames(fastECM) = atlasnames

for (row in rownames(fastECM)) {
  str = row %>% strsplit(., "/")
  sub = str[[1]][[13]]
  ses = str[[1]][[14]]
  fastECM[row,"SubjID"] = sub
  fastECM[row,"Ses"] = ses
}

fastECM = fastECM %>%
  select(SubjID, Ses, everything())
rownames(fastECM) = NULL

write.csv(fastECM, file = "/home/radv/lpieperhoff/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fastECM/fastECM.csv", row.names = F)
