# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule samtools_index:
    input:
        "{file}.bam",
    output:
        "{file}.bam.bai",
    log:
        "{file}.bam.bai.log",
    benchmark:
        repeat(
            "{file}.bam.bai.benchmark.tsv",
            config.get("samtools_index", {}).get("benchmark_repeats", 1),
        )
    container:
        config.get("samtools_index", {}).get("container", "default_container")
    threads: config.get("samtools_index", config["default_resources"]).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("samtools_index", config["default_resources"])["threads"],
        time=config.get("samtools_index", config["default_resources"])["time"],
    conda:
        "../envs/samtools_index.yaml"
    message:
        "{rule}: Index {wildcards.file} bam file"
    wrapper:
        "0.78.0/bio/samtools/index"
