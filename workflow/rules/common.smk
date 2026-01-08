__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


import pandas
import pysam
import re
import sys
import os
import yaml
from snakemake.utils import validate
from snakemake.utils import min_version

from hydra_genetics.utils.resources import load_resources
from hydra_genetics.utils.misc import extract_chr
from hydra_genetics.utils.units import *
from hydra_genetics.utils.samples import *


min_version("7.8.0")

### Set and validate config file

if not workflow.overwrite_configfiles:
    sys.exit("At least one config file must be passed using --configfile/--configfiles, by command line or a profile!")


validate(config, schema="../schemas/config.schema.yaml")
config = load_resources(config, config["resources"])
validate(config, schema="../schemas/resources.schema.yaml")


### Read and validate samples file

samples = pandas.read_table(config["samples"], dtype=str).set_index("sample", drop=False)
validate(samples, schema="../schemas/samples.schema.yaml")

### Read and validate units file
units = pandas.read_table(config["units"], dtype=str)

if units.platform.iloc[0] in ["PACBIO", "ONT"]:
    units = units.set_index(["sample", "type", "processing_unit", "barcode"], drop=False).sort_index()
else:  # assume that the platform Illumina data with a lane and flowcell columns
    units = units.set_index(["sample", "type", "flowcell", "lane", "barcode"], drop=False).sort_index()
validate(units, schema="../schemas/units.schema.yaml")

### Set wildcard constraints


wildcard_constraints:
    barcode="[A-Z+-]+",
    chr="[^_]+",
    flowcell="[A-Z0-9-]+",
    lane="L[0-9]+",
    sample="|".join(get_samples(samples)),
    type="N|T|R",
    file="^alignment/.+",


### Functions


if config.get("trimmer_software", "None") == "fastp_pe":
    if config.get("subsample", None) == "seqtk":
        alignment_input = lambda wildcards: [
            "prealignment/seqtk_subsample/{sample}_{type}_{flowcell}_{lane}_{barcode}_fastq1.ds.fastq.gz",
            "prealignment/seqtk_subsample/{sample}_{type}_{flowcell}_{lane}_{barcode}_fastq2.ds.fastq.gz",
        ]
    else:
        alignment_input = lambda wildcards: [
            "prealignment/fastp_pe/{sample}_{type}_{flowcell}_{lane}_{barcode}_fastq1.fastq.gz",
            "prealignment/fastp_pe/{sample}_{type}_{flowcell}_{lane}_{barcode}_fastq2.fastq.gz",
        ]
elif config.get("trimmer_software", "None") == "None":
    alignment_input = lambda wildcards: [
        get_fastq_file(units, wildcards, "fastq1"),
        get_fastq_file(units, wildcards, "fastq2"),
    ]


def get_deduplication_option(wildcards):
    sample = get_sample(samples, wildcards)
    if sample.get("deduplication", "") == "umi":
        return "-Y "
    else:
        return ""


def generate_read_group(wildcards):
    return "-R '@RG\\tID:{}\\tSM:{}\\tPL:{}\\tPU:{}\\tLB:{}' -v 1 ".format(
        "{}_{}.{}.{}".format(wildcards.sample, wildcards.type, wildcards.lane, wildcards.barcode),
        "{}_{}".format(wildcards.sample, wildcards.type),
        get_unit_platform(units, wildcards),
        "{}.{}.{}".format(wildcards.flowcell, wildcards.lane, wildcards.barcode),
        "{}_{}".format(wildcards.sample, wildcards.type),
    )


def get_minimap2_query(wildcards):
    unit = units.loc[(wildcards.sample, wildcards.type, wildcards.processing_unit, wildcards.barcode)]
    bam_file = unit["bam"]

    return bam_file


def get_reference_path(wildcards):
    ref_path = (config.get("reference", {}).get("fasta", ""),)
    fasta = os.path.basename(ref_path)

    return


def generate_minimap2_read_group(wildcards, input):
    """
    Extracts the read group line from a bam file using pysam.

    Args:
        input: Path to the bam file.

    Returns:
        str: The read group line (e.g. @RG\\tID:group1\\tLB:library1\\tPU:unit1).
            If no read group is found, an empty string is returned.
    """

    with pysam.AlignmentFile(input.query, "rb", check_sq=False) as bam:
        # Get the header dictionary
        header = bam.header
        # Check if Read Groups are present
        if "RG" in header:
            # Access the first read group (assuming single RG in the bam)
            read_group = header["RG"][0]
            rg_tags = []
            for key, val in read_group.items():
                if key == "SM":
                    continue
                else:
                    rg_tags.append(f"{key}:{val}")

            rg_tags.append(f"SM:{wildcards.sample}_{wildcards.type}")  # set SM to values from units.tsv

            rg_line = "-R '@RG\\t" + "\\t".join(rg_tags) + "'"

            return rg_line
        else:
            return ""


def get_chr_from_re(contig_patterns):
    contigs = []
    ref_fasta = config.get("reference", {}).get("fasta", "")
    all_contigs = extract_chr(f"{ref_fasta}.fai", filter_out=[])
    for pattern in contig_patterns:
        for contig in all_contigs:
            contig_match = re.match(pattern, contig)
            if contig_match is not None:
                contigs.append(contig_match.group())

    if len(set(contigs)) < len(contigs):  # check for duplicate conting entries
        chr_set = set()
        duplicate_contigs = [c for c in contigs if c in chr_set or chr_set.add(c)]
        dup_contigs_str = ", ".join(duplicate_contigs)
        sys.exit(
            f"Duplicate contigs detected:\n {dup_contigs_str}\n\
        Please revise the regular expressions listed under reference in the config"
        )

    return contigs


def get_chrom_bams(wildcards):
    skip_contig_patterns = config.get("reference", {}).get("skip_contigs", [])
    merge_contig_patterns = config.get("reference", {}).get("merge_contigs", [])
    contig_patterns = skip_contig_patterns + merge_contig_patterns

    if len(contig_patterns) == 0:
        skip_contigs = []
    else:
        skip_contigs = get_chr_from_re(contig_patterns)

    ref_fasta = config.get("reference", {}).get("fasta", "")
    chroms = extract_chr(f"{ref_fasta}.fai", filter_out=skip_contigs)

    bam_list = [f"alignment/picard_mark_duplicates/{wildcards.sample}_{wildcards.type}_{chr}.bam" for chr in chroms]

    return bam_list


def get_contig_list(wildcards):
    contig_patterns = config.get("reference", {}).get("merge_contigs", "")
    contigs = get_chr_from_re(contig_patterns)

    return contigs


def set_minimap2_preset(wildcards):
    extra = config.get("minimap2_align", {}).get("extra", "")
    preset = config.get("minimap2_align", {}).get("preset", "")
    preset_extra = f"-x {preset} {extra}"

    return preset_extra


def compile_output_list(wildcards):
    platform = units.platform.iloc[0]
    output_files = []
    files = {
        "alignment/minimap2_align": [".bam"],
        "alignment/pbmm2_align": [".bam"],
    }
    output_files += [
        f"{prefix}/{sample}_{unit_type}{suffix}"
        for prefix in files.keys()
        for sample in get_samples(samples)
        for platform in units.loc[(sample,)].platform
        if platform in ["ONT", "PACBIO"]
        for unit_type in get_unit_types(units, sample)
        if unit_type in ["N", "T"]
        for suffix in files[prefix]
    ]

    files = {
        "alignment/samtools_merge_bam": [".bam"],
        "alignment/samtools_filter_reads": [".bam"],
        "alignment/bwa_mem_realign_consensus_reads": [".umi.bam"],
        "alignment/fgbio_call_overlapping_consensus_bases": [".umi.bam"],
        "alignment/samtools_fastq": [".fastq1.umi.fastq.gz", ".fastq2.umi.fastq.gz"],
    }
    output_files += [
        f"{prefix}/{sample}_{unit_type}{suffix}"
        for prefix in files.keys()
        for sample in get_samples(samples)
        for platform in units.loc[(sample,)].platform
        if platform not in ["ONT", "PACBIO"]
        for unit_type in get_unit_types(units, sample)
        if unit_type in ["N", "T"]
        for suffix in files[prefix]
    ]
    files = {
        "alignment/star": [".bam"],
    }
    output_files += [
        f"{prefix}/{sample}_R{suffix}"
        for prefix in files.keys()
        for sample in get_samples(samples)
        if platform not in ["ONT", "PACBIO"]
        for unit_type in get_unit_types(units, sample)
        if "R" in get_unit_types(units, sample)
        for suffix in files[prefix]
    ]

    return output_files
