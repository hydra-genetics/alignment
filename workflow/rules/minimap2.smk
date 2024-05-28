__author__ = "Padraic Corcoran"
__copyright__ = "Copyright 2024, Padraic Corcoran"
__email__ = "padraic.corcoran@scilifelab.uu.se"
__license__ = "GPL-3"


rule minimap2:
    input:
        query=lambda wildcards: get_minimap2_query(wildcards),
        target=config.get("minimap2", {}).get("mmi", ""),
    output:
        bam=str("alignment/minimap2/{sample}.mm2.bam"),
    params:
        extra=lambda wildcards, input: "%s %s -x %s"
        % (
            config.get("minimap2", {}).get("extra", ""),
            config.get("minimap2", {}).get("read_group", generate_minimap2_read_group(wildcards, input)),
            config.get("minimap2", {}).get("preset", "map-ont"),
        ),
        sorting=config.get("minimap2", {}).get("sort_order", "coordinate"),
        sort_extra=config.get("minimap2", {}).get("sort_extra", ""),
    log:
        "alignment/minimap2/{sample}.bam.log",
    benchmark:
        repeat(
            "alignment/minimap2/{sample}.bam.benchmark.tsv",
            config.get("minimap2", {}).get("benchmark_repeats", 1),
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
        "v3.9.0/bio/minimap2/aligner"


