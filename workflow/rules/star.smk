__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule star:
    input:
        fq1=lambda wildcards: alignment_input_read1(wildcards),
        fq2=lambda wildcards: alignment_input_read2(wildcards),
        idx=config.get("star", {}).get("genome_index", ""),
    output:
        bam=temp("alignment/star/{sample}_{flowcell}_{lane}_{barcode}_{type}.bam"),
        sj=temp("alignment/star/{sample}_{flowcell}_{lane}_{barcode}_{type}.SJ.out.tab"),
    params:
        extra=lambda wildcards: "%s %s"
        % (
            config.get("star", {}).get("extra", ""),
            config.get("star", {}).get("read_group", generate_read_group(wildcards, "star")),
        ),
        idx="{input.idx}",
    log:
        "alignment/star/{sample}_{type}.bam.log",
    benchmark:
        repeat("alignment/star/{sample}_{type}.bam.benchmark.tsv", config.get("star", {}).get("benchmark_repeats", 1))
    threads: config.get("star", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("star", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("star", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("star", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("star", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("star", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("star", {}).get("container", config["default_container"])
    conda:
        "../envs/star.yaml"
    message:
        "{rule}: align with star, creating {output.bam}"
    wrapper:
        "v1.3.2/bio/star/align"
