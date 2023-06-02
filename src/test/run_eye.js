const path = require('path');
const eyePromise = require('../services/reasoning.js').eyePromise;

const basePath = path.resolve(__dirname, '../..');

main();

/**
 * Just a small testing function to test out some EYE commands
 */
async function main() {
    const config = {
        data: [
            "rules/oslo-steps/step-reasoning.n3",
            "rules/util/help.n3",
            "rules/shacl/createPattern.n3",
            "scenarios/_example1/steps.ttl",
            "scenarios/_example1/shapes.ttl",
            "scenarios/_example1/states.ttl",
            "_output/example1/goal_journey_state.n3",
        ],
        "eye:flags": [
            "--quantify http://josd.github.io/.well-known/genid/",
            // "--pass",
        ],
        query: "rules/oslo-steps/createGoal_query.n3",
    }
    config.basePath = basePath;
    const { stdout } = await eyePromise(config);
    console.log(stdout);
}
