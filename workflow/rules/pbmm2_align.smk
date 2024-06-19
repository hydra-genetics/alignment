__author__ = "Padraic Corcoran"
__copyright__ = "Copyright 2024, Padraic Corcoran"
__email__ = "padraic.corcoran@scilifelab.uu.se"
__license__ = "GPL-3"


rule pbmm2_align:
    input:
        reference=config.get("pbmm2_align", {}).get("index", ""),
        query=pbmm2_input,
    output:
        bam="alignment/pbmm2_align/{sample}_{type}_{processing_unit}_{barcode}.bam",
    params:
        preset=config.get("pbmm2_align", {}).get("preset", ""),
        sample=lambda wildcards: wildcards.sample,
        loglevel="INFO",
        extra=config.get("pbmm2_align", {}).get("extra", ""),
    log:
        bam="alignment/pbmm2_align/{sample}_{type}_{processing_unit}_{barcode}.bam.log",
    benchmark:
        repeat(
            "alignment/pbmm2_align/{sample}_{type}_{processing_unit}_{barcode}.bam.benchmark.tsv",
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


rule pbmm2_merge:
    input:
        bams=lambda wildcards: [
            "alignment/pbmm2_align/{sample}_{type}_%s_%s.bam" % (u.processing_unit, u.barcode)
            for u in get_units(units, wildcards)
        ],
    output:
        bam=temp("alignment/pbmm2_align/{sample}_{type}_unsorted.bam"),
    params:
        extra=config.get("minimap2_merge", {}).get("extra", ""),
    log:
        "alignment/pbmm2_align/{sample}_{type}_unsorted.bam.log",
    benchmark:
        repeat(
            "alignment/pbmm2_align/{sample}_{type}_unsorted.bam.benchmark.tsv",
            config.get("minimap2_merge", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("minimap2_merge", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("minimap2_merge", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("minimap2_merge", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("minimap2_merge", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("minimap2_merge", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("minimap2_merge", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("minimap2_merge", {}).get("container", config["default_container"])
    message:
        "{rule}: merge bam file {input} using samtools"
    wrapper:
        "v3.9.0/bio/samtools/merge"
