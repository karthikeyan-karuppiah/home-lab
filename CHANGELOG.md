# Changelog

## [1.3.4](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.3.3...v1.3.4) (2026-11-25)


### Bug Fixes

* **doco-cd:** increase auto-discovery depth to 6 ([c0365bf](https://github.com/karthikeyan-karuppiah/home-lab/commit/c0365bf12ecde1560b4638fdc571e67255f62952))
* **lint:** add missing trailing newline in docker-compose.yml ([272ea0a](https://github.com/karthikeyan-karuppiah/home-lab/commit/272ea0a5979b2526d03e475003258e47e98ec74e))
* **navidrome:** fix volume permissions and compose v2 resource schema ([52e3018](https://github.com/karthikeyan-karuppiah/home-lab/commit/52e30188286548422506ebfd2fc58b25e52475e3))
* **navidrome:** remove broken sha256 image digest pin ([828c50d](https://github.com/karthikeyan-karuppiah/home-lab/commit/828c50d3fb25b7efa2d96a333d3049769887e491))
* **user:** bring back the user who owns 1000 ([9512ad4](https://github.com/karthikeyan-karuppiah/home-lab/commit/9512ad47dfccb1b0cd82acc8932ef7ff213b65af))
* **user:** bring back the user who owns 1000 ([4a1afed](https://github.com/karthikeyan-karuppiah/home-lab/commit/4a1afed547ffb42b05365cb901afeb85c4817307))
* **user:** bring back the user who owns the Volumewq ([9c1f501](https://github.com/karthikeyan-karuppiah/home-lab/commit/9c1f5011fab3243857ee18b6d07e474432b3b8be))


### Documentation

* **architecture:** add six-stage mermaid sequence diagram for packet journey ([9c33308](https://github.com/karthikeyan-karuppiah/home-lab/commit/9c3330889e8348bf8de4a205c24d70e0421fd38e))


### Miscellaneous Chores

* **deps:** update ghcr.io/kimdre/doco-cd docker tag to v0.134.0 ([5c7cf51](https://github.com/karthikeyan-karuppiah/home-lab/commit/5c7cf511116db907c41a10d73892c77041ac1176))
* **deps:** update renovate/renovate docker tag to v44.239.1 ([1f9a641](https://github.com/karthikeyan-karuppiah/home-lab/commit/1f9a641d6c2443ae306b5aa005af1967a02e4fb4))


### Code Refactoring

* **navidrome:** harden application runtime context and isolate ingress port ([a04c778](https://github.com/karthikeyan-karuppiah/home-lab/commit/a04c7784593a9cefc717811ed0d2d97d2add2bc6)), closes [#14](https://github.com/karthikeyan-karuppiah/home-lab/issues/14)

## [1.3.3](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.3.2...v1.3.3) (2026-11-23)


### Bug Fixes

* **navidrome:** replace placeholder username in docker volume paths ([23d0d44](https://github.com/karthikeyan-karuppiah/home-lab/commit/23d0d44c52e6568d73f96e9699d5388f1feaced2))

## [1.3.2](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.3.1...v1.3.2) (2026-11-23)


### Miscellaneous Chores

* **deps:** update ghcr.io/0xerr0r/blocky docker tag to v0.36.0 ([8fffcf4](https://github.com/karthikeyan-karuppiah/home-lab/commit/8fffcf4e25fe3907eb00b909fc942a6d39b41791))

## [1.3.1](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.3.0...v1.3.1) (2026-11-22)


### Bug Fixes

* **authelia:** align session cookie URLs with NPM standard HTTPS ([25488ba](https://github.com/karthikeyan-karuppiah/home-lab/commit/25488bad05ad9261236ec6cee33cbccb35e35c75))
* **authelia:** align session cookie URLs with root domain on standard HTTPS ([d67f3da](https://github.com/karthikeyan-karuppiah/home-lab/commit/d67f3da4043427e0fd9658569efc2266e53d5718))
* **authelia:** restore :8443 port in session cookie URLs to match NPM ([0091b33](https://github.com/karthikeyan-karuppiah/home-lab/commit/0091b3344d41bc4b462a58a3006f8dc0757da62f))
* **authelia:** set session cookie URLs to standard HTTPS subdomains ([2da0f48](https://github.com/karthikeyan-karuppiah/home-lab/commit/2da0f4848b68668272c58acab94de0efc44fddb9))

## [1.3.0](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.2.0...v1.3.0) (2026-11-22)


### Features

* **observability:** enable prometheus metrics scraping for blocky ([907bbb1](https://github.com/karthikeyan-karuppiah/home-lab/commit/907bbb159907aa7432cb56de3f6df50b5ae38719))


### Miscellaneous Chores

* **renovate:** configure tiered automerge and perimeter safety overrides ([11aaf2b](https://github.com/karthikeyan-karuppiah/home-lab/commit/11aaf2b3185cf20018fbf37c1d0a151a96854a5b))

## [1.2.0](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.1.4...v1.2.0) (2026-11-16)


### Features

* **blocky:** add custom DNS mappings for auth.home.lab and music.home.lab ([7685181](https://github.com/karthikeyan-karuppiah/home-lab/commit/7685181e8204a7a550a31eca30ca0da59322a579))
* **identity:** introduce Authelia as central identity provider ([83cf025](https://github.com/karthikeyan-karuppiah/home-lab/commit/83cf02587c66e63b782f5af73f6f00c95e0660d8))
* **identity:** introduce Authelia as central identity provider ([1890d8d](https://github.com/karthikeyan-karuppiah/home-lab/commit/1890d8d353d60c9539eeebe7c3d042f8ff735b04))
* **identity:** introduce Authelia as central identity provider ([bf89513](https://github.com/karthikeyan-karuppiah/home-lab/commit/bf895133854c30de022ab736e20c22cda71a626b))


### Bug Fixes

* **authelia:** add port 8443 to authelia_url and default_redirection_url ([1e27fe2](https://github.com/karthikeyan-karuppiah/home-lab/commit/1e27fe29ba6947c6d54011526ff43b8444b0a7d3))
* **authelia:** Authelia password hash escaping in secrets.enc.env and WebAuthn config warning ([7aa68e8](https://github.com/karthikeyan-karuppiah/home-lab/commit/7aa68e8df512ed9e98c5c67a5926846705033848))
* **authelia:** re-encrypt users_database.enc.yml with valid YAML formatting ([d7b96ce](https://github.com/karthikeyan-karuppiah/home-lab/commit/d7b96ce90519fdeacc69fdbfae706597c2c5b88a))
* **authelia:** re-encrypt users_database.enc.yml with valid YAML formatting ([5da2b79](https://github.com/karthikeyan-karuppiah/home-lab/commit/5da2b79d81b261503d3cc5c0e67b88d1b25f40bd))
* **authelia:** rename user password hash and JWT secret env variables ([d37bc1b](https://github.com/karthikeyan-karuppiah/home-lab/commit/d37bc1b7535ff68c4c11098d0e02d89660da0916))
* **authelia:** update cookie domain to home.lab and wire Redis and env secrets ([762d15d](https://github.com/karthikeyan-karuppiah/home-lab/commit/762d15d12bcc3b20d4f45a5afcc40a152b5131fd))
* **authelia:** update USER_PASSWORD_HASH format in secrets.enc.env ([83112dc](https://github.com/karthikeyan-karuppiah/home-lab/commit/83112dc6e089481e549756958ab927ec632c9167))
* **authelia:** update USER_PASSWORD_HASH format in secrets.enc.env ([b3768a1](https://github.com/karthikeyan-karuppiah/home-lab/commit/b3768a1e87a88e6e94afc33df19a9feccef5519e))
* **authelia:** update USER_PASSWORD_HASH format in secrets.enc.env ([7c8b034](https://github.com/karthikeyan-karuppiah/home-lab/commit/7c8b034754122cb70298a6cf2a62a7f1a8570d3b))
* **authelia:** update USER_PASSWORD_HASH format in secrets.enc.env ([e15b120](https://github.com/karthikeyan-karuppiah/home-lab/commit/e15b120a0344a5851317d42565fb33b7a2b7f02b))
* Mount Authelia config files from Git via Docker Compose configs for doco-cd ([a8da737](https://github.com/karthikeyan-karuppiah/home-lab/commit/a8da73749021980c5aca2d3b7a3614f4f818b23f))


### Miscellaneous Chores

* **authelia:** encrypt users_database with SOPS ([16e841a](https://github.com/karthikeyan-karuppiah/home-lab/commit/16e841aded4e6e328a07c39695e69d882e2cb586))
* **lint:** ignore encrypted SOPS files in yamllint ([8efcd93](https://github.com/karthikeyan-karuppiah/home-lab/commit/8efcd936e338ea61b873fca625751ce51d03f261))
* **lint:** ignore encrypted SOPS files in yamllint ([27c63e5](https://github.com/karthikeyan-karuppiah/home-lab/commit/27c63e5d525784e449cbecb2503742c01657af94))
* **security:** rotate encrypted DuckDNS configuration ([b2003eb](https://github.com/karthikeyan-karuppiah/home-lab/commit/b2003eb3bd3fc0b5ed5921334be869d4c829bb25))

## [1.1.4](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.1.3...v1.1.4) (2026-11-15)


### Documentation

* add MIT license ([a22d87e](https://github.com/karthikeyan-karuppiah/home-lab/commit/a22d87ef8d98c913276f1be51697cc01acf3713f))
* fix GitHub Actions (ci & release) status badges in README ([33dc5eb](https://github.com/karthikeyan-karuppiah/home-lab/commit/33dc5eba1d39e746e142ed95c3d67cdd81d14b8f))
* fix GitHub Actions status badges in README ([5c356c9](https://github.com/karthikeyan-karuppiah/home-lab/commit/5c356c971fb4227ff1de771b5806ce4959b3ca14))
* fix GitHub Actions status badges in README ([8e1ace3](https://github.com/karthikeyan-karuppiah/home-lab/commit/8e1ace3590e88760a490f76e83f96c3010c6d888))


### Miscellaneous Chores

* **deps:** enforce container digest pinning and release age cooldown in renovate ([222d0ed](https://github.com/karthikeyan-karuppiah/home-lab/commit/222d0ed2935594328067298bee6ea64463f24a7e))
* **security:** redact personal DuckDNS domain and NAS paths ([0ffe8e2](https://github.com/karthikeyan-karuppiah/home-lab/commit/0ffe8e2bcb271d8eb8623ddc68679d9dfed7aebc))

## [1.1.3](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.1.2...v1.1.3) (2026-10-31)


### Miscellaneous Chores

* **deps:** update ghcr.io/kimdre/doco-cd docker tag to v0.131.0 ([51035c3](https://github.com/karthikeyan-karuppiah/home-lab/commit/51035c3d8270b53138fa127875fec0c7764741bd))
* **deps:** update ghcr.io/kimdre/doco-cd docker tag to v0.131.0 ([20a655b](https://github.com/karthikeyan-karuppiah/home-lab/commit/20a655bd67acc6718f95fedff538e68c089a9e4a))

## [1.1.2](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.1.1...v1.1.2) (2026-10-30)


### Bug Fixes

* correct matchFileNames schema property error inside renovate config ([5a714f8](https://github.com/karthikeyan-karuppiah/home-lab/commit/5a714f8c6a76e08fe1c96b429dd3574de47deea6))

## [1.1.1](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.1.0...v1.1.1) (2026-10-29)


### Miscellaneous Chores

* implement native bash conventional commit message git hooks ([178a478](https://github.com/karthikeyan-karuppiah/home-lab/commit/178a4785a9a29afac3b2c8be79003e69b0b4c0e3))

## [1.1.0](https://github.com/karthikeyan-karuppiah/home-lab/compare/v1.0.0...v1.1.0) (2026-10-29)


### Features

* add automated malware blocklist filtering to dns stack ([38b9b71](https://github.com/karthikeyan-karuppiah/home-lab/commit/38b9b71cd6b5d2dead0508be1c91e0a24df8bd87))
* add automated release management pipeline ([3d804e6](https://github.com/karthikeyan-karuppiah/home-lab/commit/3d804e67c2f9dcf50438552680eebf24ae5eedd7))
* implement prometheus and grafana observability stack core ([86a1aae](https://github.com/karthikeyan-karuppiah/home-lab/commit/86a1aae4651d61b2879c7884edc12b4352af1b04))
* introduce nginx proxy manager service core ([71b52d7](https://github.com/karthikeyan-karuppiah/home-lab/commit/71b52d7ef42556da81015c78b41bea7031b6ade1))
* introduce nginx proxy manager service core ([c3bff2d](https://github.com/karthikeyan-karuppiah/home-lab/commit/c3bff2dd1ba0138841935b2396ec621534c3c144))
* introduce nginx proxy manager service core ([7c69105](https://github.com/karthikeyan-karuppiah/home-lab/commit/7c69105dae78dc7109c4746165dc3d137065ac2b))
* introduce nginx proxy manager service core ([2c42b9a](https://github.com/karthikeyan-karuppiah/home-lab/commit/2c42b9a169d4d0adbf08b9b4767580506e8eed9a))
* introduce nginx proxy manager service core ([c84927a](https://github.com/karthikeyan-karuppiah/home-lab/commit/c84927a84168d0dadf3825cbb44606cc8dcb4a24))
* introduce nginx proxy manager service core ([58e248e](https://github.com/karthikeyan-karuppiah/home-lab/commit/58e248e94efe171a260e0bddf582d293012f6e4b))
* introduce nginx proxy manager service core ([8de3cd6](https://github.com/karthikeyan-karuppiah/home-lab/commit/8de3cd69f735a258ee8a576f5fc8865d80f988ac))
* introduce nginx proxy manager service core ([0e160a1](https://github.com/karthikeyan-karuppiah/home-lab/commit/0e160a1627d70e15e31e9e4dc7abc679427042a4))


### Bug Fixes

* correct blocky upstream doh endpoints and ad blocklist source url ([6656e2f](https://github.com/karthikeyan-karuppiah/home-lab/commit/6656e2fb677aeb57e2bfa44adbbddb30296c022a))
* enforce user root directive on prometheus container to remediate active query log permission denial ([89e685f](https://github.com/karthikeyan-karuppiah/home-lab/commit/89e685f6f8f7cd58402326216696be698b8d0813))
* enforce user root directive on prometheus container to remediate active query log permission denial ([8b80a47](https://github.com/karthikeyan-karuppiah/home-lab/commit/8b80a478047388c3040bb5a9ef22d77c3cf25660))
* implement zero-dependency native hadolint engine for dockerfiles ([7e78fa7](https://github.com/karthikeyan-karuppiah/home-lab/commit/7e78fa7aa588cad705af3a9a3c94d0ed5da3bc21))
* mispell ([a839052](https://github.com/karthikeyan-karuppiah/home-lab/commit/a8390524d62ba7fb9591610355662176b8c2a1d2))


### Documentation

* document automated CI/CD pipeline infrastructure in README ([63790d5](https://github.com/karthikeyan-karuppiah/home-lab/commit/63790d5eb2edf20fa689b5bcfa5c8747122163df))
* merge network flow mappings directly into ARCHITECTURE.md ([7a866bc](https://github.com/karthikeyan-karuppiah/home-lab/commit/7a866bc129748c91f9e7ac1ae9f60411903348dd))


### Miscellaneous Chores

* Configure Renovate ([00c9631](https://github.com/karthikeyan-karuppiah/home-lab/commit/00c9631281c5c358cc0701770bc3d9d91499e392))
* **deps:** update deluan/navidrome docker tag to v0.64.2 ([bd43f3e](https://github.com/karthikeyan-karuppiah/home-lab/commit/bd43f3eabbed047f04374aa4331f6eaea7f9262d))
* **deps:** update deluan/navidrome docker tag to v0.64.2 ([ae5b828](https://github.com/karthikeyan-karuppiah/home-lab/commit/ae5b82853809bc43fc861ee779caa1a913415559))
* **deps:** update ghcr.io/0xerr0r/blocky docker tag to v0.35.0 ([f9d72e7](https://github.com/karthikeyan-karuppiah/home-lab/commit/f9d72e7f33145fc84d01826423bf1e3ef3dad2f0))
* **deps:** update ghcr.io/0xerr0r/blocky docker tag to v0.35.0 ([5436af9](https://github.com/karthikeyan-karuppiah/home-lab/commit/5436af92412e97daac2f93e1e8e6df5b02916f14))
* **docs:** add renovate badge to readme header ([afc73d8](https://github.com/karthikeyan-karuppiah/home-lab/commit/afc73d8c02d1a43048871a7b546aaf9a3b3ebfab))
* fix yaml linting issues ([047f85c](https://github.com/karthikeyan-karuppiah/home-lab/commit/047f85ce17e7e0e51c8e0bae882f35a22e466bcc))
* fix yaml linting issues ([84b9fb7](https://github.com/karthikeyan-karuppiah/home-lab/commit/84b9fb77bb4345b120d7a8274a571ec6a4de3b84))
* fix yaml linting issues ([53f40e9](https://github.com/karthikeyan-karuppiah/home-lab/commit/53f40e90e42a5b5a49e943dd6813946fd111168e))
* fix yaml linting issues ([9aef1d7](https://github.com/karthikeyan-karuppiah/home-lab/commit/9aef1d7ddd1371cfc857d7486d8895b380550d24))
* force release please evaluation run ([c7c5219](https://github.com/karthikeyan-karuppiah/home-lab/commit/c7c52198db945aeb2d805d09d1120fb974f8084d))
* **infra:** add self-hosted renovate bot deployment ([49fd801](https://github.com/karthikeyan-karuppiah/home-lab/commit/49fd80117fd19af734a7d615fe4374928137b3bf))
* **infra:** add self-hosted renovate bot deployment ([4505c10](https://github.com/karthikeyan-karuppiah/home-lab/commit/4505c1004be21233b5edf27fb3eeb4518f66ece0))
* **infra:** add self-hosted renovate bot deployment ([b2b26b2](https://github.com/karthikeyan-karuppiah/home-lab/commit/b2b26b252d38591dc8e6a3a406b8dfeb59d35dd9))
* **infra:** add self-hosted renovate bot deployment ([88c236c](https://github.com/karthikeyan-karuppiah/home-lab/commit/88c236c33169ef0afa5a291b232e3b372927d7db))
* **infra:** add self-hosted renovate bot deployment ([8074df4](https://github.com/karthikeyan-karuppiah/home-lab/commit/8074df443fc6d4c298efdab5d0e868679c4948a3))
* **infra:** add self-hosted renovate bot deployment ([03ad371](https://github.com/karthikeyan-karuppiah/home-lab/commit/03ad371e0469e986e0378bde60d9423f98507fcd))
* **infra:** add self-hosted renovate bot deployment ([a280b04](https://github.com/karthikeyan-karuppiah/home-lab/commit/a280b04a7f61d2036a7bdd07e23cfd58a48a381f))
* **infra:** add self-hosted renovate bot deployment ([f556e21](https://github.com/karthikeyan-karuppiah/home-lab/commit/f556e21333ef20a90db25d221d06ff2d14907798))
* **infra:** add self-hosted renovate bot deployment ([b8f670c](https://github.com/karthikeyan-karuppiah/home-lab/commit/b8f670cbe5a89fbcccb92c5cadce065ffdba92ac))
* **infra:** add self-hosted renovate bot deployment ([a5787ec](https://github.com/karthikeyan-karuppiah/home-lab/commit/a5787ec4046d190034028ed3a3feba39499eabe7))
* **infra:** add self-hosted renovate bot deployment ([c35fd52](https://github.com/karthikeyan-karuppiah/home-lab/commit/c35fd52913054a8225ba05a25d1a2be6fb301b42))
* **infra:** add self-hosted renovate bot deployment ([bbe87ff](https://github.com/karthikeyan-karuppiah/home-lab/commit/bbe87fffe979335b8e49dbf7bf0583bf981cb9b6))
* **infra:** add self-hosted renovate bot deployment ([d74ddd8](https://github.com/karthikeyan-karuppiah/home-lab/commit/d74ddd8b5d49a59d35700575972f80afd43bc345))
* **infra:** add self-hosted renovate bot deployment ([a79e231](https://github.com/karthikeyan-karuppiah/home-lab/commit/a79e2315e8feda4ae8fb7f9910bc7a8bbf64e160))
* **infra:** add self-hosted renovate bot deployment ([74203be](https://github.com/karthikeyan-karuppiah/home-lab/commit/74203bef8fdc7bffd382a1287af8b23e7a89a052))
* **infra:** add self-hosted renovate bot deployment ([0311ced](https://github.com/karthikeyan-karuppiah/home-lab/commit/0311cedcc4ae5e523d82ef14ad0f65ca37efd09d))
* **infra:** add self-hosted renovate bot deployment ([f584b74](https://github.com/karthikeyan-karuppiah/home-lab/commit/f584b74a6a7a7ee43a73d87b012b39131300b524))
* **infra:** add self-hosted renovate bot deployment ([7963eef](https://github.com/karthikeyan-karuppiah/home-lab/commit/7963eef05e21c45b68ac08e9b8b46fe7301ba0de))
* **infra:** add self-hosted renovate bot deployment ([9f41460](https://github.com/karthikeyan-karuppiah/home-lab/commit/9f414607263f21baffc4f878196a7aeff776d3dc))
* **infra:** add self-hosted renovate bot deployment ([12b4184](https://github.com/karthikeyan-karuppiah/home-lab/commit/12b4184c3a806aa1c0bb7b0e95bea98b3edf021e))
* **infra:** add self-hosted renovate bot deployment ([704e38c](https://github.com/karthikeyan-karuppiah/home-lab/commit/704e38c5cd00be47e6002395341176af9880fcd4))
* **infra:** add self-hosted renovate bot deployment ([8621d61](https://github.com/karthikeyan-karuppiah/home-lab/commit/8621d617e2c37dfb327767842cbca46b4f6e3ca8))
* **infra:** add self-hosted renovate bot deployment ([db89ea4](https://github.com/karthikeyan-karuppiah/home-lab/commit/db89ea4cea9a602e89469ac44a467fe1962b6cb2))
* re-trigger release-please pipeline ([eafa7b9](https://github.com/karthikeyan-karuppiah/home-lab/commit/eafa7b99a8ae1c7e0bab5bf9ad960fbf5b2037f7))
* release please ([11e915c](https://github.com/karthikeyan-karuppiah/home-lab/commit/11e915c613daf230f44bb0b4d765f8a9a79553ab))
* **renovate:** configure conventional commits for release tracking ([b850923](https://github.com/karthikeyan-karuppiah/home-lab/commit/b850923520ca1c48aaa581cbea941518b38b4173))
* run hadolint if dockerfile exist ([2f49230](https://github.com/karthikeyan-karuppiah/home-lab/commit/2f49230e0b679a9203e4682e8bff7de2ae3333f1))
* update aqua security ([a887b47](https://github.com/karthikeyan-karuppiah/home-lab/commit/a887b478aa08db370e31826cd6ae89a4ff9a5790))
* update aqua security ([e49cca8](https://github.com/karthikeyan-karuppiah/home-lab/commit/e49cca85bca970964dbcbc1208c1eddf4f36fb6c))
* update blocky custom dns and switch wireguard to local blocky instance ([e8b83f7](https://github.com/karthikeyan-karuppiah/home-lab/commit/e8b83f7313145aaf7867474abf18ee73d15156fd))
* update blocky custom dns and switch wireguard to local blocky instance ([d465259](https://github.com/karthikeyan-karuppiah/home-lab/commit/d465259c687de826978c330fde1da43c792642d0))
* update blocky custom dns and switch wireguard to local blocky instance ([433b99a](https://github.com/karthikeyan-karuppiah/home-lab/commit/433b99ab3944fd59e7114dd92f4393a57a3ab009))
* update blocky custom dns and switch wireguard to local blocky instance ([82b3100](https://github.com/karthikeyan-karuppiah/home-lab/commit/82b3100098c505b0274df947112eb076046a7fd0))
* update blocky custom dns and switch wireguard to local blocky instance ([7c1be75](https://github.com/karthikeyan-karuppiah/home-lab/commit/7c1be75ade6a66f23f577cdb30d25a9fb342d9a5))
* update blocky custom dns and switch wireguard to local blocky instance ([a86f04b](https://github.com/karthikeyan-karuppiah/home-lab/commit/a86f04be56e05f002ee965c64715a7cca081966d))
* update blocky custom dns and switch wireguard to local blocky instance ([12f1aad](https://github.com/karthikeyan-karuppiah/home-lab/commit/12f1aad41dcf92b5b9d46fc8e81e183fef13900a))

## Changelog
