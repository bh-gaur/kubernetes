#!/bin/bash
# Script to make kubectl aliases permanent across terminal sessions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
ALIAS_FILE="${SCRIPT_DIR}/kubectl_alias"
SOURCE_LINE="source \"${ALIAS_FILE}\""

if [ ! -f "${ALIAS_FILE}" ]; then
    echo "Error: ${ALIAS_FILE} does not exist."
    exit 1
fi

PROFILE="${HOME}/.zshrc"
if [ "$(basename "$SHELL")" = "bash" ]; then
    PROFILE="${HOME}/.bashrc"
fi

echo "Target shell profile: ${PROFILE}"

if [ -f "${PROFILE}" ] && grep -qs "${ALIAS_FILE}" "${PROFILE}"; then
    echo "✅ kubectl aliases are already configured in ${PROFILE}."
else
    {
        echo ""
        echo "# kubectl aliases"
        echo "${SOURCE_LINE}"
    } >> "${PROFILE}" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✅ Successfully added kubectl aliases to ${PROFILE}."
    else
        echo "⚠️ Permission denied updating ${PROFILE} directly."
        echo "Please run the following command in your terminal:"
        echo ""
        echo "  echo 'source \"${ALIAS_FILE}\"' >> ${PROFILE}"
        echo ""
        exit 0
    fi
fi

echo ""
echo "To apply changes to your current terminal session immediately, run:"
echo "  source ${PROFILE}"

