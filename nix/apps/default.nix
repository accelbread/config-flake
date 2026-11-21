# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  src,
  system,
  writeShellScript,
  emacsAccelbread,
  bubblewrap,
  firefox,
  awscli2,
  jq,
  replaceVars,
  nix-update,
  firefoxExtensions,
  ...
}:
let
  inherit (builtins) readFile toJSON;
  inherit (lib) fix removePrefix removeSuffix;

  awsStack = replaceVars (src + /aws/stack.yaml) {
    ca =
      src + /misc/ca.pem
      |> readFile
      |> toJSON
      |> removePrefix "\""
      |> removeSuffix "\"";
  };
in
fix (self: {
  default = self.emacs;
  emacs = writeShellScript "emacsWithConfig" ''
    set -eu
    emacs_dir=$(mktemp -d)
    cleanup() { rm -rf "$emacs_dir"; }
    trap cleanup EXIT
    ${emacsAccelbread}/bin/emacs --init-directory="$emacs_dir" "$@"
  '';

  aws-deploy = writeShellScript "deploy-aws" ''
    exec ${awscli2}/bin/aws cloudformation deploy \
      --region us-west-2 \
      --stack-name personal-infra \
      --template-file ${awsStack} \
      --capabilities CAPABILITY_IAM \
      --no-fail-on-empty-changeset \
      "$@"
  '';
  aws-outputs = writeShellScript "aws-outputs" ''
    set -euo pipefail
    ${awscli2}/bin/aws cloudformation describe-stacks \
      --region us-west-2 \
      --stack-name personal-infra \
      --query 'Stacks[0].Outputs' \
      --output json \
      --no-cli-pager \
      "$@" |
      ${jq}/bin/jq 'map({key: .OutputKey, value: .OutputValue}) | from_entries'
  '';

  update-packages = writeShellScript "update" ''
    set -euo pipefail
    update_package() {
      ${lib.getExe nix-update} --flake "$@"
    }

    update_package r8152-udev-rules
    update_package --version=branch firefox-gnome-theme
    update_package --version=branch materialDesignIcons
    update_package --version=branch gnome-accent-directories
    update_package --version=branch \
      legacyPackages.${system}.emacsPackages.flymake-vale

    ${toString firefoxExtensions.updateScript}
  '';

  firefoxNetworkDns = writeShellScript "firefoxNetworkDns" ''
    exec ${bubblewrap}/bin/bwrap --bind / / --dev-bind /dev /dev \
      --bind /run/NetworkManager/resolv.conf /etc/resolv.conf \
      -- ${firefox}/bin/firefox
  '';
})
