const path = require('path');
const fs = require('fs/promises');
const eyePromise = require('./services/reasoning.js').eyePromise;
const $rdf = require('rdflib');
const { Namespace } = $rdf;
const ttl_read = require('@graphy/content.ttl.read');
const streams = require("@util.js/node-streams");

const basePath = path.resolve(__dirname, '..');
const cache = {};
const DEV_ENV = false;

main();

async function main() {
    const label = 'example1';
    const index = {
        "@context": {
            "@vocab": "http://www.example.org#"
        },
        "features": {}
    };
    const config = {
        label,
        oslo: {
            shapes: `scenarios/${label}/shapes.ttl`,
            states: `scenarios/${label}/states.ttl`,
            steps: `scenarios/${label}/steps.ttl`,
        },
        goalStates: ["http://localhost:8000/states#newEidPincodeRequested"],
    };
    await validateTtl(config.oslo.shapes);
    await validateTtl(config.oslo.states);
    await validateTtl(config.oslo.steps);
    console.log('all oslo files are valid TTL.');
    // const config = {
    //     label: "moving",
    //     oslo: {
    //         steps: "scenarios/_endevent_demo/change-address-steps.ttl",
    //         states: "scenarios/_endevent_demo/change-address-states.ttl",
    //         shapes: "scenarios/_endevent_demo/change-address-shapes.ttl",
    //     },
    //     goal: "?x <https://example.org/ns/example#wasteCollectionRequested> true ; <https://example.org/ns/example#addressChanged> true .",
    // };

    try {
        await fs.mkdir(path.resolve(basePath, '_output/'));
    } catch (e) {
        // OK already exists
    }
    try {
        await fs.mkdir(path.resolve(basePath, '_output/', config.label));
    } catch (e) {
        // OK already exists
    }
    const baseFolder = `_output/${config.label}`;
    const personalInfoPath = baseFolder + '/profile.ttl';
    config.baseFolder = baseFolder;
    config.personalInfo = personalInfoPath;
    await fs.writeFile(path.resolve(basePath, personalInfoPath), '<https://example.org/ns/example#user> a <https://data.vlaanderen.be/ns/persoon#Inwoner> .', 'utf8');

    // 0️⃣
    const journeyStepsPath = await reasonJourneyLevelSteps([config.oslo.steps, config.oslo.states, config.oslo.shapes], baseFolder);

    // 1️⃣
    // here we don't need block and extraRule
    const goalPath = await reasonJourneyGoal([config.oslo.steps, config.oslo.states, config.oslo.shapes], config.goalStates, config.baseFolder);
    const journeyDescriptionsPath = await reasonShortStepDescriptions([journeyStepsPath], baseFolder, `journey`);

    // 2️⃣
    // same as for other, but without block
    const journeySelectedStepsPath = await reasonSelectedSteps([journeyStepsPath, journeyDescriptionsPath, goalPath], config.baseFolder, `journey`, 'journey')
    index.features['journey_moving'] = {
        description: "journey moving",
        inference: {
            data: [
                journeySelectedStepsPath,
                config.oslo.steps,
                config.personalInfo,
                "rules/workflow-composer/gps-plugin_modified_noPermutations.n3",
                "scenarios/knowledge.n3",
            ],
            query: goalPath
        }
    }

    // 3️⃣
    // not same as reasonPaths: this one doesn't include util/graph.n3
    const journeyPathsPath = await reasonJourney([journeySelectedStepsPath, config.oslo.steps, config.personalInfo], goalPath, config.baseFolder);

    const allJourneyLevelSteps = await parsePaths(journeyPathsPath);
    console.log(allJourneyLevelSteps.join(', '));
    for (const journeyLevelStep of allJourneyLevelSteps) {
        // 0️⃣
        const containerStepsPath = await reasonContainerLevelSteps([config.oslo.steps, config.oslo.states, config.oslo.shapes], config.baseFolder);
        const containerDescriptionsPath = await reasonShortStepDescriptions([containerStepsPath], baseFolder, `container`);
        // 3️⃣
        const containerPathsPath = await reasonStep(journeyLevelStep, containerStepsPath, containerDescriptionsPath, journeyStepsPath, config, 'containers', index);
        const allContainerLevelSteps = await parsePaths(containerPathsPath);
        console.log(`for journeyLevelStep ${journeyLevelStep}, we find following containerLevelSteps: ${allContainerLevelSteps.join(', ')}`);
        for (const containerLevelStep of allContainerLevelSteps) {
            // 0️⃣
            const componentStepsPath = await reasonComponentLevelSteps([config.oslo.steps, config.oslo.states, config.oslo.shapes], config.baseFolder);
            const componentDescriptionsPath = await reasonShortStepDescriptions([componentStepsPath], baseFolder, `component`);
            // 3️⃣
            const componentPathsPath = await reasonStep(containerLevelStep, componentStepsPath, componentDescriptionsPath, containerStepsPath, config, 'components', index);
            const allComponentLevelSteps = await parsePaths(componentPathsPath);
            console.log(`for containerLevelStep ${containerLevelStep}, we find following componentLevelSteps: ${allComponentLevelSteps.join(', ')}`);
        }
    }
    await fs.writeFile(path.resolve(basePath, config.baseFolder, 'index.json'), JSON.stringify(index, null, '  '));

    /**
     * 3️⃣ Journey moving
     * - gps-plugin_modified_noPermutations -> ENGINE
     * - knowledge -> ENGINE
     * - selectedSteps_Journey -> INTERIM
     * - oslo-steps/steps -> CONFIG
     * - personalInfo -> RUNTIME
     * - Q journeyGoal -> GENERATED FOR JOURNEY FROM CONFIG
     */

    /**
     * 2️⃣ selectedSteps_Journey
     * - journey-level-steps -> INTERIM
     * - shortJourneyDescriptions -> INTERIM
     * - journeyGoal -> GENERATED FOR JOURNEY FROM CONFIG
     * - preselection -> ENGINE
     * - knowledge -> ENGINE
     * - query_preselection -> ENGINE
     */

    /**
     * 1️⃣ shortJourneyDescriptions
     * - journey-level-steps -> INTERIM
     * - knowledge -> ENGINE
     * - Q pregeneration -> ENGINE
     */

    /**
     * 0️⃣ journey-level-steps
     * - oslo-steps/steps -> CONFIG
     * - oslo-steps/states -> CONFIG
     * - oslo-steps/shapes -> CONFIG
     * - step-reasoning -> ENGINE
     * - help -> ENGINE
     * - createPattern -> ENGINE
     * - query_journeyStepToGPSDescription -> ENGINE
     */

    /**
     * ---------- PER JOURNEY
     */

    /**
     * 3️⃣ container_providePersonalInformation
     * - gps-plugin_modified_noPermutations -> ENGINE
     * - knowledge -> ENGINE
     * - selectedSteps_personalInfo -> INTERIM
     * - oslo-steps/steps -> CONFIG
     * - personalInfo -> RUNTIME
     * - extraRule_personalInfo -> INTERIM
     * - util/graph -> ENGINE
     * - Q createdGoal_PersonalInfo -> INTERIM
     */

    /**
     * 1️⃣ extraRule_personalInfo
     * - selected_PersonalInfo -> GENERATED FOR CONTAINER
     * - journey-level-steps -> INTERIM
     * - query_creationOfRuleForMissingData -> ENGINE
     */

    /**
     * 2️⃣ selectedSteps_personalInfo
     * - container-level-steps -> INTERIM
     * - shortContainerDescriptions -> INTERIM
     * - createdGoal_PersonalInfo -> INTERIM
     * - preselection -> ENGINE
     * - knowledge -> ENGINE
     * - block_personalInfo -> INTERIM
     * - query_preselection -> ENGINE
     */

    /**
     * 1️⃣ createdGoal_PersonalInfo
     * - selected_PersonalInfo -> GENERATED FOR CONTAINER
     * - journey-level-steps -> INTERIM
     * - query_subgoalCreation -> ENGINE
     */

    /**
     * 0️⃣ container-level-steps
     * - oslo-steps/steps -> CONFIG
     * - oslo-steps/states -> CONFIG
     * - oslo-steps/shapes -> CONFIG
     * - step-reasoning -> ENGINE
     * - help -> ENGINE
     * - createPattern -> ENGINE
     * - query_containerStepToGPSDescription -> ENGINE
     */

    /**
     * 1️⃣ shortContainerDescriptions
     * - container-level-steps -> INTERIM
     * - knowledge -> ENGINE
     * - Q pregeneration -> ENGINE
     */

    /**
     * 1️⃣ block_personalInfo
     * - selected_PersonalInfo -> GENERATED FOR CONTAINER
     * - journey-level-steps -> INTERIM
     * - query_creationOfBlockingInfo -> ENGINE
     */

    /**
     * -------- PER CONTAINER
     */

    /**
     * 3️⃣ component_provideCitizenNameManually
     * - gps-plugin_modified_noPermutations -> ENGINE
     * - knowledge -> ENGINE
     * - personalInfo -> RUNTIME
     * - extraRule_citizenName -> INTERIM
     * - util/graph -> ENGINE
     * - selectedSteps_citizenName -> INTERIM
     * - oslo-steps/steps -> CONFIG
     * - Q createdGoal_citizenName -> INTERIM
     */

    /**
     * 1️⃣ extraRule_citizenName
     * - selected_CitizenName -> GENERATED FOR CONTAINER
     * - container-level-steps -> INTERIM
     * - query_creationOfRuleForMissingData -> ENGINE
     */

    /**
     * 2️⃣ selectedSteps_citizenName
     * - component-level-steps -> INTERIM
     * - shortComponentDescriptions -> INTERIM
     * - createdGoal_citizenName -> INTERIM
     * - preselection -> ENGINE
     * - knowledge -> ENGINE
     * - block_citizenName -> INTERIM
     * - query_preselection -> ENGINE
     */

    /**
     * 1️⃣ createdGoal_citizenName
     * - selected_CitizenName -> GENERATED FOR CONTAINER
     * - container-level-steps -> INTERIM
     * - query_subgoalCreation -> ENGINE
     */

    /**
     * 0️⃣ component-level-steps
     * - oslo-steps/steps -> CONFIG
     * - oslo-steps/states -> CONFIG
     * - oslo-steps/shapes -> CONFIG
     * - step-reasoning -> ENGINE
     * - help -> ENGINE
     * - createPattern -> ENGINE
     * - query_componentStepToGPSDescription -> ENGINE
     */

    /**
     * 1️⃣ shortComponentDescriptions
     * - component-level-steps -> INTERIM
     * - knowledge -> ENGINE
     * - Q pregeneration -> ENGINE
     */

    /**
     * 1️⃣ block_citizenName
     * - selected_CitizenName -> GENERATED FOR CONTAINER
     * - container-level-steps -> INTERIM
     * - query_creationOfBlockingInfo -> ENGINE
     */
}

async function reasonJourneyLevelSteps(data, baseFolder) {
    const produceBase = {
        data: [
            "rules/oslo-steps/step-reasoning.n3",
            "rules/util/list.n3",
            "rules/shacl/createPattern.n3",
        ].concat(data),
        "eye:flags": [
            "--quantify http://josd.github.io/.well-known/genid/",
        ],
        query: "rules/oslo-steps/query_journeyStepToGPSDescription.n3",
    }
    const output = `${baseFolder}/steps_journey_level.n3`;
    await _cached(output, produceBase);
    return output;
}

async function reasonContainerLevelSteps(data, baseFolder) {
    const produceBase = {
        data: [
            "rules/oslo-steps/step-reasoning.n3",
            "rules/util/list.n3",
            "rules/shacl/createPattern.n3",
        ].concat(data),
        "eye:flags": [
            "--quantify http://josd.github.io/.well-known/genid/",
        ],
        query: "rules/oslo-steps/query_containerStepToGPSDescription.n3",
    }
    const output = `${baseFolder}/steps_container_level.n3`;
    await _cached(output, produceBase);
    return output;
}

async function reasonComponentLevelSteps(data, baseFolder) {
    const produceBase = {
        data: [
            "rules/oslo-steps/step-reasoning.n3",
            "rules/util/list.n3",
            "rules/shacl/createPattern.n3",
        ].concat(data),
        "eye:flags": [
            "--quantify http://josd.github.io/.well-known/genid/",
        ],
        query: "rules/oslo-steps/query_componentStepToGPSDescription.n3",
    }
    const output = `${baseFolder}/steps_component_level.n3`;
    await _cached(output, produceBase);
    return output;
}

async function reasonJourneyGoal(data, goalStates, baseFolder) {
    const goalStatePath = `${baseFolder}/goal_journey_state.n3`;
    await fs.writeFile(path.resolve(basePath, goalStatePath), goalStates.map(s => `<${s}> a <https://example.org/ns/example#goalState> .`).join('\n'), 'utf8');
    const produceBase = {
        data: [
            "rules/oslo-steps/step-reasoning.n3",
            "rules/util/list.n3",
            "rules/shacl/createPattern.n3",
            goalStatePath,
        ].concat(data),
        "eye:flags": [
            "--quantify http://josd.github.io/.well-known/genid/",
        ],
        query: "rules/oslo-steps/query_journeyGoalToGPSPath.n3",
    }
    const output = `${baseFolder}/goal_journey.n3`;
    await _cached(output, produceBase);
    return output;
}

async function reasonShortStepDescriptions(data, baseFolder, label) {
    const produceBase = {
        data: [
            "scenarios/knowledge.n3",
        ].concat(data),
        query: "rules/workflow-composer/preselection/pregeneration.n3",
    }
    const output = `${baseFolder}/short_step_descriptions_${label}.n3`;
    await _cached(output, produceBase);
    return output;
}

async function reasonSelectedSteps(data, baseFolder, label, type) {
    const produceBase = {
        data: [
            "rules/workflow-composer/preselection/preselection.n3",
            "scenarios/knowledge.n3",
        ].concat(data),
        query: "rules/workflow-composer/preselection/query_preselection.n3",
    }
    const output = `${baseFolder}/selected_steps_${type}_${label}.n3`;
    await _cached(output, produceBase);
    return output;
}

async function reasonJourney(data, query, baseFolder) {
    const produceBase = {
        data: [
            "rules/workflow-composer/gps-plugin_modified_noPermutations.n3",
            "scenarios/knowledge.n3",
        ].concat(data),
        query,
    }
    const output = `${baseFolder}/reason_journey.n3`;
    await _cached(output, produceBase, true);
    return output;
}

async function parsePaths(pathsPath) {
    const contents = await fs.readFile(path.resolve(basePath, pathsPath), 'utf8');
    const mimeType = 'text/turtle'
    const store = $rdf.graph()
    const GPS = Namespace("http://josd.github.io/eye/reasoning/gps/gps-schema#")
    const EX = Namespace("https://example.org/ns/example#")
    $rdf.parse(contents, store, `file://${pathsPath}`, mimeType)
    const paths = store.match(undefined, GPS('path'), undefined).map(t => t.object);
    const steps = {};
    for (const pathList of paths) {
        const stepList = pathList.elements[0].elements;
        for (const step of stepList) {
            if (step.elements && step.elements[0].value === 'unorderedList') {
                for (const nestedStep of step.elements[1].elements) {
                    steps[nestedStep.value] = nestedStep;
                }
            } else {
                steps[step.value] = step;
            }
        }
    }
    return Object.values(steps);
}

async function reasonStep(parentLevelStep, stepsPath, descriptionsPath, parentStepsPath, config, type, index = {}) {
    const parentStepName = parentLevelStep.value.split('#')[1];
    // 0️⃣
    const parentSelectedPath = await generateSelected(parentLevelStep, config.baseFolder, parentStepName, type)

    // 1️⃣
    const parentBlockPath = await reasonBlock([parentSelectedPath, parentStepsPath], config.baseFolder, parentStepName, type)
    const parentGoalPath = await reasonGoal([parentSelectedPath, parentStepsPath], config.baseFolder, parentStepName, type)
    const parentExtraRulePath = await reasonExtraRule([parentSelectedPath, parentStepsPath], config.baseFolder, parentStepName, type)

    // 2️⃣
    const selectedStepsPath = await reasonSelectedSteps([stepsPath, descriptionsPath, parentGoalPath, parentBlockPath], config.baseFolder, parentStepName, type)

    // 3️⃣
    index.features[`${type}_${parentStepName}`] = {
        description: `${type} level paths for ${parentStepName}`,
        inference: {
            data: [
                selectedStepsPath, config.oslo.steps, config.personalInfo, parentExtraRulePath,
                "rules/workflow-composer/gps-plugin_modified_noPermutations.n3",
                "scenarios/knowledge.n3",
                "rules/util/graph.n3",
            ],
            query: parentGoalPath
        }
    }
    return await reasonPaths([selectedStepsPath, config.oslo.steps, config.personalInfo, parentExtraRulePath], parentGoalPath, config.baseFolder, parentStepName, type);
}

async function generateSelected(step, baseFolder, label, type) {
    const output = `${baseFolder}/select_${type}_${label}.n3`;
    if (cache[output]) {
        return output;
    }
    const goal = `
@prefix step: <http://localhost:8000/steps#>.
@prefix : <http://example.org#> .

<${step.value}> :findSubpath true.
    `;
    await fs.writeFile(path.resolve(basePath, output), goal, 'utf8');
    cache[output] = output;
    return output;
}

async function reasonBlock(data, baseFolder, label, type) {
    const produceBase = {
        data,
        query: "rules/workflow-composer/subgoals/query_creationOfBlockingInfo.n3",
    }
    const output = `${baseFolder}/block_${type}_${label}.n3`;
    await _cached(output, produceBase);
    return output;
}

async function reasonGoal(data, baseFolder, label, type) {
    const produceBase = {
        data,
        "eye:flags": [
            "--quantify http://josd.github.io/.well-known/genid/",
        ],
        query: "rules/workflow-composer/subgoals/query_subgoalCreation.n3",
    }
    const output = `${baseFolder}/goal_${type}_${label}.n3`;
    await _cached(output, produceBase);
    return output;
}

async function reasonExtraRule(data, baseFolder, label, type) {
    const produceBase = {
        data,
        query: "rules/workflow-composer/query_creationOfRuleForMissingData.n3",
    }
    const output = `${baseFolder}/extra_rule_${type}_${label}.n3`;
    await _cached(output, produceBase);
    return output;
}

async function reasonPaths(data, query, baseFolder, label, type) {
    const produceBase = {
        data: [
            "rules/workflow-composer/gps-plugin_modified_noPermutations.n3",
            "scenarios/knowledge.n3",
            "rules/util/graph.n3",
        ].concat(data),
        query,
    }
    const output = `${baseFolder}/reason_paths_${type}_${label}.n3`;
    await _cached(output, produceBase, true);
    return output;
}

async function _cached(output, config, alwaysReason = false) {
    // console.log(`Working for output ${output}`)
    if (!alwaysReason && await fileExists(path.resolve(basePath, output))) {
        if (!DEV_ENV) {
            cache[output] = output;
        }
    }
    if (cache[output]) {
        return;
    }
    config.output = output;
    await _reason(config);
    cache[output] = true;
    return;
}

async function _reason(step) {
    step.basePath = basePath;
    const { stdout } = await eyePromise(step);
    return await fs.writeFile(path.resolve(step.basePath, step.output), stdout, 'utf8');
}

async function validateTtl(ttlPath) {
    const ttl = await fs.readFile(path.resolve(__dirname, '../', ttlPath), 'utf8');
    const readable = streams.fromString(ttl);
    return new Promise((resolve, reject) => {
        readable.pipe(ttl_read())
            .on('error', (e_read) => {
                reject(new Error(`${ttlPath} is an invalid Turtle document: ${e_read.message}`));
            })
            .on('eof', () => {
                resolve();
            });
    });

}

const fileExists = async path => !!(await fs.stat(path).catch(e => false));
