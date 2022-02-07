__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule bwa_mem:
    input:
        reads=[
            "prealignment/fastp_pe/{sample}_{run}_{lane}_{type}_fastq1.fastq.gz",
            "prealignment/fastp_pe/{sample}_{run}_{lane}_{type}_fastq2.fastq.gz",
        ],
    output:
        bam=temp("alignment/bwa_mem/{sample}_{run}_{lane}_{type}.bam"),
    params:
        index=config["reference"]["fasta"],
        extra=lambda wildcards: "%s %s"
        % (
            config.get("bwa_mem", {}).get("extra", ""),
            config.get("bwa_mem", {}).get("read_group", generate_read_group(wildcards)),
        ),
        sorting=config.get("bwa_mem", {}).get("sort", "samtools"),
        sort_order=config.get("bwa_mem", {}).get("sort_order", "coordinate"),
        sort_extra="-@ %s"
        % str(config.get("bwa_mem", config["default_resources"]).get("threads", config["default_resources"]["threads"])),
    log:
        "alignment/bwa_mem/{sample}_{run}_{lane}_{type}.bam.log",
    benchmark:
        repeat(
            "alignment/bwa_mem/{sample}_{run}_{lane}_{type}.bam.benchmark.tsv",
            config.get("bwa_mem", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("bwa_mem", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("bwa_mem", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("bwa_mem", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("bwa_mem", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("bwa_mem", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("bwa_mem", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("bwa_mem", {}).get("container", config["default_container"])
    conda:
        "../envs/bwa_mem.yaml"
    message:
        "{rule}: Align alignment/{rule}/{wildcards.sample}_{wildcards.run}_{wildcards.lane}_{wildcards.type} with bwa and sort"
    wrapper:
        "0.78.0/bio/bwa/mem"


rule bwa_mem_merge:
    input:
        lambda wildcards: ["alignment/bwa_mem/{sample}_%s_%s_{type}.bam" % (u.run, u.lane) for u in get_units(units, wildcards)],
    output:
        temp("alignment/bwa_mem/{sample}_{type}.bam_unsorted"),
    params:
        config.get("bwa_mem_merge", {}).get("extra", ""),
    log:
        "alignment/bwa_mem/{sample}_{type}.bam.log",
    benchmark:
        repeat(
            "alignment/bwa_mem/{sample}_{type}.bam_merge.benchmark.tsv",
            config.get("bwa_mem_merge", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("bwa_mem_merge", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("bwa_mem_merge", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("bwa_mem_merge", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("bwa_mem_merge", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("bwa_mem_merge", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("bwa_mem_merge", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("bwa_mem_merge", {}).get("container", config["default_container"])
    conda:
        "../envs/bwa_mem_merge.yaml"
    message:
        "{rule}: Merge alignment/{rule}/{wildcards.sample}_{wildcards.type} with samtools"
    wrapper:
        "v0.86.0/bio/samtools/merge"
