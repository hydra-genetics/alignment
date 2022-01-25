# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Patrik Smeds"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "patrik.smeds@scilifelab.uu.se"
__license__ = "GPL-3"


rule samtools_sort:
    input:
        "{path_file}.bam_unsorted",
    output:
        "{path_file}.bam",
    log:
        "{path_file}.samtools_sort.log",
    benchmark:
        repeat(
            "{path_file}.samtools_sort.benchmark.tsv",
            config.get("samtools_sort", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("samtools_sort", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("samtools_sort", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_sort", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("samtools_sort", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_sort", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_sort", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("samtools_sort", {}).get("container", config["default_container"])
    conda:
        "../envs/samtools_sort.yaml"
    message:
        "{rule}: Sort align {wildcards.path_file} with samtools"
    wrapper:
        "v0.86.0/bio/samtools/sort"
