# BITeam

Epilepsy Genomics Insights and Translational Bioinformatics Team 

Welcome to the Epilepsy Genomics Bioinformatics Team repository. This central hub outlines our core focus areas, methodologies, and engineering workflows. Our mission is to leverage large-scale genomic, statistical, and multi-omic data to uncover the genetic architecture of epilepsy, discover novel risk loci, and translate these findings into precision medicine strategies.

🧬 1. Population Genomics

Our population genomics framework aims to characterize the landscape of genetic variation across diverse cohorts to understand subphenotype distribution, ancestral differences, and the evolutionary constraints of epilepsy risk genes.  
• Cohort Harmonization: Standardizing phenotypic data across massive multi-site datasets (e.g., UK Biobank, Epi25 Consortium, GEL).  
• Ancestry & Population Structure: Utilizing PCA, UMAP, and local ancestry inference (e.g., RFMix) to account for population stratification in diverse cohorts.  
• Variant Curation: Filtering and prioritizing rare variants (SNVs, Indels, and SVs) utilizing gnomAD, ClinVar, and epilepsy-specific databases.  

📊 2. Statistical Genetics

We apply rigorous statistical frameworks to discover casual genetic variants, calculate genetic risk, and understand the heritability of different epilepsy syndromes.  
• Association Mapping:  
	• Running Large-scale GWAS using PLINK 2.0 and SAIGE to handle sample relatedness and case-control imbalance.  
	• Performing gene-based burden tests (e.g., SKAT) for assessing the effect of rare variants.  
• Polygenic Risk Scores (PRS): Constructing and validating PRS using tools like PRSIce or LDpred2 to model polygenic susceptibility and evaluate subphenotype cross-predictability.  
• Heritability Estimation: Estimating SNP-heritability (h²) and genetic correlation across comorbidities via LD Score Regression (LDSC).  
• Fine-mapping & Colocalization: Pinpointing causal variants within risk loci for functional colocalization.  

🔬 3. Multiomics Integration.  

Epilepsy is a complex network disease. Go look beyond DNA sequence variation, we integrate functional layers to understand the molecular mechanisms underlying network hyperexcitability.  
• Transcriptomics (RNA-Seq): Bulk and single-nucleus RNA-seq (snRNA-seq) processing to identify differential gene expression (DGE) in resected human brain tissue or iPSC-derived neurons.  
• Epigenomics (ATAC-Seq / Methylation): Mapping open chromatin regions and DNA methylation patterns to evaluate the impact of non-coding risk variants on cell-type-specific enhancers.  
• Network & Multiomic Integration: Employing WGCNA, MOGONET, or MOFA+ to build multi-layered molecular networks, bridging the gap between non-coding genetic variants and cellular phenotypes.  

🛠️ 4. Pipeline Development for PopGen Projects. 

To handle petabyte-scale data efficiently, reproducibly, and securely, we enforce modern HPC development standards.  

Infrastructure & Orchestration. 

• Workflow Managers: All production pipelines must be written in Nextflow (DSL2) or Snakemake.  
• Containerization: Every pipeline step must run inside a Docker or Singularity/Apptainer container.  
• Compute Environments: Architected for deployment across local SGE HPC clusters.  

Core Pipelines are available upon request. 

