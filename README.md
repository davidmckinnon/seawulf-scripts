# seawulf-scripts

Utility scripts for single-cell RNA-seq analysis workflows on the Seawulf HPC cluster.

## Contents

### `cellranger/upload_cellranger_multi.sh`

Uploads Cell Ranger multi per-sample outputs to Google Drive using rclone.

**Prerequisites**
- `rclone` installed and configured with a remote named `gbackup`
- Cell Ranger multi has been run, producing `*_count/outs/per_sample_outs/` directories

**Usage**

Run from the directory containing your `*_count` folders:

```bash
cd /path/to/experiment_directory
bash upload_cellranger_multi.sh
```

**Files uploaded per sample**

| File | Location in Cell Ranger output | Purpose |
|------|-------------------------------|---------|
| `web_summary.html` | `per_sample_outs/{sample}/` | Interactive QC report |
| `metrics_summary.csv` | `per_sample_outs/{sample}/` | Machine-readable QC metrics |
| `sample_filtered_feature_bc_matrix.h5` | `per_sample_outs/{sample}/count/` | Filtered count matrix (Seurat/Scanpy) |
| `cell_types.csv` | `per_sample_outs/{sample}/count/` | Automated cell type annotations |
| `sample_cloupe.cloupe` | `per_sample_outs/{sample}/count/` | Loupe Browser file |

**Google Drive destination structure**

```
gbackup:
└── {experiment}_count/
    └── {sample}/
        ├── web_summary.html
        ├── metrics_summary.csv
        ├── sample_filtered_feature_bc_matrix.h5
        ├── cell_types.csv
        └── sample_cloupe.cloupe
```
