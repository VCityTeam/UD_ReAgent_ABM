const path = require("path");
const mode = process.env.NODE_ENV;
const debugBuild = mode === "development";
const webpack = require("webpack");

let outputPath;
if (debugBuild) {
  outputPath = path.resolve(__dirname, "dist/debug");
} else {
  outputPath = path.resolve(__dirname, "dist/release");
}

module.exports = () => {
  const rules = [
    {
      // We also want to (web)pack the style files:
      test: /\.css$/,
      use: ["style-loader", "css-loader"],
    },
  ];

  const folderPath = path.resolve(__dirname, "../");
  console.log(folderPath);

  const plugins = [
    new webpack.DefinePlugin({
      FOLDER: "'" + folderPath + "'", // indicate to webpack to replace FOLDER by its value at compile time
    }),
  ];

  const config = {
    mode: mode,
    entry: [path.resolve(__dirname, "./src/bootstrap.js")],
    output: {
      path: outputPath,
      filename: "reagent.js",
    },
    module: {
      rules: rules,
    },
    plugins: plugins,
  };

  if (debugBuild) config.devtool = "source-map";

  return config;
};
