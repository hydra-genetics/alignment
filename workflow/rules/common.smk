__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


import pandas
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


if config.get("read_duplication_handling", None) == "umi":
    bwa_mem_output = "alignment/bwa_mem/{sample}_{type}_{flowcell}_{lane}_{barcode}.umi.bam"
    get_extra_umi_option = "-Y "
    bwa_merge_input = "alignment/bwa_mem/{sample}_{type}_%s_%s_%s.umi.bam"
    bwa_merge_output = "alignment/bwa_mem/{sample}_{type}.umi.bam_unsorted"
    samtools_sort_input = "{path_file}.umi.bam_unsorted"
    samtools_sort_output = "{path_file}.umi.bam"
    samtools_extract_reads_bam = "alignment/bwa_mem/{sample}_{type}.umi.bam"
    samtools_extract_reads_bai = "alignment/bwa_mem/{sample}_{type}.umi.bam.bai"
    samtools_extract_reads_output = "alignment/samtools_extract_reads/{sample}_{type}_{chr}.umi.bam"
else:
    bwa_mem_output = "alignment/bwa_mem/{sample}_{type}_{flowcell}_{lane}_{barcode}.bam"
    get_extra_umi_option = ""
    bwa_merge_input = "alignment/bwa_mem/{sample}_{type}_%s_%s_%s.bam"
    bwa_merge_output = "alignment/bwa_mem/{sample}_{type}.bam_unsorted"
    samtools_sort_input = "{path_file}.bam_unsorted"
    samtools_sort_output = "{path_file}.bam"
    samtools_extract_reads_bam = "alignment/bwa_mem/{sample}_{type}.bam"
    samtools_extract_reads_bai = "alignment/bwa_mem/{sample}_{type}.bam.bai"
    samtools_extract_reads_output = "alignment/samtools_extract_reads/{sample}_{type}_{chr}.bam"


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


def generate_read_group(wildcards):
    return "-R '@RG\\tID:{}\\tSM:{}\\tPL:{}\\tPU:{}\\tLB:{}' -v 1 ".format(
        "{}_{}.{}.{}".format(wildcards.sample, wildcards.type, wildcards.lane, wildcards.barcode),
        "{}_{}".format(wildcards.sample, wildcards.type),
        get_unit_platform(units, wildcards),
        "{}.{}.{}".format(wildcards.flowcell, wildcards.lane, wildcards.barcode),
        "{}_{}".format(wildcards.sample, wildcards.type),
    )


def compile_output_list(wildcards):
    files = {}
    if config.get("read_duplication_handling", None) == "umi":
        files = {"alignment/samtools_merge_bam": [".umi.bam"]}
    else:
        files = {"alignment/samtools_merge_bam": [".bam"]}
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
