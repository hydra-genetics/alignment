__author__ = "Padraic Corcoran"
__copyright__ = "Copyright 2024, Padraic Corcoran"
__email__ = "padraic.corcoran@scilifelab.uu.se"
__license__ = "GPL-3"


rule pbmm2_index:
    input:
        reference=config.get("reference", {}).get("fasta", ""),
    output:
        expand("{ref}_{preset}.mmi", 
        ref=config.get("reference", {}).get("fasta", ""),
        preset=config.get("pbmm2_align", {}).get("preset", "")
        )
    params:
        preset=config.get("pbmm2_align", {}).get("preset", ""),
        extra=config.get("pbmm2_index", {}).get("extra", ""),
    log:
        "alignment/pbmm2_index/pbmm2_index.log",
    benchmark:
        repeat(
            "alignment/pbmm2_index/pbmm2_index.benchmark.tsv",
            config.get("pbmm2_index", {}).get("benchmark_repeats", 1)
        )
    threads: config.get("pbmm2_index", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("pbmm2_index", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("pbmm2_index", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("pbmm2_index", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("pbmm2_index", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("pbmm2_index", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("pbmm2_index", {}).get("container", config["default_container"])
    message:
        "{rule}: index {input.reference} with pbmm2"
    wrapper:
        "v4.3.0/bio/pbmm2/index"


rule pbmm2_align:
    input:
        query=lambda wildcards: get_minimap2_query(wildcards),
        reference=expand("{ref}_{preset}.mmi", 
        ref=config.get("reference", {}).get("fasta", ""),
        preset=config.get("pbmm2_align", {}).get("preset", "")
        )
    output:
        bam="alignment/pbmm2_align/{sample}_{type}_{processing_unit}_{barcode}.bam",
    params:
        preset=config.get("pbmm2_align", {}).get("preset", ""),
        sample=lambda wildcards: wildcards.sample,
        loglevel="INFO",
        extra=" --sort %s " % (config.get("pbmm2_align", {}).get("extra", "")),
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
        "v4.3.0/bio/pbmm2/align"


rule pbmm2_merge:
    input:
        bams=lambda wildcards: [
            "alignment/pbmm2_align/{sample}_{type}_%s_%s.bam" % (u.processing_unit, u.barcode) for u in get_units(units, wildcards)
        ],
    output:
        bam=temp("alignment/pbmm2_align/{sample}_{type}.bam"),
    params:
        extra=config.get("pbmm2_align", {}).get("extra", ""),
    log:
        "alignment/pbmm2_align/{sample}_{type}_unsorted.bam.log",
    benchmark:
        repeat(
            "alignment/pbmm2_align/{sample}_{type}_unsorted.bam.benchmark.tsv",
            config.get("pbmm2_align", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("pbmm2_merge", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("pbmm2_merge", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("pbmm2_merge", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("pbmm2_merge", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("pbmm2_merge", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("pbmm2_merge", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("pbmm2_merge", {}).get("container", config["default_container"])
    message:
        "{rule}: merge bam file {input} using samtools"
    wrapper:
        "v3.9.0/bio/samtools/merge"
