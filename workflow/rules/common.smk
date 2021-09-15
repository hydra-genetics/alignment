
__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"

import pandas as pd
from snakemake.utils import validate
from snakemake.utils import min_version

min_version("6.8.0")

### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")


### Read and validate samples file

samples = pd.read_table(config["samples"], dtype=str).set_index("sample", drop=False)
validate(samples, schema="../schemas/samples.schema.yaml")

### Read and validate units file

units = pd.read_table(config["units"], dtype=str).set_index(["sample", "unit", "run", "lane"], drop=False)
validate(units, schema="../schemas/units.schema.yaml")

### Set wildcard constraints


wildcard_constraints:
    sample="|".join(samples.index),


def get_fastq(wildcards):
    fastqs = units.loc[(wildcards.sample, wildcards.unit, wildcards.run, wildcards.lane), ["fastq1", "fastq2"]].dropna()
    return {"fwd": fastqs.fastq1, "rev": fastqs.fastq2}


def get_sample_fastq(wildcards):
    fastqs = units.loc[(wildcards.sample, wildcards.unit), ["fastq1", "fastq2"]].dropna()
    return {"fwd": fastqs["fastq1"].tolist(), "rev": fastqs["fastq2"].tolist()}


def compile_output_list(wildcards):
    output_list = []
    for sample in samples.index:
        output_list.append("alignment/bwa_mem/%s_%s.bam" % sample, units[sample].unit)
        output_list.append("alignment/bwa_mem/%s_%s.bam.bai" % sample, units[sample].unit)
    return output_list
