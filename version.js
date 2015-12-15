var chalk = require('chalk');
var package = require('./package.json');
var semver = require('semver')

var current = semver.clean(process.version);

if (package.engines.node && !semver.satisfies(current, package.engines.node)) {
    console.log(
        chalk.red.bold('** WARNING ** '),
        'You\'re running an incorrect version of node for this project.'
    );

    console.log('You\'re currently running ' + current + '.');
    console.log('You should be using ' + package.engines.node + ' instead.');
    console.log('Shutting it down...')
    process.exit(1)
};