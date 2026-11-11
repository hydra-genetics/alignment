__author__ = "Camille Clouard"
__copyright__ = "Copyright 2026, Camille Clouard"
__email__ = "camille.clouard@scilifelab.uu.se"
__license__ = "GPL-3"


rule dorado_align:
    input:
        query=get_ont_query,
        reference=config.get("reference", {}).get("fasta", ""),
    output:
        bam=temp("alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}.dorado.bam"),
    params:
        extra=config.get("dorado_align", {}).get("extra", ""),
    log:
        "alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}.dorado.bam.log",
    benchmark:
        repeat(
            "alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}.dorado.bam.benchmark.tsv",
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


rule dorado_reheader:
    input:
        bam="alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}.dorado.bam",
        ubam=get_ubam_query,
    output:
        bam=temp("alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}_unsorted.bam"),
    params:
        extra=config.get("dorado_reheader", {}).get("extra", ""),
    log:
        "alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}_unsorted.bam.log",
    benchmark:
        repeat(
            "alignment/dorado_align/{sample}_{type}_{processing_unit}_{barcode}_unsorted.bam.benchmark.tsv",
            config.get("dorado_reheader", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("dorado_reheader", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("dorado_reheader", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("dorado_reheader", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("dorado_reheader", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("dorado_reheader", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("dorado_reheader", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("dorado_reheader", {}).get("container", config["default_container"])
    message:
        "{rule}: Restore the read group header lines of {input.ubam} in {input.bam}"
    shell:
        "(samtools view -H {input.ubam} | {{ grep '^@RG' || true; }} > {output.bam}.rg.sam && "
        "if [ -s {output.bam}.rg.sam ]; then "
        "samtools view -H {input.bam} "
        "| awk -v rg={output.bam}.rg.sam "
        "'$1 == \"@RG\" {{next}} "
        "$1 == \"@PG\" && !done {{while ((getline line < rg) > 0) print line; done = 1}} "
        "{{print}} "
        "END {{if (!done) while ((getline line < rg) > 0) print line}}' "
        "> {output.bam}.header.sam && "
        "samtools reheader {params.extra} {output.bam}.header.sam {input.bam} > {output.bam}; "
        "else cp {input.bam} {output.bam}; fi && "
        "rm -f {output.bam}.rg.sam {output.bam}.header.sam) "
        "2> {log}"
