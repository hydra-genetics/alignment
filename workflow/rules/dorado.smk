__author__ = "Camille Clouard"
__copyright__ = "Copyright 2026, Camille Clouard"
__email__ = "camille.clouard@scilifelab.uu.se"
__license__ = "GPL-3"


rule dorado_align:
    input:
        query=lambda wildcards: get_ubam_query(wildcards),
        reference=config.get("reference", {}).get("fasta", ""),
    output:
        bam=temp("alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}.bam"),
    params:
        extra=config.get("dorado_align", {}).get("extra", ""),
    log:
        "alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}.bam.log",
    benchmark:
        repeat(
            "alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}.bam.benchmark.tsv",
            config.get("dorado_align", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("dorado_align", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("dorado_align", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("dorado_align", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("dorado_align", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("dorado_align", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("dorado_align", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("dorado_align", {}).get("container", config["default_container"])
    message:
        "{rule}: Align ONT reads in {input.query} against {input.reference} with dorado"
    shell:
        "(dorado aligner "
        "--threads {threads} "
        "{params.extra} "
        "{input.reference} "
        "{input.query} "
        "> {output.bam}) "
        "2> {log}"
