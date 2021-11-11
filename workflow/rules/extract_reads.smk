# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Patrik Smeds"
__copyright__ = "Copyright 2021, Patrik Smeds"
__email__ = "patrik.smeds@scilifelab.uu.se"
__license__ = "GPL-3"


rule extract_reads:
    input:
        extract_reads_input,
        extract_reads_input_bai,
    output:
        temp("alignment/extract_reads/{sample}_{type}_{chr}.bam"),
    params:
        extra=config.get("extract_reads", {}).get("extra", ""),
    log:
        "alignment/extract_reads/{sample}_{type}_{chr}.log",
    benchmark:
        repeat(
            "alignment/extract_reads/{sample}_{type}_{chr}.benchmark.tsv",
            config.get("extract_reads", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("extract_reads", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("extract_reads", {}).get('threads', config["default_resources"]["threads"]),
        time=config.get("extract_reads", {}).get('time', config["default_resources"]["time"]),
        mem_mb=config.get("extract_reads", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("extract_reads", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("extract_reads", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("extract_reads", {}).get("container", config["default_container"])
    conda:
        "../envs/extract_reads.yaml"
    message:
        "{rule}: create bam with only {wildcards.chr} reads, alignment/{rule}/{wildcards.sample}_{wildcards.type}_{wildcards.chr}.bam"
    shell:
        "(samtools view -@ {threads} {params.extra} -b {input} {wildcards.chr} > {output}) &> {log}"
