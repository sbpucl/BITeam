# Storage File Path Search

## Overview

`1_search_file_paths.sh` is a Bash script designed to search and retrieve sequencing data file paths from a pre-generated master storage file index.

The script is useful for locating WGS/WES sequencing files, including BAM, FASTQ, VCF and GVCF files, stored across different directories within the `/SAN/neuroscience/` storage system.

Instead of scanning storage directories for every search, the script searches an existing master file containing full file paths, making searches faster and more efficient.

## 1. Features

- Searches multiple sample IDs or text strings in a single execution.
- Supports BAM, FASTQ, VCF and GVCF file types.
- Performs case-insensitive, fixed-string matching.
- Searches full file paths, including directory names.
- Removes duplicate and empty input entries.
- Supports both Unix and Windows-formatted input text files.
- Generates separate matched and unmatched results.
- Reports the total number of input strings, matched file paths and unmatched strings.
- Does not modify, move or delete sequencing data files.

## 2. Requirements

- Linux operating system
- Bash shell
- GNU `grep`, `sed`, `sort` and standard Unix utilities
- Read access to the master storage file index
- Write access to the output directory

No additional software installation is required.

## 3. Script and File Locations

**Script:**

```bash
/SAN/neuroscience/proj-863_vcf/ravimore/files_database/out/storage_files/full_paths/1_search_file_paths.sh
```

**Master file index:**

```bash
/SAN/neuroscience/proj-863_vcf/ravimore/files_database/out/storage_files/full_paths/ALL_STORAGE_MASTER_PATHS.txt
```

**Output directory:**

```bash
/SAN/neuroscience/proj-863_vcf/ravimore/files_database/out/storage_files/full_paths/search_results/
```

The master index must contain one absolute file path per line.

## 4. Input File

The script accepts a plain-text file containing sample IDs or search strings.

**Example: `2_input_strings.txt`**

```text
A3869309
A3872140
SMS104484
SMS104231
0340236392
EPI00397
T8288-4
```

Each search string must be provided on a separate line.

## 5. Supported File Types

| Argument | Files searched |
|---|---|
| `fastq` | `.fastq`, `.fastq.gz`, `.fq`, `.fq.gz` |
| `fastq.gz` | `.fastq.gz`, `.fq.gz` |
| `bam` | `.bam` |
| `vcf` | `.vcf` |
| `vcf.gz` | `.vcf.gz`, including `.g.vcf.gz` |
| `g.vcf.gz` | `.g.vcf.gz` |
| `all` | All file extensions |

**Note:** `recalibrated.bam` is listed as an accepted argument in the supplied script, but its filtering rule is missing. It should not be used until that rule has been added.

## 6. Usage

**Command syntax:**

```bash
bash 1_search_file_paths.sh <input_file.txt> <filetype>
```

**Example: Search BAM files**

```bash
bash 1_search_file_paths.sh 2_input_strings.txt bam
```

**Example: Search FASTQ files**

```bash
bash 1_search_file_paths.sh 2_input_strings.txt fastq
```

**Example: Search compressed VCF files**

```bash
bash 1_search_file_paths.sh 2_input_strings.txt vcf.gz
```

**Example: Search GVCF files**

```bash
bash 1_search_file_paths.sh 2_input_strings.txt g.vcf.gz
```

**Example: Search all file types**

```bash
bash 1_search_file_paths.sh 2_input_strings.txt all
```

**Run using absolute paths:**

```bash
bash /SAN/neuroscience/proj-863_vcf/ravimore/files_database/out/storage_files/full_paths/1_search_file_paths.sh \
/SAN/neuroscience/proj-863_vcf/ravimore/files_database/out/storage_files/full_paths/2_input_strings.txt \
bam
```

To measure execution time:

```bash
time bash 1_search_file_paths.sh 2_input_strings.txt bam
```

## 7. Output Files

The script generates two output files in the `search_results/` directory.

### 7.1 Matched file paths

Filename:

```text
2_input_strings_bam_matched.txt
```

Contains complete paths for files matching at least one input string and the selected file type.

Example:

```text
/SAN/neuroscience/proj-863_bam/A3869309.recalibrated.bam
/SAN/neuroscience/DRAVET_F_fin/SMS104484.realigned.recalibrated.bam
/SAN/neuroscience/DRAVET_B_raw/0340236392.realigned.recalibrated.bam
/SAN/neuroscience/proj-789_bam/EPI00397.realigned.recalibrated.bam
```

A sample may have multiple matching file paths.

### 7.2 Unmatched input strings

Filename:

```text
2_input_strings_bam_not_matched.txt
```

Contains the input strings for which no matching path with the selected file type was found.

Example:

```text
SAMPLE001
SAMPLE002
```

## 8. Example Terminal Summary

The script prints a summary upon completion.

```text
--------------------------------------
Storage search completed
--------------------------------------
Input file         : 2_input_strings.txt
File type          : bam
Total search IDs   : 100
Matched file paths : 85
Unmatched IDs      : 20

Matched output     : search_results/2_input_strings_bam_matched.txt
Not matched output : search_results/2_input_strings_bam_not_matched.txt
```

The number of matched file paths may differ from the number of matched sample IDs because one sample can match multiple files.

## 9. Search Methodology

The script performs the following operations:

1. Reads the input text file.
2. Removes empty lines, Windows carriage returns and duplicate strings.
3. Uses `grep -iFf` to search all strings against the master file index.
4. Filters matching paths by the specified file extension.
5. Writes the matching full paths to the matched output file.
6. Identifies input strings not found in the filtered results.
7. Prints a summary of the search.

The main search uses:

```bash
LC_ALL=C grep -iFf "$IDS" "$MASTER"
```

This approach avoids repeatedly scanning the master index for each individual input string.

## 10. Important Considerations

**Substring matching:** The script matches search strings anywhere within the full file path. For example, searching `SMS104484` will match any path containing that text, including directory names.

**File existence:** Results are obtained from the master index. A matched path does not guarantee that the file still exists on the storage system.

**Master index updates:** Newly created files will not be searchable until the master index has been updated.

**Output overwriting:** Running the script again with the same input filename and file type overwrites the previous results.

**Unmatched search performance:** The unmatched-ID check searches the matched output for each ID individually. This can be slower for very large input lists.

**File type filtering:** Selecting `vcf.gz` also includes GVCF files ending in `.g.vcf.gz`. The current script does not distinguish these automatically.

## 11. Verify Results

Count matching file paths:

```bash
wc -l search_results/2_input_strings_bam_matched.txt
```

Count unmatched input strings:

```bash
wc -l search_results/2_input_strings_bam_not_matched.txt
```

Display the first 20 matches:

```bash
head -20 search_results/2_input_strings_bam_matched.txt
```

Search for a specific sample:

```bash
grep -iF "SMS104484" search_results/2_input_strings_bam_matched.txt
```

Check whether matching files exist on disk:

```bash
while IFS= read -r file; do
    [[ -f "$file" ]] || printf 'MISSING: %s\n' "$file"
done < search_results/2_input_strings_bam_matched.txt
```

## 12. Applications

This utility can support bioinformatics workflows involving:

- Locating historical BAM and FASTQ files for WGS/WES reanalysis.
- Retrieving previously generated variant-calling output paths.
- Identifying missing sequencing files for sample cohorts.
- Preparing file manifests for downstream workflows.
- Checking sequencing data distribution across storage projects.
- Supporting data harmonisation and joint-genotyping preparation.

## 13. Limitations

The script searches an existing text-based file index and does not directly search the filesystem.

It does not validate file integrity, file permissions, sequencing quality, BAM indexes or VCF indexes.

Matched paths are returned as plain text; the script does not automatically copy or process the corresponding sequencing files.
