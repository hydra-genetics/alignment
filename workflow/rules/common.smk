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


def get_unit_types(units: pd.DataFrame, sample: str) -> set[str]:
    """
    function used to extract all types of units found for a sample in units.tsv (N,T,R)
    Args:
        units: DataFrame generate by importing a file following schema defintion
               found in pre-alignment/workflow/schemas/units.schema.tsv
        wildcards: wildcards object with at least the following wildcard names
               sample.
    Returns:
        list of unit types ex set("N","T")
    Raises:
        raises and exception if no unit(s) can be extracted from the Dataframe
    """
    return set([u.unit for u in units.loc[(sample,)].dropna().itertuples()])


def compile_output_list(wildcards: snakemake.io.Wildcards):
    return [
        "alignment/bwa_mem/%s_%s.bam" % (sample.Index, unit_type)
        for sample in samples.itertuples()
        for unit_type in get_unit_types(units, sample.Index)
    ]
