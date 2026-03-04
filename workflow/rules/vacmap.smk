rule vacmap_align:
    input:
        ubam=get_ubam_input,
        ref=config.get("reference", {}).get("fasta"),
    output:
        "alignment/vacmap_align/{sample}_{type}.sorted.bam",
    params:
        mode=config.get("vacmap_align", {}).get("mode", "L"),
        extra=config.get("vacmap_align", {}).get("extra", ""),
    log:
        "alignment/vacmap_align/{sample}_{type}.bam.log",
    benchmark:
        repeat(
            "alignment/vacmap_align/{sample}_{type}.bam.benchmark.tsv",
            config.get("vacmap_align", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("vacmap_align", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("vacmap_align", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("vacmap_align", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("vacmap_align", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("vacmap_align", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("vacmap_align", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("vacmap_align", {}).get("container", config["default_container"])
    message:
        "{rule}: align {input.ubam} with vacmap"
    shell:
        "vacmap -ref {input.ref} -read {input.ubam} -mode {params.mode} -o {output} -t {threads} {params.extra}"
