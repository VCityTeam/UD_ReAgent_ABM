import {
  proj4,
  itowns,
  Frame3DPlanar,
  FileUtil,
  Widget,
  InputManager,
  addBaseMapLayer,
  THREEUtil,
  THREE,
} from "@ud-viz/browser";
import { Utils } from "./Utils";
import { Maptastic } from "./vendor/maptastic.min.js";

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
  // config["extent"]["min_y"] + 100

  const frame3DPlanar = new Frame3DPlanar(extent, {
    maxSubdivisionLevel: 10,
    hasItownsControls: false,
  });

  THREEUtil.addLights(frame3DPlanar.scene);
  THREEUtil.initRenderer(frame3DPlanar.renderer, new THREE.Color("red"));

  const widthExtent = extent.east - extent.west;
  const heightExtent = extent.north - extent.south;
  const fov = frame3DPlanar.camera.fov * (Math.PI / 180); // fov radian
  const fovh = 2 * Math.atan(Math.tan(fov / 2) * frame3DPlanar.camera.aspect);
  const dx = Math.abs(heightExtent / 2 / Math.tan(fovh / 2));
  const dy = Math.abs(widthExtent / 2 / Math.tan(fov / 2));
  const fitElevation = Math.max(dx, dy);

  console.log("camera elevation is ", fitElevation);
  console.log("camera fov is ", frame3DPlanar.camera.fov);
  console.log("camera fov is ", frame3DPlanar.scene);

  const newCameraPosition = extent.center();
  frame3DPlanar.camera.position.set(
    newCameraPosition.x,
    newCameraPosition.y,
    fitElevation
  );
  frame3DPlanar.camera.rotation.set(0, 0, -Math.PI / 2);
  frame3DPlanar.camera.updateProjectionMatrix();
  frame3DPlanar.itownsView.notifyChange(frame3DPlanar.camera);

  // debug controls
  if (false) {
    document.addEventListener("keydown", function (event) {
      if (event.code == "KeyP") {
        const cameraPos = frame3DPlanar.getCamera().position.clone();
        frame3DPlanar
          .getCamera()
          .position.set(cameraPos.x, cameraPos.y, cameraPos.z + 100);
      }
      if (event.code == "KeyO") {
        const cameraPos = frame3DPlanar.getCamera().position.clone();
        frame3DPlanar
          .getCamera()
          .position.set(cameraPos.x, cameraPos.y, cameraPos.z - 10);
      }
      if (event.code == "ArrowUp") {
        const cameraPos = frame3DPlanar.getCamera().position.clone();
        frame3DPlanar
          .getCamera()
          .position.set(cameraPos.x + 10, cameraPos.y, cameraPos.z);
      }
      if (event.code == "ArrowDown") {
        const cameraPos = frame3DPlanar.getCamera().position.clone();
        frame3DPlanar
          .getCamera()
          .position.set(cameraPos.x - 10, cameraPos.y, cameraPos.z);
      }
      if (event.code == "ArrowLeft") {
        const cameraPos = frame3DPlanar.getCamera().position.clone();
        frame3DPlanar
          .getCamera()
          .position.set(cameraPos.x, cameraPos.y + 10, cameraPos.z);
      }
      if (event.code == "ArrowRight") {
        const cameraPos = frame3DPlanar.getCamera().position.clone();
        frame3DPlanar
          .getCamera()
          .position.set(cameraPos.x, cameraPos.y - 10, cameraPos.z);
      }
      console.log("camera z ", frame3DPlanar.camera.position.z);
      frame3DPlanar.camera.updateProjectionMatrix();
      frame3DPlanar.itownsView.notifyChange(frame3DPlanar.camera);
    });
  }

  //   ////// SLIDESHOW MODULE
  const slideShow = new Widget.SlideShow(
    frame3DPlanar.itownsView,
    config["slideShow"],
    extent,
    new InputManager()
  );
  slideShow.parentElement = frame3DPlanar.ui;

  let slideShowActive = false;
  window.addEventListener("keyup", (event) => {
    if (event.key == "a") {
      if (slideShowActive) {
        slideShow.disable();
      } else {
        slideShow.enable();
      }
      slideShowActive = !slideShowActive;
    }
  });

  // layers
  addBaseMapLayer(config["baseMap"], frame3DPlanar.itownsView, extent);

  // keystone
  Maptastic("viewerDiv");

  // simulation
  if (!streaming) {
    sources = getSourceListfromGeojsonCollection(config["dynamic_layer"]);
    console.log("Nb initial sources " + sources.length);
    myUtils.foo(frame3DPlanar.itownsView);
    setTimeout(() => {
      runTimelapse(frame3DPlanar.itownsView, dynamicLayer, sources, 1000);
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
        "type": "load",
        model: modelPath,
        experiment: experimentName,
        callback: function (e) {
          result = JSON.parse(e);
          if (result.content) exp_id = result.content;
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
        'type': 'expression',
        // 'species': species2Name,
        // 'attributes': [attribute2Name],
        // "crs": 'EPSG:3946',
        "expr":"to_geojson(" + species2Name + ",\"EPSG:3946\",[\"" + attribute2Name + "\"])",
        "escaped":true,
        socket_id: socket_id,
        exp_id: exp_id,
        callback: function (message) {
          // console.log("adding building");
          if (!(typeof event.data == "object")) {
            geojson = null;
            geojson = JSON.parse(message).content;
            if (layer1added) {
              frame3DPlanar.itownsView.removeLayer("BUILDING");
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
                  extrusion_height: 0.1,
                  color: myUtils.setBuildingColor,
                },
              }),
            });

            frame3DPlanar.itownsView.addLayer(gama_layer);

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
            frame3DPlanar.itownsView.removeLayer("ROAD");
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

          frame3DPlanar.itownsView.addLayer(gama_layer);

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
          // 'type': 'output',
          // 'species': species1Name,
          // 'attributes': [attribute1Name],
          // "crs": 'EPSG:3946',
        'type': 'expression', 
        "expr":"to_geojson(" + species1Name + ",\"EPSG:3946\",[\"" + attribute1Name + "\"])",
        "escaped":true,
          socket_id: socket_id,
          exp_id: exp_id,
          callback: function (message) {
            // console.log("adding people");
            if (!(typeof event.data == "object")) {
              geojson = null;
              geojson = JSON.parse(message).content;
              if (layer0added) {
                // gama_layer.delete();
                frame3DPlanar.itownsView.removeLayer(countIDLayer);
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
                    extrusion_height: 0.1,
                    color: myUtils.setPeopleColor,
                  },
                }),
              });
              frame3DPlanar.itownsView.addLayer(gama_layer);
              frame3DPlanar.itownsView.notifyChange(frame3DPlanar.camera);
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
            extrusion_height: 0.1,
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
