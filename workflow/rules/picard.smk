__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule picard_mark_duplicates:
    input:
        "alignment/samtools_extract_reads/{sample}_{type}_{chr}.bam",
    output:
        bam=temp("alignment/picard_mark_duplicates/{sample}_{type}_{chr}.bam"),
        metrics=temp("alignment/picard_mark_duplicates/{sample}_{type}_{chr}.metrics.txt"),
    params:
        extra=config.get("picard_mark_duplicates", {}).get("extra", ""),
    log:
        "alignment/picard_mark_duplicates/{sample}_{type}_{chr}.bam.log",
    benchmark:
        repeat(
            "alignment/picard_mark_duplicates/{sample}_{type}_{chr}.bam.benchmark.tsv",
            config.get("picard_mark_duplicates", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("picard_mark_duplicates", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("picard_mark_duplicates", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("picard_mark_duplicates", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("picard_mark_duplicates", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("picard_mark_duplicates", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("picard_mark_duplicates", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("picard_mark_duplicates", {}).get("container", config["default_container"])
    message:
        "{rule}: mark duplicates in {input} using picard"
    wrapper:
        "v1.3.1/bio/picard/markduplicates"
