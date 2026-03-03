#!/bin/bash
#
# Upload key Cell Ranger multi outputs to Google Drive via rclone
#
# Usage: Run from the directory containing *_count folders
#   e.g., cd /path/to/sc145 && bash upload_cellranger_multi.sh
#
# Prerequisites:
#   - rclone configured with a remote named "gbackup"
#   - Cell Ranger multi output structure:
#       *_count/outs/per_sample_outs/{sample}/
#

found=0

for OUTDIR in *_count/outs; do
    EXPERIMENT=$(basename "$(dirname "${OUTDIR}")" | sed 's/_count$//')
    DEST="gbackup:${EXPERIMENT}_count"

    # --- Job/config files (sit alongside the *_count folder) ---
    echo "Uploading ${EXPERIMENT} config files ..."
    for EXT in csv slurm txt; do
        [ -f "${EXPERIMENT}.${EXT}" ] && rclone copy -P "${EXPERIMENT}.${EXT}" "${DEST}/"
    done

    # --- Per-sample outputs ---
    for SAMPLE_DIR in "${OUTDIR}"/per_sample_outs/*/; do
        [ -d "${SAMPLE_DIR}" ] || continue
        sample=$(basename "${SAMPLE_DIR}")
        found=1

        echo "Uploading ${EXPERIMENT} / ${sample} ..."

        # Web summary (QC, interactive HTML)
        rclone copy -P "${SAMPLE_DIR}/web_summary.html" "${DEST}/${sample}/"

        # Per-sample metrics CSV (machine-readable QC: cells, genes, UMIs)
        rclone copy -P "${SAMPLE_DIR}/metrics_summary.csv" "${DEST}/${sample}/"

        # Filtered count matrix (for Seurat/Scanpy)
        rclone copy -P "${SAMPLE_DIR}/count/sample_filtered_feature_bc_matrix.h5" "${DEST}/${sample}/"

        # Cell type annotations CSV (optional: only present if Cell Ranger annotation model was used)
        # Try both possible locations; suppress all output since file may not exist
        rclone copy "${SAMPLE_DIR}/count/cell_types.csv" "${DEST}/${sample}/" > /dev/null 2>&1 || true
        rclone copy "${SAMPLE_DIR}/cell_types.csv" "${DEST}/${sample}/" > /dev/null 2>&1 || true

        # Cloupe file (for Loupe Browser visualisation)
        rclone copy -P "${SAMPLE_DIR}/count/sample_cloupe.cloupe" "${DEST}/${sample}/"

    done

    echo "Upload complete for ${EXPERIMENT}."
done

if [ $found -eq 0 ]; then
    echo "No *_count/outs/per_sample_outs/ directories found. Are you in the right directory?"
fi
