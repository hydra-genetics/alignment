# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Jonas Almlöf, Patrik Smeds"
__copyright__ = "Copyright 2021, Jonas Almlöf, Patrik Smeds"
__email__ = "jonas.almlof@scilifelab.uu.se, patrik.smeds@scilifelab.uu.se"
__license__ = "GPL-3"


rule samotools_extract_reads:
    input:
        samtools_extract_reads_input,
        samtools_extract_reads_input_bai,
    output:
        temp("alignment/samtools_extract_reads/{sample}_{type}_{chr}.bam"),
    params:
        extra=config.get("samtools_extract_reads", {}).get("extra", ""),
    log:
        "alignment/samtools_extract_reads/{sample}_{type}_{chr}.bam.log",
    benchmark:
        repeat(
            "alignment/samtools_extract_reads/{sample}_{type}_{chr}.bam.benchmark.tsv",
            config.get("samtools_extract_reads", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("samtools_extract_reads", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("samtools_extract_reads", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_extract_reads", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("samtools_extract_reads", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_extract_reads", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_extract_reads", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("samtools_extract_reads", {}).get("container", config["default_container"])
    conda:
        "../envs/samtools.yaml"
    message:
        "{rule}: create bam {output} with only reads from {wildcards.chr}"
    shell:
        "(samtools view -@ {threads} {params.extra} -b {input} {wildcards.chr} > {output}) &> {log}"


rule samtools_index:
    input:
        "{file}.bam",
    output:
        "{file}.bam.bai",
    params:
        extra=config.get("samtools_index", {}).get("extra", ""),
    log:
        "{file}.bam.bai.log",
    benchmark:
        repeat(
            "{file}.bam.bai.benchmark.tsv",
            config.get("samtools_index", {}).get("benchmark_repeats", 1),
        )
    container:
        config.get("samtools_index", {}).get("container", config["default_container"])
    threads: config.get("samtools_index", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("samtools_index", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_index", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("samtools_index", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_index", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_index", {}).get("partition", config["default_resources"]["partition"]),
    conda:
        "../envs/samtools.yaml"
    message:
        "{rule}: create index for {wildcards.file}"
    wrapper:
        "0.78.0/bio/samtools/index"


rule samtools_merge_bam:
    input:
        bams=expand(
            "alignment/picard_mark_duplicates/{{sample}}_{{type}}_{chr}.bam",
            chr=extract_chr(
                "%s.fai" % (config["reference"]["fasta"]), filter_out=config.get("reference", {}).get("skip_chrs", [])
            ),
        ),
    output:
        bam=temp("alignment/samtools_merge_bam/{sample}_{type}.bam_unsorted"),
    params:
        extra=config.get("samtools_merge_bam", {}).get("extra", ""),
    log:
        "alignment/samtools_merge_bam/{sample}_{type}.bam_unsorted.log",
    benchmark:
        repeat(
            "alignment/samtools_merge_bam/{sample}_{type}.bam_unsorted.benchmark.tsv",
            config.get("samtools_merge_bam", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("samtools_merge_bam", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("samtools_merge_bam", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_merge_bam", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("samtools_merge_bam", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_merge_bam", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_merge_bam", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("samtools", {}).get("container", config["default_container"])
    conda:
        "../envs/samtools.yaml"
    message:
        "{rule}: merge chr bam files, creating {output}"
    shell:
        "(samtools merge -c -p {params.extra} {output} {input}) &> {log}"


rule samtools_sort:
    input:
        "{path_file}.bam_unsorted",
    output:
        temp("{path_file}.bam"),
    params:
        extra=config.get("samtools_sort", {}).get("extra", ""),
    log:
        "{path_file}.bam.sort.log",
    benchmark:
        repeat(
            "{path_file}.bam.sort.benchmark.tsv",
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
        "../envs/samtools.yaml"
    message:
        "{rule}: sort bam file {input} using samtools"
    wrapper:
        "v0.86.0/bio/samtools/sort"
