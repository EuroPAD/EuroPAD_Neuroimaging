#!/usr/bin/env python3

"""
Script to extract graph properties (as .csv file)
Connectome input has to be in .csv format

Created by Luigi Lorenzini
"""

# Import libraries
import numpy as np
import pandas as pd
import scipy
from scipy.linalg import block_diag
import bct
import os
import matplotlib.pyplot as plt
import glob
from nilearn import plotting 
import sys


# Define data

#bidsdir="/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD"
filelist=sys.argv[1]
# opening the file in read mode 
my_file = open(filelist, "r") 
  
# reading the file 
data = my_file.read() 

data_list = data.split("\n")

atlas_info = pd.read_csv("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/Schaefer2018_100Parcels_7Networks_order.txt", sep = '\t', header=None).to_numpy() # Scheafer 100 is used
area_names = atlas_info[:,1]
datadir =os.path.dirname(data_list[0])

## THRESHOLD SET UP
threshold=0.5
str(threshold)

resultdir = os.path.join(datadir, "Graph_Properties_" + str(threshold))


if not os.path.exists(resultdir):
    os.makedirs(resultdir)

    
metrics = ["ID", "visit", "density","nVertices","nEdges","avgStrength", "avgBetweenness","avgClustering","charPath","small_world_coef","Gamma","Lambda" ]



# For participation coefficient  and network strengths
netlabels = pd.read_csv("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/Schaeffer_Networks_labels.txt", sep = '\t', header=None)
netnum = [1,2,3,4,5,6,7]
netname = ["Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"]
netlabels_rc = netlabels.replace(netname, netnum)


### Other settings
richclubnames=["K_raw_15", "K_raw_16", "K_raw_17", "K_raw_18", "K_raw_19", "K_raw_20","K_raw_21", "K_raw_22", "K_raw_23", "K_raw_24","K_raw_25", "K_norm_15", "K_norm_16", "K_norm_17", "K_norm_18", "K_norm_19",  "K_norm_20","K_norm_21", "K_norm_22",   "K_norm_23", "K_norm_24","K_norm_25"]


# Dictionaries are used to define and save data
global_prop = {}
reg_prop = {}
allnetsdf = {}  # to store strenght of within network connections

global_prop["fc"] = []
reg_prop["fc_RSN_strengths"] = []
reg_prop["fc_strength"] = []
reg_prop["fc_btwness"] = []
reg_prop["fc_clust"] = []
reg_prop["fc_participation"] = []
reg_prop["fc_richclub"]= []  # rich club is not regional but per k-level, but we store it in the regional dataset as its many values
    
for subpath in data_list:   # Iterate across subjects 

    subname = os.path.basename(subpath)
    print(subname)
    
    if subpath == "":
        continue 
    
    for sesfold in glob.glob(os.path.join(subpath, '*ses*')):  # Iterate across session
        
        ses = os.path.basename(sesfold)  ## Name of Session
        
        if os.path.exists(os.path.join(resultdir, subname, ses)):
            print("Graph properties already computed for subject " + subname + " for session " + ses  + " delete output folder to rerun  \n \nGoing to the next subject/session")
            continue
        else :
            os.makedirs(os.path.join(resultdir, subname, ses))
            
            
        
        
        
        ## Specify connectome locations
        #connectomes = {}
        
        
        cc = glob.glob(os.path.join(datadir, subname, ses, "dwi","extra_connectomes",  subname + "_" + ses + "_space-T1w_desc-preproc_desc-schaefer100nosubcortical_atlas_sift_radius2_count_connectome.csv"))
     
        if cc:
            print(f"Now processing {cc}")
            connMat = np.genfromtxt(cc[0], delimiter=',')
#plotting.plot_matrix(connMat, vmax = 10, vmin = 0, colorbar = True)
            
            connMat=np.log10(connMat) #log 10 structural connectivity
            connMat[np.isinf(connMat)] = 0


            # Remove all self-self connections
            connMat[np.diag_indices_from(connMat)] = 0


            # Matrix Thresholding
            nonbin_connMat=bct.threshold_proportional(connMat, threshold)
            thr_connMat = bct.threshold_proportional(connMat, threshold) # same thing but just different name for further processing
            thr_connMat[thr_connMat>0] = 1
#plotting.plot_matrix(nonbin_connMat, vmax = 10, vmin = 0, colorbar = True)
#plotting.plot_matrix(thr_connMat, vmax = 1, vmin = 0, colorbar = True)

            # SVD Normalization
#            u,s,v = scipy.linalg.svd(connMat)
#            sScaled = (10/s[0])*s
#            s_mt = np.diag(sScaled)
#            norm_connMat = u @  s_mt @ v

            ### Graph properties
            [density,nVertices,nEdges] = bct.density_und(nonbin_connMat)

            # Regional measures
            reg_strength = bct.strengths_und_sign(nonbin_connMat) ## Compute on non binary matrix
            reg_betweenness = bct.betweenness_bin(nonbin_connMat)
            reg_clust = bct.clustering_coef_wu(nonbin_connMat)

            # Global measures
            avgStrength = np.mean(reg_strength[0])
            avgBtwness = np.mean(reg_betweenness)
            avgClus = np.mean(reg_clust)
            cPathGraph = bct.charpath(connMat)[0] # characteristic path length is computed on non thresholded

            ## Small worldness
            nRand = 50    # Amount of random graphs
            rewirePar = 100 # Average rewire per edge in randmio
            clusRand = np.zeros(nRand)
            cPathRand =  np.zeros(nRand)

            #Rich Club coefficient
            RC = bct.rich_club_bu(thr_connMat)  # rich club is done on binary matrix
            RCraw = RC[0][14:25]
            
            # Create a random graph with similair properties
            for i in range(nRand):
                # [randMat,eff] = bct.randmio_und(thr_connMat,rewirePar)
                randMat = bct.randmio_und(nonbin_connMat,rewirePar)[0] # randomize the original matrix
                clusRand[i] = np.mean(bct.clustering_coef_wu(randMat))
                cPathRand[i] = bct.charpath(randMat)[0]
                RCrand = bct.rich_club_bu(randMat)  # check for what to extract from rich club
                RCrawrand = RCrand[0][14:25]


            # Calculate small worldness
            Gamma = avgClus/np.mean(clusRand) # Gamma
            Lambda = cPathGraph/np.mean(cPathRand) # Lambda
            SWcoef = Gamma/Lambda # small-word coefficient
            
            # Calculate normalized richclub 
            RCnorm = RCraw/RCrawrand
            
            # participation coefficient
            reg_pt = bct.participation_coef(thr_connMat, netlabels_rc)
            
            
           
             # mean strenght  RSN (non binarized)
            nplab = netlabels.to_numpy
            allnets = []#{}
            netstrengthnames = []
            for net in netname:
                netind=netlabels.loc[netlabels[0] == net].index
                
                for net2 in netname:
#                print(netarea_names) 
                #allnets[net] = []
                    netind2=netlabels.loc[netlabels[0] == net2].index
                    
                    netconn = nonbin_connMat[np.ix_(netind, netind2)] # Extract a submatrix
                    netstrength = np.mean(netconn)
                    allnets = np.append(allnets, netstrength)
                    
                    netstrengthnames = np.append(netstrengthnames, net + '_To_' + net2)
                #allnets[net] = netstrength
                
            ## Save properties for each subject
           
            # Global
            glob_DF = pd.DataFrame([subname,ses,density,nVertices,nEdges,avgStrength,avgBtwness,avgClus,cPathGraph,SWcoef,Gamma,Lambda])
            glob_DF = pd.DataFrame.transpose(glob_DF)
            glob_DF.columns = metrics
            glob_DF.to_csv(os.path.join(os.path.join(resultdir, subname, ses, subname + "_global_graph_properties.csv"))) # Save as .csv
            
            # RSN strength
            rsnstrength = pd.DataFrame(np.append(subname, np.append(ses,allnets)))
            rsnstrength = pd.DataFrame.transpose(rsnstrength)
            rsnstrength.columns = np.append("ID", np.append("visit", netstrengthnames))
            rsnstrength.to_csv(os.path.join(os.path.join(resultdir, subname, ses, subname + "_RSN_Strengths.csv"))) # Save as .csv

            # Local strength
            localstrength = pd.DataFrame(np.append(subname, np.append(ses,reg_strength[0])))
            localstrength = pd.DataFrame.transpose(localstrength)
            localstrength.columns = np.append("ID", np.append("visit", area_names))
            localstrength.to_csv(os.path.join(os.path.join(resultdir, subname, ses, subname + "_local_Strengths.csv"))) # Save as .csv

            # Local betweenness
            localbtw = pd.DataFrame(np.append(subname, np.append(ses,reg_betweenness)))
            localbtw = pd.DataFrame.transpose(localbtw)
            localbtw.columns = np.append("ID", np.append("visit", area_names))
            localbtw.to_csv(os.path.join(os.path.join(resultdir, subname, ses, subname + "_local_Betwennes.csv"))) # Save as .csv

            # Local clust
            localclust = pd.DataFrame(np.append(subname,np.append(ses,reg_clust)))
            localclust = pd.DataFrame.transpose(localclust)
            localclust.columns = np.append("ID", np.append("visit", area_names))
            localclust.to_csv(os.path.join(os.path.join(resultdir, subname, ses, subname + "_local_clust.csv"))) # Save as .csv

            # Local participation
            localpart = pd.DataFrame(np.append(subname,np.append(ses, reg_pt)))
            localpart = pd.DataFrame.transpose(localpart)
            localpart.columns = np.append("ID",np.append("visit", area_names))
            localpart.to_csv(os.path.join(os.path.join(resultdir, subname, ses, subname + "_local_participation.csv"))) # Save as .csv
             
             # Rich club
            richclub = pd.DataFrame(np.append(subname, np.append(np.append(ses, RCraw), RCnorm)))
            richclub = pd.DataFrame.transpose(richclub)
            richclub.columns = np.append("ID", np.append("visit", richclubnames))
            richclub.to_csv(os.path.join(os.path.join(resultdir, subname, ses, subname + "_rich_club.csv"))) # Save as .csv

            
### Second step: Concatenate all the results

print(" Saving Group Datasets")

## Do netstrengthnames again
netstrengthnames = []
for net in netname:
	netind=netlabels.loc[netlabels[0] == net].index

	for net2 in netname:

		netind2=netlabels.loc[netlabels[0] == net2].index                   
		netstrengthnames = np.append(netstrengthnames, net + '_To_' + net2)

# Create empty dataframes
glob_DF=pd.DataFrame(columns=metrics)
rsnstrength = pd.DataFrame(columns = np.append("ID", np.append("visit", netstrengthnames)))
localstrength = pd.DataFrame(columns = np.append("ID", np.append("visit", area_names)))
localbtw = pd.DataFrame(columns = np.append("ID", np.append("visit", area_names)))
localclust = pd.DataFrame(columns = np.append("ID", np.append("visit", area_names)))
localpart = pd.DataFrame(columns = np.append("ID",np.append("visit", area_names)))
richclub = pd.DataFrame(columns = np.append("ID", np.append("visit", richclubnames)))


# Iterate and append
for subname in os.listdir(resultdir): 
    if not subname.startswith("sub"):
        continue
     
    # Iterate across session
    for sesfold in glob.glob(os.path.join(resultdir, subname, '*ses*')): 
        
        ses = os.path.basename(sesfold)  ## Name of Session
        if os.path.exists(os.path.join(resultdir,subname, ses, subname + "_global_graph_properties.csv")):
            # Global metrics  
            globsubdf = pd.read_csv(os.path.join(resultdir,subname, ses, subname + "_global_graph_properties.csv"))
            glob_DF = pd.concat([glob_DF, globsubdf])
            
            # RSN strenght
            rsnstrsubdf = pd.read_csv(os.path.join(resultdir,subname, ses, subname + "_RSN_Strengths.csv"))
            rsnstrength = pd.concat([rsnstrength, rsnstrsubdf])

            # Local strength
            lclstrsubdf = pd.read_csv(os.path.join(resultdir,subname, ses, subname + "_local_Strengths.csv"))
            localstrength = pd.concat([localstrength, lclstrsubdf])

            # Local Betweenness
            btwsubdf = pd.read_csv(os.path.join(resultdir,subname, ses, subname + "_local_Betwennes.csv"))
            localbtw = pd.concat([localbtw, btwsubdf])

            # Local Clustering 
            clstsubdf = pd.read_csv(os.path.join(resultdir,subname, ses, subname + "_local_clust.csv"))
            localclust = pd.concat([localclust, clstsubdf])

            # local Participation Coefficient
            pcsubdf = pd.read_csv(os.path.join(resultdir,subname, ses, subname + "_local_participation.csv"))
            localpart = pd.concat([localpart, pcsubdf])

            # Rich club
            rcsubdf = pd.read_csv(os.path.join(resultdir,subname, ses, subname + "_rich_club.csv"))
            richclub = pd.concat([richclub, rcsubdf])

# Export results

    glob_DF.to_csv(os.path.join(resultdir, "global_graph_properties_" + str(threshold) + ".csv")) # Save as .csv
    rsnstrength.to_csv(os.path.join(resultdir, "RSN_strengths_" + str(threshold) + ".csv"))
    localstrength.to_csv(os.path.join(resultdir, "local_strength_" + str(threshold) + ".csv"))
    localbtw.to_csv(os.path.join(resultdir, "local_betweenness_" + str(threshold) + ".csv"))
    localclust.to_csv(os.path.join(resultdir, "local_clustering_" + str(threshold) + ".csv"))
    localpart.to_csv(os.path.join(resultdir, "local_participation_" + str(threshold) + ".csv"))
    richclub.to_csv(os.path.join(resultdir, "RichClub_" + str(threshold) + ".csv"))

# for mod in modalities:
#     glob_DF = pd.DataFrame(global_prop[mod])
#     glob_DF.columns = metrics
#     glob_DF.to_csv(os.path.join(resultdir, mod + "_graph_properties.csv")) # Save as .csv

#     # Regional
#     RSN_strengths_DF = pd.DataFrame(reg_prop[mod + "_RSN_strengths"], columns = np.append("ID", netname))
#     RSN_strengths_DF.to_csv(os.path.join(resultdir, mod + "_RSN_strengths.csv"))
#     strength_DF = pd.DataFrame(reg_prop[mod + "_strength"], columns = np.append("ID", area_names))
#     strength_DF.to_csv(os.path.join(resultdir, mod + "_reg_strength.csv"))
#     btwness_DF = pd.DataFrame(reg_prop[mod + "_btwness"], columns = np.append("ID", area_names))
#     btwness_DF.to_csv(os.path.join(resultdir, mod + "_reg_betweenness.csv"))
#     clust_DF = pd.DataFrame(reg_prop[mod + "_clust"], columns = np.append("ID", area_names))
#     clust_DF.to_csv(os.path.join(resultdir, mod + "_reg_clustering.csv"))
#     part_DF = pd.DataFrame(reg_prop[mod + "_participation"], columns = np.append("ID", area_names))
#     part_DF.to_csv(os.path.join(resultdir, mod + "_reg_participation.csv"))
#     RC_DF = pd.DataFrame(reg_prop[mod + "_richclub"], columns = np.append("ID", richclubnames))
#     RC_DF.to_csv(os.path.join(resultdir, mod + "_RichClub.csv"))

# print(f"Process finished: graph properties saved to {datadir}")

