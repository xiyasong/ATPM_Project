# 1.1kgenome dataset pre-processing
for i in {1..20}; do echo -e "$i\tchr$i" >> rename_chrs.txt; done
# 2.1000G dataset pre-processing
bcftools annotate --rename-chrs rename_chrs.txt 1kgenome_selectPop.vcf.gz -Oz -o 1kgenome_rename.vcf.gz
# 3.1000G dataset pre-processing
tabix -p vcf 1kgenome_rename.vcf.gz

# 4.Merge the test samples with the 1kgenome
bcftools merge 1kgenome_rename.vcf.gz P00110_1.hard-filtered.vcf.gz_vep_annotated.vcf.gz -Oz -o test_all_merge.vcf.gz --force-samples --missing-to-ref
# 5.Making bed file from VCF file
plink --vcf test_all_merge.vcf.gz --chr 1-22 X --make-bed --out test_merged --allow-extra-chr --double-id

generated :: test_merged.bed


# 6.method-1. random sampleling the snps 
# Higher FST (e.g., FST > 0.05): 
Populations are genetically more different (like African, European, and Asian populations), and you need fewer markers to differentiate between them — around 10,000 markers for GWAS correction.
# Lower FST (e.g., FST < 0.01): 
Populations are genetically more similar (like different European populations), and you need more markers — closer to 100,000 markers — to capture the finer details of population structure.


# 6.method-2.Data pruning (next try)

plink--bfile test_merged.bed --indep-pairwise 50 10 0.1
plink--bfile test_merged.bed --extract plink.prune.in --make-bed --out prunedData
