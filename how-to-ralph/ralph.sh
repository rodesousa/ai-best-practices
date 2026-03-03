#!/bin/bash

# =============================================================================
# Ralph Loop - Fresh context each iteration
# Usage: ./ralph.sh [manual|max_iterations]
# Examples:
#   ./ralph.sh           # Auto mode, unlimited iterations
#   ./ralph.sh 20        # Auto mode, max 20 iterations
#   ./ralph.sh manual    # Manual mode (Ctrl+C to stop)
# =============================================================================

# Parse arguments
if [ "$1" = "manual" ]; then
    MODE="manual"
    MAX_ITERATIONS=0
elif [[ "$1" =~ ^[0-9]+$ ]]; then
    MODE="auto"
    MAX_ITERATIONS=$1
else
    MODE="auto"
    MAX_ITERATIONS=0
fi

PROMPT_FILE="prompt.md"
STATUS_FILE="status.md"

# Check prompt exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "[!] Error: $PROMPT_FILE not found"
    exit 1
fi

# Init status if needed
if [ ! -f "$STATUS_FILE" ]; then
    echo "status: in_progress" > "$STATUS_FILE"
    echo "" >> "$STATUS_FILE"
    echo "## Notes" >> "$STATUS_FILE"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Mode:   $MODE"
echo "Prompt: $PROMPT_FILE"
echo "Status: $STATUS_FILE"
[ $MAX_ITERATIONS -gt 0 ] && echo "Max:    $MAX_ITERATIONS iterations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

iteration=1

while true; do
    # Check max iterations
    if [ $MAX_ITERATIONS -gt 0 ] && [ $iteration -gt $MAX_ITERATIONS ]; then
        echo ""
        echo "=== Reached max iterations: $MAX_ITERATIONS ==="
        exit 0
    fi

    echo ""
    echo ">>> Iteration $iteration - $(date '+%H:%M:%S')"
    echo "---"

    # Run claude based on mode
    if [ "$MODE" = "manual" ]; then
        # Hand mode: skip permissions but no streaming/verbose for cleaner output
        cat "$PROMPT_FILE" | claude --dangerously-skip-permissions
    else
        # Auto mode: full automation with YOLO permissions
        cat "$PROMPT_FILE" | claude -p \
            --dangerously-skip-permissions \
            --output-format=stream-json \
            --verbose
    fi

    # Check stop condition
    if grep -q "status: done" "$STATUS_FILE"; then
        echo ""
        echo "=== Ralph Loop completed ==="
        echo "Iterations: $iteration"
        exit 0
    fi

    ((iteration++))
    sleep 2
done
