# Helper functions for burden testing

library(SKAT)
library(ggplot2)
library(pbapply)

##################################
#Flag cases with zero variants; retain cases with non-zero variants
# report the number variants in cases
# input files: plink FAM, SSD.Info
##################################

case_nonzero = function(Set_Index, SSD_INFO, fam_file){
  Z = Get_Genotypes_SSD(SSD_INFO, Set_Index, is_ID = TRUE)
  #add hits column to fam_file, yes for GT == 1 and no for GT == 0
  fam_file$hits = ifelse(fam_file$FID %in% fam_file$FID[which(rowSums(Z!= 0) == 1)], "yes", "no")
  #return gene or set index only if cases have non-zero variants; report the number of variants in cases
  if(sum(fam_file[fam_file$hits %in% "yes"]$Phenotype) > 0) {
    case_num = sum(fam_file[fam_file$hits %in% "yes"]$Phenotype)
    return(cbind.data.frame("set_ind" = Set_Index, "case_MAC" = case_num)) }
  else {return(NULL)}
}

# run example
test_genes = lapply(seq(1, SSD.INFO$nSets, 1), function(x) case_nonzero(x, SSD_INFO, fam_file))






