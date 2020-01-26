# Artic-rabv
Repository of material for rabies virus genomic surveillance using MinION sequencing (forked and modified from [artic-base](https://github.com/artic-network/artic-base).  
Includes resources and datasets used in publication:
Brunker K, Jaswant G, Thumbi SM et al. Rapid in-country sequencing of whole virus genomes to inform rabies elimination programmes [version 1; peer review: awaiting peer review]. Wellcome Open Res 2020, 5:3 (https://doi.org/10.12688/wellcomeopenres.15518.1)

# In development  
Scripts currently being modified so may not work currently

# To install: 
* Install the GitHub repository:  
```bash
git clone --recursive https://github.com/kirstyn/artic-rabv.git 
```
* Create conda environment to install tools  
```bash
conda env create -f artic-rabv/environment.yml
cd artic-rabv/fieldbioinformatics  
python setup.py install  
cd ../..  
source activate artic-rabv
pip install medaka
conda deactivate
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
rabvTanzDg= primers designed to target Tanzanian rabies virus  
rabvSEasia= primers designed to target SE Asia lineages of rabies virus  

# Protocols  
Full "sample-to-sequence" laboratory protocol for sequencing rabies virus samples on the MinION platform

# Sequence data  
Rabies virus consensus sequence datasets used for the publication "Rapid in-country sequencing of whole virus genomes to inform rabies elimination programmes" (Brunker et al, In Prep).  
Gel results from PCR validation tests on archived RABV samples.  

