# MadGraph Parameter Scan Setup

This setup is designed for running parameter scans for MadGraph-produced processes. It automates the generation of parameter combinations, submission to HTCondor, and extraction of cross-section results.

## Overview

The workflow scans over multiple physics parameters:
- **sinθ** (sintheta): Mixing angle values
- **tanβ** (tanbeta): Ratio of vacuum expectation values
- **m35/m36/m37** (mass37): Mass parameters for particles 35, 36, and 37
- **m55** (mass55): Mass parameter for particle 55

## Files Description

### Core Scripts

- **`make_joblist.py`**: Generates a job list file (`joblist.txt`) with all parameter combinations to scan
- **`runMadscan.sh`**: Executes a single MadGraph job for a given parameter set
- **`subMadscan.sub`**: HTCondor submission file for batch job processing
- **`extract_cross_sections.py`**: Extracts cross-sections from completed MadGraph runs and creates a summary table
- **`launch_card_template.dat`**: Template for MadGraph launch cards with parameter placeholders

### Data Files

- **`bbdm_2HDMa_type1_case1_scan.tar.gz`**: Compressed MadGraph process directory containing the physics model and process definition
- **`joblist.txt`**: Generated file containing all parameter combinations (one per line: `sintheta tanbeta m35 m55`)

## Setup Instructions

### 1. Prerequisites

- **MadGraph5_aMC@NLO**: The MadGraph installation must be available
- **HTCondor**: For batch job submission (if using cluster)
- **Python 3**: For running the job list generator and cross-section extraction script
- **Bash**: For running the scan script

### 2. Configure Parameters

Edit `make_joblist.py` to set your desired parameter ranges:

```python
sint    = [0.35,0.7]           # sinθ values
tanbeta = [3,5,10,15,20,25,30,35,40,50]  # tanβ values
mass37  = [100,200,300,400,500,600,700,800,900,1000,1100,1200,1500]  # m35/m36/m37 values
mass55  = [10,50,100,200,300,400,500,600,700,800,900,1000,1100,1200,1500]  # m55 values
```

### 3. Configure Launch Card Template

Edit `launch_card_template.dat` to set:
- Fixed parameters (per job)
- Parameter placeholders that will be replaced:
  - `__TANBETA__`: Replaced with tanβ value
  - `__SINTHETA__`: Replaced with sinθ value
  - `__M35__`, `__M36__`, `__M37__`: Replaced with mass37 value
  - `__M55__`: Replaced with m55 value

### 4. Configure HTCondor Submission (if using cluster)

Edit `subMadscan.sub` to set:
- **`transfer_input_files`**: Path to your MadGraph process tar.gz file
- **`request_memory`**: Memory requirements (default: 8000 MB)
- **`request_cpus`**: CPU requirements (default: 4)
- **`+JobFlavour`**: Job priority/flavour (default: "workday")

**Important**: Update the path to your tar.gz file:
```
transfer_input_files = /path/to/your/bbdm_2HDMa_type1_case1_scan.tar.gz,launch_card_template.dat
```

## Usage Instructions

### Step 1: Generate Job List

Run the Python script to generate all parameter combinations:

```bash
python3 make_joblist.py
```

This creates `joblist.txt` with all parameter combinations. The script will print the total number of jobs.

**Example output:**
```
Total jobs: 3900
```

### Step 2: Create Required Directories

Create directories for logs and results:

```bash
mkdir -p logs/output logs/error logs/log
mkdir -p results
```

### Step 3: Submit Jobs to HTCondor

Submit all jobs to the cluster:

```bash
condor_submit subMadscan.sub
```

This will submit one job per line in `joblist.txt`. Each job will:
1. Extract the MadGraph process directory
2. Generate a launch card with specific parameters
3. Run MadEvent
4. Copy results to the `results/` directory

### Step 4: Monitor Jobs

Check job status:

```bash
condor_q
```

View job logs:
- Output: `logs/output/mg.*.out`
- Errors: `logs/error/mg.*.err`
- General log: `logs/log/mg.*.log`

### Step 5: Extract Cross-Sections and Get the Cross-Section File

After jobs complete, extract cross-sections from all results:

```bash
python3 extract_cross_sections.py
```

This script:
- Scans the `results/` directory for all `Events_*` directories
- Parses parameter values from directory names
- Extracts cross-sections from banner files
- Creates `cross_section_table.txt` with a formatted table

**Output format:**
```
# Cross-section table
# Format: sintheta | tanbeta | mA | ma | cross_section (pb)
sintheta     tanbeta    mA       ma       cross_section (pb)
0.3500       3.0        100.0    10.0     0.0001731989
...
```

### Step 6: Access the Cross-Section File

The cross-section file is created in the current working directory:

**File location:**
```
./cross_section_table.txt
```

**To view the file:**
```bash
# View the entire file
cat cross_section_table.txt

# View with pagination (press 'q' to quit)
less cross_section_table.txt

# View first 20 lines
head -20 cross_section_table.txt

# View last 20 lines
tail -20 cross_section_table.txt
```

**To copy the file to another location:**
```bash
# Copy to your home directory
cp cross_section_table.txt ~/

# Copy to a specific directory
cp cross_section_table.txt /path/to/destination/

# Copy with a new name
cp cross_section_table.txt my_cross_sections.txt
```

**File format:**
- The file is a space-delimited text file
- First two lines are comments (starting with `#`)
- Header line contains column names
- Data lines contain: `sintheta tanbeta mA ma cross_section(pb)`
- Values are sorted by parameters for easy reading

**To extract specific entries:**
```bash
# Find entries with specific sintheta value
grep "0.3500" cross_section_table.txt

# Find entries with specific tanbeta value
grep " 3.0 " cross_section_table.txt

# Count total entries (excluding header and comments)
grep -v "^#" cross_section_table.txt | tail -n +2 | wc -l
```

**Note:** If the file is not created or is empty:
1. Ensure all jobs have completed successfully
2. Check that `results/` directory contains `Events_*` subdirectories
3. Verify that banner files exist in the result directories
4. Re-run `extract_cross_sections.py` - it will overwrite the existing file

## Running Locally (Without HTCondor)

If you want to run a single job locally for testing:

```bash
./runMadscan.sh <JOBID> <SINTHETA> <TANBETA> <M35> <M55>
```

**Example:**
```bash
./runMadscan.sh 0 0.35 3 100 10
```

Make sure the script is executable:
```bash
chmod +x runMadscan.sh
```

## Directory Structure

After running, your directory structure should look like:

```
.
├── make_joblist.py
├── runMadscan.sh
├── subMadscan.sub
├── extract_cross_sections.py
├── launch_card_template.dat
├── bbdm_2HDMa_type1_case1_scan.tar.gz
├── joblist.txt
├── cross_section_table.txt
├── logs/
│   ├── output/
│   ├── error/
│   └── log/
└── results/
    ├── Events_st0p35_tb3_mA100_ma10/
    ├── Events_st0p35_tb3_mA100_ma50/
    └── ...
```

## Troubleshooting

### Jobs Failing

1. **Check error logs**: Look in `logs/error/` for specific error messages
2. **Verify tar.gz path**: Ensure the path in `subMadscan.sub` is correct and accessible
3. **Check memory/CPU**: Increase `request_memory` or `request_cpus` if jobs are killed
4. **Verify MadGraph installation**: Ensure MadGraph is available in the job environment

### Missing Results

1. **Check if jobs completed**: Use `condor_history` to see completed jobs
2. **Verify output transfer**: Check that `transfer_output_files = results` is set correctly
3. **Check disk space**: Ensure sufficient space for results

### Cross-Section Extraction Issues

1. **Verify banner files exist**: Check that `*_banner.txt` files are present in result directories
2. **Check directory naming**: Ensure directory names follow the pattern `Events_st*_tb*_mA*_ma*`
3. **Run with verbose output**: The script prints warnings for missing files

## Customization

### Adding More Parameters

To scan additional parameters:

1. Add parameter arrays to `make_joblist.py`
2. Add nested loops to generate combinations
3. Update the `f.write()` line to include new parameters
4. Update `runMadscan.sh` to accept and use new parameters
5. Update `launch_card_template.dat` with new placeholders
6. Update `subMadscan.sub` arguments line

### Changing Output Location

Edit `runMadscan.sh` to change where results are stored:

```bash
RESULT_DIR="../results/Events_st${SINTHETA_TAG}_tb${TANBETA}_mA${M35}_ma${M55}"
```

### Modifying Job Resources

Edit `subMadscan.sub`:
- `request_memory`: Memory in MB
- `request_cpus`: Number of CPUs
- `+JobFlavour`: Job priority ("espresso", "microcentury", "longlunch", "workday", "tomorrow", "testmatch", "nextweek")

## Notes

- The total number of jobs is the product of all parameter array lengths
- Each job runs independently, so they can be parallelized
- Results are stored in separate directories for each parameter combination
- The cross-section extraction script sorts results by parameter values for easy reading
- Decimal points in sinθ are converted to 'p' in directory names (e.g., 0.35 → 0p35)

## Contact

For questions or issues, refer to your local HPC documentation or MadGraph user guide.
