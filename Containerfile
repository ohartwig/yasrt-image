# syntax=docker.io/docker/dockerfile-upstream:1.29.0@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183
# The yasrt release tool, packaged for the CI job it runs in.
#
# A root filesystem from openSUSE Tumbleweed, built by
# devops/images/tumbleweed-builder and copied into FROM scratch (handbook:
# engineering/delivery/tumbleweed-migration.md, wave 2); until 2026-10 it
# was wolfi-base. This image needs a real git binary - yasrt drives git
# through os/exec precisely so that signing, credential handling and
# shallow-clone behaviour are git's own rather than a library's
# approximation.
#
# The binary is not built here. yasrt/cli releases it to its generic package
# registry; the pipeline fetches it into dist/ with a job token and this file
# only packages it. That is the same split devops/images/deploy-opkssh uses,
# and it keeps the Go toolchain out of the image.
#
# One snapshot pin per architecture, moved by pinup
# (custom.tumbleweed-snapshot), is the only package pin.
# renovate: datasource=custom.tumbleweed-snapshot depName=aarch64
ARG TW_SNAPSHOT_AARCH64=20261117.1795100969-e1e25851-6d8645fb0b2a7d7bbfe73b8f0515c54b98a9c9ee6fc8a2b7fd471a85d32f2e26
# renovate: datasource=custom.koh-snapshot depName=aarch64
ARG KOH_SNAPSHOT_AARCH64=20261120.1795137954-5d5b31309b4197d74d579f3375a4936e8e2ed4cf9c2cea4d62d03454d34e5455

FROM registry.ole-hartwig.eu/devops/images/tumbleweed-builder:1@sha256:57e6b07c075508477d9a0eb2b97ad3f3759b1077a54b8cd7d8ba85cfa0013971 AS rootfs
ARG TW_SNAPSHOT_AARCH64
ARG KOH_SNAPSHOT_AARCH64
# @userland is bash as /bin/sh and the GNU tools; openssh-clients brings
# ssh-keygen (openssh-common). The yasrt user gets the UID the jobs run as.
RUN koh-rootfs /rootfs --user yasrt:1000 @userland git-core gpg2 openssh-clients ca-certificates-mozilla

FROM scratch
COPY --from=rootfs /rootfs/ /
ARG TARGETARCH

COPY dist/yasrt-linux-${TARGETARCH} /usr/local/bin/yasrt

# safe.directory: the runner mounts CI_PROJECT_DIR with a different owner than
# the job user and git then refuses to touch it, so declare it once here rather
# than in every consuming job.
RUN chmod 0755 /usr/local/bin/yasrt \
 && git config --system --add safe.directory '*'

# Smoke test. Deliberately not `git --version`: yasrt drives git through
# os/exec for everything it does — tag creation, log parsing, signing,
# credential handling — so a git that answers --version and then cannot init a
# repository or read a log back would pass a version check and fail every
# consumer. Exercise the cycle instead.
RUN set -eu; \
    yasrt version; \
    gpg --version > /dev/null; \
    ssh-keygen -t ed25519 -N "" -C smoke -f /tmp/smoke_key -q; \
    d="$(mktemp -d)"; \
    git -C "$d" init -q -b main; \
    git -C "$d" -c user.email=smoke@invalid -c user.name=Smoke commit -q --allow-empty -m "feat: smoke"; \
    git -C "$d" -c user.email=smoke@invalid -c user.name=Smoke tag -a -m 1.0.0 1.0.0; \
    test "$(git -C "$d" log -1 --format=%s)" = "feat: smoke"; \
    test "$(git -C "$d" tag --points-at HEAD)" = "1.0.0"; \
    test -n "$(git -C "$d" rev-parse HEAD)"; \
    rm -rf "$d" /tmp/smoke_key /tmp/smoke_key.pub; \
    grep -q '^ID="opensuse-tumbleweed"' /usr/lib/os-release

USER 1000
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/yasrt"]
CMD ["--help"]
