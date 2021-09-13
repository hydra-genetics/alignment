# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule bwa_mem:
    input:
        fastq=["Pre-alignment/merge/{sample}_R1.fq.gz", "Pre-alignment/merge/{sample}_R2.fq.gz"],
    output:
        bam="Alignment/bwa-mem/{sample}.bam",
    log:
        log="Logs/Aligment/bwa-mem/{sample}.log",
    params:
        index=config["references"]["genome"],
        extra=config["bwa-mem"]["extra"],
        sort=config["bwa-mem"].get("sort", "samtools")
        sort_order=config["bwa-mem"].get("sort_order", "coordinate"),
        sort_extra="-@ " + str(config["bwa-mem"]["threads"]),
    threads: config["bwa-mem"]["threads"]
    #benchmark:
    #    repeat(_bwa_benchmark, config.get("benchmark", {}).get("repeats", 1))
    container:
        config["tools"].get("bwa-mem", config["tools"].get("default", ""))
    message:
        "{rule}: Align {wildcards.sample} with bwa and sort"
    wrapper:
        "0.70.0/bio/bwa/mem"


rule index_bwa_bam:
    input:
        "Alignment/bwa-mem/{sample}.bam"
    output:
        "Alignment/bwa-mem/{sample}.bam.bai",
    log:
        "Logs/Alignment/index_bwa_bam/{sample}.log",
    container:
        config["tools"]["common"]
    message:
        "{rule}: Index {wildcards.sample} bam file"
    shell:
        "samtools index "
        "-b {input} "
        "{output} &> {log}"
