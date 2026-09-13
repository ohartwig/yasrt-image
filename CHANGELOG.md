## [1.4.5](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.4.4...1.4.5) (2026-09-13)

### :repeat: Continuous Integrations

* **mirror:** prune every branch GitHub has that the filter did not keep ([77d12aa](https://git.ole-hartwig.eu/devops/images/yasrt/commit/77d12aaa613fea59a9f471cc1ef2ff2ba72307a9))
* wire release's needs as an override, not through the component input ([84e6037](https://git.ole-hartwig.eu/devops/images/yasrt/commit/84e6037a1882772a647e7b65a502b047570a63d2))
* **mirror:** run on the runner that can reach github.com ([c5fb8f6](https://git.ole-hartwig.eu/devops/images/yasrt/commit/c5fb8f66d28b43779854b4ef4f8498c1930fea4c))

### :wrench: Chores

* yasrt 1.9.0 ([e0591df](https://git.ole-hartwig.eu/devops/images/yasrt/commit/e0591df1dab62bc403ecb93bf2a305351e374312))

## [1.4.4](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.4.3...1.4.4) (2026-09-13)

### :repeat: Continuous Integrations

* **mirror:** prune refs with a loop, not grep | xargs ([112240e](https://git.ole-hartwig.eu/devops/images/yasrt/commit/112240e87c7a90145f4284f90eca1368a894eb2f))

### :wrench: Chores

* **deps:** update registry.ole-hartwig.eu/devops/ci-mirrors/container-scanning:8.6.35 docker digest to 9d23216 ([8d2e750](https://git.ole-hartwig.eu/devops/images/yasrt/commit/8d2e750f024c545fa73391fced870ea29969c88e))

## [1.4.3](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.4.2...1.4.3) (2026-09-13)

### :repeat: Continuous Integrations

* mirror to github.com/ohartwig/yasrt-image, without the instance's working files ([1e916f6](https://git.ole-hartwig.eu/devops/images/yasrt/commit/1e916f6c778a114994faa7e75a5161d49d97b415))

### :wrench: Chores

* **deps:** update registry.ole-hartwig.eu/devops/images/wolfi-base:2 docker digest to d3e532f ([6a5cd72](https://git.ole-hartwig.eu/devops/images/yasrt/commit/6a5cd726f123a7e28d95252034542ab076b952ea))

## [1.4.2](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.4.1...1.4.2) (2026-09-12)

### :bug: Fixes

* package yasrt 1.6.1 ([c9cdcb8](https://git.ole-hartwig.eu/devops/images/yasrt/commit/c9cdcb8138f78c80d45655bdc7fca869f419dff1))

## [1.4.1](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.4.0...1.4.1) (2026-09-12)

### :bug: Fixes

* build on the golden wolfi-base instead of the mirror ([627c40a](https://git.ole-hartwig.eu/devops/images/yasrt/commit/627c40ad429921e4ef2dd51a82a6b0b477cb3fe1))

## [1.4.0](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.3.0...1.4.0) (2026-09-11)

### :sparkles: Features

* **ci:** release with yasrt -- the tag after the image, on one pipeline ([ad30f41](https://git.ole-hartwig.eu/devops/images/yasrt/commit/ad30f41d374a579465e6fa3e27608104ea3fd1bf))

## [1.3.0](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.2.1...1.3.0) (2026-09-11)

### :sparkles: Features

* **ci:** re-scan the published image daily ([fb6c5be](https://git.ole-hartwig.eu/devops/images/yasrt/commit/fb6c5be7bebe307d08ce23450b99dd0cafae4a4b))
* package yasrt 1.6.0 ([ee0bb40](https://git.ole-hartwig.eu/devops/images/yasrt/commit/ee0bb405a70df7e1687e1ae03b11d53bba8bd35b))

## [1.2.1](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.2.0...1.2.1) (2026-09-11)

### :repeat: Chores

* **deps:** update registry.ole-hartwig.eu/devops/ci-mirrors/container-scanning docker tag to v8.6.35 ([94e5214](https://git.ole-hartwig.eu/devops/images/yasrt/commit/94e521422ea783b04f47264c926cc809c60280fa))

## [1.2.0](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.1.0...1.2.0) (2026-09-11)

### :sparkles: Features

* package yasrt 1.5.0 ([abe1735](https://git.ole-hartwig.eu/devops/images/yasrt/commit/abe1735ce03359a6baa07c087708144897ae6621))

### :repeat: Continuous Integrations

* run the yasrt shadow alongside semantic-release ([2ab50d3](https://git.ole-hartwig.eu/devops/images/yasrt/commit/2ab50d3f2b97e5707a830ebd25861909adbd4ac4))

## [1.1.0](https://git.ole-hartwig.eu/devops/images/yasrt/compare/1.0.0...1.1.0) (2026-09-11)

### :sparkles: Features

* package yasrt 1.1.0 ([8ed2799](https://git.ole-hartwig.eu/devops/images/yasrt/commit/8ed2799632a686b937448872ce485ccfd27d4981))
* package yasrt 1.2.0 ([46ff3a7](https://git.ole-hartwig.eu/devops/images/yasrt/commit/46ff3a7460c7a95f981e7b4bab3c5495a96c322e))

### :bug: Fixes

* **ci:** stop the old chain refusing a binary bump ([2dd81ae](https://git.ole-hartwig.eu/devops/images/yasrt/commit/2dd81aef827de1bd679b1a634806dd28bf086edf))

## 1.0.0 (2026-09-11)

### :sparkles: Features

* package the yasrt release tool as a Wolfi image ([6f6ebae](https://git.ole-hartwig.eu/devops/images/yasrt/commit/6f6ebae01e6c090bd42372fc9010f303037c3856))

### :bug: Fixes

* **ci:** fetch the binary before the Containerfile is verified ([1a26024](https://git.ole-hartwig.eu/devops/images/yasrt/commit/1a2602416bb3013c61cf7bd161915f45de936b1b))
* **ci:** follow the redirect when fetching the binary ([0288b53](https://git.ole-hartwig.eu/devops/images/yasrt/commit/0288b53ae023ca9f205133d5e621953063a3d478))
* **ci:** order the stages so scanning follows the build ([3ca7d33](https://git.ole-hartwig.eu/devops/images/yasrt/commit/3ca7d334879343dd802d8c48a152cad024a92a58))
* **image:** select packages by command, refresh the base digest ([3867d5a](https://git.ole-hartwig.eu/devops/images/yasrt/commit/3867d5a92e008df05400a2dd965494b38b7b7742))
