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

    for SAMPLE_DIR in "${OUTDIR}"/per_sample_outs/*/; do
        [ -d "${SAMPLE_DIR}" ] || continue
        sample=$(basename "${SAMPLE_DIR}")
        found=1

        echo "Uploading ${EXPERIMENT} / ${sample} ..."

        # Web summary (QC, interactive HTML)
        rclone copy -P "${SAMPLE_DIR}/web_summary.html" "${DEST}/${sample}/"

        # Per-sample metrics CSV (machine-readable QC: cells, genes, UMIs)
        rclone copy -P "${SAMPLE_DIR}/metrics_summary.csv" "${DEST}/${sample}/" 2>/dev/null

        # Filtered count matrix (for Seurat/Scanpy)
        rclone copy -P "${SAMPLE_DIR}/count/sample_filtered_feature_bc_matrix.h5" "${DEST}/${sample}/"

        # Cell type annotations CSV (from Cell Ranger automated annotation)
        rclone copy -P "${SAMPLE_DIR}/count/cell_types.csv" "${DEST}/${sample}/" 2>/dev/null

        # Cloupe file (for Loupe Browser visualisation)
        rclone copy -P "${SAMPLE_DIR}/count/sample_cloupe.cloupe" "${DEST}/${sample}/" 2>/dev/null

    done

    echo "Upload complete for ${EXPERIMENT}."
done

if [ $found -eq 0 ]; then
    echo "No *_count/outs/per_sample_outs/ directories found. Are you in the right directory?"
fi
