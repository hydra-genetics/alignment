# Hydra-genetics

We are an organization/community with the goal of making [snakemake](https://snakemake.readthedocs.io/en/stable/index.html) pipeline development easier, faster, a bit more structured and of higher quality.

We do this by providing [snakemake modules](https://snakemake.readthedocs.io/en/stable/snakefiles/modularization.html#modules) that can be combined to create a complete analysis or included in already existing pipelines. All modules are subjected to extensive testing to make sure that new releases doesn't unexpectedly break existing pipeline or deviate from guidelines and best practices on how to write code.

# Alignment module
The alignment module consists of alignment steps, such as alignment against a reference genome and duplicate filtering. The module takes `.fastq`-files as input and outputs `.bam`-files. BWA-mem is used to align DNA data while STAR is used for RNA data. Picard is used for duplicate marking and samtools for merging, sorting, and indexing `.bam`-files.
