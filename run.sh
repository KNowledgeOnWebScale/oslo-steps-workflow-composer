#!/bin/sh

#first we produce the steps on each level based on the OSLO steps descriptions
eye variables_and_predicates.n3 change-address-steps.ttl change-address-states.ttl change-address-shapes2.ttl step-reasoning.n3 aux.n3 createPattern2.n3 --query mappingRuleCreationJourney.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >journey-level-steps.n3

eye variables_and_predicates.n3 change-address-steps.ttl change-address-states.ttl change-address-shapes2.ttl step-reasoning.n3 aux.n3 createPattern2.n3 --query mappingRuleCreationContainer.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >container-level-steps.n3

eye variables_and_predicates.n3 change-address-steps.ttl change-address-states.ttl change-address-shapes2.ttl step-reasoning.n3 aux.n3 createPattern2.n3 --query mappingRuleCreationCL-Level.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > component-level-steps.n3


#For each goal we forsee a preselection step of relevant steps. If the goal is fixed, we can also keep the steps fixed.

#################################################
# Journey Level
###################################################

#To compute the highest level workflow use:
eye gps-plugin_modified.n3 knowledge.n3 journey-level-steps.n3 change-address-steps.ttl --query journeyGoal.n3 --nope > all_journey-paths.n3


#To compute the highest level workflow without permutations use 
eye gps-plugin_modified_noPermutations.n3 knowledge.n3 journey-level-steps.n3 change-address-steps.ttl --query journeyGoal.n3 --nope > journey-paths_noPermutation.n3


#################################################
# Container Level
###################################################
#
# Goal1: address change
#
#

# we use backwards reasoning to see which steps can lead to the goal (this step does not need to be repeated whenever we use the goal, only if either the steps or the goal changes).
eye  container-level-steps.n3 knowledge.n3 --query Preselection/pregeneration.n3 --nope >shortContainerDescriptions.n3
eye container-level-steps.n3 shortContainerDescriptions.n3 containerGoal_addressChange.n3 Preselection/preselection.n3 knowledge.n3 --nope --query Preselection/prequery.n3 >AddressChangeSelected.n3


eye gps-plugin_modified_noPermutations.n3 knowledge.n3 AddressChangeSelected.n3 change-address-steps.ttl --query containerGoal_addressChange.n3 --nope > container-address-paths.n3


