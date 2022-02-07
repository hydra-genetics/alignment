# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule merge_bam:
    input:
        bams=expand(
            "alignment/mark_duplicates/{{sample}}_{{type}}_{chr}.bam",
            chr=extract_chr(
                "%s.fai" % (config["reference"]["fasta"]), filter_out=config.get("reference", {}).get("skip_chrs", [])
            ),
        ),
    output:
        bam=temp("alignment/merge_bam/{sample}_{type}.bam_unsorted"),
    params:
        extra=config.get("merge_bam", {}).get("extra", ""),
    log:
        "alignment/merge_bam/{sample}_{type}.log",
    benchmark:
        repeat(
            "alignment/merge_bam/{sample}_{type}.benchmark.tsv",
            config.get("merge_bam", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("merge_bam", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("merge_bam", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("merge_bam", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("merge_bam", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("merge_bam", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("merge_bam", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("merge_bam", {}).get("container", config["default_container"])
    conda:
        "../envs/merge_bam.yaml"
    message:
        "{rule}: Merge bam into alignment/{rule}/{wildcards.sample}_{wildcards.type}.bam"
    shell:
        "(samtools merge -c -p {output} {input}) &> {log}"
