__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2023, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule fgbio_copy_umi_from_read_name:
    input:
        bam="alignment/bwa_mem/{sample}_{type}.bam
    output:
        bam=temp("alignment/fgbio_copy_umi_from_read_name/{sample}_{type}.bam"),
    params:
        extra=config.get("fgbio_copy_umi_from_read_name", {}).get("extra", ""),
    log:
        "alignment/fgbio_copy_umi_from_read_name/{sample}_{type}.bam.log",
    benchmark:
        repeat(
            "alignment/fgbio_copy_umi_from_read_name/{sample}_{type}.bam.benchmark.tsv",
            config.get("fgbio_copy_umi_from_read_name", {}).get("benchmark_repeats", 1)
        )
    threads: config.get("fgbio_copy_umi_from_read_name", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("fgbio_copy_umi_from_read_name", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("fgbio_copy_umi_from_read_name", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("fgbio_copy_umi_from_read_name", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("fgbio_copy_umi_from_read_name", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("fgbio_copy_umi_from_read_name", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("fgbio_copy_umi_from_read_name", {}).get("container", config["default_container"])
    message:
        "{rule}: Copy UMI from read name to sam tag on {input.bam}"
    shell:
        "(picard CopyUmiFromReadName "
        "i={input.bam} "
        "o={output.bam} "
        "{params.exta}) &> {log}"


rule fgbio_call_and_filter_consensus_reads:
    input:
        bam="alignment/fgbio_copy_umi_from_read_name/{sample}_{type}.bam",
        bai="alignment/fgbio_copy_umi_from_read_name/{sample}_{type}.bam.bai",
    output:
        bam=temp("alignment/fgbio_call_and_filter_consensus_reads/{sample}_{type}.unmapped.bam"),
    params:
        extra_call=config.get("fgbio_call_and_filter_consensus_reads", {}).get("extra_call", ""),
        extra_filter=config.get("fgbio_call_and_filter_consensus_reads", {}).get("extra_filter", ""),
        max_base_error_rate=config.get("fgbio_call_and_filter_consensus_reads", {}).get("max_base_error_rate", "0.2"),
        min_reads_call=config.get("fgbio_call_and_filter_consensus_reads", {}).get("min_reads_call", "1"),
        min_reads_filter=config.get("fgbio_call_and_filter_consensus_reads", {}).get("min_reads_filter", "1"),
        min_input_base_quality_call=config.get("fgbio_call_and_filter_consensus_reads", {}).get("min_input_base_quality_call", "20"),
        min_input_base_quality_filter=config.get("fgbio_call_and_filter_consensus_reads", {}).get("min_input_base_quality_filter", "45"),
        reference=config.get("reference", {}).get("fasta", ""),
    log:
        "alignment/fgbio_call_and_filter_consensus_reads/{sample}_{type}.unmapped.bam.log",
    benchmark:
        repeat(
            "alignment/fgbio_call_and_filter_consensus_reads/{sample}_{type}.unmapped.bam.benchmark.tsv",
            config.get("fgbio_call_and_filter_consensus_reads", {}).get("benchmark_repeats", 1)
        )
    threads: config.get("fgbio_call_and_filter_consensus_reads", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("fgbio_call_and_filter_consensus_reads", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("fgbio_call_and_filter_consensus_reads", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("fgbio_call_and_filter_consensus_reads", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("fgbio_call_and_filter_consensus_reads", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("fgbio_call_and_filter_consensus_reads", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("fgbio_call_and_filter_consensus_reads", {}).get("container", config["default_container"])
    message:
        "{rule}: call and filter consensus reads in {input.bam} into an unmapped bam file"
    shell:
        'sh -c "'
        "fgbio -Xmx4g --compression 0 CallMolecularConsensusReads "
        "--input {input.bam} "
        "--output /dev/stdout "
        "--min-reads {params.min_reads} "
        "--min-input-base-quality {params.min_input_base_quality_call} "
        "--threads {threads} "
        "{params.extra_call} "
        "| fgbio -Xmx8g --compression 1 FilterConsensusReads "
        "--input /dev/stdin "
        "--output {output.bam} "
        "--ref {params.reference} "
        "--min-reads {params.min_reads_filter} "
        "--min-base-quality {params.min_input_base_quality_filter} "
        "--max-base-error-rate {params.max_base_error_rate} "
        '{params.extra_filter}" >& {log}'
