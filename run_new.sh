#!/bin/sh

#first we produce the steps on each level based on the OSLO steps descriptions
eye NewSteps.n3 change-address-states.ttl change-address-shapes.ttl step-reasoning.n3 aux.n3 createPattern2.n3 --query mappingRuleCreationJourney.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >journey-level-steps.n3

eye  NewSteps.n3 change-address-states.ttl change-address-shapes.ttl step-reasoning.n3 aux.n3 createPattern2.n3 --query mappingRuleCreationContainer.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >container-level-steps.n3

eye  NewSteps.n3 change-address-states.ttl change-address-shapes.ttl step-reasoning.n3 aux.n3 createPattern2.n3 --query mappingRuleCreationCL-Level.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > component-level-steps.n3


#################################################
# Journey Level
#################################################

# Preselection step based on the goal
eye  journey-level-steps.n3 knowledge.n3 --query Preselection/pregeneration.n3 --nope >shortJourneyDescriptions.n3


eye journey-level-steps.n3 shortJourneyDescriptions.n3 newJourneyGoal.n3 Preselection/preselection.n3 knowledge.n3 --nope --query Preselection/prequery.n3 >selectedSteps.n3

#To compute the highest level workflow use:
eye gps-plugin_modified.n3 knowledge.n3 selectedSteps.n3 NewSteps.n3 --query newJourneyGoal.n3 --nope > all_journey-paths.n3


#To compute the highest level workflow without permutations use 
eye gps-plugin_modified_noPermutations.n3 knowledge.n3 selectedSteps.n3 NewSteps.n3 --query newJourneyGoal.n3 --nope > journey-paths_noPermutation.n3


#################################################
# Container Level
###################################################

#for our preselection steps we need short descriptions
eye  container-level-steps.n3 knowledge.n3 --query Preselection/pregeneration.n3 --nope >shortContainerDescriptions.n3



#
# Goal1: address change
#
#

# we use backwards reasoning to see which steps can lead to the goal (this step does not need to be repeated whenever we use the goal, only if either the steps or the goal changes).
#eye  container-level-steps.n3 knowledge.n3 --query Preselection/pregeneration.n3 --nope >shortContainerDescriptions.n3
#eye container-level-steps.n3 shortContainerDescriptions.n3 containerGoal_addressChange.n3 Preselection/preselection.n3 knowledge.n3 --nope --query Preselection/prequery.n3 >AddressChangeSelected.n3


#eye gps-plugin_modified_noPermutations.n3 knowledge.n3 AddressChangeSelected.n3 change-address-steps.ttl --query containerGoal_addressChange.n3 --nope > container-address-paths.n3


#
# Goal Waste collection
#




# create goal based on step name
eye selected_Waste.n3 journey-level-steps.n3 --query subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > createdGoal.n3

#create a dummy step which creates the input data of the step (this is needed if we want to create sub-workflows for steps which rely on others).
eye selected_Waste.n3 journey-level-steps.n3 --query creationOfRuleForMissingData.n3 --nope  > extraRule.n3
#todo: if this rule adds data, it should be visible in the output as one step


#preselect
eye container-level-steps.n3 shortContainerDescriptions.n3 createdGoal.n3 Preselection/preselection.n3 knowledge.n3 --nope --query Preselection/prequery.n3 >selectedSteps.n3

#create path
eye gps-plugin_modified_noPermutations.n3 knowledge.n3 extraRule.n3 aux2.n3 selectedSteps.n3 NewSteps.n3 --query createdGoal.n3 --nope > WasteContainer_noPermutation.n3



#
# Goal Request address change
#


# create goal based on step name
eye selected_AddressSubmission.n3 journey-level-steps.n3 --query subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > createdGoal.n3

#create rule to add input info for the step
eye selected_AddressSubmission.n3 journey-level-steps.n3 --query creationOfRuleForMissingData.n3 --nope >extraRule.n3

#preselect
eye container-level-steps.n3 shortContainerDescriptions.n3 createdGoal.n3 Preselection/preselection.n3 knowledge.n3 --nope --query Preselection/prequery.n3 >selectedSteps.n3

#createPath
eye gps-plugin_modified_noPermutations.n3 knowledge.n3 extraRule.n3 aux2.n3 selectedSteps.n3 NewSteps.n3 --query createdGoal.n3 --nope > ChangeAddress_noPermutation.n3


#####################################################
# Component level
##################################################
eye  component-level-steps.n3 knowledge.n3 --query Preselection/pregeneration.n3 --nope >shortComponentDescriptions.n3

#
# Policevisit
#

# create goal based on step name
eye selected_Policevisit.n3 container-level-steps.n3 --query subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > createdGoal.n3

# create rule to add input info for the step
eye selected_Policevisit.n3 container-level-steps.n3 --query creationOfRuleForMissingData.n3 --nope >extraRule.n3

#preselect
eye component-level-steps.n3 shortComponentDescriptions.n3 createdGoal.n3 Preselection/preselection.n3 knowledge.n3 --nope --query Preselection/prequery.n3 >selectedSteps.n3

#createPath
eye gps-plugin_modified_noPermutations.n3 knowledge.n3 extraRule.n3 aux2.n3 selectedSteps.n3 NewSteps.n3 --query createdGoal.n3 --nope > Policevisit_noPermutation.n3

#
# office visit to change id
#
#TODO

#################################3
#to be adjusted, here a container level is still missing (is that necessary?)

eye component-level-steps.n3 shortComponentDescriptions.n3 Goal_personalInformation.n3 Preselection/preselection.n3 knowledge.n3 --nope --query Preselection/prequery.n3 >PersonalInfoSelected.n3


#here, we get the output with all permutations, that is not really what we want, therefore that is commented out
#eye gps-plugin_modified.n3 knowledge.n3 PersonalInfoSelected.n3 NewSteps.n3 --query Goal_personalInformation.n3 --nope > personalInfo-paths.n3


# personalInfo
eye gps-plugin_modified_noPermutations.n3 knowledge.n3 PersonalInfoSelected.n3 NewSteps.n3 --query Goal_personalInformation.n3 --nope > personalInfo_noPermutation.n3

#moving data
eye component-level-steps.n3 shortComponentDescriptions.n3 Goal_provideMovingData.n3 Preselection/preselection.n3 knowledge.n3 --nope --query Preselection/prequery.n3 >PersonalInfoSelected.n3

eye gps-plugin_modified_noPermutations.n3 knowledge.n3 PersonalInfoSelected.n3 NewSteps.n3 --query Goal_provideMovingData.n3 --nope > movingData_noPermutation.n3



