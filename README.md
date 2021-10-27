# Artic-rabv
Repository of material for rabies virus genomic surveillance using MinION sequencing (forked and modified from [artic-base](https://github.com/artic-network/artic-base) and the latest conda environment from artic-ncov2019
Includes resources and datasets used in publication:
Brunker K, Jaswant G, Thumbi SM et al. Rapid in-country sequencing of whole virus genomes to inform rabies elimination programmes [version 1; peer review: awaiting peer review]. Wellcome Open Res 2020, 5:3 (https://doi.org/10.12688/wellcomeopenres.15518.1)


# To install: 
* Install the GitHub repository:  
```bash
git clone --recursive https://github.com/kirstyn/artic-rabv.git 
```
* Install mamba, which massively speeds up conda environment install:  
```bash
conda install mamba -n base -c conda-forge
```
* Create conda environment to install tools (using mamba). Modify the filepath after -f to reflect where you have installed artic-rabv on your computer.
* This will take a few minutes
```bash
mamba env create -f artic-rabv/environment.yml
``` 

* Use this command to activate your environment  
```bash
source activate artic-rabv  
```

* To update your environment after changes to environment file
```bash
conda env update --file artic-rabv/environment.yml
```

# Primer schemes  
Multiplex primer schemes for rabies virus whole genome sequencing, designed using Primal Scheme (http://primal.zibraproject.org/)  
rabvTanzDg= primers designed to target Tanzanian rabies virus (2016)
rabv_ea=updated primers for East Africa rabies virus lineages (2018)
rabvSEasia= primers designed to target SE Asia lineages of rabies virus  
rabvPeru2= primers designed to target lineages of rabies virus in Puno/Arequipa, Peru

# Protocols  
Full "sample-to-sequence" laboratory protocol for sequencing rabies virus samples on the MinION platform

# Sequence data  
Rabies virus consensus sequence datasets used for the publication "Rapid in-country sequencing of whole virus genomes to inform rabies elimination programmes" (Brunker et al, 2020, Wellcome Open Research).  
Gel results from PCR validation tests on archived RABV samples.  

