#!/usr/bin/env bash
set -e

cd /home/arman/rising-ci

rm -rf .repo/local_manifests
rm -rf .repo/projects/device/$BRAND
rm -rf .repo/projects/vendor/$BRAND
rm -rf .repo/projects/vendor/risingOTA.git
rm -rf .repo/projects/kernel/$BRAND
rm -rf out/error*.log
rm -rf out/target/product/$CODENAME
rm -rf vendor/risingOTA

wipe_rising_dependencies() {
    echo "Attempting to nuke RisingOS dependencies..."

    dependency_file_device="device/$BRAND/$CODENAME/rising.dependencies"
    dependency_file_top_level="rising.dependencies"

    if [[ -f "$dependency_file_device" ]]; then
        echo "Found dependency file in device tree: $dependency_file_device"
        dependencies=$(cat "$dependency_file_device")
    elif [[ -f "$dependency_file_top_level" ]]; then
        echo "Found dependency file in top-level directory: $dependency_file_top_level"
        dependencies=$(cat "$dependency_file_top_level")
    else
        echo "Error: rising.dependencies not found in device tree or top-level."
        exit 1
    fi

    IFS=$'\n' read -d '' -r -a dependency_array <<< "$dependencies"

    for dependency_json in "${dependency_array[@]}"; do
        if [[ -n "$dependency_json" ]]; then
            target_path=$(echo "$dependency_json" | jq -r '.target_path')
            if [[ -n "$target_path" ]]; then
                full_path="/home/arman/rising-ci/$target_path"
                echo "Removing directory: $full_path"
                if [[ -d "$full_path" ]]; then
                    rm -rf "$full_path"
                    repo_git_path=".repo/project/$(basename "$full_path").git"
                    if [[ -d "$repo_git_path" ]]; then
                        rm -rf "$repo_git_path"
                    fi
                else
                    echo "Warning: Directory not found: $full_path"
                fi
            fi
        fi
    done
    echo "Finished nuking RisingOS dependencies."
}
