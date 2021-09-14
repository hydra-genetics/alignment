# coding: utf-8

__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule bwa_mem:
    input:
        reads=["pre-alignment/merge/{sample}_{unit}_R1.fq.gz", "pre-alignment/merge/{sample}_{unit}_R2.fq.gz"],
        index=config["reference"]["fasta"],
    output:
        bam="alignment/bwa_mem/{sample}_{unit}.bam",
    params:
        index=config["reference"]["fasta"],
        extra=config["bwa_mem"]["params"]["extra"],
        sort=config["bwa_mem"]["params"].get("sort", "samtools"),
        sort_order=config["bwa_mem"]["params"].get("sort_order", "coordinate"),
        sort_extra="-@ %s" % str(config["bwa_mem"]["threads"]),
    log:
        "aligment/bwa_mem/{sample}_{unit}.bam.log",
    benchmark:
        "alignment/bwa_mem/{sample}_{unit}.bam.benchmark.tsv"
    threads: config["bwa_mem"]["threads"]
    container:
        config["bwa_mem"]["container"]
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
