<!--
SPDX-FileCopyrightText: 2026 Kai Ole Hartwig
SPDX-License-Identifier: MIT
-->

# devops/images/yasrt

The [yasrt](https://git.ole-hartwig.eu/yasrt/cli) release tool, packaged for the
CI job it runs in: `yasrt`, `git`, `gpg` and `ssh-keygen` on Wolfi, non-root.

## Purpose

yasrt decides whether a repository should be released and publishes the release
after the artefact exists. It drives `git` through `os/exec` on purpose, so the
image carries a real git binary rather than relying on a library's
approximation of signing and credential handling.

## Install

```yaml
include:
  - component: $CI_SERVER_HOST/devops/ci-cd-components/release-tools/yasrt@1
```

The component defaults to `registry.ole-hartwig.eu/devops/images/yasrt:1`, a
rolling major tag. Immutable release tags (`1.0.0`) are published alongside it.

## Configure

Nothing here. The tool is configured per consuming repository through
`.yasrt.yaml`; see the [yasrt README](https://git.ole-hartwig.eu/yasrt/cli).

The image pins one thing of its own: `YASRT_VERSION` in `.gitlab-ci.yml`, which
selects the binary fetched from `yasrt/cli`'s generic package registry. Renovate
tracks it.

## Decommission

Remove the component include from consuming repositories. The image holds no
state.

## Security

The binary is fetched with a job token — `yasrt/cli` lists this project on its
job-token allowlist, so no long-lived credential is involved — and verified
against the published `SHA256SUMS` before it is packaged. The image is signed
with cosign and carries a CycloneDX SBOM attestation, both inherited from
`buildkit-image-build`.

Report vulnerabilities as described in [SECURITY.md](SECURITY.md).
