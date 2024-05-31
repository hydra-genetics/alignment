__author__ = "Padraic Corcoran and Magdalena"
__copyright__ = "Copyright 2023, Uppsala universitet"
__email__ = "padraic.corcoran@scilifelab.uu.se"
__license__ = "GPL-3"

rule pbmm2_align:
    input:
        reference=config.get("pbmm2_align", {}).get("index", ""),
        query=pbmm2_input,
    output:
        bam="long_read/pbmm2_align/{sample}_{type}_{processing_unit}_{barcode}.pbmm2.bam",
    params:
        preset=config.get("pbmm2_align", {}).get("preset", ""),
        sample=lambda wildcards: wildcards.sample,
        loglevel="INFO",
        extra=config.get("pbmm2_align", {}).get("extra", ""),
    log:
        bam="long_read/pbmm2_align/{sample}_{type}_{processing_unit}_{barcode}.bam.log",
    benchmark:
        repeat(
            "long_read/pbmm2_align/{sample}_{type}_{processing_unit}_{barcode}.bam.benchmark.tsv",
            config.get("pbmm2_align", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("pbmm2_align", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("pbmm2_align", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("pbmm2_align", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("pbmm2_align", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("pbmm2_align", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("pbmm2_align", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("pbmm2_align", {}).get("container", config["default_container"])
    message:
        "{rule}: Align reads in {input.query} against {input.reference}"
    wrapper:
        "v1.28.0/bio/pbmm2/align"
