#!/bin/sh

#first we produce the steps on each level based on the OSLO steps descriptions
eye oslo-descriptions/change-address-steps.ttl oslo-descriptions/change-address-states.ttl oslo-descriptions/change-address-shapes.ttl translation/step-reasoning.n3 translation/help.n3 translation/createPattern.n3 --query translation/mappingRuleCreationJourney.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >interim/steps/journey-level-steps.n3


eye oslo-descriptions/change-address-steps.ttl oslo-descriptions/change-address-states.ttl oslo-descriptions/change-address-shapes.ttl translation/step-reasoning.n3 translation/help.n3 translation/createPattern.n3 --query translation/mappingRuleCreationContainer.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >interim/steps/container-level-steps.n3

eye oslo-descriptions/change-address-steps.ttl oslo-descriptions/change-address-states.ttl oslo-descriptions/change-address-shapes.ttl translation/step-reasoning.n3 translation/help.n3 translation/createPattern.n3 --query translation/mappingRuleCreationComponent.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ >interim/steps/component-level-steps.n3


#################################################
# Journey Level
#################################################

# Preselection step based on the goal
eye  interim/steps/journey-level-steps.n3 profile/knowledge.n3  --query preselection/pregeneration.n3 --nope >interim/steps/shortJourneyDescriptions.n3


eye interim/steps/journey-level-steps.n3 interim/steps/shortJourneyDescriptions.n3 journey/journeyGoal.n3 preselection/preselection.n3 profile/knowledge.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_Journey.n3

#To compute the highest level workflow use:
eye workflow-composer/gps-plugin_modified.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/selectedSteps_Journey.n3 oslo-descriptions/change-address-steps.ttl --query journey/journeyGoal.n3 --nope > interim/paths/all_journey-paths.n3

#To compute the highest level workflow without permutations use 
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/selectedSteps_Journey.n3 oslo-descriptions/change-address-steps.ttl --query journey/journeyGoal.n3 --nope > interim/paths/journey-paths_noPermutations.n3

#################################################
# Container Level
###################################################

#for our preselection steps we need short descriptions
eye  interim/steps/container-level-steps.n3 profile/knowledge.n3 --query preselection/pregeneration.n3 --nope > interim/steps/shortContainerDescriptions.n3


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
eye choices/selected_Waste.n3 interim/steps/journey-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_Waste.n3

#create a dummy step which creates the input data of the step (this is needed if we want to create sub-workflows for steps which rely on others).
eye choices/selected_Waste.n3 interim/steps/journey-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope  > interim/subgoals/extraRule_waste.n3
#todo: if this rule adds data, it should be visible in the output as one step

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_Waste.n3 interim/steps/journey-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_waste.n3

#preselect 
eye interim/steps/container-level-steps.n3 interim/steps/shortContainerDescriptions.n3 interim/subgoals/createdGoal_Waste.n3 preselection/preselection.n3 profile/knowledge.n3 interim/subgoals/block_waste.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_waste.n3

#create path
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_waste.n3 help-functions/aux2.n3 interim/steps/selectedSteps_waste.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_Waste.n3 --nope > interim/paths/WasteContainer_noPermutation.n3



#
# Goal Request address change
#


# create goal based on step name
eye choices/selected_AddressSubmission.n3 interim/steps/journey-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_address.n3

#create rule to add input info for the step
eye choices/selected_AddressSubmission.n3 interim/steps/journey-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_addresschange.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_AddressSubmission.n3 interim/steps/journey-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_addresschange.n3

#preselect
eye interim/steps/container-level-steps.n3 interim/steps/shortContainerDescriptions.n3 interim/subgoals/createdGoal_address.n3 preselection/preselection.n3 profile/knowledge.n3 interim/subgoals/block_addresschange.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_addresschange.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_addresschange.n3 help-functions/aux2.n3 interim/steps/selectedSteps_addresschange.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_address.n3 --nope > interim/paths/ChangeAddress_noPermutation.n3


#####################################################
# Component level
##################################################
eye  interim/steps/component-level-steps.n3 profile/knowledge.n3 --query preselection/pregeneration.n3 --nope >interim/steps/shortComponentDescriptions.n3

#
# Green Waste
#

# create goal based on step name
eye choices/selected_GreenWaste.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_greenWaste.n3

# create rule to add input info for the step
eye choices/selected_GreenWaste.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_greenWaste.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_GreenWaste.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_greenWaste.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_greenWaste.n3 preselection/preselection.n3 profile/knowledge.n3  interim/subgoals/block_greenWaste.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_greenWaste.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_greenWaste.n3 help-functions/aux2.n3 interim/steps/selectedSteps_greenWaste.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_greenWaste.n3 --nope > interim/paths/GreenWaste_noPermutation.n3

#
# Grey Waste
#

# create goal based on step name
eye choices/selected_GreyWaste.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_greyWaste.n3

# create rule to add input info for the step
eye choices/selected_GreyWaste.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_greyWaste.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_GreyWaste.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_greyWaste.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_greyWaste.n3 preselection/preselection.n3 profile/knowledge.n3  interim/subgoals/block_greyWaste.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_greyWaste.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_greyWaste.n3 help-functions/aux2.n3 interim/steps/selectedSteps_greyWaste.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_greyWaste.n3 --nope > interim/steps/GreyWaste_noPermutation.n3



#
# Paper Waste
#

# create goal based on step name
eye choices/selected_PaperWaste.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_paperWaste.n3

# create rule to add input info for the step
eye choices/selected_PaperWaste.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_paperWaste.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_PaperWaste.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_paperWaste.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_paperWaste.n3 preselection/preselection.n3 profile/knowledge.n3  interim/subgoals/block_paperWaste.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_paperWaste.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_paperWaste.n3 help-functions/aux2.n3 interim/steps/selectedSteps_paperWaste.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_paperWaste.n3 --nope > interim/paths/PaperWaste_noPermutation.n3


#
# Submit Waste Info
#

# create goal based on step name
eye choices/selected_SubmitWasteInfo.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_submitWasteInfo.n3

# create rule to add input info for the step
eye choices/selected_SubmitWasteInfo.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_submitWasteInfo.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_SubmitWasteInfo.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_submitWasteInfo.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_submitWasteInfo.n3 preselection/preselection.n3 profile/knowledge.n3  interim/subgoals/block_submitWasteInfo.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_submitWasteInfo.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_submitWasteInfo.n3 help-functions/aux2.n3 interim/steps/selectedSteps_submitWasteInfo.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_submitWasteInfo.n3 --nope > interim/paths/SubmitWasteInfo_noPermutation.n3

    


# produce the data used
# todo
eye profile/knowledge.n3  profile/personalInfo.n3 interim/subgoals/extraRule_submitWasteInfo.n3 help-functions/aux2.n3 --nope --query show/waste-info.n3 > interim/paths/show-waste-Info.n3



# Todo add link to all info used

#
# Policevisit
#

# create goal based on step name
eye choices/selected_Policevisit.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_police.n3

# create rule to add input info for the step
eye choices/selected_Policevisit.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_police.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_Policevisit.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_police.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_police.n3 preselection/preselection.n3 profile/knowledge.n3  interim/subgoals/block_police.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_policevisit.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_police.n3 help-functions/aux2.n3 interim/steps/selectedSteps_policevisit.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_police.n3 --nope > interim/paths/Policevisit_noPermutation.n3


#
# office visit to change id
#

# create goal based on step name
eye choices/selected_AddressChangeInOffice.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_addressChangeInOffice.n3

# create rule to add input info for the step
eye choices/selected_AddressChangeInOffice.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_addressChangeInOffice.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_AddressChangeInOffice.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_addressChangeInOffice.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_addressChangeInOffice.n3 preselection/preselection.n3 profile/knowledge.n3 interim/subgoals/block_addressChangeInOffice.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_addressChangeInOffice.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_addressChangeInOffice.n3 help-functions/aux2.n3 interim/steps/selectedSteps_addressChangeInOffice.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_addressChangeInOffice.n3 --nope > interim/paths/addressChangeInOffice__noPermutation.n3



#################################3
#to be adjusted, here a container level is still missing (is that necessary?)

eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/goal_personalInformation.n3 preselection/preselection.n3 profile/knowledge.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_personalInfo.n3


#here, we get the output with all permutations, that is not really what we want, therefore that is commented out
#eye gps-plugin_modified.n3 knowledge.n3 PersonalInfoSelected.n3 NewSteps.n3 --query Goal_personalInformation.n3 --nope > personalInfo-paths.n3


# personalInfo
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/selectedSteps_personalInfo.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/goal_personalInformation.n3 --nope > interim/paths/personalInfo_noPermutation.n3

#moving data
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/Goal_provideMovingData.n3 preselection/preselection.n3 profile/knowledge.n3  profile/personalInfo.n3  --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_movingData.n3


eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/selectedSteps_movingData.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/Goal_provideMovingData.n3 --nope > interim/paths/movingData_noPermutation.n3

#########################################################
# create input for each component step
#########################################################




#create a triple for the inpit you receive. Example: external-input/example.n3

#then run the following query
eye external-input/example.n3 help-functions/aux2.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/component-level-steps.n3 external-input/replaceValue.n3 --query external-input/CreateInputTriple.n3 --nope > interim/input/input_triples.n3

#this is just a test
eye external-input/example2.n3 interim/input/input_triples.n3 help-functions/aux2.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/component-level-steps.n3 external-input/replaceValue.n3 --query external-input/CreateInputTriple.n3 --nope > interim/input/input_triples2.n3


#alternative: use the query below and replace the values by the input values
eye help-functions/aux2.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/component-level-steps.n3 --query external-input/CreateInputPattern.n3 --nope > interim/input/input_patterns.n3




