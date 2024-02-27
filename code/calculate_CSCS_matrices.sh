#!/bin/bash

echo $1
echo $2
echo $3


dir=$1
abundance=$2
pa=$3

#dir="/Users/dlforrister/Library/CloudStorage/OneDrive-SmithsonianInstitution/Ecuador_XCMS_Projects/ERS_Seedling_Chemistry_V2_2023_Oct_10/results/gnps_output/custom_qemistree"
#abundance="quantification_table_V2_2023_10_10.tsv"
#pa="quantification_table_PA_V2_2023_10_10.tsv"

cd $dir
#cp ./*selfloop $dir/GNPS_edges.tsv

#source activate qiime2-2022.11
source activate /opt/homebrew/Caskroom/miniforge/base/envs/qiime2-2022.11
conda activate /opt/homebrew/Caskroom/miniforge/base/envs/qiime2-2022.11
#Abundance 

biom convert -i ./$abundance -o ./GNPS_buckettable_TIC.biom --table-type="OTU table" --to-hdf5
qiime tools import --type 'FeatureTable[Frequency]' --input-path GNPS_buckettable_TIC.biom --output-path GNPS_buckettable_TIC.qza

# no norm
#qiime cscs cscs --p-css-edges GNPS_edges.tsv --i-features GNPS_buckettable_TIC.qza --p-cosine-threshold 0.7 --p-no-normalization --o-distance-matrix cscs_distance_matrix_TIC_No_Norm.qza --verbose
#qiime tools export --input-path ./cscs_distance_matrix_TIC_No_Norm.qza --output-path ./cscs_distance_matrix_TIC_No_Norm.tsv

#mv ./cscs_distance_matrix_TIC_No_Norm.tsv/distance-matrix.tsv ./tmp_distance_matrix_TIC_No_Norm.tsv
#rm -r ./cscs_distance_matrix_TIC_No_Norm.tsv 
#mv ./tmp_distance_matrix_TIC_No_Norm.tsv ./cscs_distance_matrix_TIC_No_Norm.tsv

#rm cscs_distance_matrix_TIC_No_Norm.qza

#norm
#qiime cscs cscs --p-css-edges GNPS_edges.tsv --i-features GNPS_buckettable_TIC.qza --p-cosine-threshold 0.7 --p-normalization --o-distance-matrix cscs_distance_matrix_TIC_Norm.qza --verbose
#qiime tools export --input-path ./cscs_distance_matrix_TIC_Norm.qza --output-path ./cscs_distance_matrix_TIC_Norm.tsv

#mv ./cscs_distance_matrix_TIC_Norm.tsv/distance-matrix.tsv ./tmp_distance_matrix_TIC_Norm.tsv
#rm -r ./cscs_distance_matrix_TIC_Norm.tsv 
#mv ./tmp_distance_matrix_TIC_Norm.tsv ./cscs_distance_matrix_TIC_Norm.tsv

#rm cscs_distance_matrix_TIC_Norm.qza

#rm GNPS_buckettable_TIC.biom
#rm GNPS_buckettable_TIC.qza


#Presence Absence

biom convert -i ./$abundance -o ./GNPS_buckettable_PA.biom --table-type="OTU table" --to-hdf5
qiime tools import --type 'FeatureTable[Frequency]' --input-path GNPS_buckettable_PA.biom --output-path GNPS_buckettable_PA.qza

# no norm
qiime cscs cscs --p-css-edges GNPS_edges.tsv --i-features GNPS_buckettable_PA.qza --p-cosine-threshold 0.7 --p-no-normalization --o-distance-matrix cscs_distance_matrix_PA_No_Norm.qza --verbose
qiime tools export --input-path ./cscs_distance_matrix_PA_No_Norm.qza --output-path ./cscs_distance_matrix_PA_No_Norm.tsv

mv ./cscs_distance_matrix_PA_No_Norm.tsv/distance-matrix.tsv ./tmp_distance_matrix_PA_No_Norm.tsv
rm -r ./cscs_distance_matrix_PA_No_Norm.tsv 
mv ./tmp_distance_matrix_PA_No_Norm.tsv ./cscs_distance_matrix_PA_No_Norm.tsv

rm cscs_distance_matrix_PA_No_Norm.qza

#norm
qiime cscs cscs --p-css-edges GNPS_edges.tsv --i-features GNPS_buckettable_PA.qza --p-cosine-threshold 0.7 --p-normalization --o-distance-matrix cscs_distance_matrix_PA_Norm.qza --verbose
qiime tools export --input-path ./cscs_distance_matrix_PA_Norm.qza --output-path ./cscs_distance_matrix_PA_Norm.tsv

mv ./cscs_distance_matrix_PA_Norm.tsv/distance-matrix.tsv ./tmp_distance_matrix_PA_Norm.tsv
rm -r ./cscs_distance_matrix_PA_Norm.tsv 
mv ./tmp_distance_matrix_PA_Norm.tsv ./cscs_distance_matrix_PA_Norm.tsv

rm cscs_distance_matrix_PA_Norm.qza

rm GNPS_buckettable_PA.biom
rm GNPS_buckettable_PA.qza


### Calculate Tree

qiime tools import \
    --input-path /Users/dlforrister/Library/CloudStorage/OneDrive-SmithsonianInstitution/Ecuador_XCMS_Projects/ERS_Seedling_Chemistry_V2_2023_Oct_10/results/gnps_output/custom_qemistree/compoundxcompound_tree_summary.tre \
    --type 'Phylogeny[Unrooted]' \
    --output-path closed_reference.qza

#Ok so feature data should be relatively the same. 
#Tree should be able to import with the above method


qiime qemistree prune-hierarchy \
  --i-feature-data classified-merged-feature-data.qza \
  --p-column class \
  --i-tree merged-qemistree.qza \
  --o-pruned-tree merged-qemistree-class.qza


#Need to merge the tree, feature table and metadata file so we only include things that have annotations - or we can do this in R
#Need to get format of sample sample metadata - write to csv
#Need to get format of feature metadata
#
qiime empress community-plot \
    --i-tree merged-qemistree-class.qza \
    --i-feature-table feature-table-hashed.qza \
    --m-sample-metadata-file path-to-sample-metadata.tsv \
    --m-feature-metadata-file classified-merged-feature-data.qza \
    --o-visualization empress-tree.qzv