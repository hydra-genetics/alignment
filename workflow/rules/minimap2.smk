__author__ = "Padraic Corcoran"
__copyright__ = "Copyright 2024, Padraic Corcoran"
__email__ = "padraic.corcoran@scilifelab.uu.se"
__license__ = "GPL-3"


rule minimap2_index:
    input:
        target=config.get("reference", {}).get("fasta", ""),
    output:
        mmi=expand(
            "minimap2_index/{ref}.{preset}.mmi",
            ref=os.path.basename(config.get("reference", {}).get("fasta", "")),
            preset=config.get("minimap2_align", {}).get("preset", ""),
        ),
    params:
        extra=set_minimap2_preset,
    log:
        "alignment/minimap2_index/minimap2_index.log",
    benchmark:
        repeat(
            "alignment/minimap2_index/minimap2_index.benchmark.tsv", config.get("minimap2_index", {}).get("benchmark_repeats", 1)
        )
    threads: config.get("minimap2_index", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("minimap2_index", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("minimap2_index", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("minimap2_index", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("minimap2_index", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("minimap2_index", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("minimap2_index", {}).get("container", config["default_container"])
    message:
        "{rule}: index {input.target} with minimap2"
    wrapper:
        "v4.3.0/bio/minimap2/index"


rule minimap2_align:
    input:
        query=lambda wildcards: get_minimap2_query(wildcards),
        target=rules.minimap2_index.output.mmi,
    output:
        bam=temp("alignment/minimap2_align/{sample}_{type}_{processing_unit}_{barcode}.bam"),
    params:
        extra=lambda wildcards, input: "%s %s -x %s"
        % (
            config.get("minimap2_align", {}).get("extra", ""),
            config.get("minimap2_align", {}).get("read_group", generate_minimap2_read_group(wildcards, input)),
            config.get("minimap2_align", {}).get("preset", ""),
        ),
        sorting=config.get("minimap2_align", {}).get("sort_order", "coordinate"),
        sort_extra=config.get("minimap2_align", {}).get("sort_extra", ""),
    log:
        "alignment/minimap2_align/{sample}_{type}_{processing_unit}_{barcode}.bam.log",
    benchmark:
        repeat(
            "alignment/minimap2_align/{sample}_{type}_{processing_unit}_{barcode}.bam.benchmark.tsv",
            config.get("minimap2_align", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("minimap2_align", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("minimap2_align", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("minimap2_align", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("minimap2_align", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("minimap2_align", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("minimap2_align", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("minimap2_align", {}).get("container", config["default_container"])
    message:
        "{rule}: run minimap2 to align reads from {input.query} to {input.target}"
    wrapper:
        "v4.3.0/bio/minimap2/aligner"


rule minimap2_merge:
    input:
        bams=lambda wildcards: [
            "alignment/minimap2_align/{sample}_{type}_%s_%s.bam" % (u.processing_unit, u.barcode)
            for u in get_units(units, wildcards)
        ],
    output:
        bam=temp("alignment/minimap2_align/{sample}_{type}.bam"),
    params:
        extra=config.get("minimap2_merge", {}).get("extra", ""),
    log:
        "alignment/minimap2_align/{sample}_{type}.bam.log",
    benchmark:
        repeat(
            "alignment/minimap2_align/{sample}_{type}.bam.benchmark.tsv",
            config.get("minimap2", {}).get("benchmark_repeats", 1),
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
        "{rule}: merge {input.bams} using samtools merge"
    wrapper:
        "v3.9.0/bio/samtools/merge"
