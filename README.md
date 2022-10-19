# <img src="https://github.com/hydra-genetics/alignment/blob/develop/images/hydragenetics.png" width=40 /> hydra-genetics/alignment

Snakemake module containing processing steps that should be performed during sequence alignment.

![Lint](https://github.com/hydra-genetics/alignment/actions/workflows/lint.yaml/badge.svg?branch=develop)
![Snakefmt](https://github.com/hydra-genetics/alignment/actions/workflows/snakefmt.yaml/badge.svg?branch=develop)
![snakemake dry run](https://github.com/hydra-genetics/alignment/actions/workflows/snakemake-dry-run.yaml/badge.svg?branch=develop)
![integration test](https://github.com/hydra-genetics/alignment/actions/workflows/integration.yaml/badge.svg?branch=develop)

[![License: GPL-3](https://img.shields.io/badge/License-GPL3-yellow.svg)](https://opensource.org/licenses/gpl-3.0.html)

## :speech_balloon: Introduction

The module consists of alignment processing steps, such as alignment of `.fastq`-files. and duplicates marking
`.bam`-files.

## :heavy_exclamation_mark: Dependencies

In order to use this module, the following dependencies are required:

[![hydra-genetics](https://img.shields.io/badge/hydragenetics-v0.9.1-blue)](https://github.com/hydra-genetics/)
[![pandas](https://img.shields.io/badge/pandas-1.3.1-blue)](https://pandas.pydata.org/)
[![python](https://img.shields.io/badge/python-3.8-blue)](https://www.python.org/)
[![snakemake](https://img.shields.io/badge/snakemake-6.10.0-blue)](https://snakemake.readthedocs.io/en/stable/)
[![singularity](https://img.shields.io/badge/singularity-3.0.0-blue)](https://sylabs.io/docs/)

## :school_satchel: Preparations

### Sample and unit data

Input data should be added to [`samples.tsv`](https://github.com/hydra-genetics/prealignment/blob/develop/config/samples.tsv)
and [`units.tsv`](https://github.com/hydra-genetics/prealignment/blob/develop/config/units.tsv).
The following information need to be added to these files:

| Column Id | Description |
| --- | --- |
| **`samples.tsv`** |
| sample | unique sample/patient id, one per row |
| **`units.tsv`** |
| sample | same sample/patient id as in `samples.tsv` |
| type | data type identifier (one letter), can be one of **T**umor, **N**ormal, **R**NA |
| platform | type of sequencing platform, e.g. `NovaSeq` |
| machine | specific machine id, e.g. NovaSeq instruments have `@Axxxxx` |
| flowcell | identifer of flowcell used |
| lane | flowcell lane number |
| barcode | sequence library barcode/index, connect forward and reverse indices by `+`, e.g. `ATGC+ATGC` |
| fastq1/2 | absolute path to forward and reverse reads |
| adapter | adapter sequences to be trimmed, separated by comma |

### Reference data

You need have a indexed reference genome: ex reference.fna

For bwa the files are generated by [bwa index](http://bio-bwa.sourceforge.net/bwa.shtml#:~:text=SYNOPSIS-,bwa%20index%20ref.fa,-bwa%20mem%20ref). Dict files is generated using `picard CreateSequenceDictionary`. fai is generated using `samtools index`
| File | Description |
| -----| ----------- |
| reference.dict | dictionary file|
| reference.fna.amb | record appearance of N (or other non-ATGC) in the ref fasta |
| reference.fna.ann | record ref sequences, name, length, etc |
| reference.fna.bwt | the Burrows-Wheeler transformed sequence |
| reference.fna.fai | index file|
| reference.fna.pac | packaged sequence (four base pairs encode one byte) |
| reference.fna.sa | suffix array index |

## :white_check_mark: Testing

The workflow repository contains a small test dataset `.tests/integration` which can be run like so:

```bash
$ cd .tests/integration
$ snakemake -s ../../Snakefile -j1 --configfile config.yaml --use-singularity
```

## :rocket: Usage

To use this module in your workflow, follow the description in the
[snakemake docs](https://snakemake.readthedocs.io/en/stable/snakefiles/modularization.html#modules).
Add the module to your `Snakefile` like so:

```bash
module alignment:
    snakefile:
        github(
            "hydra-genetics/alignment",
            path="workflow/Snakefile",
            tag="v0.1.0",
        )
    config:
        config


use rule * from alignment as alignment_*
```

### Compatibility

Latest:
 - prealignment:v0.4.0

 See [COMPATIBLITY.md](../master/COMPATIBLITY.md) file for a complete list of module compatibility.

### Input files

| File | Description |
|---|---|
| ***`hydra-genetics/prealignment data`*** |
| `prealignment/fastp_pe/{sample}_{flowcell}_{lane}_{type}_fastq1.fastq.gz` | trimmed forward reads |
| `prealignment/fastp_pe/{sample}_{flowcell}_{lane}_{type}_fastq1.fastq.gz` | trimmed reverse reads |
| ***`original fastq files`*** |
| `PATH/fastq1.fastq.gz` | forward reads retrieved from units.tsv |
| `PATH/fastq2.fastq.gz` | reverse reads retrieved from units.tsv |


### Output files

The following output files should be targeted via another rule:

| File | Description |
|---|---|
| `alignment/samtools_merge_bam/{sample}_{type}.bam` | aligned data which have been duplicate marked |

## :judge: Rule Graph

### Align and mark duplicates

![rule_graph](images/alignment_mark_duplicates.svg)
