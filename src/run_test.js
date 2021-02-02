const path = require('path');
const fs = require('fs/promises');
const eyePromise = require('./services/reasoning.js').eyePromise;
const $rdf = require('rdflib')
const { Namespace } = $rdf;

const basePath = path.resolve(__dirname, '..');
const cache = {};

main();

async function main() {
    const config = {
        data: [
            "demo/translation/step-reasoning.n3",
            "demo/translation/help.n3",
            "demo/translation/createPattern.n3",
            "demo/_example1/example1_steps.ttl",
            "demo/_example1/example1_shapes.ttl",
            "demo/_example1/example1_states.ttl",
            "demo/_example1/example1_goalState.ttl",
        ],
        "eye:flags": [
            "--quantify http://josd.github.io/.well-known/genid/",
        ],
        query: "demo/translation/createGoal.n3",
    }
    config.basePath = basePath;
    const { stdout } = await eyePromise(config);
    console.log(stdout);
    
}
