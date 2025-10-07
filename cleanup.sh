#!/usr/bin/env bash

# Cleanup script for managing Nix garbage collection roots
# Usage: ./cleanup.sh [options]

show_help() {
    echo "🧹 Nix Cleanup Helper"
    echo "===================="
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -l, --list          List current GC roots"
    echo "  -r, --remove-roots  Remove local result symlinks"
    echo "  -g, --garbage       Run garbage collection"
    echo "  -a, --all           Remove roots and run garbage collection"
    echo "  -h, --help          Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --list                    # Show current roots"
    echo "  $0 --remove-roots            # Remove ./result-* symlinks"
    echo "  $0 --garbage                 # Run garbage collection"
    echo "  $0 --all                     # Clean everything"
}

list_roots() {
    echo "📋 Current garbage collection roots in workspace:"
    ls -la result* 2>/dev/null || echo "No result symlinks found"
    echo ""
    echo "📋 System-wide GC roots:"
    find /nix/var/nix/gcroots -type l 2>/dev/null | head -10
    echo "..."
}

remove_roots() {
    echo "🗑️  Removing local result symlinks..."
    rm -f result*
    echo "✅ Local result symlinks removed"
}

run_garbage_collection() {
    echo "🧹 Running Nix garbage collection..."
    nix-collect-garbage -d
    echo "✅ Garbage collection completed"
}

case "$1" in
    -l|--list)
        list_roots
        ;;
    -r|--remove-roots)
        remove_roots
        ;;
    -g|--garbage)
        run_garbage_collection
        ;;
    -a|--all)
        remove_roots
        run_garbage_collection
        ;;
    -h|--help|"")
        show_help
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac