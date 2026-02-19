__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


import math


rule bwa_mem:
    input:
        reads=lambda wildcards: alignment_input(wildcards),
        idx=[
            config.get("bwa_mem", {}).get("amb", ""),
            config.get("bwa_mem", {}).get("ann", ""),
            config.get("bwa_mem", {}).get("bwt", ""),
            config.get("bwa_mem", {}).get("pac", ""),
            config.get("bwa_mem", {}).get("sa", ""),
        ],
    output:
        bam=temp("alignment/bwa_mem/{sample}_{type}_{flowcell}_{lane}_{barcode}.bam"),
    params:
        extra=lambda wildcards: "%s %s %s"
        % (
            config.get("bwa_mem", {}).get("extra", ""),
            config.get("bwa_mem", {}).get("read_group", generate_read_group(wildcards)),
            get_deduplication_option(wildcards),
        ),
        sorting=config.get("bwa_mem", {}).get("sort", "samtools"),
        sort_order=config.get("bwa_mem", {}).get("sort_order", "coordinate"),
        sort_extra="-@ %s"
        % str(config.get("bwa_mem", config["default_resources"]).get("threads", config["default_resources"]["threads"])),
    log:
        "alignment/bwa_mem/{sample}_{type}_{flowcell}_{lane}_{barcode}.bam.log",
    benchmark:
        repeat(
            "alignment/bwa_mem/{sample}_{type}_{flowcell}_{lane}_{barcode}.bam.benchmark.tsv",
            config.get("bwa_mem", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("bwa_mem", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("bwa_mem", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("bwa_mem", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("bwa_mem", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("bwa_mem", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("bwa_mem", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("bwa_mem", {}).get("container", config["default_container"])
    message:
        "{rule}: align fastq files {input.reads} using bwa mem against {input.idx[2]}"
    wrapper:
        "v1.3.1/bio/bwa/mem"


rule bwa_mem_merge:
    input:
        bams=lambda wildcards: [
            "alignment/bwa_mem/{sample}_{type}_%s_%s_%s.bam" % (u.flowcell, u.lane, u.barcode)
            for u in get_units(units, wildcards)
        ],
    output:
        bam=temp("alignment/bwa_mem/{sample}_{type}_unsorted.bam"),
    params:
        config.get("bwa_mem_merge", {}).get("extra", ""),
    log:
        "alignment/bwa_mem/{sample}_{type}_unsorted.bam.log",
    benchmark:
        repeat(
            "alignment/bwa_mem/{sample}_{type}_unsorted.bam.benchmark.tsv",
            config.get("bwa_mem_merge", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("bwa_mem_merge", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("bwa_mem_merge", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("bwa_mem_merge", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("bwa_mem_merge", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("bwa_mem_merge", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("bwa_mem_merge", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("bwa_mem_merge", {}).get("container", config["default_container"])
    message:
        "{rule}: merge bam file {input} using samtools"
    wrapper:
        "v1.1.0/bio/samtools/merge"


rule bwa_mem_realign_consensus_reads:
    input:
        bam="alignment/fgbio_call_and_filter_consensus_reads/{sample}_{type}.umi.unmapped_bam",
    output:
        bam=temp("alignment/bwa_mem_realign_consensus_reads/{sample}_{type}.umi_unsorted.bam"),
    params:
        extra_bwa_mem=config.get("bwa_mem_realign_consensus_reads", {}).get("extra_bwa_mem", ""),
        reference=config.get("reference", {}).get("fasta", ""),
        tmp_dir = "alignment/tmp_realign_{sample}_{type}",
        fgbio_sorted_unmapped = "alignment/tmp_realign_{sample}_{type}/fgbio_query_sorted.bam",
    log:
        "alignment/bwa_mem_realign_consensus_reads/{sample}_{type}.umi.bam.log",
    benchmark:
        repeat(
            "alignment/bwa_mem_realign_consensus_reads/{sample}_{type}.umi.bam.benchmark.tsv",
            config.get("bwa_mem_realign_consensus_reads", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("bwa_mem_realign_consensus_reads", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("bwa_mem_realign_consensus_reads", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("bwa_mem_realign_consensus_reads", {}).get(
            "mem_per_cpu", config["default_resources"]["mem_per_cpu"]
        ),
        partition=config.get("bwa_mem_realign_consensus_reads", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("bwa_mem_realign_consensus_reads", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("bwa_mem_realign_consensus_reads", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("bwa_mem_realign_consensus_reads", {}).get("container", config["default_container"])
    message:
        "{rule}: realign unmappend consensus reads found in {input.bam}"
    shell:
        'sh -c "'
        "set -e; "
        "mkdir -p {params.tmp_dir}; "
        "trap 'rm -rf {params.tmp_dir}' EXIT; "
        
        # 1. Sort the input unmapped BAM with fgbio to set the correct collating order
        "fgbio -Xmx16g SortBam -i {input.bam} -s Queryname -o {params.fgbio_sorted_unmapped}; "
        
        # 2. Realign and Zip in a single stream
        "samtools fastq -n {params.fgbio_sorted_unmapped} | "
        "bwa mem -t {threads} -p -K 150000000 -Y {params.reference} {params.extra_bwa_mem} - | "
        "fgbio -Xmx16g SortBam -i /dev/stdin -s Queryname -o /dev/stdout | "
        "fgbio -Xmx16g ZipperBams "
        "--unmapped {params.fgbio_sorted_unmapped} "
        "--ref {params.reference} "
        "--tags-to-reverse cd ce ad ae bd be aq bq "
        "--tags-to-revcomp ac bc "
        "-o {output.bam}"
        '" >& {log}'
