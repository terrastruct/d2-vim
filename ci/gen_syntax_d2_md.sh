#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

syntax_d2="$(cat test/syntax.d2)"

cat > test/syntax.d2.md <<EOF
<!-- syntax.d2 embedded within a markdown document -->
<!-- generated by ci/gen_syntax_d2_md.sh -->

\`\`\`d2
$syntax_d2
\`\`\`
EOF
