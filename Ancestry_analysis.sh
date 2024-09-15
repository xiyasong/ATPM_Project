```for i in {1..20}; do echo -e "$i\tchr$i" >> rename_chrs.txt; done```
```bcftools annotate --rename-chrs rename_chrs.txt 1kgenome_selectPop.vcf.gz -Oz -o 1kgenome_rename.vcf.gz```
```tabix -p vcf 1kgenome_rename.vcf.gz```
