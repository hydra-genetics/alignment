__author__ = "Jonas Almlöf, Patrik Smeds, Pádraic Corcoran"
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


rule samtools_extract_reads_non_chr:
    input:
        bam="alignment/bwa_mem/{sample}_{type}.bam",
        bai="alignment/bwa_mem/{sample}_{type}.bam.bai",
    output:
        bam=temp("alignment/samtools_extract_reads/{sample}_{type}_non_chr.bam"),
    params:
        contigs=get_contig_list,
        extra=config.get("samtools_extract_reads_non_chr", {}).get("extra", ""),
    log:
        "alignment/samtools_extract_reads/{sample}_{type}_non_chr.bam.log",
    benchmark:
        repeat(
            "alignment/samtools_extract_reads/{sample}_{type}_non_chr.bam.benchmark.tsv",
            config.get("samtools_extract_reads_non_chr", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("samtools_extract_reads_non_chr", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("samtools_extract_reads_non_chr", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_extract_reads_non_chr", {}).get(
            "mem_per_cpu", config["default_resources"]["mem_per_cpu"]
        ),
        partition=config.get("samtools_extract_reads_non_chr", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_extract_reads_non_chr", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_extract_reads_non_chr", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("samtools_extract_reads_non_chr", {}).get("container", config["default_container"])
    message:
        "{rule}: create bam {output} with only reads from {params.contigs}"
    shell:
        "(samtools view -@ {threads} {params.extra} -b {input} {params.contigs} '*' > {output}) &> {log}"


rule samtools_extract_reads_umi:
    input:
        bam="alignment/bwa_mem_realign_consensus_reads/{sample}_{type}.umi.bam",
        bai="alignment/bwa_mem_realign_consensus_reads/{sample}_{type}.umi.bam.bai",
    output:
        bam=temp("alignment/samtools_extract_reads_umi/{sample}_{type}_{chr}.umi.bam"),
    params:
        extra=config.get("samtools_extract_reads", {}).get("extra", ""),
    log:
        "alignment/samtools_extract_reads_umi/{sample}_{type}_{chr}.umi.bam.log",
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


rule samtools_extract_reads_non_chr_umi:
    input:
        bam="alignment/bwa_mem_realign_consensus_reads/{sample}_{type}.umi.bam",
        bai="alignment/bwa_mem_realign_consensus_reads/{sample}_{type}.bam.bai",
    output:
        bam=temp("alignment/samtools_extract_reads/{sample}_{type}_non_chr.umi.bam"),
    params:
        contigs=get_contig_list,
        extra=config.get("samtools_extract_reads_non_chr_umi", {}).get("extra", ""),
    log:
        "alignment/samtools_extract_reads_non_chr_umi/{sample}_{type}_non_chr.umi.bam.log",
    benchmark:
        repeat(
            "alignment/samtools_extract_reads_non_chr_umi/{sample}_{type}_non_chr.umi.bam.benchmark.tsv",
            config.get("samtools_extract_reads_non_chr_umi", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("samtools_extract_reads_non_chr_umi", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("samtools_extract_reads_non_chr_umi", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_extract_reads_non_chr_umi", {}).get(
            "mem_per_cpu", config["default_resources"]["mem_per_cpu"]
        ),
        partition=config.get("samtools_extract_reads_non_chr_umi", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_extract_reads_non_chr_umi", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_extract_reads_non_chr_umi", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("samtools_extract_reads_non_chr_umi", {}).get("container", config["default_container"])
    message:
        "{rule}: create bam {output} with only reads from {params.contigs}"
    shell:
        "(samtools view -@ {threads} {params.extra} -b {input} {params.contigs} '*' > {output}) &> {log}"


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
        "{rule}: create index for {input.bam}"
    wrapper:
        "v1.1.0/bio/samtools/index"


rule samtools_merge_bam:
    input:
        bams=get_chrom_bams,
        non_chr_bams="alignment/picard_mark_duplicates/{sample}_{type}_non_chr.bam"
        if config.get("reference", {}).get("merge_contigs", None) is not None
        else [],
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
        bam="{file}.bam_unsorted",
    output:
        bam=temp("{file}.bam"),
    params:
        extra=config.get("samtools_sort", {}).get("extra", ""),
    log:
        "{file}.bam.sort.log",
    benchmark:
        repeat(
            "{file}.bam.sort.benchmark.tsv",
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
        "{rule}: sort bam file {input.bam} using samtools"
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


rule samtools_fastq:
    input:
        bam="alignment/fgbio_call_and_filter_consensus_reads/{sample}_{type}.umi.unmapped_bam",
    output:
        fastq1="alignment/samtools_fastq/{sample}_{type}.fastq1.umi.fastq.gz",
        fastq2="alignment/samtools_fastq/{sample}_{type}.fastq2.umi.fastq.gz",
    params:
        sort=config.get("samtools_fastq", {}).get("sort", "-m 4G"),
        fastq=config.get("samtools_fastq", {}).get("fastq", "-n"),
    log:
        "alignment/samtools_fastq/{sample}_{type}.output.log",
    benchmark:
        repeat(
            "alignment/samtools_fastq/{sample}_{type}.output.benchmark.tsv",
            config.get("samtools_fastq", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("samtools_fastq", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("samtools_fastq", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("samtools_fastq", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("samtools_fastq", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("samtools_fastq", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("samtools_fastq", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("samtools_fastq", {}).get("container", config["default_container"])
    message:
        "{rule}: Convert the bam file {input.bam} into a fastq file"
    wrapper:
        "v2.6.0/bio/samtools/fastq/separate"
