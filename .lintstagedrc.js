require('dotenv').config()
const path = require('path')

const erbLintPath = (files) => `bundle exec erblint -a ${files}`;
const rubocopRubyPath = (files) => `bundle exec rubocop -c ./.rubocop.yml -a ${files}`;
const rubocopJsonPath = (files) => `bundle exec rubocop -c ./.rubocop-json.yml -a ${files}`;

module.exports = {
  "app/**/*.{js,es6,jsx,scss,css}": [
    "./node_modules/prettier/bin-prettier.js --trailing-comma --single-quote es5 --write",
    "git add"
  ],
  "app/**/*.html.erb": absolutePaths => {
    const cwd = process.cwd();
    const relativePaths = absolutePaths.map(file => path.relative(cwd, file));
    return [
      erbLintPath(relativePaths.join(' ')),
      `git add ${absolutePaths.join(' ')}`
    ];
  },
  "app/**/*.json.jbuilder" : absolutePaths => {
    const cwd = process.cwd();
    const relativePaths = absolutePaths.map(file => path.relative(cwd, file));
    return [
      rubocopJsonPath(relativePaths.join(' ')),
      `git add ${absolutePaths.join(' ')}`
    ];
  },
  "{app,test,config,db,lib,spec}/**/*.rb": absolutePaths => {
    const cwd = process.cwd();
    const relativePaths = absolutePaths.map(file => path.relative(cwd, file));
    return [
      rubocopRubyPath(relativePaths.join(' ')),
      `git add ${absolutePaths.join(' ')}`
    ];
  },
  "lib/**/*.rake": absolutePaths => {
    const cwd = process.cwd();
    const relativePaths = absolutePaths.map(file => path.relative(cwd, file));
    return [
      rubocopRubyPath(relativePaths.join(' ')),
      `git add ${absolutePaths.join(' ')}`
    ];
  },
  "Gemfile": absolutePaths => {
    const cwd = process.cwd();
    const relativePaths = absolutePaths.map(file => path.relative(cwd, file));
    return [
      rubocopRubyPath(relativePaths.join(' ')),
      `git add ${absolutePaths.join(' ')}`
    ];
  }
}