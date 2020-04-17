#!/bin/sh

#first we produce the steps on each level based on the OSLO steps descriptions
eye oslo-descriptions/change-address-steps.ttl oslo-descriptions/change-address-states.ttl oslo-descriptions/change-address-shapes.ttl translation/step-reasoning.n3 translation/help.n3 translation/createPattern.n3 --query translation/mappingRuleCreationJourney.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >interim/journey-level-steps.n3


eye oslo-descriptions/change-address-steps.ttl oslo-descriptions/change-address-states.ttl oslo-descriptions/change-address-shapes.ttl translation/step-reasoning.n3 translation/help.n3 translation/createPattern.n3 --query translation/mappingRuleCreationContainer.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >interim/container-level-steps.n3

eye oslo-descriptions/change-address-steps.ttl oslo-descriptions/change-address-states.ttl oslo-descriptions/change-address-shapes.ttl translation/step-reasoning.n3 translation/help.n3 translation/createPattern.n3 --query translation/mappingRuleCreationComponent.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >interim/component-level-steps.n3


#################################################
# Journey Level
#################################################

# Preselection step based on the goal
eye  interim/journey-level-steps.n3 profile/knowledge.n3  --query preselection/pregeneration.n3 --nope >interim/shortJourneyDescriptions.n3


eye interim/journey-level-steps.n3 interim/shortJourneyDescriptions.n3 journey/journeyGoal.n3 preselection/preselection.n3 profile/knowledge.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_Journey.n3

#To compute the highest level workflow use:
eye workflow-composer/gps-plugin_modified.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/selectedSteps_Journey.n3 oslo-descriptions/change-address-steps.ttl --query journey/journeyGoal.n3 --nope > interim/all_journey-paths.n3

#To compute the highest level workflow without permutations use 
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/selectedSteps_Journey.n3 oslo-descriptions/change-address-steps.ttl --query journey/journeyGoal.n3 --nope > interim/journey-paths_noPermutations.n3

#################################################
# Container Level
###################################################

#for our preselection steps we need short descriptions
eye  interim/container-level-steps.n3 profile/knowledge.n3 --query preselection/pregeneration.n3 --nope > interim/shortContainerDescriptions.n3


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
eye choices/selected_Waste.n3 interim/journey-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/createdGoal_Waste.n3

#create a dummy step which creates the input data of the step (this is needed if we want to create sub-workflows for steps which rely on others).
eye choices/selected_Waste.n3 interim/journey-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope  > interim/extraRule_waste.n3
#todo: if this rule adds data, it should be visible in the output as one step

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_Waste.n3 interim/journey-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/block_waste.n3

#preselect 
eye interim/container-level-steps.n3 interim/shortContainerDescriptions.n3 interim/createdGoal_Waste.n3 preselection/preselection.n3 profile/knowledge.n3 interim/block_waste.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_waste.n3

#create path
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/extraRule_waste.n3 help-functions/aux2.n3 interim/selectedSteps_waste.n3 oslo-descriptions/change-address-steps.ttl --query interim/createdGoal_Waste.n3 --nope > interim/WasteContainer_noPermutation.n3



#
# Goal Request address change
#


# create goal based on step name
eye choices/selected_AddressSubmission.n3 interim/journey-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/createdGoal_address.n3

#create rule to add input info for the step
eye choices/selected_AddressSubmission.n3 interim/journey-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/extraRule_addresschange.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_AddressSubmission.n3 interim/journey-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/block_addresschange.n3

#preselect
eye interim/container-level-steps.n3 interim/shortContainerDescriptions.n3 interim/createdGoal_address.n3 preselection/preselection.n3 profile/knowledge.n3 interim/block_addresschange.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_addresschange.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/extraRule_addresschange.n3 help-functions/aux2.n3 interim/selectedSteps_addresschange.n3 oslo-descriptions/change-address-steps.ttl --query interim/createdGoal_address.n3 --nope > interim/ChangeAddress_noPermutation.n3


#####################################################
# Component level
##################################################
eye  interim/component-level-steps.n3 profile/knowledge.n3 --query preselection/pregeneration.n3 --nope >interim/shortComponentDescriptions.n3

#
# Green Waste
#

# create goal based on step name
eye choices/selected_GreenWaste.n3 interim/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/createdGoal_greenWaste.n3

# create rule to add input info for the step
eye choices/selected_GreenWaste.n3 interim/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/extraRule_greenWaste.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_GreenWaste.n3 interim/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/block_greenWaste.n3

#preselect
eye interim/component-level-steps.n3 interim/shortComponentDescriptions.n3 interim/createdGoal_greenWaste.n3 preselection/preselection.n3 profile/knowledge.n3  interim/block_greenWaste.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_greenWaste.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/extraRule_greenWaste.n3 help-functions/aux2.n3 interim/selectedSteps_greenWaste.n3 oslo-descriptions/change-address-steps.ttl --query interim/createdGoal_greenWaste.n3 --nope > interim/GreenWaste_noPermutation.n3

#
# Grey Waste
#

# create goal based on step name
eye choices/selected_GreyWaste.n3 interim/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/createdGoal_greyWaste.n3

# create rule to add input info for the step
eye choices/selected_GreyWaste.n3 interim/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/extraRule_greyWaste.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_GreyWaste.n3 interim/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/block_greyWaste.n3

#preselect
eye interim/component-level-steps.n3 interim/shortComponentDescriptions.n3 interim/createdGoal_greyWaste.n3 preselection/preselection.n3 profile/knowledge.n3  interim/block_greyWaste.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_greyWaste.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/extraRule_greyWaste.n3 help-functions/aux2.n3 interim/selectedSteps_greyWaste.n3 oslo-descriptions/change-address-steps.ttl --query interim/createdGoal_greyWaste.n3 --nope > interim/GreyWaste_noPermutation.n3



#
# Paper Waste
#

# create goal based on step name
eye choices/selected_PaperWaste.n3 interim/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/createdGoal_paperWaste.n3

# create rule to add input info for the step
eye choices/selected_PaperWaste.n3 interim/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/extraRule_paperWaste.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_PaperWaste.n3 interim/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/block_paperWaste.n3

#preselect
eye interim/component-level-steps.n3 interim/shortComponentDescriptions.n3 interim/createdGoal_paperWaste.n3 preselection/preselection.n3 profile/knowledge.n3  interim/block_paperWaste.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_paperWaste.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/extraRule_paperWaste.n3 help-functions/aux2.n3 interim/selectedSteps_paperWaste.n3 oslo-descriptions/change-address-steps.ttl --query interim/createdGoal_paperWaste.n3 --nope > interim/PaperWaste_noPermutation.n3


#
# Submit Waste Info
#

# create goal based on step name
eye choices/selected_SubmitWasteInfo.n3 interim/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/createdGoal_submitWasteInfo.n3

# create rule to add input info for the step
eye choices/selected_SubmitWasteInfo.n3 interim/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/extraRule_submitWasteInfo.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_SubmitWasteInfo.n3 interim/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/block_submitWasteInfo.n3

#preselect
eye interim/component-level-steps.n3 interim/shortComponentDescriptions.n3 interim/createdGoal_submitWasteInfo.n3 preselection/preselection.n3 profile/knowledge.n3  interim/block_submitWasteInfo.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_submitWasteInfo.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/extraRule_submitWasteInfo.n3 help-functions/aux2.n3 interim/selectedSteps_submitWasteInfo.n3 oslo-descriptions/change-address-steps.ttl --query interim/createdGoal_submitWasteInfo.n3 --nope > interim/SubmitWasteInfo_noPermutation.n3

    


# produce the data used
# todo
eye profile/knowledge.n3  profile/personalInfo.n3 interim/extraRule_submitWasteInfo.n3 help-functions/aux2.n3 --nope --query show/waste-info.n3 > interim/show-waste-Info.n3



# Todo add link to all info used

#
# Policevisit
#

# create goal based on step name
eye choices/selected_Policevisit.n3 interim/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/createdGoal_police.n3

# create rule to add input info for the step
eye choices/selected_Policevisit.n3 interim/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/extraRule_police.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_Policevisit.n3 interim/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/block_police.n3

#preselect
eye interim/component-level-steps.n3 interim/shortComponentDescriptions.n3 interim/createdGoal_police.n3 preselection/preselection.n3 profile/knowledge.n3  interim/block_police.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_policevisit.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/extraRule_police.n3 help-functions/aux2.n3 interim/selectedSteps_policevisit.n3 oslo-descriptions/change-address-steps.ttl --query interim/createdGoal_police.n3 --nope > interim/Policevisit_noPermutation.n3


#
# office visit to change id
#

# create goal based on step name
eye choices/selected_AddressChangeInOffice.n3 interim/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/createdGoal_addressChangeInOffice.n3

# create rule to add input info for the step
eye choices/selected_AddressChangeInOffice.n3 interim/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/extraRule_addressChangeInOffice.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_AddressChangeInOffice.n3 interim/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/block_addressChangeInOffice.n3

#preselect
eye interim/component-level-steps.n3 interim/shortComponentDescriptions.n3 interim/createdGoal_addressChangeInOffice.n3 preselection/preselection.n3 profile/knowledge.n3 interim/block_addressChangeInOffice.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_addressChangeInOffice.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/extraRule_addressChangeInOffice.n3 help-functions/aux2.n3 interim/selectedSteps_addressChangeInOffice.n3 oslo-descriptions/change-address-steps.ttl --query interim/createdGoal_addressChangeInOffice.n3 --nope > interim/addressChangeInOffice__noPermutation.n3



#################################3
#to be adjusted, here a container level is still missing (is that necessary?)

eye interim/component-level-steps.n3 interim/shortComponentDescriptions.n3 interim/goal_personalInformation.n3 preselection/preselection.n3 profile/knowledge.n3 --nope --query preselection/prequery.n3 >interim/selectedSteps_personalInfo.n3


#here, we get the output with all permutations, that is not really what we want, therefore that is commented out
#eye gps-plugin_modified.n3 knowledge.n3 PersonalInfoSelected.n3 NewSteps.n3 --query Goal_personalInformation.n3 --nope > personalInfo-paths.n3


# personalInfo
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/SelectedSteps_personalInfo.n3 oslo-descriptions/change-address-steps.ttl --query interim/goal_personalInformation.n3 --nope > interim/personalInfo_noPermutation.n3

#moving data
eye interim/component-level-steps.n3 interim/shortComponentDescriptions.n3 interim/Goal_provideMovingData.n3 preselection/preselection.n3 profile/knowledge.n3  profile/personalInfo.n3  --nope --query preselection/prequery.n3 >interim/selectedSteps_movingData.n3


eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/selectedSteps_movingData.n3 oslo-descriptions/change-address-steps.ttl --query interim/Goal_provideMovingData.n3 --nope > interim/movingData_noPermutation.n3

#########################################################
# create input form for each component step
#########################################################




#create a triple for the inpit you receive. Example: external-input/example.n3

#then run the following query
eye external-input/example.n3 help-functions/aux2.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/component-level-steps.n3 external-input/replaceValue.n3 --query external-input/CreateInputTriple.n3 --nope > interim/input_triples.n3


#alternative: use the query below and replace the values by the input values
eye help-functions/aux2.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/component-level-steps.n3 --query external-input/CreateInputPattern.n3 --nope > interim/input_patterns.n3



