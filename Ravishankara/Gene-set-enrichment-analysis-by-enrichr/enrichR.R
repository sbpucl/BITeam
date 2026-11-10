# Intall and load the R library
install.packages("enrichr")
library(enrichR)

# Read the gene list
genes <- read.table("ID_AD_genes.txt",
                    header = FALSE,
                    stringsAsFactors = FALSE)$V1

# View the first few genes and count the genes
head(genes)
length(genes)

#  Retrieve available Enrichr databases
dbs <- listEnrichrDbs()

# Search for Reactome databases
grep("Reactome", dbs$libraryName, value = TRUE)

# Run pathway enrichment
reactome <- enrichr(genes, databases = c("Reactome_Pathways_2024"))

# Extract Reactome results
reactome_results <- reactome[["Reactome_Pathways_2024"]]

# View the top pathways
head(reactome_results)

# Keep significant pathways and Sort by significance
sig <- reactome_results[reactome_results$Adjusted.P.value < 0.05, ]
sig[order(sig$Adjusted.P.value), ]


# Save significant pathways
write.table(sig,
            "Reactome_enrichment_ID_AD_Genes.txt",
            sep = "\t",
            row.names = FALSE,
            quote = FALSE)
