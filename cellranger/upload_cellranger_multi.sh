#!/bin/bash
#
# Upload key Cell Ranger multi outputs to Google Drive via rclone
#
# Usage: Run from the top-level experiment directory (e.g. sc145/)
#   e.g., cd /path/to/sc145 && bash upload_cellranger_multi.sh
#
# Expected structure:
#   sc145/
#   ├── sc145_A/
#   │   ├── sc145_A.csv / .slurm / .txt   (config files)
#   │   └── sc145_A_count/outs/per_sample_outs/{sample}/
#   ├── sc145_B/
#   └── ...
#
# Prerequisites:
#   - rclone configured with a remote named "gbackup"
#

found=0

for OUTDIR in */*_count/outs; do
    EXPERIMENT=$(basename "$(dirname "${OUTDIR}")" | sed 's/_count$//')
    EXPERIMENT_DIR=$(dirname "$(dirname "${OUTDIR}")")
    DEST="gbackup:${EXPERIMENT}_count"

    # --- Job/config files (sit inside the sc145_A/ folder) ---
    echo ""
    echo "=== ${EXPERIMENT}: uploading config files ==="
    for EXT in csv slurm txt; do
        FILE="${EXPERIMENT_DIR}/${EXPERIMENT}.${EXT}"
        if [ -f "${FILE}" ]; then
            echo "  -> ${EXPERIMENT}.${EXT}"
            rclone copy -P "${FILE}" "${DEST}/"
        fi
    done

    # --- Per-sample outputs ---
    for SAMPLE_DIR in "${OUTDIR}"/per_sample_outs/*/; do
        [ -d "${SAMPLE_DIR}" ] || continue
        sample=$(basename "${SAMPLE_DIR}")
        found=1

        echo ""
        echo "=== ${EXPERIMENT} / ${sample} ==="

        echo "  -> web_summary.html"
        rclone copy -P "${SAMPLE_DIR}/web_summary.html" "${DEST}/${sample}/"

        echo "  -> metrics_summary.csv"
        rclone copy -P "${SAMPLE_DIR}/metrics_summary.csv" "${DEST}/${sample}/"

        echo "  -> sample_filtered_feature_bc_matrix.h5"
        rclone copy -P "${SAMPLE_DIR}/count/sample_filtered_feature_bc_matrix.h5" "${DEST}/${sample}/"

        # Cell type annotation folder (optional: only present if Cell Ranger annotation model was used)
        # Contains: cell_types.csv, cell_annotation_differential_expression.csv, cell_annotation_results.json.gz
        if [ -d "${SAMPLE_DIR}/count/cell_types" ]; then
            echo "  -> cell_types/cell_types.csv"
            rclone copy -P "${SAMPLE_DIR}/count/cell_types/cell_types.csv" "${DEST}/${sample}/cell_types/"
            echo "  -> cell_types/cell_annotation_differential_expression.csv"
            rclone copy -P "${SAMPLE_DIR}/count/cell_types/cell_annotation_differential_expression.csv" "${DEST}/${sample}/cell_types/"
        fi

        echo "  -> sample_cloupe.cloupe"
        rclone copy -P "${SAMPLE_DIR}/count/sample_cloupe.cloupe" "${DEST}/${sample}/"

    done

    echo ""
    echo "Upload complete for ${EXPERIMENT}."
done

if [ $found -eq 0 ]; then
    echo "No *_count/outs/per_sample_outs/ directories found. Are you in the right directory?"
fi
