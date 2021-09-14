# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule bwa_mem:
    input:
        reads=["pre-alignment/merge/{sample}_{unit}_R1.fq.gz", "Pre-alignment/merge/{sample}_{unit}_R2.fq.gz"],
        index=config["references"]["genome"],
    output:
        bam="alignment/bwa_mem/{sample}_{unit}.bam",
    params:
        index=config["references"]["genome"],
        extra=config["bwa_mem"]["extra"],
        sort=config["bwa_mem"].get("sort", "samtools"),
        sort_order=config["bwa_mem"].get("sort_order", "coordinate"),
        sort_extra="-@ " + str(config["bwa_mem"]["threads"]),
    log:
            log="aligment/bwa_mem/{sample}_{unit}.bam.log",
    benchmark:
        "alignment/bwa_mem/{sample}_{unit}.bam.benchmark.tsv"
    threads: config["bwa_mem"]["threads"]
    container:
        config["tools"].get("bwa_mem", config["tools"].get("default", ""))
    message:
        "{rule}: Align {wildcards.sample}_{wildcards.unit} with bwa and sort"
    wrapper:
        "0.70.0/bio/bwa/mem"


rule samtools_index:
    input:
        "{module}/{software}/{file}.bam",
    output:
        "{module}/{software}/{file}.bam.bai",
    log:
        "{module}/{software}/{file}.bam.bai.log",
    benchmark:
        "{module}/{software}/{file}.bam.bai.benchmark.tsv"
    container:
        config["tools"]["common"]
    message:
        "{rule}: Index {wildcards.module}/{wildcards.software}/{wildcards.file} bam file"
    shell:
        "samtools index "
        "-b {input} "
        "{output} &> {log}"
