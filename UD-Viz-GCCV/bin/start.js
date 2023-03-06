const exec = require("child-process-promise").exec;
const ExpressAppWrapper = require("@ud-viz/node").ExpressAppWrapper;

const app = new ExpressAppWrapper();
app.start({
  folder: "./",
  port: 8000,
});

const printExec = function (result) {
  console.log("stdout: \n", result.stdout);
  console.log("stderr: \n", result.stderr);
};
exec("npm run build").then(printExec);
