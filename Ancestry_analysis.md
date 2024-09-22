
### 1. 1kgenome dataset pre-processing
```for i in {1..20}; do echo -e "$i\tchr$i" >> rename_chrs.txt; done```
### 2. 1000G dataset pre-processing
```bcftools annotate --rename-chrs rename_chrs.txt 1kgenome_selectPop.vcf.gz -Oz -o 1kgenome_rename.vcf.gz```
### 3. 1000G dataset pre-processing
```tabix -p vcf 1kgenome_rename.vcf.gz```

### 4. Merge the test samples with the 1kgenome
(XXX)```bcftools merge 1kgenome_rename.vcf.gz P00110_1.hard-filtered.vcf.gz_vep_annotated.vcf.gz -Oz -o test_all_merge.vcf.gz --force-samples --missing-to-ref```

```bcftools merge -Oz -o P0092_42_samples_merged.normalized.merged_with_1kgenome.vcf.gz P0092_42_samples_merged.normalized.vcf.gz /Users/xiyas/ATPM_Project/ancestry_analysis/1kgenome_rename.vcf.gz```

### latest: test with teydep P001_25, P001_26, P001_167,P001_203
```tabix -p vcf  P0092_42_samples_merged.normalized.merged_with_1kgenome.vcf.gz```
```bcftools merge -Oz -o P0092_42_samples_merged.normalized.merged_with_1kgenome_teydep.vcf.gz P0092_42_samples_merged.normalized.merged_with_1kgenome.vcf.gz /Users/xiyas/ATPM_Project/P001_167.hard-filtered.vcf.gz_PASS.vcf.gz /Users/xiyas/ATPM_Project/P001_25.hard-filtered.vcf.gz_PASS.vcf.gz /Users/xiyas/ATPM_Project/P001_26.hard-filtered.vcf.gz_PASS.vcf.gz /Users/xiyas/ATPM_Project/P001_203.hard-filtered.vcf.gz_PASS.vcf.gz```


### 5. Making bed file from VCF file
```plink --vcf test_all_merge.vcf.gz --chr 1-22 X --make-bed --out test_merged --allow-extra-chr --double-id```

**generated** :: ```test_merged.bed``` 


### 6.method-1. random sampleling the snps and pilot trial of 1000 reference samples with 1 test sample
Higher FST (e.g., FST > 0.05): 
Populations are genetically more different (like African, European, and Asian populations), and you need fewer markers to differentiate between them — around 10,000 markers for GWAS correction.
Lower FST (e.g., FST < 0.01): 
Populations are genetically more similar (like different European populations), and you need more markers — closer to 100,000 markers — to capture the finer details of population structure.

#### 6.1 To select the first 500 samples and last 500 samples from datast (including all 5 superpopulatiosn. EUR, AMR, EAS, etc)
```head -n 500 test_merged.fam > first_500_samples.txt```
```tail -n 500 test_merged.fam > last_500_samples.txt```
```cat first_500_samples.txt last_500_samples.txt > combined_1000_samples.txt```

#### 6.2.1 Way 1 Extract the 20,000 SNPs and the 1,000 samples:
```plink --bfile test_merged --keep combined_1000_samples.txt --thin-count 20000 --make-bed --out test_subset_1000_samples_2w_snps```

#### 6.2.2 (Ongoing) Way 2 Select the less distant reference samples , with merged cohort of test samples (42 samples in P0092 project)
```cd /Users/xiyas/ATPM_Project/Anatolian _project_vcf/P0092_vcf/vcf```

```for vcf in *.vcf.gz; do tabix -p vcf $vcf done```
```bcftools merge -Oz -o P0092_42_samples_merged.vcf.gz P0092_*.hard-filtered.vcf.gz```

Check and Normalize Your Merged VCF: It’s a good idea to check your merged VCF for multiallelic sites or any format inconsistencies. Use bcftools norm to normalize the merged VCF:

```bcftools norm -m -any -Oz -o P0092_42_samples_merged.normalized.vcf.gz P0092_42_samples_merged.vcf.gz```

```tabix -p vcf P0092_42_samples_merged.normalized.vcf.gz```

Merge with 1kGenome: 

```bcftools merge -Oz -o P0092_42_samples_merged.normalized.merged_with_1kgenome.vcf.gz P0092_42_samples_merged.normalized.vcf.gz /Users/xiyas/ATPM_Project/ancestry_analysis/1kgenome_rename.vcf.gz```

#### 6.2.3 Way 3 Data pruning (next try)

```plink --bfile test_merged --indep-pairwise 50 10 0.1```
```plink --bfile test_merged --extract plink.prune.in --make-bed --out prunedData_test_merged```

#### 6.3 Run Admixture with CV
```for K in 4 5 6 7 8 9 10; do admixture --cv test_subset_1000_samples_2w_snps.bed $K | tee log${K}.out; done``` 
or run directly with one K
```admixture test_subset_1000_samples_2w_snps.bed $5```

### with P0092_samples:
plink --vcf P0092_42_samples_merged.normalized.merged_with_1kgenome.vcf.gz --chr 1-22 X --make-bed --out P0092_merged --allow-extra-chr --double-id 
**with teydep test data**
plink --vcf P0092_42_samples_merged.normalized.merged_with_1kgenome_teydep.vcf.gz --chr 1-22 X --make-bed  --thin-count 20000 --out P0092_teydep-merged --allow-extra-chr --double-id plink --bfile P0092_merged --keep combined_1000_samples.txt --thin-count 20000 --make-bed --out P0092_subset_1000_samples_2w_snps
admixture P0092_subset_1000_samples_2w_snps.bed 5
admixture P0092_teydep_subset_1000_samples_2w_snps.bed 5 
what I want to make: 
<img width="564" alt="image" src="https://github.com/user-attachments/assets/e3dd4081-5433-4a5f-ae71-c77b650e58ed">
