# seawulf-scripts

Utility scripts for single-cell RNA-seq analysis workflows on the Seawulf HPC cluster.

## Contents

### `cellranger/upload_cellranger_multi.sh`

Uploads Cell Ranger multi per-sample outputs to Google Drive using rclone.

**Prerequisites**
- `rclone` installed and configured with a remote named `gbackup`
- Cell Ranger multi has been run, producing the directory structure below

**Expected directory structure**

```
sc145/                          ← run script from here
├── sc145_A/
│   ├── sc145_A.csv             (multi config)
│   ├── sc145_A.slurm           (job submission script)
│   ├── sc145_A.txt             (library/reference file)
│   └── sc145_A_count/
│       └── outs/
│           └── per_sample_outs/
│               ├── control_1/
│               ├── control_2/
│               ├── PTX_1/
│               └── PTX_2/
├── sc145_B/
├── sc145_C/
└── sc145_D/
```

**Usage**

```bash
cd /path/to/sc145
bash /path/to/seawulf-scripts/cellranger/upload_cellranger_multi.sh
```

**Files uploaded per experiment**

| File | Source location | Destination |
|------|----------------|-------------|
| `{experiment}.csv` | `sc145_A/` | `gbackup:{experiment}_count/` |
| `{experiment}.slurm` | `sc145_A/` | `gbackup:{experiment}_count/` |
| `{experiment}.txt` | `sc145_A/` | `gbackup:{experiment}_count/` |

**Files uploaded per sample**

| File | Source location | Purpose |
|------|----------------|---------|
| `web_summary.html` | `per_sample_outs/{sample}/` | Interactive QC report |
| `metrics_summary.csv` | `per_sample_outs/{sample}/` | Machine-readable QC metrics |
| `sample_filtered_feature_bc_matrix.h5` | `per_sample_outs/{sample}/count/` | Filtered count matrix (Seurat/Scanpy) |
| `cell_types.csv` | `per_sample_outs/{sample}/count/` | Automated cell type annotations (optional) |
| `sample_cloupe.cloupe` | `per_sample_outs/{sample}/count/` | Loupe Browser file |

**Google Drive destination structure**

```
gbackup:
└── sc145_A_count/
    ├── sc145_A.csv
    ├── sc145_A.slurm
    ├── sc145_A.txt
    └── control_1/
        ├── web_summary.html
        ├── metrics_summary.csv
        ├── sample_filtered_feature_bc_matrix.h5
        ├── cell_types.csv          (if present)
        └── sample_cloupe.cloupe
```
