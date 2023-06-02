#!/bin/sh

#alias eye='docker run --rm -v $(pwd):/$(pwd) bdevloed/eye' #Linux
alias eye='docker run --rm -v "$(pwd)":"$(pwd)" -w "$(pwd)" --net=host -i bdevloed/eye'
# alias eye='docker run --rm -v "/c/Users/bjdmeest/Ben/Work/iMinds/Projects/2019 09 SEMIC - CGI/git/n3-mapping-rules/demo:/tmp" bdevloed/eye' #windows powershell

#first we produce the steps on each level based on the OSLO steps descriptions
eye demo/oslo-descriptions/change-address-steps.ttl demo/oslo-descriptions/change-address-states.ttl demo/oslo-descriptions/change-address-shapes.ttl demo/translation/step-reasoning.n3 demo/translation/help.n3 demo/translation/createPattern.n3 --query demo/translation/mappingRuleCreationJourney.n3 --nope --quantify http://josd.github.io/.well-known/genid/ >demo/interim/steps/journey-level-steps.n3


eye demo/oslo-descriptions/change-address-steps.ttl demo/oslo-descriptions/change-address-states.ttl demo/oslo-descriptions/change-address-shapes.ttl demo/translation/step-reasoning.n3 demo/translation/help.n3 demo/translation/createPattern.n3 --query demo/translation/mappingRuleCreationContainer.n3 --nope --quantify http://josd.github.io/.well-known/genid/ >demo/interim/steps/container-level-steps.n3

eye demo/oslo-descriptions/change-address-steps.ttl demo/oslo-descriptions/change-address-states.ttl demo/oslo-descriptions/change-address-shapes.ttl demo/translation/step-reasoning.n3 demo/translation/help.n3 demo/translation/createPattern.n3 --query demo/translation/mappingRuleCreationComponent.n3 --nope --quantify http://josd.github.io/.well-known/genid/ >demo/interim/steps/component-level-steps.n3


#################################################
# Journey Level
#################################################

# Preselection step based on the goal
eye  demo/interim/steps/journey-level-steps.n3 demo/profile/knowledge.n3  --query demo/preselection/pregeneration.n3 --nope >demo/interim/steps/shortJourneyDescriptions.n3


eye demo/interim/steps/journey-level-steps.n3 demo/interim/steps/shortJourneyDescriptions.n3 demo/journey/journeyGoal.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_Journey.n3

#To compute the highest level workflow use:
eye demo/workflow-composer/gps-plugin_modified.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/steps/selectedSteps_Journey.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/journey/journeyGoal.n3 --nope > demo/interim/paths/all_journey-paths.n3

#To compute the highest level workflow without permutations use 
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/steps/selectedSteps_Journey.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/journey/journeyGoal.n3 --nope > demo/interim/paths/journey-paths_noPermutations.n3

#extra test case (earlier that cause performance problems):
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/testData/personalInfo_testCase.n3  demo/interim/steps/selectedSteps_Journey.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/journey/journeyGoal.n3 --nope > demo/testData/journey-paths_noPermutations.n3

#################################################
# Container Level
###################################################

#for our preselection steps we need short descriptions
eye  demo/interim/steps/container-level-steps.n3 demo/profile/knowledge.n3 --query demo/preselection/pregeneration.n3 --nope > demo/interim/steps/shortContainerDescriptions.n3


#
# Goal1: address change
#
#

# we use backwards reasoning to see which steps can lead to the goal (this step does not need to be repeated whenever we use the goal, only if either the steps or the goal changes).
#eye  container-level-steps.n3 knowledge.n3 --query demo/preselection/pregeneration.n3 --nope >shortContainerDescriptions.n3
#eye container-level-steps.n3 shortContainerDescriptions.n3 containerGoal_addressChange.n3 demo/preselection/preselection.n3 knowledge.n3 --nope --query demo/preselection/prequery.n3 >AddressChangeSelected.n3




#eye gps-plugin_modified_noPermutations.n3 knowledge.n3 AddressChangeSelected.n3 change-address-steps.ttl --query containerGoal_addressChange.n3 --nope > container-address-paths.n3

#
# Goal Personal Info
#

# create goal based on step name
eye demo/choices/selected_PersonalInfo.n3 demo/interim/steps/journey-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_PersonalInfo.n3

#create a dummy step which creates the input data of the step (this is needed if we want to create sub-workflows for steps which rely on others).
eye demo/choices/selected_PersonalInfo.n3 demo/interim/steps/journey-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope  > demo/interim/subgoals/extraRule_personalInfo.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_PersonalInfo.n3 demo/interim/steps/journey-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_personalInfo.n3

#preselect 
eye demo/interim/steps/container-level-steps.n3 demo/interim/steps/shortContainerDescriptions.n3 demo/interim/subgoals/createdGoal_PersonalInfo.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 demo/interim/subgoals/block_personalInfo.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_personalInfo.n3

#create path
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_personalInfo.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_personalInfo.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_PersonalInfo.n3 --nope > demo/interim/paths/PersonalInfo_noPermutation.n3


#
# Goal Waste collection
#

# create goal based on step name
eye demo/choices/selected_Waste.n3 demo/interim/steps/journey-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_Waste.n3

#create a dummy step which creates the input data of the step (this is needed if we want to create sub-workflows for steps which rely on others).
eye demo/choices/selected_Waste.n3 demo/interim/steps/journey-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope  > demo/interim/subgoals/extraRule_waste.n3
#todo: if this rule adds data, it should be visible in the output as one step

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_Waste.n3 demo/interim/steps/journey-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_waste.n3

#preselect 
eye demo/interim/steps/container-level-steps.n3 demo/interim/steps/shortContainerDescriptions.n3 demo/interim/subgoals/createdGoal_Waste.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 demo/interim/subgoals/block_waste.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_waste.n3

#create path
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_waste.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_waste.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_Waste.n3 --nope > demo/interim/paths/WasteContainer_noPermutation.n3



#
# Goal Request address change
#


# create goal based on step name
eye demo/choices/selected_AddressSubmission.n3 demo/interim/steps/journey-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_address.n3

#create rule to add input info for the step
eye demo/choices/selected_AddressSubmission.n3 demo/interim/steps/journey-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_addresschange.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_AddressSubmission.n3 demo/interim/steps/journey-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_addresschange.n3

#preselect
eye demo/interim/steps/container-level-steps.n3 demo/interim/steps/shortContainerDescriptions.n3 demo/interim/subgoals/createdGoal_address.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 demo/interim/subgoals/block_addresschange.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_addresschange.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_addresschange.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_addresschange.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_address.n3 --nope > demo/interim/paths/ChangeAddress_noPermutation.n3




#####################################################
# Component level
##################################################
eye  demo/interim/steps/component-level-steps.n3 demo/profile/knowledge.n3 --query demo/preselection/pregeneration.n3 --nope >demo/interim/steps/shortComponentDescriptions.n3

#
# Green Waste
#

# create goal based on step name
eye demo/choices/selected_GreenWaste.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_greenWaste.n3

# create rule to add input info for the step
eye demo/choices/selected_GreenWaste.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_greenWaste.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_GreenWaste.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_greenWaste.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_greenWaste.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3  demo/interim/subgoals/block_greenWaste.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_greenWaste.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_greenWaste.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_greenWaste.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_greenWaste.n3 --nope > demo/interim/paths/GreenWaste_noPermutation.n3

#
# Grey Waste
#

# create goal based on step name
eye demo/choices/selected_GreyWaste.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_greyWaste.n3

# create rule to add input info for the step
eye demo/choices/selected_GreyWaste.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_greyWaste.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_GreyWaste.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_greyWaste.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_greyWaste.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3  demo/interim/subgoals/block_greyWaste.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_greyWaste.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_greyWaste.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_greyWaste.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_greyWaste.n3 --nope > demo/interim/steps/GreyWaste_noPermutation.n3



#
# Paper Waste
#

# create goal based on step name
eye demo/choices/selected_PaperWaste.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_paperWaste.n3

# create rule to add input info for the step
eye demo/choices/selected_PaperWaste.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_paperWaste.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_PaperWaste.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_paperWaste.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_paperWaste.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3  demo/interim/subgoals/block_paperWaste.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_paperWaste.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_paperWaste.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_paperWaste.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_paperWaste.n3 --nope > demo/interim/paths/PaperWaste_noPermutation.n3


#
# Submit Waste Info
#

# create goal based on step name
eye demo/choices/selected_SubmitWasteInfo.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_submitWasteInfo.n3

# create rule to add input info for the step
eye demo/choices/selected_SubmitWasteInfo.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_submitWasteInfo.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_SubmitWasteInfo.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_submitWasteInfo.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_submitWasteInfo.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3  demo/interim/subgoals/block_submitWasteInfo.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_submitWasteInfo.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_submitWasteInfo.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_submitWasteInfo.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_submitWasteInfo.n3 --nope > demo/interim/paths/SubmitWasteInfo_noPermutation.n3


   
# Todo add link to all info used

#
# Policevisit
#

# create goal based on step name
eye demo/choices/selected_Policevisit.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_police.n3

# create rule to add input info for the step
eye demo/choices/selected_Policevisit.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_police.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_Policevisit.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_police.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_police.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3  demo/interim/subgoals/block_police.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_policevisit.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_police.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_policevisit.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_police.n3 --nope > demo/interim/paths/Policevisit_noPermutation.n3


#
# office visit to change id
#

# create goal based on step name
eye demo/choices/selected_AddressChangeInOffice.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_addressChangeInOffice.n3

# create rule to add input info for the step
eye demo/choices/selected_AddressChangeInOffice.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_addressChangeInOffice.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_AddressChangeInOffice.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_addressChangeInOffice.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_addressChangeInOffice.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 demo/interim/subgoals/block_addressChangeInOffice.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_addressChangeInOffice.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_addressChangeInOffice.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_addressChangeInOffice.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_addressChangeInOffice.n3 --nope > demo/interim/paths/AddressChangeInOffice_noPermutation.n3



#
# citizen name
#

# create goal based on step name
eye demo/choices/selected_CitizenName.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_citizenName.n3

# create rule to add input info for the step
eye demo/choices/selected_CitizenName.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_citizenName.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_CitizenName.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_citizenName.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_citizenName.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 demo/interim/subgoals/block_citizenName.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_citizenName.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_citizenName.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_citizenName.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_citizenName.n3 --nope > demo/interim/paths/CitizenName_noPermutation.n3

#
# contact data
#

# create goal based on step name
eye demo/choices/selected_ContactData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_contactData.n3

# create rule to add input info for the step
eye demo/choices/selected_ContactData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_contactData.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_ContactData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_contactData.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_contactData.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 demo/interim/subgoals/block_contactData.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_contactData.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_contactData.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_contactData.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_contactData.n3 --nope > demo/interim/paths/ContactData_noPermutation.n3

#
# birth data
#

# create goal based on step name
eye demo/choices/selected_BirthData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_birthData.n3

# create rule to add input info for the step
eye demo/choices/selected_BirthData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_birthData.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_BirthData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_birthData.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_birthData.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 demo/interim/subgoals/block_birthData.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_birthData.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_birthData.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_birthData.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_birthData.n3 --nope > demo/interim/paths/BirthData_noPermutation.n3

#
# additional data
#

# create goal based on step name
eye demo/choices/selected_AdditionalData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_additionalData.n3

# create rule to add input info for the step
eye demo/choices/selected_AdditionalData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_additionalData.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_AdditionalData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_additionalData.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_additionalData.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 demo/interim/subgoals/block_additionalData.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_additionalData.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_additionalData.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_additionalData.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_additionalData.n3 --nope > demo/interim/paths/AdditionalData_noPermutation.n3

#
# moving data -> note: for moving data we did not create a container level path
#

# create goal based on step name
eye demo/choices/selected_MovingData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/subgoalCreation.n3 --nope --quantify http://josd.github.io/.well-known/genid/ > demo/interim/subgoals/createdGoal_movingData.n3

# create rule to add input info for the step
eye demo/choices/selected_MovingData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfRuleForMissingData.n3 --nope >demo/interim/subgoals/extraRule_movingData.n3

# mark the triples which can be created by the extra rule to block them for step selection
eye demo/choices/selected_MovingData.n3 demo/interim/steps/container-level-steps.n3 --query demo/subgoals/creationOfBlockingInfo.n3 --nope >demo/interim/subgoals/block_movingData.n3

#preselect
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/shortComponentDescriptions.n3 demo/interim/subgoals/createdGoal_movingData.n3 demo/preselection/preselection.n3 demo/profile/knowledge.n3 demo/interim/subgoals/block_movingData.n3 --nope --query demo/preselection/prequery.n3 >demo/interim/steps/selectedSteps_movingData.n3

#createPath
eye demo/workflow-composer/gps-plugin_modified_noPermutations.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/subgoals/extraRule_movingData.n3 demo/help-functions/aux2.n3 demo/interim/steps/selectedSteps_movingData.n3 demo/oslo-descriptions/change-address-steps.ttl --query demo/interim/subgoals/createdGoal_movingData.n3 --nope > demo/interim/paths/MovingData_noPermutation.n3


#########################################################
# create input for each component step
#########################################################

#create a triple for the input you receive. Example: demo/external-input//example.n3

#then run the following query
eye demo/external-input//example.n3 demo/help-functions/aux2.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/steps/component-level-steps.n3 demo/external-input//replaceValue.n3 --query demo/external-input//CreateInputTriple.n3 --nope > demo/interim/input/input_triples.n3


#this is just a test
eye demo/external-input//example2.n3 demo/interim/input/input_triples.n3 demo/help-functions/aux2.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/steps/component-level-steps.n3 demo/external-input//replaceValue.n3 --query demo/external-input//CreateInputTriple.n3 --nope > demo/interim/input/input_triples2.n3


#alternative: use the query below and replace the values by the input values
eye demo/help-functions/aux2.n3 demo/profile/knowledge.n3  demo/profile/personalInfo.n3  demo/interim/steps/component-level-steps.n3 --query demo/external-input//CreateInputPattern.n3 --nope > demo/interim/input/input_patterns.n3

#create input patterns for states
#eye demo/profile/knowledge.n3  demo/profile/personalInfo.n3 demo/help-functions/aux2.n3  demo/oslo-descriptions/change-address-states.ttl demo/oslo-descriptions/change-address-shapes.ttl demo/translation/help.n3 demo/translation/createPattern.n3 --query demo/translation/statePatternCreation.n3 --nope  > out.n3
#I am still working on this

###############################
# Produce the info used by a step
###############################

# create Input Patterns for all steps
eye demo/interim/steps/component-level-steps.n3 demo/interim/steps/container-level-steps.n3 demo/interim/steps/journey-level-steps.n3 demo/interim/steps/shortJourneyDescriptions.n3 demo/help-functions/built-ins.n3  --nope --query demo/show/query_generation.n3 > demo/interim/show/query-patterns.n3 

#Example show waste info

# we need a file in which the request is stated. Here we have: demo/show/Request_showInfoUsed_wasteCollection.n3

#Using that file, we can make a query
eye demo/profile/knowledge.n3  demo/profile/personalInfo.n3 demo/show/getInfo.n3 demo/interim/show/query-patterns.n3 demo/interim/steps/component-level-steps.n3 demo/interim/steps/container-level-steps.n3 demo/interim/steps/journey-level-steps.n3 demo/show/Request_showInfoUsed_wasteCollection.n3 --query demo/show/query_used.n3 demo/help-functions/built-ins.n3 --nope > demo/interim/show/show-waste-Info.n3

# a test with complete input data (just to be sure that works)
eye demo/profile/knowledge.n3  demo/profile/personalInfo.n3 demo/show/getInfo.n3 demo/interim/show/query-patterns.n3 demo/interim/steps/component-level-steps.n3 demo/interim/steps/container-level-steps.n3 demo/interim/steps/journey-level-steps.n3 demo/show/test_show-waste-Info.n3 demo/show/Request_showInfoUsed_wasteCollection.n3 demo/help-functions/built-ins.n3 --query demo/show/query_used.n3 --nope > demo/interim/show/show-waste-Info.n3

#Example: last name
eye demo/profile/knowledge.n3  demo/profile/personalInfo.n3 demo/show/getInfo.n3 demo/interim/show/query-patterns.n3 demo/interim/steps/component-level-steps.n3 demo/interim/steps/container-level-steps.n3 demo/interim/steps/journey-level-steps.n3 demo/show/Request_showInfoUsed_lastName.n3 demo/help-functions/built-ins.n3  --query demo/show/query_used.n3 --nope > demo/interim/show/show-lastName-Info.n3

# Example: address info
eye demo/profile/knowledge.n3  demo/profile/personalInfo.n3 demo/show/getInfo.n3 demo/interim/show/query-patterns.n3 demo/interim/steps/component-level-steps.n3 demo/interim/steps/container-level-steps.n3 demo/interim/steps/journey-level-steps.n3 demo/show/test_show-waste-Info.n3 demo/show/Request_showInfoUsed_changeAddress.n3 demo/help-functions/built-ins.n3 --query demo/show/query_used.n3 --nope > demo/interim/show/show-address-Info.n3




# File: demo/show/Request_showInfoUsed_changeAddress.n3
# Query:
#eye demo/profile/knowledge.n3  demo/profile/personalInfo.n3 demo/show/getInfo.n3 demo/interim/steps/journey-level-steps.n3 demo/show/Request_showInfoUsed_changeAddress.n3 --query demo/show/query_InfoUsed.n3 --nope > demo/interim/show/show-address-Info.n3

#eye demo/profile/knowledge.n3  demo/profile/personalInfo.n3 demo/show/getInput.n3 demo/interim/steps/journey-level-steps.n3 demo/show/Request_showInfoUsed_changeAddress.n3 demo/interim/steps/shortJourneyDescriptions.n3 --query demo/show/query_Info.n3 --nope > demo/interim/show/show-address-Info.n3

#currently the latter has serious performance issues

# Todo: test everything with phone info and/or cell phone (complicated pattern)
