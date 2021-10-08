__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


import pandas
import yaml
from snakemake.utils import validate
from snakemake.utils import min_version

from hydra_genetics.utils.resources import load_resources
from hydra_genetics.utils.units import *
from hydra_genetics.utils.samples import *

min_version("6.8.0")


### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")
config = load_resources(config, config["resources"])
validate(config, schema="../schemas/resources.schema.yaml")


### Read and validate samples file

samples = pandas.read_table(config["samples"], dtype=str).set_index("sample", drop=False)
validate(samples, schema="../schemas/samples.schema.yaml")

### Read and validate units file

units = pandas.read_table(config["units"], dtype=str).set_index(["sample", "type", "run", "lane"], drop=False)
validate(units, schema="../schemas/units.schema.yaml")

### Set wildcard constraints


wildcard_constraints:
    sample="|".join(get_samples(samples)),
    type="N|T|R",


if config.get("alignment_software", None) == "gpu":
    extract_reads_input = "alignment/apply_bqsr_GPU/{sample}_{type}.bqsr.dedup.bam"
else:
    extract_reads_input = "alignment/bwa_mem/{sample}_{type}.bam"


def compile_output_list(wildcards: snakemake.io.Wildcards):
    return [
        "alignment/extract_reads/%s_%s_%s.bam" % (sample, type, "chr1")
        for sample in get_samples(samples)
        for type in get_unit_types(units, sample)
    ]
