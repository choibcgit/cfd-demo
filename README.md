# CFD Demo

Computational Fluid Dynamics (CFD) analysis project for turbulent pipe flow simulation.

## Files

- `cfd_analysis.m` — MATLAB script for CFD analysis
- `cfd_full_analysis.js` — Node.js CFD analysis pipeline
- `analyze_cfd.js` — CFD result analyzer
- `create_paper.js` — Paper generation script
- `export_json.m` — MATLAB JSON export utility
- `cfd_export_results.m` — MATLAB results export script

## Results

Analysis results are stored in:
- `cfd_analysis_results.json`
- `cfd_analysis_results_2.json`

## Requirements

- Node.js 18+
- MATLAB (for `.m` scripts)

## Usage

```bash
npm install
npm start        # runs cfd_full_analysis.js
npm run analyze  # runs analyze_cfd.js
```
