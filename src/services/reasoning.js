/* eslint-disable no-useless-escape */
/* eslint-disable prefer-promise-reject-errors */
/**
 * Builds the command necessary to run the reasoner.
 *
 * Original author: Cristian Vasquez
 *
 * Source: https://github.com/cristianvasquez/HES-Agent/blob/master/readme.md
 * @module Services/Reasoning
 */

const path = require('path')
const exec = require('child-process-promise').exec
const Glob = require('glob').Glob

const config = {
  serverOptions: {
    verbose: false,
  },
  eyeOptions: {
    consoleLogging: true,
    command_arguments: { maxBuffer: 1024 * 500 },
    eyePath: 'docker run --rm -v "/c/Users/Ben/Ben/Work/iMinds/Projects/2019 09 SEMIC - CGI/git/n3-mapping-rules/demo":/demo custom-eye',
    defaultFlags: ['--nope']
  }
}
/**
 * @typedef {Object} module:Reasoning.Inference
 * @property {String} query - Path to N3 file containing the query to be passed to the reasoner
 * @property {String[]} data - Array of paths to N3 files containing the auxiliary data to be used by the reasoner
 */

/**
 * Wrapper for "invokeEye" that builds the necessary command for you.
 *
 * @param {Inference} inference - Object containing data to be used by the reasoner
 * @returns {Promise} - Promise resolving to the output of the reasoner
 * @see {@link invokeEye}
 */
function eyePromise(inference) {
  return invokeEye(getEyeCommand(inference), true)
}

/**
 * Build up a command for eye, from an expanded inference description
 *
 * @param {Inference} inference - Object containing data to be used by the reasoner
 * @returns {String} - command string to be passed to {@link Reasoning.invokeEye}
 */
function getEyeCommand(inference) {
  if (config.serverOptions.verbose) {
    console.log(JSON.stringify(inference, null, 2))
  }
  let command = config.eyeOptions.eyePath

  /**
     * Handle flags
     */
  let flags = config.eyeOptions.defaultFlags.join(' ')
  if (inference.options) {
    if (inference.options.proof) {
      flags = ''
    }
  } else if (inference['eye:flags']) {
    if (Array.isArray(inference['eye:flags'])) {
      flags = flags + ' ' + inference['eye:flags'].join(' ')
    } else {
      flags = flags + ' ' + inference['eye:flags']
    }
  }
  command = command + ' ' + flags

  const basePath = inference.basePath ? inference.basePath : path.resolve(__dirname, '../../');

  /**
     * Handle data
     */
  if (inference.data) {
    const dataLocations = []

    if (Array.isArray(inference.data)) {
      for (const data of inference.data) {
        // trace the location with glob, if the path is relative and refers to multiple files it is handled
        const files = new Glob(basePath + '/' + data, { nodir: true, mark: true, sync: true })
        if (files.found && files.found.length > 0) {
          files.found.forEach(x => dataLocations.push(path.relative(basePath, x).replace(/\\/g, '/')))
        }
      }
    } else {
      const files = new Glob(inference.data, { nodir: true, mark: true, sync: true })
      if (files.found && files.found.length > 0) {
        files.found.forEach(x => dataLocations.push(x))
      }
    }

    // replace old date locations with the new ones, so it contains paths to /* locations
    inference.data = dataLocations

    // build the data part of the command
    command = command + ' ' + inference.data.join(' ')
  }

  /**
     * Handle query
     */
  if (inference.query) {
    if (Array.isArray(inference.query)) {
      if (inference.query.length === 1) {
        command = command + ' --query ' + inference.query[0]
      } else {
        throw new Error('cannot handle multiple queries')
      }
    } else {
      command = command + ' --query ' + inference.query
    }
  }

  /**
     * Handle proof
     */
  // proof only supports urls by the moment
  if (inference.proof) {
    if (!inference.proof) {
      throw new Error('href for proof not specified')
    }
    if (Array.isArray(inference.proof)) {
      command = command + ' --proof ' + inference.proof.join(' --proof ')
    } else {
      command = command + ' --proof ' + inference.proof
    }
  }

  if (config.serverOptions.verbose) {
    console.log(command)
  }

  return command
}

/**
 * Executes the reasoner program using both the command string and the options set inside the server config
 *
 * @param {String} command - Command to be run
 * @param {Boolean} fullOutput - Display full output or not, defaults to true
 * @returns {Promise} - Promise resolving to an object containing the stdout and stderr streams of the reasoner
 */

function invokeEye(command, fullOutput = true) {
  return new Promise(function (resolve, reject) {
    if (config.serverOptions.verbose) {
      console.log(command)
    }
    exec(command, config.eyeOptions.command_arguments)
      .then(function (result) {
        const stdout = result.stdout
        const stderr = result.stderr

        // EYE do not show signature as usual.
        if (!stderr.match(eyeSignatureRegex)) {
          reject({
            stdout: result.stdout,
            stderr: result.stderr,
            error: 'No match for EYE signature'
          })
        }

        // An error detected
        const errorMatch = stderr.match(errorRegex)
        if (errorMatch) {
          reject({
            stdout: result.stdout,
            stderr: result.stderr,
            error: errorMatch
          })
        }

        if (fullOutput) {
          resolve({
            stdout: result.stdout,
            stderr: result.stderr
          })
        } else {
          if (config.eyeOptions.consoleLogging) { console.log(stdout) }
          resolve(clean(stdout))
        }
      })
      .catch(function (err) {
        console.error('Command line exception :' + err)
        reject({
          error: err
        })
      })
  })
}

// taken from https://github.com/RubenVerborgh/EyeServer
const commentRegex = /^#.*$\n/mg
const prefixDeclarationRegex = /^@prefix|PREFIX ([\w\-]*:) <([^>]+)>\.?\n/g
const eyeSignatureRegex = /^(Id: euler\.yap|EYE)/m
const errorRegex = /^\*\* ERROR \*\*\s*(.*)$/m

// taken from https://github.com/RubenVerborgh/EyeServer
function clean(n3) {
  // remove comments
  n3 = n3.replace(commentRegex, '')

  // remove prefix declarations from the document, storing them in an object
  const prefixes = {}
  n3 = n3.replace(prefixDeclarationRegex, function (match, prefix, namespace) {
    prefixes[prefix] = namespace.replace(/^file:\/\/.*?([^\/]+)$/, '$1')
    return ''
  })

  // remove unnecessary whitespace from the document
  n3 = n3.trim()

  // find the used prefixes
  const prefixLines = []
  for (const prefix in prefixes) {
    const namespace = prefixes[prefix]

    // EYE does not use prefixes of namespaces ending in a slash (instead of a hash),
    // so we apply them manually
    if (namespace.match(/\/$/)) {
      // warning: this could wreck havoc inside string literals
      n3 = n3.replace(new RegExp('<' + escapeForRegExp(namespace) + '(\\w+)>', 'gm'), prefix + '$1')
    }

    // add the prefix if it's used
    // (we conservatively employ a wide definition of "used")
    if (n3.match(prefix)) { prefixLines.push('PREFIX ', prefix, ' <', namespace, '>\n') }
  }

  // join the used prefixes and the rest of the N3
  return !prefixLines.length ? n3 : (prefixLines.join('') + '\n' + n3)
}

function escapeForRegExp(text) {
  return text.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
}

module.exports = {
  getEyeCommand: getEyeCommand,
  eyePromise: eyePromise,
  invokeEye: invokeEye
}
