# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule mark_duplicates:
    input:
        "alignment/extract_reads/{sample}_{type}_{chr}.bam",
    output:
        bam=temp("alignment/mark_duplicates/{sample}_{type}_{chr}.bam"),
        metrics=temp("alignment/mark_duplicates/{sample}_{type}_{chr}.metrics.txt"),
    params:
        extra=config.get("mark_duplicates", {}).get("extra", ""),
    log:
        "alignment/mark_duplicates/{sample}_{type}_{chr}.log",
    benchmark:
        repeat(
            "alignment/mark_duplicates/{sample}_{type}_{chr}.benchmark.tsv",
            config.get("mark_duplicates", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("mark_duplicates", config["default_resources"]).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("mark_duplicates", {}).get('threads', config["default_resources"]["threads"]),
        time=config.get("mark_duplicates", {}).get('time', config["default_resources"]["time"]),
    container:
        config.get("mark_duplicates", {}).get("container", config["default_container"])
    conda:
        "../envs/mark_duplicates.yaml"
    message:
        "{rule}: Mark duplicates in alignment/{rule}/{wildcards.sample}_{wildcards.type}_{wildcards.chr}.bam"
    wrapper:
        "0.79.0/bio/picard/markduplicates"
