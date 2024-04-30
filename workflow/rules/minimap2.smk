__author__ = "Padraic Corcoran"
__copyright__ = "Copyright 2024, Padraic Corcoran"
__email__ = "padraic.corcoran@scilifelab.uu.se"
__license__ = "GPL-3"


rule minimap2:
    input:
        query=lambda wildcards: get_minimap2_query(wildcards),
        target=config.get("minimap2", {}).get("mmi", ""),
    output:
        bam="alignment/minimap2/{sample}_{type}_{processing_unit}_{barcode}.bam",
    params:
        extra=lambda wildcards, input: "%s %s -x %s"
        % (
            config.get("minimap2", {}).get("extra", ""),
            config.get("minimap2", {}).get("read_group", generate_minimap2_read_group(wildcards, input)),
            config.get("minimap2", {}).get("preset","map-ont")
        ),
        sorting=config.get("minimap2", {}).get("sort_order", "coordinate"),
        sort_extra="-@ %s"
        % str(config.get("minimap2", config["default_resources"]).get("threads", config["default_resources"]["threads"])),
    log:
        "alignment/minimap2/{sample}_{type}_{processing_unit}_{barcode}.bam.log",
    benchmark:
        repeat(
            "alignment/minimap2/{sample}_{type}_{processing_unit}_{barcode}.bam.benchmark.tsv",
            config.get("minimap2", {}).get("benchmark_repeats", 1)
        )
    threads: config.get("minimap2", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("minimap2", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("minimap2", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("minimap2", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("minimap2", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("minimap2", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("minimap2", {}).get("container", config["default_container"])
    message:
        "{rule}: run minimap2 on {input}"
    wrapper:
        "v3.5.0/bio/minimap2/aligner"


rule minimap2_merge:
    input:
        bams=lambda wildcards: [
            "alignment/minimap2/{sample}_{type}_%s_%s.bam" % (u.processing_unit, u.barcode)
            for u in get_units(units, wildcards)
        ],
    output:
        bam="alignment/minimap2/{sample}_{type}.bam_unsorted",
    params:
        extra=config.get("minimap2", {}).get("extra", ""),
    log:
        "alignment/minimap2/{sample}_{type}.bam_unsorted.bam.log",
    benchmark:
        repeat(
            "alignment/minimap2/{sample}_{type}bam_unsorted.bam.benchmark.tsv",
            config.get("minimap2", {}).get("benchmark_repeats", 1)
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
        "v3.5.0/bio/samtools/merge"
