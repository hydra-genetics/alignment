__author__ = "Andrei Guliaev"
__copyright__ = "Copyright 2026, Andrei Guliaev"
__email__ = "andrei.guliaev@scilifelab.uu.se"
__license__ = "GPL-3"


rule vacmap_index:
    input:
        fasta=config.get("reference", {}).get("fasta", ""),
    output:
        mmi=expand(
            "alignment/vacmap_index/{ref}.w{window_size}_k{kmer_size}.mmi",
            ref=os.path.basename(config.get("reference", {}).get("fasta", "")),
            window_size=config.get("vacmap_index", {}).get("window_size", 10),
            kmer_size=config.get("vacmap_index", {}).get("kmer_size", 15),
        ),
    params:
        kmer_size=config.get("vacmap_index", {}).get("kmer_size", 15),
        window_size=config.get("vacmap_index", {}).get("window_size", 10),
        extra=config.get("vacmap_index", {}).get("extra", ""),
    log:
        "alignment/vacmap_index/vacmap_index.log",
    benchmark:
        repeat(
            "alignment/vacmap_index/vacmap_index.benchmark.tsv",
            config.get("vacmap_index", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("vacmap_index", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("vacmap_index", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("vacmap_index", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("vacmap_index", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("vacmap_index", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("vacmap_index", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("vacmap_index", {}).get("container", config["default_container"])
    message:
        "{rule}: index {input.fasta} with minimap2 for vacmap"
    shell:
        "minimap2 -d {output.mmi} -w {params.window_size} -k {params.kmer_size} -I 1000G -t {threads} {params.extra} {input.fasta} 2> {log}"


rule vacmap_align:
    input:
        ubam=lambda wildcards: get_ubam_query(wildcards),
        index=expand(
            "alignment/vacmap_index/{ref}.w{window_size}_k{kmer_size}.mmi",
            ref=os.path.basename(config.get("reference", {}).get("fasta", "")),
            window_size=config.get("vacmap_index", {}).get("window_size", 10),
            kmer_size=config.get("vacmap_index", {}).get("kmer_size", 15),
        ),
    output:
        bam=temp("alignment/vacmap_align/{sample}_{type}_{processing_unit}_{barcode}.sorted.bam"),
    params:
        kmer_size=config.get("vacmap_index", {}).get("kmer_size", 15),
        mode=config.get("vacmap_align", {}).get("mode", "L"),
        window_size=config.get("vacmap_index", {}).get("window_size", 10),
        read_group=lambda wildcards, input: generate_longread_group(wildcards, input, tool="vacmap"),
        extra=config.get("vacmap_align", {}).get("extra", ""),
    log:
        "alignment/vacmap_align/{sample}_{type}_{processing_unit}_{barcode}.sorted.bam.log",
    benchmark:
        repeat(
            "alignment/vacmap_align/{sample}_{type}_{processing_unit}_{barcode}.sorted.bam.benchmark.tsv",
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
        "vacmap -ref {input.index} -read {input.ubam} -mode {params.mode} -k {params.kmer_size} -w {params.window_size} "
        "-o {output} -t {threads} {params.read_group} {params.extra} 2> {log}"


rule vacmap_merge:
    input:
        bams=lambda wildcards: [
            "alignment/vacmap_align/{sample}_{type}_%s_%s.sorted.bam" % (u.processing_unit, u.barcode)
            for u in get_units(units, wildcards)
        ],
    output:
        bam=temp("alignment/vacmap_align/{sample}_{type}.bam"),
    params:
        extra=config.get("vacmap_merge", {}).get("extra", ""),
    log:
        "alignment/vacmap_align/{sample}_{type}.bam.log",
    benchmark:
        repeat(
            "alignment/vacmap_align/{sample}_{type}.bam.benchmark.tsv",
            config.get("vacmap_merge", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("vacmap_merge", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("vacmap_merge", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("vacmap_merge", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("vacmap_merge", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("vacmap_merge", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("vacmap_merge", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("vacmap_merge", {}).get("container", config["default_container"])
    message:
        "{rule}: merge {input.bams} using samtools merge"
    wrapper:
        "v3.9.0/bio/samtools/merge"
