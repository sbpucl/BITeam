# Helper functions for burden testing

library(SKAT)
library(ggplot2)
library(pbapply)

# Generate SSD_INFO file
gen_ssd_info = function(dir_path, plink_fil_nam, ssdfil_name){
  File.Bed <- paste0(dir_path, "plink_fil_nam", ".bed")
  File.Bim <- paste0(dir_path, "plink_fil_nam", ".bim")
  File.Fam <- paste0(dir_path, "plink_fil_nam", ".fam")
  File.SetID <- paste0(dir_path, "ssdfil_name", ".SetID") #modified SetID or new file
  File.SSD <- paste0(dir_path, "ssdfil_name", ".SSD")
  File.Info <- paste0(dir_path, "ssdfil_name", ".SSD.info")
  
  Generate_SSD_SetID(File.Bed, File.Bim, File.Fam, File.SetID, File.SSD, File.Info)
  
  SSD.INFO <- Open_SSD(File.SSD, File.Info)
  return(SSD.INFO)
}

##################################
#Function to combine genotype matrices from a geneset
# input files: genes_inp (character vector representing the geneset), SSD.Info
##################################

mat_geneset = function(genes_inp, SSD_INFO){
  set_indices = SSD_INFO$SetInfo[SSD_INFO$SetInfo$SetID %in% genes_inp,]$SetIndex
  mat_list = lapply(set_indices, function(x) Get_Genotypes_SSD(SSD_INFO, Set_Index=x, is_ID = TRUE))
  return(mat_comb = do.call("cbind", mat_list))
}


##################################
#Function to generate SNP weights from SetID file
# input files: genes_inp, anno_SetID (SetID file with CADD weights, different from original SetID)
##################################

ext_geneset_weights = function(dir_path, genes_inp, anno_file_setid){
  tab_wt = read.delim(paste0(dir_path, anno_file_setid), sep = "\t", header = T, stringsAsFactors = F)
  
  CADD_wt_var = tab_wt[,c(1:3,10)]
  CADD_wt_var$CADD_PHRED = as.numeric(CADD_wt_var$CADD_PHRED)
  
  CADD_wt_var$CADD_PHRED[is.na(CADD_wt_var$CADD_PHRED)] <- 0
  #Assign Maximum score to PTV not scored by CADD
  CADD_wt_var$CADD_PHRED = ifelse(grepl("frameshift", CADD_wt_var$CADD_PHRED, ignore.case = T),
                                  max(CADD_wt_var$CADD_PHRED), CADD_wt_var$CADD_PHRED)
  CADD_wt_var = CADD_wt_var[CADD_wt_var$SYMBOL %in% genes_inp,]
  return(CADD_wt_var)
  
}


##################################
#Input file preparation for SKAT
##################################

#Step.1 Generate SSD.INFO file
SSD.INFO = gen_ssd_info(dir_path = dir_path, plink_fil_nam = plink_fil_nam, ssdfil_name = ssdfil_name)

#Step.2 Generate FAM file with Covariates
# Covariate file (tab separated) contains ancestry PCs and other nuisance variables
# Ensure the cases are set to 1 and controls to 0 in FAM$Phenotype
File.Fam <- paste0(dir_path, "plink_fil_nam", ".fam")
File.Cov = paste0(dir_path, "cov_fil_nam", ".cov")
FAM = Read_Plink_FAM_Cov(File.Fam, File.Cov, Is.binary = TRUE, cov_header = FALSE)

#Step.3 combine GT matrices from the genes input and add SNP weights 
geneset_mat = mat_geneset(genes_inp = genes_inp, SSD_INFO = SSD.INFO)

SNP_weights_sub = ext_geneset_weights(dir_path = dir_path, genes_inp = genes_inp, anno_file_setid = anno_file_setid)
SNP_weights_sub = SNP_weights_sub[match(colnames(geneset_mat), SNP_weights_sub$variation),]


#Step.4 Tests
obj = SKAT_Null_Model(Phenotype ~ Sex + Cov1 + Cov2, out_type = "D")

out.skat_burden_rob = SKATBinary_Robust(geneset_mat, obj, 
                                        weights = SNP_weights_sub$CADD_PHRED, 
                                        method = "Burden")

Close_SSD()


