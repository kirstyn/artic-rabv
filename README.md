## 🧬 ARTIC-RABV

> ⚠️ **This repository provides materials to support publications from 2020 and 2023 on in-country rabies virus genome sequencing using Oxford Nanopore (MinION).**  
> For the latest workflow, please see the [RAGE-toolkit](https://github.com/RAGE-toolkit/Artic-nf/tree/main/meta_data/primer-schemes/rabv_ea).

---

### 📄 Publications
**1.** Brunker K, Jaswant G, Thumbi SM, et al.  
*Rapid in-country sequencing of whole virus genomes to inform rabies elimination programmes*  
_Wellcome Open Research_, 2020, 5:3  
🔗 [DOI: 10.12688/wellcomeopenres.15518.1](https://doi.org/10.12688/wellcomeopenres.15518.1)

**2.** Bautista C, Jaswant G, French H, Campbell K, Durrant R, Gifford R, et al.  
*Whole genome sequencing for rapid characterization of rabies virus using nanopore technology*  
_Journal of Visualized Experiments (JoVE)_  
🔗 [DOI: 10.3791/65414](https://app.jove.com/t/65414/whole-genome-sequencing-for-rapid-characterization-rabies-virus-using)

---

### 🛠️ About This Repository

This repository contains resources for **rabies virus genomic surveillance using Oxford Nanopore MinION sequencing**.  
It is based on a fork of the [ARTIC base pipeline](https://github.com/artic-network/artic-base), with modifications and updates drawn from the latest `artic-ncov2019` conda environment.


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

