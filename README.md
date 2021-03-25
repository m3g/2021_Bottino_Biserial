# 2020_Bottino_Biserial_Scripts

Those are the scripts and sample data files that go along with the article _**Structural discrimination analysis for constraint selection in protein modeling**_ (XXX) by G. Bottino and L. Martínez.

___
## Setting up

In order to follow this tutorial, you will need to set up some software:

1. If you want to use only the analysis and selection scripts...

   - **Up-to-date versions of Lovoalign and G-Score softwares**, both by M3G. You will need a FORTRAN compiler to build those programs. We suggest _gfortran_ for the linux users. If you emply a Ubuntu-based distribution, you may install _gfortran_ by merely executing `apt install gfortran` with _sudo_ privileges.
     - Lovoalign is a structural alignment package and can be obtained on https://github.com/m3g/lovoalign.git. Installation instructions are available on the README page.
     - G-score is a model score estimation package and can be obtained on https://github.com/m3g/gscore.git. Installation instructions are available on the README page.
   - **An installation of the Julia computing language, version at least 1.2**. To obtain Julia, visit https://julialang.org/downloads/ and follow the instructions.
   - **Up-to-date versions of the Julia packages PDBTools and XCorrelation**, both by M3G.
     - PDBTools is a simple PDB manipulation package with friendly vmd-based syntax. It is available on https://github.com/m3g/PDBTools.git. Since PDBTools is currently into the Julia registry, it can be installed with the command `$julia> ]add PDBTools`. For the development version, use `$julia> ]add https://github.com/m3g/PDBTools.git`.
     - XCorrelation is the Julia package that implements the biserial selection in the article. It is available in https://github.com/m3g/XCorrelation.git. To install the package, use `$julia> ]add https://github.com/m3g/XCorrelation.git`

2. If you want to run some modeling rounds as well...

   - _All the softare above, plus_
   - **A capable compilation of the Rosetta modeling software suite**
     - Rosetta comes in many versions and installation/compilation and configuration may require some information about your computing system. Ask your system administrator for help and/or refer to https://www.rosettacommons.org/demos/latest/tutorials/install_build/install_build to get further instructions. In this work, we employed Rosetta version X.XX.XXXXXX

___
## Example Target: PDB 1C75

In this repository, we provide detailed instructions for reproduction of all resultes for target PDBID 1C75, chain A. PDB_1C75_A is a 71-residue-long protein and, due to its size, the results can be obtained quickly.

### Contents

We provide the following files: _TODO_

```
PDB_1C75_A                                      Parent folder
|--- FIXED_INPUT                                Folder containing the INPUT files for modeling
     |--- 1C75_A.fasta                          Protein sequence in FASTA format
     |--- 1C75_A.pdb                            Protein structure in PDB format
     |--- aa1C75A03_05.200_v1_3                 Rosetta Frag3 file (legacy format, obtained from old.robetta.org)
     |--- aa1C75A09_05.200_v1_3                 Rosetta Frag9 file (legacy format, obtained from old.robetta.org)
|--- PREDICTION                                 Folder containing files relevant to the preliminary DCA
     |--- 1C75_A_DCA_RESULTS.dat                File with DI estimates between residues using GaussDCA.jl
     |--- 1C75_A_DCA_constraints.cst            Constraint file in the Rosetta Format
     |--- 1C75_A_MSA_NOGAP.msa                  MSA of target protein aligned to its family and trimmed to target length (input to DCA)
|--- MODELING                                   Folder containing the actual modeling scripts
     |--- rosetta_flags.txt                     Parameter flags for the Rosetta AbinitioRelax protocol
     |--- modeling_round.pbs                    Generic PBS modeling round script (to be adapted according to infrastructure)
|--- 1C75_A_PRE00                               Folder containing the results of the preliminary round for target 1C75_A_PRE00
     |--- 1C75_A_PRE00_PDBfiles.tar.gz     Tar file containing the PDB files generated
     |--- 1C75_A_PRE00_alignlogs.tar.gz    Tar file containing the alignment logs for all-on-all alignment
     |--- aa1C75A03_05.200_v1_3                 Rosetta Frag3 file (legacy format, obtained from old.robetta.org)
     |--- aa1C75A09_05.200_v1_3                 Rosetta Frag9 file (legacy format, obtained from old.robetta.org)
|--- constraintSelector.jl                      Script responsible for constraint selection
```

### Tutorial

1. Clone this repository
2. Extract the `.tar.gz` files in their respective folders. Move or delete the original file afterwards.

_TODO_
