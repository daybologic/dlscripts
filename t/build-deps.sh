#!/usr/bin/env sh

set -e

EXECUTABLE=build-deps.sh
REF_PATH=t/data/build-deps
EXPECTED_INPUT=$REF_PATH/input.txt
EXPECTED_OUTPUT=$REF_PATH/output.txt

ACTUAL_OUTPUT=`tempfile`

./$EXECUTABLE $EXPECTED_INPUT > $ACTUAL_OUTPUT
cmp $ACTUAL_OUTPUT $EXPECTED_OUTPUT

exit 0
