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

#extra test case (earlier that cause performance problems):
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  testData/personalInfo_testCase.n3  interim/steps/selectedSteps_Journey.n3 oslo-descriptions/change-address-steps.ttl --query journey/journeyGoal.n3 --nope > testData/journey-paths_noPermutations.n3

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
# Goal Personal Info
#

# create goal based on step name
eye choices/selected_PersonalInfo.n3 interim/steps/journey-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_PersonalInfo.n3

#create a dummy step which creates the input data of the step (this is needed if we want to create sub-workflows for steps which rely on others).
eye choices/selected_PersonalInfo.n3 interim/steps/journey-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope  > interim/subgoals/extraRule_personalInfo.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_PersonalInfo.n3 interim/steps/journey-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_personalInfo.n3

#preselect 
eye interim/steps/container-level-steps.n3 interim/steps/shortContainerDescriptions.n3 interim/subgoals/createdGoal_PersonalInfo.n3 preselection/preselection.n3 profile/knowledge.n3 interim/subgoals/block_personalInfo.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_personalInfo.n3

#create path
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_personalInfo.n3 help-functions/aux2.n3 interim/steps/selectedSteps_personalInfo.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_PersonalInfo.n3 --nope > interim/paths/PersonalInfo_noPermutation.n3


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
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_addressChangeInOffice.n3 help-functions/aux2.n3 interim/steps/selectedSteps_addressChangeInOffice.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_addressChangeInOffice.n3 --nope > interim/paths/AddressChangeInOffice_noPermutation.n3



#
# citizen name
#

# create goal based on step name
eye choices/selected_CitizenName.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_citizenName.n3

# create rule to add input info for the step
eye choices/selected_CitizenName.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_citizenName.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_CitizenName.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_citizenName.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_citizenName.n3 preselection/preselection.n3 profile/knowledge.n3 interim/subgoals/block_citizenName.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_citizenName.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_citizenName.n3 help-functions/aux2.n3 interim/steps/selectedSteps_citizenName.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_citizenName.n3 --nope > interim/paths/CitizenName_noPermutation.n3

#
# contact data
#

# create goal based on step name
eye choices/selected_ContactData.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_contactData.n3

# create rule to add input info for the step
eye choices/selected_ContactData.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_contactData.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_ContactData.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_contactData.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_contactData.n3 preselection/preselection.n3 profile/knowledge.n3 interim/subgoals/block_contactData.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_contactData.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_contactData.n3 help-functions/aux2.n3 interim/steps/selectedSteps_contactData.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_contactData.n3 --nope > interim/paths/ContactData_noPermutation.n3

#
# birth data
#

# create goal based on step name
eye choices/selected_BirthData.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_birthData.n3

# create rule to add input info for the step
eye choices/selected_BirthData.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_birthData.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_BirthData.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_birthData.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_birthData.n3 preselection/preselection.n3 profile/knowledge.n3 interim/subgoals/block_birthData.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_birthData.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_birthData.n3 help-functions/aux2.n3 interim/steps/selectedSteps_birthData.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_birthData.n3 --nope > interim/paths/BirthData_noPermutation.n3

#
# additional data
#

# create goal based on step name
eye choices/selected_AdditionalData.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_additionalData.n3

# create rule to add input info for the step
eye choices/selected_AdditionalData.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_additionalData.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_AdditionalData.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_additionalData.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_additionalData.n3 preselection/preselection.n3 profile/knowledge.n3 interim/subgoals/block_additionalData.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_additionalData.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_additionalData.n3 help-functions/aux2.n3 interim/steps/selectedSteps_additionalData.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_additionalData.n3 --nope > interim/paths/AdditionalData_noPermutation.n3

#
# moving data -> note: for moving data we did not create a container level path
#

# create goal based on step name
eye choices/selected_MovingData.n3 interim/steps/container-level-steps.n3 --query subgoals/subgoalCreation.n3 --nope --no-skolem http://josd.github.io/.well-known/genid/ > interim/subgoals/createdGoal_movingData.n3

# create rule to add input info for the step
eye choices/selected_MovingData.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfRuleForMissingData.n3 --nope >interim/subgoals/extraRule_movingData.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye choices/selected_MovingData.n3 interim/steps/container-level-steps.n3 --query subgoals/creationOfBlockingInfo.n3 --nope >interim/subgoals/block_movingData.n3

#preselect
eye interim/steps/component-level-steps.n3 interim/steps/shortComponentDescriptions.n3 interim/subgoals/createdGoal_movingData.n3 preselection/preselection.n3 profile/knowledge.n3 interim/subgoals/block_movingData.n3 --nope --query preselection/prequery.n3 >interim/steps/selectedSteps_movingData.n3

#createPath
eye workflow-composer/gps-plugin_modified_noPermutations.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/subgoals/extraRule_movingData.n3 help-functions/aux2.n3 interim/steps/selectedSteps_movingData.n3 oslo-descriptions/change-address-steps.ttl --query interim/subgoals/createdGoal_movingData.n3 --nope > interim/paths/MovingData_noPermutation.n3


#########################################################
# create input for each component step
#########################################################

#create a triple for the input you receive. Example: external-input/example.n3

#then run the following query
eye external-input/example.n3 help-functions/aux2.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/component-level-steps.n3 external-input/replaceValue.n3 --query external-input/CreateInputTriple.n3 --nope > interim/input/input_triples.n3


#this is just a test
eye external-input/example2.n3 interim/input/input_triples.n3 help-functions/aux2.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/component-level-steps.n3 external-input/replaceValue.n3 --query external-input/CreateInputTriple.n3 --nope > interim/input/input_triples2.n3


#alternative: use the query below and replace the values by the input values
eye help-functions/aux2.n3 profile/knowledge.n3  profile/personalInfo.n3  interim/steps/component-level-steps.n3 --query external-input/CreateInputPattern.n3 --nope > interim/input/input_patterns.n3

#create input patterns for states
#eye profile/knowledge.n3  profile/personalInfo.n3 help-functions/aux2.n3  oslo-descriptions/change-address-states.ttl oslo-descriptions/change-address-shapes.ttl translation/help.n3 translation/createPattern.n3 --query translation/statePatternCreation.n3 --nope  > out.n3
#I am still working on this

###############################
# Produce the info used by a step
###############################

# create Input Patterns for all steps
eye interim/steps/component-level-steps.n3 interim/steps/container-level-steps.n3 interim/steps/journey-level-steps.n3 interim/steps/shortJourneyDescriptions.n3 help-functions/built-ins.n3  --nope --query show/query_generation.n3 > interim/show/query-patterns.n3 

#Example show waste info

# we need a file in which the request is stated. Here we have: show/Request_showInfoUsed_wasteCollection.n3

#Using that file, we can make a query
eye profile/knowledge.n3  profile/personalInfo.n3 show/getInfo.n3 interim/show/query-patterns.n3 interim/steps/component-level-steps.n3 interim/steps/container-level-steps.n3 interim/steps/journey-level-steps.n3 show/Request_showInfoUsed_wasteCollection.n3 --query show/query_used.n3 help-functions/built-ins.n3 --nope > interim/show/show-waste-Info.n3

# a test with complete input data (just to be sure that works)
eye profile/knowledge.n3  profile/personalInfo.n3 show/getInfo.n3 interim/show/query-patterns.n3 interim/steps/component-level-steps.n3 interim/steps/container-level-steps.n3 interim/steps/journey-level-steps.n3 show/test_show-waste-Info.n3 show/Request_showInfoUsed_wasteCollection.n3 help-functions/built-ins.n3 --query show/query_used.n3 --nope > interim/show/show-waste-Info.n3

#Example: last name
eye profile/knowledge.n3  profile/personalInfo.n3 show/getInfo.n3 interim/show/query-patterns.n3 interim/steps/component-level-steps.n3 interim/steps/container-level-steps.n3 interim/steps/journey-level-steps.n3 show/Request_showInfoUsed_lastName.n3 help-functions/built-ins.n3  --query show/query_used.n3 --nope > interim/show/show-lastName-Info.n3

# Example: address info
eye profile/knowledge.n3  profile/personalInfo.n3 show/getInfo.n3 interim/show/query-patterns.n3 interim/steps/component-level-steps.n3 interim/steps/container-level-steps.n3 interim/steps/journey-level-steps.n3 show/test_show-waste-Info.n3 show/Request_showInfoUsed_changeAddress.n3 help-functions/built-ins.n3 --query show/query_used.n3 --nope > interim/show/show-address-Info.n3




# File: show/Request_showInfoUsed_changeAddress.n3
# Query:
#eye profile/knowledge.n3  profile/personalInfo.n3 show/getInfo.n3 interim/steps/journey-level-steps.n3 show/Request_showInfoUsed_changeAddress.n3 --query show/query_InfoUsed.n3 --nope > interim/show/show-address-Info.n3

#eye profile/knowledge.n3  profile/personalInfo.n3 show/getInput.n3 interim/steps/journey-level-steps.n3 show/Request_showInfoUsed_changeAddress.n3 interim/steps/shortJourneyDescriptions.n3 --query show/query_Info.n3 --nope > interim/show/show-address-Info.n3

#currently the latter has serious performance issues

# Todo: test everything with phone info and/or cell phone (complicated pattern)
