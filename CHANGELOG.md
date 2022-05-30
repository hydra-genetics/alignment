# Changelog

## [0.2.0](https://www.github.com/hydra-genetics/alignment/compare/v0.1.0...v0.2.0) (2022-05-30)


### Features

* new schemas for reference files ([03de2f5](https://www.github.com/hydra-genetics/alignment/commit/03de2f5b7a0264c9cfaccab08029d8738f38adf5))
* run different schemas dependent on sample type ([5c44fbd](https://www.github.com/hydra-genetics/alignment/commit/5c44fbdc3c3273841881f9cc8378b30a6b073e16))
* star alignment rule ([e40fb0d](https://www.github.com/hydra-genetics/alignment/commit/e40fb0d5a4fecd27f539f9b42058999fdf93db29))
* update name of compatibility test ([9691276](https://www.github.com/hydra-genetics/alignment/commit/9691276d4c7f9bd1ba42ef3523ec44a4a800b278))


### Bug Fixes

* Add snakemake wrapper utils to samtools env ([6b3ed44](https://www.github.com/hydra-genetics/alignment/commit/6b3ed44c1d6915f127e3366fd2a38bd6f66056b7))
* add temp on outfiles ([ec1d408](https://www.github.com/hydra-genetics/alignment/commit/ec1d408696d55f022e59022e96e74955febbdac5))
* also handle unit type T ([f9aebeb](https://www.github.com/hydra-genetics/alignment/commit/f9aebeb76096db0f35a995c3aa3b20abb78f0895))
* change to version of samtools sort that uses temp directory ([f5830a0](https://www.github.com/hydra-genetics/alignment/commit/f5830a0c1d0f7f51fc8b3b7e206e1599cc6fb621))
* changes due to comments ([428b79f](https://www.github.com/hydra-genetics/alignment/commit/428b79f88f6e5ba340122c9d2089cc899561b60c))
* remove hardcoded reference key ([7038c32](https://www.github.com/hydra-genetics/alignment/commit/7038c3297e7ab208cc0ea596c08adf2fc9e604f1))
* requirements ([6a887cb](https://www.github.com/hydra-genetics/alignment/commit/6a887cbc81a1dc160c578eab79674118741e0b91))
* suggested changes ([b6fc85e](https://www.github.com/hydra-genetics/alignment/commit/b6fc85ef5d6ec4ec808d7bca20835d2f0fbb1350))
* suggested changes ([4563bc1](https://www.github.com/hydra-genetics/alignment/commit/4563bc126dc38588f801d4d5d254b363d781ebc8))
* updated schema ([e3cf603](https://www.github.com/hydra-genetics/alignment/commit/e3cf603813f73760cd6ba52855e1e7b1b2e8d287))

## 0.1.0 (2022-04-19)


### Features

* Adapt rules and Snakefile to standard ([01d71e5](https://www.github.com/hydra-genetics/alignment/commit/01d71e520df4e2a15b9693d0cf2993d20d36d123))
* Adapt rules and Snakefile to standard ([4d43741](https://www.github.com/hydra-genetics/alignment/commit/4d43741abc28f0bf8a8563bfa53a1b0007e46fee))
* add compatibility file ([b240f15](https://www.github.com/hydra-genetics/alignment/commit/b240f1520e97a5d544c195bc0d92b307dcf57bba))
* add conventional-prs workflow ([47975b1](https://www.github.com/hydra-genetics/alignment/commit/47975b11d84bd2f88e656e2058bb8632dec494d3))
* add conventional-prs workflow ([debdd9a](https://www.github.com/hydra-genetics/alignment/commit/debdd9a0b09bc14e93903d9368761d9f5cada378))
* add resources usage to rules. ([0afb759](https://www.github.com/hydra-genetics/alignment/commit/0afb7592cfa039179651d33ee864cd7fcec33eb4))
* add resources usage to rules. ([5f73322](https://www.github.com/hydra-genetics/alignment/commit/5f73322da05108c7d42000a194ef8662317f8b24))
* add venv to gitignore. ([f460675](https://www.github.com/hydra-genetics/alignment/commit/f460675eaa6a4f61ccec3ae7abc41065e45f34a7))
* add venv to gitignore. ([41cce37](https://www.github.com/hydra-genetics/alignment/commit/41cce379db2ea2d2f0e0c401347cfaaffff5bb15))
* added release-please workflow ([b646a9f](https://www.github.com/hydra-genetics/alignment/commit/b646a9f58b78c780640700a5d58e8e333af07694))
* added release-please workflow ([877b761](https://www.github.com/hydra-genetics/alignment/commit/877b76100a1c2f2d4107741e3bf1252449a4bd56))
* Added rule merge_bam ([9c888ac](https://www.github.com/hydra-genetics/alignment/commit/9c888ac0dfb0d7895c9d372380a6666d2db852c3))
* Added rule merge_bam ([281c237](https://www.github.com/hydra-genetics/alignment/commit/281c237cc66d0236292f047b60d663b691310efe))
* lock mamba version ([7d4d1ed](https://www.github.com/hydra-genetics/alignment/commit/7d4d1ed220d278afe92484c4a80d66a7a9855e07))
* make input for alignment configurable. ([856e585](https://www.github.com/hydra-genetics/alignment/commit/856e5852145b2ec106392dfc1db225002e37078a))
* make input for alignment configurable. ([dddd8a0](https://www.github.com/hydra-genetics/alignment/commit/dddd8a00235fc015fa6f421ff4e6ca32e6f35bfb))
* New rules: mark_duplicates and samtools_index. Also some corrections to extract_reads ([30cdb91](https://www.github.com/hydra-genetics/alignment/commit/30cdb912706081151d5565363b4726b39357c6aa))
* New rules: mark_duplicates and samtools_index. Also some corrections to extract_reads ([d493cf4](https://www.github.com/hydra-genetics/alignment/commit/d493cf43206ff7cf80d7d8c8d64fb2333fedd2f7))
* rule used to extract reads from one chr ([3f4eb02](https://www.github.com/hydra-genetics/alignment/commit/3f4eb0212e40cc2d47177c46e888bdbd1627d254))
* rule used to extract reads from one chr ([1bce758](https://www.github.com/hydra-genetics/alignment/commit/1bce758aa5c9303600a8015081e143536ca699ca))
* setup compatibility test will make sure to catch when prealignment and alignment aren't compatible. ([7a28213](https://www.github.com/hydra-genetics/alignment/commit/7a28213a2208494873288949e93ad6f1ce1bc131))
* update pull-request template. ([21d7e64](https://www.github.com/hydra-genetics/alignment/commit/21d7e6489e97f05bcf284a3f8fd649bb775c37ff))
* update read groups. ([62dca55](https://www.github.com/hydra-genetics/alignment/commit/62dca5580f6d1720719e2827f468878af8aa0c1c))
* update read groups. ([d309352](https://www.github.com/hydra-genetics/alignment/commit/d30935229fe4059c359201085e0ea9842c680fdc))
* update to hydra-genetics version 0.9.2 ([f34e59a](https://www.github.com/hydra-genetics/alignment/commit/f34e59a585b2c636ff3d09eec8929c19ccecb710))
* update to newer version of hydra-genetics. ([670e212](https://www.github.com/hydra-genetics/alignment/commit/670e212d0192f5901c5fb48addd9fc28f589c89c))
* update to newer version of hydra-genetics. ([ac3fbac](https://www.github.com/hydra-genetics/alignment/commit/ac3fbacf5d755962653182d511cfdd77fe281600))


### Bug Fixes

* add missing software ([af6bcb4](https://www.github.com/hydra-genetics/alignment/commit/af6bcb4fa2098fbbd6c124444137ef465ca0b078))
* added type to sample name in BWA ([f3edfda](https://www.github.com/hydra-genetics/alignment/commit/f3edfda219296fa14ba8771f0ede3ddb17d8ea48))
* added type to sample name in BWA ([cd8f83d](https://www.github.com/hydra-genetics/alignment/commit/cd8f83d80eb017e5a0fd8dc05715332cccbaf50c))
* change run column name to flowcell in units. ([3ec6417](https://www.github.com/hydra-genetics/alignment/commit/3ec6417c67cd86f0bdea6b1d40585a8a13edfa27))
* change run column name to flowcell in units. ([18048ea](https://www.github.com/hydra-genetics/alignment/commit/18048ea09ed70d20a7ec6896ce8f622630c1ccff))
* change to older wrapper of samtools merge that aren't using wrapper utils. make bwa_mem rule compatible with bwa-wrapper ([c4fa9ab](https://www.github.com/hydra-genetics/alignment/commit/c4fa9abb7bda6610683ba343cc98c554b89fee62))
* change to older wrapper of samtools merge that aren't using wrapper utils. make bwa_mem rule compatible with bwa-wrapper ([042c935](https://www.github.com/hydra-genetics/alignment/commit/042c93573050b3162a45f748818389fca581c057))
* change version of all samtool wrappers ([eba51e6](https://www.github.com/hydra-genetics/alignment/commit/eba51e6aa90cd5fa19828b75b8644e48cac1a189))
* fix codestyle. ([d43ba8e](https://www.github.com/hydra-genetics/alignment/commit/d43ba8edab9fa7fc26b9f4d0b4e6d1c0fc872be6))
* fix codestyle. ([9ed95dc](https://www.github.com/hydra-genetics/alignment/commit/9ed95dc7e683584c4be698f0e16fe5821d7f4fbf))
* fix codestyle. ([f6f0fae](https://www.github.com/hydra-genetics/alignment/commit/f6f0fae230ec0bb8163bb63e574d9cd3633a2211))
* handle case when rule have settings but no resources set. ([9cdf5d8](https://www.github.com/hydra-genetics/alignment/commit/9cdf5d848334d0045a4f900a51c2d9e71d451aa7))
* handle case when rule have settings but no resources set. ([9e8080c](https://www.github.com/hydra-genetics/alignment/commit/9e8080cfa00959989841ca95c6173ebe3ce66375))
* newer version of codestyle. ([4bdb3c9](https://www.github.com/hydra-genetics/alignment/commit/4bdb3c971822c915a363ceaa20e027ef111ae5d4))
* newer version of codestyle. ([36a7de9](https://www.github.com/hydra-genetics/alignment/commit/36a7de90b446db46c39ca9cebe966550d17ae8f5))
* style and missing import. ([1ffb7cf](https://www.github.com/hydra-genetics/alignment/commit/1ffb7cf625510707e313bd6dcabbb9d0e68c6824))
* style and missing import. ([49d3436](https://www.github.com/hydra-genetics/alignment/commit/49d3436a100742e7350b13a25a6e9549d55a2cac))
* update according to review comments. ([cd636ba](https://www.github.com/hydra-genetics/alignment/commit/cd636ba94d8685765ee6e39a1cdfc762211fdf7c))
* update according to review comments. ([9b53891](https://www.github.com/hydra-genetics/alignment/commit/9b53891324c02d389addcfec9c5756072b3757d4))
* update conda env ([cc50ffc](https://www.github.com/hydra-genetics/alignment/commit/cc50ffcd161fb76bcf9ee01f68711f18b9f1b12f))
* update conda env ([dc91eec](https://www.github.com/hydra-genetics/alignment/commit/dc91eeca12581ce4997e53a30fd31b2c37261ed9))
* update read group ([41de4b4](https://www.github.com/hydra-genetics/alignment/commit/41de4b4bd5905d1e146ee48d8ddb414325c066a9))


### Documentation

* pull-request template ([df2ed30](https://www.github.com/hydra-genetics/alignment/commit/df2ed30503cf96e3d58d64ead83bb4df6341a9fb))
* pull-request template ([a30d199](https://www.github.com/hydra-genetics/alignment/commit/a30d1997af516b23a3c06adf45223e5e57c5b794))
* update compatibility list ([095c962](https://www.github.com/hydra-genetics/alignment/commit/095c9626cd3b4f8c62686a65e633d7ca3797c69e))
