import {
  proj4,
  itowns,
  AllWidget,
  FileUtil,
  Widget,
  InputManager,
  addBaseMapLayer,
} from "@ud-viz/browser";
import { Utils } from "./Utils";

const myUtils = new Utils();
const streaming = Boolean(true);
let sources;
let dynamicLayer;

console.log("Folder in .env is ", FOLDER);

FileUtil.loadJSON("../assets/config/config.json").then((config) => {
  // http://proj4js.org/
  // define a projection as a string and reference it that way
  // the definition of the projection should be in config TODO_ISSUE
  proj4.default.defs(
    config["crs"],
    "+proj=lcc +lat_1=45.25 +lat_2=46.75" +
      " +lat_0=46 +lon_0=3 +x_0=1700000 +y_0=5200000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
  );

  const extent = new itowns.Extent(
    config["crs"],
    config["extent"]["min_x"],
    config["extent"]["max_x"],
    config["extent"]["min_y"],
    config["extent"]["max_y"]
  );

  const app = new AllWidget(extent, config["all_widget"], {
    maxSubdivisionLevel: 10,
  });

  // set zoom in factor
  app.frame3DPlanar.itownsView.controls.zoomInFactor = 1.1;
  app.frame3DPlanar.itownsView.controls.zoomOutFactor =
    1 / app.frame3DPlanar.itownsView.controls.zoomInFactor;

  const newCameraPosition = extent.center();
  app.frame3DPlanar.camera.position.set(
    newCameraPosition.x,
    newCameraPosition.y,
    config["camera"]["z"]
  );
  app.frame3DPlanar.camera.rotation.set(0, 0, -Math.PI / 1.99);
  app.frame3DPlanar.camera.updateProjectionMatrix();
  app.frame3DPlanar.itownsView.notifyChange(app.frame3DPlanar.camera);

  //   ////// SLIDESHOW MODULE
  const slideShow = new Widget.SlideShow(
    app.frame3DPlanar.itownsView,
    config["slideShow"],
    extent,
    new InputManager()
  );
  app.addWidgetView("slideShow", slideShow);

  // layers
  addBaseMapLayer(config["baseMap"], app.frame3DPlanar.itownsView, extent);

  // no streaming
  if (!streaming) {
    sources = getSourceListfromGeojsonCollection(config["dynamic_layer"]);
    console.log("Nb initial sources " + sources.length);
    myUtils.foo(app.frame3DPlanar.itownsView);
    setTimeout(() => {
      runTimelapse(app.frame3DPlanar.itownsView, dynamicLayer, sources, 1000);
    }, 200);
  } else {
    const wSocket = new WebSocket("ws://localhost:6868/");

    WebSocket.prototype.sendMessage = function (message) {
      this.send(message);
      console.log("Message sent: " + message);
    };

    const modelPath = FOLDER + "/ReAgent/models/Gratte_Ciel_Demo.gaml";
    const experimentName = "Demo";

    const species1Name = "people";
    const attribute1Name = "type";
    const species2Name = "building";
    const attribute2Name = "type";
    // const species3Name = "road";
    // const attribute3Name = "type";

    let geojson;
    let gama_layer;
    let _source;

    let socket_id = 0;
    let exp_id = 0;

    let layer0added = 0;
    let layer1added = 0;
    // let layer2added = 0;

    const queue = [];
    let request = "";
    let result = "";
    let updateSource;
    const executor_speed = 1;
    const executor = setInterval(() => {
      if (queue.length > 0 && request === "") {
        request = queue.shift();
        request.exp_id = exp_id;
        request.socket_id = socket_id;
        wSocket.send(JSON.stringify(request));
        wSocket.onmessage = function (event) {
          // console.log("message recieved");
          const msg = event.data;
          if (!(event.data instanceof Blob)) {
            if (request.callback) {
              request.callback(msg);
            } else {
              request = "";
            }
          }
        };
      }
    }, executor_speed);

    wSocket.onclose = function () {
      clearInterval(executor);
      clearInterval(updateSource);
    };

    wSocket.onopen = function (event) {
      let cmd = {
        type: "launch",
        model: modelPath,
        experiment: experimentName,
        callback: function (e) {
          result = JSON.parse(e);
          if (result.exp_id) exp_id = result.exp_id;
          if (result.socket_id) socket_id = result.socket_id;
          request = "";
        },
      };
      queue.push(cmd);
      cmd = {
        type: "play",
        socket_id: socket_id,
        exp_id: exp_id,
      };
      queue.push(cmd);

      // STATIC LAYER

      // Building
      cmd = {
        type: "output",
        species: species2Name,
        attributes: [attribute2Name],
        crs: "EPSG:3946",
        socket_id: socket_id,
        exp_id: exp_id,
        callback: function (message) {
          // console.log("adding building");
          if (!(typeof event.data == "object")) {
            geojson = null;
            geojson = JSON.parse(message);
            if (layer1added) {
              app.frame3DPlanar.itownsView.removeLayer("BUILDING");
            }
            layer1added = 1;

            _source = new itowns.FileSource({
              fetchedData: geojson,
              crs: "EPSG:3946",
              format: "application/json",
            });

            gama_layer = new itowns.FeatureGeometryLayer("BUILDING", {
              // Use a FileSource to load a single file once
              source: _source,
              transparent: true,
              opacity: 1,
              style: new itowns.Style({
                fill: {
                  extrusion_height: 10,
                  color: myUtils.setBuildingColor,
                },
              }),
            });

            app.frame3DPlanar.itownsView.addLayer(gama_layer);

            // app.update3DView();
          }
          request = ""; // IMPORTANT FLAG TO ACCOMPLISH CURRENT TRANSACTION
        },
      };
      queue.push(cmd);
      //road
      /*cmd = {
      'type': 'output',
      'species': species3Name,
      'attributes': [attribute3Name],
      "crs": 'EPSG:3946',
      'socket_id': socket_id,
      'exp_id': exp_id,
      "callback": function (message) {
        if (typeof event.data == "object") {
        } else {
          geojson = null;
          geojson = JSON.parse(message);
          if (layer2added) {
            app.frame3DPlanar.itownsView.removeLayer("ROAD");
          }
          layer2added = 1;

          _source = new itowns.FileSource({
            fetchedData: geojson,
            crs: 'EPSG:3946',
            format: 'application/json',
          });

          gama_layer = new itowns.FeatureGeometryLayer('ROAD', {
            source: _source,
            transparent: true,
            opacity: 1,
            style: new itowns.Style({
              stroke: {
                color: myUtils.setRoadColor,
              }
            })
          });

          app.frame3DPlanar.itownsView.addLayer(gama_layer);

          app.update3DView();
        }
        request = "";//IMPORTANT FLAG TO ACCOMPLISH CURRENT TRANSACTION
      }
    };*/
      // queue.push(cmd);

      // DYNAMIC LAYER (PEOPLE)
      let countIDLayer = 0;
      updateSource = setInterval(() => {
        cmd = {
          type: "output",
          species: species1Name,
          attributes: [attribute1Name],
          crs: "EPSG:3946",
          socket_id: socket_id,
          exp_id: exp_id,
          callback: function (message) {
            // console.log("adding people");
            if (!(typeof event.data == "object")) {
              geojson = null;
              geojson = JSON.parse(message);
              if (layer0added) {
                // gama_layer.delete();
                app.frame3DPlanar.itownsView.removeLayer(countIDLayer);
              }
              layer0added = 1;

              _source = new itowns.FileSource({
                fetchedData: geojson,
                crs: "EPSG:3946",
                format: "application/json",
              });
              countIDLayer++;
              gama_layer = new itowns.FeatureGeometryLayer(countIDLayer, {
                // Use a FileSource to load a single file once
                source: _source,
                transparent: true,
                opacity: 1,
                style: new itowns.Style({
                  fill: {
                    // base_altitude: setAltitude,
                    extrusion_height: 10,
                    color: myUtils.setPeopleColor,
                  },
                }),
              });
              app.frame3DPlanar.itownsView.addLayer(gama_layer);
              app.frame3DPlanar.itownsView.notifyChange(
                app.frame3DPlanar.camera
              );
            }
            request = ""; // IMPORTANT FLAG TO ACCOMPLISH CURRENT TRANSACTION
          },
        };
        queue.push(cmd);
      }, 200);
    };

    wSocket.onerror = function () {
      console.log("An error occurred. Sorry for that.");
    };
  }
});

/*
  Read all GeoJson stored in the directory (geojsonCollectionUrl)
  They are stored as itowns.FileSource
*/
function getSourceListfromGeojsonCollection(parameters) {
  const sourceList = new Array();
  for (let i = 0; i < parameters["step"]; i++) {
    const _source = new itowns.FileSource({
      url: parameters["geojsonCollectionUrl"] + i + ".geojson",
      crs: parameters["crs"],
      format: parameters["format"],
    });
    sourceList.push(_source);
  }
  return sourceList;
}

/**
 * Run a simulation using a geojsonCollection.
 * @param itownsView
 * @param layer The FeatureGeometryLayer that will be updated (filled with step 0)
 * @param stepTime Time between each step of the timelapse
 */
function runTimelapse(itownsView, layer, _sources, stepTime) {
  let step = 0;
  const interval = setInterval(() => {
    if (step > _sources.length - 1) {
      clearInterval(interval);
      console.log("Simulation Done with " + step + " Steps");
    } else {
      if (step > 0) {
        itownsView.removeLayer("current_layer" + (step - 1));
      }
      layer = new itowns.FeatureGeometryLayer("current_layer" + step, {
        source: _sources[step],
        transparent: true,
        batchId: function (property) {
          return parseInt(property.geojson.id);
        },
        opacity: 1,
        style: new itowns.Style({
          fill: {
            extrusion_height: 1,
            color: myUtils.setPeopleColor,
          },
        }),
      });
      itownsView.addLayer(layer);
      // app.update3DView();
    }
    step += 1;
  }, stepTime);
}
