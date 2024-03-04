__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


import pandas
import re
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

units = (
    pandas.read_table(config["units"], dtype=str)
    .set_index(["sample", "type", "flowcell", "lane", "barcode"], drop=False)
    .sort_index()
)
validate(units, schema="../schemas/units.schema.yaml")

### Set wildcard constraints


wildcard_constraints:
    barcode="[A-Z+]+",
    chr="[^_]+",
    flowcell="[A-Z0-9-]+",
    lane="L[0-9]+",
    sample="|".join(get_samples(samples)),
    type="N|T|R",


### Functions


if config.get("trimmer_software", "None") == "fastp_pe":
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


def compile_output_list(wildcards):
    files = {
        "alignment/samtools_merge_bam": [".bam"],
        "alignment/bwa_mem_realign_consensus_reads": [".umi.bam"],
        "alignment/samtools_fastq": [".fastq1.umi.fastq.gz", ".fastq2.umi.fastq.gz"],
    }
    output_files = [
        "%s/%s_%s%s" % (prefix, sample, unit_type, suffix)
        for prefix in files.keys()
        for sample in get_samples(samples)
        for unit_type in get_unit_types(units, sample)
        if unit_type in ["N", "T"]
        for suffix in files[prefix]
    ]
    files = {
        "alignment/star": [".bam"],
    }
    output_files.append(
        [
            "%s/%s_R%s" % (prefix, sample, suffix)
            for prefix in files.keys()
            for sample in get_samples(samples)
            if "R" in get_unit_types(units, sample)
            for suffix in files[prefix]
        ]
    )
    return output_files
