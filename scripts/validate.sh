#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Building Bicep template..."
az bicep build --file "$ROOT/bicep/main.bicep"

echo "Formatting and validating Terraform..."
terraform -chdir="$ROOT/terraform" fmt -check -recursive
terraform -chdir="$ROOT/terraform" init -backend=false
terraform -chdir="$ROOT/terraform" validate
