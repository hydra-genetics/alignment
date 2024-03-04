# Softwares used in the alignment module

## [bwa_mem](https://github.com/lh3/bwa)
Align `.fastq` files to a reference genome and generate a `.bam` file.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__bwa__bwa_mem#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__bwa__bwa_mem#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__bwa_mem#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__bwa_mem#

---

## [bwa_mem_merge](http://www.htslib.org/doc/samtools-merge.html)
Merge `.bam` files from the same sample using samtools merge.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__bwa__bwa_mem_merge#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__bwa__bwa_mem_merge#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__bwa_mem_merge#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__bwa_mem_merge#

---

## [bwa_mem_realign_consensus_reads](https://github.com/lh3/bwa)
Realign after consensus read creation by fgbio_call_and_filter_consensus_reads and generate a `.bam` file.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__bwa__bwa_mem_realign_consensus_reads#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__bwa__bwa_mem_realign_consensus_reads#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__bwa_mem_realign_consensus_reads#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__bwa_mem_realign_consensus_reads#

---

## [fgbio_call_and_filter_consensus_reads](http://fulcrumgenomics.github.io/fgbio/tools/latest/)
Call and filter consensus reads based on umis using fgbio (CallDuplexConsensusReads followed by FilterConsensusReads)

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__fgbio__fgbio_call_and_filter_consensus_reads#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__fgbio__fgbio_call_and_filter_consensus_reads#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__fgbio_call_and_filter_consensus_reads#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__fgbio_call_and_filter_consensus_reads#

---

## [fgbio_group_reads_by_umi](http://fulcrumgenomics.github.io/fgbio/tools/latest/GroupReadsByUmi.html)
Group and sort reads based on umi using fgbio in preparation for fgbio_call_and_filter_consensus_reads. Also add mate pair MQ sam tags using samblaster.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__fgbio__fgbio_group_reads_by_umi#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__fgbio__fgbio_group_reads_by_umi#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__fgbio_group_reads_by_umi#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__fgbio_group_reads_by_umi#

---

## [fgbio_copy_umi_from_read_name](http://fulcrumgenomics.github.io/fgbio/tools/latest/CopyUmiFromReadName.html)
Copies the UMI at the end of the BAM’s read name to the RX tag using fgbio in preparation for fgbio_group_reads_by_umi

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__fgbio__fgbio_copy_umi_from_read_name#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__fgbio__fgbio_copy_umi_from_read_name#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__fgbio_copy_umi_from_read_name#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__fgbio_copy_umi_from_read_name#

---

## [picard mark duplicates](https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates)
Generate a bam file for a single chromosome with duplicates marked

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__picard__picard_mark_duplicates#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__picard__picard_mark_duplicates#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__picard_mark_duplicates#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__picard_mark_duplicates#

---

## [picard_mark_duplicates_non_chr](https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates)
Generate a bam file for a non-chromosomal contigs and unmapped reads with duplicates marked

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__picard__picard_mark_duplicates_non_chr#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__picard__picard_mark_duplicates_non_chr#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__picard_mark_duplicates_non_chr#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__picard_mark_duplicates_non_chr#

---

## [samtools_extract_reads](http://www.htslib.org/doc/samtools-view.html)
Extract reads from each chromosome and put into separate `.bam` files using samtools view.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__samtools__samtools_extract_reads#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__samtools__samtools_extract_reads#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__samtools_extract_reads#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__samtools_extract_reads#

---

## [samtools_extract_reads_non_chr](http://www.htslib.org/doc/samtools-view.html)
Extract reads from non-chromosomal contigs and unmapped reads to separate `.bam` files using samtools view.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__samtools__samtools_extract_reads_non_chr#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__samtools__samtools_extract_reads_non_chr#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__samtools_extract_reads_non_chr#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__samtools_extract_reads_non_chr#

---

## [samtools_extract_reads_umi](http://www.htslib.org/doc/samtools-view.html)
Extract reads from each chromosome and put into separate `.bam` files using samtools view.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__samtools__samtools_extract_reads_umi#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__samtools__samtools_extract_reads_umi#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__samtools_extract_reads_umi#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__samtools_extract_reads_umi#

---

## [samtools_extract_reads_non_chr_umi](http://www.htslib.org/doc/samtools-view.html)
Introduction to samtools_extract_reads_non_chr_umi

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__samtools__samtools_extract_reads_non_chr_umi#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__samtools__samtools_extract_reads_non_chr_umi#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__samtools_extract_reads_non_chr_umi#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__samtools_extract_reads_non_chr_umi#
---

## [samtools_fastq](http://www.htslib.org/doc/samtools-fasta.html)
Converts a bam file to separate fastq files

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__samtools__samtools_fastq#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__samtools__samtools_fastq#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__samtools_fastq#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__samtools_fastq#

---

## [samtools index](http://www.htslib.org/doc/samtools-index.html)
Index `.bam` files using samtools index.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__samtools__samtools_index#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__samtools__samtools_index#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__samtools_index#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__samtools_index#

---

## [samtools_merge_bam](http://www.htslib.org/doc/samtools-merge.html)
Merge `.bam` files from the same sample using samtools merge.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__samtools__samtools_merge_bam#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__samtools__samtools_merge_bam#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__samtools_merge_bam#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__samtools_merge_bam#

---

## [samtools sort](http://www.htslib.org/doc/samtools-sort.html)
Sort `.bam` files using samtools sort.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__samtools__samtools_sort#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__samtools__samtools_sort#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__samtools_sort#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__samtools_sort#

---

## [samtools sort_umi](http://www.htslib.org/doc/samtools-sort.html)
Sort `.bam` files using samtools sort. Sort on query name.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__samtools__samtools_sort#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__samtools__samtools_sort#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__samtools_sort#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__samtools_sort#

---

## [star](https://github.com/alexdobin/STAR)
Align `.fastq` files to a reference genome and generate a `.bam` file. Star is a split read aware aligner for RNA-data.

### :snake: Rule

#SNAKEMAKE_RULE_SOURCE__star__star#

#### :left_right_arrow: input / output files

#SNAKEMAKE_RULE_TABLE__star__star#

### :wrench: Configuration

#### Software settings (`config.yaml`)

#CONFIGSCHEMA__star#

#### Resources settings (`resources.yaml`)

#RESOURCESSCHEMA__star#

