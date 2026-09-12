# The yasrt release tool, packaged for the CI job it runs in.
#
# Built on devops/images/wolfi-base like every other golden image here: the
# base carries the address selection (K38), the melange key and the package
# sources, so none of that is repeated below. This image needs a real git
# binary anyway — yasrt drives git through os/exec precisely so that signing,
# credential handling and shallow-clone behaviour are git's own rather than a
# library's approximation.
#
# The binary is not built here. yasrt/cli releases it to its generic package
# registry; the pipeline fetches it into dist/ with a job token and this file
# only packages it. That is the same split devops/images/deploy-opkssh uses,
# and it keeps the Go toolchain out of the image.
#
# renovate: datasource=docker depName=registry.ole-hartwig.eu/devops/images/wolfi-base
FROM registry.ole-hartwig.eu/devops/images/wolfi-base:2@sha256:d3e532f05091266a154bdae00629477a455b1a473a5c76c551379511d8630bd1

# Set by BuildKit for each leg of a multi-platform build.
ARG TARGETARCH

USER root

# Three things this line learned the hard way, all found by building it:
#
#  - Packages are selected by the COMMAND they provide, not by name. Wolfi's
#    `gnupg` and `openssh-client` are meta-packages that install an SBOM entry
#    and no binaries; the gpg binary lives in a package called `gpg`, and
#    ssh-keygen in one of the openssh subpackages. `cmd:` says what the image
#    actually needs and lets apk resolve it, instead of guessing names.
#  - ca-certificates-bundle ships the bundle and no update-ca-certificates
#    script; calling it exits 127. devops/images/golang does not call it either.
#  - Nothing here is version-pinned. Wolfi rolls forward, the base image digest
#    is what fixes this image in time, and an exact apk pin only guarantees a
#    build that stops working. Same reasoning as devops/images/golang!79.
RUN apk add --no-cache \
      cmd:git \
      cmd:gpg \
      cmd:ssh-keygen \
      ca-certificates-bundle

COPY dist/yasrt-linux-${TARGETARCH} /usr/local/bin/yasrt

# safe.directory: the runner mounts CI_PROJECT_DIR with a different owner than
# the job user and git then refuses to touch it, so declare it once here rather
# than in every consuming job.
RUN chmod 0755 /usr/local/bin/yasrt \
 && git config --system --add safe.directory '*' \
 && adduser -D -u 1000 yasrt

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
    rm -rf "$d" /tmp/smoke_key /tmp/smoke_key.pub

USER 1000
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/yasrt"]
CMD ["--help"]
