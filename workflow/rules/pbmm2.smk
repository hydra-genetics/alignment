__author__ = "Padraic Corcoran and Magdalena"
__copyright__ = "Copyright 2024, Padraic Corcoran and Magdalena"
__email__ = "padraic.corcoran@scilifelab.uu.se"
__license__ = "GPL-3"


rule pbmm2:
    input:
        input1="...",
    output:
        output1="alignment/pbmm2/{sample}_{type}.output.txt",
    params:
        extra=config.get("pbmm2", {}).get("extra", ""),
    log:
        "alignment/pbmm2/{sample}_{type}.output.log",
    benchmark:
        repeat(
            "alignment/pbmm2/{sample}_{type}.output.benchmark.tsv",
            config.get("pbmm2", {}).get("benchmark_repeats", 1)
        )
    threads: config.get("pbmm2", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("pbmm2", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("pbmm2", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("pbmm2", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("pbmm2", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("pbmm2", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("pbmm2", {}).get("container", config["default_container"])
    message:
        "{rule}: do stuff on {input.input1}"
    wrapper:
        "..."
