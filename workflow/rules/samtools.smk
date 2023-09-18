__author__ = "Jonas Almlöf, Patrik Smeds"
__copyright__ = "Copyright 2021, Jonas Almlöf, Patrik Smeds"
__email__ = "jonas.almlof@scilifelab.uu.se, patrik.smeds@scilifelab.uu.se"
__license__ = "GPL-3"


rule samtools_extract_reads:
    input:
        bam="alignment/bwa_mem/{sample}_{type}.bam",
        bai="alignment/bwa_mem/{sample}_{type}.bam.bai",
    output:
        bam=temp("alignment/samtools_extract_reads/{sample}_{type}_{chr}.bam"),
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
        mem_mb=config.get("samtools_extract_reads", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_extract_reads", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_extract_reads", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_extract_reads", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_extract_reads", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("samtools_extract_reads", {}).get("container", config["default_container"])
    message:
        "{rule}: create bam {output} with only reads from {wildcards.chr}"
    shell:
        "(samtools view -@ {threads} {params.extra} -b {input} {wildcards.chr} > {output}) &> {log}"


rule samtools_extract_reads_umi:
    input:
        bam="alignment/bwa_mem_realign_consensus_reads/{sample}_{type}.umi.bam",
        bai="alignment/bwa_mem_realign_consensus_reads/{sample}_{type}.umi.bam.bai",
    output:
        bam=temp("alignment/samtools_extract_reads_umi/{sample}_{type}_{chr}.umi.bam"),
    params:
        extra=config.get("samtools_extract_reads", {}).get("extra", ""),
    log:
        "alignment/samtools_extract_reads_umi/{sample}_{type}_{chr}.bam.log",
    benchmark:
        repeat(
            "alignment/samtools_extract_reads_umi/{sample}_{type}_{chr}.bam.benchmark.tsv",
            config.get("samtools_extract_reads_umi", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("samtools_extract_reads_umi", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("samtools_extract_reads_umi", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_extract_reads_umi", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_extract_reads_umi", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_extract_reads_umi", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_extract_reads_umi", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("samtools_extract_reads_umi", {}).get("container", config["default_container"])
    message:
        "{rule}: create bam {output} with only reads from {wildcards.chr}"
    shell:
        "(samtools view -@ {threads} {params.extra} -b {input} {wildcards.chr} > {output}) &> {log}"


rule samtools_index:
    input:
        bam="{file}.bam",
    output:
        bai=temp("{file}.bam.bai"),
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
        mem_mb=config.get("samtools_index", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_index", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_index", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_index", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_index", {}).get("time", config["default_resources"]["time"]),
    message:
        "{rule}: create index for {wildcards.file}"
    wrapper:
        "v1.1.0/bio/samtools/index"


rule samtools_merge_bam:
    input:
        bams=expand(
            "alignment/picard_mark_duplicates/{{sample}}_{{type}}_{chr}.bam",
            chr=extract_chr(
                "%s.fai" % (config.get("reference", {}).get("fasta", "")),
                filter_out=config.get("reference", {}).get("skip_chrs", []),
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
        mem_mb=config.get("samtools_merge_bam", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_merge_bam", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_merge_bam", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_merge_bam", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_merge_bam", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("samtools", {}).get("container", config["default_container"])
    message:
        "{rule}: merge chr bam files, creating {output}"
    wrapper:
        "v1.1.0/bio/samtools/merge"


rule samtools_sort:
    input:
        bam="{path_file}.bam_unsorted",
    output:
        bam=temp("{path_file}.bam"),
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
        mem_mb=config.get("samtools_sort", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_sort", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_sort", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_sort", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_sort", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("samtools_sort", {}).get("container", config["default_container"])
    message:
        "{rule}: sort bam file {input} using samtools"
    wrapper:
        "v1.3.2/bio/samtools/sort"


rule samtools_sort_umi:
    input:
        bam="alignment/bwa_mem/{sample}_{type}.bam_unsorted",
    output:
        bam=temp("alignment/bwa_mem/{sample}_{type}.umi.bam"),
    params:
        extra=config.get("samtools_sort", {}).get("extra", "-n"),
    log:
        "alignment/samtools_merge_bam/{sample}_{type}.umi.bam.log",
    benchmark:
        repeat(
            "alignment/samtools_merge_bam/{sample}_{type}.umi.bam.benchmark.tsv",
            config.get("samtools_sort", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("samtools_sort", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("samtools_sort", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_sort", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_sort", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_sort", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_sort", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("samtools_sort", {}).get("container", config["default_container"])
    message:
        "{rule}: sort bam file {input} using samtools"
    wrapper:
        "v1.3.2/bio/samtools/sort"
