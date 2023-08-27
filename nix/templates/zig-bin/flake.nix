# hello-world -- Template Zig application
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: AGPL-3.0-or-later

{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flakelight.url = "github:accelbread/flakelight";
    flakelight-zig.url = "github:accelbread/flakelight-zig";
  };
  outputs = { flakelight, flakelight-zig, ... }@inputs: flakelight ./. {
    imports = [ flakelight-zig.flakelightModules.default ];
    inherit inputs;

    name = "hello-world";
    version = "0.0.1";
    description = "Template Zig application.";
    license = "agpl3Plus";
  };
}
