__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule star:
    input:
        fq1="prealignment/merged/{sample}_{type}_fastq1.fastq.gz",
        fq2="prealignment/merged/{sample}_{type}_fastq2.fastq.gz",
        idx=config.get("star", {}).get("genome_index", ""),
    output:
        bam=temp("alignment/star/{sample}_{type}.bam"),
        sj=temp("alignment/star/{sample}_{type}.SJ.out.tab"),
    params:
        extra=config.get("star", {}).get("extra", "--outSAMtype BAM SortedByCoordinate"),
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
