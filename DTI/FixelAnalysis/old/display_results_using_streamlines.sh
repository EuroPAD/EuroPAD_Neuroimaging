#!/bin/bash

#unfinished
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels

included_tracts=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_files/all_included_bundles.tck

###########fc###########
#####amyloid#
#t1#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/fwe_1mpvalue_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/t1.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/std_effect_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/colour_t1.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/t1.tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/t1_smooth.tsf

#t2#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/fwe_1mpvalue_t2.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/t2.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/std_effect_t2.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/colour_t2.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/t2.tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/amyloid/both_contrasts/t2_smooth.tsf

####tau#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/tau/both_contrasts/fwe_1mpvalue_t2.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/tau/both_contrasts/t2.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/tau/both_contrasts/std_effect_t2.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/tau/both_contrasts/colour_t2.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/tau/both_contrasts/t2.tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/tau/both_contrasts/t2_smooth.tsf

####migration#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/pathway4_migration_noapoe_BA/both_contrasts/fwe_1mpvalue_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/pathway4_migration_noapoe_BA/both_contrasts/t1.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/pathway4_migration_noapoe_BA/both_contrasts/std_effect_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/pathway4_migration_noapoe_BA/both_contrasts/colour_t1.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/pathway4_migration_noapoe_BA/both_contrasts/t1.tsf ${fixeldir}/template/tract_stats/all_included_bundles/log_fc_smooth/pathway4_migration_noapoe_BA/both_contrasts/t1_smooth.tsf

###############fd##########
####amyloid#
#t1#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/fwe_1mpvalue_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/t1.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/std_effect_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/colour_t1.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/t1.tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/t1_smooth.tsf

#t2#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/fwe_1mpvalue_t2.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/t2.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/std_effect_t2.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/colour_t2.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/t2.tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/amyloid/both_contrasts/t2_smooth.tsf

####tau#
#t1#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/fwe_1mpvalue_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/t1.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/std_effect_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/colour_t1.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/t1.tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/t1_smooth.tsf

#t2#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/fwe_1mpvalue_t2.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/t2.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/std_effect_t2.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/colour_t2.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/t2.tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/tau/both_contrasts/t2_smooth.tsf

####signal transduction#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway2_migration_noapoe_BA/both_contrasts/fwe_1mpvalue_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway2_migration_noapoe_BA/both_contrasts/t1.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway2_migration_noapoe_BA/both_contrasts/std_effect_t1.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway2_migration_noapoe_BA/both_contrasts/colour_t1.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway2_migration_noapoe_BA/both_contrasts/t1.tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway2_migration_noapoe_BA/both_contrasts/t1_smooth.tsf

####amyloid pathway interact with amyloid#
fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway5_amyloid_noapoe_BA_int/contrasts/fwe_1mpvalue_t4.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway5_amyloid_noapoe_BA_int/contrasts/t4.tsf

fixel2tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway5_amyloid_noapoe_BA_int/contrasts/std_effect_t4.mif $included_tracts ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway5_amyloid_noapoe_BA_int/contrasts/colour_t4.tsf

tsfsmooth -stdev 2 ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway5_amyloid_noapoe_BA_int/contrasts/t4.tsf ${fixeldir}/template/tract_stats/all_included_bundles/fd_smooth/pathway5_amyloid_noapoe_BA_int/contrasts/t4_smooth.tsf

